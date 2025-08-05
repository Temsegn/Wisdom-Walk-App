const { Single, Marriage, Healing, Motherhood } = require("../models/GroupModels")
const User = require("../models/User")
const Message = require("../models/Message")
const Chat = require("../models/Chat")
const Notification = require("../models/Notification")
const { getPaginationMeta } = require("../utils/helpers")
const { saveMultipleFiles } = require("../utils/localStorageService")

// Helper function to determine file type
const getFileType = (fileName) => {
  const extension = fileName.split(".").pop().toLowerCase()
  const imageTypes = ["jpg", "jpeg", "png", "gif", "webp"]
  const videoTypes = ["mp4", "avi", "mov", "wmv"]
  const audioTypes = ["mp3", "wav", "ogg"]
  const documentTypes = ["pdf", "doc", "docx", "txt"]

  if (imageTypes.includes(extension)) return "image"
  if (videoTypes.includes(extension)) return "video"
  if (audioTypes.includes(extension)) return "audio"
  if (documentTypes.includes(extension)) return "document"
  return "file"
}

// Helper function to get group description
const getGroupDescription = (groupType) => {
  const descriptions = {
    single: "A community for single individuals to share experiences and support.",
    marriage: "A community for married couples to share experiences and support.",
    healing: "A community for individuals seeking healing and support.",
    motherhood: "A community for mothers to share experiences and support.",
  }
  return descriptions[groupType] || "No description available."
}

// Helper function to get group chat model
const getGroupChatModel = (groupType) => {
  return Chat
}

// Get group model by type (for posts)
const getGroupModel = (groupType) => {
  const models = {
    single: Single,
    marriage: Marriage,
    healing: Healing,
    motherhood: Motherhood,
  }
  return models[groupType]
}

// ===== GROUP MEMBERSHIP FUNCTIONS =====

// Get user's joined groups
const getUserGroups = async (req, res) => {
  try {
    const userId = req.user._id
    const user = await User.findById(userId).select("joinedGroups")

    const groupsWithStats = await Promise.all(
      user.joinedGroups.map(async (group) => {
        // Get member count for each group
        const memberCount = await User.countDocuments({
          "joinedGroups.groupType": group.groupType,
          isEmailVerified: true,
          isAdminVerified: true,
          status: "active",
        })

        // Get user's active chats in this group
        const activeChats = await Chat.countDocuments({
          type: "group",
          "groupInfo.groupType": group.groupType,
          participants: userId,
          isActive: true,
        })

        return {
          groupType: group.groupType,
          joinedAt: group.joinedAt,
          isAdmin: group.isAdmin,
          memberCount,
          activeChats,
        }
      }),
    )

    res.json({
      success: true,
      data: {
        groups: groupsWithStats,
        totalGroups: groupsWithStats.length,
      },
    })
  } catch (error) {
    console.error("Get user groups error:", error)
    res.status(500).json({
      success: false,
      message: "Failed to fetch user groups",
      error: error.message,
    })
  }
}
// Get all available groups for users to join
const getAvailableGroups = async (req, res) => {
  try {
    // Fetch distinct group types (assuming groups are defined by groupType)
    const distinctGroupTypes = await User.distinct("joinedGroups.groupType")

    const groups = await Promise.all(
      distinctGroupTypes.map(async (groupType) => {
        // Get member count for each group
        const memberCount = await User.countDocuments({
          "joinedGroups.groupType": groupType,
          isEmailVerified: true,
          isAdminVerified: true,
          status: "active",
        })

        // Get group creation date (assume first user who joined created it)
        const groupCreator = await User.findOne({
          "joinedGroups.groupType": groupType,
        }).select("joinedGroups.$")

        return {
          groupType,
          createdAt: groupCreator?.joinedGroups[0]?.joinedAt || null,
          memberCount,
        }
      })
    )

    res.json({
      success: true,
      data: {
        groups,
        totalGroups: groups.length,
      },
    })
  } catch (error) {
    console.error("Get available groups error:", error)
    res.status(500).json({
      success: false,
      message: "Failed to fetch available groups",
      error: error.message,
    })
  }
}

