const express = require("express")
const mongoose = require("mongoose")
const cors = require("cors")
const helmet = require("helmet")
const rateLimit = require("express-rate-limit")
const path = require("path")
const cookieParser = require("cookie-parser")
const http = require("http")
const { Server } = require("socket.io")

require("dotenv").config()

const authRoutes = require("./routes/authRoutes")
const userRoutes = require("./routes/userRoutes")
const postRoutes = require("./routes/postRoutes")
const chatRoutes = require("./routes/chatRoutes")
const adminRoutes = require("./routes/adminRoutes")
const notificationRoutes = require("./routes/notificationRoutes")
const reportRoutes = require("./routes/reportRoutes")
const movementRoutes = require("./routes/movementRoute")
const bookingRoutes = require("./routes/bookingRoute")
const eventRoutes = require("./routes/eventRoutes")
const groupRoutes = require("./routes/group")

const app = express()
const server = http.createServer(app)

// CORS configuration - Fixed for Flutter app
app.use(
  cors({
    origin: "*", // Allow all origins for development
    credentials: true,
    methods: ["GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS"],
    allowedHeaders: ["Content-Type", "Authorization"],
  }),
)

// Socket.IO CORS configuration - Fixed
const io = new Server(server, {
  cors: {
    origin: "*",
    credentials: true,
    methods: ["GET", "POST"],
  },
})

app.use(cookieParser())
app.use(helmet())

app.use(express.json({ limit: "10mb" }))
app.use(express.urlencoded({ extended: true, limit: "10mb" }))

app.use(express.static(path.join(__dirname, "public")))
app.use("/uploads", express.static(path.join(__dirname, "Uploads")))

app.set("io", io)
require("./socket/socket")(io)

// Routes
app.use("/api/auth", authRoutes)
app.use("/api/users", userRoutes)
app.use("/api/posts", postRoutes)
app.use("/api/chats", chatRoutes)
app.use("/api/groups", groupRoutes)
app.use("/api/admin", adminRoutes)
app.use("/api/notifications", notificationRoutes)
app.use("/api/reports", reportRoutes)
app.use("/api/movements", movementRoutes)
app.use("/api/bookings", bookingRoutes)
app.use("/api/events", eventRoutes)

// Health check
app.get("/api/health", (req, res) => {
  res.json({
    success: true,
    message: "WisdomWalk API is running",
    timestamp: new Date().toISOString(),
  })
})

// Error handling
app.use((err, req, res, next) => {
  console.error(err.stack)
  res.status(500).json({
    success: false,
    message: "Something went wrong!",
    error: process.env.NODE_ENV === "development" ? err.message : undefined,
  })
})

// 404 handler
app.use("*", (req, res) => {
  res.status(404).json({
    success: false,
    message: "Route not found",
  })
})

mongoose
  .connect(
    "mongodb+srv://tom:1234tom2394@wisdomwalk.db2qsqm.mongodb.net/?retryWrites=true&w=majority&appName=wisdomwalk",
    {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    },
  )
  .then(() => {
    server.listen(process.env.PORT || 5000, "0.0.0.0", () => {
      console.log(`Server running on port ${process.env.PORT || 5000}`)
      console.log(`Static files served from: ${path.join(__dirname, "public")}`)
      console.log(`Uploads served from: ${path.join(__dirname, "Uploads")}`)
    })
  })
  .catch((err) => console.error("MongoDB connection error:", err))

module.exports = app
