const express = require("express");
const router = express.Router();
const postController = require("../controllers/postController");
const commentController = require("../controllers/commentController");
const reportController = require("../controllers/reportController");
const { authenticateToken } = require("../middleware/auth");
const { validatePost, validateComment, validateReport } = require("../middleware/validation");
const { uploadMultiple, handleUploadError } = require("../middleware/upload");

// All routes require authentication
router.use(authenticateToken); 

// Comments (specific first)
router.get("/:postId/comments", postController.getPostComments);
router.post("/:postId/comments", validateComment, commentController.createComment);
router.get("/posts",postController.getAllPosts);
// Other comment actions 
router.put("/comments/:commentId", validateComment, commentController.updateComment);
router.delete("/comments/:commentId", commentController.deleteComment);
router.post("/comments/:commentId/like", commentController.toggleCommentLike);

// Post routes
router.post("/postprayer", uploadMultiple, handleUploadError, validatePost, postController.createPost);
router.get("/feed", postController.getPostsFeed);
router.get("/:postId", postController.getPost);
router.put("/:postId", postController.updatePost);
router.delete("/:postId", postController.deletePost);
router.get("/posts", postController.getAllPosts);
// Post interactions
router.post("/:postId/like", postController.toggleLike);
router.post("/:postId/prayer", postController.addPrayer);
router.post("/:postId/virtual-hug", postController.sendVirtualHug);
router.post("/:postId/report", validateReport, reportController.reportPost);



module.exports = router;
