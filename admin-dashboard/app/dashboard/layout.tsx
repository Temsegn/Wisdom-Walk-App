"use client"

import type React from "react"
import { useEffect, useState } from "react"
import { useRouter, usePathname } from "next/navigation"
import { ChakraProvider } from "@chakra-ui/react";

import {
  BarChart3,
  Users,
  FileText,
  AlertTriangle,
  Calendar,
  Settings,
  LogOut,
  Menu,
  Shield,
  MessageSquare,
  UserCheck,
} from "lucide-react"
import { Button } from "@/components/ui/button"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu"
import { Sheet, SheetContent, SheetTrigger } from "@/components/ui/sheet"
import Link from "next/link"
import { Badge } from "@/components/ui/badge"

const navigation = [
  { name: "Dashboard", href: "/dashboard", icon: BarChart3 },
  { name: "User Management", href: "/dashboard/users", icon: Users },
  { name: "Pending Verifications", href: "/dashboard/verifications", icon: UserCheck },
  { name: "Posts & Content", href: "/dashboard/posts", icon: FileText },
  { name: "Reports", href: "/dashboard/reports", icon: AlertTriangle },
  { name: "Bookings", href: "/dashboard/bookings", icon: Calendar },
   { name: "Notifications", href: "/dashboard/notifications", icon: MessageSquare },
  {name:"event",href:"/dashboard/events",icon:Calendar},
  { name: "Settings", href: "/dashboard/settings", icon: Settings },
  {
    name: "Groups",
    href: "/dashboard/groups",
    icon: Users,
    children: [
      { name: "All Groups", href: "/dashboard/groups" },
      { name: "Create Group", href: "/dashboard/groups/create" },
    ]
  },
]

