"use client"

import { useEffect, useState } from "react"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Badge } from "@/components/ui/badge"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
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
import { MoreHorizontal, Search, Trash2, Eye, Heart, MessageCircle, Users, Filter, X } from "lucide-react"
import { useToast } from "@/hooks/use-toast"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"

interface Post {
  _id: string
  author: {
    _id: string
    firstName: string
    lastName: string
    profilePicture?: string
  }
  type: string
  category: string
  content: string
  title?: string
  isAnonymous: boolean
  likes: any[]
  prayers: any[]
  virtualHugs: any[]
  commentsCount: number
  reportCount: number
  isReported: boolean
  isHidden: boolean
  createdAt: string
}

export default function PostsPage() {
  const [posts, setPosts] = useState<Post[]>([])
  const [loading, setLoading] = useState(true)
  const [searchTerm, setSearchTerm] = useState("")
  const [selectedPost, setSelectedPost] = useState<Post | null>(null)
  const [showDeleteDialog, setShowDeleteDialog] = useState(false)
  const [filters, setFilters] = useState({
    type: "",
    category: "",
    reportedOnly: false
  })
  const [activeTab, setActiveTab] = useState("all")
  const { toast } = useToast()

  useEffect(() => {
    fetchPosts()
  }, [])

  const fetchPosts = async () => {
    try {
      const token = localStorage.getItem("adminToken")
      const response = await fetch("https://wisdom-walk-app.onrender.com/api/posts/posts", {
        headers: {
          Authorization: `Bearer ${token}`,
        },
      })

      if (response.ok) {
        const data = await response.json()
        setPosts(data.data)
      }
    } catch (error) {
      console.error("Error fetching posts:", error)
      toast({
        title: "Error",
        description: "Failed to fetch posts",
        variant: "destructive",
      })
    } finally {
      setLoading(false)
    }
  }

  const handleDeletePost = async (postId: string) => {
    try {
      const token = localStorage.getItem("adminToken")
      const response = await fetch(`https://wisdom-walk-app.onrender.com/api/posts/${postId}`, {
        method: "DELETE",
        headers: {
          Authorization: `Bearer ${token}`,
        },
      })

      if (response.ok) {
        toast({
          title: "Success",
          description: "Post deleted successfully",
        })
        fetchPosts()
      } else {
        throw new Error("Failed to delete post")
      }
    } catch (error) {
      console.error("Error deleting post:", error)
      toast({
        title: "Error",
        description: "Failed to delete post",
        variant: "destructive",
      })
    }
    setShowDeleteDialog(false)
    setSelectedPost(null)
  }

  const handleFilterChange = (key: string, value: string | boolean) => {
    setFilters(prev => ({ ...prev, [key]: value }))
  }

  const clearFilters = () => {
    setFilters({
      type: "",
      category: "",
      reportedOnly: false 
    })
    setSearchTerm("")
  }

  const filteredPosts = posts.filter((post) => {
    // Search term filter
    const matchesSearch = 
      post.content.toLowerCase().includes(searchTerm.toLowerCase()) ||
      post.title?.toLowerCase().includes(searchTerm.toLowerCase()) ||
      (!post.isAnonymous &&
        (post.author.firstName.toLowerCase().includes(searchTerm.toLowerCase()) ||
          post.author.lastName.toLowerCase().includes(searchTerm.toLowerCase())))
    
    // Type filter
    const matchesType = filters.type ? post.type === filters.type : true
    
    // Category filter
    const matchesCategory = filters.category ? post.category === filters.category : true
    
    // Reported filter
    const matchesReported = filters.reportedOnly ? post.isReported : true
    
    // Tab filter
    const matchesTab = 
      activeTab === "all" ? true :
      activeTab === "prayers" ? post.type === "prayer" :
      activeTab === "shares" ? post.type === "share" : true
    
    return matchesSearch && matchesType && matchesCategory && matchesReported && matchesTab
  })

  const getPostTypeBadge = (type: string) => {
    switch (type) {
      case "prayer":
        return (
          <Badge variant="default" className="bg-purple-100 text-purple-800">
            Prayer
          </Badge>
        )
      case "share":
        return (
          <Badge variant="default" className="bg-blue-100 text-blue-800">
            Share
          </Badge>
        )
      default:
        return <Badge variant="secondary">{type}</Badge>
    }
  }

  const getCategoryBadge = (category: string) => {
    switch (category) {
      case "testimony":
        return <Badge variant="outline" className="border-green-200 text-green-800">Testimony</Badge>
      case "confession":
        return <Badge variant="outline" className="border-yellow-200 text-yellow-800">Confession</Badge>
      case "struggle":
        return <Badge variant="outline" className="border-red-200 text-red-800">Struggle</Badge>
      default:
        return null
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
                <div key={i} className="space-y-3 border-b pb-4">
                  <div className="flex items-center space-x-3">
                    <div className="h-8 w-8 bg-gray-200 rounded-full animate-pulse"></div>
                    <div className="space-y-1 flex-1">
                      <div className="h-4 bg-gray-200 rounded w-32 animate-pulse"></div>
                      <div className="h-3 bg-gray-200 rounded w-48 animate-pulse"></div>
                    </div>
                  </div>
                  <div className="h-16 bg-gray-200 rounded animate-pulse"></div>
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
      <div className="flex justify-between items-start">
        <div>
          <h1 className="text-3xl font-bold tracking-tight">Community Posts</h1>
          <p className="text-muted-foreground">Manage and moderate all community content</p>
        </div>
      </div>

      <Tabs value={activeTab} onValueChange={setActiveTab}>
        <TabsList className="grid w-full grid-cols-4">
          <TabsTrigger value="all">All Posts</TabsTrigger>
          <TabsTrigger value="prayers">Prayers</TabsTrigger>
          <TabsTrigger value="shares">Shares</TabsTrigger>
          <TabsTrigger value="reported">Reported</TabsTrigger>
        </TabsList>
      </Tabs>

      <Card>
        <CardHeader>
          <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
            <div>
              <CardTitle>Community Content</CardTitle>
              <CardDescription>
                {filteredPosts.length} {filteredPosts.length === 1 ? 'post' : 'posts'} found
              </CardDescription>
            </div>
            
            <div className="flex items-center gap-2">
              <div className="relative flex-1 max-w-sm">
                <Search className="absolute left-2 top-2.5 h-4 w-4 text-muted-foreground" />
                <Input
                  placeholder="Search posts..."
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                  className="pl-8"
                />
              </div>
              
              <DropdownMenu>
  <DropdownMenuTrigger asChild>
    <Button variant="outline">
      <Filter className="h-4 w-4 mr-2" />
      Filters
    </Button>
  </DropdownMenuTrigger>
  <DropdownMenuContent className="w-56">
    <DropdownMenuLabel>Filter Posts</DropdownMenuLabel>
    <DropdownMenuSeparator />
    
    <div className="px-2 py-1.5 space-y-2">
      <div>
        <p className="text-xs text-muted-foreground mb-1">Post Type</p>
        <Select 
          value={filters.type} 
          onValueChange={(value) => handleFilterChange("type", value)}
        >
          <SelectTrigger className="w-full">
            <SelectValue placeholder="All types" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="all">All types</SelectItem>
            <SelectItem value="prayer">Prayer</SelectItem>
            <SelectItem value="share">Share</SelectItem>
          </SelectContent>
        </Select>
      </div>
      
      <div>
        <p className="text-xs text-muted-foreground mb-1">Category</p>
        <Select 
          value={filters.category} 
          onValueChange={(value) => handleFilterChange("category", value)}
        >
          <SelectTrigger className="w-full">
            <SelectValue placeholder="All categories" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="all">All categories</SelectItem>
            <SelectItem value="testimony">Testimony</SelectItem>
            <SelectItem value="confession">Confession</SelectItem>
            <SelectItem value="struggle">Struggle</SelectItem>
          </SelectContent>
        </Select>
      </div>
      
      <div className="flex items-center space-x-2 pt-1">
        <input
          type="checkbox"
          id="reportedOnly"
          checked={filters.reportedOnly}
          onChange={(e) => handleFilterChange("reportedOnly", e.target.checked)}
          className="h-4 w-4 rounded border-gray-300 text-indigo-600 focus:ring-indigo-500"
        />
        <label htmlFor="reportedOnly" className="text-sm font-medium leading-none">
          Reported only
        </label>
      </div>
    </div>
    
    <DropdownMenuSeparator />
    <DropdownMenuItem onClick={clearFilters}>
      <X className="mr-2 h-4 w-4" />
      Clear filters
    </DropdownMenuItem>
  </DropdownMenuContent>
</DropdownMenu>
            </div>
          </div>
        </CardHeader>
        
        <CardContent>
          {filteredPosts.length === 0 ? (
            <div className="flex flex-col items-center justify-center py-12 space-y-4">
              <Search className="h-12 w-12 text-muted-foreground" />
              <h3 className="text-lg font-medium">No posts found</h3>
              <p className="text-sm text-muted-foreground">
                Try adjusting your search or filter criteria
              </p>
              <Button variant="outline" onClick={clearFilters}>
                Clear filters
              </Button>
            </div>
          ) : (
            <div className="space-y-6">
              {filteredPosts.map((post) => (
                <div key={post._id} className="border rounded-lg p-4 space-y-3 hover:shadow-sm transition-shadow">
                  {/* Post Header */}
                  <div className="flex items-start justify-between">
                    <div className="flex items-center space-x-3">
                      <Avatar className="h-8 w-8">
                        <AvatarImage src={post.isAnonymous ? undefined : post.author.profilePicture} />
                        <AvatarFallback>
                          {post.isAnonymous ? "A" : `${post.author.firstName[0]}${post.author.lastName[0]}`}
                        </AvatarFallback>
                      </Avatar>
                      <div>
                        <div className="font-medium">
                          {post.isAnonymous ? "Anonymous Sister" : `${post.author.firstName} ${post.author.lastName}`}
                        </div>
                        <div className="text-sm text-muted-foreground">
                          {new Date(post.createdAt).toLocaleDateString('en-US', {
                            year: 'numeric',
                            month: 'short',
                            day: 'numeric',
                            hour: '2-digit',
                            minute: '2-digit'
                          })}
                        </div>
                      </div>
                      <div className="flex gap-2">
                        {getPostTypeBadge(post.type)}
                        {post.category && getCategoryBadge(post.category)}
                        {post.isReported && (
                          <Badge variant="destructive" className="flex items-center gap-1">
                            Reported {post.reportCount > 0 && `(${post.reportCount})`}
                          </Badge>
                        )}
                      </div>
                    </div>

                    <DropdownMenu>
                      <DropdownMenuTrigger asChild>
                        <Button variant="ghost" className="h-8 w-8 p-0">
                          <MoreHorizontal className="h-4 w-4" />
                        </Button>
                      </DropdownMenuTrigger>
                      <DropdownMenuContent align="end">
                        <DropdownMenuLabel>Actions</DropdownMenuLabel>
                        <DropdownMenuSeparator />
                        <DropdownMenuItem>
                          <Eye className="mr-2 h-4 w-4" />
                          View Details
                        </DropdownMenuItem>
                        <DropdownMenuItem
                          onClick={() => {
                            setSelectedPost(post)
                            setShowDeleteDialog(true)
                          }}
                          className="text-red-600"
                        >
                          <Trash2 className="mr-2 h-4 w-4" />
                          Delete Post
                        </DropdownMenuItem>
                      </DropdownMenuContent>
                    </DropdownMenu>
                  </div>

                  {/* Post Content */}
                  <div className="space-y-2">
                    {post.title && (
                      <h3 className="font-semibold text-lg text-gray-900">{post.title}</h3>
                    )}
                    <p className="text-gray-700 whitespace-pre-line">{post.content}</p>
                  </div>

                  {/* Post Stats */}
                  <div className="flex items-center space-x-6 text-sm text-muted-foreground pt-2">
                    <div className="flex items-center space-x-1">
                      <Heart className="h-4 w-4" />
                      <span>{post.likes.length} likes</span>
                    </div>
                    <div className="flex items-center space-x-1">
                      <MessageCircle className="h-4 w-4" />
                      <span>{post.commentsCount} comments</span>
                    </div>
                    <div className="flex items-center space-x-1">
                      <Users className="h-4 w-4" />
                      <span>{post.prayers.length} prayers</span>
                    </div>
                    <div className="flex items-center space-x-1">
                      <span>🤗</span>
                      <span>{post.virtualHugs.length} hugs</span>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          )}
        </CardContent>
      </Card>

      {/* Delete Confirmation Dialog */}
      <AlertDialog open={showDeleteDialog} onOpenChange={setShowDeleteDialog}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>Delete Post</AlertDialogTitle>
            <AlertDialogDescription>
              Are you sure you want to delete this post? This action cannot be undone and will also remove all
              associated comments and interactions.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel>Cancel</AlertDialogCancel>
            <AlertDialogAction
              onClick={() => selectedPost && handleDeletePost(selectedPost._id)}
              className="bg-red-600 hover:bg-red-700"
            >
              Delete Post
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  )
}