const Notification = require("../models/Notification")
const User = require("../models/User") // Import User model
const { getPaginationMeta } = require("../utils/helpers")

// Get user notifications
const getUserNotifications = async (req, res) => {
  try {
    const userId = req.user._id
    const { page = 1, limit = 20, isRead } = req.query
    const skip = (page - 1) * limit

    const filter = { recipient: userId }
    if (isRead !== undefined) {
      filter.isRead = isRead === "true"
    }

    const notifications = await Notification.find(filter)
      .populate("sender", "firstName lastName profilePicture")
      .populate("relatedPost", "title content type")
      .populate("relatedComment", "content")
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(Number.parseInt(limit))

    const total = await Notification.countDocuments(filter)
    const unreadCount = await Notification.countDocuments({
      recipient: userId,
      isRead: false,
    })

    res.json({
      success: true,
      data: notifications,
      pagination: getPaginationMeta(Number.parseInt(page), Number.parseInt(limit), total),
      unreadCount,
    })
  } catch (error) {
    console.error("Get user notifications error:", error)
    res.status(500).json({
      success: false,
      message: "Failed to fetch notifications",
      error: error.message,
    })
  }
}

// Mark notification as read
const markAsRead = async (req, res) => {
  try {
    const { notificationId } = req.params
    const userId = req.user._id

    const notification = await Notification.findOneAndUpdate(
      { _id: notificationId, recipient: userId },
      { isRead: true, readAt: new Date() },
      { new: true },
    )

    if (!notification) {
      return res.status(404).json({
        success: false,
        message: "Notification not found",
      })
    }

    res.json({
      success: true,
      message: "Notification marked as read",
      data: notification,
    })
  } catch (error) {
    console.error("Mark notification as read error:", error)
    res.status(500).json({
      success: false,
      message: "Failed to mark notification as read",
      error: error.message,
    })
  }
}

// Mark all notifications as read
const markAllAsRead = async (req, res) => {
  try {
    const userId = req.user._id

    await Notification.updateMany({ recipient: userId, isRead: false }, { isRead: true, readAt: new Date() })

    res.json({
      success: true,
      message: "All notifications marked as read",
    })
  } catch (error) {
    console.error("Mark all notifications as read error:", error)
    res.status(500).json({
      success: false,
      message: "Failed to mark all notifications as read",
      error: error.message,
    })
  }
}

// Delete notification
const deleteNotification = async (req, res) => {
  try {
    const { notificationId } = req.params
    const userId = req.user._id

    const notification = await Notification.findOneAndDelete({
      _id: notificationId,
      recipient: userId,
    })

    if (!notification) {
      return res.status(404).json({
        success: false,
        message: "Notification not found",
      })
    }

    res.json({
      success: true,
      message: "Notification deleted successfully",
    })
  } catch (error) {
    console.error("Delete notification error:", error)
    res.status(500).json({
      success: false,
      message: "Failed to delete notification",
      error: error.message,
    })
  }
}

// Get notification settings
const getNotificationSettings = async (req, res) => {
  try {
    const userId = req.user._id
    const user = await User.findById(userId).select("preferences")

    res.json({
      success: true,
      data: user.preferences,
    })
  } catch (error) {
    console.error("Get notification settings error:", error)
    res.status(500).json({
      success: false,
      message: "Failed to fetch notification settings",
      error: error.message,
    })
  }
}

module.exports = {
  getUserNotifications,
  markAsRead,
  markAllAsRead,
  deleteNotification,
  getNotificationSettings,
}
