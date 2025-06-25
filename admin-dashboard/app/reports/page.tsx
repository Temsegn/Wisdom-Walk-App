"use client"

import { useState } from "react"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { SidebarInset, SidebarTrigger } from "@/components/ui/sidebar"
import { Separator } from "@/components/ui/separator"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Badge } from "@/components/ui/badge"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { useToast } from "@/hooks/use-toast"
import { Search, Filter, Eye, CheckCircle, XCircle, Flag, Users, FileText, Bell, Clock, User } from "lucide-react"

interface PostReport {
  id: string
  postId: string
  postTitle: string
  postAuthor: string
  reportedBy: string
  reportReason: string
  reportDate: string
  status: "pending" | "resolved" | "dismissed"
  severity: "low" | "medium" | "high"
  reportCount: number
}

interface UserReport {
  id: string
  reportedUserId: string
  reportedUsername: string
  reportedUserEmail: string
  reportedBy: string
  reportReason: string
  reportDate: string
  status: "pending" | "resolved" | "dismissed"
  severity: "low" | "medium" | "high"
  reportCount: number
}

interface PendingUser {
  id: string
  username: string
  email: string
  registrationDate: string
  livePhoto?: string
  idPhoto?: string
  verificationStatus: "pending" | "under_review"
}

interface PendingNotification {
  id: string
  title: string
  message: string
  type: "info" | "warning" | "success" | "error"
  target: "all" | "active" | "pending" | "moderators"
  scheduledDate: string
  createdBy: string
  status: "draft" | "scheduled"
}

const mockPostReports: PostReport[] = [
  {
    id: "pr-1",
    postId: "post-123",
    postTitle: "Controversial Opinion on Modern Tech",
    postAuthor: "mike_wilson",
    reportedBy: "user_reporter1",
    reportReason: "Inappropriate content and hate speech",
    reportDate: "2024-01-24",
    status: "pending",
    severity: "high",
    reportCount: 5,
  },
  {
    id: "pr-2",
    postId: "post-456",
    postTitle: "Spam Advertisement Post",
    postAuthor: "spam_user",
    reportedBy: "user_reporter2",
    reportReason: "Spam and promotional content",
    reportDate: "2024-01-23",
    status: "pending",
    severity: "medium",
    reportCount: 3,
  },
  {
    id: "pr-3",
    postId: "post-789",
    postTitle: "Misleading Information About Health",
    postAuthor: "health_guru",
    reportedBy: "concerned_user",
    reportReason: "Misinformation and false claims",
    reportDate: "2024-01-22",
    status: "resolved",
    severity: "high",
    reportCount: 8,
  },
]

const mockUserReports: UserReport[] = [
  {
    id: "ur-1",
    reportedUserId: "user-456",
    reportedUsername: "problematic_user",
    reportedUserEmail: "problem@example.com",
    reportedBy: "community_member",
    reportReason: "Harassment and bullying behavior",
    reportDate: "2024-01-24",
    status: "pending",
    severity: "high",
    reportCount: 7,
  },
  {
    id: "ur-2",
    reportedUserId: "user-789",
    reportedUsername: "fake_account",
    reportedUserEmail: "fake@example.com",
    reportedBy: "vigilant_user",
    reportReason: "Fake account and impersonation",
    reportDate: "2024-01-23",
    status: "pending",
    severity: "medium",
    reportCount: 4,
  },
]

const mockPendingUsers: PendingUser[] = [
  {
    id: "pu-1",
    username: "new_user_1",
    email: "newuser1@example.com",
    registrationDate: "2024-01-25",
    livePhoto: "/placeholder.svg?height=100&width=100",
    idPhoto: "/placeholder.svg?height=100&width=100",
    verificationStatus: "pending",
  },
  {
    id: "pu-2",
    username: "new_user_2",
    email: "newuser2@example.com",
    registrationDate: "2024-01-24",
    livePhoto: "/placeholder.svg?height=100&width=100",
    idPhoto: "/placeholder.svg?height=100&width=100",
    verificationStatus: "under_review",
  },
]

const mockPendingNotifications: PendingNotification[] = [
  {
    id: "pn-1",
    title: "Scheduled Maintenance Notice",
    message: "System maintenance will be performed this weekend.",
    type: "warning",
    target: "all",
    scheduledDate: "2024-01-28",
    createdBy: "System Admin",
    status: "scheduled",
  },
  {
    id: "pn-2",
    title: "New Feature Announcement",
    message: "Exciting new features are coming soon!",
    type: "info",
    target: "active",
    scheduledDate: "2024-01-30",
    createdBy: "Product Team",
    status: "draft",
  },
]

