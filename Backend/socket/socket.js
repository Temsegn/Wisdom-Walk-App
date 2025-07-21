const { verify } = require("jsonwebtoken");
const User = require("../models/User");
const Chat = require("../models/Chat");
const Message = require("../models/Message");
const Notification = require("../models/Notification");
const { saveMultipleFiles } = require("../utils/localStorageService");

// Track connected users
const connectedUsers = new Map();

module.exports = (io) => {
  io.use(async (socket, next) => {
    try {
      const token = socket.handshake.auth.token;
      if (!token) return next(new Error("Authentication required"));
      
      const decoded = verify(token, process.env.JWT_SECRET);
      const user = await User.findById(decoded.userId);
      if (!user) return next(new Error("User not found"));
      
      socket.user = user;
      next();
    } catch (error) {
      next(new Error("Invalid token"));
    }
  });

  io.on("connection", (socket) => {
    console.log(`User connected: ${socket.user._id}`);
    connectedUsers.set(socket.user._id.toString(), socket.id);

    // Join user to all their chats
    Chat.find({ participants: socket.user._id })
      .then(chats => {
        chats.forEach(chat => {
          socket.join(chat._id.toString());
          console.log(`User ${socket.user._id} joined chat ${chat._id}`);
        });
      });

    // Message handlers
    socket.on("sendMessage", async ({ chatId, content, messageType = "text", replyToId, files = [] }, callback) => {
      try {
        const userId = socket.user._id;
        const chat = await Chat.findOne({ _id: chatId, participants: userId });
        if (!chat) throw new Error("Chat not found or access denied");

        const user = await User.findById(userId);
        const otherParticipants = chat.participants.filter(p => p.toString() !== userId.toString());
        
        // Check for blocked users
        if (otherParticipants.some(p => user.blockedUsers.includes(p))) {
          throw new Error("Cannot send message to a blocked user");
        }

        // Create message
        const messageData = {
          chat: chatId,
          sender: userId,
          content,
          messageType,
          replyTo: replyToId
        };

        // Handle file attachments
        if (files.length > 0) {
          const uploadResults = await saveMultipleFiles(files, "messages");
          messageData.attachments = uploadResults.map(result => ({
            type: result.url,
            fileType: result.fileType || "image",
            fileName: result.fileName
          }));
        }

        const message = new Message(messageData);
        await message.save();

        // Update chat last message
        chat.lastMessage = message._id;
        chat.lastActivity = new Date();
        await chat.save();

        // Populate sender info
        await message.populate("sender", "firstName lastName profilePicture");
        if (message.replyTo) {
          await message.populate("replyTo", "content sender");
        }

        // Send notifications to offline users
        const notifications = [];
        for (const participantId of otherParticipants) {
          const settings = chat.participantSettings.find(
            s => s.user.toString() === participantId.toString()
          );
          
          // Only notify if not muted and user is offline
          if (!settings.isMuted && !connectedUsers.has(participantId.toString())) {
            notifications.push({
              recipient: participantId,
              sender: userId,
              type: "message",
              title: "New message",
              message: `${user.firstName} sent you a message`,
              relatedChat: chatId
            });
          }
        }

        if (notifications.length > 0) {
          await Notification.insertMany(notifications);
        }

        // Emit to all in chat room
        io.to(chatId).emit("newMessage", message);
        callback({ success: true, data: message });
      } catch (error) {
        console.error("Send message error:", error);
        callback({ success: false, message: error.message });
      }
    });

    // Typing indicators
    socket.on("typing", ({ chatId }) => {
      socket.to(chatId).emit("typing", { 
        userId: socket.user._id, 
        firstName: socket.user.firstName 
      });
    });

    socket.on("stopTyping", ({ chatId }) => {
      socket.to(chatId).emit("stopTyping", { 
        userId: socket.user._id 
      });
    });

    // Handle disconnection
    socket.on("disconnect", () => {
      console.log(`User disconnected: ${socket.user._id}`);
      connectedUsers.delete(socket.user._id.toString());
    });

    // Error handling
    socket.on("error", (err) => {
      console.error(`Socket error for user ${socket.user._id}:`, err);
    });
  });
};