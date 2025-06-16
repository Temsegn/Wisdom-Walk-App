const express = require("express");
const router = express.Router();
const userController = require("../controllers/userController");
const { authenticateToken } = require("../middleware/auth");
const { uploadSingle, handleUploadError } = require("../middleware/upload");

router.use(authenticateToken);

router.get("/profile", userController.getProfile);
router.put("/profile", uploadSingle, handleUploadError, userController.updateProfile);
router.put("/preferences", userController.updatePreferences);
router.delete("/account", userController.deleteAccount);
router.post("/status", userController.updateOnlineStatus);
router.post("/block", userController.blockUser);
router.post("/unblock", userController.unblockUser);
router.post("/join-group", userController.joinGroup);
router.post("/leave-group", userController.leaveGroup);
router.get("/posts/my", userController.getMyPosts);
router.get("/search", userController.searchUsers);
router.get("/:userId", userController.getUserById);
router.get("/:userId/posts", userController.getUserPosts);

module.exports = router;