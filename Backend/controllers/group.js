const Group = require("../models/group");
const Chat = require("../models/Chat");
const User = require("../models/User");
const Message = require("../models/Message");
const { generateRandomString } = require("../utils/helpers");

// Helper function to check if user is group admin
const isGroupAdmin = (group, userId) => {
  return group.admins.some(adminId => adminId.toString() === userId.toString());
};

// Helper function to check if user is group member
const isGroupMember = (group, userId) => {
  return group.members.some(member => member.user.toString() === userId.toString());
};

// Group CRUD Operations
const createGroup = async (req, res) => {
  try {
    const { name, description, type } = req.body;
    const creatorId = req.user._id;

    if (!name || !type) {
      return res.status(400).json({ 
        success: false,
        message: "Group name and type are required" 
      });
    }

    // Create group chat first
    const chat = new Chat({
      type: "group",
      participants: [creatorId]
    });
    await chat.save();

    // Create the group
    const group = new Group({
      name,
      description,
      type,
      creator: creatorId,
      chat: chat._id,
      admins: [creatorId],
      members: [{ user: creatorId, role: "admin" }]
    });
    await group.save();

    // Update chat with group reference
    chat.group = group._id;
    await chat.save();

    const populatedGroup = await Group.findById(group._id)
      .populate("creator", "firstName lastName avatar")
      .populate("members.user", "firstName lastName avatar");

    res.status(201).json({
      success: true,
      group: populatedGroup
    });
  } catch (error) {
    console.error("Error creating group:", error);
    res.status(500).json({ 
      success: false,
      message: "Failed to create group" 
    });
  }
};
const getAllGroups = async (req, res) => {
  try {
    const groups = await Group.find({})
      .populate("creator", "firstName lastName avatar")
      .populate("members.user", "firstName lastName avatar")
      .populate("admins", "firstName lastName avatar");

    res.status(200).json({
      success: true,
      groups: groups || []
    });
  } catch (error) {
    console.error("Error fetching groups:", error);
    res.status(500).json({
      success: false,
      message: "Failed to fetch groups",
      groups: []
    });
  }
};


const getGroupDetails = async (req, res) => {
  try {
    const group = await Group.findById(req.params.groupId)
      .populate("creator", "firstName lastName avatar")
      .populate("members.user", "firstName lastName avatar")
      .populate("admins", "firstName lastName avatar")
      .populate({
        path: "pinnedMessages.message",
        populate: {
          path: "sender",
          select: "firstName lastName avatar"
        }
      });

    if (!group) {
      return res.status(404).json({ 
        success: false,
        message: "Group not found" 
      });
    }

    // // Allow access if user is a member or an admin
    // if (!isGroupMember(group, req.user._id) && req.user.role !== 'admin') {
    //   return res.status(403).json({ 
    //     success: false,
    //     message: "Access denied. Not a group member" 
    //   });
    // }

    res.status(200).json({ 
      success: true,
      group 
    });
  } catch (error) {
    console.error("Error fetching group details:", error);
    res.status(500).json({ 
      success: false,
      message: "Failed to fetch group details" 
    });
  }
};

const updateGroup = async (req, res) => {
  try {
    const { name, description } = req.body;
    const group = await Group.findById(req.params.groupId);

    if (!group) {
      return res.status(404).json({ 
        success: false,
        message: "Group not found" 
      });
    }

    // // Allow update if user is group admin or system admin
    // if (!isGroupAdmin(group, req.user._id) && req.user.role !== 'admin') {
    //   return res.status(403).json({ 
    //     success: false,
    //     message: "Only admins can update group" 
    //   });
    // }

    if (name) group.name = name;
    if (description) group.description = description;
    await group.save();

    res.status(200).json({ 
      success: true,
      group 
    });
  } catch (error) {
    console.error("Error updating group:", error);
    res.status(500).json({ 
      success: false,
      message: "Failed to update group" 
    });
  }
};

