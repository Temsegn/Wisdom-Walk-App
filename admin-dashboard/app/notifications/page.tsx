"use client"

import { useState } from "react"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { SidebarInset, SidebarTrigger } from "@/components/ui/sidebar"
import { Separator } from "@/components/ui/separator"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Badge } from "@/components/ui/badge"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog"
import { Label } from "@/components/ui/label"
import { Textarea } from "@/components/ui/textarea"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { useToast } from "@/hooks/use-toast"
import { Bell, Send, Users, Eye, Trash2, Plus, AlertCircle, CheckCircle, Info } from "lucide-react"

interface Notification {
  id: string
  title: string
  message: string
  type: "info" | "warning" | "success" | "error"
  target: "all" | "active" | "pending" | "moderators"
  sentDate: string
  sentBy: string
  status: "sent" | "draft" | "scheduled"
  recipients: number
  readCount: number
}

const mockNotifications: Notification[] = [
  {
    id: "1",
    title: "System Maintenance Scheduled",
    message:
      "We will be performing scheduled maintenance on our servers this weekend. Please expect brief service interruptions.",
    type: "warning",
    target: "all",
    sentDate: "2024-01-20",
    sentBy: "System Admin",
    status: "sent",
    recipients: 2847,
    readCount: 2156,
  },
  {
    id: "2",
    title: "New Features Available",
    message: "We've released exciting new features! Check out the latest updates in your dashboard.",
    type: "success",
    target: "active",
    sentDate: "2024-01-18",
    sentBy: "Product Team",
    status: "sent",
    recipients: 2234,
    readCount: 1876,
  },
  {
    id: "3",
    title: "Community Guidelines Update",
    message: "Our community guidelines have been updated. Please review the changes to ensure compliance.",
    type: "info",
    target: "all",
    sentDate: "2024-01-15",
    sentBy: "Community Team",
    status: "sent",
    recipients: 2847,
    readCount: 1923,
  },
  {
    id: "4",
    title: "Welcome New Users",
    message: "Welcome to our platform! Here's everything you need to know to get started.",
    type: "info",
    target: "pending",
    sentDate: "2024-01-22",
    sentBy: "Onboarding Team",
    status: "draft",
    recipients: 0,
    readCount: 0,
  },
]

