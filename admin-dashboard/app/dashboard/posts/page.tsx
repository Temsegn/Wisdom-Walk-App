
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
import { MoreHorizontal, Search, Trash2, Eye, Heart, MessageCircle, Users, ArrowLeft } from "lucide-react"
import { useToast } from "@/hooks/use-toast"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"

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
    type: "all",
    category: "all",
    time: "all"
  })
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

  const handleFilterChange = (key: string, value: string) => {
    setFilters(prev => ({ ...prev, [key]: value }))
  }

  const isWithinTimeRange = (createdAt: string, range: string) => {
    const postDate = new Date(createdAt)
    const now = new Date()
    
    if (range === "today") {
      return postDate.toDateString() === now.toDateString()
    } else if (range === "week") {
      const weekAgo = new Date(now.setDate(now.getDate() - 7))
      return postDate >= weekAgo
    } else if (range === "month") {
      const monthAgo = new Date(now.setMonth(now.getMonth() - 1))
      return postDate >= monthAgo
    } else if (range === "year") {
      const yearAgo = new Date(now.setFullYear(now.getFullYear() - 1))
      return postDate >= yearAgo
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
    
    const matchesType = filters.type !== "all" ? post.type === filters.type : true
    const matchesCategory = filters.category !== "all" ? post.category === filters.category : true
    const matchesTime = filters.time !== "all" ? isWithinTimeRange(post.createdAt, filters.time) : true
    
    return matchesSearch && matchesType && matchesCategory && matchesTime
  })

  const getPostTypeBadge = (type: string) => {
    switch (type) {
      case "confession":
        return (
          <Badge className="bg-gradient-to-r from-yellow-500 to-yellow-700 text-white font-medium">
            Confession
          </Badge>
        )
      case "testimony":
        return (
          <Badge className="bg-gradient-to-r from-green-500 to-green-700 text-white font-medium">
            Testimony
          </Badge>
        )
      case "struggle":
        return (
          <Badge className="bg-gradient-to-r from-red-500 to-red-700 text-white font-medium">
            Struggle
          </Badge>
        )
      default:
        return <Badge className="bg-gray-200 text-gray-800">{type}</Badge>
    }
  }

  const getCategoryBadge = (category: string) => {
    switch (category) {
      case "share":
        return <Badge className="border-blue-500 text-blue-600 font-medium">Share</Badge>
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

  if (loading) {
    return (
      <div className="container mx-auto px-4 sm:px-6 lg:px-8 py-6 space-y-6">
        <div className="h-8 bg-gradient-to-r from-gray-200 to-gray-300 rounded-lg w-48 animate-pulse"></div>
        <Card className="shadow-lg rounded-xl">
          <CardContent className="p-4 sm:p-6">
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
              <h1 className="text-2xl sm:text-3xl font-extrabold tracking-tight text-gray-900 bg-clip-text text-transparent bg-gradient-to-r from-indigo-500 to-purple-600">
                Community Posts
              </h1>
              <p className="text-gray-600 mt-1 text-sm sm:text-base">Manage and moderate all community content</p>
            </div>
          </div>

          <Card className="shadow-lg rounded-xl border-0 bg-white">
            <CardHeader>
              <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3 sm:gap-4">
                <div>
                  <CardTitle className="text-lg sm:text-xl font-semibold text-gray-900">Community Content</CardTitle>
                  <CardDescription className="text-gray-600 text-sm sm:text-base">
                    {filteredPosts.length} {filteredPosts.length === 1 ? 'post' : 'posts'} found
                  </CardDescription>
                </div>
                
                <div className="flex flex-col sm:flex-row items-start sm:items-center gap-2 w-full sm:w-auto">
                   <Select 
                    value={filters.type} 
                    onValueChange={(value) => handleFilterChange("type", value)}
                  >
                    <SelectTrigger className="w-full sm:w-32 rounded-md border-green-400 bg-green-50/50 text-green-700 focus:ring-green-500 focus:border-green-500 text-sm hover:bg-green-100 transition-colors">
                      <SelectValue placeholder="Type" />
                    </SelectTrigger>
                    <SelectContent className="rounded-md border-green-400 bg-white">
                      <SelectItem value="all">All types</SelectItem>
                      <SelectItem value="share">Share</SelectItem>
                      <SelectItem value="prayer">Prayer</SelectItem>
                     </SelectContent>
                  </Select>
                  <Select 
                    value={filters.category} 
                    onValueChange={(value) => handleFilterChange("category", value)}
                  >
                    <SelectTrigger className="w-full sm:w-32 rounded-md border-blue-400 bg-blue-50/50 text-blue-700 focus:ring-blue-500 focus:border-blue-500 text-sm hover:bg-blue-100 transition-colors">
                      <SelectValue placeholder="Category" />
                    </SelectTrigger>
                    <SelectContent className="rounded-md border-blue-400 bg-white">
                      <SelectItem value="all">All categories</SelectItem>
                       <SelectItem value="testimony">Testimony</SelectItem>
                      <SelectItem value="confession">Confession</SelectItem>
                      <SelectItem value="struggle">Struggle</SelectItem>
                    </SelectContent>
                  </Select>
                 
                  <Select 
                    value={filters.time} 
                    onValueChange={(value) => handleFilterChange("time", value)}
                  >
                    <SelectTrigger className="w-full sm:w-32 rounded-md border-purple-400 bg-purple-50/50 text-purple-700 focus:ring-purple-500 focus:border-purple-500 text-sm hover:bg-purple-100 transition-colors">
                      <SelectValue placeholder="Time" />
                    </SelectTrigger>
                    <SelectContent className="rounded-md border-purple-400 bg-white">
                      <SelectItem value="all">All time</SelectItem>
                      <SelectItem value="today">Today</SelectItem>
                      <SelectItem value="week">This Week</SelectItem>
                      <SelectItem value="month">This Month</SelectItem>
                      <SelectItem value="year">This Year</SelectItem>
                    </SelectContent>
                  </Select>
                  <div className="relative flex-1 w-full sm:max-w-xs">
                    <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-gray-500" />
                    <Input
                      placeholder="Search posts..."
                      value={searchTerm}
                      onChange={(e) => setSearchTerm(e.target.value)}
                      className="pl-10 rounded-lg border-gray-300 focus:ring-indigo-500 focus:border-indigo-500 text-sm hover:bg-gray-50 transition-colors"
                    />
                  </div>
                </div>
              </div>
            </CardHeader>
            
            <CardContent className="p-4 sm:p-6">
              {filteredPosts.length === 0 ? (
                <div className="flex flex-col items-center justify-center py-12 space-y-4">
                  <Search className="h-12 w-12 text-gray-400" />
                  <h3 className="text-lg font-semibold text-gray-900">No posts found</h3>
                  <p className="text-sm text-gray-600">
                    Try adjusting your search or filter criteria
                  </p>
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
                            <div className="font-semibold text-gray-900 text-sm sm:text-base">
                              {post.isAnonymous ? "Anonymous Sister" : `${post.author.firstName} ${post.author.lastName}`}
                            </div>
                            <div className="text-xs sm:text-sm text-gray-600">
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
                          <h3 className="font-semibold text-base sm:text-lg text-gray-900">{post.title}</h3>
                        )}
                        <p className="text-gray-700 whitespace-pre-line line-clamp-3 sm:line-clamp-none text-sm sm:text-base">{post.content}</p>
                      </div>

                      <div className="flex flex-wrap items-center gap-3 sm:gap-4 text-xs sm:text-sm text-gray-600 pt-2">
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
                <CardTitle className="text-lg sm:text-xl font-semibold text-gray-900">Post Details</CardTitle>
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
                      <div className="font-semibold text-base sm:text-lg text-gray-900">
                        {selectedPost.isAnonymous ? "Anonymous Sister" : `${selectedPost.author.firstName} ${selectedPost.author.lastName}`}
                      </div>
                      <div className="text-xs sm:text-sm text-gray-600">
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
                    <h3 className="font-semibold text-base sm:text-xl text-gray-900">{selectedPost.title}</h3>
                  )}
                  <p className="text-gray-700 whitespace-pre-line text-sm sm:text-base">{selectedPost.content}</p>
                </div>

                <div className="grid grid-cols-1 sm:grid-cols-2 gap-3 sm:gap-4">
                  <div>
                    <p className="text-xs sm:text-sm font-medium text-gray-900">Post ID</p>
                    <p className="text-xs sm:text-sm text-gray-600">{selectedPost._id}</p>
                  </div>
                  <div>
                    <p className="text-xs sm:text-sm font-medium text-gray-900">Author ID</p>
                    <p className="text-xs sm:text-sm text-gray-600">{selectedPost.author._id}</p>
                  </div>
                  <div>
                    <p className="text-xs sm:text-sm font-medium text-gray-900">Likes</p>
                    <p className="text-xs sm:text-sm text-gray-600">{selectedPost.likes.length}</p>
                  </div>
                  <div>
                    <p className="text-xs sm:text-sm font-medium text-gray-900">Comments</p>
                    <p className="text-xs sm:text-sm text-gray-600">{selectedPost.commentsCount}</p>
                  </div>
                  <div>
                    <p className="text-xs sm:text-sm font-medium text-gray-900">Prayers</p>
                    <p className="text-xs sm:text-sm text-gray-600">{selectedPost.prayers.length}</p>
                  </div>
                  <div>
                    <p className="text-xs sm:text-sm font-medium text-gray-900">Virtual Hugs</p>
                    <p className="text-xs sm:text-sm text-gray-600">{selectedPost.virtualHugs.length}</p>
                  </div>
                  <div>
                    <p className="text-xs sm:text-sm font-medium text-gray-900">Report Count</p>
                    <p className="text-xs sm:text-sm text-gray-600">{selectedPost.reportCount}</p>
                  </div>
                  <div>
                    <p className="text-xs sm:text-sm font-medium text-gray-900">Visibility</p>
                    <p className="text-xs sm:text-sm text-gray-600">{selectedPost.isHidden ? "Hidden" : "Visible"}</p>
                  </div>
                </div>

                <div className="flex gap-2">
                  <Button
                    variant="destructive"
                    onClick={() => {
                      setShowDeleteDialog(true)
                    }}
                    className="rounded-lg bg-red-600 hover:bg-red-700 text-sm"
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
        <AlertDialogContent className="rounded-lg max-w-[90vw] sm:max-w-md">
          <AlertDialogHeader>
            <AlertDialogTitle className="text-gray-900">Delete Post</AlertDialogTitle>
            <AlertDialogDescription className="text-gray-600 text-sm">
              Are you sure you want to delete this post? This action cannot be undone and will also remove all
              associated comments and interactions.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel className="rounded-lg text-sm">Cancel</AlertDialogCancel>
            <AlertDialogAction
              onClick={() => selectedPost && handleDeletePost(selectedPost._id)}
              className="rounded-lg bg-red-600 hover:bg-red-700 text-sm"
            >
              Delete Post
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  )
}
 