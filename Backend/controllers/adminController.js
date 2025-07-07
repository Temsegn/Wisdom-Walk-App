const User = require("../models/User")
const Post = require("../models/Post")
const Comment = require("../models/Comment")
const Report = require("../models/Report")
const Booking = require("../models/booking")
const Notification = require("../models/Notification")
const Event =require("../models/Event")
const { sendUserNotificationEmail, sendAdminNotificationEmail,sendBannedEmailToUser,sendBlockedEmailToUser,sendUnblockedEmailToUser } = require("../utils/emailService")
const { getPaginationMeta } = require("../utils/helpers")
// Get all unread admin_message notifications
const getAllNotifications = async (req, res) => {
  try {
    const filter = {
      
      type: "admin_message",
    };

    const notifications = await Notification.find(filter)
      .populate("sender", "firstName lastName profilePicture role")
      .populate("recipient", "firstName lastName profilePicture role")
      .sort({ createdAt: -1 })
      .lean();

    const totalCount = await Notification.countDocuments(filter);

    res.status(200).json({
      success: true,
      data: notifications,
      counts: {
        total: totalCount,
      },
    });
  } catch (error) {
    console.error("Get all notifications error:", error);
    res.status(500).json({
      success: false,
      message: "Failed to fetch notifications",
      error: error.message,
    });
  }
};




// Mark a notification as read
const markAsRead = async (req, res) => {
  try {
    const { notificationId } = req.params;
    const userId = req.user._id;

    const notification = await Notification.findOneAndUpdate(
      { _id: notificationId},
      { isRead: true, readAt: new Date() },
      { new: true }
    );

    if (!notification) {
      return res.status(404).json({
        success: false,
        message: "Notification not found",
      });
    }

    res.status(200).json({
      success: true,
      message: "Notification marked as read",
      data: notification,
    });
  } catch (error) {
    console.error("Mark notification as read error:", error);
    res.status(500).json({
      success: false,
      message: "Failed to mark notification as read",
      error: error.message,
    });
  }
};

// Get pending user verificationsfff 
const getPendingVerifications = async (req, res) => {
  try {
    const { page = 1, limit = 10 } = req.query
    const skip = (page - 1) * limit

    const pendingUsers = await User.find({
      isEmailVerified: true,
      verificationStatus: "pending",
      //isAdminVerified: false,
    })
      .select("firstName lastName email phoneNumber location livePhoto nationalId createdAt")
      .sort({ createdAt: -1 }) 
      .skip(skip)
      .limit(Number.parseInt(limit))  

    const total = await User.countDocuments({
      isEmailVerified: true,
      verificationStatus: "pending",
    })

    res.json({
      success: true,
      data: pendingUsers,
      pagination: getPaginationMeta(Number.parseInt(page), Number.parseInt(limit), total),
    })
  } catch (error) {
    console.error("Get pending verifications error:", error)
    res.status(500).json({
      success: false,
      message: "Failed to fetch pending verifications",
      error: error.message,
    })
  }
}

// Verify or reject user
const verifyUser = async (req, res) => {
  try {
    const { userId } = req.params
    const { action, notes } = req.body // action: 'approve' or 'reject'
    const adminId = req.user._id

    const user = await User.findById(userId)
    if (!user) {
      return res.status(404).json({
        success: false,
        message: "User not found",
      })
    }

    if (action === "approve") {
      user.verificationStatus = "approved"
      user.isAdminVerified = true
      user.verifiedBy = adminId
      user.verifiedAt = new Date()
      user.verificationNotes = notes

      await user.save()

      // Send approval email
      await sendUserNotificationEmail(
        user.email,
        "Account Verified - Welcome to WisdomWalk!",
        `Congratulations! Your account has been verified and you now have full access to WisdomWalk. Welcome to our community of Christian women!`,
        user.firstName,
      )

      // Create notification
      await new Notification({
        recipient: userId,
        type: "admin_verification",
        title: "Account Verified!",
        message: "Your account has been verified. Welcome to WisdomWalk!",
        priority: "high",
      }).save()
    } else if (action === "reject") {
      user.verificationStatus = "rejected"
      user.verificationNotes = notes

      await user.save()

      // Send rejection email
      await sendUserNotificationEmail(
        user.email,
        "Account Verification Update",
        `We were unable to verify your account at this time. ${notes || "Please contact support for more information."}`,
        user.firstName,
      )
    }

    res.json({
      success: true,
      message: `User ${action}d successfully`,
      data: {
        userId,
        action,
        verificationStatus: user.verificationStatus,
      },
    })
  } catch (error) {
    console.error("Verify user error:", error)
    res.status(500).json({
      success: false,
      message: "Failed to verify user",
      error: error.message,
    })
  }
}