export default function ReportsPage() {
  const [postReports, setPostReports] = useState<PostReport[]>(mockPostReports)
  const [userReports, setUserReports] = useState<UserReport[]>(mockUserReports)
  const [pendingUsers, setPendingUsers] = useState<PendingUser[]>(mockPendingUsers)
  const [pendingNotifications, setPendingNotifications] = useState<PendingNotification[]>(mockPendingNotifications)
  const [searchTerm, setSearchTerm] = useState("")
  const [statusFilter, setStatusFilter] = useState<string>("all")
  const [selectedReport, setSelectedReport] = useState<any>(null)
  const [isViewDialogOpen, setIsViewDialogOpen] = useState(false)
  const [selectedUser, setSelectedUser] = useState<PendingUser | null>(null)
  const [isUserDialogOpen, setIsUserDialogOpen] = useState(false)
  const { toast } = useToast()

  const handleResolvePostReport = (reportId: string) => {
    setPostReports(
      postReports.map((report) => (report.id === reportId ? { ...report, status: "resolved" as const } : report)),
    )
    toast({
      title: "Report Resolved",
      description: "Post report has been marked as resolved.",
    })
  }

  const handleDismissPostReport = (reportId: string) => {
    setPostReports(
      postReports.map((report) => (report.id === reportId ? { ...report, status: "dismissed" as const } : report)),
    )
    toast({
      title: "Report Dismissed",
      description: "Post report has been dismissed.",
    })
  }

  const handleResolveUserReport = (reportId: string) => {
    setUserReports(
      userReports.map((report) => (report.id === reportId ? { ...report, status: "resolved" as const } : report)),
    )
    toast({
      title: "Report Resolved",
      description: "User report has been marked as resolved.",
    })
  }

  const handleApproveUser = (userId: string) => {
    setPendingUsers(pendingUsers.filter((user) => user.id !== userId))
    toast({
      title: "User Approved",
      description: "User has been approved and activated.",
    })
  }

  const handleRejectUser = (userId: string) => {
    setPendingUsers(pendingUsers.filter((user) => user.id !== userId))
    toast({
      title: "User Rejected",
      description: "User registration has been rejected.",
      variant: "destructive",
    })
  }

  const getSeverityBadge = (severity: string) => {
    switch (severity) {
      case "high":
        return <Badge className="bg-red-100 text-red-800 hover:bg-red-100">High</Badge>
      case "medium":
        return <Badge className="bg-orange-100 text-orange-800 hover:bg-orange-100">Medium</Badge>
      case "low":
        return <Badge className="bg-yellow-100 text-yellow-800 hover:bg-yellow-100">Low</Badge>
      default:
        return <Badge variant="outline">{severity}</Badge>
    }
  }

  const getStatusBadge = (status: string) => {
    switch (status) {
      case "pending":
        return <Badge className="bg-yellow-100 text-yellow-800 hover:bg-yellow-100">Pending</Badge>
      case "resolved":
        return <Badge className="bg-green-100 text-green-800 hover:bg-green-100">Resolved</Badge>
      case "dismissed":
        return <Badge className="bg-gray-100 text-gray-800 hover:bg-gray-100">Dismissed</Badge>
      default:
        return <Badge variant="outline">{status}</Badge>
    }
  }

  const filteredPostReports = postReports.filter((report) => {
    const matchesSearch =
      report.postTitle.toLowerCase().includes(searchTerm.toLowerCase()) ||
      report.postAuthor.toLowerCase().includes(searchTerm.toLowerCase())
    const matchesStatus = statusFilter === "all" || report.status === statusFilter
    return matchesSearch && matchesStatus
  })

  const filteredUserReports = userReports.filter((report) => {
    const matchesSearch =
      report.reportedUsername.toLowerCase().includes(searchTerm.toLowerCase()) ||
      report.reportedUserEmail.toLowerCase().includes(searchTerm.toLowerCase())
    const matchesStatus = statusFilter === "all" || report.status === statusFilter
    return matchesSearch && matchesStatus
  })

  return (
    <SidebarInset>
      <header className="flex h-16 shrink-0 items-center gap-2 border-b px-4">
        <SidebarTrigger className="-ml-1" />
        <Separator orientation="vertical" className="mr-2 h-4" />
        <h1 className="text-lg font-semibold">Reports & Pending Items</h1>
      </header>

      <div className="flex-1 space-y-4 p-4 md:p-8 pt-6">
        {/* Summary Cards */}
        <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium">Post Reports</CardTitle>
              <Flag className="h-4 w-4 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">{postReports.filter((r) => r.status === "pending").length}</div>
              <p className="text-xs text-muted-foreground">{postReports.length} total reports</p>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium">User Reports</CardTitle>
              <Users className="h-4 w-4 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">{userReports.filter((r) => r.status === "pending").length}</div>
              <p className="text-xs text-muted-foreground">{userReports.length} total reports</p>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium">Pending Users</CardTitle>
              <User className="h-4 w-4 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">{pendingUsers.length}</div>
              <p className="text-xs text-muted-foreground">Awaiting approval</p>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium">Pending Notifications</CardTitle>
              <Bell className="h-4 w-4 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">{pendingNotifications.length}</div>
              <p className="text-xs text-muted-foreground">Scheduled & drafts</p>
            </CardContent>
          </Card>
        </div>

        <Tabs defaultValue="post-reports" className="space-y-4">
          <TabsList className="grid w-full grid-cols-4">
            <TabsTrigger value="post-reports">
              <FileText className="h-4 w-4 mr-2" />
              Post Reports
            </TabsTrigger>
            <TabsTrigger value="user-reports">
              <Users className="h-4 w-4 mr-2" />
              User Reports
            </TabsTrigger>
            <TabsTrigger value="pending-users">
              <User className="h-4 w-4 mr-2" />
              Pending Users
            </TabsTrigger>
            <TabsTrigger value="pending-notifications">
              <Bell className="h-4 w-4 mr-2" />
              Pending Notifications
            </TabsTrigger>
          </TabsList>

          {/* Post Reports Tab */}
          <TabsContent value="post-reports" className="space-y-4">
            <Card>
              <CardHeader>
                <CardTitle>Post Reports</CardTitle>
                <CardDescription>Manage reported posts and content violations</CardDescription>
              </CardHeader>
              <CardContent>
                {/* Filters */}
                <div className="flex flex-col sm:flex-row gap-4 mb-6">
                  <div className="relative flex-1">
                    <Search className="absolute left-2 top-2.5 h-4 w-4 text-muted-foreground" />
                    <Input
                      placeholder="Search post reports..."
                      value={searchTerm}
                      onChange={(e) => setSearchTerm(e.target.value)}
                      className="pl-8"
                    />
                  </div>
                  <Select value={statusFilter} onValueChange={setStatusFilter}>
                    <SelectTrigger className="w-[180px]">
                      <Filter className="h-4 w-4 mr-2" />
                      <SelectValue placeholder="Filter by status" />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="all">All Status</SelectItem>
                      <SelectItem value="pending">Pending</SelectItem>
                      <SelectItem value="resolved">Resolved</SelectItem>
                      <SelectItem value="dismissed">Dismissed</SelectItem>
                    </SelectContent>
                  </Select>
                </div>

                <div className="rounded-md border">
                  <Table>
                    <TableHeader>
                      <TableRow>
                        <TableHead>Post</TableHead>
                        <TableHead>Author</TableHead>
                        <TableHead>Reported By</TableHead>
                        <TableHead>Reason</TableHead>
                        <TableHead>Reports</TableHead>
                        <TableHead>Severity</TableHead>
                        <TableHead>Status</TableHead>
                        <TableHead>Actions</TableHead>
                      </TableRow>
                    </TableHeader>
                    <TableBody>
                      {filteredPostReports.map((report) => (
                        <TableRow key={report.id}>
                          <TableCell>
                            <div>
                              <p className="font-medium truncate max-w-xs">{report.postTitle}</p>
                              <p className="text-xs text-muted-foreground">ID: {report.postId}</p>
                            </div>
                          </TableCell>
                          <TableCell>{report.postAuthor}</TableCell>
                          <TableCell>{report.reportedBy}</TableCell>
                          <TableCell>
                            <p className="text-sm truncate max-w-xs">{report.reportReason}</p>
                          </TableCell>
                          <TableCell>
                            <Badge variant="outline" className="bg-red-50">
                              {report.reportCount} reports
                            </Badge>
                          </TableCell>
                          <TableCell>{getSeverityBadge(report.severity)}</TableCell>
                          <TableCell>{getStatusBadge(report.status)}</TableCell>
                          <TableCell>
                            <div className="flex items-center space-x-2">
                              <Button
                                variant="ghost"
                                size="sm"
                                onClick={() => {
                                  setSelectedReport(report)
                                  setIsViewDialogOpen(true)
                                }}
                              >
                                <Eye className="h-4 w-4" />
                              </Button>
                              {report.status === "pending" && (
                                <>
                                  <Button
                                    variant="ghost"
                                    size="sm"
                                    onClick={() => handleResolvePostReport(report.id)}
                                    className="text-green-600 hover:text-green-700"
                                  >
                                    <CheckCircle className="h-4 w-4" />
                                  </Button>
                                  <Button
                                    variant="ghost"
                                    size="sm"
                                    onClick={() => handleDismissPostReport(report.id)}
                                    className="text-red-600 hover:text-red-700"
                                  >
                                    <XCircle className="h-4 w-4" />
                                  </Button>
                                </>
                              )}
                            </div>
                          </TableCell>
                        </TableRow>
                      ))}
                    </TableBody>
                  </Table>
                </div>
              </CardContent>
            </Card>
          </TabsContent>

          {/* User Reports Tab */}
          <TabsContent value="user-reports" className="space-y-4">
            <Card>
              <CardHeader>
                <CardTitle>User Reports</CardTitle>
                <CardDescription>Manage reported users and behavioral violations</CardDescription>
              </CardHeader>
              <CardContent>
                <div className="rounded-md border">
                  <Table>
                    <TableHeader>
                      <TableRow>
                        <TableHead>Reported User</TableHead>
                        <TableHead>Reported By</TableHead>
                        <TableHead>Reason</TableHead>
                        <TableHead>Reports</TableHead>
                        <TableHead>Severity</TableHead>
                        <TableHead>Status</TableHead>
                        <TableHead>Actions</TableHead>
                      </TableRow>
                    </TableHeader>
                    <TableBody>
                      {filteredUserReports.map((report) => (
                        <TableRow key={report.id}>
                          <TableCell>
                            <div className="flex items-center space-x-3">
                              <Avatar className="h-8 w-8">
                                <AvatarImage src="/placeholder.svg?height=32&width=32" />
                                <AvatarFallback>{report.reportedUsername.charAt(0).toUpperCase()}</AvatarFallback>
                              </Avatar>
                              <div>
                                <p className="font-medium">{report.reportedUsername}</p>
                                <p className="text-xs text-muted-foreground">{report.reportedUserEmail}</p>
                              </div>
                            </div>
                          </TableCell>
                          <TableCell>{report.reportedBy}</TableCell>
                          <TableCell>
                            <p className="text-sm truncate max-w-xs">{report.reportReason}</p>
                          </TableCell>
                          <TableCell>
                            <Badge variant="outline" className="bg-red-50">
                              {report.reportCount} reports
                            </Badge>
                          </TableCell>
                          <TableCell>{getSeverityBadge(report.severity)}</TableCell>
                          <TableCell>{getStatusBadge(report.status)}</TableCell>
                          <TableCell>
                            <div className="flex items-center space-x-2">
                              <Button
                                variant="ghost"
                                size="sm"
                                onClick={() => {
                                  setSelectedReport(report)
                                  setIsViewDialogOpen(true)
                                }}
                              >
                                <Eye className="h-4 w-4" />
                              </Button>
                              {report.status === "pending" && (
                                <Button
                                  variant="ghost"
                                  size="sm"
                                  onClick={() => handleResolveUserReport(report.id)}
                                  className="text-green-600 hover:text-green-700"
                                >
                                  <CheckCircle className="h-4 w-4" />
                                </Button>
                              )}
                            </div>
                          </TableCell>
                        </TableRow>
                      ))}
                    </TableBody>
                  </Table>
                </div>
              </CardContent>
            </Card>
          </TabsContent>

          {/* Pending Users Tab */}
          <TabsContent value="pending-users" className="space-y-4">
            <Card>
              <CardHeader>
                <CardTitle>Pending User Approvals</CardTitle>
                <CardDescription>Review and approve new user registrations</CardDescription>
              </CardHeader>
              <CardContent>
                <div className="rounded-md border">
                  <Table>
                    <TableHeader>
                      <TableRow>
                        <TableHead>User</TableHead>
                        <TableHead>Email</TableHead>
                        <TableHead>Registration Date</TableHead>
                        <TableHead>Status</TableHead>
                        <TableHead>Actions</TableHead>
                      </TableRow>
                    </TableHeader>
                    <TableBody>
                      {pendingUsers.map((user) => (
                        <TableRow key={user.id}>
                          <TableCell>
                            <div className="flex items-center space-x-3">
                              <Avatar>
                                <AvatarImage src="/placeholder.svg?height=32&width=32" />
                                <AvatarFallback>{user.username.charAt(0).toUpperCase()}</AvatarFallback>
                              </Avatar>
                              <span className="font-medium">{user.username}</span>
                            </div>
                          </TableCell>
                          <TableCell>{user.email}</TableCell>
                          <TableCell>{new Date(user.registrationDate).toLocaleDateString()}</TableCell>
                          <TableCell>
                            <Badge className="bg-yellow-100 text-yellow-800 hover:bg-yellow-100">
                              {user.verificationStatus.replace("_", " ")}
                            </Badge>
                          </TableCell>
                          <TableCell>
                            <div className="flex items-center space-x-2">
                              <Button
                                variant="ghost"
                                size="sm"
                                onClick={() => {
                                  setSelectedUser(user)
                                  setIsUserDialogOpen(true)
                                }}
                              >
                                <Eye className="h-4 w-4" />
                              </Button>
                              <Button
                                variant="ghost"
                                size="sm"
                                onClick={() => handleApproveUser(user.id)}
                                className="text-green-600 hover:text-green-700"
                              >
                                <CheckCircle className="h-4 w-4" />
                              </Button>
                              <Button
                                variant="ghost"
                                size="sm"
                                onClick={() => handleRejectUser(user.id)}
                                className="text-red-600 hover:text-red-700"
                              >
                                <XCircle className="h-4 w-4" />
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
          </TabsContent>

          {/* Pending Notifications Tab */}
          <TabsContent value="pending-notifications" className="space-y-4">
            <Card>
              <CardHeader>
                <CardTitle>Pending Notifications</CardTitle>
                <CardDescription>Manage scheduled and draft notifications</CardDescription>
              </CardHeader>
              <CardContent>
                <div className="rounded-md border">
                  <Table>
                    <TableHeader>
                      <TableRow>
                        <TableHead>Notification</TableHead>
                        <TableHead>Type</TableHead>
                        <TableHead>Target</TableHead>
                        <TableHead>Scheduled Date</TableHead>
                        <TableHead>Created By</TableHead>
                        <TableHead>Status</TableHead>
                        <TableHead>Actions</TableHead>
                      </TableRow>
                    </TableHeader>
                    <TableBody>
                      {pendingNotifications.map((notification) => (
                        <TableRow key={notification.id}>
                          <TableCell>
                            <div>
                              <p className="font-medium">{notification.title}</p>
                              <p className="text-sm text-muted-foreground truncate max-w-xs">{notification.message}</p>
                            </div>
                          </TableCell>
                          <TableCell>
                            <Badge variant="outline" className="capitalize">
                              {notification.type}
                            </Badge>
                          </TableCell>
                          <TableCell className="capitalize">{notification.target}</TableCell>
                          <TableCell>
                            <div className="flex items-center space-x-2">
                              <Clock className="h-4 w-4 text-muted-foreground" />
                              <span>{new Date(notification.scheduledDate).toLocaleDateString()}</span>
                            </div>
                          </TableCell>
                          <TableCell>{notification.createdBy}</TableCell>
                          <TableCell>
                            <Badge
                              className={
                                notification.status === "scheduled"
                                  ? "bg-blue-100 text-blue-800 hover:bg-blue-100"
                                  : "bg-gray-100 text-gray-800 hover:bg-gray-100"
                              }
                            >
                              {notification.status}
                            </Badge>
                          </TableCell>
                          <TableCell>
                            <div className="flex items-center space-x-2">
                              <Button variant="ghost" size="sm">
                                <Eye className="h-4 w-4" />
                              </Button>
                              <Button variant="ghost" size="sm" className="text-blue-600 hover:text-blue-700">
                                Send Now
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
          </TabsContent>
        </Tabs>

        {/* View Report Dialog */}
        <Dialog open={isViewDialogOpen} onOpenChange={setIsViewDialogOpen}>
          <DialogContent className="max-w-2xl">
            <DialogHeader>
              <DialogTitle>Report Details</DialogTitle>
              <DialogDescription>View complete report information</DialogDescription>
            </DialogHeader>
            {selectedReport && (
              <div className="space-y-4">
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <p className="text-sm font-medium">Report ID</p>
                    <p className="text-sm text-muted-foreground">{selectedReport.id}</p>
                  </div>
                  <div>
                    <p className="text-sm font-medium">Report Date</p>
                    <p className="text-sm text-muted-foreground">
                      {new Date(selectedReport.reportDate).toLocaleDateString()}
                    </p>
                  </div>
                  <div>
                    <p className="text-sm font-medium">Severity</p>
                    <div className="mt-1">{getSeverityBadge(selectedReport.severity)}</div>
                  </div>
                  <div>
                    <p className="text-sm font-medium">Status</p>
                    <div className="mt-1">{getStatusBadge(selectedReport.status)}</div>
                  </div>
                </div>
                <Separator />
                <div>
                  <p className="text-sm font-medium">Report Reason</p>
                  <p className="text-sm text-muted-foreground mt-1">{selectedReport.reportReason}</p>
                </div>
                <div>
                  <p className="text-sm font-medium">Total Reports</p>
                  <p className="text-sm text-muted-foreground mt-1">
                    This item has been reported {selectedReport.reportCount} times
                  </p>
                </div>
              </div>
            )}
          </DialogContent>
        </Dialog>

        {/* View Pending User Dialog */}
        <Dialog open={isUserDialogOpen} onOpenChange={setIsUserDialogOpen}>
          <DialogContent className="max-w-2xl">
            <DialogHeader>
              <DialogTitle>User Verification Details</DialogTitle>
              <DialogDescription>Review user information and verification photos</DialogDescription>
            </DialogHeader>
            {selectedUser && (
              <div className="space-y-4">
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <p className="text-sm font-medium">Username</p>
                    <p className="text-sm text-muted-foreground">{selectedUser.username}</p>
                  </div>
                  <div>
                    <p className="text-sm font-medium">Email</p>
                    <p className="text-sm text-muted-foreground">{selectedUser.email}</p>
                  </div>
                  <div>
                    <p className="text-sm font-medium">Registration Date</p>
                    <p className="text-sm text-muted-foreground">
                      {new Date(selectedUser.registrationDate).toLocaleDateString()}
                    </p>
                  </div>
                  <div>
                    <p className="text-sm font-medium">Status</p>
                    <Badge className="bg-yellow-100 text-yellow-800 hover:bg-yellow-100">
                      {selectedUser.verificationStatus.replace("_", " ")}
                    </Badge>
                  </div>
                </div>
                {(selectedUser.livePhoto || selectedUser.idPhoto) && (
                  <div>
                    <p className="text-sm font-medium">Verification Photos</p>
                    <div className="grid grid-cols-2 gap-4 mt-2">
                      {selectedUser.livePhoto && (
                        <div>
                          <p className="text-sm font-medium mb-2">Live Photo</p>
                          <img
                            src={selectedUser.livePhoto || "/placeholder.svg"}
                            alt="Live photo"
                            className="w-full h-32 object-cover rounded-md border"
                          />
                        </div>
                      )}
                      {selectedUser.idPhoto && (
                        <div>
                          <p className="text-sm font-medium mb-2">ID Photo</p>
                          <img
                            src={selectedUser.idPhoto || "/placeholder.svg"}
                            alt="ID photo"
                            className="w-full h-32 object-cover rounded-md border"
                          />
                        </div>
                      )}
                    </div>
                  </div>
                )}
              </div>
            )}
            <DialogFooter>
              <Button variant="outline" onClick={() => setIsUserDialogOpen(false)}>
                Close
              </Button>
              {selectedUser && (
                <>
                  <Button
                    onClick={() => {
                      handleApproveUser(selectedUser.id)
                      setIsUserDialogOpen(false)
                    }}
                    className="bg-green-600 hover:bg-green-700"
                  >
                    Approve User
                  </Button>
                  <Button
                    variant="destructive"
                    onClick={() => {
                      handleRejectUser(selectedUser.id)
                      setIsUserDialogOpen(false)
                    }}
                  >
                    Reject User
                  </Button>
                </>
              )}
            </DialogFooter>
          </DialogContent>
        </Dialog>
      </div>
    </SidebarInset>
  )
}
