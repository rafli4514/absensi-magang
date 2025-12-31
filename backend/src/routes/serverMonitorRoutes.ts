import { Router } from 'express';
import { getServerSpecs, getServerStats } from '../controllers/serverMonitorController';

const router = Router();

router.get('/specs', getServerSpecs);
router.get('/stats', getServerStats);

export = router;