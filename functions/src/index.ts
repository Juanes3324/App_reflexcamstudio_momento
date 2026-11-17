import { createHash } from "node:crypto";
import { initializeApp } from "firebase-admin/app";
import { FieldValue, Timestamp, getFirestore } from "firebase-admin/firestore";
import { v2 as cloudinary } from "cloudinary";
import { logger } from "firebase-functions";
import { defineSecret } from "firebase-functions/params";
import { onCall, onRequest, HttpsError } from "firebase-functions/v2/https";
import {
  createWompiEventChecksum,
  createWompiIntegritySignature,
  matchesWompiChecksum,
} from "./payment_signature";

initializeApp();

const REGION = "southamerica-east1";
const db = getFirestore();

const wompiPublicKey = defineSecret("WOMPI_PUBLIC_KEY");
const wompiIntegritySecret = defineSecret("WOMPI_INTEGRITY_SECRET");
const wompiEventsSecret = defineSecret("WOMPI_EVENTS_SECRET");
const cloudinaryCloudName = defineSecret("CLOUDINARY_CLOUD_NAME");
const cloudinaryApiKey = defineSecret("CLOUDINARY_API_KEY");
const cloudinaryApiSecret = defineSecret("CLOUDINARY_API_SECRET");

const services: Record<string, { title: string; price: number; category: string }> = {
  product_branding: {
    title: "Fotografía de Producto & Branding",
    price: 350000,
    category: "Fotografía",
  },
  promotional_video: {
    title: "Video Promocional & Reels",
    price: 200000,
    category: "Video",
  },
  event_coverage: {
    title: "Cobertura de Evento",
    price: 250000,
    category: "Fotografía",
  },
  fashion_lookbook: {
    title: "Lookbook & Moda Editorial",
    price: 250000,
    category: "Fotografía",
  },
};

const extras: Record<string, { title: string; price: number }> = {
  styling_assistant: { title: "Asistente de estilismo", price: 80000 },
  extra_lighting: { title: "Iluminación extra", price: 50000 },
  express_delivery: { title: "Entrega express", price: 70000 },
};

interface BookingLocation {
  type: "studio" | "external";
  address: string;
  latitude?: number;
  longitude?: number;
}

interface BookingInput {
  bookingId: string;
  serviceIds: string[];
  extraIds: string[];
  scheduledAt: string;
  location: BookingLocation;
  logistics: string;
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function stringArray(value: unknown, field: string): string[] {
  if (
    !Array.isArray(value) ||
    value.some((entry) => typeof entry !== "string")
  ) {
    throw new HttpsError("invalid-argument", `El campo ${field} no es válido.`);
  }
  return [...new Set(value as string[])].sort();
}

function parseBookingInput(value: unknown): BookingInput {
  if (!isRecord(value) || !isRecord(value.location)) {
    throw new HttpsError("invalid-argument", "La reserva no es válida.");
  }

  const { location } = value;
  const bookingId = value.bookingId;
  const scheduledAt = value.scheduledAt;
  const address = location.address;
  const logistics = value.logistics;

  if (
    typeof bookingId !== "string" ||
    !/^[A-Za-z0-9_-]{1,128}$/.test(bookingId) ||
    typeof scheduledAt !== "string" ||
    !Number.isFinite(Date.parse(scheduledAt)) ||
    Date.parse(scheduledAt) <= Date.now() ||
    typeof address !== "string" ||
    address.length > 300 ||
    typeof logistics !== "string" ||
    logistics.length > 1000
  ) {
    throw new HttpsError("invalid-argument", "Revisa los datos de la reserva.");
  }

  const locationType = location.type;
  if (locationType !== "studio" && locationType !== "external") {
    throw new HttpsError("invalid-argument", "La ubicación no es válida.");
  }

  const parsedLocation: BookingLocation = {
    type: locationType,
    address: address.trim(),
  };
  if (locationType === "external") {
    const latitude = location.latitude;
    const longitude = location.longitude;
    if (
      typeof latitude !== "number" ||
      typeof longitude !== "number" ||
      latitude < -90 ||
      latitude > 90 ||
      longitude < -180 ||
      longitude > 180
    ) {
      throw new HttpsError(
        "invalid-argument",
        "Marca un punto válido para la locación externa.",
      );
    }
    parsedLocation.latitude = latitude;
    parsedLocation.longitude = longitude;
  }

  return {
    bookingId,
    serviceIds: stringArray(value.serviceIds, "serviceIds"),
    extraIds: stringArray(value.extraIds, "extraIds"),
    scheduledAt,
    location: parsedLocation,
    logistics: logistics.trim(),
  };
}

function calculatePrice(input: BookingInput): {
  totalAmount: number;
  depositAmount: number;
  serviceTitles: string[];
  extraTitles: string[];
} {
  if (input.serviceIds.length === 0) {
    throw new HttpsError(
      "invalid-argument",
      "Selecciona al menos un servicio.",
    );
  }

  const selectedServices = input.serviceIds.map((id) => {
    const service = services[id];
    if (!service) {
      throw new HttpsError("invalid-argument", "Hay un servicio no válido.");
    }
    return service;
  });
  const selectedExtras = input.extraIds.map((id) => {
    const extra = extras[id];
    if (!extra) {
      throw new HttpsError("invalid-argument", "Hay un adicional no válido.");
    }
    return extra;
  });

  const totalAmount =
    selectedServices.reduce((total, service) => total + service.price, 0) +
    selectedExtras.reduce((total, extra) => total + extra.price, 0);

  return {
    totalAmount,
    depositAmount: Math.round(totalAmount * 0.5),
    serviceTitles: selectedServices.map((service) => service.title),
    extraTitles: selectedExtras.map((extra) => extra.title),
  };
}

function makeCheckoutUrl(reference: string, amountInCents: number): string {
  const publicKey = wompiPublicKey.value();
  const integritySecret = wompiIntegritySecret.value();
  if (!publicKey || !integritySecret) {
    throw new HttpsError(
      "failed-precondition",
      "Faltan las credenciales de Wompi en Secret Manager.",
    );
  }

  const integrity = createWompiIntegritySignature(
    reference,
    amountInCents,
    "COP",
    integritySecret,
  );
  const query = new URLSearchParams({
    "public-key": publicKey,
    currency: "COP",
    "amount-in-cents": String(amountInCents),
    reference,
    "signature:integrity": integrity,
  });

  return `https://checkout.wompi.co/p/?${query.toString()}`;
}

export const createWompiCheckout = onCall(
  {
    region: REGION,
    secrets: [wompiPublicKey, wompiIntegritySecret],
  },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Inicia sesión para reservar.");
    }

