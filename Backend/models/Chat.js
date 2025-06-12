const mongoose = require("mongoose")

const chatSchema = new mongoose.Schema(
  {
    participants: [
      {
        type: mongoose.Schema.Types.ObjectId,
        ref: "User",
        required: true,
      },
    ],

    type: {
      type: String,
      enum: ["direct", "group"],
      default: "direct",
    },

    // For group chats
    groupName: String,
    groupDescription: String,
    groupAdmin: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
    },

    // Last message for quick access
    lastMessage: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Message",
    },

    lastActivity: {
      type: Date,
      default: Date.now,
    },

    // Privacy settings
    isActive: {
      type: Boolean,
      default: true,
    },

    // Participant settings
    participantSettings: [
      {
        user: {
          type: mongoose.Schema.Types.ObjectId,
          ref: "User",
        },
        isMuted: {
          type: Boolean,
          default: false,
        },
        joinedAt: {
          type: Date,
          default: Date.now,
        },
        leftAt: Date,
        lastReadMessage: {
          type: mongoose.Schema.Types.ObjectId,
          ref: "Message",
        },
      },
    ],
  },
  {
    timestamps: true,
  },
)

// Indexes
chatSchema.index({ participants: 1 })
chatSchema.index({ lastActivity: -1 })
chatSchema.index({ type: 1 })

module.exports = mongoose.model("Chat", chatSchema)
