"use client";

import { useState, useEffect, use } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import { 
  ArrowLeft, Edit, Users, Settings, Activity, 
  MoreVertical, Trash2, Loader2, MessageSquare,
  Mail, UserPlus, Shield, UserX
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

  // Unwrap the params promise
  const { id } = use(params);

  useEffect(() => {
    if (!id || id === 'undefined') {
      setError('Invalid group ID');
      setLoading({ group: false, members: false, activities: false });
      router.push('/dashboard/groups');
      return;
    }
    fetchGroupData();
  }, [id]);

  const fetchGroupData = async () => {
    try {
      setLoading({
        group: true,
        members: true,
        activities: true
      });
      setError(null);

      const [groupRes, membersRes, activitiesRes] = await Promise.all([
        fetch(`/api/groups/${id}`),
        fetch(`/api/groups/${id}/members`),
        fetch(`/api/groups/${id}/activities`)
      ]);

      if (!groupRes.ok) throw new Error('Failed to fetch group details');
      if (!membersRes.ok) throw new Error('Failed to fetch members');
      if (!activitiesRes.ok) throw new Error('Failed to fetch activities');

      const [groupData, membersData, activitiesData] = await Promise.all([
        groupRes.json(),
        membersRes.json(),
        activitiesRes.json()
      ]);

      setGroup(groupData);
      setMembers(membersData);
      setActivities(activitiesData);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to load group data');
      console.error(err);
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
      const response = await fetch(`/api/groups/${group.id}/settings`, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(settings)
      });

      if (!response.ok) throw new Error('Failed to update settings');

      const updatedSettings = await response.json();
      setGroup({ ...group, settings: updatedSettings });
      toast.success('Group settings updated');
    } catch (err) {
      toast.error('Failed to update settings');
      console.error(err);
    } finally {
      setUpdating(false);
    }
  };

  const updateMemberRole = async (memberId: string, newRole: 'member' | 'admin') => {
    try {
      const response = await fetch(`/api/groups/${id}/members/${memberId}/role`, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({ role: newRole })
      });

      if (!response.ok) throw new Error('Failed to update role');

      setMembers(members.map(member => 
        member.id === memberId ? { ...member, role: newRole } : member
      ));
      toast.success(`Member role updated to ${newRole}`);
    } catch (err) {
      toast.error('Failed to update role');
      console.error(err);
    }
  };

  const removeMember = async (memberId: string) => {
    try {
      const response = await fetch(`/api/groups/${id}/members/${memberId}`, {
        method: 'DELETE'
      });

      if (!response.ok) throw new Error('Failed to remove member');

      setMembers(members.filter(member => member.id !== memberId));
      toast.success('Member removed from group');
    } catch (err) {
      toast.error('Failed to remove member');
      console.error(err);
    }
  };

  const handleDeleteGroup = async () => {
    try {
      setDeleting(true);
      const response = await fetch(`/api/groups/${id}`, {
        method: 'DELETE'
      });

      if (!response.ok) throw new Error('Failed to delete group');

      toast.success('Group deleted successfully');
      router.push('/dashboard/groups');
    } catch (err) {
      toast.error('Failed to delete group');
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
      {/* Rest of your component remains the same */}
      {/* ... */}
    </div>
  );
}