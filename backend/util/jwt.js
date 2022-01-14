const jwt = require("jsonwebtoken");
const prisma = require("../prisma/client");
const secret = process.env.JWT_SECRET || "secret";

async function genToken(
  /** @type import("@prisma/client").User */
  user
) {
  const token = jwt.sign(
    {
      sub: user.id,
      email: user.email,
    },
    secret,
    { expiresIn: "1w" }
  );

  await prisma.jWTToken.create({ data: { token } });

  return token;
}

async function getUserFromToken(token) {
  const tokenDb = await prisma.jWTToken.findFirst({ where: { token } });
  if (!tokenDb) return null;
  try {
    const { sub, email } = jwt.verify(token, secret);
    if (typeof sub !== "string" || typeof email !== "string") throw new Error();
    const user = await prisma.user.findFirst({ where: { id: sub, email } });
    if (!user) throw new Error();
    return user;
  } catch {
    await blacklistToken(token);
    return null;
  }
}

function blacklistToken(token) {
  return prisma.jWTToken.delete({ where: { token } });
}

module.exports = {
  genToken,
  getUserFromToken,
  blacklistToken,
};