// Join a group type
const joinGroup = async (req, res) => {
  try {
    const { groupType } = req.body 
    const userId = req.user._id

    const validGroups = ["single", "marriage", "healing", "motherhood"]
    if (!validGroups.includes(groupType)) {
      return res.status(400).json({
        success: false,
        message: "Invalid group type",
        validGroups,
      })
    }

    const user = await User.findById(userId)

    // Check if already in group
    const existingGroup = user.joinedGroups.find((g) => g.groupType === groupType)
    if (existingGroup) {
      return res.status(400).json({
        success: false,
        message: "You are already a member of this group",
      })
    }

    user.joinedGroups.push({
      groupType,
      joinedAt: new Date(),
    })

    await user.save()

    // Create or join the main group chat
    let groupChat = await Chat.findOne({
      type: "group",
      "groupInfo.groupType": groupType,
      "groupInfo.isMainChat": true,
    })

    if (!groupChat) {
      // Create main group chat if it doesn't exist
      groupChat = new Chat({
        type: "group",
        groupName: `${groupType.charAt(0).toUpperCase() + groupType.slice(1)} Main Chat`,
        groupDescription: `Main chat room for ${groupType} group members`,
        participants: [userId],
        groupInfo: {
          groupType,
          isMainChat: true,
        },
        participantSettings: [
          {
            user: userId,
            joinedAt: new Date(),
          },
        ],
      })
    } else {
      // Add user to existing main chat if not already there
      const isAlreadyParticipant = groupChat.participants.includes(userId)
      if (!isAlreadyParticipant) {
        groupChat.participants.push(userId)
        groupChat.participantSettings.push({
          user: userId,
          joinedAt: new Date(),
        })
      }
    }

    await groupChat.save()

    // Get updated member count
    const memberCount = await User.countDocuments({
      "joinedGroups.groupType": groupType,
      isEmailVerified: true,
      isAdminVerified: true,
      status: "active",
    })

    res.json({
      success: true,
      message: `Successfully joined ${groupType} group`,
      data: {
        groupType,
        joinedAt: new Date(),
        memberCount,
        mainChatId: groupChat._id,
      },
    })
  } catch (error) {
    console.error("Join group error:", error)
    res.status(500).json({
      success: false,
      message: "Failed to join group",
      error: error.message,
    })
  }
}

// Leave a group type
const leaveGroup = async (req, res) => {
  try {
    const { groupType } = req.body
    const userId = req.user._id

    const user = await User.findById(userId)

    // Find and remove the group
    const groupIndex = user.joinedGroups.findIndex((g) => g.groupType === groupType)
    if (groupIndex === -1) {
      return res.status(400).json({
        success: false,
        message: "You are not a member of this group",
      })
    }

    user.joinedGroups.splice(groupIndex, 1)
    await user.save()

    // Remove user from all group chats
    await Chat.updateMany(
      {
        type: "group",
        "groupInfo.groupType": groupType,
        participants: userId,
      },
      {
        $pull: {
          participants: userId,
          participantSettings: { user: userId },
        },
      },
    )

    res.json({
      success: true,
      message: `Successfully left ${groupType} group`,
      data: {
        groupType,
        leftAt: new Date(),
      },
    })
  } catch (error) {
    console.error("Leave group error:", error)
    res.status(500).json({
      success: false,
      message: "Failed to leave group",
      error: error.message,
    })
  }
}

// Get group information
const getGroupInfo = async (req, res) => {
  try {
    const { groupType } = req.params
    const userId = req.user._id

    // Check if user is member of the group
    const userInGroup = req.user.joinedGroups.some((group) => group.groupType === groupType)
    if (!userInGroup) {
      return res.status(403).json({
        success: false,
        message: `You must be a member of the ${groupType} group to view its information`,
      })
    }

    const GroupModel = getGroupModel(groupType)
    if (!GroupModel) {
      return res.status(400).json({
        success: false,
        message: "Invalid group type",
      })
    }

    // Get group statistics
    const memberCount = await User.countDocuments({
      "joinedGroups.groupType": groupType,
      isEmailVerified: true,
      isAdminVerified: true,
      status: "active",
    })

    const postCount = await GroupModel.countDocuments()

    // Get recent activity (posts in last 7 days)
    const weekAgo = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000)
    const recentPosts = await GroupModel.countDocuments({
      createdAt: { $gte: weekAgo },
    })

    // Get user's role in group
    const userGroup = req.user.joinedGroups.find((group) => group.groupType === groupType)

    const groupInfo = {
      groupType,
      memberCount,
      postCount,
      recentActivity: recentPosts,
      userRole: userGroup.isAdmin ? "admin" : "member",
      joinedAt: userGroup.joinedAt,
      description: getGroupDescription(groupType),
    }

    res.json({
      success: true,
      data: groupInfo,
    })
  } catch (error) {
    console.error("Get group info error:", error)
    res.status(500).json({
      success: false,
      message: "Failed to fetch group information",
      error: error.message,
    })
  }
}

