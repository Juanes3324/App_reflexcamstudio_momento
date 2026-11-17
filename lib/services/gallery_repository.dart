import 'package:cloud_functions/cloud_functions.dart';

class GallerySession {
  const GallerySession({
    required this.bookingId,
    required this.title,
    required this.category,
    required this.scheduledAt,
    required this.photos,
  });

  final String bookingId;
  final String title;
  final String category;
  final DateTime? scheduledAt;
  final List<Uri> photos;

  String get dateLabel {
    final date = scheduledAt;
    if (date == null) return 'Fecha por confirmar';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String get status => photos.isEmpty ? 'En preparación' : 'Entregada';
}

abstract interface class GalleryRepository {
  Future<List<GallerySession>> listMyGalleries();
}

class FirebaseGalleryRepository implements GalleryRepository {
  FirebaseGalleryRepository({FirebaseFunctions? functions})
    : _functions =
          functions ??
          FirebaseFunctions.instanceFor(region: 'southamerica-east1');

  final FirebaseFunctions _functions;

  @override
  Future<List<GallerySession>> listMyGalleries() async {
    final response = await _functions.httpsCallable('listMyGalleries').call();
    final result = Map<String, dynamic>.from(response.data as Map);
    final galleries = result['galleries'];
    if (galleries is! List) {
      throw StateError(
        'La respuesta de galerías no tiene el formato esperado.',
      );
    }

    return galleries.map((entry) {
      if (entry is! Map) {
        throw StateError('La respuesta incluye una galería no válida.');
      }
      final data = Map<String, dynamic>.from(entry);
      final photos = data['photos'];
      if (photos is! List) {
        throw StateError('La galería no contiene una lista de fotos válida.');
      }
      final urls = photos.map((photo) {
        if (photo is! Map || photo['url'] is! String) {
          throw StateError('La galería contiene una URL no válida.');
        }
        final uri = Uri.tryParse(photo['url'] as String);
        if (uri == null || uri.scheme != 'https') {
          throw StateError('La galería contiene una URL no segura.');
        }
        return uri;
      }).toList();
      final scheduledAt = DateTime.tryParse(
        data['scheduledAt'] as String? ?? '',
      );
      if (data['bookingId'] is! String ||
          data['title'] is! String ||
          data['category'] is! String) {
        throw StateError('La galería contiene datos incompletos.');
      }
      return GallerySession(
        bookingId: data['bookingId'] as String,
        title: data['title'] as String,
        category: data['category'] as String,
        scheduledAt: scheduledAt,
        photos: List<Uri>.unmodifiable(urls),
      );
    }).toList();
  }
}
