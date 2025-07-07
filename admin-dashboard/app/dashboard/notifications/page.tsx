"use client"

import { useEffect, useState } from "react"
import { Bell } from "lucide-react"
import { useToast } from "@/components/ui/use-toast"
import { Card, CardContent } from "@/components/ui/card"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { Badge } from "@/components/ui/badge"
import { Skeleton } from "@/components/ui/skeleton"
import { Button } from "@/components/ui/button"
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogDescription,
  DialogFooter,
  DialogClose,
} from "@/components/ui/dialog"

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
  type: "admin_message"
  isRead: boolean
  sender: Sender
  createdAt: string
  readAt?: string
}

export default function NotificationPage() {
  const { toast } = useToast()
  const [notifications, setNotifications] = useState<Notification[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const [selectedNotification, setSelectedNotification] = useState<Notification | null>(null)

  useEffect(() => {
    fetchNotifications()
    const interval = setInterval(fetchNotifications, 30000)
    return () => clearInterval(interval)
  }, [])

  const fetchNotifications = async () => {
    try {
      setIsLoading(true)
      const response = await fetch("/api/admin/notifications", {
        headers: {
          Authorization: `Bearer ${localStorage.getItem("adminToken")}`,
        },
        cache: "no-store",
      })

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`)
      }

      const { data } = await response.json()
      setNotifications(data || [])
    } catch (error) {
      console.error("Fetch notifications error:", error)
      toast({
        title: "Error",
        description: "Failed to load notifications",
        variant: "destructive",
      })
    } finally {
      setIsLoading(false)
    }
  }
const markAsRead = async (id: string) => {
  try {
    const response = await fetch(`/api/admin/notifications/${id}/read`, {
      method: "PUT",
      headers: {
        Authorization: `Bearer ${localStorage.getItem("adminToken")}`,
        "Content-Type": "application/json",
      },
    })

    if (!response.ok) {
      const errorData = await response.json()
      throw new Error(errorData.message || "Failed to mark as read")
    }

    setNotifications(prev =>
      prev.map(n =>
        n._id === id ? { ...n, isRead: true, readAt: new Date().toISOString() } : n
      )
    )
  } catch (error) {
    console.error("Mark as read error:", error)
    toast({
      title: "Error",
      description: error instanceof Error ? error.message : "Could not mark notification as read",
      variant: "destructive",
    })
  }
}

  const handleNotificationClick = async (notification: Notification) => {
    setSelectedNotification(notification)
    if (!notification.isRead) {
      await markAsRead(notification._id)
    }
  }

  const NotificationSkeleton = () => (
    <Card className="bg-white shadow-sm">
      <CardContent className="p-5 flex items-start gap-4">
        <Skeleton className="h-10 w-10 rounded-full" />
        <div className="flex-grow space-y-2">
          <Skeleton className="h-4 w-2/3" />
          <Skeleton className="h-3 w-full" />
          <Skeleton className="h-3 w-1/2" />
        </div>
      </CardContent>
    </Card>
  )

  const sortedNotifications = [...notifications].sort((a, b) => {
    if (a.isRead !== b.isRead) return a.isRead ? 1 : -1
    return new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime()
  })

  return (
    <div className="container mx-auto py-10 px-4">
      <h1 className="text-3xl font-bold mb-8">📬 Admin Notifications</h1>

      <div className="space-y-4">
        {isLoading ? (
          <>
            <NotificationSkeleton />
            <NotificationSkeleton />
            <NotificationSkeleton />
          </>
        ) : sortedNotifications.length === 0 ? (
          <p className="text-center py-12 text-muted-foreground">No notifications available.</p>
        ) : (
          sortedNotifications.map(notification => (
            <Card
              key={notification._id}
              onClick={() => handleNotificationClick(notification)}
              className={`transition-all duration-200 shadow-sm border cursor-pointer ${
                !notification.isRead ? "bg-slate-50 hover:bg-slate-100" : "bg-white"
              }`}
            >
              <CardContent className="p-5">
                <div className="flex items-start gap-4">
                  <Bell className="h-5 w-5 text-purple-500 mt-1" />
                  <div className="flex-grow space-y-2">
                    <div className="flex justify-between items-start">
                      <h2 className="text-lg font-semibold text-gray-900">{notification.title}</h2>
                      {!notification.isRead && (
                        <Badge variant="destructive" className="text-xs rounded-full px-2">
                          unread
                        </Badge>
                      )}
                    </div>
                    <p className="text-sm text-gray-700 line-clamp-2">{notification.message}</p>
                    <div className="text-xs text-muted-foreground pt-2">
                      🕒 {new Date(notification.createdAt).toLocaleString()}
                    </div>
                  </div>
                </div>
              </CardContent>
            </Card>
          ))
        )}
      </div>

      <Dialog open={!!selectedNotification} onOpenChange={() => setSelectedNotification(null)}>
        <DialogContent className="max-w-xl">
          {selectedNotification && (
            <>
              <DialogHeader>
                <div className="flex items-center gap-3">
                  <Avatar className="h-10 w-10">
                    <AvatarImage
                      src={selectedNotification.sender.profilePicture || "/placeholder.svg"}
                      alt={`${selectedNotification.sender.firstName} ${selectedNotification.sender.lastName}`}
                    />
                    <AvatarFallback>
                      {selectedNotification.sender.firstName[0]}
                      {selectedNotification.sender.lastName[0]}
                    </AvatarFallback>
                  </Avatar>
                  <div>
                    <DialogTitle className="text-lg">{selectedNotification.title}</DialogTitle>
                    <DialogDescription className="text-sm text-muted-foreground">
                      Sent by{" "}
                      <span className="font-medium">
                        {selectedNotification.sender.firstName} {selectedNotification.sender.lastName}
                      </span>{" "}
                      ({selectedNotification.sender.role})<br />
                      📅 {new Date(selectedNotification.createdAt).toLocaleString()}
                    </DialogDescription>
                  </div>
                </div>
              </DialogHeader>

              <div className="mt-4 text-sm text-gray-800 whitespace-pre-line leading-relaxed">
                {selectedNotification.message}
              </div>

              <div className="mt-6 text-xs text-muted-foreground space-y-1">
                <p>🔖 Type: {selectedNotification.type.replace(/_/g, " ")}</p>
                <p>
                  {selectedNotification.isRead
                    ? `✅ Read at: ${new Date(selectedNotification.readAt!).toLocaleString()}`
                    : "❌ Not read yet"}
                </p>
              </div>

              <DialogFooter className="mt-6">
                <DialogClose asChild>
                  <Button variant="ghost">Close</Button>
                </DialogClose>
              </DialogFooter>
            </>
          )}
        </DialogContent>
      </Dialog>
    </div>
  )
}