// ===== GROUP POSTS FUNCTIONS =====

// Get group posts
const getGroupPosts = async (req, res) => {
  try {
    const { groupType } = req.params
    const { page = 1, limit = 10, topicType, sortBy = "recent" } = req.query
    const userId = req.user._id
    const skip = (page - 1) * limit

    // Check if user is member of the group
    const userInGroup = req.user.joinedGroups.some((group) => group.groupType === groupType)
    if (!userInGroup) {
      return res.status(403).json({
        success: false,
        message: `You must be a member of the ${groupType} group to view its posts`,
      })
    }

    const GroupModel = getGroupModel(groupType)
    if (!GroupModel) {
      return res.status(400).json({
        success: false,
        message: "Invalid group type",
      })
    }

    const filter = {}
    if (topicType) {
      filter.topicType = topicType
    }

    // Determine sort order
    let sortOptions = { createdAt: -1 } // Default: recent first
    if (sortBy === "pinned") {
      sortOptions = { isPinned: -1, createdAt: -1 }
    } else if (sortBy === "popular") {
      sortOptions = { likesCount: -1, createdAt: -1 }
    }

    const posts = await GroupModel.find(filter)
      .populate("author", "firstName lastName profilePicture")
      .populate("comments")
      .sort(sortOptions)
      .skip(skip)
      .limit(Number.parseInt(limit))

    const total = await GroupModel.countDocuments(filter)

    // Format posts (hide author info for anonymous posts)
    const formattedPosts = posts.map((post) => {
      const postObj = post.toObject()
      if (postObj.isAnonymous) {
        postObj.author = {
          firstName: "Anonymous",
          lastName: "Sister",
          profilePicture: null,
        }
      }
      // Add engagement metrics
      postObj.likesCount = postObj.likes?.length || 0
      postObj.commentsCount = postObj.comments?.length || 0
      return postObj
    })

    res.json({
      success: true,
      data: formattedPosts,
      pagination: getPaginationMeta(Number.parseInt(page), Number.parseInt(limit), total),
      filters: {
        groupType,
        topicType,
        sortBy,
      },
    })
  } catch (error) {
    console.error("Get group posts error:", error)
    res.status(500).json({
      success: false,
      message: "Failed to fetch group posts",
      error: error.message,
    })
  }
}

// Create group post
const createGroupPost = async (req, res) => {
  try {
    const { groupType } = req.params
    const userId = req.user._id

    // Check if user is member of the group
    const userInGroup = req.user.joinedGroups.some((group) => group.groupType === groupType)
    if (!userInGroup) {
      return res.status(403).json({
        success: false,
        message: `You must be a member of the ${groupType} group to post`,
      })
    }

    const GroupModel = getGroupModel(groupType)
    if (!GroupModel) {
      return res.status(400).json({
        success: false,
        message: "Invalid group type",
      })
    }

    const postData = {
      ...req.body,
      author: userId,
    }

    const post = new GroupModel(postData)
    await post.save()

    await post.populate("author", "firstName lastName profilePicture")

    res.status(201).json({
      success: true,
      message: "Group post created successfully",
      data: post,
    })
  } catch (error) {
    console.error("Create group post error:", error)
    res.status(500).json({
      success: false,
      message: "Failed to create group post",
      error: error.message,
    })
  }
}

