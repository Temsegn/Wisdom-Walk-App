const multer = require("multer")
const path = require("path")

// Configure multer for memory storage
const storage = multer.memoryStorage()

// File filter function
const fileFilter = (req, file, cb) => {
  // Check file type
  const allowedTypes = /jpeg|jpg|png|gif/
  const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase())
  const mimetype = allowedTypes.test(file.mimetype)

  if (mimetype && extname) {
    return cb(null, true)
  } else {
    cb(new Error("Only images (JPEG, JPG, PNG, GIF) and PDF files are allowed"))
  }
}

// Configure multer
const upload = multer({
  storage: storage,
  limits: {
    fileSize: 10 * 1024 * 1024, // 10MB limit
  },
  fileFilter: fileFilter,
})

// Different upload configurations
const uploadSingle = upload.single("file")
const uploadMultiple = upload.array("files", 5) // Max 5 files
const uploadFields = upload.fields([
  { name: "livePhoto", maxCount: 1 },
  { name: "nationalId", maxCount: 1 },
  { name: "profilePicture", maxCount: 1 },
])

// Error handling middleware for multer
const handleUploadError = (err, req, res, next) => {
  if (err instanceof multer.MulterError) {
    if (err.code === "LIMIT_FILE_SIZE") {
      return res.status(400).json({
        success: false,
        message: "File too large. Maximum size is 10MB.",
      })
    }
    if (err.code === "LIMIT_FILE_COUNT") {
      return res.status(400).json({
        success: false,
        message: "Too many files. Maximum is 5 files.",
      })
    }
  }

  if (err.message.includes("Only images")) {
    return res.status(400).json({
      success: false,
      message: err.message,
    })
  }

  next(err)
}

module.exports = {
  uploadSingle,
  uploadMultiple,
  uploadFields,
  handleUploadError,
}
