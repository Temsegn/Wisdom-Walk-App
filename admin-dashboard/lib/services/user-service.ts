// User management service
import { apiClient } from "../api"
import type { User } from "../types"

interface UserFilters {
  search?: string
  status?: string
  role?: string
  page?: number
  limit?: number
}

interface UserUpdateData {
  username?: string
  email?: string
  fullName?: string
  role?: string
  status?: string
}

interface BanUserData {
  reason: string
  duration: string
}

export class UserService {
  // Get all users with filters
  static async getUsers(filters: UserFilters = {}) {
    const queryParams = new URLSearchParams()

    Object.entries(filters).forEach(([key, value]) => {
      if (value !== undefined && value !== "") {
        queryParams.append(key, value.toString())
      }
    })

    const endpoint = `/users${queryParams.toString() ? `?${queryParams.toString()}` : ""}`
    return apiClient.get<{ users: User[]; total: number; page: number; totalPages: number }>(endpoint)
  }

  // Get single user
  static async getUser(userId: string) {
    return apiClient.get<User>(`/users/${userId}`)
  }

  // Update user
  static async updateUser(userId: string, data: UserUpdateData) {
    return apiClient.put<User>(`/users/${userId}`, data)
  }

  // Ban user
  static async banUser(userId: string, banData: BanUserData) {
    return apiClient.patch<User>(`/users/${userId}/ban`, banData)
  }

  // Unban user
  static async unbanUser(userId: string) {
    return apiClient.patch<User>(`/users/${userId}/unban`)
  }

  // Delete user
  static async deleteUser(userId: string) {
    return apiClient.delete(`/users/${userId}`)
  }

  // Approve pending user
  static async approveUser(userId: string) {
    return apiClient.patch<User>(`/users/${userId}/approve`)
  }

  // Reject pending user
  static async rejectUser(userId: string) {
    return apiClient.patch<User>(`/users/${userId}/reject`)
  }

  // Get pending users
  static async getPendingUsers() {
    return apiClient.get<User[]>("/users/pending")
  }

  // Upload profile photo
  static async uploadProfilePhoto(userId: string, file: File) {
    return apiClient.uploadFile<{ profilePhoto: string }>(`/users/${userId}/photo`, file)
  }
}
