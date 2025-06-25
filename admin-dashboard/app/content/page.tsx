"use client"

import { useState } from "react"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { SidebarInset, SidebarTrigger } from "@/components/ui/sidebar"
import { Separator } from "@/components/ui/separator"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Badge } from "@/components/ui/badge"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { useToast } from "@/hooks/use-toast"
import { Search, Filter, Eye, Flag, Trash2, CheckCircle, XCircle, MessageSquare } from "lucide-react"

interface Post {
  id: string
  title: string
  author: string
  authorEmail: string
  content: string
  createdDate: string
  status: "published" | "draft" | "reported" | "removed"
  category: string
  likes: number
  comments: number
  reports: number
}

const mockPosts: Post[] = [
  {
    id: "1",
    title: "Getting Started with React Development",
    author: "john_doe",
    authorEmail: "john.doe@example.com",
    content: "React is a powerful JavaScript library for building user interfaces...",
    createdDate: "2024-01-20",
    status: "published",
    category: "Technology",
    likes: 45,
    comments: 12,
    reports: 0,
  },
  {
    id: "2",
    title: "Best Practices for Web Design",
    author: "jane_smith",
    authorEmail: "jane.smith@example.com",
    content: "Creating beautiful and functional web designs requires attention to detail...",
    createdDate: "2024-01-18",
    status: "published",
    category: "Design",
    likes: 32,
    comments: 8,
    reports: 0,
  },
  {
    id: "3",
    title: "Controversial Opinion on Modern Tech",
    author: "mike_wilson",
    authorEmail: "mike.wilson@example.com",
    content: "This post contains some controversial opinions that have been reported...",
    createdDate: "2024-01-15",
    status: "reported",
    category: "Opinion",
    likes: 15,
    comments: 25,
    reports: 5,
  },
  {
    id: "4",
    title: "Draft: Upcoming Features",
    author: "sarah_connor",
    authorEmail: "sarah.connor@example.com",
    content: "This is a draft post about upcoming features...",
    createdDate: "2024-01-22",
    status: "draft",
    category: "News",
    likes: 0,
    comments: 0,
    reports: 0,
  },
  {
    id: "5",
    title: "Photography Tips for Beginners",
    author: "alex_brown",
    authorEmail: "alex.brown@example.com",
    content: "Learn the basics of photography with these essential tips...",
    createdDate: "2024-01-19",
    status: "published",
    category: "Photography",
    likes: 67,
    comments: 18,
    reports: 0,
  },
]

