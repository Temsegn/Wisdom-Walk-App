const express = require("express")
const router = express.Router()
const authController = require("../controllers/authController")
const { validateRegistration, validateLogin } = require("../middleware/validation")
const { uploadFields, handleUploadError } = require("../middleware/upload")
const {authenticateToken} = require("../middleware/auth")

router.post(
  "/register",
  uploadFields,            // handles file upload
  handleUploadError,       // optional: handles multer errors
  authController.register  // controller logic
)

// Email verification
router.post("/verify", authController.verifyEmail)

// Login
router.post("/login", validateLogin, authController.login)

// Password reset request
router.post("/forgot-password", authController.requestPasswordReset)

// Password reset
router.post("/reset-password", authController.resetPassword)

// Resend verification email
router.post("/resend-verification", authController.resendVerificationEmail)

// Change password
router.post("/change-password", authenticateToken, authController.changePassword)
router.post("/logout", authController.logout)

module.exports = router


