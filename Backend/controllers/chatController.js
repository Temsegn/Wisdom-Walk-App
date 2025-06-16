const Chat = require("../models/Chat");
const Message = require("../models/Message");
const User = require("../models/User");
const Notification = require("../models/Notification");
const { getPaginationMeta } = require("../utils/helpers");
const { saveMultipleFiles } = require("../utils/localStorageService");

// Get user's chats
const getUserChats = async (req, res) => {
  try {
    const userId = req.user._id;
    const { page = 1, limit = 20 } = req.query;
    const skip = (page - 1) * limit;

    const chats = await Chat.find({
      participants: userId,
      isActive: true,
    })
      .populate("participants", "firstName lastName profilePicture lastActive isOnline")
      .populate("lastMessage")
      .sort({ lastActivity: -1 })
      .skip(skip)
      .limit(Number.parseInt(limit));

    const total = await Chat.countDocuments({
      participants: userId,
      isActive: true,
    });

    // Format chats with unread count
    const formattedChats = await Promise.all(
      chats.map(async (chat) => {
        const chatObj = chat.toObject();

        // Get unread messages count
        const userSettings = chat.participantSettings.find(
          (setting) => setting.user.toString() === userId.toString()
        );
        const lastReadMessage = userSettings?.lastReadMessage;

        let unreadCount = 0;
        if (lastReadMessage) {
          unreadCount = await Message.countDocuments({
            chat: chat._id,
            _id: { $gt: lastReadMessage },
            sender: { $ne: userId },
          });
        } else {
          unreadCount = await Message.countDocuments({
            chat: chat._id,
            sender: { $ne: userId },
          });
        }

        chatObj.unreadCount = unreadCount;

        // For direct chats, get the other participant
        if (chat.type === "direct") {
          const otherParticipant = chat.participants.find(
            (p) => p._id.toString() !== userId.toString()
          );
          chatObj.chatName = `${otherParticipant.firstName} ${otherParticipant.lastName}`;
          chatObj.chatImage = otherParticipant.profilePicture;
          chatObj.isOnline = otherParticipant.isOnline;
          chatObj.lastActive = otherParticipant.lastActive;
        }

        return chatObj;
      })
    );

    res.json({
      success: true,
      data: formattedChats,
      pagination: getPaginationMeta(Number.parseInt(page), Number.parseInt(limit), total),
    });
  } catch (error) {
    console.error("Get user chats error:", error);
    res.status(500).json({
      success: false,
      message: "Failed to fetch chats",
      error: error.message,
    });
  }
};

// Create or get direct chat
const createDirectChat = async (req, res) => {
  try {
    const { participantId } = req.body;
    const userId = req.user._id;

    if (participantId === userId.toString()) {
      return res.status(400).json({
        success: false,
        message: "Cannot create chat with yourself",
      });
    }

    // Check if user has blocked the participant
    const user = await User.findById(userId);
    if (user.blockedUsers.includes(participantId)) {
      return res.status(403).json({
        success: false,
        message: "Cannot create chat with a blocked user",
      });
    }

    // Check if participant exists and is verified
    const participant = await User.findById(participantId);
    if (!participant || !participant.canAccess()) {
      return res.status(404).json({
        success: false,
        message: "User not found or not accessible",
      });
    }

    // Check if chat already exists
    let chat = await Chat.findOne({
      type: "direct",
      participants: { $all: [userId, participantId], $size: 2 },
    }).populate("participants", "firstName lastName profilePicture");

    if (!chat) {
      // Create new chat
      chat = new Chat({
        type: "direct",
        participants: [userId, participantId],
        participantSettings: [
          { user: userId, joinedAt: new Date() },
          { user: participantId, joinedAt: new Date() },
        ],
      });

      await chat.save();
      await chat.populate("participants", "firstName lastName profilePicture");
    }

    res.json({
      success: true,
      message: "Chat created/retrieved successfully",
      data: chat,
    });
  } catch (error) {
    console.error("Create direct chat error:", error);
    res.status(500).json({
      success: false,
      message: "Failed to create chat",
      error: error.message,
    });
  }
};

