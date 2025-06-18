const { verify } = require("jsonwebtoken");
const User = require("../models/User");
const Chat = require("../models/Chat");
const Message = require("../models/Message");
const Notification = require("../models/Notification");
const { saveMultipleFiles } = require("../utils/localStorageService");

module.exports = (io) => {
  io.use(async (socket, next) => {
    const token = socket.handshake.auth.token;
    if (!token) return next(new Error("Authentication required"));
    try {
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
    socket.on("joinChat", (chatId) => {
      socket.join(chatId);
    });

    socket.on("sendMessage", async ({ chatId, content, messageType = "text", scripture, replyToId, files = [] }, callback) => {
      try {
        const userId = socket.user._id;
        const chat = await Chat.findOne({ _id: chatId, participants: userId });
        if (!chat) throw new Error("Chat not found or access denied");

        const user = await User.findById(userId);
        const otherParticipants = chat.participants.filter((p) => p.toString() !== userId.toString());
        if (otherParticipants.some((p) => user.blockedUsers.includes(p))) {
          throw new Error("Cannot send message to a blocked user");
        }

        const messageData = {
          chat: chatId,
          sender: userId,
          content,
          messageType,
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

        if (files.length > 0) {
          const uploadResults = await saveMultipleFiles(files, "messages");
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
              message: `${user.firstName} sent you a message`,
              relatedChat: chatId,
            });
          }
        }
        await Notification.insertMany(notifications);

        io.to(chatId).emit("newMessage", message);
        callback({ success: true, data: message });
      } catch (error) {
        callback({ success: false, message: error.message });
      }
    });

    socket.on("typing", ({ chatId }) => {
      socket.to(chatId).emit("typing", { userId: socket.user._id, firstName: socket.user.firstName });
    });

    socket.on("stopTyping", ({ chatId }) => {
      socket.to(chatId).emit("stopTypings", { userId: socket.user._id });
    });
  });
};