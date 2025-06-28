const mongoose = require("mongoose")
const bcrypt = require("bcryptjs")
const User = require("../models/User")
const Post = require("../models/Post")
const { Single, Marriage, Healing, Motherhood } = require("../models/GroupModels")
require("dotenv").config()

// Sample data
const sampleUsers = [
  {
    email: "admin@wisdomwalk.com",
    password: "Admin123!",
    firstName: "Sarah",
    lastName: "Admin",
    dateOfBirth: new Date("1985-06-15"),
    phoneNumber: "+1234567890",
    location: { city: "New York", country: "USA" },
    isEmailVerified: true,
    isAdminVerified: true,
    isGlobalAdmin: true,
    adminPermissions: ["verify_users", "manage_posts", "manage_groups", "send_notifications", "ban_users"],
    livePhoto: "https://example.com/admin-live.jpg",
    nationalId: "https://example.com/admin-id.jpg",
    verificationStatus: "approved",
  },
  {
    email: "mary@example.com",
    password: "Mary123!",
    firstName: "Mary",
    lastName: "Johnson",
    dateOfBirth: new Date("1990-03-20"),
    phoneNumber: "+1234567891",
    location: { city: "Los Angeles", country: "USA" },
    bio: "Single mom seeking God's guidance in raising my children.",
    isEmailVerified: true,
    isAdminVerified: true,
    joinedGroups: [
      { groupType: "motherhood", isAdmin: false },
      { groupType: "single", isAdmin: true },
    ],
    livePhoto: "https://example.com/mary-live.jpg",
    nationalId: "https://example.com/mary-id.jpg",
    verificationStatus: "approved",
  },
  {
    email: "grace@example.com",
    password: "Grace123!",
    firstName: "Grace",
    lastName: "Williams",
    dateOfBirth: new Date("1988-11-10"),
    phoneNumber: "+1234567892",
    location: { city: "Chicago", country: "USA" },
    bio: "Married for 5 years, passionate about ministry and serving others.",
    isEmailVerified: true,
    isAdminVerified: true,
    joinedGroups: [
      { groupType: "marriage", isAdmin: true },
      { groupType: "healing", isAdmin: false },
    ],
    livePhoto: "https://example.com/grace-live.jpg",
    nationalId: "https://example.com/grace-id.jpg",
    verificationStatus: "approved",
  },
  {
    email: "hope@example.com",
    password: "Hope123!",
    firstName: "Hope",
    lastName: "Davis",
    dateOfBirth: new Date("1992-07-25"),
    phoneNumber: "+1234567893",
    location: { city: "Houston", country: "USA" },
    bio: "On a healing journey, finding strength in God's love.",
    isEmailVerified: true,
    isAdminVerified: true,
    joinedGroups: [
      { groupType: "healing", isAdmin: true },
      { groupType: "single", isAdmin: false },
    ],
    livePhoto: "https://example.com/hope-live.jpg",
    nationalId: "https://example.com/hope-id.jpg",
    verificationStatus: "approved",
  },
  {
    email: "faith@example.com",
    password: "Faith123!",
    firstName: "Faith",
    lastName: "Brown",
    dateOfBirth: new Date("1987-12-05"),
    phoneNumber: "+1234567894",
    location: { city: "Phoenix", country: "USA" },
    bio: "Mother of three, finding joy in Christ through motherhood.",
    isEmailVerified: true,
    isAdminVerified: true,
    joinedGroups: [
      { groupType: "motherhood", isAdmin: true },
      { groupType: "marriage", isAdmin: false },
    ],
    livePhoto: "https://example.com/faith-live.jpg",
    nationalId: "https://example.com/faith-id.jpg",
    verificationStatus: "approved",
  },
]

const samplePosts = [
  {
    type: "prayer",
    content: "Please pray for my job interview tomorrow. I'm feeling anxious but trusting in God's plan for my life.",
    title: "Job Interview Prayer Request",
    targetGroup: "general",
    tags: ["prayer", "job", "anxiety"],
  },
  {
    type: "confession",
    content:
      "I've been struggling with forgiveness. Someone hurt me deeply and I know I need to forgive, but it's so hard.",
    isAnonymous: true,
    targetGroup: "healing",
    tags: ["forgiveness", "healing"],
  },
  {
    type: "location",
    content: "Moving to Seattle next month! Looking for a good church and Christian community there.",
    title: "Moving to Seattle",
    location: { city: "Seattle", country: "USA" },
    targetGroup: "general",
    tags: ["relocation", "church", "community"],
  },
]

