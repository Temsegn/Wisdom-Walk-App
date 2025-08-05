const express = require("express")
const router = express.Router()
const groupController = require("../controllers/groupController")
const { authenticateToken } = require("../middleware/auth")
const { validateMessage } = require("../middleware/validation")
const { uploadMultiple, handleUploadError } = require("../middleware/upload")

// All routes require authentication
router.use(authenticateToken)

// ===== GROUP MEMBERSHIP ROUTES =====
// Get user's joined groups 
router.get("/my-groups", groupController.getUserGroups)
router.get("/get-groups", groupController.getAvailableGroups)
// Join/leave group types
router.post("/join", groupController.joinGroup)
router.post("/leave", groupController.leaveGroup)

// Get group members list
router.get("/:groupType/members", groupController.getGroupMembers)

// ===== GROUP CHAT ROUTES =====
// Get all chats user has joined in this group
router.get("/:groupType/chats", groupController.getJoinedChats)

// Get messages in group chat
router.get("/:groupType/chats/:chatId/messages", groupController.getChatMessages)

// Send message to group chat (with file sharing)
router.post(
  "/:groupType/chats/:chatId/messages",
  uploadMultiple,
  handleUploadError,
  validateMessage,
  groupController.sendMessage
)

// React to message
router.post("/:groupType/chats/:chatId/messages/:messageId/react", groupController.addReaction)

// Delete own message
router.delete("/:groupType/chats/:chatId/messages/:messageId", groupController.deleteMessage)

// ===== GROUP POSTS ROUTES =====
// Toggle pin post (any member can pin/unpin)
router.post("/:groupType/posts/:postId/pin", groupController.togglePinPost)


module.exports = router  
