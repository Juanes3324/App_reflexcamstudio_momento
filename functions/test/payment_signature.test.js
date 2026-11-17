const assert = require("node:assert/strict");
const { test } = require("node:test");
const {
  createWompiEventChecksum,
  createWompiIntegritySignature,
  matchesWompiChecksum,
} = require("../lib/payment_signature.js");

test("generates Wompi's documented integrity signature", () => {
  const signature = createWompiIntegritySignature(
    "sk8-438k4-xmxm392-sn2m",
    2490000,
    "COP",
    "prod_integrity_Z5mMke9x0k8gpErbDqwrJXMqsI6SFli6",
  );
  assert.equal(
    signature,
    "37c8407747e595535433ef8f6a811d853cd943046624a0ec04662b17bbf33bf5",
  );
});

test("validates Wompi's event checksum with the listed properties and timestamp", () => {
  const checksum = createWompiEventChecksum(
    ["1234-1610641025-49201", "APPROVED", "4490000"],
    1530291411,
    "prod_events_OcHnIzeBl5socpwByQ4hA52Em3USQ93Z",
  );
  assert.equal(
    checksum,
    "5a18ec5e8fdb7df463e9f94774cba8f583ba21bd04a09ceff2ea68a4bc0aefbe",
  );
  assert.equal(matchesWompiChecksum(checksum, checksum.toUpperCase()), true);
  assert.equal(matchesWompiChecksum(checksum, `${checksum.slice(1)}`), false);
});
