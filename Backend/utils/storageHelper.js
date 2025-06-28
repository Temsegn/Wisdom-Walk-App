const cloudinary = require('../config/cloudinary')

// Upload a single file buffer
const saveFile = async (fileBuffer, originalName, folder = "temp") => {
  try {
    const uploadResult = await cloudinary.uploader.upload_stream(
      {
        resource_type: 'auto',
        folder,
        public_id: originalName.split('.')[0],
        overwrite: false,
      },
      (error, result) => {
        if (error) throw error
        return result
      }
    )

    // Convert file buffer to stream and pipe to Cloudinary
    const { Readable } = require('stream')
    const stream = Readable.from(fileBuffer)
    stream.pipe(uploadResult)

    return new Promise((resolve, reject) => {
      uploadResult.on('finish', () => resolve(uploadResult))
      uploadResult.on('error', reject)
    })
  } catch (error) {
    console.error('Error uploading to Cloudinary:', error)
    throw error
  }
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

// Upload a verification document to a specific folder
const saveVerificationDocument = async (fileBuffer, userId, type, originalName) => {
  const folder = `verification/${userId}`
  const result = await saveFile(fileBuffer, originalName, folder)

  return {
    url: result.secure_url,
    public_id: result.public_id,
    originalName,
    documentType: type,
    size: result.bytes,
  }
}
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
