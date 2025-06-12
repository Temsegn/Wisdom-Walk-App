const express = require("express")
const router = express.Router()
const userController = require("../controllers/userController")
const { authenticateToken } = require("../middleware/auth")
const { uploadSingle, handleUploadError } = require("../middleware/upload")

// All routes require authentication
router.use(authenticateToken)

// Profile routes
router.get("/profile", userController.getProfile)
router.put("/profile", uploadSingle, handleUploadError, userController.updateProfile)
router.put("/preferences", userController.updatePreferences)
router.delete("/account", userController.deleteAccount)

// Group management
router.post("/join-group", userController.joinGroup)
router.post("/leave-group", userController.leaveGroup)

// User posts
router.get("/posts/my", userController.getMyPosts) // Get posts by the logged-in user


// User discovery

router.get("/search", userController.searchUsers)
router.get("/:userId", userController.getUserById)
router.get("/:userId/posts", userController.getUserPosts) 
module.exports = router 

 