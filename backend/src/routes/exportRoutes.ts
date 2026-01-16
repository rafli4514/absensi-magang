import { Router } from "express";
import { authenticateToken } from "../middleware/auth";
import { exportLogbook, exportActivity } from "../controllers/exportController";

const router = Router();

router.use(authenticateToken);

router.get("/logbook", exportLogbook);
router.get("/activity", exportActivity);

export default router;
