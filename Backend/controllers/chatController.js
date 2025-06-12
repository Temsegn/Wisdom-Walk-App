const Chat = require("../models/Chat")
const Message = require("../models/Message")
const User = require("../models/User")
const Notification = require("../models/Notification")
const { getPaginationMeta } = require("../utils/helpers")
const { saveMultipleFiles } = require("../utils/localStorageService")

// Get user's chats
const getUserChats = async (req, res) => {
  try {
    const userId = req.user._id
    const { page = 1, limit = 20 } = req.query
    const skip = (page - 1) * limit

    const chats = await Chat.find({
      participants: userId,
      isActive: true,
    })
      .populate("participants", "firstName lastName profilePicture lastActive")
      .populate("lastMessage")
      .sort({ lastActivity: -1 })
      .skip(skip)
      .limit(Number.parseInt(limit))

    const total = await Chat.countDocuments({
      participants: userId,
      isActive: true,
    })

    // Format chats with unread count
    const formattedChats = await Promise.all(
      chats.map(async (chat) => {
        const chatObj = chat.toObject()

        // Get unread messages count
        const userSettings = chat.participantSettings.find((setting) => setting.user.toString() === userId.toString())
        const lastReadMessage = userSettings?.lastReadMessage

        let unreadCount = 0
        if (lastReadMessage) {
          unreadCount = await Message.countDocuments({
            chat: chat._id,
            _id: { $gt: lastReadMessage },
            sender: { $ne: userId },
          })
        } else {
          unreadCount = await Message.countDocuments({
            chat: chat._id,
            sender: { $ne: userId },
          })
        }

        chatObj.unreadCount = unreadCount

        // For direct chats, get the other participant
        if (chat.type === "direct") {
          const otherParticipant = chat.participants.find((p) => p._id.toString() !== userId.toString())
          chatObj.chatName = `${otherParticipant.firstName} ${otherParticipant.lastName}`
          chatObj.chatImage = otherParticipant.profilePicture
        }

        return chatObj
      }),
    )

    res.json({
      success: true,
      data: formattedChats,
      pagination: getPaginationMeta(Number.parseInt(page), Number.parseInt(limit), total),
    })
  } catch (error) {
    console.error("Get user chats error:", error)
    res.status(500).json({
      success: false,
      message: "Failed to fetch chats",
      error: error.message,
    })
  }
}

// Create or get direct chat
const createDirectChat = async (req, res) => {
  try {
    const { participantId } = req.body
    const userId = req.user._id

    if (participantId === userId.toString()) {
      return res.status(400).json({
        success: false,
        message: "Cannot create chat with yourself",
      })
    }

    // Check if participant exists and is verified
    const participant = await User.findById(participantId)
    if (!participant || !participant.canAccess()) {
      return res.status(404).json({
        success: false,
        message: "User not found or not accessible",
      })
    }

    // Check if chat already exists
    let chat = await Chat.findOne({
      type: "direct",
      participants: { $all: [userId, participantId], $size: 2 },
    }).populate("participants", "firstName lastName profilePicture")

    if (!chat) {
      // Create new chat
      chat = new Chat({
        type: "direct",
        participants: [userId, participantId],
        participantSettings: [
          { user: userId, joinedAt: new Date() },
          { user: participantId, joinedAt: new Date() },
        ],
      })

      await chat.save()
      await chat.populate("participants", "firstName lastName profilePicture")
    }

    res.json({
      success: true,
      message: "Chat created/retrieved successfully",
      data: chat,
    })
  } catch (error) {
    console.error("Create direct chat error:", error)
    res.status(500).json({
      success: false,
      message: "Failed to create chat",
      error: error.message,
    })
  }
}

// Get chat messages
const getChatMessages = async (req, res) => {
  try {
    const { chatId } = req.params
    const { page = 1, limit = 50 } = req.query
    const userId = req.user._id
    const skip = (page - 1) * limit

    // Check if user is participant in the chat
    const chat = await Chat.findOne({
      _id: chatId,
      participants: userId,
    })

    if (!chat) {
      return res.status(404).json({
        success: false,
        message: "Chat not found or access denied",
      })
    }

    const messages = await Message.find({
      chat: chatId,
      isDeleted: false,
    })
      .populate("sender", "firstName lastName profilePicture")
      .populate("replyTo", "content sender")
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(Number.parseInt(limit))

    const total = await Message.countDocuments({
      chat: chatId,
      isDeleted: false,
    })

    // Mark messages as read
    const unreadMessages = await Message.find({
      chat: chatId,
      sender: { $ne: userId },
      "readBy.user": { $ne: userId },
    })

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
        },
      )

      // Update user's last read message
      await Chat.updateOne(
        { _id: chatId, "participantSettings.user": userId },
        {
          $set: {
            "participantSettings.$.lastReadMessage": messages[0]?._id,
          },
        },
      )
    }

    res.json({
      success: true,
      data: messages.reverse(), // Reverse to show oldest first
      pagination: getPaginationMeta(Number.parseInt(page), Number.parseInt(limit), total),
    })
  } catch (error) {
    console.error("Get chat messages error:", error)
    res.status(500).json({
      success: false,
      message: "Failed to fetch messages",
      error: error.message,
    })
  }
}