// Get all users with filters
const getAllUsers = async (req, res) => {
  try {
    const { page = 1, limit = 20, status, verificationStatus, search } = req.query
    const skip = (page - 1) * limit

    const filter = {}

    if (status) filter.status = status
    if (verificationStatus) filter.verificationStatus = verificationStatus

    if (search) {
      filter.$or = [
        { firstName: { $regex: search, $options: "i" } },
        { lastName: { $regex: search, $options: "i" } },
        { email: { $regex: search, $options: "i" } },
      ]
    }

    const users = await User.find(filter)
      .select("firstName lastName email status verificationStatus isEmailVerified isAdminVerified createdAt lastActive")
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(Number.parseInt(limit))

    const total = await User.countDocuments(filter)

    res.json({
      success: true,
      data: users,
      pagination: getPaginationMeta(Number.parseInt(page), Number.parseInt(limit), total),
    })
  } catch (error) {
    console.error("Get all users error:", error)
    res.status(500).json({
      success: false,
      message: "Failed to fetch users",
      error: error.message,
    })
  }
}

// Block/unblock user
const toggleUserBlock = async (req, res) => {
  try {
    const { userId } = req.params
    const { reason, duration } = req.body // duration in days
    const adminId = req.user._id

    const user = await User.findById(userId)
    if (!user) {
      return res.status(404).json({
        success: false,
        message: "User not found",
      })
    }

    if (user.status === "blocked") {
      // Unblock user
      user.status = "active"
      user.blockedUntil = null
      await user.save()

      // Send notification
      await  sendUnblockedEmailToUser(
        user.email,
        "Account Unblocked",
        "Your account has been unblocked. You can now access WisdomWalk again.",
        user.firstName,
      )

      // Create notification
      await new Notification({
        recipient: userId,
        sender: adminId,
        type: "unblocked",
        title: "Account Unblocked",
        message: "Your account has been unblocked. You can now access WisdomWalk again.",
        priority: "high",
      }).save()
      // Send email notification
      await sendUnblockedEmailToUser(
        user.email,
        "Account Unblocked",
        "Your account has been unblocked. You can now access WisdomWalk again.",
        user.firstName,
      )

      res.json({
        success: true,
        message: "User unblocked successfully",
      })
    } else {
      // Block user
      user.status = "blocked"
      if (duration) {
        user.blockedUntil = new Date(Date.now() + duration * 24 * 60 * 60 * 1000)
      }

      await user.save()

      // Send notification
      await sendBlockedEmailToUser(
        user.email,
        reason || "You have been blocked from WisdomWalk.",
        user.firstName,
      )

      // Create notification
      await new Notification({
        recipient: userId,
        sender: adminId,
        type: "account_status",
        title: "Account Blocked",
        message: `Your account has been temporarily blocked. ${reason || ""}`,
        priority: "high",
      }).save()

      res.json({
        success: true,
        message: "User blocked successfully",
      })
    }
  } catch (error) {
    console.error("Toggle user block error:", error)
    res.status(500).json({
      success: false,
      message: "Failed to toggle user block",
      error: error.message,
    })
  }
}

// Ban user permanently
const banUser = async (req, res) => {
  try {
    const { userId } = req.params
    const { reason } = req.body
    const adminId = req.user._id

    const user = await User.findById(userId)
    if (!user) {
      return res.status(404).json({
        success: false,
        message: "User not found",
      })
    }

    user.status = "banned"
    user.banReason = reason
    await user.save()

    // Send notification
    await sendBannedEmailToUser(
      user.email,
      reason || "You have been permanently banned from WisdomWalk.",
      user.firstName,
    )


    res.json({
      success: true,
      message: "User banned successfully",
    })
  } catch (error) {
    console.error("Ban user error:", error)
    res.status(500).json({
      success: false,
      message: "Failed to ban user",
      error: error.message,
    })
  }
}