const deleteGroup = async (req, res) => {
  try {
    const group = await Group.findById(req.params.groupId);

    if (!group) {
      return res.status(404).json({ 
        success: false,
        message: "Group not found" 
      });
    }

    // Allow delete if user is group creator or system admin
    if (group.creator.toString() !== req.user._id.toString() && req.user.role !== 'admin') {
      return res.status(403).json({ 
        success: false,
        message: "Only group creator or system admin can delete the group" 
      });
    }

    // Delete associated chat
    await Chat.deleteOne({ _id: group.chat });
    
    // Delete the group
    await Group.deleteOne({ _id: group._id });

    res.status(200).json({ 
      success: true,
      message: "Group deleted successfully" 
    });
  } catch (error) {
    console.error("Error deleting group:", error);
    res.status(500).json({ 
      success: false,
      message: "Failed to delete group" 
    });
  }
};
const getGroupMembers = async (req, res) => {
  try {
    const group = await Group.findById(req.params.groupId)
      .populate("members.user", "firstName lastName email avatar");

    if (!group) {
      return res.status(404).json({
        success: false,
        message: "Group not found",
      });
    }

    const members = group.members.map((member) => ({
      id: member._id,
      role: member.role,
      isMuted: member.isMuted,
      joinedAt: member.joinedAt,
      name: `${member.user?.firstName ?? ''} ${member.user?.lastName ?? ''}`.trim(),
      email: member.user?.email ?? '',
      avatar: member.user?.avatar ?? '',
    }));

    res.status(200).json({
      success: true,
      members,
    });
  } catch (error) {
    console.error("Error fetching group members:", error);
    res.status(500).json({
      success: false,
      message: "Failed to fetch group members",
      members: [],
    });
  }
};


// Group Membership Management
const joinGroupViaLink = async (req, res) => {
  try {
    const group = await Group.findOne({ inviteLink: req.params.inviteLink });
    
    if (!group) {
      return res.status(404).json({ 
        success: false,
        message: "Invalid or expired invite link" 
      });
    }

    // if (isGroupMember(group, req.user._id)) {
    //   return res.status(400).json({ 
    //     success: false,
    //     message: "You are already a member of this group" 
    //   });
    // }

    group.members.push({ user: req.user._id });
    await group.save();

    res.status(200).json({ 
      success: true,
      message: "Joined group successfully" 
    });
  } catch (error) {
    console.error("Error joining group via link:", error);
    res.status(500).json({ 
      success: false,
      message: "Failed to join group" 
    });
  }
};

const leaveGroup = async (req, res) => {
  try {
    const group = await Group.findById(req.params.groupId);
    
    if (!group) {
      return res.status(404).json({ 
        success: false,
        message: "Group not found" 
      });
    }

    // if (!isGroupMember(group, req.user._id)) {
    //   return res.status(400).json({ 
    //     success: false,
    //     message: "You are not a member of this group" 
    //   });
    // }

    // Remove from admins if admin
    group.admins = group.admins.filter(
      adminId => adminId.toString() !== req.user._id.toString()
    );

    // Remove from members
    group.members = group.members.filter(
      member => member.user.toString() !== req.user._id.toString()
    );

    await group.save();

    res.status(200).json({ 
      success: true,
      message: "Left group successfully" 
    });
  } catch (error) {
    console.error("Error leaving group:", error);
    res.status(500).json({ 
      success: false,
      message: "Failed to leave group" 
    });
  }
};
const joinGroup = async (req, res) => {
  try {
    const group = await Group.findById(req.params.groupId);

    if (!group) {
      return res.status(404).json({
        success: false,
        message: "Group not found"
      });
    }

    // Check if user is already a member
    const isAlreadyMember = group.members.some(
      member => member.user.toString() === req.user._id.toString()
    );

    if (isAlreadyMember) {
      return res.status(400).json({
        success: false,
        message: "You are already a member of this group"
      });
    }

    // Add user to members
    group.members.push({ user: req.user._id });

    await group.save();

    res.status(200).json({
      success: true,
      message: "Joined group successfully"
    });
  } catch (error) {
    console.error("Error joining group:", error);
    res.status(500).json({
      success: false,
      message: "Failed to join group"
    });
  }
};


