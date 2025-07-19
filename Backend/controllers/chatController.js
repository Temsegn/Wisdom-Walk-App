const Chat = require("../models/Chat");
const Message = require("../models/Message");
const User = require("../models/User");
const Notification = require("../models/Notification");
const { getPaginationMeta } = require("../utils/helpers");
const { saveMultipleFiles } = require("../utils/localStorageService");
const mongoose = require('mongoose');
const getUserChats = async (req, res) => {
  try {
    const userId = req.user._id;
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;

    // Fetch chats with optimized query
    const chats = await Chat.find({
      participants: userId,
      isActive: true,
      lastMessage: { $exists: true } // Only include chats with messages
    })
      .populate({
        path: 'participants',
        select: 'firstName lastName profilePicture lastActive isOnline',
        match: { _id: { $ne: userId } } // Exclude current user from participants array
      })
      .populate('lastMessage')
      .sort({ lastActivity: -1 })
      .skip(skip)
      .limit(limit)
      .lean(); // Use lean() for better performance

    // Get total count for pagination
    const total = await Chat.countDocuments({
      participants: userId,
      isActive: true,
      lastMessage: { $exists: true }
    });

    // Process chats in parallel
    const formattedChats = await Promise.all(
      chats.map(async (chat) => {
        const userSettings = chat.participantSettings.find(
          setting => setting.user.toString() === userId.toString()
        );

        // Calculate unread messages
        const unreadCount = await Message.countDocuments({
          chat: chat._id,
          sender: { $ne: userId },
          ...(userSettings?.lastReadMessage && { _id: { $gt: userSettings.lastReadMessage } })
        });

        // Handle direct chat specifics
        if (chat.type === 'direct') {
          const otherParticipant = chat.participants[0]; // Since we filtered out current user
          
          return {
            ...chat,
            unreadCount,
            chatName: otherParticipant 
              ? `${otherParticipant.firstName || ''} ${otherParticipant.lastName || ''}`.trim()
              : 'Deleted User',
            chatImage: otherParticipant?.profilePicture || null,
            isOnline: otherParticipant?.isOnline || false,
            lastActive: otherParticipant?.lastActive || null
          };
        }

        // For group chats
        return {
          ...chat,
          unreadCount,
          chatName: chat.groupName || 'Group Chat',
          chatImage: chat.groupImage || null,
          isOnline: false // Groups don't have online status
        };
      })
    );

    // Filter out any null/undefined values
    const validChats = formattedChats.filter(chat => chat !== null);

    res.json({
      success: true,
      data: validChats,
      pagination: getPaginationMeta(page, limit, total),
    });

  } catch (error) {
    console.error('Get user chats error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch chats',
      error: error.message,
      ...(process.env.NODE_ENV === 'development' && { stack: error.stack })
    });
  }
};
const createDirectChat = async (req, res) => {
  const session = await mongoose.startSession();
  session.startTransaction();

  try {
    const { participantId } = req.body;
    const userId = req.user._id;

    // 1. Validate input
    if (!participantId || !mongoose.Types.ObjectId.isValid(participantId)) {
      await session.abortTransaction();
      return res.status(400).json({ success: false, message: "Invalid participant ID" });
    }

    // 2. Verify users exist
    const [user, participant] = await Promise.all([
      User.findById(userId).session(session),
      User.findById(participantId).session(session)
    ]);

    if (!user || !participant) {
      await session.abortTransaction();
      return res.status(404).json({ success: false, message: "User not found" });
    }

    // 3. Check for existing chats (transaction-safe)
    const existingChat = await Chat.findOne({
      type: "direct",
      participants: { $all: [userId, participantId], $size: 2 }
    }).session(session);

    if (existingChat) {
      await session.commitTransaction();
      return res.json({ 
        success: true, 
        data: await existingChat.populate('participants') 
      });
    }

    // 4. Create new chat
    const chat = new Chat({
      type: "direct",
      participants: [userId, participantId],
      participantSettings: [
        { user: userId, notification: 'all' },
        { user: participantId, notification: 'all' }
      ]
    });

    await chat.save({ session });
    await session.commitTransaction();

    res.status(201).json({ 
      success: true, 
      data: await chat.populate('participants') 
    });
  } catch (error) {
    await session.abortTransaction();
    console.error("Chat creation error:", error);
    res.status(500).json({ 
      success: false, 
      message: error.message || "Chat creation failed" 
    });
  } finally {
    session.endSession();
  }
};
 const getChatMessages = async (req, res) => {
  try {
    const { chatId } = req.params;
    const { page = 1, limit = 50 } = req.query;
    const userId = req.user._id;
    const skip = (page - 1) * limit;

    // Handle preview chat IDs (skip database queries)
    if (chatId.startsWith('preview-')) {
      return res.json({
        success: true,
        data: [],
        pagination: getPaginationMeta(Number.parseInt(page), Number.parseInt(limit), 0),
        isPreview: true
      });
    }

    // Validate chat ID format
    if (!mongoose.Types.ObjectId.isValid(chatId)) {
      return res.status(400).json({
        success: false,
        message: "Invalid chat ID format"
      });
    }

    // Check chat access
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

    // Get messages
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

    // Mark messages as read (only for real chats)
    if (!chatId.startsWith('preview-')) {
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
      error: process.env.NODE_ENV === 'development' ? error.message : undefined,
    });
  }
};