export default function DashboardLayout({
  children,
}: {
  children: React.ReactNode
}) {
  const router = useRouter()
  const pathname = usePathname()
  const [adminUser, setAdminUser] = useState<any>(null)
  const [sidebarOpen, setSidebarOpen] = useState(false)
  const [isLoading, setIsLoading] = useState(true)
  const [notificationCounts, setNotificationCounts] = useState({
    verifications: 0,
    reports: 0,
    notifications: 0,
    posts: 0,
    users: 0,
    bookings: 0,
    events:0,
  })

  useEffect(() => {
    // Add a small delay to ensure localStorage is available
    const checkAuth = () => {
      try {
        const token = localStorage.getItem("adminToken")
        const user = localStorage.getItem("adminUser")

        if (!token || !user) {
          router.push("/login")
          return
        }

        const parsedUser = JSON.parse(user)
        setAdminUser(parsedUser)
      } catch (error) {
        console.error("Error parsing user data:", error)
        router.push("/login")
      } finally {
        setIsLoading(false)
      }
    }

    // Check immediately and also after a short delay
    checkAuth()
    const timeoutId = setTimeout(checkAuth, 100)

    return () => clearTimeout(timeoutId)
  }, [router])

  useEffect(() => {
    // Fetch notification counts
   const fetchNotificationCounts = async () => {
  try {
    const token = localStorage.getItem("adminToken")

    const res = await fetch("https://wisdom-walk-app.onrender.com/api/admin/dashboard/stats", {
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${token}`,
      },
    })

    const json = await res.json()
    if (!res.ok) throw new Error(json.message || "Failed to fetch stats")

    const stats = json.data

    setNotificationCounts({
      verifications: stats.users.pendingVerifications || 0,
      reports: stats.reports.pending || 0,
      notifications: stats.content.hiddenPosts || 0, // Adjust if needed
      posts: stats.content.totalPosts || 0,
      users: stats.users.total || 0,
      bookings: stats.bookings.total || 0,
      events:stats.events.total||0,
    })
  } catch (error) {
    console.error("Error fetching notification counts:", error)
  }
}


    fetchNotificationCounts()
    const interval = setInterval(fetchNotificationCounts, 30000) // Refresh every 30 seconds

    return () => clearInterval(interval)
  }, [])

  const handleLogout = () => {
    localStorage.removeItem("adminToken")
    localStorage.removeItem("adminUser")
    router.push("/login")
  }

  if (isLoading) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-purple-600"></div>
      </div>
    )
  }

  if (!adminUser) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-purple-600"></div>
      </div>
    )
  }

  const Sidebar = ({ mobile = false }: { mobile?: boolean }) => (
    <div className={`flex flex-col h-full ${mobile ? "p-4" : ""}`}>
      <div className="flex items-center gap-2 px-6 py-4 border-b">
        <Shield className="h-8 w-8 text-purple-600" />
        <div>
          <h1 className="font-bold text-lg">WisdomWalk</h1>
          <p className="text-sm text-muted-foreground">Admin Dashboard</p>
        </div>
      </div>

      <nav className="flex-1 px-4 py-6">
        <ul className="space-y-2">
          {navigation.map((item) => {
            const isActive = pathname === item.href
            let badgeCount = 0
            
            // Assign badge counts based on route
            if (item.href === "/dashboard/verifications") {
              badgeCount = notificationCounts.verifications
            } else if (item.href === "/dashboard/reports") {
              badgeCount = notificationCounts.reports
            } else if (item.href === "/dashboard/notifications") {
              badgeCount = notificationCounts.notifications
            } else if (item.href === "/dashboard/posts") {
              badgeCount = notificationCounts.posts
            }
            else if (item.href === "/dashboard/users") {
              badgeCount = notificationCounts.users
            }
            else if (item.href === "/dashboard/bookings") {
              badgeCount = notificationCounts.bookings
            }

            return (
              <li key={item.name}>
                <Link
                  href={item.href}
                  onClick={() => mobile && setSidebarOpen(false)}
                  className={`flex items-center justify-between gap-3 px-3 py-2 rounded-lg text-sm font-medium transition-colors ${
                    isActive ? "bg-purple-100 text-purple-700" : "text-gray-600 hover:bg-gray-100 hover:text-gray-900"
                  }`}
                >
                  <div className="flex items-center gap-3">
                    <item.icon className="h-5 w-5" />
                    {item.name}
                  </div>
                  {badgeCount > 0 && (
                    <Badge 
                      variant={isActive ? "default" : "secondary"}
                      className="h-5 w-5 flex items-center justify-center p-0"
                    >
                      {badgeCount}
                    </Badge>
                  )}
                </Link>
              </li>
            )
          })}
        </ul>
      </nav>
    </div>
  )

  return (
    <div className="flex h-screen bg-gray-50">
      {/* Desktop Sidebar */}
      <div className="hidden lg:flex lg:w-64 lg:flex-col lg:bg-white lg:border-r">
        <Sidebar />
      </div>

      {/* Mobile Sidebar */}
      <Sheet open={sidebarOpen} onOpenChange={setSidebarOpen}>
        <SheetContent side="left" className="p-0 w-64">
          <Sidebar mobile />
        </SheetContent>
      </Sheet>

      {/* Main Content */}
      <div className="flex-1 flex flex-col overflow-hidden">
        {/* Header */}
        <header className="bg-white border-b px-4 py-3 flex items-center justify-between">
          <div className="flex items-center gap-4">
            <Sheet>
              <SheetTrigger asChild>
                <Button variant="ghost" size="icon" className="lg:hidden">
                  <Menu className="h-5 w-5" />
                </Button>
              </SheetTrigger>
              <SheetContent side="left" className="p-0 w-64">
                <Sidebar mobile />
              </SheetContent>
            </Sheet>

            <h2 className="font-semibold text-lg text-gray-900">
              {navigation.find((item) => item.href === pathname)?.name || "Dashboard"}
            </h2>
          </div>

          <div className="flex items-center gap-4">
            {/* Notification Bell with Badge */}
            <DropdownMenu>
              <DropdownMenuTrigger asChild>
                <Button variant="ghost" size="icon" className="relative">
                  <MessageSquare className="h-5 w-5" />
                  {notificationCounts.notifications > 0 && (
                    <Badge 
                      variant="destructive"
                      className="absolute -top-1 -right-1 h-5 w-5 flex items-center justify-center p-0"
                    >
                      {notificationCounts.notifications > 9 ? "9+" : notificationCounts.notifications}
                    </Badge>
                  )}
                </Button>
              </DropdownMenuTrigger>
              <DropdownMenuContent className="w-80 p-0" align="end">
                <DropdownMenuLabel className="flex justify-between items-center px-4 py-3 border-b">
                  <span>Notifications</span>
                  <Button variant="link" size="sm" className="h-6 px-2">
                    Mark all as read
                  </Button>
                </DropdownMenuLabel>
                <div className="max-h-96 overflow-y-auto">
                  {/* Sample notification items - replace with actual data */}
                  {Array.from({ length: Math.min(notificationCounts.notifications, 5) }).map((_, i) => (
                    <DropdownMenuItem key={i} className="px-4 py-3 border-b">
                      <div className="flex gap-3">
                        <div className="bg-purple-100 rounded-full p-2">
                          <MessageSquare className="h-4 w-4 text-purple-600" />
                        </div>
                        <div>
                          <p className="text-sm font-medium">New notification #{i + 1}</p>
                          <p className="text-xs text-muted-foreground">Just now</p>
                        </div>
                      </div>
                    </DropdownMenuItem>
                  ))}
                </div>
                <DropdownMenuItem className="justify-center py-2">
                  <Button variant="link" size="sm">
                    View all notifications
                  </Button>
                </DropdownMenuItem>
              </DropdownMenuContent>
            </DropdownMenu>

            {/* User Avatar Dropdown */}
            <DropdownMenu>
              <DropdownMenuTrigger asChild>
                <Button variant="ghost" className="relative h-8 w-8 rounded-full">
                  <Avatar className="h-8 w-8">
                    <AvatarImage src={adminUser?.profilePicture || "/placeholder.svg"} alt={adminUser?.firstName} />
                    <AvatarFallback>
                      {adminUser?.firstName?.[0]}
                      {adminUser?.lastName?.[0]}
                    </AvatarFallback>
                  </Avatar>
                </Button>
              </DropdownMenuTrigger>
              <DropdownMenuContent className="w-56" align="end" forceMount>
                <DropdownMenuLabel className="font-normal">
                  <div className="flex flex-col space-y-1">
                    <p className="text-sm font-medium leading-none">
                      {adminUser?.firstName} {adminUser?.lastName}
                    </p>
                    <p className="text-xs leading-none text-muted-foreground">{adminUser?.email}</p>
                  </div>
                </DropdownMenuLabel>
                <DropdownMenuSeparator />
                <DropdownMenuItem asChild>
                  <Link href="/dashboard/settings">
                    <Settings className="mr-2 h-4 w-4" />
                    Settings
                  </Link>
                </DropdownMenuItem>
                <DropdownMenuSeparator />
                <DropdownMenuItem onClick={handleLogout}>
                  <LogOut className="mr-2 h-4 w-4" />
                  Log out
                </DropdownMenuItem>
              </DropdownMenuContent>
            </DropdownMenu>
          </div>
        </header>

        {/* Page Content */}
        <main className="flex-1 overflow-auto p-6">{children}</main>
      </div>
    </div>
  )
}