const User = require("../models/User")
const Post = require("../models/Post")
const { formatUserResponse, getPaginationMeta } = require("../utils/helpers")
const { saveFile,deleteFile } = require("../utils/localStorageService")
const { saveVerificationDocument } = require("../utils/storageHelper")

// Get current user profile
const getProfile = async (req, res) => {
  try {
    console.log("Fetching profile for user:", req.user._id)
    const user = await User.findById(req.user._id).populate("joinedGroups.groupType")

    res.json({
      success: true,
      data: formatUserResponse(user),
    })
  } catch (error) {
    console.error("Get profile error:", error)
    res.status(500).json({
      success: false,
      message: "Failed to fetch profile",
      error: error.message,
    })
  }
}

// Update user profile
const updateProfile = async (req, res) => {
  try {
    const { firstName, lastName, bio, location, preferences } = req.body
    const userId = req.user._id

    const updateData = {}

    if (firstName) updateData.firstName = firstName
    if (lastName) updateData.lastName = lastName
    if (bio) updateData.bio = bio
    if (location) updateData.location = location
    if (preferences) updateData.preferences = { ...req.user.preferences, ...preferences }

    // Handle profile picture upload
    if (req.file) {
      const uploadResult = await saveFile(req.file.buffer, req.file.originalname, "profiles")
      updateData.profilePicture = uploadResult.url
    }

    const user = await User.findByIdAndUpdate(userId, updateData, { new: true, runValidators: true })

    res.json({
      success: true,
      message: "Profile updated successfully",
      data: formatUserResponse(user),
    })
  } catch (error) {
    console.error("Update profile error:", error)
    res.status(500).json({
      success: false,
      message: "Failed to update profile",
      error: error.message,
    })
  }
}

