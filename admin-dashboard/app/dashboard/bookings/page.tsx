"use client"

import { useEffect, useState } from "react"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { Calendar, Phone, Mail, MapPin, Clock, User } from "lucide-react"

interface Booking {
  _id: string
  user: {
    _id: string
    firstName: string
    lastName: string
    email: string
    profilePicture?: string
  }
  issueTitle: string
  issueDescription: string
  phoneNumber: string
  email: string
  virtualSession: boolean
  createdAt: string
}

export default function BookingsPage() {
  const [bookings, setBookings] = useState<Booking[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    fetchBookings()
  }, [])

  const fetchBookings = async () => {
    try {
      const token = localStorage.getItem("adminToken")
      const response = await fetch("/api/bookings", {
        headers: {
          Authorization: `Bearer ${token}`,
        },
      })

      if (response.ok) {
        const data = await response.json()
        setBookings(data)
      }
    } catch (error) {
      console.error("Error fetching bookings:", error)
    } finally {
      setLoading(false)
    }
  }

  const getIssueBadge = (issueTitle: string) => {
    const colors = {
      "Marriage and Ministry": "bg-purple-100 text-purple-800",
      "Single and Purposeful": "bg-blue-100 text-blue-800",
      "Healing and Forgiveness": "bg-green-100 text-green-800",
      "Mental Health and Faith": "bg-orange-100 text-orange-800",
    }
    return (
      <Badge variant="outline" className={colors[issueTitle as keyof typeof colors] || "bg-gray-100 text-gray-800"}>
        {issueTitle}
      </Badge>
    )
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
                  <div className="h-4 bg-gray-200 rounded w-32 animate-pulse"></div>
                  <div className="h-16 bg-gray-200 rounded animate-pulse"></div>
                  <div className="h-4 bg-gray-200 rounded w-24 animate-pulse"></div>
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
        <h1 className="text-3xl font-bold tracking-tight">Session Bookings</h1>
        <p className="text-muted-foreground">Manage counseling session requests from community members.</p>
      </div>

      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Total Bookings</CardTitle>
            <Calendar className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{bookings.length}</div>
            <p className="text-xs text-muted-foreground">All time sessions</p>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Virtual Sessions</CardTitle>
            <MapPin className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{bookings.filter((b) => b.virtualSession).length}</div>
            <p className="text-xs text-muted-foreground">Online sessions</p>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">This Month</CardTitle>
            <Clock className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">
              {bookings.filter((b) => new Date(b.createdAt).getMonth() === new Date().getMonth()).length}
            </div>
            <p className="text-xs text-muted-foreground">Recent bookings</p>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Most Common</CardTitle>
            <User className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">Marriage</div>
            <p className="text-xs text-muted-foreground">Top issue category</p>
          </CardContent>
        </Card>
      </div>

      {bookings.length === 0 ? (
        <Card>
          <CardContent className="flex flex-col items-center justify-center py-12">
            <Calendar className="h-12 w-12 text-gray-400 mb-4" />
            <h3 className="text-lg font-semibold mb-2">No bookings yet</h3>
            <p className="text-muted-foreground text-center">
              Session booking requests will appear here when users submit them.
            </p>
          </CardContent>
        </Card>
      ) : (
        <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
          {bookings.map((booking) => (
            <Card key={booking._id} className="overflow-hidden">
              <CardHeader className="pb-4">
                <div className="flex items-start justify-between">
                  <div className="space-y-1">
                    <CardTitle className="text-lg">{booking.issueTitle}</CardTitle>
                    <CardDescription className="flex items-center gap-2">
                      <Clock className="h-3 w-3" />
                      {new Date(booking.createdAt).toLocaleDateString()}
                    </CardDescription>
                  </div>
                  {getIssueBadge(booking.issueTitle)}
                </div>
              </CardHeader>
              <CardContent className="space-y-4">
                {/* User Info */}
                <div className="flex items-center space-x-3">
                  <Avatar className="h-8 w-8">
                    <AvatarImage src={booking.user?.profilePicture || "/placeholder.svg"} />
                    <AvatarFallback>
                      {booking.user ? `${booking.user.firstName[0]}${booking.user.lastName[0]}` : "U"}
                    </AvatarFallback>
                  </Avatar>
                  <div>
                    <div className="font-medium">
                      {booking.user ? `${booking.user.firstName} ${booking.user.lastName}` : "Unknown User"}
                    </div>
                    <div className="text-sm text-muted-foreground flex items-center gap-1">
                      <Mail className="h-3 w-3" />
                      {booking.email}
                    </div>
                  </div>
                </div>

                {/* Contact Info */}
                <div className="space-y-2 text-sm">
                  <div className="flex items-center gap-2">
                    <Phone className="h-4 w-4 text-muted-foreground" />
                    <span>{booking.phoneNumber}</span>
                  </div>
                  <div className="flex items-center gap-2">
                    <MapPin className="h-4 w-4 text-muted-foreground" />
                    <span>{booking.virtualSession ? "Virtual Session" : "In-Person Session"}</span>
                  </div>
                </div>

                {/* Issue Description */}
                <div className="space-y-2">
                  <h4 className="font-medium text-sm">Description:</h4>
                  <p className="text-sm text-gray-700 line-clamp-3">{booking.issueDescription}</p>
                </div>
              </CardContent>
            </Card>
          ))}
        </div>
      )}
    </div>
  )
}
