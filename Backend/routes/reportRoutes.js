const express = require("express")
const router = express.Router()
const reportController = require("../controllers/reportController")
const { authenticateToken } = require("../middleware/auth")
const { validateReport } = require("../middleware/validation")

// All routes require authentication
router.use(authenticateToken)

// General report routes
router.post("/", validateReport, reportController.createReport)
router.get("/my-reports", reportController.getUserReports)

module.exports = router
