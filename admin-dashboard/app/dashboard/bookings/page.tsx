"use client"

import { useEffect, useState } from "react"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { Calendar, Phone, Mail, MapPin, Clock, User, Check, X, Loader2, AlertTriangle, Filter } from "lucide-react"
import { useToast } from "@/hooks/use-toast"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Button } from "@/components/ui/button"
import { Popover, PopoverContent, PopoverTrigger } from "@/components/ui/popover"

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
  sessionDate?: string
}

type TimeFilter = 'all' | 'today' | 'week' | 'month' | 'year'

export default function BookingsPage() {
  const [bookings, setBookings] = useState<Booking[]>([])
  const [filteredBookings, setFilteredBookings] = useState<Booking[]>([])
  const [loading, setLoading] = useState(true)
  const [fetchStatus, setFetchStatus] = useState<'idle' | 'loading' | 'success' | 'error'>('idle')
  const [categoryFilter, setCategoryFilter] = useState<string>('all')
  const [timeFilter, setTimeFilter] = useState<TimeFilter>('all')
  const { toast } = useToast()

  useEffect(() => {
    fetchBookings()
  }, [])

  useEffect(() => {
    applyFilters()
  }, [bookings, categoryFilter, timeFilter])

  const fetchBookings = async () => {
    setFetchStatus('loading')
    try {
      const token = localStorage.getItem("adminToken")
      const response = await fetch("/api/bookings", {
        headers: {
          Authorization: `Bearer ${token}`,
        },
      })

     if (response.ok) {
  const data = await response.json()
  const sortedBookings = data.sort((a: Booking, b: Booking) => 
    new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime()
  )
  setBookings(sortedBookings)
  setFetchStatus('success')
} else {
  setFetchStatus('error')
}
    } catch (error) {
      console.error("Error fetching bookings:", error)
      setFetchStatus('error')
      toast({
        title: "Error",
        description: "Failed to fetch bookings",
        variant: "destructive",
      })
    } finally {
      setLoading(false)
    }
  }

  const applyFilters = () => {
    let result = [...bookings]

    // Apply category filter
    if (categoryFilter !== 'all') {
      result = result.filter(booking => booking.issueTitle === categoryFilter)
    }

    // Apply time filter
    const now = new Date()
    now.setHours(0, 0, 0, 0)

    switch (timeFilter) {
      case 'today':
        result = result.filter(booking => {
          const bookingDate = new Date(booking.sessionDate || booking.createdAt)
          return bookingDate >= now
        })
        break
      case 'week':
        const weekStart = new Date(now)
        weekStart.setDate(now.getDate() - now.getDay()) // Start of current week (Sunday)
        result = result.filter(booking => {
          const bookingDate = new Date(booking.sessionDate || booking.createdAt)
          return bookingDate >= weekStart
        })
        break
      case 'month':
        const monthStart = new Date(now.getFullYear(), now.getMonth(), 1)
        result = result.filter(booking => {
          const bookingDate = new Date(booking.sessionDate || booking.createdAt)
          return bookingDate >= monthStart
        })
        break
      case 'year':
        const yearStart = new Date(now.getFullYear(), 0, 1)
        result = result.filter(booking => {
          const bookingDate = new Date(booking.sessionDate || booking.createdAt)
          return bookingDate >= yearStart
        })
        break
      case 'all':
      default:
        // No time filter applied
        break
    }

    setFilteredBookings(result)
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

  const isBookingExpired = (bookingDate: string) => {
    if (!bookingDate) return false
    const today = new Date()
    today.setHours(0, 0, 0, 0)
    const bookingDay = new Date(bookingDate)
    return bookingDay < today
  }

  const getStatusBadge = () => {
    const statusMap = {
      loading: {
        text: "Loading",
        icon: <Loader2 className="h-3 w-3 animate-spin" />,
        color: "bg-yellow-100 text-yellow-800",
      },
      success: {
        text: "Data loaded",
        icon: <Check className="h-3 w-3" />,
        color: "bg-green-100 text-green-800",
      },
      error: {
        text: "Error loading",
        icon: <X className="h-3 w-3" />,
        color: "bg-red-100 text-red-800",
      },
      idle: {
        text: "Idle",
        icon: null,
        color: "bg-gray-100 text-gray-800",
      },
    }

    const status = statusMap[fetchStatus]

    return (
      <Badge variant="outline" className={`${status.color} flex items-center gap-1`}>
        {status.icon}
        {status.text}
      </Badge>
    )
  }

  const getUniqueCategories = () => {
    const categories = new Set<string>()
    bookings.forEach(booking => categories.add(booking.issueTitle))
    return Array.from(categories)
  }

  if (loading) {
    return (
      <div className="space-y-6">
        <div className="flex justify-between items-center">
          <div className="h-8 bg-gray-200 rounded w-48 animate-pulse"></div>
          <div className="h-6 bg-gray-200 rounded w-24 animate-pulse"></div>
        </div>
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
      <div className="flex justify-between items-start">
        <div>
          <h1 className="text-3xl font-bold tracking-tight">Session Bookings</h1>
          <p className="text-muted-foreground">Manage counseling session requests from community members.</p>
        </div>
        {getStatusBadge()}
      </div>

      {/* Filter Controls */}
      <div className="flex flex-col sm:flex-row gap-4">
        <div className="flex-1 grid grid-cols-2 gap-4">
          <Select value={categoryFilter} onValueChange={setCategoryFilter}>
            <SelectTrigger className="w-full">
              <div className="flex items-center gap-2">
                <Filter className="h-4 w-4" />
                <SelectValue placeholder="Filter by category" />
              </div>
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="all">All Categories</SelectItem>
              {getUniqueCategories().map(category => (
                <SelectItem key={category} value={category}>{category}</SelectItem>
              ))}
            </SelectContent>
          </Select>

          <Select value={timeFilter} onValueChange={(value) => setTimeFilter(value as TimeFilter)}>
            <SelectTrigger className="w-full">
              <div className="flex items-center gap-2">
                <Calendar className="h-4 w-4" />
                <SelectValue placeholder="Filter by time" />
              </div>
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="all">All Time</SelectItem>
              <SelectItem value="today">Today</SelectItem>
              <SelectItem value="week">This Week</SelectItem>
              <SelectItem value="month">This Month</SelectItem>
              <SelectItem value="year">This Year</SelectItem>
            </SelectContent>
          </Select>
        </div>
      </div>

      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Total Bookings</CardTitle>
            <Calendar className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{filteredBookings.length}</div>
            <p className="text-xs text-muted-foreground">Showing {filteredBookings.length} of {bookings.length}</p>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Virtual Sessions</CardTitle>
            <MapPin className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{filteredBookings.filter((b) => b.virtualSession).length}</div>
            <p className="text-xs text-muted-foreground">Online sessions</p>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Expired Sessions</CardTitle>
            <AlertTriangle className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">
              {filteredBookings.filter(b => isBookingExpired(b.sessionDate || b.createdAt)).length}
            </div>
            <p className="text-xs text-muted-foreground">Past due sessions</p>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Current Filter</CardTitle>
            <Filter className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-lg font-bold capitalize">
              {timeFilter === 'all' ? 'All Time' : timeFilter}
            </div>
            <p className="text-xs text-muted-foreground">
              {categoryFilter === 'all' ? 'All Categories' : categoryFilter}
            </p>
          </CardContent>
        </Card>
      </div>

      {filteredBookings.length === 0 ? (
        <Card>
          <CardContent className="flex flex-col items-center justify-center py-12">
            <Calendar className="h-12 w-12 text-gray-400 mb-4" />
            <h3 className="text-lg font-semibold mb-2">No matching bookings</h3>
            <p className="text-muted-foreground text-center">
              {bookings.length === 0 
                ? "No bookings have been created yet" 
                : "No bookings match your current filters"}
            </p>
          </CardContent>
        </Card>
      ) : (
        <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
          {filteredBookings.map((booking) => {
            const isExpired = isBookingExpired(booking.sessionDate || booking.createdAt)
            return (
              <Card key={booking._id} className="overflow-hidden relative">
                {isExpired && (
                  <div className="absolute bottom-4 right-2">
                    <Badge variant="destructive" className="flex items-center gap-1">
                      <AlertTriangle className="h-3 w-3" />
                      Expired
                    </Badge>
                  </div>
                )}
                <CardHeader className="pb-4">
                  <div className="flex items-start justify-between">
                    <div className="space-y-1">
                      <CardTitle className="text-lg">{booking.issueTitle}</CardTitle>
                      <CardDescription className="flex items-center gap-2">
                        <Clock className="h-3 w-3" />
                        {new Date(booking.sessionDate || booking.createdAt).toLocaleDateString('en-US', {
                          year: 'numeric',
                          month: 'short',
                          day: 'numeric',
                          hour: '2-digit',
                          minute: '2-digit'
                        })}
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
            )
          })}
        </div>
      )}
    </div>
  )
}