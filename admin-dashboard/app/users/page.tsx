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
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Textarea } from "@/components/ui/textarea"
import { Label } from "@/components/ui/label"
import { useToast } from "@/hooks/use-toast"
import { Search, Filter, Eye, Ban, Trash2, Edit, CheckCircle, XCircle } from "lucide-react"

interface User {
  id: string
  username: string
  email: string
  registrationDate: string
  status: "active" | "blocked" | "pending"
  role: "user" | "moderator" | "admin"
  livePhoto?: string
  idPhoto?: string
  banReason?: string
  banDuration?: string
}

const mockUsers: User[] = [
  {
    id: "1",
    username: "john_doe",
    email: "john.doe@example.com",
    registrationDate: "2024-01-15",
    status: "active",
    role: "user",
    livePhoto: "/placeholder.svg?height=200&width=200",
    idPhoto: "/placeholder.svg?height=200&width=200",
  },
  {
    id: "2",
    username: "jane_smith",
    email: "jane.smith@example.com",
    registrationDate: "2024-01-20",
    status: "pending",
    role: "user",
    livePhoto: "/placeholder.svg?height=200&width=200",
    idPhoto: "/placeholder.svg?height=200&width=200",
  },
  {
    id: "3",
    username: "mike_wilson",
    email: "mike.wilson@example.com",
    registrationDate: "2024-01-10",
    status: "blocked",
    role: "user",
    banReason: "Inappropriate content",
    banDuration: "30 days",
  },
  {
    id: "4",
    username: "sarah_connor",
    email: "sarah.connor@example.com",
    registrationDate: "2024-01-25",
    status: "active",
    role: "moderator",
  },
  {
    id: "5",
    username: "alex_brown",
    email: "alex.brown@example.com",
    registrationDate: "2024-01-18",
    status: "pending",
    role: "user",
    livePhoto: "/placeholder.svg?height=200&width=200",
    idPhoto: "/placeholder.svg?height=200&width=200",
  },
]

