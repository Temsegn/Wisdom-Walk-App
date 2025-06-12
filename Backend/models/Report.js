const mongoose = require("mongoose")

const reportSchema = new mongoose.Schema(
  {
    reporter: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },

    reportedUser: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
    },

    reportedPost: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Post",
    },

    reportedComment: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Comment",
    },

    reportedMessage: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Message",
    },

    type: {
      type: String,
      enum: [
        "inappropriate_content",
        "harassment",
        "spam",
        "fake_profile",
        "violence",
        "hate_speech",
        "sexual_content",
        "misinformation",
        "other",
      ],
      required: true,
    },

    reason: {
      type: String,
      required: true,
      maxlength: 1000,
    },

    evidence: [
      {
        type: String, // URLs to screenshots or other evidence
        description: String,
      },
    ],

    status: {
      type: String,
      enum: ["pending", "investigating", "resolved", "dismissed"],
      default: "pending",
    },

    // Admin handling
    assignedTo: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
    },

    adminNotes: String,

    actionTaken: {
      type: String,
      enum: ["no_action", "warning_sent", "content_removed", "user_blocked", "user_banned", "account_suspended"],
    },

    resolvedAt: Date,
    resolvedBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
    },
  },
  {
    timestamps: true,
  },
)

// Indexes
reportSchema.index({ status: 1, createdAt: -1 })
reportSchema.index({ reporter: 1 })
reportSchema.index({ reportedUser: 1 })
reportSchema.index({ assignedTo: 1 })

module.exports = mongoose.model("Report", reportSchema)
