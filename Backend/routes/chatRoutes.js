const express = require("express");
const router = express.Router();
const chatController = require("../controllers/chatController");
const { authenticateToken } = require("../middleware/auth");
const { validateMessage } = require("../middleware/validation");
const { uploadMultiple, handleUploadError } = require("../middleware/upload");

router.use(authenticateToken);

router.get("/", chatController.getUserChats);
router.post("/direct", chatController.createDirectChat);
router.get("/:chatId/messages", chatController.getChatMessages);

router.put(
  "/messages/:messageId",
  validateMessage,
  chatController.editMessage
);
router.delete("/messages/:messageId", chatController.deleteMessage);
router.post("/messages/:messageId/reaction", chatController.addReaction);
router.post("/block", chatController.blockUser);
router.post("/unblock", chatController.unblockUser);
router.post("/messages/:messageId/forward", chatController.forwardMessage);
router.delete("/:chatId", chatController.deleteChat);
router.post("/:chatId/pin/:messageId", chatController.pinMessage);
router.put("/:chatId/unpin/:messageId", chatController.unpinMessage);
router.post("/:chatId/mute", chatController.muteChat);
router.post("/:chatId/unmute", chatController.unmuteChat);
router.get("/:chatId/messages/search", chatController.searchMessages);

module.exports = router;