    const input = parseBookingInput(request.data);
    const price = calculatePrice(input);
    const reference = `RFX-${input.bookingId}`;
    const fingerprint = createHash("sha256")
      .update(
        JSON.stringify({
          ...input,
          serviceIds: input.serviceIds,
          extraIds: input.extraIds,
        }),
      )
      .digest("hex");
    const bookingRef = db.collection("bookings").doc(input.bookingId);
    const booking = await db.runTransaction(async (transaction) => {
      const current = await transaction.get(bookingRef);
      if (current.exists) {
        const existing = current.data();
        if (
          existing?.userId !== request.auth?.uid ||
          existing?.requestFingerprint !== fingerprint ||
          existing?.payment?.status !== "pending"
        ) {
          throw new HttpsError(
            "already-exists",
            "Esta solicitud de reserva ya fue procesada.",
          );
        }
        return existing;
      }

      const amountInCents = price.depositAmount * 100;
      const data = {
        userId: request.auth?.uid,
        serviceIds: input.serviceIds,
        serviceTitles: price.serviceTitles,
        extraIds: input.extraIds,
        extraTitles: price.extraTitles,
        scheduledAt: Timestamp.fromDate(new Date(input.scheduledAt)),
        location: input.location,
        logistics: input.logistics,
        totalAmount: price.totalAmount,
        depositAmount: price.depositAmount,
        requestFingerprint: fingerprint,
        status: "pending_payment",
        createdAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
        payment: {
          status: "pending",
          reference,
          amountInCents,
          currency: "COP",
        },
      };
      transaction.create(bookingRef, data);
      return data;
    });

    const amountInCents = booking.payment.amountInCents as number;
    return {
      bookingId: input.bookingId,
      reference,
      checkoutUrl: makeCheckoutUrl(reference, amountInCents),
      totalAmount: booking.totalAmount,
      depositAmount: booking.depositAmount,
    };
  },
);

function readPath(value: unknown, path: string): unknown {
  return path.split(".").reduce<unknown>((current, segment) => {
    if (!isRecord(current)) return undefined;
    return current[segment];
  }, value);
}

function verifyWompiEvent(body: unknown): body is Record<string, unknown> {
  if (!isRecord(body) || !isRecord(body.signature)) return false;
  const signature = body.signature;
  if (
    !Array.isArray(signature.properties) ||
    typeof signature.timestamp !== "number" ||
    typeof signature.checksum !== "string" ||
    !/^[\da-f]{64}$/i.test(signature.checksum)
  ) {
    return false;
  }

  const propertyValues: string[] = [];
  for (const property of signature.properties) {
    if (typeof property !== "string") return false;
    const propertyValue = readPath(body.data, property);
    if (
      propertyValue === undefined ||
      propertyValue === null ||
      typeof propertyValue === "object"
    ) {
      return false;
    }
    propertyValues.push(String(propertyValue));
  }

  const expected = createWompiEventChecksum(
    propertyValues,
    signature.timestamp,
    wompiEventsSecret.value(),
  );
  return matchesWompiChecksum(expected, signature.checksum);
}

