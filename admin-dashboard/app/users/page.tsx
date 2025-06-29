"use client"

import { useState, useEffect } from "react"
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
import { useApi, usePaginatedApi } from "@/hooks/use-api"
import { UserService } from "@/lib/services/user-service"
import type { User } from "@/lib/types"
import { Search, Filter, Eye, Ban, Trash2, CheckCircle, XCircle } from "lucide-react"

export default function UsersPage() {
  const [searchTerm, setSearchTerm] = useState("")
  const [statusFilter, setStatusFilter] = useState<string>("all")
  const [selectedUser, setSelectedUser] = useState<User | null>(null)
  const [isViewDialogOpen, setIsViewDialogOpen] = useState(false)
  const [isBanDialogOpen, setIsBanDialogOpen] = useState(false)
  const [isDeleteDialogOpen, setIsDeleteDialogOpen] = useState(false)
  const [banReason, setBanReason] = useState("")
  const [banDuration, setBanDuration] = useState("")
  const { toast } = useToast()

  // API hooks
  const { data: users, pagination, loading: usersLoading, execute: loadUsers } = usePaginatedApi<User>()

  const { execute: banUser, loading: banLoading } = useApi<User>()
  const { execute: deleteUser, loading: deleteLoading } = useApi<void>()
  const { execute: approveUser, loading: approveLoading } = useApi<User>()
  const { execute: rejectUser, loading: rejectLoading } = useApi<void>()

  // Load users on component mount and when filters change
  useEffect(() => {
    loadUsers((page, limit) =>
      UserService.getUsers({
        search: searchTerm,
        status: statusFilter === "all" ? undefined : statusFilter,
        page,
        limit,
      }).then((response) => ({
        success: response.success,
        data: response.data
          ? {
              items: response.data.users,
              total: response.data.total,
              page: response.data.page,
              totalPages: response.data.totalPages,
            }
          : undefined,
        message: response.message,
      })),
    )
  }, [searchTerm, statusFilter])

  const handleApproveUser = async (userId: string) => {
    await approveUser(() => UserService.approveUser(userId), {
      showSuccessToast: true,
      successMessage: "User has been successfully approved and activated.",
      onSuccess: () => {
        // Reload users list
        loadUsers((page, limit) =>
          UserService.getUsers({
            search: searchTerm,
            status: statusFilter === "all" ? undefined : statusFilter,
            page,
            limit,
          }).then((response) => ({
            success: response.success,
            data: response.data
              ? {
                  items: response.data.users,
                  total: response.data.total,
                  page: response.data.page,
                  totalPages: response.data.totalPages,
                }
              : undefined,
            message: response.message,
          })),
        )
      },
    })
  }

  const handleRejectUser = async (userId: string) => {
    await rejectUser(() => UserService.rejectUser(userId), {
      showSuccessToast: true,
      successMessage: "User registration has been rejected and removed.",
      onSuccess: () => {
        // Reload users list
        loadUsers((page, limit) =>
          UserService.getUsers({
            search: searchTerm,
            status: statusFilter === "all" ? undefined : statusFilter,
            page,
            limit,
          }).then((response) => ({
            success: response.success,
            data: response.data
              ? {
                  items: response.data.users,
                  total: response.data.total,
                  page: response.data.page,
                  totalPages: response.data.totalPages,
                }
              : undefined,
            message: response.message,
          })),
        )
      },
    })
  }

  const handleBanUser = async () => {
    if (selectedUser && banReason) {
      await banUser(() => UserService.banUser(selectedUser._id, { reason: banReason, duration: banDuration }), {
        showSuccessToast: true,
        successMessage: "User has been successfully banned.",
        onSuccess: () => {
          setIsBanDialogOpen(false)
          setBanReason("")
          setBanDuration("")
          // Reload users list
          loadUsers((page, limit) =>
            UserService.getUsers({
              search: searchTerm,
              status: statusFilter === "all" ? undefined : statusFilter,
              page,
              limit,
            }).then((response) => ({
              success: response.success,
              data: response.data
                ? {
                    items: response.data.users,
                    total: response.data.total,
                    page: response.data.page,
                    totalPages: response.data.totalPages,
                  }
                : undefined,
              message: response.message,
            })),
          )
        },
      })
    }
  }

  const handleDeleteUser = async () => {
    if (selectedUser) {
      await deleteUser(() => UserService.deleteUser(selectedUser._id), {
        showSuccessToast: true,
        successMessage: "User account has been permanently deleted.",
        onSuccess: () => {
          setIsDeleteDialogOpen(false)
          // Reload users list
          loadUsers((page, limit) =>
            UserService.getUsers({
              search: searchTerm,
              status: statusFilter === "all" ? undefined : statusFilter,
              page,
              limit,
            }).then((response) => ({
              success: response.success,
              data: response.data
                ? {
                    items: response.data.users,
                    total: response.data.total,
                    page: response.data.page,
                    totalPages: response.data.totalPages,
                  }
                : undefined,
              message: response.message,
            })),
          )
        },
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

  const handlePageChange = (newPage: number) => {
    loadUsers(
      (page, limit) =>
        UserService.getUsers({
          search: searchTerm,
          status: statusFilter === "all" ? undefined : statusFilter,
          page: newPage,
          limit,
        }).then((response) => ({
          success: response.success,
          data: response.data
            ? {
                items: response.data.users,
                total: response.data.total,
                page: response.data.page,
                totalPages: response.data.totalPages,
              }
            : undefined,
          message: response.message,
        })),
      newPage,
    )
  }

  return (
    <SidebarInset>
      <header className="flex h-16 shrink-0 items-center gap-2 border-b px-4">
        <SidebarTrigger className="-ml-1" />
        <Separator orientation="vertical" className="mr-2 h-4" />
        <h1 className="text-lg font-semibold">User Management</h1>
      </header>

      <div className="flex-1 space-y-4 p-4 md:p-8 pt-6">
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
                  {usersLoading ? (
                    <TableRow>
                      <TableCell colSpan={6} className="text-center py-8">
                        Loading users...
                      </TableCell>
                    </TableRow>
                  ) : users?.length === 0 ? (
                    <TableRow>
                      <TableCell colSpan={6} className="text-center py-8">
                        No users found
                      </TableCell>
                    </TableRow>
                  ) : (
                    users?.map((user) => (
                      <TableRow key={user._id}>
                        <TableCell className="flex items-center space-x-3">
                          <Avatar>
                            <AvatarImage src={user.profilePhoto || "/placeholder.svg?height=32&width=32"} />
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
                                  onClick={() => handleApproveUser(user._id)}
                                  disabled={approveLoading}
                                  className="text-green-600 hover:text-green-700"
                                >
                                  <CheckCircle className="h-4 w-4" />
                                </Button>
                                <Button
                                  variant="ghost"
                                  size="sm"
                                  onClick={() => handleRejectUser(user._id)}
                                  disabled={rejectLoading}
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
                                setIsDeleteDialogOpen(true)
                              }}
                              className="text-red-600 hover:text-red-700"
                            >
                              <Trash2 className="h-4 w-4" />
                            </Button>
                          </div>
                        </TableCell>
                      </TableRow>
                    ))
                  )}
                </TableBody>
              </Table>
            </div>

            {/* Pagination */}
            {pagination.totalPages > 1 && (
              <div className="flex items-center justify-between mt-4">
                <p className="text-sm text-muted-foreground">
                  Showing {(pagination.page - 1) * pagination.limit + 1} to{" "}
                  {Math.min(pagination.page * pagination.limit, pagination.total)} of {pagination.total} users
                </p>
                <div className="flex items-center space-x-2">
                  <Button
                    variant="outline"
                    size="sm"
                    onClick={() => handlePageChange(pagination.page - 1)}
                    disabled={pagination.page === 1 || usersLoading}
                  >
                    Previous
                  </Button>
                  <span className="text-sm">
                    Page {pagination.page} of {pagination.totalPages}
                  </span>
                  <Button
                    variant="outline"
                    size="sm"
                    onClick={() => handlePageChange(pagination.page + 1)}
                    disabled={pagination.page === pagination.totalPages || usersLoading}
                  >
                    Next
                  </Button>
                </div>
              </div>
            )}
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
                    <Label>Full Name</Label>
                    <p className="text-sm font-medium">{selectedUser.fullName}</p>
                  </div>
                  <div>
                    <Label>Status</Label>
                    <div className="mt-1">{getStatusBadge(selectedUser.status)}</div>
                  </div>
                  <div>
                    <Label>Role</Label>
                    <p className="text-sm font-medium capitalize">{selectedUser.role}</p>
                  </div>
                  <div>
                    <Label>Registration Date</Label>
                    <p className="text-sm font-medium">
                      {new Date(selectedUser.registrationDate).toLocaleDateString()}
                    </p>
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
              <Button variant="destructive" onClick={handleBanUser} disabled={!banReason || banLoading}>
                {banLoading ? "Banning..." : "Ban User"}
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
              <Button variant="destructive" onClick={handleDeleteUser} disabled={deleteLoading}>
                {deleteLoading ? "Deleting..." : "Delete User"}
              </Button>
            </DialogFooter>
          </DialogContent>
        </Dialog>
      </div>
    </SidebarInset>
  )
}