const addMember = async (req, res) => {
  try {
    const { userId } = req.body;
    const group = await Group.findById(req.params.groupId);

    if (!group) {
      return res.status(404).json({ 
        success: false,
        message: "Group not found" 
      });
    }

    // // Allow add if user is group admin or system admin
    // if (!isGroupAdmin(group, req.user._id) && req.user.role !== 'admin') {
    //   return res.status(403).json({ 
    //     success: false,
    //     message: "Only admins can add members" 
    //   });
    // }

    // Check if user is already a member
    // if (isGroupMember(group, userId)) {
    //   return res.status(400).json({ 
    //     success: false,
    //     message: "User is already a group member" 
    //   });
    // }

    group.members.push({ user: userId });
    await group.save();

    res.status(200).json({ 
      success: true,
      message: "Member added successfully" 
    });
  } catch (error) {
    console.error("Error adding member:", error);
    res.status(500).json({ 
      success: false,
      message: "Failed to add member" 
    });
  }
};

const removeMember = async (req, res) => {
  try {
    const group = await Group.findById(req.params.groupId);
    
    if (!group) {
      return res.status(404).json({ 
        success: false,
        message: "Group not found" 
      });
    }

    // Allow remove if user is group admin or system admin
    // if (!isGroupAdmin(group, req.user._id) && req.user.role !== 'admin') {
    //   return res.status(403).json({ 
    //     success: false,
    //     message: "Only admins can remove members" 
    //   });
    // }

    // Cannot remove yourself
    if (req.params.userId === req.user._id.toString()) {
      return res.status(400).json({ 
        success: false,
        message: "Use the leave group option instead" 
      });
    }

    // Remove from admins first if they are admin
    group.admins = group.admins.filter(
      adminId => adminId.toString() !== req.params.userId
    );

    // Remove from members
    group.members = group.members.filter(
      member => member.user.toString() !== req.params.userId
    );

    await group.save();

    res.status(200).json({ 
      success: true,
      message: "Member removed successfully" 
    });
  } catch (error) {
    console.error("Error removing member:", error);
    res.status(500).json({ 
      success: false,
      message: "Failed to remove member" 
    });
  }
};

// Admin Management
const promoteToAdmin = async (req, res) => {
  try {
    const group = await Group.findById(req.params.groupId);
    
    if (!group) {
      return res.status(404).json({ 
        success: false,
        message: "Group not found" 
      });
    }

    // // Allow promote if user is group admin or system admin
    // if (!isGroupAdmin(group, req.user._id) && req.user.role !== 'admin') {
    //   return res.status(403).json({ 
    //     success: false,
    //     message: "Only admins can promote members" 
    //   });
    // }

    // // Check if user is already admin
    // if (isGroupAdmin(group, req.params.userId)) {
    //   return res.status(400).json({ 
    //     success: false,
    //     message: "User is already an admin" 
    //   });
    // }

    // Check if user is a member
    // if (!isGroupMember(group, req.params.userId)) {
    //   return res.status(400).json({ 
    //     success: false,
    //     message: "User is not a group member" 
    //   });
    // }

    group.admins.push(req.params.userId);
    await group.save();

    res.status(200).json({ 
      success: true,
      message: "User promoted to admin successfully" 
    });
  } catch (error) {
    console.error("Error promoting to admin:", error);
    res.status(500).json({ 
      success: false,
      message: "Failed to promote user" 
    });
  }
};

