const mongoose = require("mongoose")
const bcrypt = require("bcryptjs")

const userSchema = new mongoose.Schema(
  {
    email: {
      type: String,
      required: true,
      unique: true,
      lowercase: true,
      trim: true,
    },
    password: {
      type: String,
      required: true,
      minlength: 6,
    },
    firstName: {
      type: String,
       trim: true,
    },
    lastName: {
      type: String,
       trim: true,
    },
    profilePicture: {
      type: String,
      default: null,
    },
    bio: {
      type: String,
      maxlength: 500,
    },
    location: {
      city: String,
      country: String,
    },
    dateOfBirth: {
      type: Date,
      required: true,
    },
    phoneNumber: {
      type: String,
      required: true,
    },

    // Verification fields
    isEmailVerified: {
      type: Boolean,
      default: false,
    },
    isAdminVerified: {
      type: Boolean,
      default: false,
    },
    emailVerificationToken: String,
    emailVerificationExpires: Date,

    // Admin verification documents
    livePhoto: {
  url: { type: String, required: true },
  publicId: { type: String, required: true }
},
  nationalId: {
  url: { type: String, required: true },
  publicId: { type: String, required: true }
   },
    verificationCode: {
      type: String, // Cloudinary URL
      required: false,
      default: null,
    },
    
    verificationStatus: {
      type: String,
      enum: ["pending", "approved", "rejected"],
      default: "pending",
    },
    verificationNotes: String,
    verifiedBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
    },
    verifiedAt: Date,

    // User status
    status: {
      type: String,
      enum: ["active", "blocked", "banned"],
      default: "active",
    },
    blockedUntil: Date,
    banReason: String,

    // Groups membership
    joinedGroups: [
      {
        groupType: {
          type: String,
          enum: ["single", "marriage", "healing", "motherhood"],
        },
        joinedAt: {
          type: Date,
          default: Date.now,
        },
        isAdmin: {
          type: Boolean,
          default: false,
        },
      },
    ],

    // Preferences
    preferences: {
      prayerVisibility: {
        type: String,
        enum: ["public", "friends", "anonymous"],
        default: "public",
      },
      allowDirectMessages: {
        type: Boolean,
        default: true,
      },
      emailNotifications: {
        type: Boolean,
        default: true,
      },
      pushNotifications: {
        type: Boolean,
        default: true,
      },
    },

    // Admin fields
    isGlobalAdmin: {
      type: Boolean,
      default: false,
    },
    adminPermissions: [
      {
        type: String,
        enum: ["verify_users", "manage_posts", "manage_groups", "send_notifications", "ban_users"],
      },
    ],

    lastActive: {
      type: Date,
      default: Date.now,
    },
   isOnline: {
      type: Boolean,
      default: false,
    },
    blockedUsers: [
      {
        type: mongoose.Schema.Types.ObjectId,
        ref: "User",
      },
    ],
    // Password reset
    passwordResetToken: String,
    passwordResetExpires: Date,
  },
  {
    timestamps: true, // Automatically manage createdAt and updatedAt fields
    toJSON: {
      virtuals: true,
      transform: function(doc, ret) {
        delete ret.password;
        delete ret.__v;
        return ret;
      }
    }
  }
)

userSchema.virtual('fullName').get(function() {
  return `${this.firstName} ${this.lastName}`.trim();
});

// Add method to update names consistently
userSchema.methods.updateNames = function(firstName, lastName) {
  this.firstName = firstName.trim();
  this.lastName = lastName.trim();
  return this.save();
};
// Index for better performance
userSchema.index({ email: 1 })
userSchema.index({ verificationStatus: 1 })
userSchema.index({ status: 1 })

// Hash password before saving
userSchema.pre("save", async function (next) {
  if (!this.isModified("password")) return next()

  try {
    const salt = await bcrypt.genSalt(12)
    this.password = await bcrypt.hash(this.password, salt)
    next()
  } catch (error) {
    next(error)
  }
})

// Compare password method
userSchema.methods.comparePassword = async function (candidatePassword) {
  return await bcrypt.compare(candidatePassword, this.password)
}

// Check if user can access the app
userSchema.methods.canAccess = function () {
  return (
    this.isEmailVerified &&
    
    this.status === "active" &&
    (!this.blockedUntil || this.blockedUntil < new Date())
  )
}

// Get user's group admin status
userSchema.methods.isGroupAdmin = function (groupType) {
  const group = this.joinedGroups.find((g) => g.groupType === groupType)
  return group ? group.isAdmin : false
}

module.exports = mongoose.model("User", userSchema)
