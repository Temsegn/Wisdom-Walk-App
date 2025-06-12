const mongoose = require("mongoose")

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
      required: true,
      maxlength: 2000,
    },

    messageType: {
      type: String,
      enum: ["text", "image", "scripture", "prayer"],
      default: "text",
    },

    // Media attachments
    attachments: [
      {
        type: String, // URL to file
        fileType: String,
        fileName: String,
      },
    ],

    // Scripture sharing
    scripture: {
      verse: String,
      reference: String,
    },

    // Message status
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

    // Read receipts
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

    // Reactions
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

    // Reply to message
    replyTo: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Message",
    },
  },
  {
    timestamps: true,
  },
)

// Indexes
messageSchema.index({ chat: 1, createdAt: -1 })
messageSchema.index({ sender: 1 })

module.exports = mongoose.model("Message", messageSchema)