const demoteAdmin = async (req, res) => {
  try {
    const group = await Group.findById(req.params.groupId);
    
    if (!group) {
      return res.status(404).json({ 
        success: false,
        message: "Group not found" 
      });
    }

    // // Allow demote if user is group admin or system admin
    // if (!isGroupAdmin(group, req.user._id) && req.user.role !== 'admin') {
    //   return res.status(403).json({ 
    //     success: false,
    //     message: "Only admins can demote members" 
    //   });
    // }

    // // Check if user is actually an admin
    // if (!isGroupAdmin(group, req.params.userId)) {
    //   return res.status(400).json({ 
    //     success: false,
    //     message: "User is not an admin" 
    //   });
    // }

    // Cannot demote yourself
    if (req.params.userId === req.user._id.toString()) {
      return res.status(400).json({ 
        success: false,
        message: "You cannot demote yourself" 
      });
    }

    group.admins = group.admins.filter(
      adminId => adminId.toString() !== req.params.userId
    );
    await group.save();

    res.status(200).json({ 
      success: true,
      message: "User demoted successfully" 
    });
  } catch (error) {
    console.error("Error demoting admin:", error);
    res.status(500).json({ 
      success: false,
      message: "Failed to demote user" 
    });
  }
};

// Group Chat Operations
const getChatMessages = async (req, res) => {
  try {
    const group = await Group.findById(req.params.groupId);
    
    if (!group) {
      return res.status(404).json({ 
        success: false,
        message: "Group not found" 
      });
    }

    // Allow access if user is member or system admin
    // if (!isGroupMember(group, req.user._id) && req.user.role !== 'admin') {
    //   return res.status(403).json({ 
    //     success: false,
    //     message: "Access denied. Not a group member" 
    //   });
    // }

    const chat = await Chat.findOne({ group: group._id })
      .populate({
        path: "messages",
        options: { sort: { createdAt: -1 } },
        populate: [
          { path: "sender", select: "firstName lastName avatar" },
          { path: "replyTo", populate: { path: "sender", select: "firstName lastName" } }
        ]
      });

    res.status(200).json({ 
      success: true,
      messages: chat?.messages || [] 
    });
  } catch (error) {
    console.error("Error fetching chat messages:", error);
    res.status(500).json({ 
      success: false,
      message: "Failed to fetch messages" 
    });
  }
};

const sendMessage = async (req, res) => {
  try {
    const { content, replyTo } = req.body;
    const group = await Group.findById(req.params.groupId).populate("members.user");

    if (!group) {
      return res.status(404).json({
        success: false,
        message: "Group not found"
      });
    }

    // Ensure chat exists for the group
    if (!group.chat) {
      const participantIds = group.members.map(m => m.user._id);

      const newChat = new Chat({
        participants: participantIds,
        type: "group",
        groupName: group.name,
        groupDescription: group.description,
        groupAdmin: group.creator,
      });

      await newChat.save();

      group.chat = newChat._id;
      await group.save();
    }

    // Optional: Uncomment to enforce access control
    // const isMember = group.members.some(m => m.user.toString() === req.user._id.toString());
    // if (!isMember && req.user.role !== 'admin') {
    //   return res.status(403).json({
    //     success: false,
    //     message: "Access denied. Not a group member"
    //   });
    // }

    const member = group.members.find(
      m => m.user.toString() === req.user._id.toString()
    );

    // Check if user is muted (non-admins only)
    if (member && member.isMuted && req.user.role !== 'admin') {
      return res.status(403).json({
        success: false,
        message: "You are muted in this group"
      });
    }

    const message = new Message({
      chat: group.chat,
      sender: req.user._id,
      content,
      replyTo,
      attachments: req.files?.map(file => ({
        url: file.path,
        fileType: file.mimetype.split("/")[0],
        fileName: file.originalname
      }))
    });

    await message.save();

    // Update chat
    await Chat.findByIdAndUpdate(group.chat, {
      $push: { messages: message._id },
      lastMessage: message._id,
      lastActivity: Date.now()
    });

    const populatedMessage = await Message.populate(message, [
      { path: "sender", select: "firstName lastName avatar" },
      { path: "replyTo", populate: { path: "sender", select: "firstName lastName" } }
    ]);

    res.status(201).json({
      success: true,
      message: populatedMessage
    });
  } catch (error) {
    console.error("Error sending message:", error);
    res.status(500).json({
      success: false,
      message: "Failed to send message"
    });
  }
};

