import { Router } from "express";
import healthRouter from "./health.js";
import authRouter from "./auth.js";
import communityRouter from "./community.js";
import postsRouter from "./posts.js";
import commentsRouter from "./comments.js";
import usersRouter from "./users.js";
import notificationsRouter from "./notifications.js";
import uploadRouter from "./upload.js";

const router = Router();

router.use(healthRouter);
router.use("/auth", authRouter);
router.use("/communities", communityRouter);
router.use("/posts", postsRouter);
router.use("/comments", commentsRouter);
router.use("/users", usersRouter);
router.use("/notifications", notificationsRouter);
router.use("/upload", uploadRouter);

export default router;
