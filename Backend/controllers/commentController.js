const Comment = require("../models/Comment")
const Post = require("../models/Post")
const Notification = require("../models/Notification")

// Create a comment
const createComment = async (req, res) => {
  try {
    const { postId } = req.params
    const { content, isAnonymous, parentCommentId } = req.body
    const userId = req.user._id

    // Check if post exists
    const post = await Post.findById(postId)
    if (!post) {
      return res.status(404).json({
        success: false,
        message: "Post not found",
      })
    }

    // Check if parent comment exists (for replies)
    let parentComment = null
    if (parentCommentId) {
      parentComment = await Comment.findById(parentCommentId)
      if (!parentComment) {
        return res.status(404).json({
          success: false,
          message: "Parent comment not found",
        })
      }
    }

    const comment = new Comment({
      post: postId,
      author: userId,
      content,
      isAnonymous: isAnonymous || false,
      parentComment: parentCommentId || null,
    })

    await comment.save()

    // Update parent comment replies if this is a reply
    if (parentComment) {
      parentComment.replies.push(comment._id)
      await parentComment.save()
    }

    // Update post comments count
    await Post.findByIdAndUpdate(postId, { $inc: { commentsCount: 1 } })

    // Populate author info
    await comment.populate("author", "firstName lastName profilePicture")

    // Create notification for post author (if not anonymous and not self-comment)
    if (!post.isAnonymous && post.author.toString() !== userId.toString()) {
      await new Notification({
        recipient: post.author,
        sender: userId,
        type: "comment",
        title: "New comment on your post",
        message: isAnonymous
          ? `Someone commented on your ${post.type}`
          : `${req.user.firstName} commented on your ${post.type}`,
        relatedPost: postId,
        relatedComment: comment._id,
      }).save()
    }

    // Create notification for parent comment author (if this is a reply)
    if (parentComment && parentComment.author.toString() !== userId.toString()) {
      await new Notification({
        recipient: parentComment.author,
        sender: userId,
        type: "comment",
        title: "Someone replied to your comment",
        message: isAnonymous ? "Someone replied to your comment" : `${req.user.firstName} replied to your comment`,
        relatedPost: postId,
        relatedComment: comment._id,
      }).save()
    }

    // Format response for anonymous comments
    const commentObj = comment.toObject()
    if (commentObj.isAnonymous) {
      commentObj.author = {
        firstName: "Anonymous",
        lastName: "Sister",
        profilePicture: null,
      }
    }

    res.status(201).json({
      success: true,
      message: "Comment created successfully",
      data: commentObj,
    })
  } catch (error) {
    console.error("Create comment error:", error)
    res.status(500).json({
      success: false,
      message: "Failed to create comment",
      error: error.message,
    })
  }
}

// Like/unlike a comment
const toggleCommentLike = async (req, res) => {
  try {
    const { commentId } = req.params
    const userId = req.user._id

    const comment = await Comment.findById(commentId)
    if (!comment) {
      return res.status(404).json({
        success: false,
        message: "Comment not found",
      })
    }

    const existingLike = comment.likes.find((like) => like.user.toString() === userId.toString())

    if (existingLike) {
      // Remove like
      comment.likes = comment.likes.filter((like) => like.user.toString() !== userId.toString())
    } else {
      // Add like
      comment.likes.push({ user: userId })
    }

    await comment.save()

    res.json({
      success: true,
      message: existingLike ? "Comment unliked" : "Comment liked",
      data: {
        likesCount: comment.likes.length,
        isLiked: !existingLike,
      },
    })
  } catch (error) {
    console.error("Toggle comment like error:", error)
    res.status(500).json({
      success: false,
      message: "Failed to toggle comment like",
      error: error.message,
    })
  }
}

// Update comment
const updateComment = async (req, res) => {
  try {
    const { commentId } = req.params
    const { content } = req.body
    const userId = req.user._id

    const comment = await Comment.findById(commentId)
    if (!comment) {
      return res.status(404).json({
        success: false,
        message: "Comment not found",
      })
    }

    // Check if user owns the comment
    if (comment.author.toString() !== userId.toString()) {
      return res.status(403).json({
        success: false,
        message: "You can only edit your own comments",
      })
    }

    comment.content = content
    await comment.save()

    res.json({
      success: true,
      message: "Comment updated successfully",
      data: comment,
    })
  } catch (error) {
    console.error("Update comment error:", error)
    res.status(500).json({
      success: false,
      message: "Failed to update comment",
      error: error.message,
    })
  }
}

// Delete comment
const deleteComment = async (req, res) => {
  try {
    const { commentId } = req.params
    const userId = req.user._id

    const comment = await Comment.findById(commentId)
    if (!comment) {
      return res.status(404).json({
        success: false,
        message: "Comment not found",
      })
    }

    // Check if user owns the comment or is admin
    if (comment.author.toString() !== userId.toString() && !req.user.isGlobalAdmin) {
      return res.status(403).json({
        success: false,
        message: "You can only delete your own comments",
      })
    }

    // Soft delete
    comment.isHidden = true
    await comment.save()

    // Update post comments count
    await Post.findByIdAndUpdate(comment.post, { $inc: { commentsCount: -1 } })

    res.json({
      success: true,
      message: "Comment deleted successfully",
    })
  } catch (error) {
    console.error("Delete comment error:", error)
    res.status(500).json({
      success: false,
      message: "Failed to delete comment",
      error: error.message,
    })
  }
}

module.exports = {
  createComment,
  toggleCommentLike,
  updateComment,
  deleteComment,
}
