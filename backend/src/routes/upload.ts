import { Router } from "express";
import { requireAuth } from "../middleware/auth.js";
import { upload } from "../utils/upload.js";
import {
  uploadAvatar,
  uploadPostImage,
  uploadCommunityIcon,
  uploadCommunityBanner,
  uploadStandalonePostImage,
} from "../controllers/uploadController.js";

const router = Router();

// All upload routes require authentication
router.use(requireAuth);

// User avatar upload
router.post("/avatar", upload.single("image"), uploadAvatar);

// Generic post image upload (before post exists)
router.post("/post-image", upload.single("image"), uploadStandalonePostImage);

// Post image upload
router.post("/post/:postId", upload.single("image"), uploadPostImage);

// Community icon upload
router.post("/community/:name/icon", upload.single("image"), uploadCommunityIcon);

// Community banner upload
router.post("/community/:name/banner", upload.single("image"), uploadCommunityBanner);

export default router;
