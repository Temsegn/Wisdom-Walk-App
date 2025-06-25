"use client"

import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { SidebarInset, SidebarTrigger } from "@/components/ui/sidebar"
import { Separator } from "@/components/ui/separator"
import { Badge } from "@/components/ui/badge"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { TrendingUp, TrendingDown, Users, FileText, Activity } from "lucide-react"
import {
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  LineChart,
  Line,
  PieChart,
  Pie,
  Cell,
  AreaChart,
  Area,
} from "recharts"
import { useState } from "react"

const userGrowthData = [
  { month: "Jan", users: 1200, active: 980, new: 220 },
  { month: "Feb", users: 1450, active: 1180, new: 250 },
  { month: "Mar", users: 1680, active: 1350, new: 230 },
  { month: "Apr", users: 1920, active: 1540, new: 240 },
  { month: "May", users: 2180, active: 1750, new: 260 },
  { month: "Jun", users: 2450, active: 1960, new: 270 },
  { month: "Jul", users: 2680, active: 2140, new: 230 },
  { month: "Aug", users: 2847, active: 2278, new: 167 },
]

const contentData = [
  { month: "Jan", posts: 450, comments: 1200, likes: 3400 },
  { month: "Feb", posts: 520, comments: 1450, likes: 3800 },
  { month: "Mar", posts: 680, comments: 1680, likes: 4200 },
  { month: "Apr", posts: 720, comments: 1920, likes: 4600 },
  { month: "May", posts: 850, comments: 2180, likes: 5100 },
  { month: "Jun", posts: 920, comments: 2450, likes: 5500 },
  { month: "Jul", posts: 1050, comments: 2680, likes: 6200 },
  { month: "Aug", posts: 1234, comments: 2847, likes: 6800 },
]

const deviceData = [
  { name: "Desktop", value: 45, color: "#3b82f6" },
  { name: "Mobile", value: 40, color: "#10b981" },
  { name: "Tablet", value: 15, color: "#f59e0b" },
]

const topContentData = [
  { title: "Getting Started Guide", views: 12500, engagement: 85 },
  { title: "Advanced Features Tutorial", views: 9800, engagement: 78 },
  { title: "Community Guidelines", views: 8600, engagement: 72 },
  { title: "FAQ Section", views: 7200, engagement: 68 },
  { title: "Privacy Policy", views: 5400, engagement: 45 },
]