// Get group members
const getGroupMembers = async (req, res) => {
  try {
    const { groupType } = req.params
    const { page = 1, limit = 20 } = req.query
    const userId = req.user._id
    const skip = (page - 1) * limit
  
    // Check if user is member of the group
    const userInGroup = req.user.joinedGroups.some((group) => group.groupType === groupType)
    if (!userInGroup) {
      return res.status(403).json({
        success: false,
        message: `You must be a member of the ${groupType} group to view members`,
      })
    }

    const filter = {
      "joinedGroups.groupType": groupType,
      isEmailVerified: true,
      isAdminVerified: true,
      status: "active",
    }

    const members = await User.find(filter)
      .select("firstName lastName profilePicture bio location joinedGroups lastActive")
      .skip(skip)
      .limit(Number.parseInt(limit))

    const total = await User.countDocuments(filter)

    // Add group-specific info
    const formattedMembers = members.map((member) => {
      const memberObj = member.toObject()
      const groupInfo = member.joinedGroups.find((group) => group.groupType === groupType)
      memberObj.groupInfo = {
        joinedAt: groupInfo.joinedAt,
        isAdmin: groupInfo.isAdmin,
        role: groupInfo.isAdmin ? "admin" : "member",
      }
      return memberObj
    })

    res.json({
      success: true,
      data: formattedMembers,
      pagination: getPaginationMeta(Number.parseInt(page), Number.parseInt(limit), total),
      groupType,
    })
  } catch (error) {
    console.error("Get group members error:", error)
    res.status(500).json({
      success: false,
      message: "Failed to fetch group members",
      error: error.message,
    })
  }
}

// Get group statistics
const getGroupStats = async (req, res) => {
  try {
    const { groupType } = req.params
    const userId = req.user._id

    // Check if user is member of the group
    const userInGroup = req.user.joinedGroups.some((group) => group.groupType === groupType)
    if (!userInGroup) {
      return res.status(403).json({
        success: false,
        message: `You must be a member of the ${groupType} group to view statistics`,
      })
    }

    const GroupModel = getGroupModel(groupType)
    if (!GroupModel) {
      return res.status(400).json({
        success: false,
        message: "Invalid group type",
      })
    }

    // Get member count
    const memberCount = await User.countDocuments({
      "joinedGroups.groupType": groupType,
      isEmailVerified: true,
      isAdminVerified: true,
      status: "active",
    })

    // Get admin count
    const adminCount = await User.countDocuments({
      "joinedGroups.groupType": groupType,
      "joinedGroups.isAdmin": true,
      isEmailVerified: true,
      isAdminVerified: true,
      status: "active",
    })

    // Get post count
    const postCount = await GroupModel.countDocuments()

    // Get recent activity (posts in last 7 days)
    const weekAgo = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000)
    const recentPosts = await GroupModel.countDocuments({
      createdAt: { $gte: weekAgo },
    })

    // Get top contributors (users with most posts)
    const topContributors = await GroupModel.aggregate([
      { $match: { isAnonymous: false } },
      { $group: { _id: "$author", postCount: { $sum: 1 } } },
      { $sort: { postCount: -1 } },
      { $limit: 5 },
      {
        $lookup: {
          from: "users",
          localField: "_id",
          foreignField: "_id",
          as: "user",
        },
      },
      { $unwind: "$user" },
      {
        $project: {
          postCount: 1,
          "user.firstName": 1,
          "user.lastName": 1,
          "user.profilePicture": 1,
        },
      },
    ])

    // Get growth stats (new members in last 30 days)
    const monthAgo = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000)
    const newMembersThisMonth = await User.countDocuments({
      "joinedGroups.groupType": groupType,
      "joinedGroups.joinedAt": { $gte: monthAgo },
      isEmailVerified: true,
      isAdminVerified: true,
      status: "active",
    })

    res.json({
      success: true,
      data: {
        memberCount,
        adminCount,
        postCount,
        recentPosts,
        newMembersThisMonth,
        topContributors,
        groupType,
        lastUpdated: new Date(),
      },
    })
  } catch (error) {
    console.error("Get group stats error:", error)
    res.status(500).json({
      success: false,
      message: "Failed to fetch group statistics",
      error: error.message,
    })
  }
}

