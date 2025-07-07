const express = require("express");
const router = express.Router();
const adminController = require("../controllers/adminController");
const { authenticateToken, requireAdmin, requirePermission } = require("../middleware/auth");

// Apply global middlewares for all routes below
router.use(authenticateToken);

// User verification
router.get("/verifications/pending",  adminController.getPendingVerifications);
router.post("/users/:userId/verify",  adminController.verifyUser);
router.get("/notifications", adminController.getAllNotifications); // Ensure this is protected
router.put("/notifications/:notificationId/read", adminController.markAsRead);
 
// User management
router.get("/users", adminController.getAllUsers); // Now correctly protected
router.post("/users/:userId/block",  adminController.toggleUserBlock);
router.post("/users/:userId/ban", adminController.banUser);

// Content moderation
router.get("/reports",  adminController.getReportedContent);
router.post("/reports/:reportId/handle", adminController.handleReport);

// Notifications
router.post("/notifications/send", adminController.sendNotificationToUsers);

// Group management
router.post("/groups/nominate-admin", adminController.nominateGroupAdmin);

// Dashboard
router.get("/dashboard/stats", adminController.getDashboardStats);

module.exports = router;