// Get reported content
const getReportedContent = async (req, res) => {
  try {
    const { page = 1, limit = 20, status = "pending", type, priority } = req.query
    const skip = (page - 1) * limit

    const filter = {}
    if (status && status !== "all") {
      filter.status = status
    }
    if (type) {
      filter.type = type
    }

    const reports = await Report.find(filter)
      .populate("reporter", "firstName lastName email profilePicture")
      .populate("reportedUser", "firstName lastName email profilePicture status")
      .populate({
        path: "reportedPost",
        select: "title content type author targetGroup createdAt isHidden",
        populate: {
          path: "author",
          select: "firstName lastName email",
        },
      })
      .populate({
        path: "reportedComment",
        select: "content author post createdAt isHidden",
        populate: {
          path: "author",
          select: "firstName lastName email",
        },
      })
      .populate({
        path: "reportedMessage",
        select: "content sender chat createdAt isDeleted",
        populate: {
          path: "sender",
          select: "firstName lastName email",
        },
      })
      .populate("assignedTo", "firstName lastName")
      .populate("resolvedBy", "firstName lastName")
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(Number.parseInt(limit))

    const total = await Report.countDocuments(filter)

    // Get summary statistics
    const stats = await Report.aggregate([
      {
        $group: {
          _id: "$status",
          count: { $sum: 1 },
        },
      },
    ])

    const statusCounts = {
      pending: 0,
      investigating: 0,
      resolved: 0,
      dismissed: 0,
    }

    stats.forEach((stat) => {
      statusCounts[stat._id] = stat.count
    })

    // Format reports with additional context
    const formattedReports = reports.map((report) => {
      const reportObj = report.toObject()

      // Add content preview and type
      if (reportObj.reportedPost) {
        reportObj.contentPreview =
          reportObj.reportedPost.title || reportObj.reportedPost.content.substring(0, 150) + "..."
        reportObj.contentType = "post"
        reportObj.contentAuthor = reportObj.reportedPost.author
      } else if (reportObj.reportedComment) {
        reportObj.contentPreview = reportObj.reportedComment.content.substring(0, 150) + "..."
        reportObj.contentType = "comment"
        reportObj.contentAuthor = reportObj.reportedComment.author
      } else if (reportObj.reportedUser) {
        reportObj.contentPreview = `User: ${reportObj.reportedUser.firstName} ${reportObj.reportedUser.lastName}`
        reportObj.contentType = "user"
        reportObj.contentAuthor = reportObj.reportedUser
      } else if (reportObj.reportedMessage) {
        reportObj.contentPreview = reportObj.reportedMessage.content.substring(0, 150) + "..."
        reportObj.contentType = "message"
        reportObj.contentAuthor = reportObj.reportedMessage.sender
      }

      // Add urgency level based on report count and type
      if (reportObj.type === "violence" || reportObj.type === "hate_speech") {
        reportObj.urgency = "high"
      } else if (reportObj.type === "harassment" || reportObj.type === "sexual_content") {
        reportObj.urgency = "medium"
      } else {
        reportObj.urgency = "low"
      }

      return reportObj
    })

    res.json({
      success: true,
      data: formattedReports,
      pagination: getPaginationMeta(Number.parseInt(page), Number.parseInt(limit), total),
      stats: statusCounts,
    })
  } catch (error) {
    console.error("Get reported content error:", error)
    res.status(500).json({
      success: false,
      message: "Failed to fetch reported content",
      error: error.message,
    })
  }
}

// Handle report
const handleReport = async (req, res) => {
  try {
    const { reportId } = req.params
    const { action, adminNotes } = req.body
    const adminId = req.user._id

    const report = await Report.findById(reportId).populate("reportedPost reportedComment reportedUser")

    if (!report) {
      return res.status(404).json({
        success: false,
        message: "Report not found",
      })
    }

    report.status = "resolved"
    report.actionTaken = action
    report.adminNotes = adminNotes
    report.resolvedBy = adminId
    report.resolvedAt = new Date()

    // Take action based on the decision
    switch (action) {
      case "content_removed":
        if (report.reportedPost) {
          await Post.findByIdAndUpdate(report.reportedPost._id, { isHidden: true })
        }
        if (report.reportedComment) {
          await Comment.findByIdAndUpdate(report.reportedComment._id, { isHidden: true })
        }
        break

      case "user_blocked":
        if (report.reportedUser) {
          await User.findByIdAndUpdate(report.reportedUser._id, {
            status: "blocked",
            blockedUntil: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000), // 7 days
          })
        }
        break

      case "user_banned":
        if (report.reportedUser) {
          await User.findByIdAndUpdate(report.reportedUser._id, {
            status: "banned",
            banReason: `Banned due to report: ${report.reason}`,
          })
        }
        break

      case "warning_sent":
        if (report.reportedUser) {
          await new Notification({
            recipient: report.reportedUser._id,
            sender: adminId,
            type: "admin_message",
            title: "Community Guidelines Warning",
            message: `You have received a warning for violating community guidelines. ${adminNotes || ""}`,
            priority: "high",
          }).save()
        }
        break
    }

    await report.save()

    res.json({
      success: true,
      message: "Report handled successfully",
      data: report,
    })
  } catch (error) {
    console.error("Handle report error:", error)
    res.status(500).json({
      success: false,
      message: "Failed to handle report",
      error: error.message,
    })
  }
}

