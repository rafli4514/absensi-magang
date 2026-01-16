import { Router } from "express";
import { authenticateToken } from "../middleware/auth";
import { getTimeline } from "../controllers/activityController";

const router = Router();

router.use(authenticateToken);

router.get("/", getTimeline);

export default router;
