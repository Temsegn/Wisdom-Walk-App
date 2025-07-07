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
router.post("/:chatId/messages", chatController.sendMessage);
router.get('/exists/:userId', async (req, res) => {
  try {
    const currentUserId = req.user._id;
    const otherUserId = req.params.userId;

    const chat = await Chat.findOne({
      isGroupChat: false,
      participants: { $all: [currentUserId, otherUserId] }
    }).populate('participants', 'firstName lastName profilePicture');

    if (chat) {
      return res.json({
        success: true,
        exists: true,
        chat: formatChatResponse(chat)
      });
    }

    res.json({
      success: true,
      exists: false
    });
  } catch (error) {
    console.error("Error checking chat existence:", error);
    res.status(500).json({
      success: false,
      message: "Failed to check chat existence"
    });
  }
});

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