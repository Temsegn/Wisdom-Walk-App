const express = require('express')
const router = express.Router()
const reportController = require('../controllers/reportController')
const { authenticateToken } = require('../middleware/auth')

// Create a report (general route: supports post or user)
router.post('/', authenticateToken, reportController.createReport)

// Get all reports submitted by the logged-in user
router.get('/my-reports', authenticateToken, reportController.getUserReports)

// Quick report a post (shortcut)
router.post('/posts/:postId', authenticateToken, reportController.reportPost)

// Quick report a user (new route)
router.post('/users/:userId', authenticateToken, reportController.reportUser)

module.exports = router
