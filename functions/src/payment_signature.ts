import { createHash, timingSafeEqual } from "node:crypto";

export function createWompiIntegritySignature(
  reference: string,
  amountInCents: number,
  currency: string,
  secret: string,
): string {
  return createHash("sha256")
    .update(`${reference}${amountInCents}${currency}${secret}`)
    .digest("hex");
}

export function createWompiEventChecksum(
  propertyValues: string[],
  timestamp: number,
  secret: string,
): string {
  return createHash("sha256")
    .update(`${propertyValues.join("")}${timestamp}${secret}`)
    .digest("hex");
}

export function matchesWompiChecksum(
  expectedHex: string,
  suppliedHex: string,
): boolean {
  if (!/^[\da-f]{64}$/i.test(suppliedHex)) return false;
  const expected = Buffer.from(expectedHex, "hex");
  const supplied = Buffer.from(suppliedHex, "hex");
  return expected.length === supplied.length && timingSafeEqual(expected, supplied);
}
