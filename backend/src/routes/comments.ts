import { Router } from "express";
import {
  createComment,
  listComments,
  voteComment,
} from "../controllers/commentController.ts";
import { requireAuth } from "../middleware/auth.ts";

const router = Router();

router.get("/posts/:postId", listComments);
router.post("/posts/:postId", requireAuth, createComment);
router.post("/:id/vote", requireAuth, voteComment);

export default router;