const sampleGroupPosts = {
  single: [
    {
      title: "Dating with Purpose",
      content: "How do you navigate dating while keeping Christ at the center? Looking for advice from my sisters.",
      topicType: "dating_advice",
      ageRange: "26-35",
      tags: ["dating", "purpose", "relationships"],
    },
    {
      title: "Career vs. Calling",
      content:
        "Struggling to balance my career ambitions with what I feel God is calling me to do. Anyone else been here?",
      topicType: "purpose_discovery",
      tags: ["career", "calling", "purpose"],
    },
  ],
  marriage: [
    {
      title: "Praying Together as a Couple",
      content: "My husband and I want to strengthen our prayer life together. What practices have worked for you?",
      topicType: "ministry_together",
      marriageStage: "established",
      tags: ["prayer", "couple", "ministry"],
    },
    {
      title: "Conflict Resolution",
      content: "We had our first big fight and I'm not sure how to move forward biblically. Seeking wisdom.",
      topicType: "conflict_resolution",
      marriageStage: "newlywed",
      tags: ["conflict", "resolution", "marriage"],
    },
  ],
  healing: [
    {
      title: "Healing from Past Trauma",
      content: "Starting therapy and would appreciate prayers as I work through some difficult memories.",
      healingType: "trauma",
      isSensitive: true,
      supportLevel: "professional_needed",
      triggerWarnings: ["trauma", "therapy"],
      tags: ["trauma", "therapy", "healing"],
    },
    {
      title: "Overcoming Addiction",
      content: "Celebrating 6 months sober! God is so good. For anyone struggling, there is hope.",
      healingType: "addiction",
      supportLevel: "peer_support",
      tags: ["addiction", "recovery", "testimony"],
    },
  ],
  motherhood: [
    {
      title: "Raising Godly Children",
      content:
        "How do you teach your children about God in age-appropriate ways? My 4-year-old asks the best questions!",
      motherhoodStage: "toddler",
      topicType: "spiritual_training",
      childrenAges: ["4"],
      canMentor: true,
      tags: ["parenting", "spiritual", "children"],
    },
    {
      title: "Working Mom Guilt",
      content: "Struggling with guilt about working full-time. How do you balance it all while trusting God?",
      motherhoodStage: "school_age",
      topicType: "work_life_balance",
      isSeekingMentorship: true,
      tags: ["working", "guilt", "balance"],
    },
  ],
}

const seedDatabase = async () => {
  try {
    // Connect to database
    await mongoose.connect(process.env.MONGODB_URI || "mongodb+srv://tom:1234tom2394@wisdomwalk.db2qsqm.mongodb.net/?retryWrites=true&w=majority&appName=wisdomwalk")
    console.log("Connected to MongoDB")

    // Clear existing data
    await User.deleteMany({})
    await Post.deleteMany({})
    await Single.deleteMany({})
    await Marriage.deleteMany({})
    await Healing.deleteMany({})
    await Motherhood.deleteMany({})

    console.log("Cleared existing data")

    // Create users
    const createdUsers = []
    for (const userData of sampleUsers) {
      const user = new User(userData)
      await user.save()
      createdUsers.push(user)
      console.log(`Created user: ${user.firstName} ${user.lastName}`)
    }

    // Create general posts
    for (const postData of samplePosts) {
      const randomUser = createdUsers[Math.floor(Math.random() * createdUsers.length)]
      const post = new Post({
        ...postData,
        author: randomUser._id,
      })
      await post.save()
      console.log(`Created post: ${post.title || post.content.substring(0, 50)}...`)
    }

    // Create group-specific posts
    const groupModels = {
      single: Single,
      marriage: Marriage,
      healing: Healing,
      motherhood: Motherhood,
    }

    for (const [groupType, posts] of Object.entries(sampleGroupPosts)) {
      const GroupModel = groupModels[groupType]

      for (const postData of posts) {
        // Find a user who is in this group
        const groupUser = createdUsers.find((user) => user.joinedGroups.some((group) => group.groupType === groupType))

        if (groupUser) {
          const post = new GroupModel({
            ...postData,
            author: groupUser._id,
          })
          await post.save()
          console.log(`Created ${groupType} post: ${post.title}`)
        }
      }
    }

    // Add this after creating posts and before the final console.log

    // Create sample reports
    const sampleReports = [
      {
        type: "inappropriate_content",
        reason: "This post contains content that doesn't align with our community guidelines.",
      },
      {
        type: "spam",
        reason: "This appears to be spam content posted multiple times.",
      },
      {
        type: "harassment",
        reason: "This comment is targeting another user inappropriately.",
      },
    ]

    // Create reports for some posts
    const allPosts = await Post.find().limit(3)
    for (let i = 0; i < Math.min(sampleReports.length, allPosts.length); i++) {
      const reportData = sampleReports[i]
      const post = allPosts[i]
      const reporter = createdUsers[Math.floor(Math.random() * createdUsers.length)]

      // Don't let users report their own posts
      if (reporter._id.toString() !== post.author.toString()) {
        const report = new (require("../models/Report"))({
          reporter: reporter._id,
          reportedPost: post._id,
          type: reportData.type,
          reason: reportData.reason,
        })

        await report.save()

        // Update post report status
        await Post.findByIdAndUpdate(post._id, {
          isReported: true,
          $inc: { reportCount: 1 },
        })

        console.log(`Created report for post: ${post.title || post.content.substring(0, 30)}...`)
      }
    }

    console.log("Database seeded successfully!")
    console.log("\nSample login credentials:")
    console.log("Admin: admin@wisdomwalk.com / Admin123!")
    console.log("User: mary@example.com / Mary123!")
    console.log("User: grace@example.com / Grace123!")
    console.log("User: hope@example.com / Hope123!")
    console.log("User: faith@example.com / Faith123!")
  } catch (error) {
    console.error("Error seeding database:", error)
  } finally {
    await mongoose.disconnect()
    console.log("Disconnected from MongoDB")
  }
}

// Run the seed function
if (require.main === module) {
  seedDatabase()
}

module.exports = seedDatabase
