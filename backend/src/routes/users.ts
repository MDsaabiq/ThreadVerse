import { Router } from "express";
import { getUser, updateMe } from "../controllers/userController.ts";
import { requireAuth } from "../middleware/auth.ts";

const router = Router();

router.get("/:username", getUser);
router.patch("/me", requireAuth, updateMe);

export default router;
