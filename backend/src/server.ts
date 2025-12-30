import cors from "cors";
import dotenv from "dotenv";
import express from "express";
import helmet from "helmet";
import morgan from "morgan";
import { connectToDatabase } from "./config/db.ts";
import { errorHandler } from "./middleware/errorHandler.ts";
import apiRouter from "./routes/index.ts";

dotenv.config();

const PORT = Number(process.env.PORT) || 4000;
const app = express();

app.enable("trust proxy");

const corsOptions: cors.CorsOptions = {
  origin: (_origin, callback) => {
    // Allow all origins (frontends may be served via forwarded HTTPS hosts)
    callback(null, true);
  },
  credentials: true,
};

app.use(helmet());
app.use(cors(corsOptions));
app.options("*", cors(corsOptions));
app.use(express.json({ limit: "1mb" }));
app.use(morgan("dev"));

app.use("/api/v1", apiRouter);

app.use(errorHandler);

async function bootstrap() {
  await connectToDatabase();
  app.listen(PORT, () => {
    console.log(`API listening on port ${PORT}`);
  });
}

bootstrap().catch((err) => {
  console.error("Failed to start server", err);
  process.exit(1);
});