export default function NotificationsPage() {
  const [notifications, setNotifications] = useState<Notification[]>(mockNotifications)
  const [isCreateDialogOpen, setIsCreateDialogOpen] = useState(false)
  const [isViewDialogOpen, setIsViewDialogOpen] = useState(false)
  const [isDeleteDialogOpen, setIsDeleteDialogOpen] = useState(false)
  const [selectedNotification, setSelectedNotification] = useState<Notification | null>(null)
  const [newNotification, setNewNotification] = useState<Partial<Notification>>({
    type: "info",
    target: "all",
    status: "draft",
  })
  const { toast } = useToast()

  const handleCreateNotification = () => {
    if (newNotification.title && newNotification.message) {
      const notification: Notification = {
        id: Date.now().toString(),
        title: newNotification.title,
        message: newNotification.message,
        type: newNotification.type || "info",
        target: newNotification.target || "all",
        sentDate: new Date().toISOString().split("T")[0],
        sentBy: "Admin",
        status: "sent",
        recipients: getRecipientCount(newNotification.target || "all"),
        readCount: 0,
      }
      setNotifications([notification, ...notifications])
      setNewNotification({ type: "info", target: "all", status: "draft" })
      setIsCreateDialogOpen(false)
      toast({
        title: "Notification Sent",
        description: "System-wide notification has been sent successfully.",
      })
    }
  }

  const handleDeleteNotification = () => {
    if (selectedNotification) {
      setNotifications(notifications.filter((notif) => notif.id !== selectedNotification.id))
      setIsDeleteDialogOpen(false)
      toast({
        title: "Notification Deleted",
        description: "Notification has been permanently deleted.",
        variant: "destructive",
      })
    }
  }

  const getRecipientCount = (target: string) => {
    switch (target) {
      case "all":
        return 2847
      case "active":
        return 2234
      case "pending":
        return 47
      case "moderators":
        return 12
      default:
        return 0
    }
  }

  const getTypeIcon = (type: string) => {
    switch (type) {
      case "info":
        return <Info className="h-4 w-4 text-blue-500" />
      case "warning":
        return <AlertCircle className="h-4 w-4 text-orange-500" />
      case "success":
        return <CheckCircle className="h-4 w-4 text-green-500" />
      case "error":
        return <AlertCircle className="h-4 w-4 text-red-500" />
      default:
        return <Bell className="h-4 w-4" />
    }
  }

  const getTypeBadge = (type: string) => {
    switch (type) {
      case "info":
        return <Badge className="bg-blue-100 text-blue-800 hover:bg-blue-100">Info</Badge>
      case "warning":
        return <Badge className="bg-orange-100 text-orange-800 hover:bg-orange-100">Warning</Badge>
      case "success":
        return <Badge className="bg-green-100 text-green-800 hover:bg-green-100">Success</Badge>
      case "error":
        return <Badge className="bg-red-100 text-red-800 hover:bg-red-100">Error</Badge>
      default:
        return <Badge variant="outline">{type}</Badge>
    }
  }

  const getStatusBadge = (status: string) => {
    switch (status) {
      case "sent":
        return <Badge className="bg-green-100 text-green-800 hover:bg-green-100">Sent</Badge>
      case "draft":
        return <Badge className="bg-gray-100 text-gray-800 hover:bg-gray-100">Draft</Badge>
      case "scheduled":
        return <Badge className="bg-blue-100 text-blue-800 hover:bg-blue-100">Scheduled</Badge>
      default:
        return <Badge variant="outline">{status}</Badge>
    }
  }

  const getReadPercentage = (readCount: number, recipients: number) => {
    if (recipients === 0) return 0
    return Math.round((readCount / recipients) * 100)
  }

  return (
    <SidebarInset>
      <header className="flex h-16 shrink-0 items-center gap-2 border-b px-4">
        <SidebarTrigger className="-ml-1" />
        <Separator orientation="vertical" className="mr-2 h-4" />
        <h1 className="text-lg font-semibold">Notifications</h1>
      </header>

      <div className="flex-1 space-y-4 p-4 md:p-8 pt-6">
        <Card>
          <CardHeader>
            <div className="flex items-center justify-between">
              <div>
                <CardTitle>System Notifications</CardTitle>
                <CardDescription>Send and manage system-wide notifications to users</CardDescription>
              </div>
              <Button onClick={() => setIsCreateDialogOpen(true)}>
                <Plus className="h-4 w-4 mr-2" />
                Send Notification
              </Button>
            </div>
          </CardHeader>
          <CardContent>
            {/* Notifications Table */}
            <div className="rounded-md border">
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Notification</TableHead>
                    <TableHead>Type</TableHead>
                    <TableHead>Target</TableHead>
                    <TableHead>Date Sent</TableHead>
                    <TableHead>Status</TableHead>
                    <TableHead>Engagement</TableHead>
                    <TableHead>Actions</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {notifications.map((notification) => (
                    <TableRow key={notification.id}>
                      <TableCell>
                        <div className="flex items-start space-x-3">
                          {getTypeIcon(notification.type)}
                          <div>
                            <p className="font-medium">{notification.title}</p>
                            <p className="text-sm text-muted-foreground truncate max-w-xs">{notification.message}</p>
                            <p className="text-xs text-muted-foreground mt-1">By {notification.sentBy}</p>
                          </div>
                        </div>
                      </TableCell>
                      <TableCell>{getTypeBadge(notification.type)}</TableCell>
                      <TableCell>
                        <div className="flex items-center space-x-2">
                          <Users className="h-4 w-4 text-muted-foreground" />
                          <span className="capitalize">{notification.target}</span>
                        </div>
                      </TableCell>
                      <TableCell>{new Date(notification.sentDate).toLocaleDateString()}</TableCell>
                      <TableCell>{getStatusBadge(notification.status)}</TableCell>
                      <TableCell>
                        {notification.status === "sent" ? (
                          <div>
                            <div className="text-sm">
                              {notification.readCount}/{notification.recipients} read
                            </div>
                            <div className="text-xs text-muted-foreground">
                              {getReadPercentage(notification.readCount, notification.recipients)}% read rate
                            </div>
                            <div className="w-full bg-gray-200 rounded-full h-1 mt-1">
                              <div
                                className="bg-blue-600 h-1 rounded-full"
                                style={{
                                  width: `${getReadPercentage(notification.readCount, notification.recipients)}%`,
                                }}
                              ></div>
                            </div>
                          </div>
                        ) : (
                          <span className="text-sm text-muted-foreground">Not sent</span>
                        )}
                      </TableCell>
                      <TableCell>
                        <div className="flex items-center space-x-2">
                          <Button
                            variant="ghost"
                            size="sm"
                            onClick={() => {
                              setSelectedNotification(notification)
                              setIsViewDialogOpen(true)
                            }}
                          >
                            <Eye className="h-4 w-4" />
                          </Button>
                          <Button
                            variant="ghost"
                            size="sm"
                            onClick={() => {
                              setSelectedNotification(notification)
                              setIsDeleteDialogOpen(true)
                            }}
                            className="text-red-600 hover:text-red-700"
                          >
                            <Trash2 className="h-4 w-4" />
                          </Button>
                        </div>
                      </TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            </div>
          </CardContent>
        </Card>

        {/* Create Notification Dialog */}
        <Dialog open={isCreateDialogOpen} onOpenChange={setIsCreateDialogOpen}>
          <DialogContent className="max-w-2xl">
            <DialogHeader>
              <DialogTitle>Send System Notification</DialogTitle>
              <DialogDescription>Create and send a notification to users</DialogDescription>
            </DialogHeader>
            <div className="space-y-4">
              <div>
                <Label htmlFor="title">Notification Title</Label>
                <Input
                  id="title"
                  value={newNotification.title || ""}
                  onChange={(e) => setNewNotification({ ...newNotification, title: e.target.value })}
                  placeholder="Enter notification title"
                />
              </div>
              <div>
                <Label htmlFor="message">Message</Label>
                <Textarea
                  id="message"
                  value={newNotification.message || ""}
                  onChange={(e) => setNewNotification({ ...newNotification, message: e.target.value })}
                  placeholder="Enter notification message"
                  rows={4}
                />
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <Label htmlFor="type">Notification Type</Label>
                  <Select
                    value={newNotification.type}
                    onValueChange={(value) => setNewNotification({ ...newNotification, type: value as any })}
                  >
                    <SelectTrigger>
                      <SelectValue placeholder="Select type" />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="info">Info</SelectItem>
                      <SelectItem value="warning">Warning</SelectItem>
                      <SelectItem value="success">Success</SelectItem>
                      <SelectItem value="error">Error</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
                <div>
                  <Label htmlFor="target">Target Audience</Label>
                  <Select
                    value={newNotification.target}
                    onValueChange={(value) => setNewNotification({ ...newNotification, target: value as any })}
                  >
                    <SelectTrigger>
                      <SelectValue placeholder="Select target" />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="all">All Users ({getRecipientCount("all")})</SelectItem>
                      <SelectItem value="active">Active Users ({getRecipientCount("active")})</SelectItem>
                      <SelectItem value="pending">Pending Users ({getRecipientCount("pending")})</SelectItem>
                      <SelectItem value="moderators">Moderators ({getRecipientCount("moderators")})</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
              </div>
              <div className="bg-muted p-3 rounded-md">
                <p className="text-sm text-muted-foreground">
                  This notification will be sent to {getRecipientCount(newNotification.target || "all")} users.
                </p>
              </div>
            </div>
            <DialogFooter>
              <Button variant="outline" onClick={() => setIsCreateDialogOpen(false)}>
                Cancel
              </Button>
              <Button onClick={handleCreateNotification}>
                <Send className="h-4 w-4 mr-2" />
                Send Notification
              </Button>
            </DialogFooter>
          </DialogContent>
        </Dialog>

        {/* View Notification Dialog */}
        <Dialog open={isViewDialogOpen} onOpenChange={setIsViewDialogOpen}>
          <DialogContent className="max-w-2xl">
            <DialogHeader>
              <DialogTitle>Notification Details</DialogTitle>
              <DialogDescription>View complete notification information</DialogDescription>
            </DialogHeader>
            {selectedNotification && (
              <div className="space-y-4">
                <div className="flex items-start space-x-3">
                  {getTypeIcon(selectedNotification.type)}
                  <div className="flex-1">
                    <h3 className="text-lg font-semibold">{selectedNotification.title}</h3>
                    <div className="flex items-center space-x-2 mt-1">
                      {getTypeBadge(selectedNotification.type)}
                      {getStatusBadge(selectedNotification.status)}
                    </div>
                  </div>
                </div>
                <Separator />
                <div>
                  <Label>Message</Label>
                  <p className="text-sm mt-1 leading-relaxed">{selectedNotification.message}</p>
                </div>
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <Label>Target Audience</Label>
                    <p className="text-sm mt-1 capitalize">{selectedNotification.target} users</p>
                  </div>
                  <div>
                    <Label>Sent By</Label>
                    <p className="text-sm mt-1">{selectedNotification.sentBy}</p>
                  </div>
                  <div>
                    <Label>Date Sent</Label>
                    <p className="text-sm mt-1">{new Date(selectedNotification.sentDate).toLocaleDateString()}</p>
                  </div>
                  <div>
                    <Label>Recipients</Label>
                    <p className="text-sm mt-1">{selectedNotification.recipients} users</p>
                  </div>
                </div>
                {selectedNotification.status === "sent" && (
                  <div>
                    <Label>Engagement Stats</Label>
                    <div className="mt-2 p-3 bg-muted rounded-md">
                      <div className="flex justify-between items-center mb-2">
                        <span className="text-sm">Read Rate</span>
                        <span className="text-sm font-medium">
                          {getReadPercentage(selectedNotification.readCount, selectedNotification.recipients)}%
                        </span>
                      </div>
                      <div className="w-full bg-gray-200 rounded-full h-2">
                        <div
                          className="bg-blue-600 h-2 rounded-full"
                          style={{
                            width: `${getReadPercentage(selectedNotification.readCount, selectedNotification.recipients)}%`,
                          }}
                        ></div>
                      </div>
                      <p className="text-xs text-muted-foreground mt-1">
                        {selectedNotification.readCount} out of {selectedNotification.recipients} users have read this
                        notification
                      </p>
                    </div>
                  </div>
                )}
              </div>
            )}
          </DialogContent>
        </Dialog>

        {/* Delete Notification Dialog */}
        <Dialog open={isDeleteDialogOpen} onOpenChange={setIsDeleteDialogOpen}>
          <DialogContent>
            <DialogHeader>
              <DialogTitle>Delete Notification</DialogTitle>
              <DialogDescription>
                Are you sure you want to permanently delete this notification? This action cannot be undone.
              </DialogDescription>
            </DialogHeader>
            <DialogFooter>
              <Button variant="outline" onClick={() => setIsDeleteDialogOpen(false)}>
                Cancel
              </Button>
              <Button variant="destructive" onClick={handleDeleteNotification}>
                Delete Notification
              </Button>
            </DialogFooter>
          </DialogContent>
        </Dialog>
      </div>
    </SidebarInset>
  )
}