export const wompiWebhook = onRequest(
  { region: REGION, secrets: [wompiEventsSecret] },
  async (request, response) => {
    if (request.method !== "POST") {
      response.status(405).send("Method not allowed");
      return;
    }
    if (!verifyWompiEvent(request.body)) {
      response.status(401).send("Invalid Wompi signature");
      return;
    }

    const body = request.body as Record<string, unknown>;
    if (body.event !== "transaction.updated" || !isRecord(body.data)) {
      response.status(200).send("Event ignored");
      return;
    }
    const transactionData = body.data.transaction;
    if (!isRecord(transactionData)) {
      response.status(400).send("Invalid transaction");
      return;
    }

    const reference = transactionData.reference;
    const amountInCents = transactionData.amount_in_cents;
    const currency = transactionData.currency;
    const status = transactionData.status;
    if (
      typeof reference !== "string" ||
      !reference.startsWith("RFX-") ||
      typeof amountInCents !== "number" ||
      currency !== "COP" ||
      typeof status !== "string"
    ) {
      response.status(400).send("Invalid transaction fields");
      return;
    }

    const bookingId = reference.substring(4);
    const bookingRef = db.collection("bookings").doc(bookingId);
    const snapshot = await bookingRef.get();
    const booking = snapshot.data();
    if (
      !snapshot.exists ||
      booking?.payment?.reference !== reference ||
      booking?.payment?.amountInCents !== amountInCents
    ) {
      response.status(404).send("Booking not found");
      return;
    }

    const transactionId =
      typeof transactionData.id === "string" ? transactionData.id : null;
    const paymentStatus = status === "APPROVED"
      ? "approved"
      : ["DECLINED", "ERROR", "VOIDED"].includes(status)
        ? "failed"
        : "pending";

    await db.runTransaction(async (transaction) => {
      const current = await transaction.get(bookingRef);
      const currentPaymentStatus = current.data()?.payment?.status;
      if (currentPaymentStatus === "approved" && paymentStatus !== "approved") {
        return;
      }
      transaction.update(bookingRef, {
        "payment.status": paymentStatus,
        "payment.transactionId": transactionId,
        "payment.providerStatus": status,
        "payment.updatedAt": FieldValue.serverTimestamp(),
        status: paymentStatus === "approved"
          ? "paid"
          : paymentStatus === "failed"
            ? "payment_failed"
            : "pending_payment",
        updatedAt: FieldValue.serverTimestamp(),
      });
    });

    response.status(200).send("Event processed");
  },
);

function configureCloudinary(): void {
  const cloudName = cloudinaryCloudName.value();
  const apiKey = cloudinaryApiKey.value();
  const apiSecret = cloudinaryApiSecret.value();
  if (!cloudName || !apiKey || !apiSecret) {
    throw new HttpsError(
      "failed-precondition",
      "Faltan las credenciales de Cloudinary en Secret Manager.",
    );
  }
  cloudinary.config({
    cloud_name: cloudName,
    api_key: apiKey,
    api_secret: apiSecret,
    secure: true,
  });
}

export const listMyGalleries = onCall(
  {
    region: REGION,
    timeoutSeconds: 120,
    secrets: [cloudinaryCloudName, cloudinaryApiKey, cloudinaryApiSecret],
  },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Inicia sesión para ver entregas.");
    }

    configureCloudinary();
    const bookings = await db
      .collection("bookings")
      .where("userId", "==", request.auth.uid)
      .orderBy("createdAt", "desc")
      .limit(50)
      .get();
    const paidBookings = bookings.docs
      .filter((document) => document.data().payment?.status === "approved")
      .sort((left, right) => {
        const leftDate = left.data().createdAt?.toMillis?.() ?? 0;
        const rightDate = right.data().createdAt?.toMillis?.() ?? 0;
        return rightDate - leftDate;
      })
      .slice(0, 20);

    try {
      const galleries = await Promise.all(
        paidBookings.map(async (document) => {
          const booking = document.data();
          const tag = `booking_${document.id}`;
          const images = await cloudinary.api.resources_by_tag(tag, {
            resource_type: "image",
            type: "authenticated",
            max_results: 100,
          });
          const resources = (images.resources ?? []).map(
            (resource: { public_id: string }) => resource.public_id,
          );
          const scheduledAt = booking.scheduledAt as Timestamp | undefined;
          const serviceIds = booking.serviceIds as string[];
          const category = services[serviceIds?.[0]]?.category ?? "Fotografía";

          return {
            bookingId: document.id,
            title: (booking.serviceTitles as string[] | undefined)?.join(", ") ??
              "Entrega Reflexcam",
            category,
            scheduledAt: scheduledAt?.toDate?.().toISOString() ?? "",
            photos: resources.map((publicId: string) => ({
              url: cloudinary.url(publicId, {
                resource_type: "image",
                type: "authenticated",
                sign_url: true,
                secure: true,
              }),
            })),
          };
        }),
      );
      return { galleries };
    } catch (error) {
      logger.error("Cloudinary gallery lookup failed", error);
      throw new HttpsError(
        "unavailable",
        "No se pudieron consultar las galerías en este momento.",
      );
    }
  },
);
