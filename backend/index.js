require("dotenv").config();

const express = require("express");
const cors = require("cors");
const prisma = require("./prisma/client");

const app = express();
app.use(express.json());
app.use(cors());

const authRouter = require("./routes/auth");
app.use("/auth", authRouter);

app.get("/", (_, res) => res.send("Hello, world!"));

const port = process.env.PORT || 5000;

async function main() {
  await prisma.$connect();
  app.listen(port, () => console.log(`Server started on port ${port}`));
}

main()
  .catch((e) => {
    throw e;
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
