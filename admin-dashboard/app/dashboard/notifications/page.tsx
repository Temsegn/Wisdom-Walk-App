"use client"

import { useEffect, useState } from "react"
import { Card, CardContent } from "@/components/ui/card"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { Badge } from "@/components/ui/badge"
import { Bell } from "lucide-react"
import { useToast } from "@/components/ui/use-toast"
import { Skeleton } from "@/components/ui/skeleton"

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
    })

    if (!response.ok) throw new Error("Failed to fetch notifications")

    const data = await response.json()
    setNotifications(data.data || [])
  } catch (error) {
    console.error(error)
    toast({
      title: "Error",
      description: "Failed to load notifications",
      variant: "destructive",
    })
  } finally {
    setIsLoading(false)
  }
}


  const markAsRead = async (notification: Notification) => {
    try {
      const response = await fetch(`/api/notifications/${notification._id}/read`, {
        method: "PUT",
        headers: {
          Authorization: `Bearer ${localStorage.getItem("adminToken")}`,
        },
      })
      if (!response.ok) throw new Error("Failed to mark as read")
      setNotifications(prev =>
        prev.map(n =>
          n._id === notification._id
            ? { ...n, isRead: true, readAt: new Date().toISOString() }
            : n
        )
      )
    } catch (error) {
      console.error(error)
      toast({
        title: "Error",
        description: "Failed to mark notification as read",
        variant: "destructive",
      })
    }
  }

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

  const sortedNotifications = [...notifications].sort((a, b) => {
    if (a.isRead !== b.isRead) return a.isRead ? 1 : -1
    return new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime()
  })

  return (
    <div className="container mx-auto py-8 px-4">
      <h1 className="text-3xl font-bold mb-6">Admin Messages</h1>

      <div className="space-y-4">
        {isLoading ? (
          <>
            <NotificationSkeleton />
            <NotificationSkeleton />
            <NotificationSkeleton />
          </>
        ) : sortedNotifications.length === 0 ? (
          <p className="text-center py-8 text-muted-foreground">No admin messages found.</p>
        ) : (
          sortedNotifications.map(notif => (
            <Card
              key={notif._id}
              className={`cursor-pointer transition-colors ${notif.isRead ? "bg-white" : "bg-slate-50 hover:bg-slate-100"}`}
              onClick={() => markAsRead(notif)}
            >
              <CardContent className="p-4 flex items-start gap-4">
                <div className="flex-shrink-0 mt-1">
                  <Bell className="h-5 w-5 text-purple-500" />
                </div>
                <div className="flex items-center gap-3 flex-grow">
                  <Avatar className="h-10 w-10">
                    <AvatarImage src={notif.sender.profilePicture || "/placeholder.svg"} alt={`${notif.sender.firstName} ${notif.sender.lastName}`} />
                    <AvatarFallback>
                      {notif.sender.firstName.charAt(0)}
                      {notif.sender.lastName.charAt(0)}
                    </AvatarFallback>
                  </Avatar>
                  <div className="flex-grow">
                    <div className="flex justify-between items-start">
                      <div>
                        <h3 className="font-semibold">{notif.title}</h3>
                        <p className="text-sm text-muted-foreground">{notif.message}</p>
                      </div>
                      {!notif.isRead && (
                        <Badge variant="destructive" className="rounded-full px-2">
                          New
                        </Badge>
                      )}
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
    </div>
  )
}
