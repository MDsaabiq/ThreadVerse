import { Router } from "express";
import {
  createPost,
  getPost,
  listPosts,
  votePost,
} from "../controllers/postController.ts";
import { requireAuth } from "../middleware/auth.ts";

const router = Router();

router.get("/", listPosts);
router.post("/", requireAuth, createPost);
router.get("/:id", getPost);
router.post("/:id/vote", requireAuth, votePost);

export default router;
