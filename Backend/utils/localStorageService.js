const fs = require("fs")
const path = require("path")
const crypto = require("crypto")

// Create uploads directory if it doesn't exist
const uploadsDir = path.join(__dirname, "../uploads")
const subdirs = ["profiles", "posts", "messages", "verification", "temp"]

// Ensure upload directories exist
if (!fs.existsSync(uploadsDir)) {
  fs.mkdirSync(uploadsDir, { recursive: true })
}

subdirs.forEach((subdir) => {
  const dirPath = path.join(uploadsDir, subdir)
  if (!fs.existsSync(dirPath)) {
    fs.mkdirSync(dirPath, { recursive: true })
  }
})

// Generate unique filename
const generateFileName = (originalName, folder = "temp") => {
  const timestamp = Date.now()
  const randomString = crypto.randomBytes(8).toString("hex")
  const extension = path.extname(originalName)
  const baseName = path.basename(originalName, extension)

  return `${folder}/${timestamp}_${randomString}_${baseName}${extension}`
}

// Save file to local storage
const saveFile = async (fileBuffer, originalName, folder = "temp") => {
  try {
    const fileName = generateFileName(originalName, folder)
    const filePath = path.join(uploadsDir, fileName)

    // Ensure directory exists
    const dir = path.dirname(filePath)
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true })
    }

    // Write file
    fs.writeFileSync(filePath, fileBuffer)

    // Return file info
    return {
      url: `/uploads/${fileName}`,
      fileName: fileName,
      originalName: originalName,
      size: fileBuffer.length,
      path: filePath,
    }
  } catch (error) {
    console.error("Error savin file:", error)
    throw error
  }
}

// Save multiple files
const saveMultipleFiles = async (files, folder = "temp") => {
  try {
    const results = []

    for (const file of files) {
      const result = await saveFile(file.buffer, file.originalname, folder)
      results.push(result)
    }

    return results
  } catch (error) {
    console.error("Error saving multiple files:", error)
    throw error
  }
}

// Delete file from local storage
const deleteFile = async (filePath) => {
  try {
    // Remove /uploads/ prefix if present
    const cleanPath = filePath.replace(/^\/uploads\//, "")
    const fullPath = path.join(uploadsDir, cleanPath)

    if (fs.existsSync(fullPath)) {
      fs.unlinkSync(fullPath)
      return true
    }

    return false
  } catch (error) {
    console.error("Error deleting file:", error)
    throw error
  }
}

// Get file info
const getFileInfo = async (filePath) => {
  try {
    const cleanPath = filePath.replace(/^\/uploads\//, "")
    const fullPath = path.join(uploadsDir, cleanPath)

    if (fs.existsSync(fullPath)) {
      const stats = fs.statSync(fullPath)
      return {
        exists: true,
        size: stats.size,
        created: stats.birthtime,
        modified: stats.mtime,
        path: fullPath,
      }
    }

    return { exists: false }
  } catch (error) {
    console.error("Error getting file info:", error)
    throw error
  }
}

// Upload verification documents
const saveVerificationDocument = async (fileBuffer, userId, documentType, originalName) => {
  try {
    const folder = `verification/${userId}`
    const fileName = `${documentType}_${Date.now()}_${originalName}`

    // Create user verification directory
    const userVerificationDir = path.join(uploadsDir, "verification", userId)
    if (!fs.existsSync(userVerificationDir)) {
      fs.mkdirSync(userVerificationDir, { recursive: true })
    }

    const filePath = path.join(userVerificationDir, fileName)
    fs.writeFileSync(filePath, fileBuffer)

    return {
      url: `/uploads/verification/${userId}/${fileName}`,
      fileName: fileName,
      originalName: originalName,
      documentType: documentType,
      size: fileBuffer.length,
    }
  } catch (error) {
    console.error("Error saving verification document:", error)
    throw error
  }
}

// Clean up old temporary files (run periodically)
const cleanupTempFiles = async (maxAgeHours = 24) => {
  try {
    const tempDir = path.join(uploadsDir, "temp")
    if (!fs.existsSync(tempDir)) return

    const files = fs.readdirSync(tempDir)
    const maxAge = maxAgeHours * 60 * 60 * 1000 // Convert to milliseconds
    const now = Date.now()

    let deletedCount = 0

    for (const file of files) {
      const filePath = path.join(tempDir, file)
      const stats = fs.statSync(filePath)

      if (now - stats.birthtime.getTime() > maxAge) {
        fs.unlinkSync(filePath)
        deletedCount++
      }
    }

    console.log(`Cleaned up ${deletedCount} temporary files`)
    return deletedCount
  } catch (error) {
    console.error("Error cleaning up temp files:", error)
    throw error
  }
}

// Get storage statistics
const getStorageStats = async () => {
  try {
    const stats = {
      totalFiles: 0,
      totalSize: 0,
      byFolder: {},
    }

    const calculateDirStats = (dirPath, folderName) => {
      if (!fs.existsSync(dirPath)) return { files: 0, size: 0 }

      let files = 0
      let size = 0

      const items = fs.readdirSync(dirPath)

      for (const item of items) {
        const itemPath = path.join(dirPath, item)
        const itemStats = fs.statSync(itemPath)

        if (itemStats.isDirectory()) {
          const subStats = calculateDirStats(itemPath, item)
          files += subStats.files
          size += subStats.size
        } else {
          files++
          size += itemStats.size
        }
      }

      return { files, size }
    }

    // Calculate stats for each subdirectory
    for (const subdir of subdirs) {
      const dirPath = path.join(uploadsDir, subdir)
      const dirStats = calculateDirStats(dirPath, subdir)

      stats.byFolder[subdir] = dirStats
      stats.totalFiles += dirStats.files
      stats.totalSize += dirStats.size
    }

    return stats
  } catch (error) {
    console.error("Error getting storage stats:", error)
    throw error
  }
}

module.exports = {
  saveFile,
  saveMultipleFiles,
  deleteFile,
  getFileInfo,
  saveVerificationDocument,
  cleanupTempFiles,
  getStorageStats,
  uploadsDir,
}
