const Post = require("../models/Post")
const Comment = require("../models/Comment")
const User = require("../models/User")
const Notification = require("../models/Notification")
const { saveMultipleFiles } = require("../utils/localStorageService")
const { getRandomScripture, getPaginationMeta } = require("../utils/helpers")
const {sendReportEmailToAdmin,sendNewPostEmailToAdmin,sendLikeNotificationEmail,sendCommentNotificationEmail} = require("../utils/emailService")
// Create a new post
const createPost = async (req, res) => {
  try {
    const { type, content, title, isAnonymous, visibility, tags,category } = req.body
    const authorId = req.user._id 

    // Validate group membership for group posts 
  

    // if (targetGroup && targetGroup !== "general") {
    //   const userInGroup = req.user.joinedGroups.some((group) => group.groupType === targetGroup)
    //   if (!userInGroup) {
    //     return res.status(403).json({
    //       success: false,
    //       message: `You must be  member of the ${targetGroup} group to post there`,
    //     })
    //   }
    // }

    const postData = {
      author: authorId,
      type,
      content,
      title,
      category: category , // Default to "testimony" if not provided
      isAnonymous: isAnonymous || false,
      visibility: visibility || "public",
       tags: tags || [],
    }

    // Handle location data for location posts
    

    // Handle image uploads
    if (req.files && req.files.length > 0) {
      const uploadResults = await saveMultipleFiles(req.files, "posts")
      postData.images = uploadResults.map((result, index) => ({
        url: result.url,
        caption: req.body.captions ? req.body.captions[index] : "",
      }))
    }

    const post = new Post(postData)
    await post.save()
    
    // Populate author info for response
    if(isAnonymous) {
    await post.populate("author", "firstName lastName profilePicture")
    } 
    // Create notifications for group members (if group post)
    // if (targetGroup && targetGroup !== "general") {
    //   const groupMembers = await User.find({
    //     "joinedGroups.groupType": targetGroup,
    //     _id: { $ne: authorId },
    //     isEmailVerified: true,
    //     isAdminVerified: true,
    //     status: "active",
    //   })

    //   const notifications = groupMembers.map((member) => ({
    //     recipient: member._id,
    //     sender: authorId,
    //     type: type === "prayer" ? "prayer_request" : "post",
    //     title: `New ${type} in ${targetGroup} group`,
    //     message: isAnonymous
    //       ? `Someone shared a ${type} in the ${targetGroup} group`
    //       : `${req.user.firstName} shared a ${type} in the ${targetGroup} group`,
    //     relatedPost: post._id,
    //   }))
    
    //   await Notification.insertMany(notifications)
    // }
    sendNewPostEmailToAdmin(
      process.env.ADMIN_EMAIL,
      post
    )
    // Create notification for post author
    if (!isAnonymous && post.author.toString() !== authorId.toString()) {
      await new Notification({
        recipient: authorId,
        sender: post.author,
        type: "post",
        title: "Your post was created successfully",
        message: `Your ${type} has been created successfully`,
        relatedPost: post._id,
      }).save()
    }
    res.status(201).json({
      success: true,
      message: "Post created successfully",
      data: post,
    })
  } catch (error) {
    console.error("Create post error:", error)
    res.status(500).json({
      success: false,
      message: "Failed to create post",
      error: error.message,
    }) 
  }
}

