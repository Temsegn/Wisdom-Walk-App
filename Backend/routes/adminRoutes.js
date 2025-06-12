const express = require("express")
const router = express.Router()
const adminController = require("../controllers/adminController")
const { authenticateToken, requireAdmin, requirePermission } = require("../middleware/auth")

// All routes require authentication and admin access
router.use(authenticateToken)
router.use(requireAdmin)

// User verification
router.get("/verifications/pending", requirePermission("verify_users"), adminController.getPendingVerifications)
router.post("/users/:userId/verify", requirePermission("verify_users"), adminController.verifyUser)

// User management
router.get("/users", adminController.getAllUsers)
router.post("/users/:userId/block", requirePermission("ban_users"), adminController.toggleUserBlock)
router.post("/users/:userId/ban", requirePermission("ban_users"), adminController.banUser)

// Content moderation
router.get("/reports", requirePermission("manage_posts"), adminController.getReportedContent)
router.post("/reports/:reportId/handle", requirePermission("manage_posts"), adminController.handleReport)

// Notifications
router.post("/notifications/send", requirePermission("send_notifications"), adminController.sendNotificationToUsers)

// Group management
router.post("/groups/nominate-admin", requirePermission("manage_groups"), adminController.nominateGroupAdmin)

// Dashboard
router.get("/dashboard/stats", adminController.getDashboardStats)

module.exports = router