// Pinned Messages
const getPinnedMessages = async (req, res) => {
  try {
    const group = await Group.findById(req.params.groupId)
      .populate({
        path: "pinnedMessages.message",
        populate: {
          path: "sender",
          select: "firstName lastName avatar"
        }
      })
      .populate("pinnedMessages.pinnedBy", "firstName lastName");

    if (!group) {
      return res.status(404).json({ 
        success: false,
        message: "Group not found" 
      });
    }

    // Allow access if user is member or system admin
    // if (!isGroupMember(group, req.user._id) && req.user.role !== 'admin') {
    //   return res.status(403).json({ 
    //     success: false,
    //     message: "Access denied. Not a group member" 
    //   });
    // }

    res.status(200).json({ 
      success: true,
      pinnedMessages: group.pinnedMessages 
    });
  } catch (error) {
    console.error("Error fetching pinned messages:", error);
    res.status(500).json({ 
      success: false,
      message: "Failed to fetch pinned messages" 
    });
  }
};

const pinMessage = async (req, res) => {
  try {
    const group = await Group.findById(req.params.groupId);
    
    if (!group) {
      return res.status(404).json({ 
        success: false,
        message: "Group not found" 
      });
    }

    // // Allow pinning if user is group admin or system admin
    // if (!isGroupAdmin(group, req.user._id) && req.user.role !== 'admin') {
    //   return res.status(403).json({ 
    //     success: false,
    //     message: "Only admins can pin messages" 
    //   });
    // }

    const message = await Message.findOne({
      _id: req.params.messageId,
      chat: group.chat
    });

    if (!message) {
      return res.status(404).json({ 
        success: false,
        message: "Message not found in this group" 
      });
    }

    // Check if already pinned
    const alreadyPinned = group.pinnedMessages.some(
      pm => pm.message.toString() === req.params.messageId
    );

    if (alreadyPinned) {
      return res.status(400).json({ 
        success: false,
        message: "Message is already pinned" 
      });
    }

    group.pinnedMessages.push({ 
      message: message._id,
      pinnedBy: req.user._id,
      pinnedAt: Date.now()
    });
    await group.save();

    res.status(200).json({ 
      success: true,
      message: "Message pinned successfully" 
    });
  } catch (error) {
    console.error("Error pinning message:", error);
    res.status(500).json({ 
      success: false,
      message: "Failed to pin message" 
    });
  }
};

const unpinMessage = async (req, res) => {
  try {
    const group = await Group.findById(req.params.groupId);
    
    if (!group) {
      return res.status(404).json({ 
        success: false,
        message: "Group not found" 
      });
    }

    // // Allow unpinning if user is group admin or system admin
    // if (!isGroupAdmin(group, req.user._id) && req.user.role !== 'admin') {
    //   return res.status(403).json({ 
    //     success: false,
    //     message: "Only admins can unpin messages" 
    //   });
    // }

    const pinIndex = group.pinnedMessages.findIndex(
      pm => pm.message.toString() === req.params.messageId
    );

    if (pinIndex === -1) {
      return res.status(404).json({ 
        success: false,
        message: "Message is not pinned" 
      });
    }

    group.pinnedMessages.splice(pinIndex, 1);
    await group.save();

    res.status(200).json({ 
      success: true,
      message: "Message unpinned successfully" 
    });
  } catch (error) {
    console.error("Error unpinning message:", error);
    res.status(500).json({ 
      success: false,
      message: "Failed to unpin message" 
    });
  }
};

