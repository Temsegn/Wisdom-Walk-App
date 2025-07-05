const Report = require("../models/Report")
const Post = require("../models/Post")
const Comment = require("../models/Comment")
const User = require("../models/User")
const Message = require("../models/Message")
const Notification = require("../models/Notification")
const { getPaginationMeta } = require("../utils/helpers")
const {sendReportEmailToAdmin} = require("../utils/emailService")
const { post } = require("../routes/movementRoute")
// Create a report
const createReport = async (req, res) => { 
  try {
    const { type, reason, evidence, reportedUserId, reportedPostId, reportedCommentId, reportedMessageId } = req.body
    const reporterId = req.user._id

    // Validate that at least one item is being reported
    if (!reportedUserId && !reportedPostId && !reportedCommentId && !reportedMessageId) {
      return res.status(400).json({
        success: false,
        message: "You must specify what you are reporting",
      })
    }

    // Validate reported content exists
    if (reportedPostId) {
      const post = await Post.findById(reportedPostId)
      if (!post || post.isHidden) {
        return res.status(404).json({
          success: false,
          message: "Post not found",
        })
      }
    }

    if (reportedCommentId) {
      const comment = await Comment.findById(reportedCommentId)
      if (!comment || comment.isHidden) {
        return res.status(404).json({
          success: false,
          message: "Comment not found",
        })
      }
    }

    if (reportedUserId) {
      const user = await User.findById(reportedUserId)
      if (!user) {
        return res.status(404).json({
          success: false,
          message: "User not found",
        })
      }
    }

    if (reportedMessageId) {
      const message = await Message.findById(reportedMessageId)
      if (!message || message.isDeleted) {
        return res.status(404).json({
          success: false,
          message: "Message not found",
        })
      }
    }

    // Check if user has already reported this specific content
    const existingReport = await Report.findOne({
      reporter: reporterId,
      $or: [
        { reportedUser: reportedUserId },
        { reportedPost: reportedPostId },
        { reportedComment: reportedCommentId },
        { reportedMessage: reportedMessageId },
      ],
      status: { $in: ["pending", "investigating"] },
    })

    if (existingReport) {
      return res.status(400).json({
        success: false,
        message: "You have already reported this content and it's being reviewed",
      })
    }

    const report = new Report({
      reporter: reporterId,
      reportedUser: reportedUserId,
      reportedPost: reportedPostId,
      reportedComment: reportedCommentId,
      reportedMessage: reportedMessageId,
      type,
      reason,
      evidence: evidence || [],
    })

    await report.save()

    // Update reported content flags
    if (reportedPostId) {
      await Post.findByIdAndUpdate(reportedPostId, {
        isReported: true,
        $inc: { reportCount: 1 },
      })
    }

    if (reportedCommentId) {
      await Comment.findByIdAndUpdate(reportedCommentId, {
        isReported: true,
      })
    }

    // Notify admins about new report
    const admins = await User.find({
      $or: [{ isGlobalAdmin: true }, { adminPermissions: "manage_posts" }],
    }).select("_id")

    const adminNotifications = admins.map((admin) => ({
      recipient: admin._id,
      sender: reporterId,
      type: "admin_message",
      title: "New Report Submitted",
      message: `A new ${type} report has been submitted and requires review`,
      priority: "high",
      data: {
        reportId: report._id,
        reportType: type,
        contentType: reportedPostId ? "post" : reportedCommentId ? "comment" : reportedUserId ? "user" : "message",
      },
    }))

    await Notification.insertMany(adminNotifications)
    // Send email notification to admins
    await sendReportEmailToAdmin(process.env.ADMIN_EMAIL, {
      postId: reportedPostId,
      commentId: reportedCommentId,
    }, reporterId)

    // Populate the report for response
    await report.populate([
      { path: "reportedPost", select: "title content type author" },
      { path: "reportedComment", select: "content author" },
      { path: "reportedUser", select: "firstName lastName email" },
      { path: "reportedMessage", select: "content sender" },
    ])

    res.status(201).json({
      success: true,
      message: "Report submitted successfully. Our team will review it shortly.",
      data: {
        reportId: report._id,
        status: report.status,
        submittedAt: report.createdAt,
      },
    })
  } catch (error) {
    console.error("Create report error:", error)
    res.status(500).json({
      success: false,
      message: "Failed to submit report",
      error: error.message,
    })
  }
}