// Send notification to users
const sendNotificationToUsers = async (req, res) => {
  try {
    const { title, message, userIds, groupType, priority = "normal" } = req.body
    const adminId = req.user._id

    let recipients = [] 

    if (userIds && userIds.length > 0) {
      // Send to specific users
      recipients = userIds
    } else if (groupType) {
      // Send to all users in a specific group
      const groupUsers = await User.find({
        "joinedGroups.groupType": groupType, 
        isEmailVerified: true,
        isAdminVerified: true,
        status: "active",
      }).select("_id")

      recipients = groupUsers.map((user) => user._id)
    } else {
      // Send to all active users
      const allUsers = await User.find({
        isEmailVerified: true,
        isAdminVerified: true,
        status: "active",
      }).select("_id")

      recipients = allUsers.map((user) => user._id)
    }

    // Create notifications
    const notifications = recipients.map((userId) => ({
      recipient: userId,
      sender: adminId,
      type: "admin_message",
      title,
      message,
      priority,
    }))

    await Notification.insertMany(notifications)

    res.json({
      success: true,
      message: `Notification sent to ${recipients.length} users`,
      data: {
        recipientCount: recipients.length,
      },
    })
  } catch (error) {
    console.error("Send notification error:", error)
    res.status(500).json({
      success: false,
      message: "Failed to send notification",
      error: error.message,
    })
  }
}

// Nominate group admin
const nominateGroupAdmin = async (req, res) => {
  try {
    const { userId, groupType } = req.body
    const adminId = req.user._id

    const user = await User.findById(userId)
    if (!user) {
      return res.status(404).json({
        success: false,
        message: "User not found",
      })
    }

    // Check if user is member of the group
    const groupIndex = user.joinedGroups.findIndex((group) => group.groupType === groupType)
    if (groupIndex === -1) {
      return res.status(400).json({
        success: false,
        message: "User is not a member of this group",
      })
    }

    // Make user admin of the group
    user.joinedGroups[groupIndex].isAdmin = true
    await user.save()

    // Send notification to the new admin
    await new Notification({
      recipient: userId,
      sender: adminId,
      type: "admin_message",
      title: "Group Admin Nomination",
      message: `Congratulations! You have been nominated as an admin for the ${groupType} group.`,
      priority: "high",
    }).save()

    // Send email notification
    await sendUserNotificationEmail(
      user.email,
      "Group Admin Nomination",
      `Congratulations! You have been nominated as an admin for the ${groupType} group in WisdomWalk.`,
      user.firstName,
    )

    res.json({
      success: true,
      message: "User nominated as group admin successfully",
    })
  } catch (error) {
    console.error("Nominate group admin error:", error)
    res.status(500).json({
      success: false,
      message: "Failed to nominate group admin",
      error: error.message,
    })
  }
}

// Get admin dashboard stats
const getDashboardStats = async (req, res) => {
  try { 
    // Get user statistics
    const totalUsers = await User.countDocuments()
    const activeUsers = await User.countDocuments({ status: "active", isAdminVerified: true })
    const pendingVerifications = await User.countDocuments({ verificationStatus: "pending", isEmailVerified:true })
    const blockedUsers = await User.countDocuments({ status: "blocked" })

    // Get content statistics
    const totalPosts = await Post.countDocuments()
    const totalComments = await Comment.countDocuments()
    const hiddenPosts = await Post.countDocuments({ isHidden: true })
    const totalBooks = await Booking.countDocuments() // Assuming Booking is the model for bookings
    const totalEvents= await Event.countDocuments();
    // Get report statistics
    const pendingReports = await Report.countDocuments({ status: "pending" })
    const resolvedReports = await Report.countDocuments({ status: "resolved" })

    // Get recent activity (last 7 days)
    const weekAgo = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000)
    const newUsersThisWeek = await User.countDocuments({
      createdAt: { $gte: weekAgo },
      isAdminVerified: true,
    })
    const newPostsThisWeek = await Post.countDocuments({
      createdAt: { $gte: weekAgo },
    })

    // Get group statistics
    const groupStats = await User.aggregate([
      { $unwind: "$joinedGroups" },
      { $group: { _id: "$joinedGroups.groupType", count: { $sum: 1 } } },
    ])

    res.json({
      success: true,
      data: {
        users: {
          total: totalUsers,
          active: activeUsers,
          pendingVerifications,
          blocked: blockedUsers,
          newThisWeek: newUsersThisWeek,
        },
        content: {
          totalPosts,
          totalComments,
          hiddenPosts,
          newPostsThisWeek,
        },
        reports: {
          pending: pendingReports,
          resolved: resolvedReports,
        },
        bookings: {
          total: totalBooks,
        },
        events:{
          total:totalEvents,
        },
        groups: groupStats,
      },
    })
  } catch (error) {
    console.error("Get dashboard stats error:", error)
    res.status(500).json({
      success: false,
      message: "Failed to fetch dashboard statistics",
      error: error.message,
    })
  }
}

module.exports = {
  getPendingVerifications,
  verifyUser,
  getAllUsers,
  toggleUserBlock,
  banUser,
  getReportedContent,
  handleReport,
  sendNotificationToUsers,
  nominateGroupAdmin,
  getDashboardStats,
  getAllNotifications,
  markAsRead

}