export default function AnalyticsPage() {
  const [timeRange, setTimeRange] = useState("30d")

  return (
    <SidebarInset>
      <header className="flex h-16 shrink-0 items-center gap-2 border-b px-4">
        <SidebarTrigger className="-ml-1" />
        <Separator orientation="vertical" className="mr-2 h-4" />
        <div className="flex items-center justify-between w-full">
          <h1 className="text-lg font-semibold">Analytics Dashboard</h1>
          <Select value={timeRange} onValueChange={setTimeRange}>
            <SelectTrigger className="w-[120px]">
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="7d">Last 7 days</SelectItem>
              <SelectItem value="30d">Last 30 days</SelectItem>
              <SelectItem value="90d">Last 90 days</SelectItem>
              <SelectItem value="1y">Last year</SelectItem>
            </SelectContent>
          </Select>
        </div>
      </header>

      <div className="flex-1 space-y-4 p-4 md:p-8 pt-6">
        {/* Key Metrics */}
        <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium">Total Users</CardTitle>
              <Users className="h-4 w-4 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">2,847</div>
              <div className="flex items-center text-xs text-muted-foreground">
                <TrendingUp className="h-3 w-3 mr-1 text-green-500" />
                <span className="text-green-600">+12.5%</span>
                <span className="ml-1">from last month</span>
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium">Active Users</CardTitle>
              <Activity className="h-4 w-4 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">2,278</div>
              <div className="flex items-center text-xs text-muted-foreground">
                <TrendingUp className="h-3 w-3 mr-1 text-green-500" />
                <span className="text-green-600">+8.2%</span>
                <span className="ml-1">from last month</span>
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium">Total Posts</CardTitle>
              <FileText className="h-4 w-4 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">12,234</div>
              <div className="flex items-center text-xs text-muted-foreground">
                <TrendingUp className="h-3 w-3 mr-1 text-green-500" />
                <span className="text-green-600">+15.3%</span>
                <span className="ml-1">from last month</span>
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium">Engagement Rate</CardTitle>
              <TrendingUp className="h-4 w-4 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">73.2%</div>
              <div className="flex items-center text-xs text-muted-foreground">
                <TrendingDown className="h-3 w-3 mr-1 text-red-500" />
                <span className="text-red-600">-2.1%</span>
                <span className="ml-1">from last month</span>
              </div>
            </CardContent>
          </Card>
        </div>

        <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-7">
          {/* User Growth Chart */}
          <Card className="col-span-4">
            <CardHeader>
              <CardTitle>User Growth Trends</CardTitle>
              <CardDescription>Monthly user registration and activity patterns</CardDescription>
            </CardHeader>
            <CardContent className="pl-2">
              <ResponsiveContainer width="100%" height={350}>
                <AreaChart data={userGrowthData}>
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis dataKey="month" />
                  <YAxis />
                  <Tooltip />
                  <Area type="monotone" dataKey="users" stackId="1" stroke="#3b82f6" fill="#3b82f6" fillOpacity={0.6} />
                  <Area
                    type="monotone"
                    dataKey="active"
                    stackId="2"
                    stroke="#10b981"
                    fill="#10b981"
                    fillOpacity={0.6}
                  />
                </AreaChart>
              </ResponsiveContainer>
            </CardContent>
          </Card>

          {/* Device Usage */}
          <Card className="col-span-3">
            <CardHeader>
              <CardTitle>Device Usage</CardTitle>
              <CardDescription>User device preferences</CardDescription>
            </CardHeader>
            <CardContent>
              <ResponsiveContainer width="100%" height={200}>
                <PieChart>
                  <Pie
                    data={deviceData}
                    cx="50%"
                    cy="50%"
                    innerRadius={60}
                    outerRadius={80}
                    paddingAngle={5}
                    dataKey="value"
                  >
                    {deviceData.map((entry, index) => (
                      <Cell key={`cell-${index}`} fill={entry.color} />
                    ))}
                  </Pie>
                  <Tooltip />
                </PieChart>
              </ResponsiveContainer>
              <div className="flex justify-center space-x-4 mt-4">
                {deviceData.map((entry, index) => (
                  <div key={index} className="flex items-center space-x-2">
                    <div className="w-3 h-3 rounded-full" style={{ backgroundColor: entry.color }} />
                    <span className="text-sm">
                      {entry.name}: {entry.value}%
                    </span>
                  </div>
                ))}
              </div>
            </CardContent>
          </Card>
        </div>

        {/* Content Analytics */}
        <Card>
          <CardHeader>
            <CardTitle>Content Engagement</CardTitle>
            <CardDescription>Posts, comments, and likes over time</CardDescription>
          </CardHeader>
          <CardContent className="pl-2">
            <ResponsiveContainer width="100%" height={300}>
              <LineChart data={contentData}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="month" />
                <YAxis />
                <Tooltip />
                <Line type="monotone" dataKey="posts" stroke="#3b82f6" strokeWidth={2} />
                <Line type="monotone" dataKey="comments" stroke="#10b981" strokeWidth={2} />
                <Line type="monotone" dataKey="likes" stroke="#f59e0b" strokeWidth={2} />
              </LineChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>

        {/* Top Content */}
        <Card>
          <CardHeader>
            <CardTitle>Top Performing Content</CardTitle>
            <CardDescription>Most viewed and engaging content pieces</CardDescription>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              {topContentData.map((content, index) => (
                <div key={index} className="flex items-center justify-between p-3 border rounded-lg">
                  <div className="flex items-center space-x-3">
                    <div className="flex items-center justify-center w-8 h-8 rounded-full bg-primary text-primary-foreground text-sm font-medium">
                      {index + 1}
                    </div>
                    <div>
                      <p className="font-medium">{content.title}</p>
                      <p className="text-sm text-muted-foreground">{content.views.toLocaleString()} views</p>
                    </div>
                  </div>
                  <div className="flex items-center space-x-2">
                    <Badge
                      variant={
                        content.engagement >= 80 ? "default" : content.engagement >= 70 ? "secondary" : "outline"
                      }
                    >
                      {content.engagement}% engagement
                    </Badge>
                  </div>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>
      </div>
    </SidebarInset>
  )
}
