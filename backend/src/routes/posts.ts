import { Router } from "express";
import {
  createPost,
  getPost,
  listPosts,
  autoFillPost,
  votePost,
  votePollOption,
  updatePost,
  deletePost,
  listUserPosts,
} from "../controllers/postController.js";
import { requireAuth } from "../middleware/auth.js";

const router = Router();

router.get("/", listPosts);
router.post("/auto-fill", requireAuth, autoFillPost);
router.post("/", requireAuth, createPost);
router.get("/user/:username", listUserPosts);
router.get("/:id", getPost);
router.put("/:id", requireAuth, updatePost);
router.delete("/:id", requireAuth, deletePost);
router.post("/:id/vote", requireAuth, votePost);
router.post("/:id/poll/:optionId/vote", requireAuth, votePollOption);

export default router;
