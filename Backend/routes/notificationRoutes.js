const express = require("express")
const router = express.Router()
const notificationController = require("../controllers/notificationController")
const reportController = require("../controllers/reportController")
const { authenticateToken } = require("../middleware/auth")
const { validateReport } = require("../middleware/validation")

// All routes require authentication
router.use(authenticateToken)

// Notification routes
router.get("/", notificationController.getUserNotifications)
router.put("/:notificationId/read", notificationController.markAsRead)
router.put("/mark-all-read", notificationController.markAllAsRead)
router.delete("/:notificationId", notificationController.deleteNotification)
router.get("/settings", notificationController.getNotificationSettings)

module.exports = router
