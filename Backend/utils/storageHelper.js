// utils/storageHelper.js
const fs = require('fs')
const path = require('path')

const saveVerificationDocument = async (buffer, userId, type, originalname) => {
  const dir = path.join(__dirname, '../uploads', userId)
  if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true })

  const filename = `${type}-${Date.now()}-${originalname}`
  const filePath = path.join(dir, filename)

  fs.writeFileSync(filePath, buffer)

  return {
    url: `/uploads/${userId}/${filename}` // You might serve this via static middleware
  }
}

module.exports = { saveVerificationDocument }
