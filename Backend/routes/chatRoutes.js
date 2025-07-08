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
// Update your route handler to properly check for undefined sender
router.get('/exists/:userId', async (req, res) => {
  try {
    const currentUserId = req.user._id;
    const otherUserId = req.params.userId;

    if (!mongoose.Types.ObjectId.isValid(otherUserId)) {
      return res.status(400).json({ success: false, message: "Invalid user ID" });
    }

    const chat = await Chat.findOne({
      type: "direct",
      participants: { $all: [currentUserId, otherUserId] }
    })
    .populate({
      path: 'participants',
      select: 'firstName lastName profilePicture isOnline',
      match: { _id: { $ne: currentUserId } }
    })
    .populate('lastMessage')
    .lean();

    if (chat) {
      // Safely handle potentially undefined participants
      const otherUser = chat.participants?.[0];
      if (!otherUser) {
        return res.status(404).json({ success: false, message: "User not found" });
      }

      return res.json({
        success: true,
        exists: true,
        chat: {
          id: chat._id,
          chatName: `${otherUser.firstName} ${otherUser.lastName}`,
          chatImage: otherUser.profilePicture,
          isOnline: otherUser.isOnline,
          lastMessage: chat.lastMessage,
          participants: chat.participants
        }
      });
    }

    res.json({ success: true, exists: false });
  } catch (error) {
    console.error("Error:", error);
    res.status(500).json({ success: false, message: "Server error" });
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