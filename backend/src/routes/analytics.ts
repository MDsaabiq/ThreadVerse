import { Router } from "express";
import { requireAuth } from "../middleware/auth.js";
import {
  getCommunityHealthMetrics,
  getUserAnalytics,
  getContentAnalytics,
  createReport,
  listReports,
  resolveReport,
  getReportStats,
} from "../controllers/analyticsController.js";

const router = Router();

// Public report creation
router.post("/reports", requireAuth, createReport);

// Admin-only analytics routes
router.get("/community-health", requireAuth, getCommunityHealthMetrics);
router.get("/users", requireAuth, getUserAnalytics);
router.get("/content", requireAuth, getContentAnalytics);

// Admin-only report management
router.get("/reports", requireAuth, listReports);
router.get("/reports/stats", requireAuth, getReportStats);
router.patch("/reports/:id", requireAuth, resolveReport);

export default router;