// Get posts feed
const getPostsFeed = async (req, res) => {
  try {
    const { type, group, page = 1, limit = 10 } = req.query
    const skip = (page - 1) * limit
    const userId = req.user._id

    const filter = {
      isHidden: false,
      isPublished: true,
    }

    // Filter by post type
    if (type) {
      filter.type = type
    }

    // Filter by group
    if (group) {
      filter.targetGroup = group
      // Check if user is member of the group
      const userInGroup = req.user.joinedGroups.some((userGroup) => userGroup.groupType === group)
      if (!userInGroup && group !== "general") {
        return res.status(403).json({
          success: false,
          message: `You must be a member of the ${group} group to view its posts`,
        })
      }
    } else {
      // Show posts from user's groups + general posts
      const userGroups = req.user.joinedGroups.map((group) => group.groupType)
      filter.$or = [{ targetGroup: "general" }, { targetGroup: { $in: userGroups } }]
    }

    const posts = await Post.find(filter)
      .populate("author", "firstName lastName profilePicture")
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(Number.parseInt(limit))

    const total = await Post.countDocuments(filter)

    // Format posts (hide author info for anonymous posts)
    const formattedPosts = posts.map((post) => {
      const postObj = post.toObject()
      if (postObj.isAnonymous) {
        postObj.author = {
          firstName: "Anonymous",
          lastName: "Sister",
          profilePicture: null,
        }
      }
      return postObj
    })

    res.json({
      success: true,
      data: formattedPosts,
      pagination: getPaginationMeta(Number.parseInt(page), Number.parseInt(limit), total),
    })
  } catch (error) {
    console.error("Get posts feed error:", error)
    res.status(500).json({
      success: false,
      message: "Failed to fetch posts",
      error: error.message,
    })
  }
}

// Get single post
const getPost = async (req, res) => {
  try {
    const { postId } = req.params

    const post = await Post.findById(postId).populate("author", "firstName lastName profilePicture").populate({
      path: "prayers.user",
      select: "firstName lastName profilePicture",
    })

    if (!post) {
      return res.status(404).json({
        success: false,
        message: "Post not found",
      })
    }

    if (post.isHidden) {
      return res.status(404).json({
        success: false,
        message: "Post not found",
      })
    }

    // Check group access
     

    // Format anonymous post
    const postObj = post.toObject()
    if (postObj.isAnonymous) {
      postObj.author = {
        firstName: "Anonymous",
        lastName: "Sister",
        profilePicture: null,
      }
    }

    res.json({
      success: true,
      data: postObj,
    })
  } catch (error) {
    console.error("Get post error:", error)
    res.status(500).json({
      success: false,
      message: "Failed to fetch post",
      error: error.message,
    })
  }
}
 
     
// Like/unlike a post
const toggleLike = async (req, res) => {
  try {
    const { postId } = req.params
    const userId = req.user._id

    const post = await Post.findById(postId)
    if (!post) {
      return res.status(404).json({
        success: false,
        message: "Post not found",
      })
    }

    const existingLike = post.likes.find((like) => like.user.toString() === userId.toString())

    if (existingLike) {
      // Remove like
      post.likes = post.likes.filter((like) => like.user.toString() !== userId.toString())
    } else {
      // Add like
      post.likes.push({ user: userId })

      // Create notification for post author (if not anonymous and not self-like)
      if (!post.isAnonymous && post.author.toString() !== userId.toString()) {
        await new Notification({
          recipient: post.author,
          sender: userId,
          type: "like",
          title: "Someone liked your post",
          message: `${req.user.firstName} liked your ${post.type}`,
          relatedPost: postId,
        }).save()
      }
    }

    await post.save()

    res.json({
      success: true,
      message: existingLike ? "Post unliked" : "Post liked",
      data: {
        likesCount: post.likes.length,
        isLiked: !existingLike,
      },
    })
  } catch (error) {
    console.error("Toggle like error:", error)
    res.status(500).json({
      success: false,
      message: "Failed to toggle like",
      error: error.message,
    })
  }
}

