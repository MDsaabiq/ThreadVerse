import jwt from "jsonwebtoken";

export type JwtUser = { id: string; username: string };

function getSecret() {
  const secret = process.env.JWT_SECRET;
  if (!secret) {
    throw new Error("JWT_SECRET is not set");
  }
  return secret;
}

export function signAccessToken(payload: JwtUser) {
  return jwt.sign(payload, getSecret(), { expiresIn: "12h" });
}

export function verifyAccessToken(token: string): JwtUser {
  return jwt.verify(token, getSecret()) as JwtUser;
}
