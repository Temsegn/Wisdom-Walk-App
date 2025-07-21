const { verify } = require("jsonwebtoken")
const User = require("../models/User")
const Chat = require("../models/Chat")
const Message = require("../models/Message")
const Notification = require("../models/Notification")
const { saveMultipleFiles } = require("../utils/localStorageService")

// Track connected users
const connectedUsers = new Map()

module.exports = (io) => {
  io.use(async (socket, next) => {
    try {
      const token = socket.handshake.auth.token // Fixed: Get token from auth object
      if (!token) return next(new Error("Authentication required"))

      const decoded = verify(token, process.env.JWT_SECRET)
      const user = await User.findById(decoded.userId)
      if (!user) return next(new Error("User not found"))

      socket.user = user
      next()
    } catch (error) {
      next(new Error("Invalid token"))
    }
  })

  io.on("connection", (socket) => {
    console.log(`User connected: ${socket.user._id}`)
    connectedUsers.set(socket.user._id.toString(), socket.id)

    // Join user to all their chats
    Chat.find({ participants: socket.user._id }).then((chats) => {
      chats.forEach((chat) => {
        socket.join(chat._id.toString())
        console.log(`User ${socket.user._id} joined chat ${chat._id}`)
      })
    })

    // Handle joining specific chat
    socket.on("joinChat", (chatId) => {
      socket.join(chatId)
      console.log(`User ${socket.user._id} joined chat ${chatId}`)
    })

    // Handle leaving specific chat
    socket.on("leaveChat", (chatId) => {
      socket.leave(chatId)
      console.log(`User ${socket.user._id} left chat ${chatId}`)
    })

    // Message handlers
    socket.on("sendMessage", async ({ chatId, content, messageType = "text", replyToId, files = [] }, callback) => {
      try {
        const userId = socket.user._id
        const chat = await Chat.findOne({ _id: chatId, participants: userId })
        if (!chat) throw new Error("Chat not found or access denied")

        const user = await User.findById(userId)
        const otherParticipants = chat.participants.filter((p) => p.toString() !== userId.toString())

        // Check for blocked users
        if (otherParticipants.some((p) => user.blockedUsers.includes(p))) {
          throw new Error("Cannot send message to a blocked user")
        }

        // Create message
        const messageData = {
          chat: chatId,
          sender: userId,
          content,
          messageType,
          replyTo: replyToId,
        }

        // Handle file attachments
        if (files.length > 0) {
          const uploadResults = await saveMultipleFiles(files, "messages")
          messageData.attachments = uploadResults.map((result) => ({
            type: result.url,
            fileType: result.fileType || "image",
            fileName: result.fileName,
          }))
        }

        const message = new Message(messageData)
        await message.save()

        // Update chat last message
        chat.lastMessage = message._id
        chat.lastActivity = new Date()
        await chat.save()

        // Populate sender info
        await message.populate("sender", "firstName lastName profilePicture")
        if (message.replyTo) {
          await message.populate("replyTo", "content sender")
        }

        // Send notifications to offline users
        const notifications = []
        for (const participantId of otherParticipants) {
          const settings = chat.participantSettings.find((s) => s.user.toString() === participantId.toString())

          // Only notify if not muted and user is offline
          if (!settings?.isMuted && !connectedUsers.has(participantId.toString())) {
            notifications.push({
              recipient: participantId,
              sender: userId,
              type: "message",
              title: "New message",
              message: `${user.firstName} sent you a message`,
              relatedChat: chatId,
            })
          }
        }

        if (notifications.length > 0) {
          await Notification.insertMany(notifications)
        }

        // Emit to all in chat room
        io.to(chatId).emit("newMessage", message)
        callback({ success: true, data: message })
      } catch (error) {
        console.error("Send message error:", error)
        callback({ success: false, message: error.message })
      }
    })

    // Message editing
    socket.on("messageEdited", async ({ chatId, messageId, content }) => {
      try {
        const userId = socket.user._id
        const message = await Message.findById(messageId)

        if (!message || message.sender.toString() !== userId.toString()) {
          return
        }

        message.content = content
        message.isEdited = true
        message.editedAt = new Date()
        await message.save()

        await message.populate("sender", "firstName lastName profilePicture")

        io.to(chatId).emit("messageEdited", message)
      } catch (error) {
        console.error("Edit message error:", error)
      }
    })

    // Message deletion
    socket.on("messageDeleted", async ({ chatId, messageId }) => {
      try {
        const userId = socket.user._id
        const message = await Message.findById(messageId)

        if (!message || message.sender.toString() !== userId.toString()) {
          return
        }

        message.isDeleted = true
        message.deletedAt = new Date()
        await message.save()

        io.to(chatId).emit("messageDeleted", { messageId })
      } catch (error) {
        console.error("Delete message error:", error)
      }
    })

    // Message pinning
    socket.on("pinMessage", async ({ chatId, messageId }) => {
      try {
        const userId = socket.user._id
        const chat = await Chat.findOne({ _id: chatId, participants: userId })
        if (!chat) return

        const message = await Message.findById(messageId)
        if (!message || message.chat.toString() !== chatId) return

        // Update message pin status
        message.isPinned = true
        await message.save()

        // Update chat pinned messages
        await Chat.findByIdAndUpdate(chatId, {
          $addToSet: { pinnedMessages: messageId },
        })

        io.to(chatId).emit("messagePinned", {
          messageId,
          chatId,
          pinnedBy: {
            _id: userId,
            firstName: socket.user.firstName,
            lastName: socket.user.lastName,
          },
        })
      } catch (error) {
        console.error("Pin message error:", error)
      }
    })

    // Message unpinning
    socket.on("unpinMessage", async ({ chatId, messageId }) => {
      try {
        const userId = socket.user._id
        const chat = await Chat.findOne({ _id: chatId, participants: userId })
        if (!chat) return

        const message = await Message.findById(messageId)
        if (!message || message.chat.toString() !== chatId) return

        // Update message pin status
        message.isPinned = false
        await message.save()

        // Update chat pinned messages
        await Chat.findByIdAndUpdate(chatId, {
          $pull: { pinnedMessages: messageId },
        })

        io.to(chatId).emit("messageUnpinned", {
          messageId,
          chatId,
          unpinnedBy: {
            _id: userId,
            firstName: socket.user.firstName,
            lastName: socket.user.lastName,
          },
        })
      } catch (error) {
        console.error("Unpin message error:", error)
      }
    })

    // Message reactions
    socket.on("addReaction", async ({ chatId, messageId, emoji }) => {
      try {
        const userId = socket.user._id
        const message = await Message.findById(messageId)
        if (!message) return

        const chat = await Chat.findOne({ _id: message.chat, participants: userId })
        if (!chat) return

        const existingReactionIndex = message.reactions.findIndex(
          (reaction) => reaction.user.toString() === userId.toString() && reaction.emoji === emoji,
        )

        let isAdding = false
        if (existingReactionIndex >= 0) {
          // Remove existing reaction
          message.reactions.splice(existingReactionIndex, 1)
          isAdding = false
        } else {
          // Add new reaction
          message.reactions.push({ user: userId, emoji })
          isAdding = true
        }

        await message.save()

        // Populate user info for the reaction
        await message.populate("reactions.user", "firstName lastName profilePicture")

        // Emit the reaction with proper structure
        const reactionData = {
          messageId,
          chatId,
          reaction: {
            emoji,
            userId: userId.toString(),
            user: {
              _id: userId,
              firstName: socket.user.firstName,
              lastName: socket.user.lastName,
              profilePicture: socket.user.profilePicture,
            },
            isAdding, // true if added, false if removed
          },
        }

        io.to(chatId).emit("messageReaction", reactionData)
      } catch (error) {
        console.error("Add reaction error:", error)
      }
    })

    // Typing indicators
    socket.on("typing", ({ chatId }) => {
      socket.to(chatId).emit("typing", {
        userId: socket.user._id,
        firstName: socket.user.firstName,
      })
    })

    socket.on("stopTyping", ({ chatId }) => {
      socket.to(chatId).emit("stopTyping", {
        userId: socket.user._id,
      })
    })

    // Ping/Pong for connection health
    socket.on("ping", () => {
      socket.emit("pong")
    })

    // Handle disconnection
    socket.on("disconnect", () => {
      console.log(`User disconnected: ${socket.user._id}`)
      connectedUsers.delete(socket.user._id.toString())
    })

    // Error handling
    socket.on("error", (err) => {
      console.error(`Socket error for user ${socket.user._id}:`, err)
    })
  })
}
