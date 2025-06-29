// Dashboard data service
import { apiClient } from "../api"
import type { DashboardStats } from "../types"

export class DashboardService {
  // Get dashboard statistics
  static async getDashboardStats() {
    return apiClient.get<DashboardStats>("/dashboard/stats")
  }

  // Get recent activities
  static async getRecentActivities() {
    return apiClient.get<
      Array<{
        id: string
        action: string
        user: string
        time: string
        type: string
      }>
    >("/dashboard/activities")
  }

  // Get user growth data
  static async getUserGrowthData(period = "6m") {
    return apiClient.get<
      Array<{
        month: string
        users: number
        active: number
        new: number
      }>
    >(`/dashboard/user-growth?period=${period}`)
  }

  // Get content analytics
  static async getContentAnalytics(period = "6m") {
    return apiClient.get<
      Array<{
        month: string
        posts: number
        comments: number
        likes: number
      }>
    >(`/dashboard/content-analytics?period=${period}`)
  }
}
