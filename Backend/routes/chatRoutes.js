const express = require("express");
const router = express.Router();
const chatController = require("../controllers/chatController");
const { authenticateToken } = require("../middleware/auth");
const { validateMessage } = require("../middleware/validation");
const { uploadMultiple, handleUploadError } = require("../middleware/upload");

// All routes require authentication
router.use(authenticateToken);

// Chat routes
router.get("/", chatController.getUserChats);
router.post("/direct", chatController.createDirectChat);
router.get("/:chatId/messages", chatController.getChatMessages);
router.post(
  "/:chatId/messages",
  uploadMultiple,
  handleUploadError,
  validateMessage,
  chatController.sendMessage
);
router.put(
  "/messages/:messageId",
  validateMessage,
  chatController.editMessage
);
router.delete("/messages/:messageId", chatController.deleteMessage);
router.post("/messages/:messageId/reaction", chatController.addReaction);
router.post("/:chatId/typing", chatController.handleTyping);
router.post("/block", chatController.blockUser);
router.post("/unblock", chatController.unblockUser);
router.post("/messages/:messageId/forward", chatController.forwardMessage);
router.delete("/:chatId", chatController.deleteChat);
router.post("/:chatId/pin/:messageId", chatController.pinMessage);
router.delete("/:chatId/pin/:messageId", chatController.unpinMessage);
router.post("/:chatId/mute", chatController.muteChat);
router.post("/:chatId/unmute", chatController.unmuteChat);
router.get("/:chatId/messages/search", chatController.searchMessages);

 
module.exports = router;