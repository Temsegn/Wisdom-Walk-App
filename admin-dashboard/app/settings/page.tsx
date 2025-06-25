"use client"

import { useState } from "react"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { SidebarInset, SidebarTrigger } from "@/components/ui/sidebar"
import { Separator } from "@/components/ui/separator"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { useToast } from "@/hooks/use-toast"
import { Camera, User, Lock, Settings, Save } from "lucide-react"

interface AdminProfile {
  id: string
  username: string
  email: string
  fullName: string
  profilePhoto: string
  role: string
  lastLogin: string
  createdAt: string
}

const mockAdminProfile: AdminProfile = {
  id: "admin-1",
  username: "admin_user",
  email: "admin@example.com",
  fullName: "Administrator User",
  profilePhoto: "/placeholder.svg?height=100&width=100",
  role: "Super Admin",
  lastLogin: "2024-01-25T10:30:00Z",
  createdAt: "2023-06-15T09:00:00Z",
}

export default function SettingsPage() {
  const [profile, setProfile] = useState<AdminProfile>(mockAdminProfile)
  const [isEditing, setIsEditing] = useState(false)
  const [passwords, setPasswords] = useState({
    current: "",
    new: "",
    confirm: "",
  })
  const [profileForm, setProfileForm] = useState({
    username: profile.username,
    fullName: profile.fullName,
    email: profile.email,
  })
  const { toast } = useToast()

  const handleProfileUpdate = () => {
    setProfile({
      ...profile,
      username: profileForm.username,
      fullName: profileForm.fullName,
      email: profileForm.email,
    })
    setIsEditing(false)
    toast({
      title: "Profile Updated",
      description: "Your profile information has been successfully updated.",
    })
  }

  const handlePasswordChange = () => {
    if (passwords.new !== passwords.confirm) {
      toast({
        title: "Password Mismatch",
        description: "New password and confirmation password do not match.",
        variant: "destructive",
      })
      return
    }

    if (passwords.new.length < 8) {
      toast({
        title: "Password Too Short",
        description: "Password must be at least 8 characters long.",
        variant: "destructive",
      })
      return
    }

    setPasswords({ current: "", new: "", confirm: "" })
    toast({
      title: "Password Changed",
      description: "Your password has been successfully updated.",
    })
  }

  const handlePhotoUpload = () => {
    // Simulate photo upload
    const newPhotoUrl = "/placeholder.svg?height=100&width=100&text=New"
    setProfile({ ...profile, profilePhoto: newPhotoUrl })
    toast({
      title: "Photo Updated",
      description: "Your profile photo has been successfully updated.",
    })
  }

  return (
    <SidebarInset>
      <header className="flex h-16 shrink-0 items-center gap-2 border-b px-4">
        <SidebarTrigger className="-ml-1" />
        <Separator orientation="vertical" className="mr-2 h-4" />
        <h1 className="text-lg font-semibold">Profile Settings</h1>
      </header>

      <div className="flex-1 space-y-4 p-4 md:p-8 pt-6">
        <div className="max-w-4xl mx-auto">
          <Tabs defaultValue="profile" className="space-y-4">
            <TabsList className="grid w-full grid-cols-3">
              <TabsTrigger value="profile">
                <User className="h-4 w-4 mr-2" />
                Profile
              </TabsTrigger>
              <TabsTrigger value="security">
                <Lock className="h-4 w-4 mr-2" />
                Security
              </TabsTrigger>
              <TabsTrigger value="preferences">
                <Settings className="h-4 w-4 mr-2" />
                Preferences
              </TabsTrigger>
            </TabsList>

            {/* Profile Tab */}
            <TabsContent value="profile" className="space-y-4">
              <Card>
                <CardHeader>
                  <CardTitle>Profile Information</CardTitle>
                  <CardDescription>Update your personal information and profile photo</CardDescription>
                </CardHeader>
                <CardContent className="space-y-6">
                  {/* Profile Photo Section */}
                  <div className="flex items-center space-x-4">
                    <Avatar className="h-20 w-20">
                      <AvatarImage src={profile.profilePhoto || "/placeholder.svg"} alt="Profile" />
                      <AvatarFallback className="text-lg">
                        {profile.fullName
                          .split(" ")
                          .map((n) => n[0])
                          .join("")}
                      </AvatarFallback>
                    </Avatar>
                    <div className="space-y-2">
                      <h3 className="text-lg font-medium">{profile.fullName}</h3>
                      <p className="text-sm text-muted-foreground">{profile.role}</p>
                      <Button variant="outline" size="sm" onClick={handlePhotoUpload}>
                        <Camera className="h-4 w-4 mr-2" />
                        Change Photo
                      </Button>
                    </div>
                  </div>

                  <Separator />

                  {/* Profile Form */}
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div className="space-y-2">
                      <Label htmlFor="fullName">Full Name</Label>
                      <Input
                        id="fullName"
                        value={isEditing ? profileForm.fullName : profile.fullName}
                        onChange={(e) => setProfileForm({ ...profileForm, fullName: e.target.value })}
                        disabled={!isEditing}
                      />
                    </div>
                    <div className="space-y-2">
                      <Label htmlFor="username">Username</Label>
                      <Input
                        id="username"
                        value={isEditing ? profileForm.username : profile.username}
                        onChange={(e) => setProfileForm({ ...profileForm, username: e.target.value })}
                        disabled={!isEditing}
                      />
                    </div>
                    <div className="space-y-2">
                      <Label htmlFor="email">Email Address</Label>
                      <Input
                        id="email"
                        type="email"
                        value={isEditing ? profileForm.email : profile.email}
                        onChange={(e) => setProfileForm({ ...profileForm, email: e.target.value })}
                        disabled={!isEditing}
                      />
                    </div>
                    <div className="space-y-2">
                      <Label htmlFor="role">Role</Label>
                      <Input id="role" value={profile.role} disabled />
                    </div>
                  </div>

                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div className="space-y-2">
                      <Label>Last Login</Label>
                      <p className="text-sm text-muted-foreground">{new Date(profile.lastLogin).toLocaleString()}</p>
                    </div>
                    <div className="space-y-2">
                      <Label>Account Created</Label>
                      <p className="text-sm text-muted-foreground">
                        {new Date(profile.createdAt).toLocaleDateString()}
                      </p>
                    </div>
                  </div>

                  <div className="flex justify-end space-x-2">
                    {isEditing ? (
                      <>
                        <Button variant="outline" onClick={() => setIsEditing(false)}>
                          Cancel
                        </Button>
                        <Button onClick={handleProfileUpdate}>
                          <Save className="h-4 w-4 mr-2" />
                          Save Changes
                        </Button>
                      </>
                    ) : (
                      <Button onClick={() => setIsEditing(true)}>Edit Profile</Button>
                    )}
                  </div>
                </CardContent>
              </Card>
            </TabsContent>

            {/* Security Tab */}
            <TabsContent value="security" className="space-y-4">
              <Card>
                <CardHeader>
                  <CardTitle>Change Password</CardTitle>
                  <CardDescription>Update your password to keep your account secure</CardDescription>
                </CardHeader>
                <CardContent className="space-y-4">
                  <div className="space-y-2">
                    <Label htmlFor="currentPassword">Current Password</Label>
                    <Input
                      id="currentPassword"
                      type="password"
                      value={passwords.current}
                      onChange={(e) => setPasswords({ ...passwords, current: e.target.value })}
                      placeholder="Enter your current password"
                    />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="newPassword">New Password</Label>
                    <Input
                      id="newPassword"
                      type="password"
                      value={passwords.new}
                      onChange={(e) => setPasswords({ ...passwords, new: e.target.value })}
                      placeholder="Enter your new password"
                    />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="confirmPassword">Confirm New Password</Label>
                    <Input
                      id="confirmPassword"
                      type="password"
                      value={passwords.confirm}
                      onChange={(e) => setPasswords({ ...passwords, confirm: e.target.value })}
                      placeholder="Confirm your new password"
                    />
                  </div>
                  <div className="bg-muted p-3 rounded-md">
                    <h4 className="text-sm font-medium mb-2">Password Requirements:</h4>
                    <ul className="text-xs text-muted-foreground space-y-1">
                      <li>• At least 8 characters long</li>
                      <li>• Include uppercase and lowercase letters</li>
                      <li>• Include at least one number</li>
                      <li>• Include at least one special character</li>
                    </ul>
                  </div>
                  <Button onClick={handlePasswordChange} className="w-full">
                    Update Password
                  </Button>
                </CardContent>
              </Card>

              <Card>
                <CardHeader>
                  <CardTitle>Two-Factor Authentication</CardTitle>
                  <CardDescription>Add an extra layer of security to your account</CardDescription>
                </CardHeader>
                <CardContent>
                  <div className="flex items-center justify-between">
                    <div>
                      <p className="font-medium">Two-Factor Authentication</p>
                      <p className="text-sm text-muted-foreground">
                        Secure your account with 2FA using an authenticator app
                      </p>
                    </div>
                    <Button variant="outline">Enable 2FA</Button>
                  </div>
                </CardContent>
              </Card>
            </TabsContent>

            {/* Preferences Tab */}
            <TabsContent value="preferences" className="space-y-4">
              <Card>
                <CardHeader>
                  <CardTitle>Notification Preferences</CardTitle>
                  <CardDescription>Manage how you receive notifications</CardDescription>
                </CardHeader>
                <CardContent className="space-y-4">
                  <div className="flex items-center justify-between">
                    <div>
                      <p className="font-medium">Email Notifications</p>
                      <p className="text-sm text-muted-foreground">Receive notifications via email</p>
                    </div>
                    <Button variant="outline" size="sm">
                      Configure
                    </Button>
                  </div>
                  <Separator />
                  <div className="flex items-center justify-between">
                    <div>
                      <p className="font-medium">System Alerts</p>
                      <p className="text-sm text-muted-foreground">Get notified about system issues</p>
                    </div>
                    <Button variant="outline" size="sm">
                      Configure
                    </Button>
                  </div>
                  <Separator />
                  <div className="flex items-center justify-between">
                    <div>
                      <p className="font-medium">User Activity</p>
                      <p className="text-sm text-muted-foreground">Notifications about user activities</p>
                    </div>
                    <Button variant="outline" size="sm">
                      Configure
                    </Button>
                  </div>
                </CardContent>
              </Card>

              <Card>
                <CardHeader>
                  <CardTitle>Display Preferences</CardTitle>
                  <CardDescription>Customize your dashboard appearance</CardDescription>
                </CardHeader>
                <CardContent className="space-y-4">
                  <div className="flex items-center justify-between">
                    <div>
                      <p className="font-medium">Theme</p>
                      <p className="text-sm text-muted-foreground">Choose your preferred theme</p>
                    </div>
                    <Button variant="outline" size="sm">
                      Light Mode
                    </Button>
                  </div>
                  <Separator />
                  <div className="flex items-center justify-between">
                    <div>
                      <p className="font-medium">Language</p>
                      <p className="text-sm text-muted-foreground">Select your language</p>
                    </div>
                    <Button variant="outline" size="sm">
                      English
                    </Button>
                  </div>
                </CardContent>
              </Card>
            </TabsContent>
          </Tabs>
        </div>
      </div>
    </SidebarInset>
  )
}
