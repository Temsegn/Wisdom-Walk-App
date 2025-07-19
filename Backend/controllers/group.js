const Group = require("../models/group");
const Chat = require("../models/Chat");
const User = require("../models/User");
const Message = require("../models/Message");
const { generateRandomString } = require("../utils/helpers");
exports.createGroup = async (req, res) => {
  try {
    const { name, description, type } = req.body;
    const creator = req.user._id;

    if (!name || !type) {
      return res.status(400).json({
        success: false,
        message: "Group name and type are required"
      });
    }

    // Create the group first without chat reference
    const group = new Group({
      name,
      description,
      type,
      creator,
      admins: [creator],
      members: [{
        user: creator,
        role: "admin"
      }]
    });

    await group.save();

    // Then create chat
    const chat = new Chat({
      type: "group",
      group: group._id,
      participants: [creator],
      participantSettings: [{
        user: creator
      }]
    });

    await chat.save();

    // Update group with chat reference
    group.chat = chat._id;
    await group.save();

    res.status(201).json({
      success: true,
      group
    });

  } catch (error) {
    console.error("Error creating group:", error);
    res.status(500).json({
      success: false,
      message: error.message // Send actual error message
    });
  }
};
exports.getGroupDetails = async (req, res) => {
  try {
    const group = await Group.findById(req.params.groupId)
      .populate("creator", "firstName lastName avatar")
      .populate("members.user", "firstName lastName avatar")
      .populate("admins", "firstName lastName avatar")
      .populate({
        path: "pinnedMessages.message",
        populate: {
          path: "sender",
          select: "firstName lastName avatar",
        },
      });

    if (!group) {
      return res.status(404).json({
        success: false,
        message: "Group not found",
      });
    }

    res.status(200).json({
      success: true,
      group,
    });
  } catch (error) {
    console.error("Error fetching group details:", error);
    res.status(500).json({
      success: false,
      message: "Failed to fetch group details",
    });
  }
};

// ... (other controller methods for the routes above)

exports.sendMessage = async (req, res) => {
  try {
    const { groupId } = req.params;
    const { content, messageType, replyTo } = req.body;
    const sender = req.user._id;

    // Check if user is member of group
    const group = await Group.findById(groupId);
    if (!group || !group.isMember(sender)) {
      return res.status(403).json({
        success: false,
        message: "You are not a member of this group",
      });
    }

    // Check if user is muted
    const member = group.members.find(
      (m) => m.user.toString() === sender.toString()
    );
    if (member && member.isMuted) {
      return res.status(403).json({
        success: false,
        message: "You are muted in this group",
      });
    }

    // Create message
    const message = new Message({
      chat: group.chat,
      sender,
      content,
      messageType,
      replyTo,
      attachments: req.files?.map((file) => ({
        url: file.path,
        fileType: file.mimetype.split("/")[0],
        fileName: file.originalname,
      })),
    });

    await message.save();

    // Update chat last message and activity
    await Chat.findByIdAndUpdate(group.chat, {
      lastMessage: message._id,
      lastActivity: Date.now(),
    });

    // Populate message for response
    const populatedMessage = await Message.findById(message._id)
      .populate("sender", "firstName lastName avatar")
      .populate("replyTo");

    // TODO: Emit socket event for real-time update

    res.status(201).json({
      success: true,
      message: populatedMessage,
    });
  } catch (error) {
    console.error("Error sending message:", error);
    res.status(500).json({
      success: false,
      message: "Failed to send message",
    });
  }
};
exports.getChatMessages = async (req, res) => {
  try {
    const { groupId } = req.params;
    const chat = await Chat.findOne({ group: groupId })
      .populate({
        path: "messages",
        populate: {
          path: "sender",
          select: "firstName lastName avatar",
        },
      });

    if (!chat) {
      return res.status(404).json({
        success: false,
        message: "Chat not found",
      });
    }

    res.status(200).json({
      success: true,
      chat,
    });
  } catch (error) {
    console.error("Error fetching chat messages:", error);
    res.status(500).json({
      success: false,
      message: "Failed to fetch chat messages",
    });
  }
};
exports.getGroupMembers = async (req, res) => {
  try {
    const { groupId } = req.params;
    const group = await Group.findById(groupId)
      .populate("members.user", "firstName lastName avatar")
      .populate("admins", "firstName lastName avatar");     


    if (!group) {
      return res.status(404).json({
        success: false,
        message: "Group not found",
      });
    }

    res.status(200).json({
      success: true,
      members: group.members,
      admins: group.admins,
    });
  } catch (error) {
    console.error("Error fetching group members:", error);
    res.status(500).json({
      success: false,
      message: "Failed to fetch group members",
    });
  }
};

