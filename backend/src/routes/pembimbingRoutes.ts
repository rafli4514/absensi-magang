import express from "express";
import { getPembimbings, getAllBidang } from "../controllers/pembimbingController";
import { authenticateToken } from "../middleware/auth";

const router = express.Router();

// Public or Authenticated? Implementation plan says participant selects mentor during registration (public?)
// But for security, maybe just some basic API key or just public. 
// Usually registration form needs this data before user has token.
// So let's make it public for now, or require a separate token if needed.
// Given the context "Peserta hanya memilih pembimbing ... kemudian sistem memfilter", this happens on the Registration Page.
// So it must be public or protected by a temporary token. Assuming public for simplicity as it's just a list of mentors.

router.get("/", getPembimbings);
router.get("/bidang", getAllBidang);

export default router;
