const mongoose = require("mongoose");

const groupSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: true,
      trim: true,
      maxlength: 100,
    },
    description: {
      type: String,
      trim: true,
      maxlength: 500,
    },
    avatar: {
      type: String,
      default: "",
    },
    coverPhoto: {
      type: String,
      default: "",
    },
    creator: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
    admins: [
      {
        type: mongoose.Schema.Types.ObjectId,
        ref: "User",
      },
    ],
    members: [
      {
        user: {
          type: mongoose.Schema.Types.ObjectId,
          ref: "User",
          required: true,
        },
        joinedAt: {
          type: Date,
          default: Date.now,
        },
        role: {
          type: String,
          enum: ["member", "admin"],
          default: "member",
        },
        lastSeen: Date,
        isMuted: {
          type: Boolean,
          default: false,
        },
      },
    ],
    type: {
      type: String,
      enum: ["public", "private", "restricted"],
      default: "public",
    },
    inviteLink: {
      type: String,
      unique: true,
    },
    inviteLinkExpires: Date,
    pinnedMessages: [
      {
        message: {
          type: mongoose.Schema.Types.ObjectId,
          ref: "Message",
        },
        pinnedBy: {
          type: mongoose.Schema.Types.ObjectId,
          ref: "User",
        },
        pinnedAt: {
          type: Date,
          default: Date.now,
        },
      },
    ],
    chat: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Chat",
    },
    settings: {
      sendMessages: {
        type: Boolean,
        default: true,
      },
      sendMedia: {
        type: Boolean,
        default: true,
      },
      sendPolls: {
        type: Boolean,
        default: true,
      },
      sendStickers: {
        type: Boolean,
        default: true,
      },
      changeInfo: {
        type: Boolean,
        default: false,
      },
      inviteUsers: {
        type: Boolean,
        default: true,
      },
      pinMessages: {
        type: Boolean,
        default: false,
      },
    },
    isActive: {
      type: Boolean,
      default: true,
    },
    deletedAt: Date,
  },
  {
    timestamps: true,
    toJSON: { virtuals: true },
    toObject: { virtuals: true },
  }
);

// Indexes
groupSchema.index({ name: "text", description: "text" });
groupSchema.index({ creator: 1 });
groupSchema.index({ "members.user": 1 });
groupSchema.index({ inviteLink: 1 }, { unique: true });

// Virtual for member count
groupSchema.virtual("memberCount").get(function () {
  return this.members.length;
});

// Pre-save hook to generate invite link
groupSchema.pre("save", function (next) {
  if (!this.inviteLink) {
    const randomString = Math.random().toString(36).substring(2, 15);
    this.inviteLink = `invite-${randomString}`;
    this.inviteLinkExpires = new Date(Date.now() + 30 * 24 * 60 * 60 * 1000); // 30 days
  }
  next();
});

// Method to check if user is admin
groupSchema.methods.isAdmin = function (userId) {
  return this.admins.some(
    (adminId) => adminId.toString() === userId.toString()
  );
};

// Method to check if user is member
groupSchema.methods.isMember = function (userId) {
  return this.members.some(
    (member) => member.user.toString() === userId.toString()
  );
};

module.exports = mongoose.model("Group", groupSchema);