// Get user's reports
const getUserReports = async (req, res) => {
  try {
    const userId = req.user._id
    const { page = 1, limit = 10, status } = req.query
    const skip = (page - 1) * limit

    const filter = { reporter: userId }
    if (status) {
      filter.status = status
    }

    const reports = await Report.find(filter)
      .populate("reportedUser", "firstName lastName")
      .populate("reportedPost", "title content type")
      .populate("reportedComment", "content")
      .populate("reportedMessage", "content")
      .populate("assignedTo", "firstName lastName")
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(Number.parseInt(limit))

    const total = await Report.countDocuments(filter)

    // Format reports for user view
    const formattedReports = reports.map((report) => {
      const reportObj = report.toObject()

      // Add content preview
      if (reportObj.reportedPost) {
        reportObj.contentPreview =
          reportObj.reportedPost.title || reportObj.reportedPost.content.substring(0, 100) + "..."
        reportObj.contentType = "post"
      } else if (reportObj.reportedComment) {
        reportObj.contentPreview = reportObj.reportedComment.content.substring(0, 100) + "..."
        reportObj.contentType = "comment"
      } else if (reportObj.reportedUser) {
        reportObj.contentPreview = `${reportObj.reportedUser.firstName} ${reportObj.reportedUser.lastName}`
        reportObj.contentType = "user"
      } else if (reportObj.reportedMessage) {
        reportObj.contentPreview = reportObj.reportedMessage.content.substring(0, 100) + "..."
        reportObj.contentType = "message"
      }

      return reportObj
    })

    res.json({
      success: true,
      data: formattedReports,
      pagination: getPaginationMeta(Number.parseInt(page), Number.parseInt(limit), total),
    })
  } catch (error) {
    console.error("Get user reports error:", error)
    res.status(500).json({
      success: false,
      message: "Failed to fetch reports",
      error: error.message,
    })
  }
}

// Report a single post (simplified endpoint)
const reportPost = async (req, res) => {
  try {
    const { postId } = req.params
    const { type, reason } = req.body
    const reporterId = req.user._id

    // Check if post exists
    const post = await Post.findById(postId)
    if (!post || post.isHidden) {
      return res.status(404).json({
        success: false,
        message: "Post not found",
      })
    }

    // Check if user already reported this post
    const existingReport = await Report.findOne({
      reporter: reporterId,
      reportedPost: postId,
      status: { $in: ["pending", "investigating"] },
    })

    if (existingReport) {
      return res.status(400).json({
        success: false,
        message: "You have already reported this post",
      })
    }

    // Create report
    const report = new Report({
      reporter: reporterId,
      reportedPost: postId,
      type,
      reason,
    })

    await report.save()

    // Update post report status
    await Post.findByIdAndUpdate(postId, {
      isReported: true,
      $inc: { reportCount: 1 },
    })
    

    // Notify admins
    const admins = await User.find({
      $or: [{ isGlobalAdmin: true }, { adminPermissions: "manage_posts" }],
    }).select("_id")

    const adminNotifications = admins.map((admin) => ({
      recipient: admin._id,
      sender: reporterId,
      type: "admin_message",
      title: "Post Reported",
      message: `A post has been reported for ${type}`,
      priority: "high",
      relatedPost: postId,
      data: {
        reportId: report._id,
        reportType: type,
      },
    }))

    await Notification.insertMany(adminNotifications)

    res.status(201).json({
      success: true,
      message: "Post reported successfully. Thank you for helping keep our community safe.",
      data: {
        reportId: report._id,
      },
    })
  } catch (error) {
    console.error("Report post error:", error)
    res.status(500).json({
      success: false,
      message: "Failed to report post",
      error: error.message,
    })
  }
}
const reportUser = async (req, res) => {
  try {
    const { type, reason } = req.body
    const reportedUserId = req.params.userId
    const reporterId = req.user._id

    if (!reason || reason.trim().length < 10) {
      return res.status(400).json({
        success: false,
        message: "Please provide a valid reason for reporting the user",
      })
    }

    const user = await User.findById(reportedUserId)
    if (!user) {
      return res.status(404).json({
        success: false,
        message: "User not found",
      })
    }

    // Check for duplicate report
    const existingReport = await Report.findOne({
      reporter: reporterId,
      reportedUser: reportedUserId,
      status: { $in: ["pending", "investigating"] },
    })

    if (existingReport) {
      return res.status(400).json({
        success: false,
        message: "You have already reported this user",
      })
    }

    const report = new Report({
      reporter: reporterId,
      reportedUser: reportedUserId,
      type,
      reason,
    })

    await report.save()

    // Notify admins
    const admins = await User.find({
      $or: [{ isGlobalAdmin: true }, { adminPermissions: "manage_users" }],
    }).select("_id")

    const adminNotifications = admins.map((admin) => ({
      recipient: admin._id,
      sender: reporterId,
      type: "admin_message",
      title: "User Reported",
      message: `A user has been reported for ${type}`,
      priority: "high",
      data: {
        reportId: report._id,
        reportType: type,
        contentType: "user",
      },
    }))

    await Notification.insertMany(adminNotifications)

    res.status(201).json({
      success: true,
      message: "User reported successfully.",
      data: {
        reportId: report._id,
      },
    })
  } catch (error) {
    console.error("Report user error:", error)
    res.status(500).json({
      success: false,
      message: "Failed to report user",
      error: error.message,
    })
  }
}

module.exports = {
  createReport,
  getUserReports,
  reportPost,
  reportUser
}
