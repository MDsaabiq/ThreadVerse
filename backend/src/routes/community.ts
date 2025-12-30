import { Router } from "express";
import {
  createCommunity,
  getCommunity,
  joinCommunity,
  leaveCommunity,
  listCommunities,
} from "../controllers/communityController.ts";
import { requireAuth } from "../middleware/auth.ts";

const router = Router();

router.get("/", listCommunities);
router.post("/", requireAuth, createCommunity);
router.get("/:name", getCommunity);
router.post("/:name/join", requireAuth, joinCommunity);
router.delete("/:name/join", requireAuth, leaveCommunity);

export default router;