const sendMessage = async (req, res) => {
  try {
    const { chatId } = req.params;
    const { content, messageType = "text", scripture, replyToId, encryptedContent } = req.body;
    const userId = req.user._id;
    const io = req.app.get("io");

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
      encryptedContent,
    };

    if (messageType === "scripture" && scripture) {
      messageData.scripture = scripture;
    }

    if (replyToId) {
      const replyToMessage = await Message.findById(replyToId);
      if (replyToMessage && replyToMessage.chat.toString() === chatId) {
        messageData.replyTo = replyToId;
      }
    }

    if (req.files && req.files.length > 0) {
      const uploadResults = await saveMultipleFiles(req.files, "messages");
      messageData.attachments = uploadResults.map((result) => ({
        type: result.url,
        fileType: result.fileType || "image",
        fileName: result.fileName,
      }));
    }

    const message = new Message(messageData);
    await message.save();

    chat.lastMessage = message._id;
    chat.lastActivity = new Date();
    await chat.save();

    await message.populate("sender", "firstName lastName profilePicture");
    if (message.replyTo) {
      await message.populate("replyTo", "content sender");
    }
    if (message.forwardedFrom) {
      await message.populate("forwardedFrom", "content sender");
    }

    const notifications = [];
    for (const participantId of otherParticipants) {
      const settings = chat.participantSettings.find(
        (s) => s.user.toString() === participantId.toString()
      );
      if (!settings.isMuted) {
        notifications.push({
          recipient: participantId,
          sender: userId,
          type: "message",
          title: "New message",
          message: `${req.user.firstName} sent you a message`,
          relatedChat: chatId,
        });
      }
    }
    await Notification.insertMany(notifications);

    io.to(chatId).emit("newMessage", message);

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


const editMessage = async (req, res) => {
  try {
    const { messageId } = req.params;
    const { content, encryptedContent } = req.body;
    const userId = req.user._id;
    const io = req.app.get("io");

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

    const timeLimit = 15 * 60 * 1000;
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

    io.to(message.chat.toString()).emit("messageEdited", message);

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

const addReaction = async (req, res) => {
  try {
    const { messageId } = req.params;
    const { emoji } = req.body;
    const userId = req.user._id;
    const io = req.app.get("io");

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

    io.to(message.chat.toString()).emit("messageReaction", { messageId, reactions: message.reactions });

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

const deleteMessage = async (req, res) => {
  try {
    const { messageId } = req.params;
    const userId = req.user._id;
    const io = req.app.get("io");

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

    io.to(message.chat.toString()).emit("messageDeleted", { messageId });

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

const forwardMessage = async (req, res) => {
  try {
    const { messageId } = req.params;
    const { targetChatId } = req.body;
    const userId = req.user._id;
    const io = req.app.get("io");

    const originalMessage = await Message.findById(messageId);
    if (!originalMessage) {
      return res.status(404).json({
        success: false,
        message: "Message not found",
      });
    }

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

    targetChat.lastMessage = forwardedMessage._id;
    targetChat.lastActivity = new Date();
    await targetChat.save();

    await forwardedMessage.populate("sender", "firstName lastName profilePicture");
    if (forwardedMessage.forwardedFrom) {
      await forwardedMessage.populate("forwardedFrom", "content sender");
    }

    const notifications = [];
    for (const participantId of otherParticipants) {
      const settings = targetChat.participantSettings.find(
        (s) => s.user.toString() === participantId.toString()
      );
      if (!settings.isMuted) {
        notifications.push({
          recipient: participantId,
          sender: userId,
          type: "message",
          title: "New forwarded message",
          message: `${req.user.firstName} forwarded a message`,
          relatedChat: targetChatId,
        });
      }
    }
    await Notification.insertMany(notifications);

    io.to(targetChatId).emit("newMessage", forwardedMessage);

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

const pinMessage = async (req, res) => {
  try {
    const { chatId, messageId } = req.params;
    const userId = req.user._id;
    const io = req.app.get("io");

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

    // Emit to all clients in the chat room
    io.to(chatId).emit("messagePinned", { 
      messageId: message._id,
      chatId: chatId
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

const unpinMessage = async (req, res) => {
  try {
    const { chatId, messageId } = req.params;
    const userId = req.user._id;
    const io = req.app.get("io");

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

    io.to(chatId).emit("messageUnpinned", { messageId });

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

module.exports = {
  getUserChats,
  createDirectChat,
  getChatMessages,
  sendMessage,
  addReaction,
  deleteMessage,
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