"use client"

import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog"
import { Bell, User, FileText, MessageSquare, ExternalLink, Archive, Flag } from "lucide-react"

interface Sender {
  _id: string
  name: string
  avatar: string
  role: string
}

interface Notification {
  _id: string
  title: string
  message: string
  type: "signup" | "report" | "post" | "user"
  isRead: boolean
  sender: Sender
  createdAt: string
}

interface NotificationDetailDialogProps {
  notification: Notification | null
  isOpen: boolean
  onClose: () => void
}

export function NotificationDetailDialog({ notification, isOpen, onClose }: NotificationDetailDialogProps) {
  if (!notification) return null

  // Get icon based on notification type
  const getNotificationIcon = (type: string) => {
    switch (type) {
      case "signup":
        return <User className="h-5 w-5 text-blue-500" />
      case "report":
        return <FileText className="h-5 w-5 text-red-500" />
      case "post":
        return <MessageSquare className="h-5 w-5 text-green-500" />
      default:
        return <Bell className="h-5 w-5 text-gray-500" />
    }
  }

  // Get actions based on notification type
  const getNotificationActions = (type: string) => {
    switch (type) {
      case "signup":
        return (
          <>
            <Button variant="outline" className="flex items-center gap-2 bg-transparent">
              <User className="h-4 w-4" />
              View Profile
            </Button>
            <Button variant="outline" className="flex items-center gap-2 bg-transparent">
              <ExternalLink className="h-4 w-4" />
              Send Welcome Email
            </Button>
          </>
        )
      case "report":
        return (
          <>
            <Button variant="outline" className="flex items-center gap-2 bg-transparent">
              <FileText className="h-4 w-4" />
              View Report
            </Button>
            <Button variant="destructive" className="flex items-center gap-2">
              <Flag className="h-4 w-4" />
              Flag as Important
            </Button>
          </>
        )
      case "post":
        return (
          <>
            <Button variant="outline" className="flex items-center gap-2 bg-transparent">
              <MessageSquare className="h-4 w-4" />
              View Post
            </Button>
            <Button variant="outline" className="flex items-center gap-2 bg-transparent">
              <ExternalLink className="h-4 w-4" />
              Share
            </Button>
          </>
        )
      default:
        return (
          <Button variant="outline" className="flex items-center gap-2 bg-transparent">
            <ExternalLink className="h-4 w-4" />
            View Details
          </Button>
        )
    }
  }

  return (
    <Dialog open={isOpen} onOpenChange={onClose}>
      <DialogContent className="sm:max-w-[500px]">
        <DialogHeader>
          <div className="flex items-center gap-2">
            {getNotificationIcon(notification.type)}
            <DialogTitle>{notification.title}</DialogTitle>
          </div>
          <DialogDescription>
            <Badge variant="outline" className="mt-2 capitalize">
              {notification.type}
            </Badge>
          </DialogDescription>
        </DialogHeader>

        <div className="py-4">
          <div className="flex items-center gap-3 mb-4">
            <Avatar className="h-10 w-10">
              <AvatarImage src={notification.sender.avatar || "/placeholder.svg"} alt={notification.sender.name} />
              <AvatarFallback>{notification.sender.name.charAt(0)}</AvatarFallback>
            </Avatar>
            <div>
              <p className="font-medium">{notification.sender.name}</p>
              <p className="text-sm text-muted-foreground capitalize">{notification.sender.role}</p>
            </div>
          </div>

          <div className="bg-muted p-4 rounded-md mb-4">
            <p>{notification.message}</p>
          </div>

          <div className="text-sm text-muted-foreground">
            <p>
              <span className="font-medium">Received:</span> {new Date(notification.createdAt).toLocaleString()}
            </p>
            <p>
              <span className="font-medium">Status:</span> {notification.isRead ? "Read" : "Unread"}
            </p>
          </div>
        </div>

        <DialogFooter className="flex flex-col sm:flex-row gap-2">
          <Button variant="ghost" onClick={onClose} className="flex items-center gap-2">
            <Archive className="h-4 w-4" />
            Archive
          </Button>
          {getNotificationActions(notification.type)}
        </DialogFooter>
      </DialogContent>
    </Dialog>
  )
}
