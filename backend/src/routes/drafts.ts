import { Router } from "express";
import { requireAuth } from "../middleware/auth.js";
import {
  saveDraftPost,
  saveDraftComment,
  listUserDrafts,
  getDraft,
  deleteDraft,
  deleteOldDrafts,
} from "../controllers/draftController.js";

const router = Router();

// All draft routes require authentication
router.use(requireAuth);

// List user's drafts
router.get("/", listUserDrafts);

// Get specific draft
router.get("/:id", getDraft);

// Save/update draft post
router.post("/posts/:id", saveDraftPost);
router.put("/posts/:id", saveDraftPost);

// Save/update draft comment
router.post("/comments/:id", saveDraftComment);
router.put("/comments/:id", saveDraftComment);

// Delete draft
router.delete("/:id", deleteDraft);

// Delete old drafts
router.delete("/cleanup/old", deleteOldDrafts);

export default router;
