"use client"

import { useEffect, useState } from "react"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Badge } from "@/components/ui/badge"
import { Avatar, AvatarFallback } from "@/components/ui/avatar"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu"
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from "@/components/ui/alert-dialog"
import { MoreHorizontal, Search, UserCheck, UserX, Ban, Shield } from "lucide-react"
import { useToast } from "@/hooks/use-toast"
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select"

interface User {
  _id: string
  firstName: string
  lastName: string
  email: string
  status: string
  verificationStatus: string
  isEmailVerified: boolean
  isAdminVerified: boolean
  createdAt: string
  lastActive: string
}

type StatusFilter = "all" | "active" | "blocked" | "banned"
type VerificationFilter = "all" | "verified" | "pending" | "rejected" | "unverified"

export default function UsersPage() {
  const [users, setUsers] = useState<User[]>([])
  const [loading, setLoading] = useState(true)
  const [searchTerm, setSearchTerm] = useState("")
  const [selectedUser, setSelectedUser] = useState<User | null>(null)
  const [actionType, setActionType] = useState<"block" | "ban" | null>(null)
  const [statusFilter, setStatusFilter] = useState<StatusFilter>("all")
  const [verificationFilter, setVerificationFilter] = useState<VerificationFilter>("all")
  const { toast } = useToast()

  useEffect(() => {
    fetchUsers()
  }, [])

  const fetchUsers = async () => {
    try {
      const token = localStorage.getItem("adminToken")
      const response = await fetch("/api/admin/users", {
        headers: {
          Authorization: `Bearer ${token}`,
        },
      })

      if (response.ok) {
        const result = await response.json()
        console.log("Number of users fetched:", result.data?.length || 0)
        setUsers(result.data || [])
      }
    } catch (error) {
      console.error("Error fetching users:", error)
      toast({
        title: "Error",
        description: "Failed to fetch users",
        variant: "destructive",
      })
    } finally {
      setLoading(false)
    }
  }
  
  const handleUserAction = async (userId: string, action: "block" | "ban", reason?: string) => {
    try {
      const token = localStorage.getItem("adminToken")
      const endpoint = action === "block" ? `/api/admin/users/${userId}/toggle-block` : `/api/admin/users/${userId}/ban`

      const response = await fetch(endpoint, {
        method: "POST",
        headers: {
          Authorization: `Bearer ${token}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ reason }),
      })

      if (response.ok) {
        toast({
          title: "Success",
          description: `User ${action}ed successfully`,
        })
        fetchUsers()
      }
    } catch (error) {
      console.error(`Error ${action}ing user:`, error)
      toast({
        title: "Error",
        description: `Failed to ${action} user`,
        variant: "destructive",
      })
    }
    setSelectedUser(null)
    setActionType(null)
  }

  const filteredUsers = users.filter((user) => {
    // Search filter
    const matchesSearch = 
      user.firstName.toLowerCase().includes(searchTerm.toLowerCase()) ||
      user.lastName.toLowerCase().includes(searchTerm.toLowerCase()) ||
      user.email.toLowerCase().includes(searchTerm.toLowerCase())
    
    // Status filter
    const matchesStatus = 
      statusFilter === "all" || 
      (statusFilter === "active" && user.status === "active") ||
      (statusFilter === "blocked" && user.status === "blocked") ||
      (statusFilter === "banned" && user.status === "banned")
    
    // Verification filter
    const matchesVerification = 
      verificationFilter === "all" ||
      (verificationFilter === "verified" && user.isAdminVerified) ||
      (verificationFilter === "pending" && user.verificationStatus === "pending")&& !user.isAdminVerified  ||
      (verificationFilter === "rejected" && user.verificationStatus === "rejected") ||
      (verificationFilter === "unverified" && !user.isAdminVerified && user.verificationStatus !== "pending" && user.verificationStatus !== "rejected")
    
    return matchesSearch && matchesStatus && matchesVerification
  })

  const getStatusBadge = (status: string) => {
    switch (status) {
      case "active":
        return (
          <Badge variant="default" className="bg-green-100 text-green-800">
            Active
          </Badge>
        )
      case "blocked":
        return <Badge variant="destructive">Blocked</Badge>
      case "banned":
        return <Badge variant="destructive">Banned</Badge>
      default:
        return <Badge variant="secondary">{status}</Badge>
    }
  }

  const getVerificationBadge = (verificationStatus: string, isAdminVerified: boolean) => {
    if (isAdminVerified) {
      return (
        <Badge variant="default" className="bg-blue-100 text-blue-800">
          Verified
        </Badge>
      )
    }
    switch (verificationStatus) {
      case "pending":
        return (
          <Badge variant="outline" className="text-orange-600">
            Pending
          </Badge>
        )
      case "rejected":
        return <Badge variant="destructive">Rejected</Badge>
      default:
        return <Badge variant="secondary">Unverified</Badge>
    }
  }

  if (loading) {
    return (
      <div className="space-y-6">
        <div className="h-8 bg-gray-200 rounded w-48 animate-pulse"></div>
        <Card>
          <CardContent className="p-6">
            <div className="space-y-4">
              {[...Array(5)].map((_, i) => (
                <div key={i} className="flex items-center space-x-4">
                  <div className="h-10 w-10 bg-gray-200 rounded-full animate-pulse"></div>
                  <div className="space-y-2 flex-1">
                    <div className="h-4 bg-gray-200 rounded w-32 animate-pulse"></div>
                    <div className="h-3 bg-gray-200 rounded w-48 animate-pulse"></div>
                  </div>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold tracking-tight">User Management</h1>
        <p className="text-muted-foreground">Manage user accounts, verification status, and permissions.</p>
        <p className="text-sm text-gray-500 mt-2">Showing: {filteredUsers.length} users</p>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>All Users</CardTitle>
          <CardDescription>View and manage all registered users in the platform.</CardDescription>
          <div className="flex flex-col md:flex-row md:items-center gap-4">
            <div className="relative flex-1 max-w-sm">
              <Search className="absolute left-2 top-2.5 h-4 w-4 text-muted-foreground" />
              <Input
                placeholder="Search users..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="pl-8"
              />
            </div> 
            <div className="flex gap-2">
              <Select value={statusFilter} onValueChange={(value) => setStatusFilter(value as StatusFilter)}>
                <SelectTrigger className="w-[150px]">
                  <SelectValue placeholder="Status" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all">All Statuses</SelectItem>
                  <SelectItem value="active">Active</SelectItem>
                  <SelectItem value="blocked">Blocked</SelectItem>
                  <SelectItem value="banned">Banned</SelectItem>
                </SelectContent>
              </Select>
              <Select value={verificationFilter} onValueChange={(value) => setVerificationFilter(value as VerificationFilter)}>
                <SelectTrigger className="w-[150px]">
                  <SelectValue placeholder="Verification" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all">All Verification</SelectItem>
                  <SelectItem value="verified">Verified</SelectItem>
                  <SelectItem value="pending">Pending</SelectItem>
                  <SelectItem value="rejected">Rejected</SelectItem>
                  <SelectItem value="unverified">Unverified</SelectItem>
                </SelectContent>
              </Select>
            </div>
          </div>
        </CardHeader>
        <CardContent>
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>User</TableHead>
                <TableHead>Email</TableHead>
                <TableHead>Status</TableHead>
                <TableHead>Verification</TableHead>
                <TableHead>Joined</TableHead>
                <TableHead className="text-right">Actions</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {filteredUsers.map((user) => (
                <TableRow key={user._id}>
                  <TableCell className="flex items-center space-x-3">
                    <Avatar className="h-8 w-8">
                      <AvatarFallback>
                        {user.firstName[0]}
                        {user.lastName[0]}
                      </AvatarFallback>
                    </Avatar>
                    <div>
                      <div className="font-medium">
                        {user.firstName} {user.lastName}
                      </div>
                      <div className="text-sm text-muted-foreground">
                        {user.isEmailVerified ? (
                          <span className="flex items-center gap-1">
                            <UserCheck className="h-3 w-3 text-green-600" />
                            Email verified
                          </span>
                        ) : (
                          <span className="flex items-center gap-1">
                            <UserX className="h-3 w-3 text-red-600" />
                            Email not verified
                          </span>
                        )}
                      </div>
                    </div>
                  </TableCell>
                  <TableCell>{user.email}</TableCell>
                  <TableCell>{getStatusBadge(user.status)}</TableCell>
                  <TableCell>{getVerificationBadge(user.verificationStatus, user.isAdminVerified)}</TableCell>
                  <TableCell>{new Date(user.createdAt).toLocaleDateString()}</TableCell>
                  <TableCell className="text-right">
                    <DropdownMenu> 
                      <DropdownMenuTrigger asChild>
                        <Button variant="ghost" className="h-8 w-8 p-0">
                          <MoreHorizontal className="h-4 w-4" />
                        </Button>
                      </DropdownMenuTrigger>
                      <DropdownMenuContent align="end">
                        <DropdownMenuLabel>Actions</DropdownMenuLabel>
                        <DropdownMenuSeparator />
                        {user.status === "blocked" ? (
                          <DropdownMenuItem onClick={() => handleUserAction(user._id, "block")}>
                            <Shield className="mr-2 h-4 w-4" />
                            Unblock User
                          </DropdownMenuItem>
                        ) : (
                          <DropdownMenuItem
                            onClick={() => {
                              setSelectedUser(user)
                              setActionType("block")
                            }}
                          >
                            <UserX className="mr-2 h-4 w-4" />
                            Block User
                          </DropdownMenuItem>
                        )}
                        {user.status !== "banned" && (
                          <DropdownMenuItem
                            onClick={() => {
                              setSelectedUser(user)
                              setActionType("ban")
                            }}
                            className="text-red-600"
                          >
                            <Ban className="mr-2 h-4 w-4" />
                            Ban User
                          </DropdownMenuItem>
                        )}
                      </DropdownMenuContent>
                    </DropdownMenu>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </CardContent>
      </Card>

      {/* Confirmation Dialog */}
      <AlertDialog
        open={!!selectedUser && !!actionType}
        onOpenChange={() => {
          setSelectedUser(null)
          setActionType(null)
        }}
      >
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>{actionType === "block" ? "Block" : "Ban"} User</AlertDialogTitle>
            <AlertDialogDescription>
              Are you sure you want to {actionType} {selectedUser?.firstName} {selectedUser?.lastName}?
              {actionType === "ban"
                ? " This action cannot be undone."
                : " They will be unable to access the platform until unblocked."}
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel>Cancel</AlertDialogCancel>
            <AlertDialogAction
              onClick={() =>
                selectedUser && actionType && handleUserAction(selectedUser._id, actionType, `${actionType}ed by admin`)
              }
              className={actionType === "ban" ? "bg-red-600 hover:bg-red-700" : ""}
            >
              {actionType === "block" ? "Block" : "Ban"} User
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  )
}