"use client"

import { useEffect, useState } from "react"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Users, FileText, AlertTriangle, Calendar, UserCheck, UserX, MessageSquare, Heart } from "lucide-react"
import { Badge } from "@/components/ui/badge"
import { useToast } from "@/hooks/use-toast"

interface DashboardStats {
  users: {
    total: number
    active: number
    pendingVerifications: number
    blocked: number
    newThisWeek: number
  }
  content: {
    totalPosts: number
    totalComments: number
    hiddenPosts: number
    newPostsThisWeek: number
  }
  reports: {
    pending: number
    resolved: number
  }
  groups: Array<{
    _id: string
    count: number
  }>
}

export default function DashboardPage() {
  const [stats, setStats] = useState<DashboardStats | null>(null)
  const [bookingsCount, setBookingsCount] = useState(0)
  const [loading, setLoading] = useState(true)
  const { toast } = useToast()

  useEffect(() => {
    fetchDashboardData()
  }, [])

  const fetchDashboardData = async () => {
    try {
      const token = localStorage.getItem("adminToken")

      // Fetch dashboard stats - now using the correct endpoint
      const statsRes = await fetch("/api/admin/dashboard/stats", {
        headers: {
          Authorization: `Bearer ${token}`,
        },
      })

      if (statsRes.ok) {
        const contentType = statsRes.headers.get("content-type")
        if (contentType && contentType.includes("application/json")) {
          const statsData = await statsRes.json()
          setStats(statsData.data)
        } else {
          console.warn("Dashboard stats returned non-JSON response")
        }
      } else {
        console.error("Dashboard stats request failed:", statsRes.status)
      }

      // Fetch bookings count
      const bookingsRes = await fetch("/api/bookings", {
        headers: {
          Authorization: `Bearer ${token}`,
        },
      })

      if (bookingsRes.ok) {
        const contentType = bookingsRes.headers.get("content-type")
        if (contentType && contentType.includes("application/json")) {
          const bookingsData = await bookingsRes.json()
          setBookingsCount(bookingsData.length || 0)
        }
      }
    } catch (error) {
      console.error("Error fetching dashboard data:", error)
      toast({
        title: "Error",
        description: "Failed to load dashboard data",
        variant: "destructive",
      })
    } finally {
      setLoading(false)
    }
  }

  if (loading) {
    return (
      <div className="space-y-6">
        <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
          {[...Array(4)].map((_, i) => (
            <Card key={i}>
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <div className="h-4 bg-gray-200 rounded w-20 animate-pulse"></div>
                <div className="h-4 w-4 bg-gray-200 rounded animate-pulse"></div>
              </CardHeader>
              <CardContent>
                <div className="h-8 bg-gray-200 rounded w-16 animate-pulse mb-2"></div>
                <div className="h-3 bg-gray-200 rounded w-24 animate-pulse"></div>
              </CardContent>
            </Card>
          ))}
        </div>
      </div>
    )
  }

  const statCards = [
    {
      title: "Total Users",
      value: stats?.users.total || 0,
      description: `${stats?.users.newThisWeek || 0} new this week`,
      icon: Users,
      color: "text-blue-600",
    },
    {
      title: "Active Users",
      value: stats?.users.active || 0,
      description: "Verified and active",
      icon: UserCheck,
      color: "text-green-600",
    },
    {
      title: "Pending Verifications",
      value: stats?.users.pendingVerifications || 0,
      description: "Awaiting admin review",
      icon: UserX,
      color: "text-orange-600",
    },
    {
      title: "Total Posts",
      value: stats?.content.totalPosts || 0,
      description: `${stats?.content.newPostsThisWeek || 0} new this week`,
      icon: FileText,
      color: "text-purple-600",
    },
    {
      title: "Pending Reports",
      value: stats?.reports.pending || 0,
      description: "Require attention",
      icon: AlertTriangle,
      color: "text-red-600",
    },
    {
      title: "Session Bookings",
      value: bookingsCount,
      description: "Counseling sessions",
      icon: Calendar,
      color: "text-indigo-600",
    },
    {
      title: "Total Comments",
      value: stats?.content.totalComments || 0,
      description: "Community engagement",
      icon: MessageSquare,
      color: "text-teal-600",
    },
    {
      title: "Hidden Posts",
      value: stats?.content.hiddenPosts || 0,
      description: "Moderated content",
      icon: Heart,
      color: "text-pink-600",
    },
  ]

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold tracking-tight">Dashboard Overview</h1>
        <p className="text-muted-foreground">
          Welcome to the WisdomWalk admin dashboard. Here's what's happening in your community.
        </p>
      </div>

      {/* Stats Grid */}
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
        {statCards.map((stat, index) => {
          const Icon = stat.icon
          return (
            <Card key={index}>
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-sm font-medium">{stat.title}</CardTitle>
                <Icon className={`h-4 w-4 ${stat.color}`} />
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold">{stat.value.toLocaleString()}</div>
                <p className="text-xs text-muted-foreground">{stat.description}</p>
              </CardContent>
            </Card>
          )
        })}
      </div>

      {/* Quick Actions */}
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
        <Card>
          <CardHeader>
            <CardTitle className="text-lg">Recent Activity</CardTitle>
            <CardDescription>Latest community updates</CardDescription>
          </CardHeader>
          <CardContent className="space-y-3">
            <div className="flex items-center justify-between">
              <span className="text-sm">New users this week</span>
              <Badge variant="secondary">{stats?.users.newThisWeek || 0}</Badge>
            </div>
            <div className="flex items-center justify-between">
              <span className="text-sm">New posts this week</span>
              <Badge variant="secondary">{stats?.content.newPostsThisWeek || 0}</Badge>
            </div>
            <div className="flex items-center justify-between">
              <span className="text-sm">Blocked users</span>
              <Badge variant="destructive">{stats?.users.blocked || 0}</Badge>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle className="text-lg">Community Groups</CardTitle>
            <CardDescription>Group membership overview</CardDescription>
          </CardHeader>
          <CardContent className="space-y-3">
            {stats?.groups?.map((group, index) => (
              <div key={index} className="flex items-center justify-between">
                <span className="text-sm capitalize">{group._id.replace(/_/g, " ")}</span>
                <Badge variant="outline">{group.count} members</Badge>
              </div>
            ))}
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle className="text-lg">Moderation Queue</CardTitle>
            <CardDescription>Items requiring attention</CardDescription>
          </CardHeader>
          <CardContent className="space-y-3">
            <div className="flex items-center justify-between">
              <span className="text-sm">Pending verifications</span>
              <Badge variant="outline">{stats?.users.pendingVerifications || 0}</Badge>
            </div>
            <div className="flex items-center justify-between">
              <span className="text-sm">Pending reports</span>
              <Badge variant="destructive">{stats?.reports.pending || 0}</Badge>
            </div>
            <div className="flex items-center justify-between">
              <span className="text-sm">Hidden posts</span>
              <Badge variant="secondary">{stats?.content.hiddenPosts || 0}</Badge>
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  )
}