// Add prayer for a post
const addPrayer = async (req, res) => {
  try {
    const { postId } = req.params
    const { message } = req.body
    const userId = req.user._id

    const post = await Post.findById(postId)
    if (!post) {
      return res.status(404).json({
        success: false,
        message: "Post not found",
      })
    }

    // Add prayer
    post.prayers.push({
      user: userId,
      message: message || "Praying for you ❤️",
    })

    await post.save()

    // Create notification for post author (if not anonymous and not self-prayer)
    if (!post.isAnonymous && post.author.toString() !== userId.toString()) {
      await new Notification({
        recipient: post.author,
        sender: userId,
        type: "prayer_response",
        title: "Someone is praying for you",
        message: `${req.user.firstName} is praying for your ${post.type}`,
        relatedPost: postId,
      }).save()
    }

    res.json({
      success: true,
      message: "Prayer added successfully",
      data: {
        prayersCount: post.prayers.length,
      },
    })
  } catch (error) {
    console.error("Add prayer error:", error)
    res.status(500).json({
      success: false,
      message: "Failed to add prayer",
      error: error.message,
    })
  }
}

// Send virtual hug
const sendVirtualHug = async (req, res) => {
  try {
    const { postId } = req.params
    const userId = req.user._id

    const post = await Post.findById(postId)
    if (!post) {
      return res.status(404).json({
        success: false,
        message: "Post not found",
      })
    }

    // Check if user already sent a hug
    const existingHug = post.virtualHugs.find((hug) => hug.user.toString() === userId.toString())
    if (existingHug) {
      return res.status(400).json({
        success: false,
        message: "You have already sent a virtual hug to this post",
      })
    }

    // Get random scripture
    const scripture = getRandomScripture()

    // Add virtual hug
    post.virtualHugs.push({
      user: userId,
      scripture: `${scripture.verse} - ${scripture.reference}`,
    })

    await post.save()

    // Create notification for post author (if not anonymous and not self-hug)
    if (!post.isAnonymous && post.author.toString() !== userId.toString()) {
      await new Notification({
        recipient: post.author,
        sender: userId,
        type: "virtual_hug",
        title: "Someone sent you a virtual hug",
        message: `${req.user.firstName} sent you a virtual hug with scripture: ${scripture.reference}`,
        relatedPost: postId,
        data: { scripture },
      }).save()
    }

    res.json({
      success: true,
      message: "Virtual hug sent successfully",
      data: {
        scripture,
        virtualHugsCount: post.virtualHugs.length,
      },
    })
  } catch (error) {
    console.error("Send virtual hug error:", error)
    res.status(500).json({
      success: false,
      message: "Failed to send virtual hug",
      error: error.message,
    })
  }
}

// Update post
const updatePost = async (req, res) => {
  try {
    const { postId } = req.params
    const { content, title, tags } = req.body
    const userId = req.user._id

    const post = await Post.findById(postId)
    if (!post) {
      return res.status(404).json({
        success: false,
        message: "Post not found",
      })
    }

    // Check if user owns the post
    if (post.author.toString() !== userId.toString()) {
      return res.status(403).json({
        success: false,
        message: "You can only edit your own posts",
      })
    }

    // Update fields
    if (content) post.content = content
    if (title) post.title = title
    if (tags) post.tags = tags

    await post.save()

    res.json({
      success: true,
      message: "Post updated successfully",
      data: post,
    })
  } catch (error) {
    console.error("Update post error:", error)
    res.status(500).json({
      success: false,
      message: "Failed to update post",
      error: error.message,
    })
  }
}
// Delete (soft-delete) post
// const deletePost = async (req, res) => {
//   try {
//     const { postId } = req.params
//     const userId = req.user._id

//     const post = await Post.findById(postId)
//     if (!post) {
//       return res.status(404).json({
//         success: false,
//         message: "Post not found",
//       })
//     }

//     // Check if user owns the post or is a global admin
//     if (post.author.toString() !== userId.toString() && !req.user.isGlobalAdmin) {
//       return res.status(403).json({
//         success: false,
//         message: "You can only delete your own posts",
//       })
//     }

//     // Soft delete - mark the post as hidden
//     post.isHidden = true
//     await post.save()

//     // Also soft-delete related comments
//     await Comment.updateMany({ post: postId }, { isHidden: true })