// Get chat messages
const getChatMessages = async (req, res) => {
  try {
    const { chatId } = req.params;
    const { page = 1, limit = 50 } = req.query;
    const userId = req.user._id;
    const skip = (page - 1) * limit;

    // Check if user is participant in the chat
    const chat = await Chat.findOne({
      _id: chatId,
      participants: userId,
    });

    if (!chat) {
      return res.status(404).json({
        success: false,
        message: "Chat not found or access denied",
      });
    }

    const messages = await Message.find({
      chat: chatId,
      isDeleted: false,
    })
      .populate("sender", "firstName lastName profilePicture")
      .populate("replyTo", "content sender")
      .populate("forwardedFrom", "content sender")
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(Number.parseInt(limit));

    const total = await Message.countDocuments({
      chat: chatId,
      isDeleted: false,
    });

    // Mark messages as read
    const unreadMessages = await Message.find({
      chat: chatId,
      sender: { $ne: userId },
      "readBy.user": { $ne: userId },
    });

    if (unreadMessages.length > 0) {
      await Message.updateMany(
        {
          chat: chatId,
          sender: { $ne: userId },
          "readBy.user": { $ne: userId },
        },
        {
          $push: {
            readBy: {
              user: userId,
              readAt: new Date(),
            },
          },
        }
      );

      // Update user's last read message
      await Chat.updateOne(
        { _id: chatId, "participantSettings.user": userId },
        {
          $set: {
            "participantSettings.$.lastReadMessage": messages[0]?._id,
          },
        }
      );
    }

    res.json({
      success: true,
      data: messages.reverse(),
      pagination: getPaginationMeta(Number.parseInt(page), Number.parseInt(limit), total),
    });
  } catch (error) {
    console.error("Get chat messages error:", error);
    res.status(500).json({
      success: false,
      message: "Failed to fetch messages",
      error: error.message,
    });
  }
};

// Send message
const sendMessage = async (req, res) => {
  try {
    const { chatId } = req.params;
    const { content, messageType = "text", scripture, replyToId, encryptedContent } = req.body;
    const userId = req.user._id;

    // Check if user is participant in the chat
    const chat = await Chat.findOne({
      _id: chatId,
      participants: userId,
    });

    if (!chat) {
      return res.status(404).json({
        success: false,
        message: "Chat not found or access denied",
      });
    }

    // Check if user has blocked any participant
    const user = await User.findById(userId);
    const otherParticipants = chat.participants.filter(
      (p) => p.toString() !== userId.toString()
    );
    if (otherParticipants.some((p) => user.blockedUsers.includes(p))) {
      return res.status(403).json({
        success: false,
        message: "Cannot send message to a blocked user",
      });
    }

    const messageData = {
      chat: chatId,
      sender: userId,
      content,
      messageType,
      encryptedContent, // Store encrypted content if provided
    };

    // Handle scripture message
    if (messageType === "scripture" && scripture) {
      messageData.scripture = scripture;
    }

    // Handle reply
    if (replyToId) {
      const replyToMessage = await Message.findById(replyToId);
      if (replyToMessage && replyToMessage.chat.toString() === chatId) {
        messageData.replyTo = replyToId;
      }
    }

    // Handle file attachments
    if (req.files && req.files.length > 0) {
      const uploadResults = await saveMultipleFiles(req.files, "messages");
      messageData.attachments = uploadResults.map((result) => ({
        type: result.url,
        fileType: result.fileType || "image", // Support image, video, document
        fileName: result.fileName,
      }));
    }

    const message = new Message(messageData);
    await message.save();

    // Update chat's last message and activity
    chat.lastMessage = message._id;
    chat.lastActivity = new Date();
    await chat.save();

    // Populate message data
    await message.populate("sender", "firstName lastName profilePicture");
    if (message.replyTo) {
      await message.populate("replyTo", "content sender");
    }
    if (message.forwardedFrom) {
      await message.populate("forwardedFrom", "content sender");
    }

    // Create notifications for other participants (if not muted)
    const notifications = otherParticipants
      .filter(async (participantId) => {
        const settings = chat.participantSettings.find(
          (s) => s.user.toString() === participantId.toString()
        );
        return !settings.isMuted;
      })
      .map((participantId) => ({
        recipient: participantId,
        sender: userId,
        type: "message",
        title: "New message",
        message: `${req.user.firstName} sent you a message`,
        relatedChat: chatId,
      }));

    await Notification.insertMany(notifications);

    res.status(201).json({
      success: true,
      message: "Message sent successfully",
      data: message,
    });
  } catch (error) {
    console.error("Send message error:", error);
    res.status(500).json({
      success: false,
      message: "Failed to send message",
      error: error.message,
    });
  }
};

