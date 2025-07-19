"use client";

import { useState, useEffect } from 'react'
import { useRouter } from 'next/navigation'
import { 
  ArrowLeft, Edit, Users, Settings, Activity, 
  MoreVertical, Trash2, Loader2, MessageSquare,
  Mail, UserPlus, Shield, UserX, Check, X
} from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar'
import { toast } from 'sonner'
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger
} from '@/components/ui/dropdown-menu'
import { Switch } from '@/components/ui/switch'
import { Label } from '@/components/ui/label'
import { Input } from '@/components/ui/input'
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle } from '@/components/ui/dialog'

type Group = {
  id: string
  name: string
  description: string
  type: 'public' | 'private'
  isActive: boolean
  memberCount: number
  avatar?: string
  settings: {
    sendMessages: boolean
    sendMedia: boolean
    sendPolls: boolean
  }
  createdAt: string
  updatedAt: string
}

type Member = {
  id: string
  name: string
  email: string
  avatar?: string
  role: 'member' | 'admin'
  joinedAt: string
  lastSeen?: string
}

type Activity = {
  id: string
  type: string
  user: {
    id: string
    name: string
    avatar?: string
  }
  timestamp: string
  message?: string
}

export default function GroupDetailPage({ params }: { params: { groupId: string } }) {
  const router = useRouter()
  const [group, setGroup] = useState<Group | null>(null)
  const [members, setMembers] = useState<Member[]>([])
  const [activities, setActivities] = useState<Activity[]>([])
  const [loading, setLoading] = useState({
    group: true,
    members: true,
    activities: true
  })
  const [deleting, setDeleting] = useState(false)
  const [showDeleteDialog, setShowDeleteDialog] = useState(false)
  const [updating, setUpdating] = useState(false)

  useEffect(() => {
    fetchGroupData()
  }, [params.groupId])

  const fetchGroupData = async () => {
    try {
      setLoading({
        group: true,
        members: true,
        activities: true
      })

      // Fetch group details
      const groupRes = await fetch(`/api/groups/${params.groupId}`)
      const groupData = await groupRes.json()
      setGroup(groupData)

      // Fetch members
      const membersRes = await fetch(`/api/groups/${params.groupId}/members`)
      const membersData = await membersRes.json()
      setMembers(membersData)

      // Fetch activities
      const activitiesRes = await fetch(`/api/groups/${params.groupId}/activities`)
      const activitiesData = await activitiesRes.json()
      setActivities(activitiesData)
    } catch (error) {
      toast.error('Failed to load group data')
      console.error(error)
    } finally {
      setLoading({
        group: false,
        members: false,
        activities: false
      })
    }
  }

  const updateGroupSettings = async (settings: Partial<Group['settings']>) => {
    if (!group) return

    try {
      setUpdating(true)
      const response = await fetch(`/api/groups/${group.id}/settings`, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(settings)
      })

      if (!response.ok) throw new Error('Failed to update settings')

      const updatedSettings = await response.json()
      setGroup({ ...group, settings: updatedSettings })
      toast.success('Group settings updated')
    } catch (error) {
      toast.error('Failed to update settings')
      console.error(error)
    } finally {
      setUpdating(false)
    }
  }

  const updateMemberRole = async (memberId: string, newRole: 'member' | 'admin') => {
    try {
      const response = await fetch(`/api/groups/${params.groupId}/members/${memberId}/role`, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({ role: newRole })
      })

      if (!response.ok) throw new Error('Failed to update role')

      setMembers(members.map(member => 
        member.id === memberId ? { ...member, role: newRole } : member
      ))
      toast.success(`Member role updated to ${newRole}`)
    } catch (error) {
      toast.error('Failed to update role')
      console.error(error)
    }
  }

  const removeMember = async (memberId: string) => {
    try {
      const response = await fetch(`/api/groups/${params.groupId}/members/${memberId}`, {
        method: 'DELETE'
      })

      if (!response.ok) throw new Error('Failed to remove member')

      setMembers(members.filter(member => member.id !== memberId))
      toast.success('Member removed from group')
    } catch (error) {
      toast.error('Failed to remove member')
      console.error(error)
    }
  }

  const handleDeleteGroup = async () => {
    try {
      setDeleting(true)
      const response = await fetch(`/api/groups/${params.groupId}`, {
        method: 'DELETE'
      })

      if (!response.ok) throw new Error('Failed to delete group')

      toast.success('Group deleted successfully')
      router.push('/dashboard/groups')
    } catch (error) {
      toast.error('Failed to delete group')
      console.error(error)
    } finally {
      setDeleting(false)
      setShowDeleteDialog(false)
    }
  }

  if (loading.group) {
    return (
      <div className="flex items-center justify-center h-64">
        <Loader2 className="h-8 w-8 animate-spin" />
      </div>
    )
  }

  if (!group) {
    return (
      <div className="text-center py-12">
        <p>Group not found</p>
        <Button className="mt-4" onClick={() => router.push('/dashboard/groups')}>
          Back to Groups
        </Button>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center gap-4">
        <Button variant="outline" size="icon" onClick={() => router.back()}>
          <ArrowLeft className="h-4 w-4" />
        </Button>
        <div className="flex items-center gap-3">
          <Avatar className="h-10 w-10">
            <AvatarImage src={group.avatar} />
            <AvatarFallback>{group.name.charAt(0)}</AvatarFallback>
          </Avatar>
          <div>
            <h1 className="text-2xl font-bold">{group.name}</h1>
            <div className="flex items-center gap-2">
              <Badge variant={group.isActive ? 'default' : 'destructive'}>
                {group.isActive ? 'Active' : 'Inactive'}
              </Badge>
              <Badge variant={group.type === 'public' ? 'default' : 'secondary'}>
                {group.type}
              </Badge>
            </div>
          </div>
        </div>
        <div className="ml-auto flex gap-2">
          <Button asChild variant="outline">
            <Link href={`/dashboard/groups/${group.id}/edit`}>
              <Edit className="mr-2 h-4 w-4" />
              Edit
            </Link>
          </Button>
          <Button 
            variant="destructive" 
            onClick={() => setShowDeleteDialog(true)}
            disabled={deleting}
          >
            {deleting ? (
              <Loader2 className="mr-2 h-4 w-4 animate-spin" />
            ) : (
              <Trash2 className="mr-2 h-4 w-4" />
            )}
            Delete
          </Button>
        </div>
      </div>

      <Tabs defaultValue="overview">
        <TabsList>
          <TabsTrigger value="overview">Overview</TabsTrigger>
          <TabsTrigger value="members">
            <Users className="mr-2 h-4 w-4" />
            Members
          </TabsTrigger>
          <TabsTrigger value="settings">
            <Settings className="mr-2 h-4 w-4" />
            Settings
          </TabsTrigger>
          <TabsTrigger value="activity">
            <Activity className="mr-2 h-4 w-4" />
            Activity
          </TabsTrigger>
        </TabsList>

        <TabsContent value="overview" className="space-y-6">
          <Card>
            <CardHeader>
              <CardTitle>Group Information</CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              {group.description && (
                <div>
                  <Label>Description</Label>
                  <p className="text-muted-foreground">{group.description}</p>
                </div>
              )}
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <Label>Created</Label>
                  <p>{new Date(group.createdAt).toLocaleDateString()}</p>
                </div>
                <div>
                  <Label>Last Updated</Label>
                  <p>{new Date(group.updatedAt).toLocaleDateString()}</p>
                </div>
                <div>
                  <Label>Members</Label>
                  <div className="flex items-center gap-2">
                    <Users className="h-4 w-4" />
                    <span>{group.memberCount}</span>
                  </div>
                </div>
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle>Quick Actions</CardTitle>
            </CardHeader>
            <CardContent className="grid grid-cols-3 gap-4">
              <Button variant="outline">
                <Mail className="mr-2 h-4 w-4" />
                Send Announcement
              </Button>
              <Button variant="outline">
                <MessageSquare className="mr-2 h-4 w-4" />
                View Chat
              </Button>
              <Button variant="outline">
                <UserPlus className="mr-2 h-4 w-4" />
                Invite Members
              </Button>
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="members">
          <Card>
            <CardHeader>
              <CardTitle>Group Members</CardTitle>
              <CardDescription>
                {members.length} members in this group
              </CardDescription>
            </CardHeader>
            <CardContent>
              {loading.members ? (
                <div className="flex items-center justify-center h-32">
                  <Loader2 className="h-8 w-8 animate-spin" />
                </div>
              ) : members.length === 0 ? (
                <div className="text-center py-12">
                  <p className="text-muted-foreground">No members found</p>
                </div>
              ) : (
                <div className="space-y-4">
                  {members.map((member) => (
                    <div key={member.id} className="flex items-center justify-between p-4 border rounded-lg">
                      <div className="flex items-center gap-3">
                        <Avatar>
                          <AvatarImage src={member.avatar} />
                          <AvatarFallback>{member.name.charAt(0)}</AvatarFallback>
                        </Avatar>
                        <div>
                          <p className="font-medium">{member.name}</p>
                          <p className="text-sm text-muted-foreground">{member.email}</p>
                        </div>
                      </div>
                      <div className="flex items-center gap-2">
                        <Badge variant={member.role === 'admin' ? 'default' : 'secondary'}>
                          {member.role}
                        </Badge>
                        <DropdownMenu>
                          <DropdownMenuTrigger asChild>
                            <Button variant="ghost" size="icon">
                              <MoreVertical className="h-4 w-4" />
                            </Button>
                          </DropdownMenuTrigger>
                          <DropdownMenuContent align="end">
                            <DropdownMenuItem
                              onClick={() => updateMemberRole(
                                member.id, 
                                member.role === 'admin' ? 'member' : 'admin'
                              )}
                            >
                              {member.role === 'admin' ? (
                                <>
                                  <UserX className="mr-2 h-4 w-4" />
                                  Demote to Member
                                </>
                              ) : (
                                <>
                                  <Shield className="mr-2 h-4 w-4" />
                                  Promote to Admin
                                </>
                              )}
                            </DropdownMenuItem>
                            <DropdownMenuItem
                              className="text-red-600"
                              onClick={() => removeMember(member.id)}
                            >
                              <Trash2 className="mr-2 h-4 w-4" />
                              Remove
                            </DropdownMenuItem>
                          </DropdownMenuContent>
                        </DropdownMenu>
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="settings">
          <Card>
            <CardHeader>
              <CardTitle>Group Settings</CardTitle>
              <CardDescription>
                Configure how members interact with this group
              </CardDescription>
            </CardHeader>
            <CardContent className="space-y-6">
              <div className="flex items-center justify-between rounded-lg border p-4">
                <div className="space-y-0.5">
                  <Label>Allow members to post messages</Label>
                  <p className="text-sm text-muted-foreground">
                    When disabled, only admins can send messages
                  </p>
                </div>
                <Switch
                  checked={group.settings.sendMessages}
                  onCheckedChange={(value) => updateGroupSettings({ sendMessages: value })}
                  disabled={updating}
                />
              </div>
              <div className="flex items-center justify-between rounded-lg border p-4">
                <div className="space-y-0.5">
                  <Label>Allow media sharing</Label>
                  <p className="text-sm text-muted-foreground">
                    Members can share images, videos and files
                  </p>
                </div>
                <Switch
                  checked={group.settings.sendMedia}
                  onCheckedChange={(value) => updateGroupSettings({ sendMedia: value })}
                  disabled={updating}
                />
              </div>
              <div className="flex items-center justify-between rounded-lg border p-4">
                <div className="space-y-0.5">
                  <Label>Allow polls</Label>
                  <p className="text-sm text-muted-foreground">
                    Members can create polls in the group
                  </p>
                </div>
                <Switch
                  checked={group.settings.sendPolls}
                  onCheckedChange={(value) => updateGroupSettings({ sendPolls: value })}
                  disabled={updating}
                />
              </div>
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="activity">
          <Card>
            <CardHeader>
              <CardTitle>Recent Activity</CardTitle>
              <CardDescription>
                {activities.length} activities in the last 30 days
              </CardDescription>
            </CardHeader>
            <CardContent>
              {loading.activities ? (
                <div className="flex items-center justify-center h-32">
                  <Loader2 className="h-8 w-8 animate-spin" />
                </div>
              ) : activities.length === 0 ? (
                <div className="text-center py-12">
                  <p className="text-muted-foreground">No recent activity</p>
                </div>
              ) : (
                <div className="space-y-4">
                  {activities.map((activity) => (
                    <div key={activity.id} className="flex items-start gap-3 p-4 border rounded-lg">
                      <Avatar>
                        <AvatarImage src={activity.user.avatar} />
                        <AvatarFallback>{activity.user.name.charAt(0)}</AvatarFallback>
                      </Avatar>
                      <div className="flex-1">
                        <div className="flex items-center gap-2">
                          <p className="font-medium">{activity.user.name}</p>
                          <span className="text-sm text-muted-foreground">
                            {new Date(activity.timestamp).toLocaleString()}
                          </span>
                        </div>
                        {activity.type === 'message' && (
                          <p className="text-sm">Posted a message: "{activity.message}"</p>
                        )}
                        {activity.type === 'join' && (
                          <p className="text-sm">Joined the group</p>
                        )}
                        {activity.type === 'leave' && (
                          <p className="text-sm">Left the group</p>
                        )}
                        {activity.type === 'role_change' && (
                          <p className="text-sm">Role updated</p>
                        )}
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>

      <Dialog open={showDeleteDialog} onOpenChange={setShowDeleteDialog}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Delete this group?</DialogTitle>
            <DialogDescription>
              This action cannot be undone. All group data including messages and member associations will be permanently removed.
            </DialogDescription>
          </DialogHeader>
          <DialogFooter>
            <Button variant="outline" onClick={() => setShowDeleteDialog(false)}>
              Cancel
            </Button>
            <Button variant="destructive" onClick={handleDeleteGroup} disabled={deleting}>
              {deleting ? (
                <Loader2 className="mr-2 h-4 w-4 animate-spin" />
              ) : (
                <Trash2 className="mr-2 h-4 w-4" />
              )}
              Delete Group
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  )
}