// Send message
const sendMessage = async (req, res) => {
  try {
    const { chatId } = req.params
    const { content, messageType = "text", scripture, replyToId } = req.body
    const userId = req.user._id

    // Check if user is participant in the chat
    const chat = await Chat.findOne({
      _id: chatId,
      participants: userId,
    })

    if (!chat) {
      return res.status(404).json({
        success: false,
        message: "Chat not found or access denied",
      })
    }

    const messageData = {
      chat: chatId,
      sender: userId,
      content,
      messageType,
    }

    // Handle scripture message
    if (messageType === "scripture" && scripture) {
      messageData.scripture = scripture
    }

    // Handle reply
    if (replyToId) {
      const replyToMessage = await Message.findById(replyToId)
      if (replyToMessage && replyToMessage.chat.toString() === chatId) {
        messageData.replyTo = replyToId
      }
    }

    // Handle file attachments
    if (req.files && req.files.length > 0) {
      const uploadResults = await saveMultipleFiles(req.files, "messages")
      messageData.attachments = uploadResults.map((result) => ({
        type: result.url,
        fileType: "image",
        fileName: result.fileName,
      }))
    }

    const message = new Message(messageData)
    await message.save()

    // Update chat's last message and activity
    chat.lastMessage = message._id
    chat.lastActivity = new Date()
    await chat.save()

    // Populate message data
    await message.populate("sender", "firstName lastName profilePicture")
    if (message.replyTo) {
      await message.populate("replyTo", "content sender")
    }

    // Create notifications for other participants
    const otherParticipants = chat.participants.filter((p) => p.toString() !== userId.toString())

    const notifications = otherParticipants.map((participantId) => ({
      recipient: participantId,
      sender: userId,
      type: "message",
      title: "New message",
      message: `${req.user.firstName} sent you a message`,
      relatedChat: chatId,
    }))

    await Notification.insertMany(notifications)

    res.status(201).json({
      success: true,
      message: "Message sent successfully",
      data: message,
    })
  } catch (error) {
    console.error("Send message error:", error)
    res.status(500).json({
      success: false,
      message: "Failed to send message",
      error: error.message,
    })
  }
}

// Add reaction to message
const addReaction = async (req, res) => {
  try {
    const { messageId } = req.params
    const { emoji } = req.body
    const userId = req.user._id

    const message = await Message.findById(messageId)
    if (!message) {
      return res.status(404).json({
        success: false,
        message: "Message not found",
      })
    }

    // Check if user is participant in the chat
    const chat = await Chat.findOne({
      _id: message.chat,
      participants: userId,
    })

    if (!chat) {
      return res.status(403).json({
        success: false,
        message: "Access denied",
      })
    }

    // Check if user already reacted with this emoji
    const existingReaction = message.reactions.find(
      (reaction) => reaction.user.toString() === userId.toString() && reaction.emoji === emoji,
    )

    if (existingReaction) {
      // Remove reaction
      message.reactions = message.reactions.filter(
        (reaction) => !(reaction.user.toString() === userId.toString() && reaction.emoji === emoji),
      )
    } else {
      // Add reaction
      message.reactions.push({
        user: userId,
        emoji,
      })
    }

    await message.save()

    res.json({
      success: true,
      message: existingReaction ? "Reaction removed" : "Reaction added",
      data: {
        reactions: message.reactions,
      },
    })
  } catch (error) {
    console.error("Add reaction error:", error)
    res.status(500).json({
      success: false,
      message: "Failed to add reaction",
      error: error.message,
    })
  }
}

// Delete message
const deleteMessage = async (req, res) => {
  try {
    const { messageId } = req.params
    const userId = req.user._id

    const message = await Message.findById(messageId)
    if (!message) {
      return res.status(404).json({
        success: false,
        message: "Message not found",
      })
    }

    // Check if user owns the message
    if (message.sender.toString() !== userId.toString()) {
      return res.status(403).json({
        success: false,
        message: "You can only delete your own messages",
      })
    }

    message.isDeleted = true
    message.deletedAt = new Date()
    await message.save()

    res.json({
      success: true,
      message: "Message deleted successfully",
    })
  } catch (error) {
    console.error("Delete message error:", error)
    res.status(500).json({
      success: false,
      message: "Failed to delete message",
      error: error.message,
    })
  }
}

module.exports = {
  getUserChats,
  createDirectChat,
  getChatMessages,
  sendMessage,
  addReaction,
  deleteMessage,
}