// Edit message
const editMessage = async (req, res) => {
  try {
    const { messageId } = req.params;
    const { content, encryptedContent } = req.body;
    const userId = req.user._id;

    const message = await Message.findById(messageId);
    if (!message) {
      return res.status(404).json({
        success: false,
        message: "Message not found",
      });
    }

    if (message.sender.toString() !== userId.toString()) {
      return res.status(403).json({
        success: false,
        message: "You can only edit your own messages",
      });
    }

    const timeLimit = 15 * 60 * 1000; // 15 minutes
    if (new Date() - new Date(message.createdAt) > timeLimit) {
      return res.status(403).json({
        success: false,
        message: "Message edit time limit exceeded",
      });
    }

    message.content = content;
    message.encryptedContent = encryptedContent;
    message.isEdited = true;
    message.editedAt = new Date();
    await message.save();

    await message.populate("sender", "firstName lastName profilePicture");
    if (message.replyTo) {
      await message.populate("replyTo", "content sender");
    }
    if (message.forwardedFrom) {
      await message.populate("forwardedFrom", "content sender");
    }

    res.json({
      success: true,
      message: "Message edited successfully",
      data: message,
    });
  } catch (error) {
    console.error("Edit message error:", error);
    res.status(500).json({
      success: false,
      message: "Failed to edit message",
      error: error.message,
    });
  }
};

// Add reaction to message
const addReaction = async (req, res) => {
  try {
    const { messageId } = req.params;
    const { emoji } = req.body;
    const userId = req.user._id;

    const message = await Message.findById(messageId);
    if (!message) {
      return res.status(404).json({
        success: false,
        message: "Message not found",
      });
    }

    const chat = await Chat.findOne({
      _id: message.chat,
      participants: userId,
    });

    if (!chat) {
      return res.status(403).json({
        success: false,
        message: "Access denied",
      });
    }

    const existingReaction = message.reactions.find(
      (reaction) => reaction.user.toString() === userId.toString() && reaction.emoji === emoji
    );

    if (existingReaction) {
      message.reactions = message.reactions.filter(
        (reaction) => !(reaction.user.toString() === userId.toString() && reaction.emoji === emoji)
      );
    } else {
      message.reactions.push({
        user: userId,
        emoji,
      });
    }

    await message.save();

    res.json({
      success: true,
      message: existingReaction ? "Reaction removed" : "Reaction added",
      data: {
        reactions: message.reactions,
      },
    });
  } catch (error) {
    console.error("Add reaction error:", error);
    res.status(500).json({
      success: false,
      message: "Failed to add reaction",
      error: error.message,
    });
  }
};

// Delete message
const deleteMessage = async (req, res) => {
  try {
    const { messageId } = req.params;
    const userId = req.user._id;

    const message = await Message.findById(messageId);
    if (!message) {
      return res.status(404).json({
        success: false,
        message: "Message not found",
      });
    }

    if (message.sender.toString() !== userId.toString()) {
      return res.status(403).json({
        success: false,
        message: "You can only delete your own messages",
      });
    }

    message.isDeleted = true;
    message.deletedAt = new Date();
    await message.save();

    res.json({
      success: true,
      message: "Message deleted successfully",
    });
  } catch (error) {
    console.error("Delete message error:", error);
    res.status(500).json({
      success: false,
      message: "Failed to delete message",
      error: error.message,
    });
  }
};

// Block user
const blockUser = async (req, res) => {
  try {
    const { userIdToBlock } = req.body;
    const userId = req.user._id;

    if (userIdToBlock === userId.toString()) {
      return res.status(400).json({
        success: false,
        message: "Cannot block yourself",
      });
    }

    const userToBlock = await User.findById(userIdToBlock);
    if (!userToBlock) {
      return res.status(404).json({
        success: false,
        message: "User not found",
      });
    }

    await User.findByIdAndUpdate(userId, {
      $addToSet: { blockedUsers: userIdToBlock },
    });

    res.json({
      success: true,
      message: "User blocked successfully",
    });
  } catch (error) {
    console.error("Block user error:", error);
    res.status(500).json({
      success: false,
      message: "Failed to block user",
      error: error.message,
    });
  }
};

// Unblock user
const unblockUser = async (req, res) => {
  try {
    const { userIdToUnblock } = req.body;
    const userId = req.user._id;

    await User.findByIdAndUpdate(userId, {
      $pull: { blockedUsers: userIdToUnblock },
    });

    res.json({
      success: true,
      message: "User unblocked successfully",
    });
  } catch (error) {
    console.error("Unblock user error:", error);
    res.status(500).json({
      success: false,
      message: "Failed to unblock user",
      error: error.message,
    });
  }
};