// Pin/unpin group post (admin only)
const togglePinPost = async (req, res) => {
  try {
    const { groupType, postId } = req.params
    const userId = req.user._id

    // Check if user is member of the group
    const userInGroup = req.user.joinedGroups.some((group) => group.groupType === groupType)
    if (!userInGroup) {
      return res.status(403).json({
        success: false,
        message: `You must be a member of the ${groupType} group`,
      })
    }

    const GroupModel = getGroupModel(groupType)
    if (!GroupModel) {
      return res.status(400).json({
        success: false,
        message: "Invalid group type",
      })
    }

    const post = await GroupModel.findById(postId)
    if (!post) {
      return res.status(404).json({
        success: false,
        message: "Post not found",
      })
    }

    post.isPinned = !post.isPinned
    await post.save()

    res.json({
      success: true,
      message: post.isPinned ? "Post pinned successfully" : "Post unpinned successfully",
      data: {
        postId,
        isPinned: post.isPinned,
        updatedAt: new Date(),
      },
    })
  } catch (error) {
    console.error("Toggle pin post error:", error)
    res.status(500).json({
      success: false,
      message: "Failed to toggle pin status",
      error: error.message,
    })
  }
}

// ===== GROUP CHAT FUNCTIONS =====

// Get all chats user has joined in this group
const getJoinedChats = async (req, res) => {
  try {
    const { groupType } = req.params
    const { page = 1, limit = 20 } = req.query
    const userId = req.user._id
    const skip = (page - 1) * limit

    // Check if user is member of the group
    const userInGroup = req.user.joinedGroups.some((group) => group.groupType === groupType)
    if (!userInGroup) {
      return res.status(403).json({
        success: false,
        message: `You must be a member of the ${groupType} group to view chats`,
      })
    }

    const chats = await Chat.find({
      type: "group",
      "groupInfo.groupType": groupType,
      participants: userId,
      isActive: true,
    })
      .populate("participants", "firstName lastName profilePicture lastActive")
      .populate("lastMessage")
      .sort({ lastActivity: -1 })
      .skip(skip)
      .limit(Number.parseInt(limit))

    const total = await Chat.countDocuments({
      type: "group",
      "groupInfo.groupType": groupType,
      participants: userId,
      isActive: true,
    })

    // Format chats with unread count
    const formattedChats = await Promise.all(
      chats.map(async (chat) => {
        const chatObj = chat.toObject()

        // Get unread messages count
        const userSettings = chat.participantSettings.find((setting) => setting.user.toString() === userId.toString())
        const lastReadMessage = userSettings?.lastReadMessage

        let unreadCount = 0
        if (lastReadMessage) {
          unreadCount = await Message.countDocuments({
            chat: chat._id,
            _id: { $gt: lastReadMessage },
            sender: { $ne: userId },
          })
        } else {
          unreadCount = await Message.countDocuments({
            chat: chat._id,
            sender: { $ne: userId },
          })
        }

        chatObj.unreadCount = unreadCount
        chatObj.participantsCount = chat.participants.length

        return chatObj
      }),
    )

    res.json({
      success: true,
      data: formattedChats,
      pagination: getPaginationMeta(Number.parseInt(page), Number.parseInt(limit), total),
      groupType,
    })
  } catch (error) {
    console.error("Get joined chats error:", error)
    res.status(500).json({
      success: false,
      message: "Failed to fetch joined chats",
      error: error.message,
    })
  }
}

// Get messages in group chat
const getChatMessages = async (req, res) => {
  try {
    const { groupType, chatId } = req.params
    const { page = 1, limit = 50, before } = req.query
    const userId = req.user._id
    const skip = (page - 1) * limit

    // Check if user is member of the group
    const userInGroup = req.user.joinedGroups.some((group) => group.groupType === groupType)
    if (!userInGroup) {
      return res.status(403).json({
        success: false,
        message: `You must be a member of the ${groupType} group`,
      })
    }

    const chat = await Chat.findOne({
      _id: chatId,
      type: "group",
      "groupInfo.groupType": groupType,
      participants: userId,
    })

    if (!chat) {
      return res.status(404).json({
        success: false,
        message: "Chat not found or access denied",
      })
    }

    // Build message filter
    const messageFilter = {
      chat: chatId,
      isDeleted: false,
    }

    // Add before filter for pagination
    if (before) {
      messageFilter.createdAt = { $lt: new Date(before) }
    }

    const messages = await Message.find(messageFilter)
      .populate("sender", "firstName lastName profilePicture")
      .populate("replyTo", "content sender")
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(Number.parseInt(limit))

    const total = await Message.countDocuments(messageFilter)

    // Mark messages as read for this user
    const unreadMessages = await Message.find({
      chat: chatId,
      sender: { $ne: userId },
      "readBy.user": { $ne: userId },
    })

    if (unreadMessages.length > 0) {
      await Message.updateMany(
        {
          chat: chatId,
          sender: { $ne: userId },
          "readBy.user": { $ne: userId },
        },
        {
          $push: {
            readBy: {
              user: userId,
              readAt: new Date(),
            },
          },
        },
      )

      // Update user's last read message
      await Chat.updateOne(
        { _id: chatId, "participantSettings.user": userId },
        {
          $set: {
            "participantSettings.$.lastReadMessage": messages[0]?._id,
          },
        },
      )
    }

    res.json({
      success: true,
      data: messages.reverse(), // Reverse to show oldest first
      pagination: getPaginationMeta(Number.parseInt(page), Number.parseInt(limit), total),
      chatInfo: {
        chatId,
        groupType,
        chatName: chat.groupName,
        participantsCount: chat.participants.length,
      },
    })
  } catch (error) {
    console.error("Get chat messages error:", error)
    res.status(500).json({
      success: false,
      message: "Failed to fetch chat messages",
      error: error.message,
    })
  }
}

