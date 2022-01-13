import express from "express";
import cors from "cors";
import prisma from "./prisma/client";

const app = express();
app.use(express.json());
app.use(cors());

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