// Forward message
const forwardMessage = async (req, res) => {
  try {
    const { messageId } = req.params;
    const { targetChatId } = req.body;
    const userId = req.user._id;

    // Verify original message
    const originalMessage = await Message.findById(messageId);
    if (!originalMessage) {
      return res.status(404).json({
        success: false,
        message: "Message not found",
      });
    }

    // Verify target chat
    const targetChat = await Chat.findOne({
      _id: targetChatId,
      participants: userId,
    });
    if (!targetChat) {
      return res.status(404).json({
        success: false,
        message: "Target chat not found or access denied",
      });
    }

    // Check for blocked users in target chat
    const user = await User.findById(userId);
    const otherParticipants = targetChat.participants.filter(
      (p) => p.toString() !== userId.toString()
    );
    if (otherParticipants.some((p) => user.blockedUsers.includes(p))) {
      return res.status(403).json({
        success: false,
        message: "Cannot forward message to a chat with a blocked user",
      });
    }

    // Create forwarded message
    const forwardedMessage = new Message({
      chat: targetChatId,
      sender: userId,
      content: originalMessage.content,
      encryptedContent: originalMessage.encryptedContent,
      messageType: originalMessage.messageType,
      scripture: originalMessage.scripture,
      attachments: originalMessage.attachments,
      forwardedFrom: messageId,
    });

    await forwardedMessage.save();

    // Update target chat
    targetChat.lastMessage = forwardedMessage._id;
    targetChat.lastActivity = new Date();
    await targetChat.save();

    // Populate forwarded message
    await forwardedMessage.populate("sender", "firstName lastName profilePicture");
    if (forwardedMessage.forwardedFrom) {
      await forwardedMessage.populate("forwardedFrom", "content sender");
    }

    // Create notifications for other participants (if not muted)
    const notifications = otherParticipants
      .filter(async (participantId) => {
        const settings = targetChat.participantSettings.find(
          (s) => s.user.toString() === participantId.toString()
        );
        return !settings.isMuted;
      })
      .map((participantId) => ({
        recipient: participantId,
        sender: userId,
        type: "message",
        title: "New forwarded message",
        message: `${req.user.firstName} forwarded a message`,
        relatedChat: targetChatId,
      }));

    await Notification.insertMany(notifications);

    res.status(201).json({
      success: true,
      message: "Message forwarded successfully",
      data: forwardedMessage,
    });
  } catch (error) {
    console.error("Forward message error:", error);
    res.status(500).json({
      success: false,
      message: "Failed to forward message",
      error: error.message,
    });
  }
};

// Delete chat
const deleteChat = async (req, res) => {
  try {
    const { chatId } = req.params;
    const userId = req.user._id;

    const chat = await Chat.findOne({
      _id: chatId,
      participants: userId,
    });

    if (!chat) {
      return res.status(404).json({
        success: false,
        message: "Chat not found or access denied",
      });
    }

    // For direct chats, mark as inactive for the user
    await Chat.updateOne(
      { _id: chatId, "participantSettings.user": userId },
      {
        $set: {
          "participantSettings.$.leftAt": new Date(),
          isActive: false,
        },
      }
    );

    res.json({
      success: true,
      message: "Chat deleted successfully",
    });
  } catch (error) {
    console.error("Delete chat error:", error);
    res.status(500).json({
      success: false,
      message: "Failed to delete chat",
      error: error.message,
    });
  }
};

// Pin message
const pinMessage = async (req, res) => {
  try {
    const { chatId, messageId } = req.params;
    const userId = req.user._id;

    const chat = await Chat.findOne({
      _id: chatId,
      participants: userId,
    });

    if (!chat) {
      return res.status(404).json({
        success: false,
        message: "Chat not found or access denied",
      });
    }

    const message = await Message.findById(messageId);
    if (!message || message.chat.toString() !== chatId) {
      return res.status(404).json({
        success: false,
        message: "Message not found or not in this chat",
      });
    }

    if (message.isDeleted) {
      return res.status(400).json({
        success: false,
        message: "Cannot pin a deleted message",
      });
    }

    message.isPinned = true;
    await message.save();

    await Chat.findByIdAndUpdate(chatId, {
      $addToSet: { pinnedMessages: messageId },
    });

    res.json({
      success: true,
      message: "Message pinned successfully",
    });
  } catch (error) {
    console.error("Pin message error:", error);
    res.status(500).json({
      success: false,
      message: "Failed to pin message",
      error: error.message,
    });
  }
};

