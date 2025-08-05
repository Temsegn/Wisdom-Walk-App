const express = require("express");
const router = express.Router();
const groupController = require("../controllers/group");
const { authenticateToken } = require("../middleware/auth");
const { uploadMultiple } = require("../middleware/upload");

// Debugging - verify controller imports
console.log("Group Controller Methods:", Object.keys(groupController));

router.use(authenticateToken);

// Group CRUD
router.post("/", groupController.createGroup);
router.get("/", groupController.getAllGroups);
router.get("/:groupId", groupController.getGroupDetails);
router.put("/:groupId", groupController.updateGroup);
router.delete("/:groupId", groupController.deleteGroup);

// Members
router.post("/join/:inviteLink", groupController.joinGroupViaLink);
router.post("/:groupId/leave", groupController.leaveGroup);
router.post("/:groupId/join", groupController.joinGroup);
router.post("/:groupId/members", groupController.addMember);
router.delete("/:groupId/members/:userId", groupController.removeMember);
router.get("/:groupId/members", groupController.getGroupMembers);

// Admin
router.post("/:groupId/admins/:userId", groupController.promoteToAdmin);
router.delete("/:groupId/admins/:userId", groupController.demoteAdmin);

// Chat
router.get("/:groupId/chat/messages", groupController.getChatMessages);
router.post("/:groupId/chat/messages", uploadMultiple, groupController.sendMessage);

// Pinned
router.get("/:groupId/chat/pinned", groupController.getPinnedMessages);
router.post("/:groupId/chat/messages/:messageId/pin", groupController.pinMessage);
router.delete("/:groupId/chat/messages/:messageId/pin", groupController.unpinMessage);

// Settings
router.put("/:groupId/settings", groupController.updateGroupSettings);
router.post("/:groupId/invite-link", groupController.generateInviteLink);

// Notifications
router.post("/:groupId/mute", groupController.muteGroup);
router.post("/:groupId/unmute", groupController.unmuteGroup);

module.exports = router;