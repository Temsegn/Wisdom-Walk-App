const express = require("express");
const router = express.Router();

const notificationController = require("../controllers/notificationController");
const { authenticateToken } = require("../middleware/auth");

// Protect all routes with authentication middleware
router.use(authenticateToken);
 
router.get("/", notificationController.getUserNotifications);

router.get("/unread-count", notificationController.getUnreadNotificationCount);

router.put("/:notificationId/read", notificationController.markAsRead);
 
router.put("/mark-all-read", notificationController.markAllAsRead);
 
router.delete("/:notificationId", notificationController.deleteNotification);
 
router.delete("/clear-all", notificationController.clearAllNotifications);
 
router.get("/settings", notificationController.getNotificationSettings);
 
router.put("/settings", notificationController.updateNotificationSettings);

module.exports = router;
