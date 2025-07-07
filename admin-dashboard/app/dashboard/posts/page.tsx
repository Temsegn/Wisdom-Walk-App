
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
import { MoreHorizontal, Search, Trash2, Eye, Heart, MessageCircle, Users, Filter, X, ArrowLeft } from "lucide-react"
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
  const [showDetailView, setShowDetailView] = useState(false)
  const [filters, setFilters] = useState({
    type: "",
    category: "",
    time: "",
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
      const response = await fetch("/api/posts", {
        headers: {
          Authorization: `Bearer ${token}`,
        },
      })

      if (response.ok) {
        const data = await response.json()
        setPosts(data.data)
      } else {
        throw new Error("Failed to fetch posts")
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

  const fetchPostById = async (postId: string) => {
    try {
      const token = localStorage.getItem("adminToken")
      const response = await fetch(`/api/posts/${postId}`, {
        headers: {
          Authorization: `Bearer ${token}`,
        },
      })

      if (response.ok) {
        const data = await response.json()
        setSelectedPost(data.data)
        setShowDetailView(true)
      } else {
        throw new Error("Failed to fetch post details")
      }
    } catch (error) {
      console.error("Error fetching post:", error)
      toast({
        title: "Error",
        description: "Failed to fetch post details",
        variant: "destructive",
      })
    }
  }

  const handleDeletePost = async (postId: string) => {
    try {
      const token = localStorage.getItem("adminToken")
      const response = await fetch(`/api/posts/${postId}`, {
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
    setShowDetailView(false)
  }

  const handleFilterChange = (key: string, value: string | boolean) => {
    setFilters(prev => ({ ...prev, [key]: value }))
  }

  const clearFilters = () => {
    setFilters({
      type: "",
      category: "",
      time: "",
      reportedOnly: false
    })
    setSearchTerm("")
  }

  const isWithinTimeRange = (createdAt: string, range: string) => {
    const postDate = new Date(createdAt)
    const now = new Date()
    
    if (range === "today") {
      return postDate.toDateString() === now.toDateString()
    } else if (range === "week") {
      const weekAgo = new Date(now.setDate(now.getDate() - 7))
      return postDate >= weekAgo
    }
    return true
  }

  const filteredPosts = posts.filter((post) => {
    const matchesSearch = 
      post.content.toLowerCase().includes(searchTerm.toLowerCase()) ||
      post.title?.toLowerCase().includes(searchTerm.toLowerCase()) ||
      (!post.isAnonymous &&
        (post.author.firstName.toLowerCase().includes(searchTerm.toLowerCase()) ||
          post.author.lastName.toLowerCase().includes(searchTerm.toLowerCase())))
    
    const matchesType = filters.type ? post.type === filters.type : true
    const matchesCategory = filters.category ? post.category === filters.category : true
    const matchesReported = filters.reportedOnly ? post.isReported : true
    const matchesTime = filters.time ? isWithinTimeRange(post.createdAt, filters.time) : true
    const matchesTab = 
      activeTab === "all" ? true :
      activeTab === "prayers" ? post.type === "prayer" :
      activeTab === "shares" ? post.type === "share" :
      activeTab === "reported" ? post.isReported : true
    
    return matchesSearch && matchesType && matchesCategory && matchesReported && matchesTime && matchesTab
  })

  const getPostTypeBadge = (type: string) => {
    switch (type) {
      case "prayer":
        return (
          <Badge className="bg-gradient-to-r from-purple-500 to-purple-700 text-white font-medium">
            Prayer
          </Badge>
        )
      case "share":
        return (
          <Badge className="bg-gradient-to-r from-blue-500 to-blue-700 text-white font-medium">
            Share
          </Badge>
        )
      default:
        return <Badge className="bg-gray-200 text-gray-800">{type}</Badge>
    }
  }

  const getCategoryBadge = (category: string) => {
    switch (category) {
      case "testimony":
        return <Badge className="border-green-500 text-green-600 font-medium">Testimony</Badge>
      case "confession":
        return <Badge className="border-yellow-500 text-yellow-600 font-medium">Confession</Badge>
      case "struggle":
        return <Badge className="border-red-500 text-red-600 font-medium">Struggle</Badge>
      default:
        return null
    }
  }

  // Calculate stats for rectangular cards
  const totalPosts = posts.length
  const reportedPosts = posts.filter(post => post.isReported).length
  const prayerPosts = posts.filter(post => post.type === "prayer").length
  const sharePosts = posts.filter(post => post.type === "share").length

  if (loading) {
    return (
      <div className="container mx-auto px-4 sm:px-6 lg:px-8 py-6 space-y-6">
        <div className="h-8 bg-gradient-to-r from-gray-200 to-gray-300 rounded-lg w-48 animate-pulse"></div>
        <Card className="shadow-lg rounded-xl">
          <CardContent className="p-6">
            <div className="space-y-4">
              {[...Array(5)].map((_, i) => (
                <div key={i} className="space-y-3 border-b pb-4">
                  <div className="flex items-center space-x-3">
                    <div className="h-10 w-10 bg-gradient-to-r from-gray-200 to-gray-300 rounded-full animate-pulse"></div>
                    <div className="space-y-2 flex-1">
                      <div className="h-4 bg-gradient-to-r from-gray-200 to-gray-300 rounded w-32 animate-pulse"></div>
                      <div className="h-3 bg-gradient-to-r from-gray-200 to-gray-300 rounded w-48 animate-pulse"></div>
                    </div>
                  </div>
                  <div className="h-16 bg-gradient-to-r from-gray-200 to-gray-300 rounded-lg animate-pulse"></div>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>
      </div>
    )
  }

  return (
    <div className="container mx-auto px-4 sm:px-6 lg:px-8 py-6 space-y-6">
      {!showDetailView ? (
        <>
          <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
            <div>
              <h1 className="text-3xl font-extrabold tracking-tight text-gray-900 bg-clip-text text-transparent bg-gradient-to-r from-indigo-500 to-purple-600">
                Community Posts
              </h1>
              <p className="text-gray-600 mt-1">Manage and moderate all community content</p>
            </div>
          </div>

          {/* Stats Cards */}
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
            <Card className="shadow-md hover:shadow-lg transition-shadow rounded-xl bg-gradient-to-br from-indigo-50 to-blue-50">
              <CardHeader className="pb-2">
                <CardTitle className="text-sm font-semibold text-indigo-700">Total Posts</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold text-indigo-900">{totalPosts}</div>
              </CardContent>
            </Card>
            <Card className="shadow-md hover:shadow-lg transition-shadow rounded-xl bg-gradient-to-br from-red-50 to-pink-50">
              <CardHeader className="pb-2">
                <CardTitle className="text-sm font-semibold text-red-700">Reported Posts</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold text-red-900">{reportedPosts}</div>
              </CardContent>
            </Card>
            <Card className="shadow-md hover:shadow-lg transition-shadow rounded-xl bg-gradient-to-br from-purple-50 to-violet-50">
              <CardHeader className="pb-2">
                <CardTitle className="text-sm font-semibold text-purple-700">Prayer Posts</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold text-purple-900">{prayerPosts}</div>
              </CardContent>
            </Card>
            <Card className="shadow-md hover:shadow-lg transition-shadow rounded-xl bg-gradient-to-br from-blue-50 to-cyan-50">
              <CardHeader className="pb-2">
                <CardTitle className="text-sm font-semibold text-blue-700">Share Posts</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold text-blue-900">{sharePosts}</div>
              </CardContent>
            </Card>
          </div>

          <Tabs value={activeTab} onValueChange={setActiveTab} className="w-full">
            <TabsList className="grid w-full grid-cols-2 sm:grid-cols-4 gap-2 bg-gray-100 p-2 rounded-lg">
              <TabsTrigger value="all" className="rounded-md data-[state=active]:bg-indigo-600 data-[state=active]:text-white">All Posts</TabsTrigger>
              <TabsTrigger value="prayers" className="rounded-md data-[state=active]:bg-purple-600 data-[state=active]:text-white">Prayers</TabsTrigger>
              <TabsTrigger value="shares" className="rounded-md data-[state=active]:bg-blue-600 data-[state=active]:text-white">Shares</TabsTrigger>
              <TabsTrigger value="reported" className="rounded-md data-[state=active]:bg-red-600 data-[state=active]:text-white">Reported</TabsTrigger>
            </TabsList>
          </Tabs>

          <Card className="shadow-lg rounded-xl border-0 bg-white">
            <CardHeader>
              <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
                <div>
                  <CardTitle className="text-xl font-semibold text-gray-900">Community Content</CardTitle>
                  <CardDescription className="text-gray-600">
                    {filteredPosts.length} {filteredPosts.length === 1 ? 'post' : 'posts'} found
                  </CardDescription>
                </div>
                
                <div className="flex flex-col sm:flex-row items-start sm:items-center gap-2 w-full sm:w-auto">
                  <div className="relative flex-1 sm:max-w-sm w-full">
                    <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-gray-500" />
                    <Input
                      placeholder="Search posts..."
                      value={searchTerm}
                      onChange={(e) => setSearchTerm(e.target.value)}
                      className="pl-10 rounded-lg border-gray-300 focus:ring-indigo-500 focus:border-indigo-500"
                    />
                  </div>
                  
                  <DropdownMenu>
                    <DropdownMenuTrigger asChild>
                      <Button variant="outline" className="rounded-lg border-gray-300 hover:bg-gray-50">
                        <Filter className="h-4 w-4 mr-2" />
                        Filters
                      </Button>
                    </DropdownMenuTrigger>
                    <DropdownMenuContent className="w-64 sm:w-72 rounded-lg shadow-lg">
                      <DropdownMenuLabel className="font-semibold text-gray-900">Filter Posts</DropdownMenuLabel>
                      <DropdownMenuSeparator />
                      
                      <div className="px-3 py-2 space-y-3">
                        <div>
                          <p className="text-xs font-medium text-gray-600 mb-1">Post Type</p>
                          <Select 
                            value={filters.type} 
                            onValueChange={(value) => handleFilterChange("type", value)}
                          >
                            <SelectTrigger className="w-full rounded-md border-gray-300">
                              <SelectValue placeholder="All types" />
                            </SelectTrigger>
                            <SelectContent className="rounded-md">
                              <SelectItem value="">All types</SelectItem>
                              <SelectItem value="prayer">Prayer</SelectItem>
                              <SelectItem value="share">Share</SelectItem>
                            </SelectContent>
                          </Select>
                        </div>
                        
                        <div>
                          <p className="text-xs font-medium text-gray-600 mb-1">Category</p>
                          <Select 
                            value={filters.category} 
                            onValueChange={(value) => handleFilterChange("category", value)}
                          >
                            <SelectTrigger className="w-full rounded-md border-gray-300">
                              <SelectValue placeholder="All categories" />
                            </SelectTrigger>
                            <SelectContent className="rounded-md">
                              <SelectItem value="">All categories</SelectItem>
                              <SelectItem value="testimony">Testimony</SelectItem>
                              <SelectItem value="confession">Confession</SelectItem>
                              <SelectItem value="struggle">Struggle</SelectItem>
                            </SelectContent>
                          </Select>
                        </div>
                        
                        <div>
                          <p className="text-xs font-medium text-gray-600 mb-1">Time Range</p>
                          <Select 
                            value={filters.time} 
                            onValueChange={(value) => handleFilterChange("time", value)}
                          >
                            <SelectTrigger className="w-full rounded-md border-gray-300">
                              <SelectValue placeholder="All time" />
                            </SelectTrigger>
                            <SelectContent className="rounded-md">
                              <SelectItem value="">All time</SelectItem>
                              <SelectItem value="today">Today</SelectItem>
                              <SelectItem value="week">This Week</SelectItem>
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
                          <label htmlFor="reportedOnly" className="text-sm font-medium text-gray-700">
                            Reported only
                          </label>
                        </div>
                      </div>
                      
                      <DropdownMenuSeparator />
                      <DropdownMenuItem onClick={clearFilters} className="text-red-600 hover:bg-red-50">
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
                  <Search className="h-12 w-12 text-gray-400" />
                  <h3 className="text-lg font-semibold text-gray-900">No posts found</h3>
                  <p className="text-sm text-gray-600">
                    Try adjusting your search or filter criteria
                  </p>
                  <Button 
                    variant="outline" 
                    onClick={clearFilters}
                    className="rounded-lg border-gray-300 hover:bg-gray-50"
                  >
                    Clear filters
                  </Button>
                </div>
              ) : (
                <div className="space-y-4">
                  {filteredPosts.map((post) => (
                    <div key={post._id} className="border rounded-lg p-4 sm:p-6 space-y-3 hover:shadow-md transition-shadow bg-white">
                      <div className="flex flex-col sm:flex-row items-start justify-between gap-4">
                        <div className="flex items-center space-x-3 w-full">
                          <Avatar className="h-10 w-10">
                            <AvatarImage src={post.isAnonymous ? undefined : post.author.profilePicture} />
                            <AvatarFallback className="bg-indigo-100 text-indigo-800">
                              {post.isAnonymous ? "A" : `${post.author.firstName[0]}${post.author.lastName[0]}`}
                            </AvatarFallback>
                          </Avatar>
                          <div className="flex-1">
                            <div className="font-semibold text-gray-900">
                              {post.isAnonymous ? "Anonymous Sister" : `${post.author.firstName} ${post.author.lastName}`}
                            </div>
                            <div className="text-sm text-gray-600">
                              {new Date(post.createdAt).toLocaleDateString('en-US', {
                                year: 'numeric',
                                month: 'short',
                                day: 'numeric',
                                hour: '2-digit',
                                minute: '2-digit'
                              })}
                            </div>
                          </div>
                          <div className="flex flex-wrap gap-2">
                            {getPostTypeBadge(post.type)}
                            {post.category && getCategoryBadge(post.category)}
                            {post.isReported && (
                              <Badge className="bg-red-600 text-white flex items-center gap-1">
                                Reported {post.reportCount > 0 && `(${post.reportCount})`}
                              </Badge>
                            )}
                          </div>
                        </div>

                        <DropdownMenu>
                          <DropdownMenuTrigger asChild>
                            <Button variant="ghost" className="h-8 w-8 p-0">
                              <MoreHorizontal className="h-5 w-5 text-gray-600" />
                            </Button>
                          </DropdownMenuTrigger>
                          <DropdownMenuContent align="end" className="rounded-md">
                            <DropdownMenuLabel className="font-semibold">Actions</DropdownMenuLabel>
                            <DropdownMenuSeparator />
                            <DropdownMenuItem onClick={() => fetchPostById(post._id)} className="hover:bg-indigo-50">
                              <Eye className="mr-2 h-4 w-4 text-indigo-600" />
                              View Details
                            </DropdownMenuItem>
                            <DropdownMenuItem
                              onClick={() => {
                                setSelectedPost(post)
                                setShowDeleteDialog(true)
                              }}
                              className="text-red-600 hover:bg-red-50"
                            >
                              <Trash2 className="mr-2 h-4 w-4" />
                              Delete Post
                            </DropdownMenuItem>
                          </DropdownMenuContent>
                        </DropdownMenu>
                      </div>

                      <div className="space-y-2">
                        {post.title && (
                          <h3 className="font-semibold text-lg text-gray-900">{post.title}</h3>
                        )}
                        <p className="text-gray-700 whitespace-pre-line line-clamp-3 sm:line-clamp-none">{post.content}</p>
                      </div>

                      <div className="flex flex-wrap items-center gap-4 text-sm text-gray-600 pt-2">
                        <div className="flex items-center space-x-1">
                          <Heart className="h-4 w-4 text-red-500" />
                          <span>{post.likes.length} likes</span>
                        </div>
                        <div className="flex items-center space-x-1">
                          <MessageCircle className="h-4 w-4 text-blue-500" />
                          <span>{post.commentsCount} comments</span>
                        </div>
                        <div className="flex items-center space-x-1">
                          <Users className="h-4 w-4 text-purple-500" />
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
        </>
      ) : (
        <Card className="shadow-lg rounded-xl border-0 bg-white">
          <CardHeader>
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-2">
                <Button
                  variant="ghost"
                  onClick={() => setShowDetailView(false)}
                  className="h-8 w-8 p-0"
                >
                  <ArrowLeft className="h-5 w-5 text-indigo-600" />
                </Button>
                <CardTitle className="text-xl font-semibold text-gray-900">Post Details</CardTitle>
              </div>
            </div>
          </CardHeader>
          <CardContent className="p-4 sm:p-6">
            {selectedPost && (
              <div className="space-y-6">
                <div className="flex flex-col sm:flex-row items-start justify-between gap-4">
                  <div className="flex items-center space-x-3">
                    <Avatar className="h-12 w-12">
                      <AvatarImage src={selectedPost.isAnonymous ? undefined : selectedPost.author.profilePicture} />
                      <AvatarFallback className="bg-indigo-100 text-indigo-800">
                        {selectedPost.isAnonymous ? "A" : `${selectedPost.author.firstName[0]}${selectedPost.author.lastName[0]}`}
                      </AvatarFallback>
                    </Avatar>
                    <div>
                      <div className="font-semibold text-lg text-gray-900">
                        {selectedPost.isAnonymous ? "Anonymous Sister" : `${selectedPost.author.firstName} ${selectedPost.author.lastName}`}
                      </div>
                      <div className="text-sm text-gray-600">
                        {new Date(selectedPost.createdAt).toLocaleDateString('en-US', {
                          year: 'numeric',
                          month: 'long',
                          day: 'numeric',
                          hour: '2-digit',
                          minute: '2-digit'
                        })}
                      </div>
                    </div>
                    <div className="flex flex-wrap gap-2">
                      {getPostTypeBadge(selectedPost.type)}
                      {selectedPost.category && getCategoryBadge(selectedPost.category)}
                      {selectedPost.isReported && (
                        <Badge className="bg-red-600 text-white flex items-center gap-1">
                          Reported {selectedPost.reportCount > 0 && `(${selectedPost.reportCount})`}
                        </Badge>
                      )}
                      {selectedPost.isHidden && (
                        <Badge className="bg-gray-200 text-gray-800">Hidden</Badge>
                      )}
                    </div>
                  </div>
                </div>

                <div className="space-y-4">
                  {selectedPost.title && (
                    <h3 className="font-semibold text-xl text-gray-900">{selectedPost.title}</h3>
                  )}
                  <p className="text-gray-700 whitespace-pre-line">{selectedPost.content}</p>
                </div>

                <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                  <div>
                    <p className="text-sm font-medium text-gray-900">Post ID</p>
                    <p className="text-sm text-gray-600">{selectedPost._id}</p>
                  </div>
                  <div>
                    <p className="text-sm font-medium text-gray-900">Author ID</p>
                    <p className="text-sm text-gray-600">{selectedPost.author._id}</p>
                  </div>
                  <div>
                    <p className="text-sm font-medium text-gray-900">Likes</p>
                    <p className="text-sm text-gray-600">{selectedPost.likes.length}</p>
                  </div>
                  <div>
                    <p className="text-sm font-medium text-gray-900">Comments</p>
                    <p className="text-sm text-gray-600">{selectedPost.commentsCount}</p>
                  </div>
                  <div>
                    <p className="text-sm font-medium text-gray-900">Prayers</p>
                    <p className="text-sm text-gray-600">{selectedPost.prayers.length}</p>
                  </div>
                  <div>
                    <p className="text-sm font-medium text-gray-900">Virtual Hugs</p>
                    <p className="text-sm text-gray-600">{selectedPost.virtualHugs.length}</p>
                  </div>
                  <div>
                    <p className="text-sm font-medium text-gray-900">Report Count</p>
                    <p className="text-sm text-gray-600">{selectedPost.reportCount}</p>
                  </div>
                  <div>
                    <p className="text-sm font-medium text-gray-900">Visibility</p>
                    <p className="text-sm text-gray-600">{selectedPost.isHidden ? "Hidden" : "Visible"}</p>
                  </div>
                </div>

                <div className="flex gap-2">
                  <Button
                    variant="destructive"
                    onClick={() => {
                      setShowDeleteDialog(true)
                    }}
                    className="rounded-lg bg-red-600 hover:bg-red-700"
                  >
                    <Trash2 className="mr-2 h-4 w-4" />
                    Delete Post
                  </Button>
                </div>
              </div>
            )}
          </CardContent>
        </Card>
      )}

      <AlertDialog open={showDeleteDialog} onOpenChange={setShowDeleteDialog}>
        <AlertDialogContent className="rounded-lg">
          <AlertDialogHeader>
            <AlertDialogTitle className="text-gray-900">Delete Post</AlertDialogTitle>
            <AlertDialogDescription className="text-gray-600">
              Are you sure you want to delete this post? This action cannot be undone and will also remove all
              associated comments and interactions.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel className="rounded-lg">Cancel</AlertDialogCancel>
            <AlertDialogAction
              onClick={() => selectedPost && handleDeletePost(selectedPost._id)}
              className="rounded-lg bg-red-600 hover:bg-red-700"
            >
              Delete Post
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  )
}
 