export default function ContentPage() {
  const [posts, setPosts] = useState<Post[]>(mockPosts)
  const [searchTerm, setSearchTerm] = useState("")
  const [statusFilter, setStatusFilter] = useState<string>("all")
  const [categoryFilter, setCategoryFilter] = useState<string>("all")
  const [selectedPost, setSelectedPost] = useState<Post | null>(null)
  const [isViewDialogOpen, setIsViewDialogOpen] = useState(false)
  const [isDeleteDialogOpen, setIsDeleteDialogOpen] = useState(false)
  const { toast } = useToast()

  const filteredPosts = posts.filter((post) => {
    const matchesSearch =
      post.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
      post.author.toLowerCase().includes(searchTerm.toLowerCase())
    const matchesStatus = statusFilter === "all" || post.status === statusFilter
    const matchesCategory = categoryFilter === "all" || post.category === categoryFilter
    return matchesSearch && matchesStatus && matchesCategory
  })

  const handleApprovePost = (postId: string) => {
    setPosts(posts.map((post) => (post.id === postId ? { ...post, status: "published" as const, reports: 0 } : post)))
    toast({
      title: "Post Approved",
      description: "Post has been approved and is now published.",
    })
  }

  const handleRemovePost = (postId: string) => {
    setPosts(posts.map((post) => (post.id === postId ? { ...post, status: "removed" as const } : post)))
    toast({
      title: "Post Removed",
      description: "Post has been removed due to policy violations.",
      variant: "destructive",
    })
  }

  const handleDeletePost = () => {
    if (selectedPost) {
      setPosts(posts.filter((post) => post.id !== selectedPost.id))
      setIsDeleteDialogOpen(false)
      toast({
        title: "Post Deleted",
        description: "Post has been permanently deleted.",
        variant: "destructive",
      })
    }
  }

  const getStatusBadge = (status: string) => {
    switch (status) {
      case "published":
        return <Badge className="bg-green-100 text-green-800 hover:bg-green-100">Published</Badge>
      case "draft":
        return <Badge className="bg-gray-100 text-gray-800 hover:bg-gray-100">Draft</Badge>
      case "reported":
        return <Badge className="bg-red-100 text-red-800 hover:bg-red-100">Reported</Badge>
      case "removed":
        return <Badge className="bg-red-100 text-red-800 hover:bg-red-100">Removed</Badge>
      default:
        return <Badge variant="outline">{status}</Badge>
    }
  }

  const categories = ["all", ...Array.from(new Set(posts.map((post) => post.category)))]

  return (
    <SidebarInset>
      <header className="flex h-16 shrink-0 items-center gap-2 border-b px-4">
        <SidebarTrigger className="-ml-1" />
        <Separator orientation="vertical" className="mr-2 h-4" />
        <h1 className="text-lg font-semibold">Content Management</h1>
      </header>

      <div className="flex-1 space-y-4 p-4 md:p-8 pt-6">
        <Card>
          <CardHeader>
            <CardTitle>Content Management</CardTitle>
            <CardDescription>Manage posts, reviews, and content moderation</CardDescription>
          </CardHeader>
          <CardContent>
            {/* Filters */}
            <div className="flex flex-col sm:flex-row gap-4 mb-6">
              <div className="relative flex-1">
                <Search className="absolute left-2 top-2.5 h-4 w-4 text-muted-foreground" />
                <Input
                  placeholder="Search posts..."
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                  className="pl-8"
                />
              </div>
              <Select value={statusFilter} onValueChange={setStatusFilter}>
                <SelectTrigger className="w-[150px]">
                  <Filter className="h-4 w-4 mr-2" />
                  <SelectValue placeholder="Status" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all">All Status</SelectItem>
                  <SelectItem value="published">Published</SelectItem>
                  <SelectItem value="draft">Draft</SelectItem>
                  <SelectItem value="reported">Reported</SelectItem>
                  <SelectItem value="removed">Removed</SelectItem>
                </SelectContent>
              </Select>
              <Select value={categoryFilter} onValueChange={setCategoryFilter}>
                <SelectTrigger className="w-[150px]">
                  <SelectValue placeholder="Category" />
                </SelectTrigger>
                <SelectContent>
                  {categories.map((category) => (
                    <SelectItem key={category} value={category}>
                      {category === "all" ? "All Categories" : category}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>

            {/* Posts Table */}
            <div className="rounded-md border">
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Post</TableHead>
                    <TableHead>Author</TableHead>
                    <TableHead>Category</TableHead>
                    <TableHead>Date</TableHead>
                    <TableHead>Status</TableHead>
                    <TableHead>Engagement</TableHead>
                    <TableHead>Actions</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {filteredPosts.map((post) => (
                    <TableRow key={post.id}>
                      <TableCell>
                        <div>
                          <p className="font-medium">{post.title}</p>
                          <p className="text-sm text-muted-foreground truncate max-w-xs">{post.content}</p>
                        </div>
                      </TableCell>
                      <TableCell>
                        <div className="flex items-center space-x-2">
                          <Avatar className="h-8 w-8">
                            <AvatarImage src="/placeholder.svg?height=32&width=32" />
                            <AvatarFallback>{post.author.charAt(0).toUpperCase()}</AvatarFallback>
                          </Avatar>
                          <div>
                            <p className="text-sm font-medium">{post.author}</p>
                            <p className="text-xs text-muted-foreground">{post.authorEmail}</p>
                          </div>
                        </div>
                      </TableCell>
                      <TableCell>
                        <Badge variant="outline">{post.category}</Badge>
                      </TableCell>
                      <TableCell>{new Date(post.createdDate).toLocaleDateString()}</TableCell>
                      <TableCell>{getStatusBadge(post.status)}</TableCell>
                      <TableCell>
                        <div className="flex items-center space-x-4 text-sm">
                          <span className="flex items-center">
                            <MessageSquare className="h-3 w-3 mr-1" />
                            {post.likes}
                          </span>
                          <span className="flex items-center">
                            <MessageSquare className="h-3 w-3 mr-1" />
                            {post.comments}
                          </span>
                          {post.reports > 0 && (
                            <span className="flex items-center text-red-600">
                              <Flag className="h-3 w-3 mr-1" />
                              {post.reports}
                            </span>
                          )}
                        </div>
                      </TableCell>
                      <TableCell>
                        <div className="flex items-center space-x-2">
                          <Button
                            variant="ghost"
                            size="sm"
                            onClick={() => {
                              setSelectedPost(post)
                              setIsViewDialogOpen(true)
                            }}
                          >
                            <Eye className="h-4 w-4" />
                          </Button>

                          {post.status === "reported" && (
                            <>
                              <Button
                                variant="ghost"
                                size="sm"
                                onClick={() => handleApprovePost(post.id)}
                                className="text-green-600 hover:text-green-700"
                              >
                                <CheckCircle className="h-4 w-4" />
                              </Button>
                              <Button
                                variant="ghost"
                                size="sm"
                                onClick={() => handleRemovePost(post.id)}
                                className="text-red-600 hover:text-red-700"
                              >
                                <XCircle className="h-4 w-4" />
                              </Button>
                            </>
                          )}

                          <Button
                            variant="ghost"
                            size="sm"
                            onClick={() => {
                              setSelectedPost(post)
                              setIsDeleteDialogOpen(true)
                            }}
                            className="text-red-600 hover:text-red-700"
                          >
                            <Trash2 className="h-4 w-4" />
                          </Button>
                        </div>
                      </TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            </div>
          </CardContent>
        </Card>

        {/* View Post Dialog */}
        <Dialog open={isViewDialogOpen} onOpenChange={setIsViewDialogOpen}>
          <DialogContent className="max-w-2xl">
            <DialogHeader>
              <DialogTitle>Post Details</DialogTitle>
              <DialogDescription>View full post content and details</DialogDescription>
            </DialogHeader>
            {selectedPost && (
              <div className="space-y-4">
                <div>
                  <h3 className="text-lg font-semibold">{selectedPost.title}</h3>
                  <div className="flex items-center space-x-4 text-sm text-muted-foreground mt-2">
                    <span>By {selectedPost.author}</span>
                    <span>{new Date(selectedPost.createdDate).toLocaleDateString()}</span>
                    <Badge variant="outline">{selectedPost.category}</Badge>
                    {getStatusBadge(selectedPost.status)}
                  </div>
                </div>
                <Separator />
                <div>
                  <p className="text-sm leading-relaxed">{selectedPost.content}</p>
                </div>
                <Separator />
                <div className="flex items-center justify-between text-sm">
                  <div className="flex items-center space-x-4">
                    <span>{selectedPost.likes} likes</span>
                    <span>{selectedPost.comments} comments</span>
                    {selectedPost.reports > 0 && <span className="text-red-600">{selectedPost.reports} reports</span>}
                  </div>
                </div>
              </div>
            )}
          </DialogContent>
        </Dialog>

        {/* Delete Post Dialog */}
        <Dialog open={isDeleteDialogOpen} onOpenChange={setIsDeleteDialogOpen}>
          <DialogContent>
            <DialogHeader>
              <DialogTitle>Delete Post</DialogTitle>
              <DialogDescription>
                Are you sure you want to permanently delete this post? This action cannot be undone.
              </DialogDescription>
            </DialogHeader>
            <DialogFooter>
              <Button variant="outline" onClick={() => setIsDeleteDialogOpen(false)}>
                Cancel
              </Button>
              <Button variant="destructive" onClick={handleDeletePost}>
                Delete Post
              </Button>
            </DialogFooter>
          </DialogContent>
        </Dialog>
      </div>
    </SidebarInset>
  )
}
