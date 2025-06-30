import type { ApiResponse ,ApiError } from "./types";

class ApiClient {
  private baseURL: string = "https://wisdom-walk-app.onrender.com/api"; // Direct backend URL
  private getToken: () => string | null;

  constructor() {
    this.getToken = () => {
      if (typeof window !== "undefined") {
        const user = localStorage.getItem("admin_user");
        if (user) {
          const parsed = JSON.parse(user);
          return parsed.token || null; // Use token from localStorage
        }
      }
      return null;
    };
  }

  async request<T>(endpoint: string, options: RequestInit = {}): Promise<ApiResponse<T>> {
    const url = `${this.baseURL}${endpoint}`;
    const token = this.getToken();
    const config: RequestInit = {
      headers: {
        "Content-Type": "application/json",
        ...(token ? { Authorization: `Bearer ${token}` } : {}),
        ...options.headers,
      },
      // credentials: "include", // Disabled to avoid CORS issues
      ...options,
    };

    try {
      const response = await fetch(url, config);
      let data;
      const contentType = response.headers.get("content-type");
      if (contentType && contentType.includes("application/json")) {
        data = await response.json();
      } else {
        data = { message: await response.text() || "Non-JSON response received" };
      }

      if (!response.ok) {
        if (response.status === 401 && !endpoint.includes("/login")) {
          if (typeof window !== "undefined" && !window.location.pathname.includes("/login")) {
            console.log("Unauthorized, redirecting to login...");
            localStorage.removeItem("admin_user"); // Clear invalid token
            window.location.href = "/login";
          }
        }
        throw {
          message: data.message || data.error || `HTTP ${response.status}: ${response.statusText}`,
          status: response.status,
          code: data.code,
        } as ApiError;
      }

      return data;
    } catch (error) {
      console.error("API request error:", {
        endpoint,
        error,
        type: typeof error,
        stringified: JSON.stringify(error, Object.getOwnPropertyNames(error), 2),
        stack: error instanceof Error ? error.stack : undefined,
      });

      if (error instanceof TypeError && error.message.includes("fetch")) {
        throw {
          message: "Network error: Server is unavailable or request was blocked.",
          status: 0,
        } as ApiError;
      }

      throw {
        message: error instanceof Error ? error.message : "An unexpected error occurred",
        status: (error as ApiError).status || 500,
      } as ApiError;
    }
  }

  async get<T>(endpoint: string, options: RequestInit = {}): Promise<ApiResponse<T>> {
    return this.request<T>(endpoint, { ...options, method: "GET" });
  }

  async post<T>(endpoint: string, body: any, options: RequestInit = {}): Promise<ApiResponse<T>> {
    return this.request<T>(endpoint, {
      ...options,
      method: "POST",
      body: JSON.stringify(body),
    });
  }
}

export const apiClient = new ApiClient();