// Join a group
const joinGroup = async (req, res) => {
  try {
    const { groupType } = req.body
    const userId = req.user._id

    const validGroups = ["single", "marriage", "healing", "motherhood"]
    if (!validGroups.includes(groupType)) {
      return res.status(400).json({
        success: false,
        message: "Invalid group type",
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

    res.json({
      success: true,
      message: `Successfully joined ${groupType} group`,
      data: {
        joinedGroups: user.joinedGroups,
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

// Leave a group
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

    res.json({
      success: true,
      message: `Successfully left ${groupType} group`,
      data: {
        joinedGroups: user.joinedGroups,
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

// Get user's posts
const getUserPosts = async (req, res) => {
  try {
    const userId = req.params.userId || req.user._id
    const page = Number.parseInt(req.query.page) || 1
    const limit = Number.parseInt(req.query.limit) || 10
    const skip = (page - 1) * limit

    const posts = await Post.find({
      author: userId,
      isHidden: false,
      isPublished: true,
    })
      .populate("author", "firstName lastName profilePicture")
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit)

    const total = await Post.countDocuments({
      author: userId,
      isHidden: false,
      isPublished: true,
    })

    res.json({
      success: true,
      data: posts,
      pagination: getPaginationMeta(page, limit, total),
    })
  } catch (error) {
    console.error("Get user posts error:", error)
    res.status(500).json({
      success: false,
      message: "Failed to fetch user posts",
      error: error.message,
    })
  }
}
const searchUsers = async (req, res) => {
  try {
    const { q: query } = req.query;
    
    if (!query || query.trim().length === 0) {
      return res.json({
        success: true,
        data: [],
        message: "Empty search query"
      });
    }

    const searchCriteria = {
      $or: [
        { firstName: { $regex: query, $options: "i" } },
        { lastName: { $regex: query, $options: "i" } },
        { email: { $regex: query, $options: "i" } },
        { "location.city": { $regex: query, $options: "i" } },
        { "location.country": { $regex: query, $options: "i" } }
      ],
      isEmailVerified: true,
      isAdminVerified: true,
      status: "active"
    };

    const users = await User.find(searchCriteria)
      .select("firstName lastName email profilePicture location isOnline lastActive")
      .limit(50); // Limit results for performance

    res.json({
      success: true,
      data: users.map(user => ({
        id: user._id,
        firstName: user.firstName,
        lastName: user.lastName,
        email: user.email,
        avatarUrl: user.profilePicture,
        city: user.location?.city,
        country: user.location?.country,
        isOnline: user.isOnline,
        lastActive: user.lastActive
      }))
    });
  } catch (error) {
    console.error("Search error:", error);
    res.status(500).json({
      success: false,
      message: "Failed to search users"
    });
  }
};
const getRecentUsers = async (req, res) => {
  try {
    const currentUserId = req.user._id; // Get the authenticated user's ID
    const limit = Math.min(Number.parseInt(req.query.limit) || 20, 50); // Limit to max 50 users
    
    // Get recent users excluding the current user
    const users = await User.find({ 
      _id: { $ne: currentUserId }, // Exclude current user
      isEmailVerified: true,
      isAdminVerified: true,
      status: "active"
    })
    .sort({ 
      isOnline: -1, // Online users first
      lastActive: -1, // Then by most recently active
      createdAt: -1 // Finally by account creation date
    })
    .limit(limit)
    .select("firstName lastName email profilePicture isOnline lastActive city country")
    .lean(); // Convert to plain JS objects for better performance

    // Format response for Flutter app
    const formattedUsers = users.map(user => ({
      id: user._id,
      fullName: `${user.firstName} ${user.lastName}`,
      email: user.email,
      avatarUrl: user.profilePicture || null,
      isOnline: user.isOnline,
      lastActive: user.lastActive,
      location: user.city || user.country ? 
        `${user.city ? user.city + ', ' : ''}${user.country || ''}`.trim() : 
        null,
      initials: `${user.firstName?.charAt(0) || ''}${user.lastName?.charAt(0) || ''}`.toUpperCase()
    }));

    res.json({
      success: true,
      data: formattedUsers
    });
  } catch (error) {
    console.error("Get recent users error:", error);
    
    // More specific error messages
    let errorMessage = "Failed to get recent users";
    if (error.name === 'CastError') {
      errorMessage = "Invalid request parameters";
    } else if (error.name === 'MongoError') {
      errorMessage = "Database error occurred";
    }

    res.status(500).json({
      success: false,
      message: errorMessage,
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

// Get user by ID
const getUserById = async (req, res) => {
  try {
    const { userId } = req.params

    const user = await User.findById(userId).select(
      "firstName lastName profilePicture bio location joinedGroups createdAt",
    )

    if (!user) {
      return res.status(404).json({
        success: false,
        message: "User not found",
      })
    }

    if (!user.isEmailVerified || !user.isAdminVerified || user.status !== "active") {
      return res.status(404).json({
        success: false,
        message: "User not found",
      })
    }

    res.json({
      success: true,
      data: formatUserResponse(user),
    })
  } catch (error) {
    console.error("Get user by ID error:", error)
    res.status(500).json({
      success: false,
      message: "Failed to fetch user",
      error: error.message,
    })
  }
}

// Update user preferences
const updatePreferences = async (req, res) => {
  try {
    const { preferences } = req.body
    const userId = req.user._id

    const user = await User.findByIdAndUpdate(
      userId,
      {
        preferences: {
          ...req.user.preferences,
          ...preferences,
        },
      },
      { new: true },
    )

    res.json({
      success: true,
      message: "Preferences updated successfully",
      data: {
        preferences: user.preferences,
      },
    })
  } catch (error) {
    console.error("Update preferences error:", error)
    res.status(500).json({
      success: false,
      message: "Failed to update preferences",
      error: error.message,
    })
  }
}

// Delete user account
const deleteAccount = async (req, res) => {
  try {
    const userId = req.user._id
    const { password } = req.body

    // Verify password before deletion
    const user = await User.findById(userId).select("+password")
    if (!(await user.comparePassword(password))) {
      return res.status(401).json({
        success: false,
        message: "Invalid password",
      })
    }

    // Soft delete - mark as deleted instead of removing
    await User.findByIdAndDelete(userId)

    res.json({
      success: true,
      message: "Account deleted successfully",
    })
  } catch (error) {
    console.error("Delete account error:", error)
    res.status(500).json({
      success: false,
      message: "Failed to delete account",
      error: error.message,
    })
  }
}
// Get logged-in user's own posts
const getMyPosts = async (req, res) => {
  try {
    console.log("Fetching posts for user:", req.user);
    const userId = req.user._id;
    const posts = await Post.find({ author: userId }).sort({ createdAt: -1 });

    res.json({
      success: true,
      data: posts,
    });
  } catch (error) {
    console.error("Error fetching user's posts:", error);
    res.status(500).json({
      success: false,
      message: "Failed to retrieve posts",
      error: error.message,
    });
  }
};

const updateOnlineStatus = async (req, res) => {
  try {
    const userId = req.user._id;
    const { isOnline } = req.body;

    if (typeof isOnline !== "boolean") {
      return res.status(400).json({
        success: false,
        message: "isOnline must be a boolean",
      });
    }

    await User.findByIdAndUpdate(userId, {
      isOnline,
      lastActive: new Date(),
    });

    res.json({
      success: true,
      message: "Online status updated successfully",
    });
  } catch (error) {
    console.error("Update online status error:", error);
    res.status(500).json({
      success: false,
      message: "Failed to update online status",
      error: error.message,
    });
  }
};

const blockUser = async (req, res) => {
  try {
    const { userIdToBlock } = req.body;
    const userId = req.user._id;

    if (userIdToBlock === userId.toString()) {
      return res.status(400).json({
        success: false,
        message: "Cannot block yourself",
      });
    }

    const userToBlock = await User.findById(userIdToBlock);
    if (!userToBlock) {
      return res.status(404).json({
        success: false,
        message: "User not found",
      });
    }

    await User.findByIdAndUpdate(userId, {
      $addToSet: { blockedUsers: userIdToBlock },
    });
   


    res.json({
      success: true,
      message: "User blocked successfully",
    });
  } catch (error) {
    console.error("Block user error:", error);
    res.status(500).json({
      success: false,
      message: "Failed to block user",
      error: error.message,
    });
  }
};

const unblockUser = async (req, res) => {
  try {
    const { userIdToUnblock } = req.body;
    const userId = req.user._id;

    await User.findByIdAndUpdate(userId, {
      $pull: { blockedUsers: userIdToUnblock },
    });

    res.json({
      success: true,
      message: "User unblocked successfully",
    });
  } catch (error) {
    console.error("Unblock user error:", error);
    res.status(500).json({
      success: false,
      message: "Failed to unblock user",
      error: error.message,
    });
  }
};

const updateProfilePhoto = async (req, res) => {
  try {
    // Check if file is uploaded
    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'Profile photo is required for update',
      });
    }

    const userId = req.user.id; // From authentication middleware

    // Check if user exists
    const existingUser = await User.findById(userId);
    if (!existingUser) {
      return res.status(404).json({
        success: false,
        message: 'User not found',
      });
    }

    // Delete old profile picture if it exists
    if (existingUser.profilePicture) {
      const urlParts = existingUser.profilePicture.split('/');
      const filenameWithExt = urlParts[urlParts.length - 1];
      const publicId = `profile_photos/${userId}/${filenameWithExt.split('.')[0]}`;
      await deleteFile(publicId);
    }

    // Upload new profile picture using saveVerificationDocument
    const uploadedDoc = await saveVerificationDocument(
      req.file.buffer,
      userId,
      'profilePicture',
      req.file.originalname
    );

    // Update user document with new profile picture URL
    const updatedUser = await User.findByIdAndUpdate(
      userId,
      { profilePicture: uploadedDoc.url },
      { new: true }
    ).select('_id email firstName lastName profilePicture');

    res.status(200).json({
      success: true,
      message: 'Profile photo updated successfully',
      data: {
        user: {
          id: updatedUser._id,
          email: updatedUser.email,
          firstName: updatedUser.firstName,
          lastName: updatedUser.lastName,
        },
        profilePicture: updatedUser.profilePicture,
        updateTimestamp: new Date(),
      }
    });
  } catch (error) {
    console.error('Profile photo update error:', error);
    res.status(500).json({
      success: false,
      message: 'Profile photo update failed',
      error: error.message,
    });
  }
};

 
module.exports = {
  updateProfilePhoto,
  getProfile,
  updateProfile,
  joinGroup,
  leaveGroup,
  getUserPosts,
  searchUsers,
  getUserById,
  updatePreferences,
  deleteAccount,
  getMyPosts,
  updateOnlineStatus,
  blockUser,
  unblockUser,
  getRecentUsers
}
