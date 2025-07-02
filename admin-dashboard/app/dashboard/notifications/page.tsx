"use client"

import { useState, useEffect } from "react"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { Card, CardContent } from "@/components/ui/card"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { SendNotificationDialog } from "@/components/send-notification-dialog"
import { Bell, User, FileText, MessageSquare } from "lucide-react"
import { NotificationDetailDialog } from "@/components/notification-detail-dialog"
import { useToast } from "@/components/ui/use-toast"
import { Skeleton } from "@/components/ui/skeleton"

// Types
type NotificationType = "signup" | "report" | "post" | "user" | "admin_message"

interface Sender {
  _id: string
  firstName: string
  lastName: string
  profilePicture?: string
  role: string
}

interface Notification {
  _id: string
  title: string
  message: string
  type: NotificationType
  isRead: boolean
  sender: Sender
  createdAt: string
  readAt?: string
}

interface UnreadCounts {
  total: number
  signups: number
  reports: number
  posts: number
  users: number
}

export default function NotificationPage() {
  const { toast } = useToast()
  const [notifications, setNotifications] = useState<Notification[]>([])
  const [unreadCounts, setUnreadCounts] = useState<UnreadCounts>({
    total: 0,
    signups: 0,
    reports: 0,
    posts: 0,
    users: 0,
  })
  const [activeTab, setActiveTab] = useState("all")
  const [allUsers, setAllUsers] = useState([])
  const [isDialogOpen, setIsDialogOpen] = useState(false)
  const [selectedNotification, setSelectedNotification] = useState<Notification | null>(null)
  const [isLoading, setIsLoading] = useState(true)
  const [isSending, setIsSending] = useState(false)

  // Fetch notifications from backend
  const fetchNotifications = async () => {
    try {
      setIsLoading(true)
      const response = await fetch('/api/admin/notifications', {
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('adminToken')}`
        }
      })
      
      if (!response.ok) throw new Error('Failed to fetch notifications')
      
      const data = await response.json()
      setNotifications(data.notifications || [])
      
      // Calculate unread counts
      const counts = { total: 0, signups: 0, reports: 0, posts: 0, users: 0 }
      data.notifications.forEach((n: Notification) => {
        if (!n.isRead) {
          counts.total++
          if (n.type === "signup") counts.signups++
          else if (n.type === "report") counts.reports++
          else if (n.type === "post") counts.posts++
          else if (n.type === "user") counts.users++
        }
      })
      setUnreadCounts(counts)
      
    } catch (error) {
      console.error('Error fetching notifications:', error)
      toast({
        title: "Error",
        description: "Failed to load notifications",
        variant: "destructive",
      })
    } finally {
      setIsLoading(false)
    }
  }

  // Fetch users from backend
  const fetchUsers = async () => {
    try {
      const response = await fetch('/api/admin/users', {
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('adminToken')}`
        }
      })
      
      if (!response.ok) throw new Error('Failed to fetch users')
      
      const data = await response.json()
      setAllUsers(data.users || [])
    } catch (error) {
      console.error('Error fetching users:', error)
      toast({
        title: "Error",
        description: "Failed to load users",
        variant: "destructive",
      })
    }
  }

  // Initial data fetch
  useEffect(() => {
    fetchNotifications()
    fetchUsers()
    
    // Set up polling for new notifications
    const interval = setInterval(fetchNotifications, 30000) // Refresh every 30 seconds
    return () => clearInterval(interval)
  }, [])

  // Mark notification as read
  const markAsRead = async (notificationId: string) => {
    try { 
      const response = await fetch(`/api/notifications/${notificationId}/read`, {
        method: 'PUT',
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('adminToken')}`
        }
      })
      
      if (!response.ok) throw new Error('Failed to mark as read')
      
      // Update local state
      setNotifications(prev => prev.map(n => 
        n._id === notificationId ? { ...n, isRead: true, readAt: new Date().toISOString() } : n
      ))
      
      // Update counts
      const notification = notifications.find(n => n._id === notificationId)
      if (notification && !notification.isRead) {
        setUnreadCounts(prev => ({
          ...prev,
          total: Math.max(0, prev.total - 1),
          [notification.type]: Math.max(0, prev[notification.type as keyof UnreadCounts] - 1)
        }))
      }
      
    } catch (error) {
      console.error('Error marking notification as read:', error)
      toast({
        title: "Error",
        description: "Failed to mark notification as read",
        variant: "destructive",
      })
    }
  }

  // Handle sending new notification
  const handleSendNotification = async (newNotification: {
    title: string
    message: string
    recipientType: string
    specificUsers?: string[]
    priority?: string
  }) => {
    try {
      setIsSending(true)
      
      const response = await fetch('/api/admin/notifications/send', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${localStorage.getItem('adminToken')}`
        },
        body: JSON.stringify({
          title: newNotification.title,
          message: newNotification.message,
          recipients: newNotification.recipientType === 'specific' 
            ? newNotification.specificUsers 
            : newNotification.recipientType,
          priority: newNotification.priority || 'normal'
        })
      })
      
      if (!response.ok) throw new Error('Failed to send notification')
      
      toast({
        title: "Success",
        description: "Notification sent successfully",
      })
      
      // Refresh notifications
      await fetchNotifications()
      setIsDialogOpen(false)
      
    } catch (error) {
      console.error('Error sending notification:', error)
      toast({
        title: "Error",
        description: "Failed to send notification",
        variant: "destructive",
      })
    } finally {
      setIsSending(false)
    }
  }

  // Sort notifications to put unread at the top
  const sortedNotifications = [...notifications].sort((a, b) => {
    // First sort by read status (unread first)
    if (a.isRead !== b.isRead) return a.isRead ? 1 : -1
    // Then sort by date (newest first)
    return new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime()
  })

  // Filter notifications based on active tab
  const filteredNotifications = activeTab === "all" 
    ? sortedNotifications 
    : sortedNotifications.filter(n => n.type === activeTab)

  // Get icon based on notification type
  const getNotificationIcon = (type: NotificationType) => {
    switch (type) {
      case "signup": return <User className="h-5 w-5 text-blue-500" />
      case "report": return <FileText className="h-5 w-5 text-red-500" />
      case "post": return <MessageSquare className="h-5 w-5 text-green-500" />
      case "admin_message": return <Bell className="h-5 w-5 text-purple-500" />
      default: return <Bell className="h-5 w-5 text-gray-500" />
    }
  }

  // Get color based on notification type
  const getNotificationColor = (type: NotificationType) => {
    switch (type) {
      case "signup": return "bg-blue-50 hover:bg-blue-100"
      case "report": return "bg-red-50 hover:bg-red-100"
      case "post": return "bg-green-50 hover:bg-green-100"
      case "admin_message": return "bg-purple-50 hover:bg-purple-100"
      default: return "bg-gray-50 hover:bg-gray-100"
    }
  }

  // Skeleton loader for notifications
  const NotificationSkeleton = () => (
    <Card className="bg-white">
      <CardContent className="p-4 flex items-start gap-4">
        <Skeleton className="h-5 w-5 rounded-full" />
        <div className="flex-grow space-y-2">
          <Skeleton className="h-4 w-3/4" />
          <Skeleton className="h-3 w-full" />
          <Skeleton className="h-3 w-1/2" />
        </div>
      </CardContent>
    </Card>
  )

  return (
    <div className="container mx-auto py-8 px-4">
      <div className="flex flex-col md:flex-row justify-between items-start md:items-center mb-6 gap-4">
        <div className="flex items-center">
          <h1 className="text-3xl font-bold">Admin Notifications</h1>
          {!isLoading && (
            <Badge variant="destructive" className="ml-2 text-md px-2.5 py-1">
              {unreadCounts.total}
            </Badge>
          )}
        </div>
        <Button onClick={() => setIsDialogOpen(true)}>Send Notification</Button>
      </div>

      <Tabs defaultValue="all" value={activeTab} onValueChange={setActiveTab} className="w-full">
        <TabsList className="grid grid-cols-2 md:grid-cols-5 mb-6">
          <TabsTrigger value="all" className="relative">
            All
            {!isLoading && unreadCounts.total > 0 && (
              <Badge variant="destructive" className="ml-2">
                {unreadCounts.total}
              </Badge>
            )}
          </TabsTrigger>
          <TabsTrigger value="signup" className="relative">
            New Users
            {!isLoading && unreadCounts.signups > 0 && (
              <Badge variant="destructive" className="ml-2">
                {unreadCounts.signups}
              </Badge>
            )}
          </TabsTrigger>
          <TabsTrigger value="report" className="relative">
            Reports
            {!isLoading && unreadCounts.reports > 0 && (
              <Badge variant="destructive" className="ml-2">
                {unreadCounts.reports}
              </Badge>
            )}
          </TabsTrigger>
          <TabsTrigger value="post" className="relative">
            Posts
            {!isLoading && unreadCounts.posts > 0 && (
              <Badge variant="destructive" className="ml-2">
                {unreadCounts.posts}
              </Badge>
            )}
          </TabsTrigger>
          <TabsTrigger value="admin_message" className="relative">
            Admin Messages
          </TabsTrigger>
        </TabsList>

        <TabsContent value={activeTab} className="mt-0">
          <div className="space-y-4">
            {isLoading ? (
              <>
                <NotificationSkeleton />
                <NotificationSkeleton />
                <NotificationSkeleton />
              </>
            ) : filteredNotifications.length === 0 ? (
              <p className="text-center py-8 text-muted-foreground">No notifications found.</p>
            ) : (
              filteredNotifications.map((notif) => (
                <Card
                  key={notif._id}
                  className={`cursor-pointer transition-colors ${
                    notif.isRead ? "bg-white" : getNotificationColor(notif.type)
                  }`}
                  onClick={() => {
                    handleNotificationClick(notif)
                    markAsRead(notif._id)
                  }}
                >
                  <CardContent className="p-4 flex items-start gap-4">
                    <div className="flex-shrink-0 mt-1">
                      {getNotificationIcon(notif.type)}
                    </div>

                    <div className="flex items-center gap-3 flex-grow">
                      <Avatar className="h-10 w-10">
                        <AvatarImage 
                          src={notif.sender.profilePicture || "/placeholder.svg"} 
                          alt={`${notif.sender.firstName} ${notif.sender.lastName}`} 
                        />
                        <AvatarFallback>
                          {notif.sender.firstName.charAt(0)}{notif.sender.lastName.charAt(0)}
                        </AvatarFallback>
                      </Avatar>

                      <div className="flex-grow">
                        <div className="flex justify-between items-start">
                          <div>
                            <h3 className="font-semibold">{notif.title}</h3>
                            <p className="text-sm text-muted-foreground">{notif.message}</p>
                          </div>

                          <div className="flex items-center gap-2">
                            {!notif.isRead && (
                              <Badge variant="destructive" className="rounded-full px-2">
                                New
                              </Badge>
                            )}
                            <Badge variant="outline" className="capitalize">
                              {notif.type.replace('_', ' ')}
                            </Badge>
                          </div>
                        </div>

                        <p className="text-xs text-muted-foreground mt-1">
                          {new Date(notif.createdAt).toLocaleString()}
                          {notif.readAt && (
                            <span className="ml-2">Read: {new Date(notif.readAt).toLocaleTimeString()}</span>
                          )}
                        </p>
                      </div>
                    </div>
                  </CardContent>
                </Card>
              ))
            )}
          </div>
        </TabsContent>
      </Tabs>

      <SendNotificationDialog
        isOpen={isDialogOpen}
        onClose={() => setIsDialogOpen(false)}
        onSend={handleSendNotification}
        users={allUsers}
        isSending={isSending}
      />

      <NotificationDetailDialog
        notification={selectedNotification}
        isOpen={!!selectedNotification}
        onClose={() => setSelectedNotification(null)}
      />
    </div>
  )
}