//     res.json({
//       success: true,
//       message: "Post deleted successfully (soft-deleted)",
//     })
//   } catch (error) {
//     console.error("Delete post error:", error)
//     res.status(500).json({
//       success: false,
//       message: "Failed to delete post",
//       error: error.message,
//     })
//   }
// }

// Hard delete post
const deletePost = async (req, res) => {
  try {
    const { postId } = req.params
    const userId = req.user._id

    // Find post first to check permissions
    const post = await Post.findById(postId)
    if (!post) {
      return res.status(404).json({
        success: false,
        message: "Post not found",
      })
    }

    // Check if user is author or global admin
    if (post.author.toString() !== userId.toString() && !req.user.isGlobalAdmin) {
      return res.status(403).json({
        success: false,
        message: "You can only delete your own posts",
      })
    }

    // Delete the post permanently
    await Post.findByIdAndDelete(postId)

    // Also delete all related comments permanently
    await Comment.deleteMany({ post: postId })

    res.json({
      success: true,
      message: "Post and related comments deleted successfully",
    })
  } catch (error) {
    console.error("Delete post error:", error)
    res.status(500).json({
      success: false,
      message: "Failed to delete post",
      error: error.message,
    })
  }
}


// Get post comments
const getPostComments = async (req, res) => {
  try {
    const { postId } = req.params
    const { page = 1, limit = 20 } = req.query
    const skip = (page - 1) * limit

    const comments = await Comment.find({
      post: postId,
      isHidden: false,
      parentComment: null, // Only top-level comments
    })
      .populate("author", "firstName lastName profilePicture")
      .populate({
        path: "replies",
        populate: {
          path: "author",
          select: "firstName lastName profilePicture",
        },
      })
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(Number.parseInt(limit))

    const total = await Comment.countDocuments({
      post: postId,
      isHidden: false,
      parentComment: null,
    })

    // Format anonymous comments
    const formattedComments = comments.map((comment) => {
      const commentObj = comment.toObject()
      if (commentObj.isAnonymous) {
        commentObj.author = {
          firstName: "Anonymous",
          lastName: "Sister",
          profilePicture: null,
        }
      }
      return commentObj
    })

    res.json({
      success: true,
      data: formattedComments,
      pagination: getPaginationMeta(Number.parseInt(page), Number.parseInt(limit), total),
    })
  } catch (error) {
    console.error("Get post comments error:", error)
    res.status(500).json({
      success: false,
      message: "Failed to fetch comments",
      error: error.message,
    })
  }
}

const getAllPosts = async (req, res) => {
  try {
    const { type, category } = req.query;
    const query = {
      isHidden: false,
      isPublished: true,
    };

    // Improved type handling
    if (type && typeof type === 'string') {
      const cleanType = type.replace(/"/g, '').trim();
      if (cleanType) query.type = cleanType;
    }
    
    // Improved category handling
    if (category && typeof category === 'string' && category.toLowerCase() !== 'all') {
      query.category = category.replace(/"/g, '').trim();
    }

    const posts = await Post.find(query)
      .populate("author", "firstName lastName profilePicture")
      .sort({ createdAt: -1 });

    const formattedPosts = posts.map((post) => {
      const postObj = post.toObject();
      if (postObj.isAnonymous) {
        postObj.author = {
          firstName: "Anonymous",
          lastName: "Sister",
          profilePicture: null,
        };
      }
      return postObj;
    });

    res.json({
      success: true,
      data: formattedPosts,
    });
  } catch (error) {
    console.error("Get all posts error:", error);
    res.status(500).json({
      success: false,
      message: "Failed to fetch all posts",
      error: error.message,
    });
  }
};


module.exports = {
  getAllPosts,
  createPost,
  getPostsFeed,
  getPost,
  toggleLike,
  addPrayer,
  sendVirtualHug,
  updatePost,
  deletePost,
  getPostComments,
}
