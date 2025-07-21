"use client";

import * as React from 'react';
import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import {
  ArrowLeft, Edit, Users, Activity, MoreVertical, Trash2, Loader2, UserPlus, Shield, UserX
} from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { Card, CardHeader, CardTitle, CardDescription, CardContent } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar';
import { toast } from 'sonner';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger
} from '@/components/ui/dropdown-menu';
import { Switch } from '@/components/ui/switch';
import { Label } from '@/components/ui/label';
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle } from '@/components/ui/dialog';
import { Input } from '@/components/ui/input';
import { Textarea } from '@/components/ui/textarea';
import { Skeleton } from '@/components/ui/skeleton';

type Group = {
  id: string;
  name: string;
  description: string;
  type: 'public' | 'private';
  isActive: boolean;
  memberCount: number;
  avatar?: string;
  settings: {
    sendMessages: boolean;
    sendMedia: boolean;
    sendPolls: boolean;
    allowInvites: boolean;
  };
  createdAt: string;
  updatedAt: string;
};

type Member = {
  id: string;
  name: string;
  email: string;
  avatar?: string;
  role: 'member' | 'admin';
  joinedAt: string;
  lastSeen?: string;
};

type GroupActivity = {
  id: string;
  type: string;
  user: {
    id: string;
    name: string;
    avatar?: string;
  };
  timestamp: string;
  message?: string;
};

