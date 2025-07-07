const mongoose = require("mongoose");

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
    groupName: String,
    groupDescription: String,
    groupAdmin: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
    },
    lastMessage: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Message",
    },
    lastActivity: {
      type: Date,
      default: Date.now,
    },
    isActive: {
      type: Boolean,
      default: true,
    },
    pinnedMessages: [
      {
        type: mongoose.Schema.Types.ObjectId,
        ref: "Message",
      },
    ],
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
    validate: {
      validator: function() {
        // For direct messages, must have exactly 2 participants
        if (this.type === "direct") {
          return this.participants.length === 2;
        }
        return true; // No validation for group chats
      },
      message: "Direct messages must have exactly 2 participants"
    }
  }
);

chatSchema.index({ participants: 1 });
chatSchema.index({ lastActivity: -1 });
chatSchema.index({ type: 1 });

module.exports = mongoose.model("Chat", chatSchema);