// Send message to group chat (with file sharing)
const sendMessage = async (req, res) => {
  try {
    const { groupType, chatId } = req.params
    const { content, messageType = "text", scripture, replyToId } = req.body
    const userId = req.user._id

    // Check if user is member of the group
    const userInGroup = req.user.joinedGroups.some((group) => group.groupType === groupType)
    if (!userInGroup) {
      return res.status(403).json({
        success: false,
        message: `You must be a member of the ${groupType} group`,
      })
    }

    const chat = await Chat.findOne({
      _id: chatId,
      type: "group",
      "groupInfo.groupType": groupType,
      participants: userId,
    })

    if (!chat) {
      return res.status(404).json({
        success: false,
        message: "Chat not found or access denied",
      })
    }

    const messageData = {
      chat: chatId,
      sender: userId,
      content,
      messageType,
    }

    // Handle scripture message
    if (messageType === "scripture" && scripture) {
      messageData.scripture = scripture
    }

    // Handle reply
    if (replyToId) {
      const replyToMessage = await Message.findById(replyToId)
      if (replyToMessage && replyToMessage.chat.toString() === chatId) {
        messageData.replyTo = replyToId
      }
    }

    // Handle file attachments (file sharing)
    if (req.files && req.files.length > 0) {
      const uploadResults = await saveMultipleFiles(req.files, "messages")
      messageData.attachments = uploadResults.map((result) => ({
        type: result.url,
        fileType: getFileType(result.fileName),
        fileName: result.fileName,
      }))
      messageData.messageType = "file"
    }

    const message = new Message(messageData)
    await message.save()

    // Update chat's last message and activity
    chat.lastMessage = message._id
    chat.lastActivity = new Date()
    await chat.save()

    // Populate message data
    await message.populate("sender", "firstName lastName profilePicture")
    if (message.replyTo) {
      await message.populate("replyTo", "content sender")
    }

    res.status(201).json({
      success: true,
      message: "Message sent successfully",
      data: message,
    })
  } catch (error) {
    console.error("Send message error:", error)
    res.status(500).json({
      success: false,
      message: "Failed to send message",
      error: error.message,
    })
  }
}

// React to message
const addReaction = async (req, res) => {
  try {
    const { groupType, chatId, messageId } = req.params
    const { emoji } = req.body
    const userId = req.user._id

    // Check if user is member of the group
    const userInGroup = req.user.joinedGroups.some((group) => group.groupType === groupType)
    if (!userInGroup) {
      return res.status(403).json({
        success: false,
        message: `You must be a member of the ${groupType} group`,
      })
    }

    const chat = await Chat.findOne({
      _id: chatId,
      type: "group",
      "groupInfo.groupType": groupType,
      participants: userId,
    })

    if (!chat) {
      return res.status(404).json({
        success: false,
        message: "Chat not found or access denied",
      })
    }

    const message = await Message.findById(messageId)
    if (!message || message.chat.toString() !== chatId) {
      return res.status(404).json({
        success: false,
        message: "Message not found",
      })
    }

    // Check if user already reacted with this emoji
    const existingReaction = message.reactions.find(
      (reaction) => reaction.user.toString() === userId.toString() && reaction.emoji === emoji,
    )

    if (existingReaction) {
      // Remove reaction
      message.reactions = message.reactions.filter(
        (reaction) => !(reaction.user.toString() === userId.toString() && reaction.emoji === emoji),
      )
    } else {
      // Add reaction
      message.reactions.push({
        user: userId,
        emoji,
      })
    }

    await message.save()

    res.json({
      success: true,
      message: existingReaction ? "Reaction removed" : "Reaction added",
      data: {
        messageId,
        reactions: message.reactions,
        reactionCount: message.reactions.length,
      },
    })
  } catch (error) {
    console.error("Add reaction error:", error)
    res.status(500).json({
      success: false,
      message: "Failed to add reaction",
      error: error.message,
    })
  }
}

