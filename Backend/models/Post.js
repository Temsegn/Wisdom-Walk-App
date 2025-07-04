const mongoose = require("mongoose");

const postSchema = new mongoose.Schema(
  {
    author: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    }, 

    // Post type and content
    type: {
      type: String,
      enum: ["prayer", "share"],
      required: true,
    },
    category:{
            type:String,
            enum:["testimony","confession","struggle"],
     },

    content: {
      type: String,
      required: true,
      maxlength: 2000,
    },

    title: {
      type: String,
      maxlength: 200,
    },

     images: [
      {
        url: String,
        caption: String,
      },
    ],
 

    // Privacy settings
    isAnonymous: {
      type: Boolean,
      default: false,
    },

    // Engagement
    likes: [
      {
        user: {
          type: mongoose.Schema.Types.ObjectId,
          ref: "User",
        },
        createdAt: {
          type: Date,
          default: Date.now,
        },
      },
    ],

    prayers: [
      {
        user: {
          type: mongoose.Schema.Types.ObjectId,
          ref: "User",
        },
        message: String,
        createdAt: {
          type: Date,
          default: Date.now,
        },
      },
    ],

    virtualHugs: [
      { 
        user: {
          type: mongoose.Schema.Types.ObjectId,
          ref: "User",
        },
        scripture: String,
        createdAt: {
          type: Date,
          default: Date.now,
        },
      },
    ],

    // Comments count (for performance)
    commentsCount: {
      type: Number,
      default: 0,
    },

    

     

 
    isReported: {
      type: Boolean,
      default: false,
    },

    reportCount: {
      type: Number,
      default: 0,
    },

    isHidden: {
      type: Boolean,
      default: false,
    },

    // Tags for better categorization
    tags: [String],

    // Scheduled posts
    scheduledFor: Date,
    isPublished: {
      type: Boolean,
      default: true,
    },
  },
  {
    timestamps: true,
  }
);

// Indexes for better performance
postSchema.index({ author: 1, createdAt: -1 });
postSchema.index({ isPublished: 1, isHidden: 1 });
postSchema.index({ createdAt: -1 });

// Virtual for getting engagement count
postSchema.virtual("engagementCount").get(function () {
  return (
    this.likes.length +
    this.prayers.length +
    this.virtualHugs.length +
    this.commentsCount
  );
});

module.exports = mongoose.model("Post", postSchema);
