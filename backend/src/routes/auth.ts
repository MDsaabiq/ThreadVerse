import { Router } from "express";
import { login, me, signup } from "../controllers/authController.ts";
import { requireAuth } from "../middleware/auth.ts";

const router = Router();

router.post("/signup", signup);
router.post("/login", login);
router.get("/me", requireAuth, me);

export default router;