export default function GroupDetailPage({ params }: { params: Promise<{ id: string }> }) {
  const router = useRouter();
  const { id } = React.use(params);
  const [group, setGroup] = useState<Group | null>(null);
  const [members, setMembers] = useState<Member[]>([]);
  const [activities, setActivities] = useState<GroupActivity[]>([]);
  const [loading, setLoading] = useState({
    group: true,
    members: true,
    activities: true
  });
  const [error, setError] = useState<string | null>(null);
  const [deleting, setDeleting] = useState(false);
  const [showDeleteDialog, setShowDeleteDialog] = useState(false);
  const [updating, setUpdating] = useState(false);
  const [showInviteDialog, setShowInviteDialog] = useState(false);
  const [inviteEmail, setInviteEmail] = useState('');
  const [editGroup, setEditGroup] = useState({ name: '', description: '' });
  const [isMounted, setIsMounted] = useState(true);

  useEffect(() => {
    setIsMounted(true);
    if (!id || id === 'undefined') {
      setError('Invalid group ID');
      setLoading({ group: false, members: false, activities: false });
      router.push('/dashboard/groups');
      return;
    }
    fetchGroupData();
    return () => setIsMounted(false);
  }, [id, router]);
async function fetchGroupData() {
  try {
    setLoading({ group: true, members: true, activities: true });
    setError(null);

    const token = localStorage.getItem('adminToken');
    if (!token) {
      throw new Error('Authentication token missing - please login again');
    }

    const headers = {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${token}`
    };
    console.log('Fetching group data for ID:', id, 'with token:', token);

    const [groupRes, membersRes, activitiesRes] = await Promise.all([
      fetch(`/api/groups/${id}`, { headers }),
      fetch(`/api/groups/${id}/members`, { headers }).catch(() => ({ ok: false, status: 404, json: async () => ({ members: [] }) })),
      fetch(`/api/groups/${id}/activities`, { headers }).catch(() => ({ ok: false, status: 404, json: async () => ({ activities: [] }) }))
    ]);

    const [groupData, membersData, activitiesData] = await Promise.all([
      groupRes.json(),
      membersRes.json(),
      activitiesRes.json()
    ]);

    console.log('Group response:', groupData);
    console.log('Members response:', membersData);
    console.log('Activities response:', activitiesData);

    if (!groupRes.ok) {
      
      const errorMessage = groupData.message || `Failed to fetch group details (Status: ${groupRes.status})`;
      throw new Error(errorMessage);
    }

    setGroup({
      ...groupData.group,
      settings: {
        sendMessages: groupData.group?.settings?.sendMessages ?? true,
        sendMedia: groupData.group?.settings?.sendMedia ?? true,
        sendPolls: groupData.group?.settings?.sendPolls ?? true,
        allowInvites: groupData.group?.settings?.allowInvites ?? true
      }
    });
    setMembers(membersData.members || []);
    setActivities(activitiesData.activities || []);
    setEditGroup({ name: groupData.group.name, description: groupData.group.description || '' });
  } catch (error) {
    let errorMessage = 'Failed to load group data';
    if (error instanceof Error) {
      errorMessage = error.message;
      if (error.message.toLowerCase().includes('unauthorized') || error.message.includes('401')) {
        errorMessage = 'Session expired - please login again';
        localStorage.removeItem('adminToken');
        localStorage.removeItem('adminUser');
        router.push('/login');
        return;
      }
      if (error.message.toLowerCase().includes('validation')) {
        errorMessage = `Validation error: ${error.message.split(':').pop()?.trim()}`;
      }
    }
    console.error('Fetch error:', error);
    setError(errorMessage);
    toast.error(errorMessage, {
      action: {
        label: 'Retry',
        onClick: () => fetchGroupData()
      },
      duration: 10000
    });
  } finally {
    if (isMounted) {
      setLoading({ group: false, members: false, activities: false });
    }
  }
}

  async function updateGroupSettings(settings: Partial<Group['settings']>) {
    if (!group) return;

    try {
      setUpdating(true);
      const token = localStorage.getItem('adminToken');
      if (!token) {
        throw new Error('Authentication token missing - please login again');
      }

      console.log('Updating group settings:', settings);

      const response = await fetch(`/api/groups/${id}/settings`, {
        method: 'PATCH',
        headers: { 
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`
        },
        body: JSON.stringify(settings)
      });

      const data = await response.json();
      console.log('Settings update response:', data);

      if (!response.ok) {
        const errorMessage = data.message || `Failed to update settings (Status: ${response.status})`;
        throw new Error(errorMessage);
      }

      setGroup({ ...group, settings: data.settings });
      toast.success('Group settings updated');
    } catch (error) {
      let errorMessage = 'Failed to update settings';
      if (error instanceof Error) {
        errorMessage = error.message;
        if (error.message.toLowerCase().includes('unauthorized') || error.message.includes('401')) {
          errorMessage = 'Session expired - please login again';
          localStorage.removeItem('adminToken');
          localStorage.removeItem('adminUser');
          router.push('/login');
          return;
        }
        if (error.message.toLowerCase().includes('validation')) {
          errorMessage = `Validation error: ${error.message.split(':').pop()?.trim()}`;
        }
      }
      console.error('Settings update error:', error);
      toast.error(errorMessage, {
        action: {
          label: 'Retry',
          onClick: () => updateGroupSettings(settings)
        },
        duration: 10000
      });
    } finally {
      if (isMounted) {
        setUpdating(false);
      }
    }
  }

  async function updateGroupDetails() {
    if (!group) return;

    try {
      setUpdating(true);
      const token = localStorage.getItem('adminToken');
      if (!token) {
        throw new Error('Authentication token missing - please login again');
      }

      console.log('Updating group details:', editGroup);

      const response = await fetch(`/api/groups/${id}`, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`
        },
        body: JSON.stringify({
          name: editGroup.name.trim(),
          description: editGroup.description.trim()
        })
      });

      const data = await response.json();
      console.log('Group details update response:', data);

      if (!response.ok) {
        const errorMessage = data.message || `Failed to update group details (Status: ${response.status})`;
        throw new Error(errorMessage);
      }

      setGroup({ ...group, ...data.group });
      toast.success('Group details updated');
    } catch (error) {
      let errorMessage = 'Failed to update group details';
      if (error instanceof Error) {
        errorMessage = error.message;
        if (error.message.toLowerCase().includes('unauthorized') || error.message.includes('401')) {
          errorMessage = 'Session expired - please login again';
          localStorage.removeItem('adminToken');
          localStorage.removeItem('adminUser');
          router.push('/login');
          return;
        }
        if (error.message.toLowerCase().includes('validation')) {
          errorMessage = `Validation error: ${error.message.split(':').pop()?.trim()}`;
        }
      }
      console.error('Group details update error:', error);
      toast.error(errorMessage, {
        action: {
          label: 'Retry',
          onClick: () => updateGroupDetails()
        },
        duration: 10000
      });
    } finally {
      if (isMounted) {
        setUpdating(false);
      }
    }
  }

  async function updateMemberRole(memberId: string, newRole: 'member' | 'admin') {
    try {
      const token = localStorage.getItem('adminToken');
      if (!token) {
        throw new Error('Authentication token missing - please login again');
      }

      console.log('Updating member role:', { memberId, newRole });

      const response = await fetch(`/api/groups/${id}/members/${memberId}/role`, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`
        },
        body: JSON.stringify({ role: newRole })
      });

      const data = await response.json();
      console.log('Member role update response:', data);

      if (!response.ok) {
        const errorMessage = data.message || `Failed to update role (Status: ${response.status})`;
        throw new Error(errorMessage);
      }

      setMembers(members.map(member => 
        member.id === memberId ? { ...member, role: newRole } : member
      ));
      toast.success(`Member role updated to ${newRole}`);
    } catch (error) {
      let errorMessage = 'Failed to update role';
      if (error instanceof Error) {
        errorMessage = error.message;
        if (error.message.toLowerCase().includes('unauthorized') || error.message.includes('401')) {
          errorMessage = 'Session expired - please login again';
          localStorage.removeItem('adminToken');
          localStorage.removeItem('adminUser');
          router.push('/login');
          return;
        }
        if (error.message.toLowerCase().includes('validation')) {
          errorMessage = `Validation error: ${error.message.split(':').pop()?.trim()}`;
        }
      }
      console.error('Member role update error:', error);
      toast.error(errorMessage, {
        action: {
          label: 'Retry',
          onClick: () => updateMemberRole(memberId, newRole)
        },
        duration: 10000
      });
    }
  }

  async function removeMember(memberId: string) {
    try {
      const token = localStorage.getItem('adminToken');
      if (!token) {
        throw new Error('Authentication token missing - please login again');
      }

      console.log('Removing member:', memberId);

      const response = await fetch(`/api/groups/${id}/members/${memberId}`, {
        method: 'DELETE',
        headers: {
          'Authorization': `Bearer ${token}`
        }
      });

      const data = await response.json();
      console.log('Member remove response:', data);

      if (!response.ok) {
        const errorMessage = data.message || `Failed to remove member (Status: ${response.status})`;
        throw new Error(errorMessage);
      }

      setMembers(members.filter(member => member.id !== memberId));
      setGroup(group ? { ...group, memberCount: group.memberCount - 1 } : null);
      toast.success('Member removed from group');
    } catch (error) {
      let errorMessage = 'Failed to remove member';
      if (error instanceof Error) {
        errorMessage = error.message;
        if (error.message.toLowerCase().includes('unauthorized') || error.message.includes('401')) {
          errorMessage = 'Session expired - please login again';
          localStorage.removeItem('adminToken');
          localStorage.removeItem('adminUser');
          router.push('/login');
          return;
        }
        if (error.message.toLowerCase().includes('validation')) {
          errorMessage = `Validation error: ${error.message.split(':').pop()?.trim()}`;
        }
      }
      console.error('Member remove error:', error);
      toast.error(errorMessage, {
        action: {
          label: 'Retry',
          onClick: () => removeMember(memberId)
        },
        duration: 10000
      });
    }
  }

  async function sendInvite() {
    try {
      const token = localStorage.getItem('adminToken');
      if (!token) {
        throw new Error('Authentication token missing - please login again');
      }

      console.log('Sending invite:', inviteEmail);

      const response = await fetch(`/api/groups/${id}/invites`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`
        },
        body: JSON.stringify({ email: inviteEmail })
      });

      const data = await response.json();
      console.log('Invite response:', data);

      if (!response.ok) {
        const errorMessage = data.message || `Failed to send invite (Status: ${response.status})`;
        throw new Error(errorMessage);
      }

      toast.success('Invitation sent successfully');
      setShowInviteDialog(false);
      setInviteEmail('');
    } catch (error) {
      let errorMessage = 'Failed to send invite';
      if (error instanceof Error) {
        errorMessage = error.message;
        if (error.message.toLowerCase().includes('unauthorized') || error.message.includes('401')) {
          errorMessage = 'Session expired - please login again';
          localStorage.removeItem('adminToken');
          localStorage.removeItem('adminUser');
          router.push('/login');
          return;
        }
        if (error.message.toLowerCase().includes('validation')) {
          errorMessage = `Validation error: ${error.message.split(':').pop()?.trim()}`;
        }
      }
      console.error('Invite error:', error);
      toast.error(errorMessage, {
        action: {
          label: 'Retry',
          onClick: () => sendInvite()
        },
        duration: 10000
      });
    }
  }

  async function handleDeleteGroup() {
    try {
      setDeleting(true);
      const token = localStorage.getItem('adminToken');
      if (!token) {
        throw new Error('Authentication token missing - please login again');
      }

      console.log('Deleting group:', id);

      const response = await fetch(`/api/groups/${id}`, {
        method: 'DELETE',
        headers: {
          'Authorization': `Bearer ${token}`
        }
      });

      const data = await response.json();
      console.log('Delete group response:', data);

      if (!response.ok) {
        const errorMessage = data.message || `Failed to delete group (Status: ${response.status})`;
        throw new Error(errorMessage);
      }

      toast.success('Group deleted successfully');
      router.push('/dashboard/groups');
    } catch (error) {
      let errorMessage = 'Failed to delete group';
      if (error instanceof Error) {
        errorMessage = error.message;
        if (error.message.toLowerCase().includes('unauthorized') || error.message.includes('401')) {
          errorMessage = 'Session expired - please login again';
          localStorage.removeItem('adminToken');
          localStorage.removeItem('adminUser');
          router.push('/login');
          return;
        }
        if (error.message.toLowerCase().includes('validation')) {
          errorMessage = `Validation error: ${error.message.split(':').pop()?.trim()}`;
        }
      }
      console.error('Delete group error:', error);
      toast.error(errorMessage, {
        action: {
          label: 'Retry',
          onClick: () => handleDeleteGroup()
        },
        duration: 10000
      });
    } finally {
      if (isMounted) {
        setDeleting(false);
        setShowDeleteDialog(false);
      }
    }
  }

  if (error) {
    return (
      <div className="flex flex-col items-center justify-center h-[60vh] gap-4">
        <div className="text-center space-y-2">
          <h3 className="text-lg font-medium">Error loading group</h3>
          <p className="text-sm text-muted-foreground">{error}</p>
        </div>
        <Button onClick={() => router.push('/dashboard/groups')}>
          Back to Groups
        </Button>
      </div>
    );
  }

  if (loading.group || !group) {
    return (
      <div className="space-y-6">
        <div className="flex items-center gap-4">
          <Skeleton className="h-9 w-9 rounded-md" />
          <div className="flex items-center gap-3">
            <Skeleton className="h-10 w-10 rounded-full" />
            <div className="space-y-2">
              <Skeleton className="h-6 w-48" />
              <div className="flex gap-2">
                <Skeleton className="h-5 w-16" />
                <Skeleton className="h-5 w-16" />
              </div>
            </div>
          </div>
          <div className="ml-auto flex gap-2">
            <Skeleton className="h-9 w-24" />
            <Skeleton className="h-9 w-24" />
          </div>
        </div>
        <Tabs defaultValue="overview">
          <TabsList>
            <Skeleton className="h-9 w-24" />
            <Skeleton className="h-9 w-24" />
            <Skeleton className="h-9 w-24" />
            <Skeleton className="h-9 w-24" />
          </TabsList>
          <div className="space-y-4 mt-4">
            <Skeleton className="h-32 w-full" />
            <Skeleton className="h-32 w-full" />
          </div>
        </Tabs>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center gap-4">
        <Button variant="outline" size="icon" onClick={() => router.push('/dashboard/groups')}>
          <ArrowLeft className="h-4 w-4" />
        </Button>
        <div className="flex items-center gap-3">
          <Avatar className="h-10 w-10">
            <AvatarImage src={group.avatar} />
            <AvatarFallback>{group.name.charAt(0).toUpperCase()}</AvatarFallback>
          </Avatar>
          <div>
            <h1 className="text-2xl font-bold">{group.name}</h1>
            <div className="flex gap-2">
              <Badge variant={group.type === 'public' ? 'default' : 'secondary'}>
                {group.type.charAt(0).toUpperCase() + group.type.slice(1)}
              </Badge>
              <Badge variant={group.isActive ? 'default' : 'destructive'}>
                {group.isActive ? 'Active' : 'Inactive'}
              </Badge>
            </div>
          </div>
        </div>
        <div className="ml-auto flex gap-2">
          <Button onClick={() => setShowInviteDialog(true)} disabled={updating}>
            <UserPlus className="mr-2 h-4 w-4" />
            Invite Member
          </Button>
          <Button variant="destructive" onClick={() => setShowDeleteDialog(true)} disabled={deleting}>
            {deleting ? <Loader2 className="h-4 w-4 animate-spin" /> : <Trash2 className="mr-2 h-4 w-4" />}
            Delete Group
          </Button>
        </div>
      </div>

      <Tabs defaultValue="overview" className="space-y-4">
        <TabsList>
          <TabsTrigger value="overview">Overview</TabsTrigger>
          <TabsTrigger value="members">Members</TabsTrigger>
          <TabsTrigger value="settings">Settings</TabsTrigger>
          <TabsTrigger value="activity">Activity</TabsTrigger>
        </TabsList>

        <TabsContent value="overview" className="space-y-4">
          <Card>
            <CardHeader>
              <CardTitle>Group Details</CardTitle>
              <CardDescription>Manage group information and settings</CardDescription>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="space-y-2">
                <Label htmlFor="group-name">Name</Label>
                <Input
                  id="group-name"
                  value={editGroup.name}
                  onChange={(e) => setEditGroup({ ...editGroup, name: e.target.value })}
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="group-description">Description</Label>
                <Textarea
                  id="group-description"
                  value={editGroup.description}
                  onChange={(e) => setEditGroup({ ...editGroup, description: e.target.value })}
                />
              </div>
              <Button onClick={updateGroupDetails} disabled={updating}>
                {updating ? <Loader2 className="mr-2 h-4 w-4 animate-spin" /> : <Edit className="mr-2 h-4 w-4" />}
                Update Details
              </Button>
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="members">
          <Card>
            <CardHeader>
              <CardTitle>Members ({group.memberCount})</CardTitle>
              <CardDescription>Manage group members and their roles</CardDescription>
            </CardHeader>
            <CardContent>
              {loading.members ? (
                <div className="space-y-4">
                  {[...Array(3)].map((_, i) => (
                    <Skeleton key={i} className="h-12 w-full" />
                  ))}
                </div>
              ) : members.length === 0 ? (
                <div className="text-center py-12 space-y-4">
                  <Users className="mx-auto h-8 w-8 text-muted-foreground" />
                  <p className="text-muted-foreground">No members found</p>
                </div>
              ) : (
                <div className="space-y-4">
                 {members.map((member) => (
  <div key={member?.id} className="flex items-center justify-between p-4 border rounded-lg">
    <div className="flex items-center gap-3">
      <Avatar className="h-9 w-9">
        <AvatarImage src={member?.avatar} />
        <AvatarFallback>{member?.name?.charAt?.(0)?.toUpperCase() || "?"}</AvatarFallback>
      </Avatar>
      <div>
        <p className="font-medium">{member?.name || "Unknown"}</p>
        <p className="text-sm text-muted-foreground">{member?.email || "No email"}</p>
      </div>
    </div>
    <div className="flex items-center gap-2">
      <Badge variant={member?.role === 'admin' ? 'default' : 'secondary'}>
        {(member?.role?.charAt?.(0)?.toUpperCase() || "") + (member?.role?.slice?.(1) || "")}
      </Badge>
      <DropdownMenu>
        <DropdownMenuTrigger asChild>
          <Button variant="ghost" size="icon">
            <MoreVertical className="h-4 w-4" />
          </Button>
        </DropdownMenuTrigger>
        <DropdownMenuContent align="end">
          <DropdownMenuItem onClick={() => updateMemberRole(member?.id, member?.role === 'admin' ? 'member' : 'admin')}>
            <Shield className="mr-2 h-4 w-4" />
            {member?.role === 'admin' ? 'Make Member' : 'Make Admin'}
          </DropdownMenuItem>
          <DropdownMenuItem className="text-red-600" onClick={() => removeMember(member?.id)}>
            <UserX className="mr-2 h-4 w-4" />
            Remove Member
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
              <CardDescription>Configure group permissions and features</CardDescription>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="flex items-center justify-between">
                <div className="space-y-0.5">
                  <Label>Allow Messages</Label>
                  <p className="text-sm text-muted-foreground">Enable/disable sending messages in the group</p>
                </div>
                <Switch
                  checked={group.settings.sendMessages}
                  onCheckedChange={(checked) => updateGroupSettings({ sendMessages: checked })}
                  disabled={updating}
                />
              </div>
              <div className="flex items-center justify-between">
                <div className="space-y-0.5">
                  <Label>Allow Media</Label>
                  <p className="text-sm text-muted-foreground">Enable/disable sending media in the group</p>
                </div>
                <Switch
                  checked={group.settings.sendMedia}
                  onCheckedChange={(checked) => updateGroupSettings({ sendMedia: checked })}
                  disabled={updating}
                />
              </div>
              <div className="flex items-center justify-between">
                <div className="space-y-0.5">
                  <Label>Allow Polls</Label>
                  <p className="text-sm text-muted-foreground">Enable/disable creating polls in the group</p>
                </div>
                <Switch
                  checked={group.settings.sendPolls}
                  onCheckedChange={(checked) => updateGroupSettings({ sendPolls: checked })}
                  disabled={updating}
                />
              </div>
              <div className="flex items-center justify-between">
                <div className="space-y-0.5">
                  <Label>Allow Member Invites</Label>
                  <p className="text-sm text-muted-foreground">Allow members to invite others to the group</p>
                </div>
                <Switch
                  checked={group.settings.allowInvites}
                  onCheckedChange={(checked) => updateGroupSettings({ allowInvites: checked })}
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
              <CardDescription>Recent events and actions in the group</CardDescription>
            </CardHeader>
            <CardContent>
              {loading.activities ? (
                <div className="space-y-4">
                  {[...Array(3)].map((_, i) => (
                    <Skeleton key={i} className="h-12 w-full" />
                  ))}
                </div>
              ) : activities.length === 0 ? (
                <div className="text-center py-12 space-y-4">
                  <Activity className="mx-auto h-8 w-8 text-muted-foreground" />
                  <p className="text-muted-foreground">No recent activity</p>
                </div>
              ) : (
                <div className="space-y-4">
                  {activities.map((activity) => (
                    <div key={activity.id} className="flex items-center gap-4">
                      <Avatar className="h-9 w-9">
                        <AvatarImage src={activity.user.avatar} />
                        <AvatarFallback>{activity.user.name.charAt(0).toUpperCase()}</AvatarFallback>
                      </Avatar>
                      <div className="flex-1">
                        <p className="text-sm">
                          <span className="font-medium">{activity.user.name}</span> {activity.message}
                        </p>
                        <p className="text-xs text-muted-foreground">
                          {new Date(activity.timestamp).toLocaleString()}
                        </p>
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
            <DialogTitle>Delete Group</DialogTitle>
            <DialogDescription>
              Are you sure you want to delete {group.name}? This action cannot be undone.
            </DialogDescription>
          </DialogHeader>
          <DialogFooter>
            <Button variant="outline" onClick={() => setShowDeleteDialog(false)}>
              Cancel
            </Button>
            <Button variant="destructive" onClick={handleDeleteGroup} disabled={deleting}>
              {deleting ? <Loader2 className="mr-2 h-4 w-4 animate-spin" /> : null}
              Delete
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      <Dialog open={showInviteDialog} onOpenChange={setShowInviteDialog}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Invite Member</DialogTitle>
            <DialogDescription>
              Enter the email address of the person you want to invite to {group.name}.
            </DialogDescription>
          </DialogHeader>
          <div className="space-y-4">
            <div className="space-y-2">
              <Label htmlFor="invite-email">Email</Label>
              <Input
                id="invite-email"
                type="email"
                value={inviteEmail}
                onChange={(e) => setInviteEmail(e.target.value)}
                placeholder="Enter email address"
              />
            </div>
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setShowInviteDialog(false)}>
              Cancel
            </Button>
            <Button onClick={sendInvite} disabled={!inviteEmail}>
              Send Invite
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}