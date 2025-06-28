const cloudinary = require('../config/cloudinary')
const { Readable } = require('stream')

const bufferToStream = (buffer) => Readable.from(buffer)

// Upload a single file buffer
const saveFile = (fileBuffer, originalName, folder = "temp") => {
  return new Promise((resolve, reject) => {
    const stream = cloudinary.uploader.upload_stream(
      {
        resource_type: 'auto',
        folder,
        public_id: originalName.split('.')[0] + '_' + Date.now(),
        overwrite: false,
      },
      (error, result) => {
        if (error) {
          console.error('Cloudinary upload error:', error)
          return reject(error)
        }
        resolve(result)
      }
    )

    bufferToStream(fileBuffer).pipe(stream)
  })
}

// Upload multiple files
const saveMultipleFiles = async (files, folder = "temp") => {
  const results = []
  for (const file of files) {
    const res = await saveFile(file.buffer, file.originalname, folder)
    results.push(res)
  }
  return results
}

// Upload a verification document
const saveVerificationDocument = async (fileBuffer, userId, type, originalName) => {
  const folder = `verification/${userId}`
  const result = await saveFile(fileBuffer, originalName, folder)

  return {
    url: result.secure_url,
    publicId: result.public_id,
    originalName,
    documentType: type,
    size: result.bytes,
  }
}

// Delete a file from Cloudinary
const deleteFile = async (publicId) => {
  try {
    const res = await cloudinary.uploader.destroy(publicId)
    return res.result === "ok"
  } catch (error) {
    console.error("Error deleting Cloudinary file:", error)
    throw error
  }
}

module.exports = {
  saveFile,
  saveMultipleFiles,
  saveVerificationDocument,
  deleteFile,
}
