"use client"

// Custom hook for API calls with error handling
import { useState } from "react"
import { useToast } from "./use-toast"
import type { ApiResponse, ApiError } from "../lib/api"

interface UseApiOptions<T> {
  onSuccess?: (data: T) => void
  onError?: (error: ApiError) => void
  showSuccessToast?: boolean
  showErrorToast?: boolean
  successMessage?: string
}

export function useApi<T>() {
  const [data, setData] = useState<T | null>(null)
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<ApiError | null>(null)
  const { toast } = useToast()

  const execute = async (apiCall: () => Promise<ApiResponse<T>>, options: UseApiOptions<T> = {}) => {
    const {
      onSuccess,
      onError,
      showSuccessToast = false,
      showErrorToast = true,
      successMessage = "Operation completed successfully",
    } = options

    setLoading(true)
    setError(null)

    try {
      const response = await apiCall()

      if (response.success && response.data) {
        setData(response.data)

        if (showSuccessToast) {
          toast({
            title: "Success",
            description: response.message || successMessage,
          })
        }

        onSuccess?.(response.data)
      } else {
        throw new Error(response.message || "Operation failed")
      }
    } catch (err) {
      const apiError = err as ApiError
      setError(apiError)

      if (showErrorToast) {
        toast({
          title: "Error",
          description: apiError.message || "An unexpected error occurred",
          variant: "destructive",
        })
      }

      onError?.(apiError)
    } finally {
      setLoading(false)
    }
  }

  const reset = () => {
    setData(null)
    setError(null)
    setLoading(false)
  }

  return {
    data,
    loading,
    error,
    execute,
    reset,
  }
}

// Hook for paginated data
export function usePaginatedApi<T>() {
  const [data, setData] = useState<T[]>([])
  const [pagination, setPagination] = useState({
    page: 1,
    totalPages: 1,
    total: 0,
    limit: 10,
  })
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<ApiError | null>(null)
  const { toast } = useToast()

  const execute = async (
    apiCall: (
      page: number,
      limit: number,
    ) => Promise<
      ApiResponse<{
        items: T[]
        total: number
        page: number
        totalPages: number
      }>
    >,
    page = 1,
    limit = 10,
  ) => {
    setLoading(true)
    setError(null)

    try {
      const response = await apiCall(page, limit)

      if (response.success && response.data) {
        setData(response.data.items)
        setPagination({
          page: response.data.page,
          totalPages: response.data.totalPages,
          total: response.data.total,
          limit,
        })
      }
    } catch (err) {
      const apiError = err as ApiError
      setError(apiError)

      toast({
        title: "Error",
        description: apiError.message || "Failed to load data",
        variant: "destructive",
      })
    } finally {
      setLoading(false)
    }
  }

  return {
    data,
    pagination,
    loading,
    error,
    execute,
  }
}
