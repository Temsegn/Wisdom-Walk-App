const express = require("express");
const router = express.Router();
const groupController = require("../controllers/groupController");
const { authenticateToken } = require("../middleware/auth");
const { validateMessage } = require("../middleware/validation");
const { uploadMultiple, handleUploadError } = require("../middleware/upload");

// All routes require authentication
router.use(authenticateToken);

// ===== GROUP MANAGEMENT ROUTES =====
// Create new group (admin only)
router.post("/", (req, res, next) => {
  console.log('Received group creation request', req.body)
  next() 
}, groupController.createGroup)
// Get group details
router.get("/:groupId", groupController.getGroupDetails);

// Update group info (admin only)
router.put("/:groupId",  groupController.updateGroup);

// Delete group (creator only)
router.delete("/:groupId", groupController.deleteGroup);

// ===== GROUP MEMBERSHIP ROUTES =====
// Join group via invite link
router.post("/join/:inviteLink", groupController.joinGroupViaLink);

// Leave group
router.post("/:groupId/leave", groupController.leaveGroup);

// Add member (admin only)
router.post("/:groupId/members",  groupController.addMember);

// Remove member (admin only)
router.delete(
  "/:groupId/members/:userId",
  
  groupController.removeMember
);

// Promote to admin (creator only)
router.post(
  "/:groupId/admins/:userId",
  groupController.promoteToAdmin
);

// Demote admin (creator only)
router.delete(
  "/:groupId/admins/:userId",
  groupController.demoteAdmin
);

// Get group members
router.get("/:groupId/members", groupController.getGroupMembers);

// ===== GROUP CHAT ROUTES =====
// Get group chat messages
router.get("/:groupId/chat/messages", groupController.getChatMessages);

// Send message to group chat
router.post(
  "/:groupId/chat/messages",
  uploadMultiple,
  handleUploadError,
  validateMessage,
  groupController.sendMessage
);

// Reply to message
router.post(
  "/:groupId/chat/messages/:messageId/reply",
  validateMessage,
  groupController.replyToMessage
);

// React to message
router.post(
  "/:groupId/chat/messages/:messageId/react",
  groupController.addReaction
);

// Delete message (sender or admin)
router.delete(
  "/:groupId/chat/messages/:messageId",
  groupController.deleteMessage
);

// Pin message (admin only)
router.post(
  "/:groupId/chat/messages/:messageId/pin",
  
  groupController.pinMessage
);

// Unpin message (admin only)
router.delete(
  "/:groupId/chat/messages/:messageId/pin",
  
  groupController.unpinMessage
);

// Get pinned messages
router.get("/:groupId/chat/pinned", groupController.getPinnedMessages);

// ===== GROUP SETTINGS ROUTES =====
// Update group settings (admin only)
router.put(
  "/:groupId/settings",
  
  groupController.updateGroupSettings
);

// Generate new invite link (admin only)
router.post(
  "/:groupId/invite-link",
  
  groupController.generateInviteLink
);

// Mute group notifications
router.post("/:groupId/mute", groupController.muteGroup);

// Unmute group notifications
router.post("/:groupId/unmute", groupController.unmuteGroup);

module.exports = router;