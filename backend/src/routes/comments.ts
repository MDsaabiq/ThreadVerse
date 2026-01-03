import { Router } from "express";
import {
  createComment,
  listComments,
  voteComment,
} from "../controllers/commentController.js";
import { requireAuth } from "../middleware/auth.js";

const router = Router();

router.get("/posts/:postId", listComments);
router.post("/posts/:postId", requireAuth, createComment);
router.post("/:id/vote", requireAuth, voteComment);

export default router;