// Delete own message
const deleteMessage = async (req, res) => {
  try {
    const { groupType, chatId, messageId } = req.params
    const userId = req.user._id

    // Check if user is member of the group
    const userInGroup = req.user.joinedGroups.some((group) => group.groupType === groupType)
    if (!userInGroup) {
      return res.status(403).json({
        success: false,
        message: `You must be a member of the ${groupType} group`,
      })
    }

    const chat = await Chat.findOne({
      _id: chatId,
      type: "group",
      "groupInfo.groupType": groupType,
      participants: userId,
    })

    if (!chat) {
      return res.status(404).json({
        success: false,
        message: "Chat not found or access denied",
      })
    }

    const message = await Message.findById(messageId)
    if (!message || message.chat.toString() !== chatId) {
      return res.status(404).json({
        success: false,
        message: "Message not found",
      })
    }

    // Check if user owns the message
    if (message.sender.toString() !== userId.toString()) {
      return res.status(403).json({
        success: false,
        message: "You can only delete your own messages",
      })
    }

    message.isDeleted = true
    message.deletedAt = new Date()
    await message.save()

    res.json({
      success: true,
      message: "Message deleted successfully",
      data: {
        messageId,
        deletedAt: message.deletedAt,
      },
    })
  } catch (error) {
    console.error("Delete message error:", error)
    res.status(500).json({
      success: false,
      message: "Failed to delete message",
      error: error.message,
    })
  }
}

// ===== GROUP CHAT PARTICIPANTS FUNCTIONS =====

// Get chat participants
const getChatParticipants = async (req, res) => {
  try {
    const { groupType, chatId } = req.params
    const { page = 1, limit = 20 } = req.query
    const userId = req.user._id
    const skip = (page - 1) * limit

    const GroupChatModel = getGroupChatModel(groupType)
    const groupChat = await GroupChatModel.findById(chatId).populate(
      "participants.user",
      "firstName lastName profilePicture lastActive",
    )

    if (!groupChat) {
      return res.status(404).json({
        success: false,
        message: "Group chat not found",
      })
    }

    // Check if user can access this chat
    const userParticipant = groupChat.participants.find((p) => p.user._id.toString() === userId.toString())
    if (groupChat.isPrivate && !userParticipant) {
      return res.status(403).json({
        success: false,
        message: "Access denied",
      })
    }

    // Paginate participants
    const participants = groupChat.participants.slice(skip, skip + Number.parseInt(limit))
    const total = groupChat.participants.length

    res.json({
      success: true,
      data: participants,
      pagination: getPaginationMeta(Number.parseInt(page), Number.parseInt(limit), total),
    })
  } catch (error) {
    console.error("Get chat participants error:", error)
    res.status(500).json({
      success: false,
      message: "Failed to fetch chat participants",
      error: error.message,
    })
  }
}

