import { Router } from "express";
import {
  listNotifications,
  markAsRead,
  markAllAsRead,
  getUnreadCount,
} from "../controllers/notificationController.js";
import { requireAuth } from "../middleware/auth.js";

const router = Router();

router.get("/", requireAuth, listNotifications);
router.get("/unread-count", requireAuth, getUnreadCount);
router.post("/:id/read", requireAuth, markAsRead);
router.post("/mark-all-read", requireAuth, markAllAsRead);

export default router;