// Group Settings
const updateGroupSettings = async (req, res) => {
  try {
    const { settings } = req.body;
    const group = await Group.findById(req.params.groupId);
    
    if (!group) {
      return res.status(404).json({ 
        success: false,
        message: "Group not found" 
      });
    }

    // // Allow update if user is group admin or system admin
    // if (!isGroupAdmin(group, req.user._id) && req.user.role !== 'admin') {
    //   return res.status(403).json({ 
    //     success: false,
    //     message: "Only admins can update settings" 
    //   });
    // }

    // Update settings
    group.settings = {
      ...group.settings,
      ...settings
    };

    await group.save();

    res.status(200).json({ 
      success: true,
      settings: group.settings 
    });
  } catch (error) {
    console.error("Error updating group settings:", error);
    res.status(500).json({ 
      success: false,
      message: "Failed to update settings" 
    });
  }
};

const generateInviteLink = async (req, res) => {
  try {
    const group = await Group.findById(req.params.groupId);
    
    if (!group) {
      return res.status(404).json({ 
        success: false,
        message: "Group not found" 
      });
    }

    // // Allow generating link if user is group admin or system admin
    // if (!isGroupAdmin(group, req.user._id) && req.user.role !== 'admin') {
    //   return res.status(403).json({ 
    //     success: false,
    //     message: "Only admins can generate invite links" 
    //   });
    // }

    // Generate new invite link
    group.inviteLink = generateRandomString(32);
    group.inviteLinkExpires = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000); // Expires in 7 days
    await group.save();

    res.status(200).json({ 
      success: true,
      inviteLink: group.inviteLink,
      expiresAt: group.inviteLinkExpires
    });
  } catch (error) {
    console.error("Error generating invite link:", error);
    res.status(500).json({ 
      success: false,
      message: "Failed to generate invite link" 
    });
  }
};

// Notification Settings
const muteGroup = async (req, res) => {
  try {
    const group = await Group.findById(req.params.groupId);
    
    if (!group) {
      return res.status(404).json({ 
        success: false,
        message: "Group not found" 
      });
    }

    // Find member
    const member = group.members.find(
      m => m.user.toString() === req.user._id.toString()
    );

    if (!member) {
      return res.status(403).json({ 
        success: false,
        message: "You are not a member of this group" 
      });
    }

    // Mute the group
    member.isMuted = true;
    await group.save();

    res.status(200).json({ 
      success: true,
      message: "Group muted successfully" 
    });
  } catch (error) {
    console.error("Error muting group:", error);
    res.status(500).json({ 
      success: false,
      message: "Failed to mute group" 
    });
  }
};

const unmuteGroup = async (req, res) => {
  try {
    const group = await Group.findById(req.params.groupId);
    
    if (!group) {
      return res.status(404).json({ 
        success: false,
        message: "Group not found" 
      });
    }

    // Find member
    const member = group.members.find(
      m => m.user.toString() === req.user._id.toString()
    );

    if (!member) {
      return res.status(403).json({ 
        success: false,
        message: "You are not a member of this group" 
      });
    }

    // Unmute the group
    member.isMuted = false;
    await group.save();

    res.status(200).json({ 
      success: true,
      message: "Group unmuted successfully" 
    });
  } catch (error) {
    console.error("Error unmuting group:", error);
    res.status(500).json({ 
      success: false,
      message: "Failed to unmute group" 
    });
  }
};

// Export all controller functions
module.exports = {
  createGroup,
  getGroupDetails,
  updateGroup,
  deleteGroup,
  joinGroupViaLink,
  joinGroup,
  leaveGroup,
  addMember,
  removeMember,
  promoteToAdmin,
  demoteAdmin,
  getChatMessages,
  sendMessage,
  getPinnedMessages,
  pinMessage,
  unpinMessage,
  updateGroupSettings,
  generateInviteLink,
  muteGroup,
  unmuteGroup,
  getAllGroups,
  getGroupMembers
};