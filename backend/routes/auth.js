const { Router } = require("express");
const bcrypt = require("bcryptjs");
const joi = require("joi");
const prisma = require("../prisma/client");
const { getUser } = require("../middleware/auth");
const { genToken, blacklistToken } = require("../util/jwt");

const router = Router();

router.post("/register", async (req, res) => {
  const { error, value } = joi
    .object({
      email: joi.string().email().required().trim(),
      password: joi.string().required().trim(),
      confirmPassword: joi.string().required().trim(),
    })
    .validate(req.body);
  if (error) {
    res.status(400).json({ message: error.message, ok: false });
    return;
  }

  const { email, password, confirmPassword } = value;
  if (password !== confirmPassword) {
    res.status(400).json({ message: "Passwords don't match", ok: false });
    return;
  }

  const hashedPassword = bcrypt.hashSync(password, bcrypt.genSaltSync(12));

  let user = await prisma.user.findFirst({ where: { email } });
  if (user) {
    res.status(400).json({ message: "User already exists", ok: false });
    return;
  }
  user = await prisma.user.create({
    data: { email, password: hashedPassword },
  });

  res.status(201).json({ message: "User created", ok: true, data: { user } });
});

router.post("/login", async (req, res) => {
  const { error, value } = joi
    .object({
      email: joi.string().email().required().trim(),
      password: joi.string().required().trim(),
    })
    .validate(req.body);
  if (error) {
    res.status(400).json({ message: error.message, ok: false });
    return;
  }

  const { email, password } = value;

  const user = await prisma.user.findFirst({ where: { email } });
  if (!user) {
    res.status(400).json({ message: "Invalid email", ok: false });
    return;
  }
  if (!bcrypt.compareSync(password, user.password)) {
    res.status(400).json({ message: "Invalid password", ok: false });
    return;
  }

  res.status(201).json({
    message: "Logged in",
    ok: true,
    data: { user, token: await genToken(user) },
  });
});

router.get("/me", getUser, (req, res) =>
  res.json({ message: "Logged in", ok: true, data: { user: req.user } })
);

router.delete("/logout", getUser, async (req, res) => {
  await blacklistToken(req.token);
  return res.status(200).json({message: "Logged out", ok: true});
});

module.exports = router;
