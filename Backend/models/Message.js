const mongoose = require("mongoose");

const messageSchema = new mongoose.Schema(
  {
    chat: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Chat",
      required: true,
    },
    sender: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
    content: {
      type: String,
            required: true, // Kept as required
      minlength: 1,
      maxlength: 2000, // Removed required: true to allow encryptedContent-only messages
    },
    encryptedContent: {
      type: String, // Placeholder for encrypted message content
    },
    messageType: {
      type: String,
      enum: ["text", "image", "scripture", "prayer", "video", "document"],
      default: "text",
    },
    attachments: [
      {
        type: { type: String }, // URL to file
        fileType: { type: String, enum: ["image", "video", "document"] },
        fileName: String,
      },
    ],
    scripture: {
      verse: String,
      reference: String,
    },
    forwardedFrom: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Message", // Reference to original message if forwarded
    },
    isPinned: {
      type: Boolean,
      default: false,
    },
    isEdited: {
      type: Boolean,
      default: false,
    },
    editedAt: Date,
    isDeleted: {
      type: Boolean,
      default: false,
    },
    deletedAt: Date,
    readBy: [
      {
        user: {
          type: mongoose.Schema.Types.ObjectId,
          ref: "User",
        },
        readAt: {
          type: Date,
          default: Date.now,
        },
      },
    ],
    reactions: [
      {
        user: {
          type: mongoose.Schema.Types.ObjectId,
          ref: "User",
        },
        emoji: String,
        createdAt: {
          type: Date,
          default: Date.now,
        },
      },
    ],
    replyTo: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Message",
    },
  },
  {
    timestamps: true,
  }
);

// Indexes
messageSchema.index({ chat: 1, createdAt: -1 });
messageSchema.index({ sender: 1 });
messageSchema.index({ content: "text" }); // For message search

module.exports = mongoose.model("Message", messageSchema);