"use client"

import type React from "react"

import { useEffect, useState } from "react"
import { useRouter, usePathname } from "next/navigation"
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

const navigation = [
  { name: "Dashboard", href: "/dashboard", icon: BarChart3 },
  { name: "User Management", href: "/dashboard/users", icon: Users },
  { name: "Pending Verifications", href: "/dashboard/verifications", icon: UserCheck },
  { name: "Posts & Content", href: "/dashboard/posts", icon: FileText },
  { name: "Reports", href: "/dashboard/reports", icon: AlertTriangle },
  { name: "Bookings", href: "/dashboard/bookings", icon: Calendar },
  { name: "Notifications", href: "/dashboard/notifications", icon: MessageSquare },
  { name: "Settings", href: "/dashboard/settings", icon: Settings },
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

  useEffect(() => {
    // Add a small delay to ensure localStorage is available
    const checkAuth = () => {
      try {
        const token = localStorage.getItem("adminToken")
        const user = localStorage.getItem("adminUser")

        console.log("Checking auth - Token:", !!token, "User:", !!user) // Debug log

        if (!token || !user) {
          console.log("No auth found, redirecting to login") // Debug log
          router.push("/login")
          return
        }

        const parsedUser = JSON.parse(user)
        console.log("Auth found, user:", parsedUser.firstName) // Debug log
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
            return (
              <li key={item.name}>
                <Link
                  href={item.href}
                  onClick={() => mobile && setSidebarOpen(false)}
                  className={`flex items-center gap-3 px-3 py-2 rounded-lg text-sm font-medium transition-colors ${
                    isActive ? "bg-purple-100 text-purple-700" : "text-gray-600 hover:bg-gray-100 hover:text-gray-900"
                  }`}
                >
                  <item.icon className="h-5 w-5" />
                  {item.name}
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
        </header>

        {/* Page Content */}
        <main className="flex-1 overflow-auto p-6">{children}</main>
      </div>
    </div>
  )
}
