"use client"

import { useEffect, useState } from "react"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { Textarea } from "@/components/ui/textarea"
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { AlertTriangle, Eye, CheckCircle, XCircle, Clock, User, FileText, MessageSquare } from "lucide-react"
import { useToast } from "@/hooks/use-toast"

interface Report {
  _id: string
  reporter: {
    firstName: string
    lastName: string
    email: string
    profilePicture?: string
  }
  reportedUser?: {
    firstName: string
    lastName: string
    email: string
    profilePicture?: string
  }
  reportedPost?: {
    title?: string
    content: string
    author: {
      firstName: string
      lastName: string
    }
  }
  reportedComment?: {
    content: string
    author: {
      firstName: string
      lastName: string
    }
  }
  type: string
  reason: string
  status: string
  contentPreview?: string
  contentType?: string
  urgency?: string
  createdAt: string
}

export default function ReportsPage() {
  const [reports, setReports] = useState<Report[]>([])
  const [loading, setLoading] = useState(true)
  const [selectedReport, setSelectedReport] = useState<Report | null>(null)
  const [actionNotes, setActionNotes] = useState("")
  const [selectedAction, setSelectedAction] = useState("")
  const { toast } = useToast()

  useEffect(() => {
    fetchReports()
  }, [])

  const fetchReports = async () => {
    try {
      const token = localStorage.getItem("adminToken")
      const response = await fetch("/api/admin/reports", {
        headers: {
          Authorization: `Bearer ${token}`,
        },
      })

      if (response.ok) {
        const data = await response.json()
        setReports(data.data)
      }
    } catch (error) {
      console.error("Error fetching reports:", error)
      toast({
        title: "Error",
        description: "Failed to fetch reports",
        variant: "destructive",
      })
    } finally {
      setLoading(false)
    }
  }

  const handleReportAction = async (reportId: string, action: string, notes: string) => {
    try {
      const token = localStorage.getItem("adminToken")
      const response = await fetch(`/api/admin/reports/${reportId}/handle`, {
        method: "POST",
        headers: {
          Authorization: `Bearer ${token}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ action, adminNotes: notes }),
      })

      if (response.ok) {
        toast({
          title: "Success",
          description: "Report handled successfully",
        })
        fetchReports()
        setSelectedReport(null)
        setActionNotes("")
        setSelectedAction("")
      }
    } catch (error) {
      console.error("Error handling report:", error)
      toast({
        title: "Error",
        description: "Failed to handle report",
        variant: "destructive",
      })
    }
  }

  const getStatusBadge = (status: string) => {
    switch (status) {
      case "pending":
        return (
          <Badge variant="outline" className="text-orange-600">
            <Clock className="h-3 w-3 mr-1" />
            Pending
          </Badge>
        )
      case "investigating":
        return (
          <Badge variant="outline" className="text-blue-600">
            <Eye className="h-3 w-3 mr-1" />
            Investigating
          </Badge>
        )
      case "resolved":
        return (
          <Badge variant="default" className="bg-green-100 text-green-800">
            <CheckCircle className="h-3 w-3 mr-1" />
            Resolved
          </Badge>
        )
      case "dismissed":
        return (
          <Badge variant="secondary">
            <XCircle className="h-3 w-3 mr-1" />
            Dismissed
          </Badge>
        )
      default:
        return <Badge variant="secondary">{status}</Badge>
    }
  }

  const getContentTypeIcon = (contentType: string) => {
    switch (contentType) {
      case "post":
        return <FileText className="h-4 w-4" />
      case "comment":
        return <MessageSquare className="h-4 w-4" />
      case "user":
        return <User className="h-4 w-4" />
      default:
        return <AlertTriangle className="h-4 w-4" />
    }
  }

  if (loading) {
    return (
      <div className="space-y-6">
        <div className="h-8 bg-gray-200 rounded w-48 animate-pulse"></div>
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
      <div>
        <h1 className="text-3xl font-bold tracking-tight">Reports Management</h1>
        <p className="text-muted-foreground">
          Review and handle community reports for inappropriate content and behavior.
        </p>
      </div>

      {reports.length === 0 ? (
        <Card>
          <CardContent className="flex flex-col items-center justify-center py-12">
            <CheckCircle className="h-12 w-12 text-green-600 mb-4" />
            <h3 className="text-lg font-semibold mb-2">No reports to review</h3>
            <p className="text-muted-foreground text-center">
              All reports have been handled. Great job keeping the community safe!
            </p>
          </CardContent>
        </Card>
      ) : (
        <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
          {reports.map((report) => (
            <Card key={report._id} className="overflow-hidden">
              <CardHeader className="pb-4">
                <div className="flex items-start justify-between">
                  <div className="flex items-center space-x-2">
                    {getContentTypeIcon(report.contentType || "post")}
                    <CardTitle className="text-lg capitalize">{report.type.replace("_", " ")}</CardTitle>
                  </div>
                </div>
                <CardDescription className="flex items-center gap-2">
                  {getStatusBadge(report.status)}
                  <span>•</span>
                  <span>{new Date(report.createdAt).toLocaleDateString()}</span>
                </CardDescription>
              </CardHeader>
              <CardContent className="space-y-4">
                {/* Reporter Info */}
                <div className="flex items-center space-x-2">
                  <Avatar className="h-6 w-6">
                    <AvatarImage src={report.reporter.profilePicture || "/placeholder.svg"} />
                    <AvatarFallback className="text-xs">
                      {report.reporter.firstName[0]}
                      {report.reporter.lastName[0]}
                    </AvatarFallback>
                  </Avatar>
                  <span className="text-sm text-muted-foreground">
                    Reported by {report.reporter.firstName} {report.reporter.lastName}
                  </span>
                </div>

                {/* Content Preview */}
                <div className="space-y-2">
                  <h4 className="font-medium text-sm">Content:</h4>
                  <p className="text-sm text-gray-700 line-clamp-3">{report.contentPreview || report.reason}</p>
                </div>

                {/* Reason */}
                <div className="space-y-2">
                  <h4 className="font-medium text-sm">Reason:</h4>
                  <p className="text-sm text-gray-600 line-clamp-2">{report.reason}</p>
                </div>

                <Button
                  variant="outline"
                  size="sm"
                  onClick={() => setSelectedReport(report)}
                  className="w-full"
                  disabled={report.status === "resolved"}
                >
                  <Eye className="h-4 w-4 mr-2" />
                  {report.status === "resolved" ? "View Details" : "Review & Handle"}
                </Button>
              </CardContent>
            </Card>
          ))}
        </div>
      )}

      {/* Report Review Dialog */}
      <Dialog open={!!selectedReport} onOpenChange={() => setSelectedReport(null)}>
        <DialogContent className="max-w-2xl max-h-[90vh] overflow-y-auto">
          <DialogHeader>
            <DialogTitle>Review Report</DialogTitle>
            <DialogDescription>Review the details and take appropriate action on this report.</DialogDescription>
          </DialogHeader>

          {selectedReport && (
            <div className="space-y-6">
              {/* Report Details */}
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <h4 className="font-semibold mb-2">Report Information</h4>
                  <div className="space-y-2 text-sm">
                    <div>
                      <strong>Type:</strong> {selectedReport.type.replace("_", " ")}
                    </div>
                    <div>
                      <strong>Status:</strong> {getStatusBadge(selectedReport.status)}
                    </div>
                    <div>
                      <strong>Submitted:</strong> {new Date(selectedReport.createdAt).toLocaleDateString()}
                    </div>
                    <div>
                      <strong>Content Type:</strong> {selectedReport.contentType}
                    </div>
                  </div>
                </div>
                <div>
                  <h4 className="font-semibold mb-2">Reporter</h4>
                  <div className="flex items-center space-x-2">
                    <Avatar className="h-8 w-8">
                      <AvatarImage src={selectedReport.reporter.profilePicture || "/placeholder.svg"} />
                      <AvatarFallback>
                        {selectedReport.reporter.firstName[0]}
                        {selectedReport.reporter.lastName[0]}
                      </AvatarFallback>
                    </Avatar>
                    <div>
                      <div className="font-medium">
                        {selectedReport.reporter.firstName} {selectedReport.reporter.lastName}
                      </div>
                      <div className="text-sm text-muted-foreground">{selectedReport.reporter.email}</div>
                    </div>
                  </div>
                </div>
              </div>

              {/* Report Reason */}
              <div className="space-y-2">
                <h4 className="font-semibold">Report Reason</h4>
                <p className="text-sm border rounded-lg p-3 bg-gray-50">{selectedReport.reason}</p>
              </div>

              {selectedReport.status === "pending" && (
                <>
                  {/* Action Selection */}
                  <div className="space-y-2">
                    <label className="block text-sm font-medium">Action to Take</label>
                    <Select value={selectedAction} onValueChange={setSelectedAction}>
                      <SelectTrigger>
                        <SelectValue placeholder="Select an action" />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="no_action">No Action Required</SelectItem>
                        <SelectItem value="warning_sent">Send Warning</SelectItem>
                        <SelectItem value="content_removed">Remove Content</SelectItem>
                        <SelectItem value="user_blocked">Block User</SelectItem>
                        <SelectItem value="user_banned">Ban User</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>

                  {/* Admin Notes */}
                  <div className="space-y-2">
                    <label className="block text-sm font-medium">Admin Notes</label>
                    <Textarea
                      placeholder="Add notes about your decision..."
                      value={actionNotes}
                      onChange={(e) => setActionNotes(e.target.value)}
                      rows={3}
                    />
                  </div>
                </>
              )}
            </div>
          )}

          <DialogFooter className="gap-2">
            <Button
              variant="outline"
              onClick={() => {
                setSelectedReport(null)
                setActionNotes("")
                setSelectedAction("")
              }}
            >
              {selectedReport?.status === "resolved" ? "Close" : "Cancel"}
            </Button>
            {selectedReport?.status === "pending" && (
              <Button
                onClick={() =>
                  selectedReport &&
                  selectedAction &&
                  handleReportAction(selectedReport._id, selectedAction, actionNotes)
                }
                disabled={!selectedAction}
              >
                <CheckCircle className="h-4 w-4 mr-2" />
                Handle Report
              </Button>
            )}
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  )
}
