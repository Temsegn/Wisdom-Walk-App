const mongoose = require("mongoose")

const notificationSchema = new mongoose.Schema(
  {
    recipient: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
      default:"all_users" // Default to all users if not specified
    },

    sender: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
    },

    type: {
      type: String,
      enum: [
        "prayer_request",
        "prayer_response",
        "comment",
        "like",
        "virtual_hug",
        "message",
        "group_invitation",
        "admin_verification",
        "admin_message",
        "post_moderated",
        "account_status",
        "signup",
        "post",
        "report",
         "blocked",
        "unblocked",
        "banned",
       ],
      required: true,
    },

    title: {
      type: String,
      required: true,
    },

    message: {
      type: String,
      required: true,
    },

    // Related content
    relatedPost: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Post",
    },

    relatedComment: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Comment",
    },

    relatedChat: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Chat",
    },

    // Notification data
    data: {
      type: mongoose.Schema.Types.Mixed,
    },

    // Status
    isRead: {
      type: Boolean,
      default: false,
    },

    readAt: Date,

    // Priority
    priority: {
      type: String,
      enum: ["low", "normal", "high", "urgent"],
      default: "normal",
    },

    // Delivery
    isDelivered: {
      type: Boolean,
      default: false,
    },

    deliveredAt: Date,

    // Expiration
    expiresAt: Date,
  },
  {
    timestamps: true,
  },
)

// Indexes
notificationSchema.index({ recipient: 1, createdAt: -1 })
notificationSchema.index({ isRead: 1 })
notificationSchema.index({ type: 1 })
notificationSchema.index({ expiresAt: 1 }, { expireAfterSeconds: 0 })

module.exports = mongoose.model("Notification", notificationSchema)
