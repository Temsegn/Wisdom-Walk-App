const express = require("express");
const router = express.Router();

const notificationController = require("../controllers/notificationController");
const { authenticateToken } = require("../middleware/auth");

// Protect all routes with authentication middleware
router.use(authenticateToken);

/**
 * @route   GET /api/notifications
 * @desc    Retrieve all notifications for the authenticated user (with pagination)
 * @access  Private
 */
router.get("/", notificationController.getUserNotifications);

/**
 * @route   GET /api/notifications/unread-count
 * @desc    Get count of unread notifications for the authenticated user
 * @access  Private
 */
router.get("/unread-count", notificationController.getUnreadNotificationCount);

/**
 * @route   PUT /api/notifications/:notificationId/read
 * @desc    Mark a specific notification as read
 * @access  Private
 */
router.put("/:notificationId/read", notificationController.markAsRead);

/**
 * @route   PUT /api/notifications/mark-all-read
 * @desc    Mark all notifications as read for the authenticated user
 * @access  Private
 */
router.put("/mark-all-read", notificationController.markAllAsRead);

/**
 * @route   DELETE /api/notifications/:notificationId
 * @desc    Delete a specific notification
 * @access  Private
 */
router.delete("/:notificationId", notificationController.deleteNotification);

/**
 * @route   DELETE /api/notifications/clear-all
 * @desc    Delete all notifications for the authenticated user
 * @access  Private
 */
router.delete("/clear-all", notificationController.clearAllNotifications);

/**
 * @route   GET /api/notifications/settings
 * @desc    Retrieve notification settings for the authenticated user
 * @access  Private
 */
router.get("/settings", notificationController.getNotificationSettings);

/**
 * @route   PUT /api/notifications/settings
 * @desc    Update notification settings for the authenticated user
 * @access  Private
 */
router.put("/settings", notificationController.updateNotificationSettings);

module.exports = router;
