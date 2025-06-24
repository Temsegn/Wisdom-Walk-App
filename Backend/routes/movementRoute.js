const express = require("express");
const router = express.Router();
const movementController = require("../controllers/movementController");
const { authenticateToken } = require("../middleware/auth"); // Your JWT auth middleware

router.use(authenticateToken);


// Post a move
router.post("/", movementController.postMove);

// Get my own moves
router.get("/me", movementController.getMyMoves);

// Get another user's moves
router.get("/user/:userId", movementController.getUserMoves);

// Search for users
router.get("/search", movementController.searchUsers);

module.exports = router;
