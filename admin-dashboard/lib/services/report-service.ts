// Reports service
import { apiClient } from "../api"
import type { Report } from "../types"

interface ReportFilters {
  type?: "post" | "user"
  status?: string
  priority?: string
  search?: string
  page?: number
  limit?: number
}

export class ReportService {
  // Get all reports
  static async getReports(filters: ReportFilters = {}) {
    const queryParams = new URLSearchParams()

    Object.entries(filters).forEach(([key, value]) => {
      if (value !== undefined && value !== "") {
        queryParams.append(key, value.toString())
      }
    })

    const endpoint = `/reports${queryParams.toString() ? `?${queryParams.toString()}` : ""}`
    return apiClient.get<{ reports: Report[]; total: number; page: number; totalPages: number }>(endpoint)
  }

  // Get single report
  static async getReport(reportId: string) {
    return apiClient.get<Report>(`/reports/${reportId}`)
  }

  // Resolve report
  static async resolveReport(reportId: string, resolution?: string) {
    return apiClient.patch<Report>(`/reports/${reportId}/resolve`, { resolution })
  }

  // Dismiss report
  static async dismissReport(reportId: string, reason?: string) {
    return apiClient.patch<Report>(`/reports/${reportId}/dismiss`, { reason })
  }

  // Get reports by target
  static async getReportsByTarget(targetType: "post" | "user", targetId: string) {
    return apiClient.get<Report[]>(`/reports/target/${targetType}/${targetId}`)
  }
}
