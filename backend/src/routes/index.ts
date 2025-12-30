import { Router } from "express";
import healthRouter from "./health.ts";
import authRouter from "./auth.ts";
import communityRouter from "./community.ts";
import postsRouter from "./posts.ts";
import commentsRouter from "./comments.ts";
import usersRouter from "./users.ts";

const router = Router();

router.use(healthRouter);
router.use("/auth", authRouter);
router.use("/communities", communityRouter);
router.use("/posts", postsRouter);
router.use("/comments", commentsRouter);
router.use("/users", usersRouter);

export default router;