export default function UsersPage() {
  const [users, setUsers] = useState<User[]>(mockUsers)
  const [searchTerm, setSearchTerm] = useState("")
  const [statusFilter, setStatusFilter] = useState<string>("all")
  const [selectedUser, setSelectedUser] = useState<User | null>(null)
  const [isViewDialogOpen, setIsViewDialogOpen] = useState(false)
  const [isBanDialogOpen, setIsBanDialogOpen] = useState(false)
  const [isDeleteDialogOpen, setIsDeleteDialogOpen] = useState(false)
  const [isEditDialogOpen, setIsEditDialogOpen] = useState(false)
  const [banReason, setBanReason] = useState("")
  const [banDuration, setBanDuration] = useState("")
  const { toast } = useToast()

  const filteredUsers = users.filter((user) => {
    const matchesSearch =
      user.username.toLowerCase().includes(searchTerm.toLowerCase()) ||
      user.email.toLowerCase().includes(searchTerm.toLowerCase())
    const matchesStatus = statusFilter === "all" || user.status === statusFilter
    return matchesSearch && matchesStatus
  })

  const handleApproveUser = (userId: string) => {
    setUsers(users.map((user) => (user.id === userId ? { ...user, status: "active" as const } : user)))
    toast({
      title: "User Approved",
      description: "User has been successfully approved and activated.",
    })
  }

  const handleRejectUser = (userId: string) => {
    setUsers(users.filter((user) => user.id !== userId))
    toast({
      title: "User Rejected",
      description: "User registration has been rejected and removed.",
      variant: "destructive",
    })
  }

  const handleBanUser = () => {
    if (selectedUser && banReason) {
      setUsers(
        users.map((user) =>
          user.id === selectedUser.id ? { ...user, status: "blocked" as const, banReason, banDuration } : user,
        ),
      )
      setIsBanDialogOpen(false)
      setBanReason("")
      setBanDuration("")
      toast({
        title: "User Banned",
        description: "User has been successfully banned.",
        variant: "destructive",
      })
    }
  }

  const handleDeleteUser = () => {
    if (selectedUser) {
      setUsers(users.filter((user) => user.id !== selectedUser.id))
      setIsDeleteDialogOpen(false)
      toast({
        title: "User Deleted",
        description: "User account has been permanently deleted.",
        variant: "destructive",
      })
    }
  }

  const getStatusBadge = (status: string) => {
    switch (status) {
      case "active":
        return <Badge className="bg-green-100 text-green-800 hover:bg-green-100">Active</Badge>
      case "blocked":
        return <Badge className="bg-red-100 text-red-800 hover:bg-red-100">Blocked</Badge>
      case "pending":
        return <Badge className="bg-yellow-100 text-yellow-800 hover:bg-yellow-100">Pending</Badge>
      default:
        return <Badge variant="outline">{status}</Badge>
    }
  }

  return (
    <SidebarInset>
      <header className="flex h-16 shrink-0 items-center gap-2 border-b px-4">
        <SidebarTrigger className="-ml-1" />
        <Separator orientation="vertical" className="mr-2 h-4" />
        <h1 className="text-lg font-semibold">User Management</h1>
      </header>

      <div className="flex-1 space-y-4 p-4 md:p-8 pt-6">
        {/* Filters */}
        <Card>
          <CardHeader>
            <CardTitle>User Management</CardTitle>
            <CardDescription>Manage user accounts, approvals, and permissions</CardDescription>
          </CardHeader>
          <CardContent>
            <div className="flex flex-col sm:flex-row gap-4 mb-6">
              <div className="relative flex-1">
                <Search className="absolute left-2 top-2.5 h-4 w-4 text-muted-foreground" />
                <Input
                  placeholder="Search users..."
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
                  <SelectItem value="active">Active</SelectItem>
                  <SelectItem value="pending">Pending</SelectItem>
                  <SelectItem value="blocked">Blocked</SelectItem>
                </SelectContent>
              </Select>
            </div>

            {/* Users Table */}
            <div className="rounded-md border">
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>User</TableHead>
                    <TableHead>Email</TableHead>
                    <TableHead>Registration Date</TableHead>
                    <TableHead>Status</TableHead>
                    <TableHead>Role</TableHead>
                    <TableHead>Actions</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {filteredUsers.map((user) => (
                    <TableRow key={user.id}>
                      <TableCell className="flex items-center space-x-3">
                        <Avatar>
                          <AvatarImage src="/placeholder.svg?height=32&width=32" />
                          <AvatarFallback>{user.username.charAt(0).toUpperCase()}</AvatarFallback>
                        </Avatar>
                        <span className="font-medium">{user.username}</span>
                      </TableCell>
                      <TableCell>{user.email}</TableCell>
                      <TableCell>{new Date(user.registrationDate).toLocaleDateString()}</TableCell>
                      <TableCell>{getStatusBadge(user.status)}</TableCell>
                      <TableCell className="capitalize">{user.role}</TableCell>
                      <TableCell>
                        <div className="flex items-center space-x-2">
                          <Button
                            variant="ghost"
                            size="sm"
                            onClick={() => {
                              setSelectedUser(user)
                              setIsViewDialogOpen(true)
                            }}
                          >
                            <Eye className="h-4 w-4" />
                          </Button>

                          {user.status === "pending" && (
                            <>
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
                            </>
                          )}

                          {user.status === "active" && (
                            <Button
                              variant="ghost"
                              size="sm"
                              onClick={() => {
                                setSelectedUser(user)
                                setIsBanDialogOpen(true)
                              }}
                              className="text-orange-600 hover:text-orange-700"
                            >
                              <Ban className="h-4 w-4" />
                            </Button>
                          )}

                          <Button
                            variant="ghost"
                            size="sm"
                            onClick={() => {
                              setSelectedUser(user)
                              setIsEditDialogOpen(true)
                            }}
                          >
                            <Edit className="h-4 w-4" />
                          </Button>

                          <Button
                            variant="ghost"
                            size="sm"
                            onClick={() => {
                              setSelectedUser(user)
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

        {/* View User Dialog */}
        <Dialog open={isViewDialogOpen} onOpenChange={setIsViewDialogOpen}>
          <DialogContent className="max-w-2xl">
            <DialogHeader>
              <DialogTitle>User Details</DialogTitle>
              <DialogDescription>View user information and verification photos</DialogDescription>
            </DialogHeader>
            {selectedUser && (
              <div className="space-y-4">
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <Label>Username</Label>
                    <p className="text-sm font-medium">{selectedUser.username}</p>
                  </div>
                  <div>
                    <Label>Email</Label>
                    <p className="text-sm font-medium">{selectedUser.email}</p>
                  </div>
                  <div>
                    <Label>Status</Label>
                    <div className="mt-1">{getStatusBadge(selectedUser.status)}</div>
                  </div>
                  <div>
                    <Label>Role</Label>
                    <p className="text-sm font-medium capitalize">{selectedUser.role}</p>
                  </div>
                </div>

                {selectedUser.status === "blocked" && selectedUser.banReason && (
                  <div>
                    <Label>Ban Reason</Label>
                    <p className="text-sm text-red-600">{selectedUser.banReason}</p>
                    {selectedUser.banDuration && (
                      <p className="text-sm text-muted-foreground">Duration: {selectedUser.banDuration}</p>
                    )}
                  </div>
                )}

                {(selectedUser.livePhoto || selectedUser.idPhoto) && (
                  <div>
                    <Label>Verification Photos</Label>
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
          </DialogContent>
        </Dialog>

        {/* Ban User Dialog */}
        <Dialog open={isBanDialogOpen} onOpenChange={setIsBanDialogOpen}>
          <DialogContent>
            <DialogHeader>
              <DialogTitle>Ban User</DialogTitle>
              <DialogDescription>Specify the reason and duration for banning this user</DialogDescription>
            </DialogHeader>
            <div className="space-y-4">
              <div>
                <Label htmlFor="ban-reason">Ban Reason</Label>
                <Textarea
                  id="ban-reason"
                  placeholder="Enter the reason for banning this user..."
                  value={banReason}
                  onChange={(e) => setBanReason(e.target.value)}
                />
              </div>
              <div>
                <Label htmlFor="ban-duration">Ban Duration</Label>
                <Select value={banDuration} onValueChange={setBanDuration}>
                  <SelectTrigger>
                    <SelectValue placeholder="Select duration" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="7 days">7 days</SelectItem>
                    <SelectItem value="30 days">30 days</SelectItem>
                    <SelectItem value="90 days">90 days</SelectItem>
                    <SelectItem value="permanent">Permanent</SelectItem>
                  </SelectContent>
                </Select>
              </div>
            </div>
            <DialogFooter>
              <Button variant="outline" onClick={() => setIsBanDialogOpen(false)}>
                Cancel
              </Button>
              <Button variant="destructive" onClick={handleBanUser} disabled={!banReason}>
                Ban User
              </Button>
            </DialogFooter>
          </DialogContent>
        </Dialog>

        {/* Delete User Dialog */}
        <Dialog open={isDeleteDialogOpen} onOpenChange={setIsDeleteDialogOpen}>
          <DialogContent>
            <DialogHeader>
              <DialogTitle>Delete User</DialogTitle>
              <DialogDescription>
                Are you sure you want to permanently delete this user account? This action cannot be undone.
              </DialogDescription>
            </DialogHeader>
            <DialogFooter>
              <Button variant="outline" onClick={() => setIsDeleteDialogOpen(false)}>
                Cancel
              </Button>
              <Button variant="destructive" onClick={handleDeleteUser}>
                Delete User
              </Button>
            </DialogFooter>
          </DialogContent>
        </Dialog>
      </div>
    </SidebarInset>
  )
}
