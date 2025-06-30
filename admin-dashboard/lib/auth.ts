import { apiClient } from "./api";
import type { AdminProfile } from "./types";

interface LoginCredentials {
  email: string;
  password: string;
}

interface LoginUser {
  id: string;
  email: string;
  firstName?: string;
  lastName?: string;
  isAdminVerified: boolean;
  isGlobalAdmin: boolean;
  status: string;
}

interface LoginResponse {
  success: boolean;
  message?: string;
  data?: {
    token: string;
    user: LoginUser;
  };
  error?: string;
}

const STORAGE_KEY = "admin_user";

// ========== LocalStorage Helpers ==========
const saveUserToStorage = (user: LoginUser, token: string) => {
  if (typeof window !== "undefined") {
    localStorage.setItem(STORAGE_KEY, JSON.stringify({ ...user, token }));
  }
};

const removeUserFromStorage = () => {
  if (typeof window !== "undefined") {
    localStorage.removeItem(STORAGE_KEY);
  }
};

const getUserFromStorage = (): AdminProfile | null => {
  if (typeof window !== "undefined") {
    const userData = localStorage.getItem(STORAGE_KEY);
    return userData ? JSON.parse(userData) : null;
  }
  return null;
};

// ========== Auth Service ==========
export class AuthService {
  static async login(
    credentials: LoginCredentials
  ): Promise<{ user: { fullName: string } }> {
    try {
      const response = await apiClient.post<LoginResponse>(
        "/auth/login",
        credentials,
        { credentials: "include" }
      );

      console.log("Login response:", JSON.stringify(response, null, 2));

      const { success, data, message } = response;
      

      if (success && data && data.user && data.token) {
        const { user, token } = data;
        const fullName =
          user.firstName && user.lastName
            ? `${user.firstName} ${user.lastName}`
            : user.email;

        saveUserToStorage(user, token);

        if (typeof window !== "undefined") {
          window.location.href = "/dashboard";
        }

        return { user: { fullName } };
      }

      throw new Error(message || "Login failed: Invalid response");
    } catch (error: any) {
      console.error("Login error:", {
        message: error.message,
        status: error.status,
        code: error.code,
        stack: error.stack,
      });

      if (error.status === 401) {
        throw new Error("Invalid email or password");
      }

      if (error.status === 403) {
        if (error.message?.includes("verify your email")) {
          throw new Error("Please verify your email address");
        } else if (error.message?.includes("blocked")) {
          throw new Error(error.message);
        } else if (error.message?.includes("banned")) {
          throw new Error("Your account is banned. Contact support.");
        }
        throw new Error("Access denied. Admin privileges required.");
      }

      if (error.status === 429) {
        throw new Error("Too many login attempts. Please try again later.");
      }

      if (error.status === 0) {
        throw new Error("Network error, possibly due to server unavailability.");
      }

      throw new Error(error.message || "Login failed. Please try again.");
    }
  }

  static async logout(): Promise<void> {
    try {
      await apiClient.post("/api/logout", {}, { credentials: "include" });
    } catch (error) {
      console.error("Logout error:", error);
    } finally {
      removeUserFromStorage();
      if (typeof window !== "undefined") {
        window.location.href = "/login";
      }
    }
  }

  static async refreshToken(): Promise<string> {
    try {
      const response = await apiClient.post<{
        success: boolean;
        data?: { token: string };
      }>("/api/refresh", {}, { credentials: "include" });

      if (response.success && response.data?.token) {
        return response.data.token;
      }

      throw new Error("Token refresh failed");
    } catch (error) {
      await this.logout();
      throw error;
    }
  }

  static getCurrentUser(): AdminProfile | null {
    return getUserFromStorage();
  }

  static async isAuthenticated(): Promise<boolean> {
    const userData = getUserFromStorage();
    if (!userData) return false;

    try {
      const response = await apiClient.get<{
        success: boolean;
        data?: AdminProfile;
      }>("/api/me", { credentials: "include" });

      return response.success && !!response.data;
    } catch (error: any) {
      console.error("Authentication check error:", {
        message: error.message,
        status: error.status,
        code: error.code,
      });
      return !!userData; // Fallback to localStorage state
    }
  }
}
