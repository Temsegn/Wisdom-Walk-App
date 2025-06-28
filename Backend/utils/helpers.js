const crypto = require("crypto")
const jwt = require("jsonwebtoken")

// Generate random token
const generateToken = () => {
  return crypto.randomBytes(32).toString("hex")
}
// Generate JWT token
const generateJWT = (payload) => {
  return jwt.sign(payload, "wisdom", { expiresIn: process.env.JWT_EXPIRES_IN || "7d" });
};

// Calculate age from date of birth
const calculateAge = (dateOfBirth) => {
  const today = new Date()
  const birthDate = new Date(dateOfBirth)
  let age = today.getFullYear() - birthDate.getFullYear()
  const monthDiff = today.getMonth() - birthDate.getMonth()

  if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birthDate.getDate())) {
    age--
  }

  return age
}

// Format user data for response (remove sensitive fields)
const formatUserResponse = (user) => {
  const userObj = user.toObject ? user.toObject() : user

  // Remove sensitive fields
  delete userObj.password
  delete userObj.emailVerificationToken
  delete userObj.emailVerificationExpires
  delete userObj.passwordResetToken
  delete userObj.passwordResetExpires

  // Add computed fields
  userObj.age = calculateAge(userObj.dateOfBirth)
  userObj.canAccess = user.canAccess ? user.canAccess() : false

  return userObj
}

// Generate scripture for virtual hugs
const getRandomScripture = () => {
  const scriptures = [
    {
      verse: "The Lord is near to the brokenhearted and saves the crushed in spirit.",
      reference: "Psalm 34:18",
    },
    {
      verse: "Cast all your anxiety on him because he cares for you.",
      reference: "1 Peter 5:7",
    },
    {
      verse: "She is clothed with strength and dignity; she can laugh at the days to come.",
      reference: "Proverbs 31:25",
    },
    {
      verse: "And we know that in all things God works for the good of those who love him.",
      reference: "Romans 8:28",
    },
    {
      verse:
        "Be strong and courageous. Do not be afraid; do not be discouraged, for the Lord your God will be with you wherever you go.",
      reference: "Joshua 1:9",
    },
    {
      verse:
        "The Lord your God is with you, the Mighty Warrior who saves. He will take great delight in you; in his love he will no longer rebuke you, but will rejoice over you with singing.",
      reference: "Zephaniah 3:17",
    },
    {
      verse: "Come to me, all you who are weary and burdened, and I will give you rest.",
      reference: "Matthew 11:28",
    },
    {
      verse:
        "But those who hope in the Lord will renew their strength. They will soar on wings like eagles; they will run and not grow weary, they will walk and not be faint.",
      reference: "Isaiah 40:31",
    },
  ]

  return scriptures[Math.floor(Math.random() * scriptures.length)]
}

// Validate email format
const isValidEmail = (email) => {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
  return emailRegex.test(email)
}

// Generate daily verse
const getDailyVerse = () => {
  const verses = [
    {
      verse: "Trust in the Lord with all your heart and lean not on your own understanding.",
      reference: "Proverbs 3:5",
    },
    {
      verse:
        "For I know the plans I have for you, declares the Lord, plans to prosper you and not to harm you, to give you hope and a future.",
      reference: "Jeremiah 29:11",
    },
    {
      verse: "She opens her mouth with wisdom, and the teaching of kindness is on her tongue.",
      reference: "Proverbs 31:26",
    },
    {
      verse: "Charm is deceptive, and beauty is fleeting; but a woman who fears the Lord is to be praised.",
      reference: "Proverbs 31:30",
    },
    {
      verse: "Above all else, guard your heart, for everything you do flows from it.",
      reference: "Proverbs 4:23",
    },
  ]

  // Use current date to ensure same verse for the day
  const today = new Date()
  const dayOfYear = Math.floor((today - new Date(today.getFullYear(), 0, 0)) / 1000 / 60 / 60 / 24)
  const index = dayOfYear % verses.length

  return verses[index]
}

// Sanitize user input
const sanitizeInput = (input) => {
  if (typeof input !== "string") return input

  return input
    .trim()
    .replace(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi, "") // Remove script tags
    .replace(/javascript:/gi, "") // Remove javascript: protocol
    .replace(/on\w+\s*=/gi, "") // Remove event handlers
}

// Generate pagination metadata
const getPaginationMeta = (page, limit, total) => {
  const totalPages = Math.ceil(total / limit)
  const hasNext = page < totalPages
  const hasPrev = page > 1

  return {
    currentPage: page,
    totalPages,
    totalItems: total,
    itemsPerPage: limit,
    hasNext,
    hasPrev,
    nextPage: hasNext ? page + 1 : null,
    prevPage: hasPrev ? page - 1 : null,
  }
}

module.exports = {
  generateToken,
  generateJWT,
  calculateAge,
  formatUserResponse,
  getRandomScripture,
  isValidEmail,
  getDailyVerse,
  sanitizeInput,
  getPaginationMeta,
}
