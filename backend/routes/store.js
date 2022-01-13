const { Router } = require("express");
const { getUser } = require("../middleware/auth");
const prisma = require("../prisma/client");
const crypto = require("../util/crypto");

const router = Router();

router.post("/", getUser, async (req, res) => {
  const encrypted = crypto.encrypt(
    JSON.stringify(req.body),
    process.env.SECRET
  );
  let doc = await prisma.userStorage.findFirst({
    where: { userId: req.user.id },
  });
  if (doc) {
    doc = await prisma.userStorage.update({
      where: { id: doc.id },
      data: {
        iv: encrypted.iv,
        content: encrypted.content,
      },
    });
  } else {
    doc = await prisma.userStorage.create({
      data: {
        User: {
          connect: {
            id: req.user.id,
          },
        },
        iv: encrypted.iv,
        content: encrypted.content,
      },
    });
  }
  res.status(201).json({ message: "Stored", ok: true, data: doc });
});

router.get("/", getUser, async (req, res) => {
  const doc = await prisma.userStorage.findFirst({
    where: { userId: req.user.id },
  });
  if (!doc) {
    res.status(404).json({ message: "Not found", ok: false });
    return;
  }
  const decrypted = crypto.decrypt(doc, process.env.SECRET);
  try {
    res
      .status(200)
      .json({ message: "Retrieved", ok: true, data: JSON.parse(decrypted) });
  } catch {
    res.status(200).json({ message: "Retrieved", ok: true, data: decrypted });
  }
});

module.exports = router;
