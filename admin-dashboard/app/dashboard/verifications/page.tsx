"use client"

import { useEffect, useState } from "react"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { Textarea } from "@/components/ui/textarea"
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog"
import { CheckCircle, XCircle, Eye, MapPin, Phone, Mail, Calendar } from "lucide-react"
import { useToast } from "@/hooks/use-toast"
import Image from "next/image"

interface PendingUser {
  _id: string
  firstName: string
  lastName: string
  email: string
  phoneNumber: string
  location: string
  livePhoto: string
  nationalId: string
  createdAt: string
}

export default function VerificationsPage() {
  const [pendingUsers, setPendingUsers] = useState<PendingUser[]>([])
  const [loading, setLoading] = useState(true)
  const [selectedUser, setSelectedUser] = useState<PendingUser | null>(null)
  const [verificationNotes, setVerificationNotes] = useState("")
  const { toast } = useToast()

  useEffect(() => {
    fetchPendingVerifications()
  }, [])

  const fetchPendingVerifications = async () => {
    try {
      const token = localStorage.getItem("adminToken")
      const response = await fetch("/api/admin/pending-verifications", {
        headers: {  
          Authorization: `Bearer ${token}`,
        },
      })

      if (response.ok) {
        const data = await response.json()
        setPendingUsers(data.data)
      }
    } catch (error) {
      console.error("Error fetching pending verifications:", error)
      toast({
        title: "Error",
        description: "Failed to fetch pending verifications",
        variant: "destructive",
      })
    } finally {
      setLoading(false)
    }
  }

  const handleVerification = async (userId: string, action: "approve" | "reject", notes: string) => {
    try {
      const token = localStorage.getItem("adminToken")
      const response = await fetch(`/api/admin/verify-user/${userId}`, {
        method: "POST",
        headers: {
          Authorization: `Bearer ${token}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ action, notes }),
      })

      if (response.ok) {
        toast({
          title: "Success",
          description: `User ${action}d successfully`,
        })
        fetchPendingVerifications()
        setSelectedUser(null)
        setVerificationNotes("")
      }
    } catch (error) {
      console.error(`Error ${action}ing user:`, error)
      toast({
        title: "Error",
        description: `Failed to ${action} user`,
        variant: "destructive",
      })
    }
  }

  if (loading) {
    return (
      <div className="space-y-6">
        <div className="h-8 bg-gray-200 rounded w-48 animate-pulse"></div>
        <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
          {[...Array(6)].map((_, i) => (
            <Card key={i}>
              <CardContent className="p-6">
                <div className="space-y-4">
                  <div className="h-10 w-10 bg-gray-200 rounded-full animate-pulse"></div>
                  <div className="space-y-2">
                    <div className="h-4 bg-gray-200 rounded w-32 animate-pulse"></div>
                    <div className="h-3 bg-gray-200 rounded w-48 animate-pulse"></div>
                  </div>
                </div>
              </CardContent>
            </Card>
          ))}
        </div>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold tracking-tight">Pending Verifications</h1>
        <p className="text-muted-foreground">Review and verify user accounts with submitted documentation.</p>
      </div>

      {pendingUsers.length === 0 ? (
        <Card>
          <CardContent className="flex flex-col items-center justify-center py-12">
            <CheckCircle className="h-12 w-12 text-green-600 mb-4" />
            <h3 className="text-lg font-semibold mb-2">All caught up!</h3>
            <p className="text-muted-foreground text-center">There are no pending user verifications at the moment.</p>
          </CardContent>
        </Card>
      ) : (
        <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
          {pendingUsers.map((user) => (
            <Card key={user._id} className="overflow-hidden">
              <CardHeader className="pb-4">
                <div className="flex items-center space-x-3">
                  <Avatar className="h-12 w-12">
                    <AvatarImage
                      src={user.livePhoto.url || "/placeholder.svg"}
                      alt={`${user.firstName} ${user.lastName}`}
                    />
                    <AvatarFallback>
                      {user.firstName[0]}
                      {user.lastName[0]}
                    </AvatarFallback>
                  </Avatar>
                  <div>
                    <CardTitle className="text-lg">
                      {user.firstName} {user.lastName}
                    </CardTitle>
                    <CardDescription className="flex items-center gap-1">
                      <Mail className="h-3 w-3" />
                      {user.email}
                    </CardDescription>
                  </div>
                </div>
              </CardHeader>
              <CardContent className="space-y-3">
                <div className="space-y-2 text-sm">
                  <div className="flex items-center gap-2">
                    <Phone className="h-4 w-4 text-muted-foreground" />
                    <span>{user.phoneNumber}</span>
                  </div>
                  <div className="flex items-center gap-2">
                    <MapPin className="h-4 w-4 text-muted-foreground" />
                    <span>
                      {user.location?.city || "Unknown City"}, {user.location?.country || "Unknown Country"}
                    </span>
                  </div>
                  <div className="flex items-center gap-2">
                    <Calendar className="h-4 w-4 text-muted-foreground" />
                    <span>Applied {new Date(user.createdAt).toLocaleDateString()}</span>
                  </div>
                </div>

                <div className="flex gap-2 pt-4">
                  <Button variant="outline" size="sm" onClick={() => setSelectedUser(user)} className="flex-1">
                    <Eye className="h-4 w-4 mr-1" />
                    Review
                  </Button>
                </div>
              </CardContent>
            </Card>
          ))}
        </div>
      )}

      {/* Review Dialog */}
      <Dialog open={!!selectedUser} onOpenChange={() => setSelectedUser(null)}>
        <DialogContent className="max-w-2xl max-h-[90vh] overflow-y-auto">
          <DialogHeader>
            <DialogTitle>Review User Verification</DialogTitle>
            <DialogDescription>
              Review the submitted documents and information for {selectedUser?.firstName} {selectedUser?.lastName}
            </DialogDescription>
          </DialogHeader>

          {selectedUser && (
            <div className="space-y-6">
              {/* User Info */}
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <h4 className="font-semibold mb-2">Personal Information</h4>
                  <div className="space-y-2 text-sm">
                    <div>
                      <strong>Name:</strong> {selectedUser.firstName} {selectedUser.lastName}
                    </div>
                    <div>
                      <strong>Email:</strong> {selectedUser.email}
                    </div>
                    <div>
                      <strong>Phone:</strong> {selectedUser.phoneNumber}
                    </div>
                    {/* <div>
                      <strong>Location:</strong> {selectedUser.location}
                    </div> */}
                    <div>
                      <strong>Applied:</strong> {new Date(selectedUser.createdAt).toLocaleDateString()}
                    </div>
                  </div>
                </div>
              </div>

              {/* Documents */}
              <div className="space-y-4">
                <h4 className="font-semibold">Submitted Documents</h4>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  {/* Live Photo */}
                  <div>
                    <h5 className="font-medium mb-2">Live Photo</h5>
                    <div className="border rounded-lg p-4 text-center">
                      {selectedUser.livePhoto.url ? (
                        <div className="relative h-48 w-full">
                          <Image
                            src={selectedUser.livePhoto.url}
                            alt="Live Photo"
                            fill
                            className="object-contain rounded"
                            unoptimized={true} // Add this if you're having issues with external images
                          />
                        </div>
                      ) : (
                        <div className="h-48 bg-gray-100 rounded flex items-center justify-center">
                          <span className="text-muted-foreground">No photo submitted</span>
                        </div>
                      )}
                    </div>
                  </div>

                  {/* National ID */}
                  <div>
                    <h5 className="font-medium mb-2">National ID</h5>
                    <div className="border rounded-lg p-4 text-center">
                      {selectedUser.nationalId.url ? (
                        <div className="relative h-48 w-full">
                          <Image
                            src={selectedUser.nationalId.url}
                            alt="National ID"
                            fill
                            className="object-contain rounded"
                            unoptimized={true} // Add this if you're having issues with external images
                          />
                        </div>
                      ) : (
                        <div className="h-48 bg-gray-100 rounded flex items-center justify-center">
                          <span className="text-muted-foreground">No ID submitted</span>
                        </div>
                      )}
                    </div>
                  </div>
                </div>
              </div>

              {/* Notes */}
              <div>
                <label className="block text-sm font-medium mb-2">Verification Notes (optional)</label>
                <Textarea
                  placeholder="Add any notes about this verification..."
                  value={verificationNotes}
                  onChange={(e) => setVerificationNotes(e.target.value)}
                  rows={3}
                />
              </div>
            </div>
          )}

          <DialogFooter className="gap-2">
            <Button
              variant="outline"
              onClick={() => {
                setSelectedUser(null)
                setVerificationNotes("")
              }}
            >
              Cancel
            </Button>
            <Button
              variant="destructive"
              onClick={() => selectedUser && handleVerification(selectedUser._id, "reject", verificationNotes)}
            >
              <XCircle className="h-4 w-4 mr-2" />
              Reject
            </Button>
            <Button onClick={() => selectedUser && handleVerification(selectedUser._id, "approve", verificationNotes)}>
              <CheckCircle className="h-4 w-4 mr-2" />
              Approve
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  )
}