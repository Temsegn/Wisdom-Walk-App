import { apiClient, type ApiResponse, type ApiError } from "./api";
import type { AdminProfile } from "./types";

interface LoginCredentials {
  email: string;
  password: string;
}

interface LoginResponse {
  token: string;
  user: AdminProfile;
  expiresIn: number;
}

export class AuthService {
  static async login(credentials: LoginCredentials): Promise<{ user: { fullName: string } }> {
    try {
      const response = await apiClient.post<LoginResponse>("/auth/login", credentials, {
        credentials: "include", // Include HTTP-only cookiesss
      });

      if (response.success && response.data) {
        // Store user data in localStorage for client-side access
        if (typeof window !== "undefined") {
          localStorage.setItem("admin_user", JSON.stringify(response.data.user));
        }
        return { user: { fullName: response.data.user.fullName } };
      }

      throw new Error(response.message || "Login failed");
    } catch (error: any) {
      console.error("Login error:", {
        message: error.message,
        status: error.status,
        code: error.code,
      });
      if (error.status === 401) {
        throw new Error("Invalid email or password");
      } else if (error.status === 403) {
        if (error.message?.includes("verify your email")) {
          throw new Error("Please verify your email address");
        } else if (error.message?.includes("blocked")) {
          throw new Error(error.message);
        } else if (error.message?.includes("banned")) {
          throw new Error("Your account is banned. Contact support.");
        }
        throw new Error("Access denied. Admin privileges required.");
      } else if (error.status === 429) {
        throw new Error("Too many login attempts. Please try again later.");
      } else if (error.status === 0) {
        throw new Error("Network error. Please check your internet connection.");
      }
      throw new Error(error.message || "Login failed. Please try again.");
    }
  }

  static async logout(): Promise<void> {
    try {
      await apiClient.post("/api/logout", {}, { credentials: "include" });
    } catch (error) {
      
    } finally {
      if (typeof window !== "undefined") {
        localStorage.removeItem("admin_user");
        window.location.href = "/login";
      }
    }
  }

  static async refreshToken(): Promise<string> {
    try {
      const response = await apiClient.post<{ token: string; expiresIn: number }>(
        "/api/refresh",
        {},
        { credentials: "include" }
      );
      if (response.success && response.data) {
        return response.data.token;
      }
      throw new Error("Token refresh failed");
    } catch (error) {
       
      await this.logout();
      throw error;
    }
  }

  static getCurrentUser(): AdminProfile | null {
    if (typeof window !== "undefined") {
      const userData = localStorage.getItem("admin_user");
      return userData ? JSON.parse(userData) : null;
    }
    return null;
  }

  static async isAuthenticated(): Promise<boolean> {
    if (typeof window !== "undefined") {
      const userData = localStorage.getItem("admin_user");
      if (!userData) return false;

      // Optional: Verify with /api/me if available
      try {
        const response = await apiClient.get<AdminProfile>("/api/me", {
          credentials: "include",
        });
        return response.success && !!response.data;
      } catch (error: any) {
        console.error("Authentication check error:", {
          message: error.message,
          status: error.status,
          code: error.code,
        });
        return !!userData; // Fallback to localStorage
      }
    }
    return false;
  }
}