// Add participant to chat (admin only)
const addParticipant = async (req, res) => {
  try {
    const { groupType, chatId } = req.params
    const { userId: targetUserId } = req.body
    const userId = req.user._id

    const GroupChatModel = getGroupChatModel(groupType)
    const groupChat = await GroupChatModel.findById(chatId)

    if (!groupChat) {
      return res.status(404).json({
        success: false,
        message: "Group chat not found",
      })
    }

    // Check if user is admin of the chat
    const userParticipant = groupChat.participants.find((p) => p.user.toString() === userId.toString())
    if (!userParticipant || !userParticipant.isAdmin) {
      return res.status(403).json({
        success: false,
        message: "Admin access required",
      })
    }

    // Check if target user is member of the group type
    const targetUser = await User.findById(targetUserId)
    if (!targetUser) {
      return res.status(404).json({
        success: false,
        message: "User not found",
      })
    }

    const targetUserInGroup = targetUser.joinedGroups.some((group) => group.groupType === groupType)
    if (!targetUserInGroup) {
      return res.status(400).json({
        success: false,
        message: "User must be a member of the group to be added",
      })
    }

    // Check if user is already a participant
    const isAlreadyParticipant = groupChat.participants.some((p) => p.user.toString() === targetUserId.toString())
    if (isAlreadyParticipant) {
      return res.status(400).json({
        success: false,
        message: "User is already a member of this chat",
      })
    }

    // Add user to participants
    groupChat.participants.push({
      user: targetUserId,
      joinedAt: new Date(),
      isAdmin: false,
    })
    groupChat.participantsCount += 1

    await groupChat.save()

    res.json({
      success: true,
      message: "Participant added successfully",
      data: {
        participantsCount: groupChat.participantsCount,
      },
    })
  } catch (error) {
    console.error("Add participant error:", error)
    res.status(500).json({
      success: false,
      message: "Failed to add participant",
      error: error.message,
    })
  }
}

// Remove participant from chat (admin only)
const removeParticipant = async (req, res) => {
  try {
    const { groupType, chatId, userId: targetUserId } = req.params
    const userId = req.user._id

    const GroupChatModel = getGroupChatModel(groupType)
    const groupChat = await GroupChatModel.findById(chatId)

    if (!groupChat) {
      return res.status(404).json({
        success: false,
        message: "Group chat not found",
      })
    }

    // Check if user is admin of the chat
    const userParticipant = groupChat.participants.find((p) => p.user.toString() === userId.toString())
    if (!userParticipant || !userParticipant.isAdmin) {
      return res.status(403).json({
        success: false,
        message: "Admin access required",
      })
    }

    // Find and remove the participant
    const participantIndex = groupChat.participants.findIndex((p) => p.user.toString() === targetUserId.toString())
    if (participantIndex === -1) {
      return res.status(400).json({
        success: false,
        message: "User is not a member of this chat",
      })
    }

    groupChat.participants.splice(participantIndex, 1)
    groupChat.participantsCount -= 1

    await groupChat.save()

    res.json({
      success: true,
      message: "Participant removed successfully",
    })
  } catch (error) {
    console.error("Remove participant error:", error)
    res.status(500).json({
      success: false,
      message: "Failed to remove participant",
      error: error.message,
    })
  }
}

// Update participant role (admin only)
const updateParticipantRole = async (req, res) => {
  try {
    const { groupType, chatId, userId: targetUserId } = req.params
    const { isAdmin } = req.body
    const userId = req.user._id

    const GroupChatModel = getGroupChatModel(groupType)
    const groupChat = await GroupChatModel.findById(chatId)

    if (!groupChat) {
      return res.status(404).json({
        success: false,
        message: "Group chat not found",
      })
    }

    // Check if user is admin of the chat
    const userParticipant = groupChat.participants.find((p) => p.user.toString() === userId.toString())
    if (!userParticipant || !userParticipant.isAdmin) {
      return res.status(403).json({
        success: false,
        message: "Admin access required",
      })
    }

    // Find the participant to update
    const targetParticipant = groupChat.participants.find((p) => p.user.toString() === targetUserId.toString())
    if (!targetParticipant) {
      return res.status(400).json({
        success: false,
        message: "User is not a member of this chat",
      })
    }

    targetParticipant.isAdmin = isAdmin

    await groupChat.save()

    res.json({
      success: true,
      message: `Participant role updated to ${isAdmin ? "admin" : "member"}`,
      data: {
        userId: targetUserId,
        isAdmin,
      },
    })
  } catch (error) {
    console.error("Update participant role error:", error)
    res.status(500).json({
      success: false,
      message: "Failed to update participant role",
      error: error.message,
    })
  }
}

module.exports = {
  // Group membership
  getUserGroups,
  joinGroup,
  leaveGroup,
  getGroupMembers,

  // Group chats
  getJoinedChats,
  getChatMessages,
  sendMessage,
  addReaction,
  deleteMessage,

  // Group posts
  togglePinPost,
  getAvailableGroups
}
