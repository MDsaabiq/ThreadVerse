import express from "express";
import {
  getTrustLevel,
  getMyTrustLevel,
  recalculateTrustLevel,
  recalculateAllTrustLevels,
  getTrustLevelBreakdown,
  getTrustLeaderboard,
  getUsersByTrustLevel,
  getTrustStatistics,
} from "../controllers/trustController.js";
import { requireAuth } from "../middleware/auth.js";

const router = express.Router();

// Public routes
router.get("/leaderboard", getTrustLeaderboard);
router.get("/statistics", getTrustStatistics);
router.get("/level/:level", getUsersByTrustLevel);
router.get("/:userId", getTrustLevel);
router.get("/:userId/breakdown", getTrustLevelBreakdown);

// Protected routes
router.get("/", requireAuth, getMyTrustLevel);
router.post("/recalculate/:userId", requireAuth, recalculateTrustLevel);

// Admin only
router.post("/admin/recalculate-all", requireAuth, recalculateAllTrustLevels);

export default router;
