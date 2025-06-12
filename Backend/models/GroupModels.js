const mongoose = require("mongoose")

// Single & Purposeful Group Chat Model
const singleSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: true,
      maxlength: 200,
    },
    
    description: {
      type: String,
      maxlength: 2000,
    },
    
    creator: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
    
    participants: [
      {
        user: {
          type: mongoose.Schema.Types.ObjectId,
          ref: "User",
        },
        joinedAt: {
          type: Date,
          default: Date.now,
        },
        isAdmin: {
          type: Boolean,
          default: false,
        },
        lastRead: {
          type: Date,
          default: Date.now,
        }
      }
    ],
    
    participantsCount: {
      type: Number,
      default: 1,
    },
    
    files: [
      {
        url: String,
        name: String,
        type: String,
        size: Number,
        uploadedBy: {
          type: mongoose.Schema.Types.ObjectId,
          ref: "User",
        },
        uploadedAt: {
          type: Date,
          default: Date.now,
        }
      }
    ],
    
    lastActivity: {
      type: Date,
      default: Date.now,
    },
    
    isPrivate: {
      type: Boolean,
      default: false,
    },
    
    // Specific fields for singles
    topicType: {
      type: String,
      enum: ["dating_advice", "career_focus", "spiritual_growth", "friendship", "purpose_discovery"],
      required: true,
    },

    ageRange: {
      type: String,
      enum: ["18-25", "26-35", "36-45", "45+"],
    },

    isSeekingAccountability: {
      type: Boolean,
      default: false,
    },
  },
  {
    timestamps: true,
  }
)

// Marriage & Ministry Group Chat Model
const marriageSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: true,
      maxlength: 200,
    },
    
    description: {
      type: String,
      maxlength: 2000,
    },
    
    creator: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
    
    participants: [
      {
        user: {
          type: mongoose.Schema.Types.ObjectId,
          ref: "User",
        },
        joinedAt: {
          type: Date,
          default: Date.now,
        },
        isAdmin: {
          type: Boolean,
          default: false,
        },
        lastRead: {
          type: Date,
          default: Date.now,
        }
      }
    ],
    
    participantsCount: {
      type: Number,
      default: 1,
    },
    
    files: [
      {
        url: String,
        name: String,
        type: String,
        size: Number,
        uploadedBy: {
          type: mongoose.Schema.Types.ObjectId,
          ref: "User",
        },
        uploadedAt: {
          type: Date,
          default: Date.now,
        }
      }
    ],
    
    lastActivity: {
      type: Date,
      default: Date.now,
    },
    
    isPrivate: {
      type: Boolean,
      default: false,
    },

    // Specific fields for marriage
    topicType: {
      type: String,
      enum: ["marriage_advice", "ministry_together", "conflict_resolution", "intimacy", "parenting_prep"],
      required: true,
    },

    marriageStage: {
      type: String,
      enum: ["newlywed", "established", "long_term", "ministry_focused"],
    },

    isSeekingCounseling: {
      type: Boolean,
      default: false,
    },
  },
  {
    timestamps: true,
  }
)

// Healing & Forgiveness Group Chat Model
const healingSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: true,
      maxlength: 200,
    },
    
    description: {
      type: String,
      maxlength: 2000,
    },
    
    creator: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
    
    participants: [
      {
        user: {
          type: mongoose.Schema.Types.ObjectId,
          ref: "User",
        },
        joinedAt: {
          type: Date,
          default: Date.now,
        },
        isAdmin: {
          type: Boolean,
          default: false,
        },
        lastRead: {
          type: Date,
          default: Date.now,
        }
      }
    ],
    
    participantsCount: {
      type: Number,
      default: 1,
    },
    
    files: [
      {
        url: String,
        name: String,
        type: String,
        size: Number,
        uploadedBy: {
          type: mongoose.Schema.Types.ObjectId,
          ref: "User",
        },
        uploadedAt: {
          type: Date,
          default: Date.now,
        }
      }
    ],
    
    lastActivity: {
      type: Date,
      default: Date.now,
    },
    
    isPrivate: {
      type: Boolean,
      default: false,
    },

    // Specific fields for healing
    healingType: {
      type: String,
      enum: ["trauma", "addiction", "grief", "abuse", "mental_health", "spiritual_wounds"],
      required: true,
    },

    isSensitive: {
      type: Boolean,
      default: true,
    },

    triggerWarnings: [String],

    supportLevel: {
      type: String,
      enum: ["peer_support", "professional_needed", "crisis"],
      default: "peer_support",
    },
  },
  {
    timestamps: true,
  }
)

// Motherhood in Christ Group Chat Model
const motherhoodSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: true,
      maxlength: 200,
    },
    
    description: {
      type: String,
      maxlength: 2000,
    },
    
    creator: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
    
    participants: [
      {
        user: {
          type: mongoose.Schema.Types.ObjectId,
          ref: "User",
        },
        joinedAt: {
          type: Date,
          default: Date.now,
        },
        isAdmin: {
          type: Boolean,
          default: false,
        },
        lastRead: {
          type: Date,
          default: Date.now,
        }
      }
    ],
    
    participantsCount: {
      type: Number,
      default: 1,
    },
    
    files: [
      {
        url: String,
        name: String,
        type: String,
        size: Number,
        uploadedBy: {
          type: mongoose.Schema.Types.ObjectId,
          ref: "User",
        },
        uploadedAt: {
          type: Date,
          default: Date.now,
        }
      }
    ],
    
    lastActivity: {
      type: Date,
      default: Date.now,
    },
    
    isPrivate: {
      type: Boolean,
      default: false,
    },

    // Specific fields for motherhood
    motherhoodStage: {
      type: String,
      enum: ["expecting", "newborn", "toddler", "school_age", "teen", "adult_children"],
      required: true,
    },

    topicType: {
      type: String,
      enum: ["pregnancy", "parenting_tips", "spiritual_training", "work_life_balance", "special_needs"],
    },

    childrenAges: [String],

    isSeekingMentorship: {
      type: Boolean,
      default: false,
    },

    canMentor: {
      type: Boolean,
      default: false,
    },
  },
  {
    timestamps: true,
  }
)

// Indexes for all group models
;[singleSchema, marriageSchema, healingSchema, motherhoodSchema].forEach((schema) => {
  schema.index({ creator: 1, createdAt: -1 })
  schema.index({ "participants.user": 1 })
  schema.index({ lastActivity: -1 })
  schema.index({ topicType: 1 })
})

module.exports = {
  SingleChat: mongoose.model("SingleChat", singleSchema),
  MarriageChat: mongoose.model("MarriageChat", marriageSchema),
  HealingChat: mongoose.model("HealingChat", healingSchema),
  MotherhoodChat: mongoose.model("MotherhoodChat", motherhoodSchema),
}