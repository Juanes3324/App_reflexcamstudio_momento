import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:url_launcher/url_launcher.dart';

class BookingRequest {
  const BookingRequest({
    required this.serviceIds,
    required this.extraIds,
    required this.scheduledAt,
    required this.isExternalLocation,
    required this.address,
    required this.logistics,
    this.latitude,
    this.longitude,
  });

  final List<String> serviceIds;
  final List<String> extraIds;
  final DateTime scheduledAt;
  final bool isExternalLocation;
  final String address;
  final String logistics;
  final double? latitude;
  final double? longitude;
}

class BookingCheckout {
  const BookingCheckout({
    required this.bookingId,
    required this.reference,
    required this.checkoutUrl,
    required this.totalAmount,
    required this.depositAmount,
  });

  final String bookingId;
  final String reference;
  final Uri checkoutUrl;
  final int totalAmount;
  final int depositAmount;
}

abstract interface class BookingRepository {
  Future<BookingCheckout> createCheckout(BookingRequest request);
  Future<bool> openCheckout(Uri checkoutUrl);
  Stream<String> watchPaymentStatus(String bookingId);
}

class FirebaseBookingRepository implements BookingRepository {
  FirebaseBookingRepository({
    FirebaseFirestore? firestore,
    FirebaseFunctions? functions,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _functions =
           functions ??
           FirebaseFunctions.instanceFor(region: 'southamerica-east1');

  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;
  String? _pendingBookingFingerprint;
  String? _pendingBookingId;

  @override
  Future<BookingCheckout> createCheckout(BookingRequest request) async {
    final serviceIds = request.serviceIds.toList()..sort();
    final extraIds = request.extraIds.toList()..sort();
    final fingerprint = jsonEncode({
      'serviceIds': serviceIds,
      'extraIds': extraIds,
      'scheduledAt': request.scheduledAt.toUtc().toIso8601String(),
      'isExternalLocation': request.isExternalLocation,
      'address': request.address,
      'logistics': request.logistics,
      'latitude': request.latitude,
      'longitude': request.longitude,
    });
    if (_pendingBookingFingerprint != fingerprint) {
      _pendingBookingId = _firestore.collection('bookings').doc().id;
      _pendingBookingFingerprint = fingerprint;
    }
    final bookingId = _pendingBookingId!;
    final callable = _functions.httpsCallable('createWompiCheckout');
    final result = await callable.call({
      'bookingId': bookingId,
      'serviceIds': serviceIds,
      'extraIds': extraIds,
      'scheduledAt': request.scheduledAt.toUtc().toIso8601String(),
      'location': {
        'type': request.isExternalLocation ? 'external' : 'studio',
        'address': request.address,
        if (request.latitude != null) 'latitude': request.latitude,
        if (request.longitude != null) 'longitude': request.longitude,
      },
      'logistics': request.logistics,
    });

    final data = Map<String, dynamic>.from(result.data as Map);
    final url = Uri.tryParse(data['checkoutUrl'] as String? ?? '');
    if (url == null ||
        url.scheme != 'https' ||
        url.host != 'checkout.wompi.co' ||
        data['bookingId'] != bookingId ||
        data['reference'] is! String ||
        data['totalAmount'] is! int ||
        data['depositAmount'] is! int) {
      throw StateError('El servidor devolvió datos de pago inválidos.');
    }

    return BookingCheckout(
      bookingId: bookingId,
      reference: data['reference'] as String,
      checkoutUrl: url,
      totalAmount: data['totalAmount'] as int,
      depositAmount: data['depositAmount'] as int,
    );
  }

  @override
  Future<bool> openCheckout(Uri checkoutUrl) async {
    final opened = await launchUrl(
      checkoutUrl,
      mode: LaunchMode.externalApplication,
    );
    if (opened && _pendingBookingId != null) {
      _pendingBookingFingerprint = null;
      _pendingBookingId = null;
    }
    return opened;
  }

  @override
  Stream<String> watchPaymentStatus(String bookingId) {
    return _firestore.collection('bookings').doc(bookingId).snapshots().map((
      snapshot,
    ) {
      if (!snapshot.exists) {
        throw StateError('No se encontró el estado de esta reserva.');
      }
      final payment = snapshot.data()?['payment'];
      if (payment is! Map || payment['status'] is! String) {
        throw StateError('El estado del pago recibido no es válido.');
      }
      return payment['status'] as String;
    });
  }
}
