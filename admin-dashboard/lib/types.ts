// Type definitions for backend data models
export interface User {
  _id: string
  username: string
  email: string
  fullName: string
  profilePhoto?: string
  role: "user" | "moderator" | "admin" | "super_admin"
  status: "active" | "blocked" | "pending"
  registrationDate: string
  lastLogin?: string
  livePhoto?: string
  idPhoto?: string
  banReason?: string
  banDuration?: string
  createdAt: string
  updatedAt: string
}

export interface Post {
  _id: string
  title: string
  content: string
  author: {
    _id: string
    username: string
    email: string
  }
  category: string
  status: "published" | "draft" | "reported" | "removed"
  likes: number
  comments: number
  reports: number
  createdAt: string
  updatedAt: string
}

export interface Report {
  _id: string
  type: "post" | "user"
  targetId: string
  targetDetails: {
    title?: string
    username?: string
    email?: string
  }
  reportedBy: {
    _id: string
    username: string
    email: string
  }
  reason: string
  description: string
  status: "pending" | "resolved" | "dismissed"
  priority: "low" | "medium" | "high"
  reportCount: number
  createdAt: string
  updatedAt: string
}

export interface Event {
  _id: string
  title: string
  description: string
  date: string
  time: string
  location: string
  organizer: string
  capacity: number
  registered: number
  status: "upcoming" | "ongoing" | "completed" | "cancelled"
  category: string
  createdAt: string
  updatedAt: string
}

export interface Notification {
  _id: string
  title: string
  message: string
  type: "info" | "warning" | "success" | "error"
  target: "all" | "active" | "pending" | "moderators"
  sentDate?: string
  scheduledDate?: string
  sentBy: string
  status: "sent" | "draft" | "scheduled" | "pending_approval"
  recipients: number
  readCount: number
  createdAt: string
  updatedAt: string
}

export interface AdminProfile {
  _id: string
  username: string
  email: string
  fullName: string
  profilePhoto?: string
  role: string
  lastLogin: string
  createdAt: string
}

export interface DashboardStats {
  totalUsers: number
  activeUsers: number
  totalPosts: number
  pendingApprovals: number
  totalReports: number
  upcomingEvents: number
  userGrowth: Array<{
    month: string
    users: number
    active: number
    new: number
  }>
  contentData: Array<{
    month: string
    posts: number
    comments: number
    likes: number
  }>
}