exports.joinGroup = async (req, res) => {
  try {
    const { groupId } = req.params;
    const userId = req.user._id;

    // Check if user is already a member
    const group = await Group.findById(groupId);
    if (!group) {
      return res.status(404).json({
        success: false,
        message: "Group not found",
      });
    }

    if (group.isMember(userId)) {
      return res.status(400).json({
        success: false,
        message: "You are already a member of this group",
      });
    }

    // Add user to group members
    group.members.push({ user: userId });
    await group.save();

    res.status(200).json({
      success: true,
      message: "Successfully joined the group",
    });
  } catch (error) {
    console.error("Error joining group:", error);
    res.status(500).json({
      success: false,
      message: "Failed to join group",
    });
  }
};
exports.leaveGroup = async (req, res) => {
  try {
    const { groupId } = req.params;
    const userId = req.user._id;
    const group = await Group.findById(groupId);

    if (!group) {
      return res.status(404).json({
        success: false,
        message: "Group not found",
      });
    }   
    // Check if user is a member    
    if (!group.isMember(userId)) {
      return res.status(400).json({
        success: false,
        message: "You are not a member of this group",
      });
    }

    // Remove user from group members
    group.members = group.members.filter(
      (member) => member.user.toString() !== userId.toString()
    );
    await group.save();

    res.status(200).json({
      success: true,
      message: "Successfully left the group",
    });
  } catch (error) {
    console.error("Error leaving group:", error);
    res.status(500).json({
      success: false,
      message: "Failed to leave group",
    });
  }
};
exports.joinGroupViaLink = async (req, res) => {
  try {
    const { inviteLink } = req.params;
    const userId = req.user._id;
    const group = await Group.findOne({ inviteLink });

    if (!group) {
      return res.status(404).json({
        success: false,
        message: "Group not found or invite link is invalid",
      });
    }
    // Check if user is already a member
    if (group.isMember(userId)) {
      return res.status(400).json({
        success: false,
        message: "You are already a member of this group",
      });
    }
    // Add user to group members
    group.members.push({ user: userId });
    await group.save();
    res.status(200).json({
      success: true,
      message: "Successfully joined the group via invite link",
    });
  } catch (error) {
    console.error("Error joining group via link:", error);
    res.status(500).json({
      success: false,
      message: "Failed to join group via invite link",
    });
  }
};
exports.deleteMessage = async (req, res) => {
  try {
    const { groupId, messageId } = req.params;
    const userId = req.user._id;

    const group = await Group.findById(groupId);
    if (!group) {
      return res.status(404).json({
        success: false,
        message: "Group not found",
      });
    }

    // Check if user is a member
    if (!group.isMember(userId)) {
      return res.status(400).json({
        success: false,
        message: "You are not a member of this group",
      });
    }

    // Find and delete the message
    const messageIndex = group.messages.findIndex(
      (msg) => msg._id.toString() === messageId.toString()
    );
    if (messageIndex === -1) {
      return res.status(404).json({
        success: false,
        message: "Message not found",
      });
    }

    group.messages.splice(messageIndex, 1);
    await group.save();

    res.status(200).json({
      success: true,
      message: "Message deleted successfully",
    });
  } catch (error) {
    console.error("Error deleting message:", error);
    res.status(500).json({
      success: false,
      message: "Failed to delete message",
    });
  }
};

exports.togglePinPost = async (req, res) => {
  try {
    const { groupId, postId } = req.params;
    const userId = req.user._id;    
    const group = await Group.findById(groupId);

    if (!group) {
      return res.status(404).json({
        success: false,
        message: "Group not found",
      });
    }

    // Check if user is a member
    if (!group.isMember(userId)) {
      return res.status(400).json({
        success: false,
        message: "You are not a member of this group",
      });
    }

    // Find the post
    const post = group.posts.find((p) => p._id.toString() === postId.toString());
    if (!post) {
      return res.status(404).json({
        success: false,
        message: "Post not found",
      });
    }

    // Toggle the pinned status
    post.isPinned = !post.isPinned;
    await group.save();

    res.status(200).json({
      success: true,
      message: `Post has been ${post.isPinned ? "pinned" : "unpinned"} successfully`,
    });
  } catch (error) {
    console.error("Error toggling pin post:", error);
    res.status(500).json({
      success: false,
      message: "Failed to toggle pin post",
    });
  }
};
exports.promoteToAdmin = async (req, res) => {
  try {
    const { groupId, userId } = req.params;
    const currentUserId = req.user._id; 
    const group = await Group.findBy
Id(groupId);
    if (!group) {
      return res.status(404).json({
        success: false,
        message: "Group not found",
      });
    }   
    // Check if current user is admin
    if (!group.isAdmin(currentUserId)) {
      return res.status(403).json({
        success: false,
        message: "You are not authorized to promote members",
      });
    }
    // Check if user is already an admin
    if (group.isAdmin(userId)) {
      return res.status(400).json({
        success: false,
        message: "User is already an admin",
      });
    }
    // Add user to admins
    group.admins.push(userId);
    await group.save();
    res.status(200).json({
      success: true,
      message: "User promoted to admin successfully",
    });
  } catch (error) {
    console.error("Error promoting to admin:", error);
    res.status(500).json({
      success: false,
      message: "Failed to promote user to admin",
    });
  } 
};
exports.demoteAdmin = async (req, res) => {
  try {
    const { groupId, userId } = req.params;
    const currentUserId = req.user._id; 
    const group = await Group.findById(groupId);
    if (!group) {
      return res.status(404).json({
        success: false,
        message: "Group not found",
      });
    }
    // Check if current user is admin
    if (!group.isAdmin(currentUserId)) {
      return res.status(403).json({
        success: false,
        message: "You are not authorized to demote members",
      });
    }
    // Check if user is already a member
    if (!group.isMember(userId)) {
      return res.status(400).json({
        success: false,
        message: "User is not a member",
      });
    }
    // Remove user from admins
    group.admins = group.admins.filter((admin) => admin.toString() !== userId.toString());
    await group.save();
    res.status(200).json({
      success: true,
      message: "User demoted from admin successfully",
    });
  } catch (error) {
    console.error("Error demoting admin:", error);
    res.status(500).json({
      success: false,
      message: "Failed to demote user from admin",
    });
  }
};