// Unpin message
const unpinMessage = async (req, res) => {
  try {
    const { chatId, messageId } = req.params;
    const userId = req.user._id;

    const chat = await Chat.findOne({
      _id: chatId,
      participants: userId,
    });

    if (!chat) {
      return res.status(404).json({
        success: false,
        message: "Chat not found or access denied",
      });
    }

    const message = await Message.findById(messageId);
    if (!message || message.chat.toString() !== chatId) {
      return res.status(404).json({
        success: false,
        message: "Message not found or not in this chat",
      });
    }

    message.isPinned = false;
    await message.save();

    await Chat.findByIdAndUpdate(chatId, {
      $pull: { pinnedMessages: messageId },
    });

    res.json({
      success: true,
      message: "Message unpinned successfully",
    });
  } catch (error) {
    console.error("Unpin message error:", error);
    res.status(500).json({
      success: false,
      message: "Failed to unpin message",
      error: error.message,
    });
  }
};

// Mute chat notifications
const muteChat = async (req, res) => {
  try {
    const { chatId } = req.params;
    const userId = req.user._id;

    const chat = await Chat.findOne({
      _id: chatId,
      participants: userId,
    });

    if (!chat) {
      return res.status(404).json({
        success: false,
        message: "Chat not found or access denied",
      });
    }

    await Chat.updateOne(
      { _id: chatId, "participantSettings.user": userId },
      {
        $set: { "participantSettings.$.isMuted": true },
      }
    );

    res.json({
      success: true,
      message: "Chat notifications muted successfully",
    });
  } catch (error) {
    console.error("Mute chat error:", error);
    res.status(500).json({
      success: false,
      message: "Failed to mute chat notifications",
      error: error.message,
    });
  }
};

// Unmute chat notifications
const unmuteChat = async (req, res) => {
  try {
    const { chatId } = req.params;
    const userId = req.user._id;

    const chat = await Chat.findOne({
      _id: chatId,
      participants: userId,
    });

    if (!chat) {
      return res.status(404).json({
        success: false,
        message: "Chat not found or access denied",
      });
    }

    await Chat.updateOne(
      { _id: chatId, "participantSettings.user": userId },
      {
        $set: { "participantSettings.$.isMuted": false },
      }
    );

    res.json({
      success: true,
      message: "Chat notifications unmuted successfully",
    });
  } catch (error) {
    console.error("Unmute chat error:", error);
    res.status(500).json({
      success: false,
      message: "Failed to unmute chat notifications",
      error: error.message,
    });
  }
};

// Search messages in a chat
const searchMessages = async (req, res) => {
  try {
    const { chatId } = req.params;
    const { query, page = 1, limit = 20 } = req.query;
    const userId = req.user._id;
    const skip = (page - 1) * limit;

    const chat = await Chat.findOne({
      _id: chatId,
      participants: userId,
    });

    if (!chat) {
      return res.status(404).json({
        success: false,
        message: "Chat not found or access denied",
      });
    }

    const messages = await Message.find({
      chat: chatId,
      isDeleted: false,
      $text: { $search: query },
    })
      .populate("sender", "firstName lastName profilePicture")
      .populate("replyTo", "content sender")
      .populate("forwardedFrom", "content sender")
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(Number.parseInt(limit));

    const total = await Message.countDocuments({
      chat: chatId,
      isDeleted: false,
      $text: { $search: query },
    });

    res.json({
      success: true,
      data: messages.reverse(),
      pagination: getPaginationMeta(Number.parseInt(page), Number.parseInt(limit), total),
    });
  } catch (error) {
    console.error("Search messages error:", error);
    res.status(500).json({
      success: false,
      message: "Failed to search messages",
      error: error.message,
    });
  }
};

// Handle typing (placeholder, no real-time logic)
const handleTyping = async (req, res) => {
  try {
    const { chatId } = req.params;
    const userId = req.user._id;

    const chat = await Chat.findOne({
      _id: chatId,
      participants: userId,
    });

    if (!chat) {
      return res.status(404).json({
        success: false,
        message: "Chat not found or access denied",
      });
    }

    res.json({ success: true, message: "Typing event recorded" });
  } catch (error) {
    console.error("Typing event error:", error);
    res.status(500).json({
      success: false,
      message: "Failed to record typing event",
      error: error.message,
    });
  }
};

module.exports = {
  getUserChats,
  createDirectChat,
  getChatMessages,
  sendMessage,
  addReaction,
  deleteMessage,
  handleTyping,
  editMessage,
  blockUser,
  unblockUser,
  forwardMessage,
  deleteChat,
  pinMessage,
  unpinMessage,
  muteChat,
  unmuteChat,
  searchMessages,
};