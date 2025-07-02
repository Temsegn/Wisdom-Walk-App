"use client"

import { useState } from "react"
import { X, Search } from "lucide-react"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Textarea } from "@/components/ui/textarea"
import { Badge } from "@/components/ui/badge"
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter } from "@/components/ui/dialog"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"

interface User {
  _id: string
  name: string
  avatar?: string
  role: string
}

interface SendNotificationDialogProps {
  isOpen: boolean
  onClose: () => void
  onSend: (notification: any) => void
  users: User[]
}

export function SendNotificationDialog({ isOpen, onClose, onSend, users }: SendNotificationDialogProps) {
  const [form, setForm] = useState({
    title: "",
    message: "",
    type: "user",
    recipientType: "all", // all | admins | members | specific
    specificUsers: [] as User[],
    searchQuery: "",
  })

  const handleSubmit = () => {
    if (!form.title || !form.message) return

    if (form.recipientType === "specific" && form.specificUsers.length === 0) {
      return
    }

    onSend({
      title: form.title,
      message: form.message,
      type: form.type,
      recipients: form.recipientType === "specific" ? form.specificUsers.map((u) => u._id) : form.recipientType,
    })

    // Reset form
    setForm({
      title: "",
      message: "",
      type: "user",
      recipientType: "all",
      specificUsers: [],
      searchQuery: "",
    })
  }

  const addUser = (user: User) => {
    if (!form.specificUsers.some((u) => u._id === user._id)) {
      setForm((prev) => ({
        ...prev,
        specificUsers: [...prev.specificUsers, user],
        searchQuery: "", // Clear search after adding
      }))
    }
  }

  const removeUser = (userId: string) => {
    setForm((prev) => ({
      ...prev,
      specificUsers: prev.specificUsers.filter((u) => u._id !== userId),
    }))
  }

  const filteredUsers = users.filter((user) => !form.specificUsers.some((u) => u._id === user._id))

  return (
    <Dialog open={isOpen} onOpenChange={onClose}>
      <DialogContent className="sm:max-w-[500px]">
        <DialogHeader>
          <DialogTitle>Send Notification</DialogTitle>
        </DialogHeader>

        <div className="grid gap-4 py-4">
          <div className="grid gap-2">
            <Select value={form.type} onValueChange={(value) => setForm((prev) => ({ ...prev, type: value }))}>
              <SelectTrigger>
                <SelectValue placeholder="Select notification type" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="user">User Action</SelectItem>
                <SelectItem value="signup">New User</SelectItem>
                <SelectItem value="report">Report</SelectItem>
                <SelectItem value="post">Post</SelectItem>
              </SelectContent>
            </Select>
          </div>

          <div className="grid gap-2">
            <Input
              placeholder="Notification Title"
              value={form.title}
              onChange={(e) => setForm((prev) => ({ ...prev, title: e.target.value }))}
            />
          </div>

          <div className="grid gap-2">
            <Textarea
              placeholder="Notification Message"
              value={form.message}
              onChange={(e) => setForm((prev) => ({ ...prev, message: e.target.value }))}
              rows={4}
            />
          </div>

          <div className="grid gap-2">
            <Select
              value={form.recipientType}
              onValueChange={(value) => setForm((prev) => ({ ...prev, recipientType: value }))}
            >
              <SelectTrigger>
                <SelectValue placeholder="Select recipients" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">All Users</SelectItem>
                <SelectItem value="admins">Admins Only</SelectItem>
                <SelectItem value="members">Members Only</SelectItem>
                <SelectItem value="specific">Specific Users</SelectItem>
              </SelectContent>
            </Select>
          </div>

          {form.recipientType === "specific" && (
            <div className="grid gap-2">
              <div className="flex flex-col space-y-2">
                <label className="text-sm font-medium">Search and select users</label>
                <div className="relative">
                  <Search className="absolute left-2 top-2.5 h-4 w-4 text-muted-foreground" />
                  <Input
                    placeholder="Search by name or role..."
                    className="pl-8"
                    value={form.searchQuery || ""}
                    onChange={(e) => {
                      const query = e.target.value
                      setForm((prev) => ({ ...prev, searchQuery: query }))
                    }}
                  />
                </div>
              </div>

              {form.searchQuery && form.searchQuery.length > 1 && (
                <div className="border rounded-md max-h-[200px] overflow-y-auto">
                  {filteredUsers
                    .filter(
                      (user) =>
                        user.name.toLowerCase().includes(form.searchQuery?.toLowerCase() || "") ||
                        user.role.toLowerCase().includes(form.searchQuery?.toLowerCase() || ""),
                    )
                    .map((user) => (
                      <div
                        key={user._id}
                        className="flex items-center justify-between p-2 hover:bg-muted cursor-pointer"
                        onClick={() => addUser(user)}
                      >
                        <div className="flex items-center gap-2">
                          <Avatar className="h-8 w-8">
                            <AvatarImage src={user.avatar || "/placeholder.svg"} alt={user.name} />
                            <AvatarFallback>{user.name.charAt(0)}</AvatarFallback>
                          </Avatar>
                          <div>
                            <p className="text-sm font-medium">{user.name}</p>
                            <p className="text-xs text-muted-foreground capitalize">{user.role}</p>
                          </div>
                        </div>
                        <Badge variant="outline" className="ml-auto">
                          Add
                        </Badge>
                      </div>
                    ))}
                  {filteredUsers.filter(
                    (user) =>
                      user.name.toLowerCase().includes(form.searchQuery?.toLowerCase() || "") ||
                      user.role.toLowerCase().includes(form.searchQuery?.toLowerCase() || ""),
                  ).length === 0 && <div className="p-2 text-center text-sm text-muted-foreground">No users found</div>}
                </div>
              )}

              {form.specificUsers.length > 0 && (
                <div className="flex flex-wrap gap-2 mt-2">
                  {form.specificUsers.map((user) => (
                    <Badge key={user._id} variant="secondary" className="flex items-center gap-1">
                      {user.name}
                      <Button
                        variant="ghost"
                        size="sm"
                        className="h-4 w-4 p-0 ml-1"
                        onClick={() => removeUser(user._id)}
                      >
                        <X className="h-3 w-3" />
                      </Button>
                    </Badge>
                  ))}
                </div>
              )}
            </div>
          )}
        </div>

        <DialogFooter>
          <Button variant="outline" onClick={onClose}>
            Cancel
          </Button>
          <Button
            onClick={handleSubmit}
            disabled={
              !form.title || !form.message || (form.recipientType === "specific" && form.specificUsers.length === 0)
            }
          >
            Send Notification
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  )
}
