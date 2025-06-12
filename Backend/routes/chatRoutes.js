const express = require("express")
const router = express.Router()
const chatController = require("../controllers/chatController")
const { authenticateToken } = require("../middleware/auth")
const { validateMessage } = require("../middleware/validation")
const { uploadMultiple, handleUploadError } = require("../middleware/upload")

// All routes require authentication
router.use(authenticateToken)

// Chat routes
router.get("/", chatController.getUserChats)
router.post("/direct", chatController.createDirectChat)
router.get("/:chatId/messages", chatController.getChatMessages)
router.post("/:chatId/messages", uploadMultiple, handleUploadError, validateMessage, chatController.sendMessage)
router.delete("/messages/:messageId", chatController.deleteMessage)
router.post("/messages/:messageId/reaction", chatController.addReaction)

module.exports = router
