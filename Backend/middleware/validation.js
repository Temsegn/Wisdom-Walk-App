const { body, validationResult } = require("express-validator")

// Handle validation errors
const handleValidationErrors = (req, res, next) => {
  const errors = validationResult(req)
  if (!errors.isEmpty()) {
    return res.status(400).json({
      success: false,
      message: "Validation failed",
      errors: errors.array(),
    })
  }
  next()
}

// User registration validation
const validateRegistration = [
  body("email").isEmail().normalizeEmail().withMessage("Please provide a valid email"),

  body("password")
    .isLength({ min: 6 })
    .withMessage("Password must be at least 6 characters long")
    .matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/)
    .withMessage("Password must contain at least one uppercase letter, one lowercase letter, and one number"),

 
  body("dateOfBirth")
    .isISO8601()
    .withMessage("Please provide a valid date of birth")
    .custom((value) => {
      const age = new Date().getFullYear() - new Date(value).getFullYear()
      if (age < 13) {
        throw new Error("You must be at least 13 years old to register")
      }
      return true
    }),

  body("phoneNumber").isMobilePhone().withMessage("Please provide a valid phone number"),

  handleValidationErrors,
]

// Login validation
const validateLogin = [
  body("email").isEmail().normalizeEmail().withMessage("Please provide a valid email"),

  body("password").notEmpty().withMessage("Password is required"),

  handleValidationErrors,
]

// Post creation validation
const validatePost = [
  body("type")
    .isIn(["prayer", "share"])
    .withMessage("Post type must be prayer or share"),

  body("content").trim().isLength({ min: 10, max: 2000 }).withMessage("Content must be between 10 and 2000 characters"),

  body("title").optional().trim().isLength({ max: 200 }).withMessage("Title must not exceed 200 characters"),

  body("targetGroup")
    .optional()
    .isIn(["single", "marriage", "healing", "motherhood", "general"])
    .withMessage("Invalid target group"),

  handleValidationErrors,
]

// Comment validation
const validateComment = [
  body("content").trim().isLength({ min: 1, max: 1000 }).withMessage("Comment must be between 1 and 1000 characters"),

  handleValidationErrors,
]

// Message validation
const validateMessage = [
  body("content").trim().isLength({ min: 1, max: 2000 }).withMessage("Message must be between 1 and 2000 characters"),

  body("messageType").optional().isIn(["text", "image", "scripture", "prayer"]).withMessage("Invalid message type"),

  handleValidationErrors,
]

// Report validation
const validateReport = [
  body("type")
    .isIn([
      "inappropriate_content",
      "harassment",
      "spam",
      "fake_profile",
      "violence",
      "hate_speech",
      "sexual_content",
      "misinformation",
      "other",
    ])
    .withMessage("Invalid report type"),

  body("reason").trim().isLength({ min: 10, max: 1000 }).withMessage("Reason must be between 10 and 1000 characters"),

  handleValidationErrors,
]

module.exports = {
  validateRegistration,
  validateLogin,
  validatePost,
  validateComment,
  validateMessage,
  validateReport,
  handleValidationErrors,
}
