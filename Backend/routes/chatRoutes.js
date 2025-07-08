const express = require("express");
const router = express.Router();
const chatController = require("../controllers/chatController");
const { authenticateToken } = require("../middleware/auth");
const { validateMessage } = require("../middleware/validation");
const { uploadMultiple, handleUploadError } = require("../middleware/upload");
const Chat=require("../models/Chat") 
const mongoose = require('mongoose'); // Add this import

router.use(authenticateToken);

router.get("/", chatController.getUserChats);
router.post("/direct", chatController.createDirectChat);
router.get("/:chatId/messages", chatController.getChatMessages);
router.post("/:chatId/messages", chatController.sendMessage);
router.get('/exists/:userId', async (req, res) => {
  try {
    const currentUserId = req.user._id;
    const otherUserId = req.params.userId;

    // Validate the user ID format
    if (!mongoose.Types.ObjectId.isValid(otherUserId)) {
      return res.status(400).json({
        success: false,
        message: "Invalid user ID format"
      });
    }

    const chat = await Chat.findOne({
      type: "direct",
      participants: { $all: [currentUserId, otherUserId] }
    })
    .populate('participants', 'firstName lastName profilePicture isOnline')
    .populate('lastMessage');

    if (chat) {
      // Manual formatting of the chat response
      const formattedChat = {
        id: chat._id,
        type: chat.type,
        participants: chat.participants.map(participant => ({
          id: participant._id,
          firstName: participant.firstName,
          lastName: participant.lastName,
          profilePicture: participant.profilePicture,
          isOnline: participant.isOnline
        })),
        lastMessage: chat.lastMessage ? {
          id: chat.lastMessage._id,
          content: chat.lastMessage.content,
          sender: chat.lastMessage.sender,
          createdAt: chat.lastMessage.createdAt,
          messageType: chat.lastMessage.messageType
        } : null,
        lastActivity: chat.lastActivity,
        unreadCount: chat.unreadCount || 0,
        createdAt: chat.createdAt,
        updatedAt: chat.updatedAt
      };

      return res.json({
        success: true,
        exists: true,
        chat: formattedChat
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
      message: "Failed to check chat existence",
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
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