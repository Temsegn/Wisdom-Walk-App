const cloudinary = require("../config/cloudinary")

// Upload image to Cloudinary
const uploadImage = async (fileBuffer, folder = "wisdomwalk") => {
  try {
    return new Promise((resolve, reject) => {
      cloudinary.uploader
        .upload_stream(
          {
            folder: folder,
            resource_type: "auto",
            quality: "auto:good",
            fetch_format: "auto",
          },
          (error, result) => {
            if (error) {
              reject(error)
            } else {
              resolve({
                url: result.secure_url,
                publicId: result.public_id,
              })
            }
          },
        )
        .end(fileBuffer)
    })
  } catch (error) {
    console.error("Cloudinary upload error:", error)
    throw error
  }
}

// Upload multiple images
const uploadMultipleImages = async (files, folder = "wisdomwalk") => {
  try {
    const uploadPromises = files.map((file) => uploadImage(file.buffer, folder))
    return await Promise.all(uploadPromises)
  } catch (error) {
    console.error("Multiple upload error:", error)
    throw error
  }
}

// Delete image from Cloudinary
const deleteImage = async (publicId) => {
  try {
    const result = await cloudinary.uploader.destroy(publicId)
    return result
  } catch (error) {
    console.error("Cloudinary delete error:", error)
    throw error
  }
}

// Upload verification documents
const uploadVerificationDocument = async (fileBuffer, userId, documentType) => {
  try {
    const folder = `wisdomwalk/verification/${userId}`
    const result = await uploadImage(fileBuffer, folder)

    // Add metadata for verification documents
    await cloudinary.uploader.add_tag([`verification`, `${documentType}`, `user_${userId}`], result.publicId)

    return result
  } catch (error) {
    console.error("Verification document upload error:", error)
    throw error
  }
}

module.exports = {
  uploadImage,
  uploadMultipleImages,
  deleteImage,
  uploadVerificationDocument,
}
