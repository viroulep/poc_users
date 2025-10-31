import { SignJWT, importPKCS8 } from "jose";
import { getToken } from "next-auth/jwt";

const PRIVATE_KEY_PEM = process.env.JWT_PRIVATE_KEY!.replace(/\\n/g, "\n");

type Payload = {
  email: string;
  provider: "github" | "google";
  name: string;
  uid: string;
};

export async function createJwt(payload: Payload) {
  const key = await importPKCS8(PRIVATE_KEY_PEM, "RS256");

  return await new SignJWT(payload)
    .setIssuedAt()
    .setProtectedHeader({ alg: "RS256" })
    .setIssuer("urn:example:issuer")
    .setAudience("urn:example:audience")
    .setExpirationTime("2h")
    .sign(key);
}
