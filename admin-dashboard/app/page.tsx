"use client"

import { useEffect } from "react"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { SidebarInset, SidebarTrigger } from "@/components/ui/sidebar"
import { Separator } from "@/components/ui/separator"
import { Badge } from "@/components/ui/badge"
import { Users, FileText, Calendar, AlertTriangle, CheckCircle } from "lucide-react"
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, PieChart, Pie, Cell } from "recharts"
import { useApi } from "@/hooks/use-api"
import { DashboardService } from "@/lib/services/dashboard-service"
import type { DashboardStats } from "@/lib/types"

export default function Dashboard() {
  const { data: dashboardStats, loading, execute: loadDashboardStats } = useApi<DashboardStats>()
  const { data: recentActivities, execute: loadRecentActivities } =
    useApi<
      Array<{
        id: string
        action: string
        user: string
        time: string
        type: string
      }>
    >()

  useEffect(() => {
    // Load dashboard data on component mount
    loadDashboardStats(() => DashboardService.getDashboardStats())
    loadRecentActivities(() => DashboardService.getRecentActivities())
  }, [])

  const pieData = [
    { name: "Active", value: dashboardStats?.activeUsers || 0, color: "#10b981" },
    { name: "Pending", value: dashboardStats?.pendingApprovals || 0, color: "#f59e0b" },
    {
      name: "Blocked",
      value:
        (dashboardStats?.totalUsers || 0) -
        (dashboardStats?.activeUsers || 0) -
        (dashboardStats?.pendingApprovals || 0),
      color: "#ef4444",
    },
  ]

  if (loading) {
    return (
      <SidebarInset>
        <header className="flex h-16 shrink-0 items-center gap-2 border-b px-4">
          <SidebarTrigger className="-ml-1" />
          <Separator orientation="vertical" className="mr-2 h-4" />
          <h1 className="text-lg font-semibold">Dashboard Overview</h1>
        </header>
        <div className="flex-1 flex items-center justify-center">
          <div className="text-center">
            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary mx-auto"></div>
            <p className="mt-2 text-muted-foreground">Loading dashboard...</p>
          </div>
        </div>
      </SidebarInset>
    )
  }

  return (
    <SidebarInset>
      <header className="flex h-16 shrink-0 items-center gap-2 border-b px-4">
        <SidebarTrigger className="-ml-1" />
        <Separator orientation="vertical" className="mr-2 h-4" />
        <h1 className="text-lg font-semibold">Dashboard Overview</h1>
      </header>

      <div className="flex-1 space-y-4 p-4 md:p-8 pt-6">
        {/* Stats Cards */}
        <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium">Total Users</CardTitle>
              <Users className="h-4 w-4 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">{dashboardStats?.totalUsers?.toLocaleString() || 0}</div>
              <p className="text-xs text-muted-foreground">
                <span className="text-green-600">+12.5%</span> from last month
              </p>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium">Total Posts</CardTitle>
              <FileText className="h-4 w-4 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">{dashboardStats?.totalPosts?.toLocaleString() || 0}</div>
              <p className="text-xs text-muted-foreground">
                <span className="text-green-600">+8.2%</span> from last month
              </p>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium">Upcoming Events</CardTitle>
              <Calendar className="h-4 w-4 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">{dashboardStats?.upcomingEvents || 0}</div>
              <p className="text-xs text-muted-foreground">
                <span className="text-blue-600">6 this week</span>
              </p>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium">Pending Approvals</CardTitle>
              <AlertTriangle className="h-4 w-4 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">{dashboardStats?.pendingApprovals || 0}</div>
              <p className="text-xs text-muted-foreground">
                <span className="text-orange-600">Requires attention</span>
              </p>
            </CardContent>
          </Card>
        </div>

        <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-7">
          {/* User Growth Chart */}
          <Card className="col-span-4">
            <CardHeader>
              <CardTitle>User Growth & Content Activity</CardTitle>
              <CardDescription>Monthly statistics for the past 6 months</CardDescription>
            </CardHeader>
            <CardContent className="pl-2">
              <ResponsiveContainer width="100%" height={350}>
                <BarChart data={dashboardStats?.userGrowth || []}>
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis dataKey="month" />
                  <YAxis />
                  <Tooltip />
                  <Bar dataKey="users" fill="#3b82f6" name="New Users" />
                  <Bar dataKey="active" fill="#10b981" name="Active Users" />
                </BarChart>
              </ResponsiveContainer>
            </CardContent>
          </Card>

          {/* User Status Distribution */}
          <Card className="col-span-3">
            <CardHeader>
              <CardTitle>User Status Distribution</CardTitle>
              <CardDescription>Current user status breakdown</CardDescription>
            </CardHeader>
            <CardContent>
              <ResponsiveContainer width="100%" height={200}>
                <PieChart>
                  <Pie
                    data={pieData}
                    cx="50%"
                    cy="50%"
                    innerRadius={60}
                    outerRadius={80}
                    paddingAngle={5}
                    dataKey="value"
                  >
                    {pieData.map((entry, index) => (
                      <Cell key={`cell-${index}`} fill={entry.color} />
                    ))}
                  </Pie>
                  <Tooltip />
                </PieChart>
              </ResponsiveContainer>
              <div className="flex justify-center space-x-4 mt-4">
                {pieData.map((entry, index) => (
                  <div key={index} className="flex items-center space-x-2">
                    <div className="w-3 h-3 rounded-full" style={{ backgroundColor: entry.color }} />
                    <span className="text-sm">
                      {entry.name}: {entry.value}
                    </span>
                  </div>
                ))}
              </div>
            </CardContent>
          </Card>
        </div>

        {/* Recent Activities */}
        <Card>
          <CardHeader>
            <CardTitle>Recent Activities</CardTitle>
            <CardDescription>Latest system activities and user actions</CardDescription>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              {recentActivities?.map((activity) => (
                <div key={activity.id} className="flex items-center space-x-4">
                  <div className="flex-shrink-0">
                    {activity.type === "user" && <Users className="h-4 w-4 text-blue-500" />}
                    {activity.type === "content" && <FileText className="h-4 w-4 text-orange-500" />}
                    {activity.type === "event" && <Calendar className="h-4 w-4 text-green-500" />}
                    {activity.type === "approval" && <CheckCircle className="h-4 w-4 text-purple-500" />}
                  </div>
                  <div className="flex-1 min-w-0">
                    <p className="text-sm font-medium text-gray-900">{activity.action}</p>
                    <p className="text-sm text-gray-500">{activity.user}</p>
                  </div>
                  <div className="flex-shrink-0">
                    <Badge variant="outline">{activity.time}</Badge>
                  </div>
                </div>
              )) || <div className="text-center py-4 text-muted-foreground">No recent activities</div>}
            </div>
          </CardContent>
        </Card>
      </div>
    </SidebarInset>
  )
}
