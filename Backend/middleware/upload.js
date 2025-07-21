const multer = require("multer");
const path = require("path");

// Configure multer for memory storage
const storage = multer.memoryStorage();
 const fileFilter = (req, file, cb) => {
  const extname = /\.(jpg|jpeg|png|gif)$/i.test(file.originalname); // ✅ check extension
  const mimetype = /image\/(jpeg|png|gif)/.test(file.mimetype);     // ✅ check MIME

  console.log('file.originalname:', file.originalname);  // 🔍 Debug
  console.log('file.mimetype:', file.mimetype);          // 🔍 Debug

  if (mimetype && extname) {
    cb(null, true);
  } else {
    cb(new Error("Only images (JPEG, JPG, PNG, GIF) are allowed"));
  }
};


// Configure multer
const upload = multer({
  storage: storage,
  limits: {
    fileSize: 10 * 1024 * 1024, // 10MB limit
  },
  fileFilter: fileFilter,
});

// Different upload configurations
const uploadSingle = upload.single("file"); // Generic single file upload
const uploadProfilePicture = upload.single("profilePicture"); // For updateProfilePhoto
const uploadMultiple = upload.array("files", 5); // Max 5 files
const uploadFields = upload.fields([
  { name: "livePhoto", maxCount: 1 },
  { name: "nationalId", maxCount: 1 },
  { name: "profilePicture", maxCount: 1 },
]);

// Error handling middleware for multer
const handleUploadError = (err, req, res, next) => {
  if (err instanceof multer.MulterError) {
    if (err.code === "LIMIT_FILE_SIZE") {
      return res.status(400).json({
        success: false,
        message: "File too large. Maximum size is 10MB.",
      });
    }
    if (err.code === "LIMIT_FILE_COUNT") {
      return res.status(400).json({
        success: false,
        message: "Too many files. Maximum is 5 files.",
      });
    }
    if (err.code === "LIMIT_UNEXPECTED_FILE") {
      return res.status(400).json({
        success: false,
        message: `Unexpected field. Expected field name: ${err.field || "unknown"}`,
      });
    }
  }

  if (err.message.includes("Only images")) {
    return res.status(400).json({
      success: false,
      message: err.message,
    });
  }

  next(err);
};

module.exports = {
  uploadSingle,
  uploadProfilePicture,
  uploadMultiple,
  uploadFields,
  handleUploadError,
};