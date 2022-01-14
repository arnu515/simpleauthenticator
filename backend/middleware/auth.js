const { getUserFromToken } = require("../util/jwt");

async function getUser(
  /** @type import("express").Request */
  req,
  /** @type import("express").Response */
  res,
  next
) {
  const authHeader = req.headers.authorization;
  if (!authHeader) {
    res.status(401).json({ message: "No authorization header", ok: false });
    return;
  }
  const token = authHeader.split(" ")[1];
  if (!token) {
    res.status(401).json({ message: "No token", ok: false });
    return;
  }
  const user = await getUserFromToken(token);
  if (!user) {
    res.status(401).json({ message: "Invalid token", ok: false });
    return;
  }
  req.user = user;
  req.token = token;
  next();
}

module.exports = { getUser };
