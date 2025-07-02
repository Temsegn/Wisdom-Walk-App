"use client"

import type React from "react"

import { useState, useEffect } from "react"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { Separator } from "@/components/ui/separator"
import { Eye, EyeOff, Camera, Save, User, Lock, Bell } from "lucide-react"
import { useToast } from "@/hooks/use-toast"

export default function SettingsPage() {
  const [adminUser, setAdminUser] = useState<any>(null)
  const [currentPassword, setCurrentPassword] = useState("")
  const [newPassword, setNewPassword] = useState("")
  const [confirmPassword, setConfirmPassword] = useState("")
  const [showCurrentPassword, setShowCurrentPassword] = useState(false)
  const [showNewPassword, setShowNewPassword] = useState(false)
  const [showConfirmPassword, setShowConfirmPassword] = useState(false)
  const [isLoading, setIsLoading] = useState(false)
  const { toast } = useToast()

  useEffect(() => {
    const user = localStorage.getItem("adminUser")
    if (user) {
      try {
        setAdminUser(JSON.parse(user))
      } catch (error) {
        console.error("Error parsing user data:", error)
      }
    }
  }, [])
  const handlePasswordChange = async (e: React.FormEvent) => {
  e.preventDefault();

  // Validate inputs
  if (newPassword !== confirmPassword) {
    toast({
      title: "Error",
      description: "New passwords do not match",
      variant: "destructive",
    });
    return;
  }

  setIsLoading(true);

  try {
    const token = localStorage.getItem("adminToken");
    const response = await fetch("https://wisdom-walk-app.onrender.com/api/auth/change-password", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${token}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        currentPassword,
        newPassword,
      }),
    });

    // Debugging logs
    console.log("Response status:", response.status);
    const data = await response.json();
    console.log("Response data:", data);

    // Check for successful response (200-299 range)
    if (response.ok) {
      if (data.success) {
        // Remove admin token and user data from localStorage
        localStorage.removeItem("adminToken");
        localStorage.removeItem("adminUser");
        
        toast({
          title: "Success",
          description: "Password changed successfully. Please login again.",
        });
        
        // Reset form
        setCurrentPassword("");
        setNewPassword("");
        setConfirmPassword("");
        
        // Redirect to login page
        window.location.href = "http://localhost:3000/login";
        return;
      } else {
        // Handle case where status is 200 but success is false
        throw new Error(data.message || "Password change failed");
      }
    }

    // Handle HTTP error statuses
    if (response.status === 401) {
      throw new Error("Current password is incorrect");
    } else if (response.status === 400) {
      throw new Error(data.message || "Invalid request");
    } else if (response.status === 500) {
      throw new Error("Server error occurred");
    }

    // Fallback error
    throw new Error(`Request failed with status ${response.status}`);

  } catch (error) {
    console.error("Error changing password:", error);
    toast({
      title: "Error",
      description: error instanceof Error ? error.message : "Failed to change password",
      variant: "destructive",
    });
  } finally {
    setIsLoading(false);
  }
};

  const handleProfileUpdate = async (e: React.FormEvent) => {
    e.preventDefault()
    // This would typically 
    toast({
      title: "Info",
      description: "Profile update functionality would be implemented here",
    })
  }

  if (!adminUser) {
    return (
      <div className="flex items-center justify-center min-h-[400px]">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-purple-600"></div>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold tracking-tight">Settings</h1>
        <p className="text-muted-foreground">Manage your admin account settings and preferences.</p>
      </div>

      <div className="grid gap-6 md:grid-cols-2">
        {/* Profile Settings */}
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <User className="h-5 w-5" />
              Profile Information
            </CardTitle>
            <CardDescription>Update your profile information and photo.</CardDescription>
          </CardHeader>
          <CardContent className="space-y-6">
            <div className="flex items-center space-x-4">
              <Avatar className="h-20 w-20">
                <AvatarImage src={adminUser.profilePicture || "/placeholder.svg"} alt={adminUser.firstName} />
                <AvatarFallback className="text-lg">
                  {adminUser.firstName?.[0]}
                  {adminUser.lastName?.[0]}
                </AvatarFallback>
              </Avatar>
              <Button variant="outline" size="sm">
                <Camera className="h-4 w-4 mr-2" />
                Change Photo
              </Button>
            </div>

            <form onSubmit={handleProfileUpdate} className="space-y-4">
              <div className="grid grid-cols-2 gap-4">
                <div className="space-y-2">
                  <Label htmlFor="firstName">First Name</Label>
                  <Input id="firstName" defaultValue={adminUser.firstName} placeholder="First name" />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="lastName">Last Name</Label>
                  <Input id="lastName" defaultValue={adminUser.lastName} placeholder="Last name" />
                </div>
              </div>

              <div className="space-y-2">
                <Label htmlFor="email">Email</Label>
                <Input id="email" type="email" defaultValue={adminUser.email} placeholder="Email address" />
              </div>

              <Button type="submit" className="w-full">
                <Save className="h-4 w-4 mr-2" />
                Update Profile
              </Button>
            </form>
          </CardContent>
        </Card>

        {/* Security Settings */}
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <Lock className="h-5 w-5" />
              Security Settings
            </CardTitle>
            <CardDescription>Change your password and manage security preferences.</CardDescription>
          </CardHeader>
          <CardContent>
            <form onSubmit={handlePasswordChange} className="space-y-4">
              <div className="space-y-2">
                <Label htmlFor="currentPassword">Current Password</Label>
                <div className="relative">
                  <Input
                    id="currentPassword"
                    type={showCurrentPassword ? "text" : "password"}
                    value={currentPassword}
                    onChange={(e) => setCurrentPassword(e.target.value)}
                    placeholder="Enter current password"
                    required
                  />
                  <Button
                    type="button"
                    variant="ghost"
                    size="sm"
                    className="absolute right-0 top-0 h-full px-3 py-2 hover:bg-transparent"
                    onClick={() => setShowCurrentPassword(!showCurrentPassword)}
                  >
                    {showCurrentPassword ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
                  </Button>
                </div>
              </div>

              <div className="space-y-2">
                <Label htmlFor="newPassword">New Password</Label>
                <div className="relative">
                  <Input
                    id="newPassword"
                    type={showNewPassword ? "text" : "password"}
                    value={newPassword}
                    onChange={(e) => setNewPassword(e.target.value)}
                    placeholder="Enter new password"
                    required
                  />
                  <Button
                    type="button"
                    variant="ghost"
                    size="sm"
                    className="absolute right-0 top-0 h-full px-3 py-2 hover:bg-transparent"
                    onClick={() => setShowNewPassword(!showNewPassword)}
                  >
                    {showNewPassword ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
                  </Button>
                </div>
              </div>

              <div className="space-y-2">
                <Label htmlFor="confirmPassword">Confirm New Password</Label>
                <div className="relative">
                  <Input
                    id="confirmPassword"
                    type={showConfirmPassword ? "text" : "password"}
                    value={confirmPassword}
                    onChange={(e) => setConfirmPassword(e.target.value)}
                    placeholder="Confirm new password"
                    required
                  />
                  <Button
                    type="button"
                    variant="ghost"
                    size="sm"
                    className="absolute right-0 top-0 h-full px-3 py-2 hover:bg-transparent"
                    onClick={() => setShowConfirmPassword(!showConfirmPassword)}
                  >
                    {showConfirmPassword ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
                  </Button>
                </div>
              </div>

              <Button type="submit" className="w-full" disabled={isLoading}>
                {isLoading ? "Changing Password..." : "Change Password"}
              </Button>
            </form>
          </CardContent>
        </Card>
      </div>

      {/* Additional Settings */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Bell className="h-5 w-5" />
            Notification Preferences
          </CardTitle>
          <CardDescription>Configure how you receive admin notifications.</CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="flex items-center justify-between">
            <div>
              <h4 className="font-medium">Email Notifications</h4>
              <p className="text-sm text-muted-foreground">Receive email alerts for important admin activities</p>
            </div>
            <Button variant="outline" size="sm">
              Configure
            </Button>
          </div>

          <Separator />

          <div className="flex items-center justify-between">
            <div>
              <h4 className="font-medium">Report Alerts</h4>
              <p className="text-sm text-muted-foreground">Get notified immediately when new reports are submitted</p>
            </div>
            <Button variant="outline" size="sm">
              Configure
            </Button>
          </div>

          <Separator />

          <div className="flex items-center justify-between">
            <div>
              <h4 className="font-medium">User Verification Alerts</h4>
              <p className="text-sm text-muted-foreground">Notifications for pending user verifications</p>
            </div>
            <Button variant="outline" size="sm">
              Configure
            </Button>
          </div>
        </CardContent>
      </Card>
    </div>
  )
}
