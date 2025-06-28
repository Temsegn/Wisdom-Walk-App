// config/multer.js
const multer = require('multer')

const storage = multer.memoryStorage()

const upload = multer({
  storage,
  limits: { fileSize: 20 * 1024 * 1024 }, // optional: 5MB limit
})

module.exports = upload
