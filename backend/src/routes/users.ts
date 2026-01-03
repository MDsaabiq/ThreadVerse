import { Router } from "express";
import { 
  getUser, 
  updateMe, 
  followUser, 
  unfollowUser, 
  checkFollowing,
  getUserKarma,
  getUserCommunityReps,
  getUserCommunityReputation,
  recalculateMyKarma,
  recalculateMyCommunityReputation
} from "../controllers/userController.js";
import { requireAuth } from "../middleware/auth.js";

const router = Router();

router.get("/:username", getUser);
router.patch("/me", requireAuth, updateMe);
router.post("/:username/follow", requireAuth, followUser);
router.delete("/:username/follow", requireAuth, unfollowUser);
router.get("/:username/following", requireAuth, checkFollowing);

// Karma and Reputation routes
router.get("/:username/karma", getUserKarma);
router.get("/:username/reputation", getUserCommunityReps);
router.get("/:username/reputation/:communityName", getUserCommunityReputation);
router.post("/me/karma/recalculate", requireAuth, recalculateMyKarma);
router.post("/me/reputation/:communityName/recalculate", requireAuth, recalculateMyCommunityReputation);

export default router;
