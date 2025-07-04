"use client"

import { useState, useEffect, useRef } from "react"
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card"
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
  const [formData, setFormData] = useState({
    firstName: "",
    lastName: "",
    email: "",
  })
  const { toast } = useToast()
  const fileInputRef = useRef<HTMLInputElement>(null)

  useEffect(() => {
    const user = localStorage.getItem("adminUser")
    if (user) {
      try {
        const parsedUser = JSON.parse(user)
        setAdminUser(parsedUser)
        setFormData({
          firstName: parsedUser.firstName || "",
          lastName: parsedUser.lastName || "",
          email: parsedUser.email || "",
        })
      } catch (error) {
        console.error("Error parsing user data:", error)
      }
    }
  }, [])
const handlePhotoUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
  const file = e.target.files?.[0]
  if (!file) return

  const token = localStorage.getItem("adminToken")
  const form = new FormData()
  form.append("profilePicture", file)  // <-- changed from "photo" to "profilePicture"

  try {
    const response = await fetch("https://wisdom-walk-app.onrender.com/api/users/profile/photo", {
      method: "PUT",
      headers: {
        Authorization: `Bearer ${token}`,
        // DO NOT set Content-Type header here when sending FormData
      },
      body: form,
    })

    const data = await response.json()
    if (response.ok && data.profilePicture) {
      const updatedUser = { ...adminUser, profilePicture: data.profilePicture }
      setAdminUser(updatedUser)
      localStorage.setItem("adminUser", JSON.stringify(updatedUser))

      toast({
        title: "Success",
        description: "Profile photo updated successfully",
      })
    } else {
      throw new Error(data.message || "Failed to upload photo")
    }
  } catch (error) {
    toast({
      title: "Error",
      description: error instanceof Error ? error.message : "Upload failed",
      variant: "destructive",
    })
  }
}


  const handleProfileUpdate = async (e: React.FormEvent) => {
    e.preventDefault()
    const token = localStorage.getItem("adminToken")

    try {
      const response = await fetch("https://wisdom-walk-app.onrender.com/api/users/profile", {
        method: "PUT",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
        body: JSON.stringify(formData),
      })

      const data = await response.json()
      if (response.ok && data.success) {
        const updatedUser = { ...adminUser, ...formData }
        setAdminUser(updatedUser)
        localStorage.setItem("adminUser", JSON.stringify(updatedUser))

        toast({
          title: "Success",
          description: "Profile updated successfully",
        })
      } else {
        throw new Error(data.message || "Failed to update profile")
      }
    } catch (error) {
      toast({
        title: "Error",
        description: error instanceof Error ? error.message : "Update failed",
        variant: "destructive",
      })
    }
  }

  const handlePasswordChange = async (e: React.FormEvent) => {
    e.preventDefault()

    if (newPassword !== confirmPassword) {
      toast({
        title: "Error",
        description: "New passwords do not match",
        variant: "destructive",
      })
      return
    }

    setIsLoading(true)
    const token = localStorage.getItem("adminToken")

    try {
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
      })

      const data = await response.json()

      if (response.ok && data.success) {
        localStorage.removeItem("adminToken")
        localStorage.removeItem("adminUser")
        toast({
          title: "Success",
          description: "Password changed. Please login again.",
        })

        setCurrentPassword("")
        setNewPassword("")
        setConfirmPassword("")
        window.location.href = "/login"
      } else {
        throw new Error(data.message || "Password change failed")
      }
    } catch (error) {
      toast({
        title: "Error",
        description: error instanceof Error ? error.message : "Failed to change password",
        variant: "destructive",
      })
    } finally {
      setIsLoading(false)
    }
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
              <Avatar className="h-20 w-20 border-4 border-purple-400 shadow-md">
                <AvatarImage
                  src={adminUser.profilePicture}
                  alt={adminUser.firstName}
                  onError={(e) => (e.currentTarget.style.display = "none")}
                />
                <AvatarFallback className="text-2xl text-purple-600 bg-purple-100">
                  {adminUser.firstName?.[0]?.toUpperCase()}
                  {adminUser.lastName?.[0]?.toUpperCase()}
                </AvatarFallback>
              </Avatar>

              <Button
                variant="outline"
                size="sm"
                onClick={() => fileInputRef.current?.click()}
              >
                <Camera className="h-4 w-4 mr-2" />
                Change Photo
              </Button>
              <input
                type="file"
                accept="image/*"
                ref={fileInputRef}
                onChange={handlePhotoUpload}
                className="hidden"
              />
            </div>

            <form onSubmit={handleProfileUpdate} className="space-y-4">
              <div className="grid grid-cols-2 gap-4">
                <div className="space-y-2">
                  <Label htmlFor="firstName">First Name</Label>
                  <Input
                    id="firstName"
                    value={formData.firstName}
                    onChange={(e) => setFormData({ ...formData, firstName: e.target.value })}
                  />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="lastName">Last Name</Label>
                  <Input
                    id="lastName"
                    value={formData.lastName}
                    onChange={(e) => setFormData({ ...formData, lastName: e.target.value })}
                  />
                </div>
              </div>

              <div className="space-y-2">
                <Label htmlFor="email">Email</Label>
                <Input
                  id="email"
                  type="email"
                  value={formData.email}
                  onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                />
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
              {/* Current Password */}
              <div className="space-y-2">
                <Label htmlFor="currentPassword">Current Password</Label>
                <div className="relative">
                  <Input
                    id="currentPassword"
                    type={showCurrentPassword ? "text" : "password"}
                    value={currentPassword}
                    onChange={(e) => setCurrentPassword(e.target.value)}
                    required
                  />
                  <Button
                    type="button"
                    variant="ghost"
                    size="sm"
                    className="absolute right-0 top-0 h-full px-3 py-2"
                    onClick={() => setShowCurrentPassword(!showCurrentPassword)}
                  >
                    {showCurrentPassword ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
                  </Button>
                </div>
              </div>

              {/* New Password */}
              <div className="space-y-2">
                <Label htmlFor="newPassword">New Password</Label>
                <div className="relative">
                  <Input
                    id="newPassword"
                    type={showNewPassword ? "text" : "password"}
                    value={newPassword}
                    onChange={(e) => setNewPassword(e.target.value)}
                    required
                  />
                  <Button
                    type="button"
                    variant="ghost"
                    size="sm"
                    className="absolute right-0 top-0 h-full px-3 py-2"
                    onClick={() => setShowNewPassword(!showNewPassword)}
                  >
                    {showNewPassword ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
                  </Button>
                </div>
              </div>

              {/* Confirm Password */}
              <div className="space-y-2">
                <Label htmlFor="confirmPassword">Confirm New Password</Label>
                <div className="relative">
                  <Input
                    id="confirmPassword"
                    type={showConfirmPassword ? "text" : "password"}
                    value={confirmPassword}
                    onChange={(e) => setConfirmPassword(e.target.value)}
                    required
                  />
                  <Button
                    type="button"
                    variant="ghost"
                    size="sm"
                    className="absolute right-0 top-0 h-full px-3 py-2"
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

      {/* Notifications */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Bell className="h-5 w-5" />
            Notification Preferences
          </CardTitle>
          <CardDescription>Configure how you receive admin notifications.</CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          {["Email Notifications", "Report Alerts", "User Verification Alerts"].map((title, index) => (
            <div key={index}>
              <div className="flex items-center justify-between">
                <div>
                  <h4 className="font-medium">{title}</h4>
                  <p className="text-sm text-muted-foreground">Configure your preferences</p>
                </div>
                <Button variant="outline" size="sm">Configure</Button>
              </div>
              {index < 2 && <Separator />}
            </div>
          ))}
        </CardContent>
      </Card>
    </div>
  )
}
