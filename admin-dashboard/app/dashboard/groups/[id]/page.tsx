"use client";

import * as React from 'react';
import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import { 
  ArrowLeft, Edit, Users, Settings, Activity, 
  MoreVertical, Trash2, Loader2, UserPlus, Shield, UserX
} from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card';
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
  const { id } = React.use(params); // Unwrap params using React.use()
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
  const [isAdmin, setIsAdmin] = useState<boolean>(false); // Track admin status

  useEffect(() => {
    // Check if user has admin privileges (based on adminToken)
    const token = localStorage.getItem('adminToken');
    if (token) {
      // Assume adminToken implies admin privileges; verify with backend if needed
      setIsAdmin(true);
    }

    if (!id || id === 'undefined') {
      setError('Invalid group ID');
      setLoading({ group: false, members: false, activities: false });
      router.push('/dashboard/groups');
      return;
    }
    fetchGroupData();
  }, [id, router]);

  const fetchGroupData = async () => {
    try {
      setLoading({
        group: true,
        members: true,
        activities: true
      });
      setError(null);

      const token = localStorage.getItem('adminToken');
      if (!token) {
        throw new Error('Authentication required');
      }

      const headers = {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json',
        // Add header to indicate admin request
        'X-Admin-Request': isAdmin ? 'true' : 'false'
      };

      const [groupRes, membersRes, activitiesRes] = await Promise.all([
        fetch(`/api/groups/${id}`, { headers }),
        fetch(`/api/groups/${id}/members`, { headers }),
        fetch(`/api/groups/${id}/activities`, { headers })
      ]);

      if (!groupRes.ok) {
        const errorData = await groupRes.json();
        const errorMessage = errorData.message || `Failed to fetch group details (Status: ${groupRes.status})`;
        if (errorMessage.includes('Access denied') || groupRes.status === 403) {
          throw new Error('Access denied. You are not a member of this group or lack admin privileges.');
        }
        throw new Error(errorMessage);
      }
      if (!membersRes.ok) {
        const errorData = await membersRes.json();
        throw new Error(errorData.message || `Failed to fetch members (Status: ${membersRes.status})`);
      }
      if (!activitiesRes.ok) {
        const errorData = await activitiesRes.json();
        throw new Error(errorData.message || `Failed to fetch activities (Status: ${activitiesRes.status})`);
      }

      const [groupData, membersData, activitiesData] = await Promise.all([
        groupRes.json(),
        membersRes.json(),
        activitiesRes.json()
      ]);

      setGroup({
        ...groupData,
        settings: {
          sendMessages: groupData.settings?.sendMessages ?? true,
          sendMedia: groupData.settings?.sendMedia ?? true,
          sendPolls: groupData.settings?.sendPolls ?? true,
          allowInvites: groupData.settings?.allowInvites ?? true
        }
      });
      setMembers(membersData);
      setActivities(activitiesData);
      setEditGroup({ name: groupData.name, description: groupData.description || '' });
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Failed to load group data';
      console.error('Fetch error:', err);
      setError(errorMessage);
      toast.error(errorMessage);
    } finally {
      setLoading({
        group: false,
        members: false,
        activities: false
      });
    }
  };

  const updateGroupSettings = async (settings: Partial<Group['settings']>) => {
    if (!group) return;

    try {
      setUpdating(true);
      const token = localStorage.getItem('adminToken');
      if (!token) throw new Error('Authentication required');

      const response = await fetch(`/api/groups/${id}/settings`, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`,
          'X-Admin-Request': isAdmin ? 'true' : 'false'
        },
        body: JSON.stringify(settings)
      });

      if (!response.ok) {
        const errorData = await response.json();
        throw new Error(errorData.message || 'Failed to update settings');
      }

      const updatedSettings = await response.json();
      setGroup({ ...group, settings: updatedSettings });
      toast.success('Group settings updated');
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to update settings');
      console.error(err);
    } finally {
      setUpdating(false);
    }
  };

  const updateGroupDetails = async () => {
    if (!group) return;

    try {
      setUpdating(true);
      const token = localStorage.getItem('adminToken');
      if (!token) throw new Error('Authentication required');

      const response = await fetch(`/api/groups/${id}`, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`,
          'X-Admin-Request': isAdmin ? 'true' : 'false'
        },
        body: JSON.stringify({
          name: editGroup.name,
          description: editGroup.description
        })
      });

      if (!response.ok) {
        const errorData = await response.json();
        throw new Error(errorData.message || 'Failed to update group details');
      }

      const updatedGroup = await response.json();
      setGroup({ ...group, ...updatedGroup });
      toast.success('Group details updated');
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to update group details');
      console.error(err);
    } finally {
      setUpdating(false);
    }
  };

  const updateMemberRole = async (memberId: string, newRole: 'member' | 'admin') => {
    try {
      const token = localStorage.getItem('adminToken');
      if (!token) throw new Error('Authentication required');

      const response = await fetch(`/api/groups/${id}/members/${memberId}/role`, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`,
          'X-Admin-Request': isAdmin ? 'true' : 'false'
        },
        body: JSON.stringify({ role: newRole })
      });

      if (!response.ok) {
        const errorData = await response.json();
        throw new Error(errorData.message || 'Failed to update role');
      }

      setMembers(members.map(member => 
        member.id === memberId ? { ...member, role: newRole } : member
      ));
      toast.success(`Member role updated to ${newRole}`);
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to update role');
      console.error(err);
    }
  };

  const removeMember = async (memberId: string) => {
    try {
      const token = localStorage.getItem('adminToken');
      if (!token) throw new Error('Authentication required');

      const response = await fetch(`/api/groups/${id}/members/${memberId}`, {
        method: 'DELETE',
        headers: {
          'Authorization': `Bearer ${token}`,
          'X-Admin-Request': isAdmin ? 'true' : 'false'
        }
      });

      if (!response.ok) {
        const errorData = await response.json();
        throw new Error(errorData.message || 'Failed to remove member');
      }

      setMembers(members.filter(member => member.id !== memberId));
      setGroup(group ? { ...group, memberCount: group.memberCount - 1 } : null);
      toast.success('Member removed from group');
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to remove member');
      console.error(err);
    }
  };

  const sendInvite = async () => {
    try {
      const token = localStorage.getItem('adminToken');
      if (!token) throw new Error('Authentication required');

      const response = await fetch(`/api/groups/${id}/invites`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`,
          'X-Admin-Request': isAdmin ? 'true' : 'false'
        },
        body: JSON.stringify({ email: inviteEmail })
      });

      if (!response.ok) {
        const errorData = await response.json();
        throw new Error(errorData.message || 'Failed to send invite');
      }

      toast.success('Invitation sent successfully');
      setShowInviteDialog(false);
      setInviteEmail('');
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to send invite');
      console.error(err);
    }
  };

  const handleDeleteGroup = async () => {
    try {
      setDeleting(true);
      const token = localStorage.getItem('adminToken');
      if (!token) throw new Error('Authentication required');

      const response = await fetch(`/api/groups/${id}`, {
        method: 'DELETE',
        headers: {
          'Authorization': `Bearer ${token}`,
          'X-Admin-Request': isAdmin ? 'true' : 'false'
        }
      });

      if (!response.ok) {
        const errorData = await response.json();
        throw new Error(errorData.message || 'Failed to delete group');
      }

      toast.success('Group deleted successfully');
      router.push('/dashboard/groups');
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to delete group');
      console.error(err);
    } finally {
      setDeleting(false);
      setShowDeleteDialog(false);
    }
  };

  if (error) {
    return (
      <div className="flex flex-col items-center justify-center h-[60vh] gap-4">
        <div className="text-center space-y-2">
          <h3 className="text-lg font-medium">Error loading group</h3>
          <p className="text-sm text-muted-foreground">
            {error.includes('Access denied')
              ? 'You do not have permission to view this group. Please contact a group admin to gain access.'
              : error}
          </p>
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
              {isAdmin && (
                <Badge variant="outline">Admin</Badge>
              )}
            </div>
          </div>
        </div>
        <div className="ml-auto flex gap-2">
          <Button onClick={() => setShowInviteDialog(true)} disabled={updating || !isAdmin}>
            <UserPlus className="mr-2 h-4 w-4" />
            Invite Member
          </Button>
          <Button variant="destructive" onClick={() => setShowDeleteDialog(true)} disabled={deleting || !isAdmin}>
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
                  disabled={!isAdmin}
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="group-description">Description</Label>
                <Textarea
                  id="group-description"
                  value={editGroup.description}
                  onChange={(e) => setEditGroup({ ...editGroup, description: e.target.value })}
                  disabled={!isAdmin}
                />
              </div>
              <Button onClick={updateGroupDetails} disabled={updating || !isAdmin}>
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
                    <div key={member.id} className="flex items-center justify-between p-4 border rounded-lg">
                      <div className="flex items-center gap-3">
                        <Avatar className="h-9 w-9">
                          <AvatarImage src={member.avatar} />
                          <AvatarFallback>{member.name.charAt(0).toUpperCase()}</AvatarFallback>
                        </Avatar>
                        <div>
                          <p className="font-medium">{member.name}</p>
                          <p className="text-sm text-muted-foreground">{member.email}</p>
                        </div>
                      </div>
                      <div className="flex items-center gap-2">
                        <Badge variant={member.role === 'admin' ? 'default' : 'secondary'}>
                          {member.role.charAt(0).toUpperCase() + member.role.slice(1)}
                        </Badge>
                        {isAdmin && (
                          <DropdownMenu>
                            <DropdownMenuTrigger asChild>
                              <Button variant="ghost" size="icon">
                                <MoreVertical className="h-4 w-4" />
                              </Button>
                            </DropdownMenuTrigger>
                            <DropdownMenuContent align="end">
                              <DropdownMenuItem onClick={() => updateMemberRole(member.id, member.role === 'admin' ? 'member' : 'admin')}>
                                <Shield className="mr-2 h-4 w-4" />
                                {member.role === 'admin' ? 'Make Member' : 'Make Admin'}
                              </DropdownMenuItem>
                              <DropdownMenuItem className="text-red-600" onClick={() => removeMember(member.id)}>
                                <UserX className="mr-2 h-4 w-4" />
                                Remove Member
                              </DropdownMenuItem>
                            </DropdownMenuContent>
                          </DropdownMenu>
                        )}
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
                  disabled={updating || !isAdmin}
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
                  disabled={updating || !isAdmin}
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
                  disabled={updating || !isAdmin}
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
                  disabled={updating || !isAdmin}
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
            <Button variant="destructive" onClick={handleDeleteGroup} disabled={deleting || !isAdmin}>
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
                disabled={!isAdmin}
              />
            </div>
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setShowInviteDialog(false)}>
              Cancel
            </Button>
            <Button onClick={sendInvite} disabled={!inviteEmail || !isAdmin}>
              Send Invite
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}