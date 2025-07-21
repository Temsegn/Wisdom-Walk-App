"use client";

import { useState, useEffect } from 'react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { PlusCircle, Users, MoreVertical, Trash2, Edit, Loader2, ArrowLeft } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';
import { Badge } from '@/components/ui/badge';
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger
} from '@/components/ui/dropdown-menu';
import { toast } from 'sonner';
import { Skeleton } from '@/components/ui/skeleton';

type Group = {
  id: string;
  name: string;
  description: string;
  type: 'public' | 'private';
  memberCount: number;
  avatar?: string;
  isActive: boolean;
  settings: {
    sendMessages: boolean;
    sendMedia: boolean;
    sendPolls: boolean;
    allowInvites: boolean;
  };
  createdAt: string;
  updatedAt: string;
};

export default function GroupListPage() {
  const router = useRouter();
  const [groups, setGroups] = useState<Group[]>([]);
  const [loading, setLoading] = useState(true);
  const [deletingId, setDeletingId] = useState<string | null>(null);
  const [isMounted, setIsMounted] = useState(false);

  useEffect(() => {
    setIsMounted(true);
    fetchGroups();
  }, []);

  const fetchGroups = async () => {
    try {
      setLoading(true);
      const token = localStorage.getItem('adminToken');

      if (!token) {
        toast.error('Please login first');
        router.push('/login');
        return;
      }

      const response = await fetch('/api/groups', {
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        }
      });

      const result = await response.json();
      console.log('API Response:', result); // Debug log

      if (!response.ok) {
        throw new Error(result.message || 'Failed to fetch groups');
      }

      // Handle both response formats:
      // 1. Direct array response
      // 2. Object with groups property
      const receivedGroups = Array.isArray(result) ? result : result.groups || [];

      // Transform data to match Group type
      const formattedGroups = receivedGroups.map((group: any) => ({
        id: group._id || group.id,
        name: group.name,
        description: group.description || '',
        type: group.type,
        memberCount: group.members?.length || group.memberCount || 0,
        avatar: group.avatar,
        isActive: group.isActive !== undefined ? group.isActive : true,
        settings: {
          sendMessages: group.settings?.sendMessages ?? true,
          sendMedia: group.settings?.sendMedia ?? true,
          sendPolls: group.settings?.sendPolls ?? true,
          allowInvites: group.settings?.allowInvites ?? true
        },
        createdAt: group.createdAt || new Date().toISOString(),
        updatedAt: group.updatedAt || new Date().toISOString()
      }));

      setGroups(formattedGroups);
    } catch (error) {
      console.error('Fetch error:', error);
      toast.error(
        error instanceof Error ? error.message : 'Failed to fetch groups'
      );
    } finally {
      setLoading(false);
    }
  };

  const deleteGroup = async (groupId: string) => {
    try {
      setDeletingId(groupId);
      const token = localStorage.getItem('adminToken');

      if (!token) {
        throw new Error('Authentication required');
      }

      const response = await fetch(`/api/groups/${groupId}`, {
        method: 'DELETE',
        headers: {
          'Authorization': `Bearer ${token}`
        }
      });

      if (!response.ok) {
        const errorData = await response.json();
        throw new Error(errorData.message || 'Failed to delete group');
      }

      setGroups(groups.filter(group => group.id !== groupId));
      toast.success('Group deleted successfully');
    } catch (error) {
      console.error(error);
      toast.error(
        error instanceof Error ? error.message : 'Failed to delete group'
      );
    } finally {
      setDeletingId(null);
    }
  };

  if (!isMounted) return null;

  return (
    <div className="space-y-6">
      <div className="flex items-center gap-4">
        <Button
          variant="outline"
          size="icon"
          onClick={() => router.back()}
          disabled={loading}
        >
          <ArrowLeft className="h-4 w-4" />
        </Button>
        <div className="flex-1">
          <h1 className="text-2xl font-bold">Groups</h1>
          <p className="text-sm text-muted-foreground">
            Manage all groups in your organization
          </p>
        </div>
        <Button asChild>
          <Link href="/dashboard/groups/create">
            <PlusCircle className="mr-2 h-4 w-4" />
            Create Group
          </Link>
        </Button>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>All Groups</CardTitle>
          <CardDescription>
            {groups.length} {groups.length === 1 ? 'group' : 'groups'} found
          </CardDescription>
        </CardHeader>
        <CardContent>
          {loading ? (
            <div className="space-y-4">
              {[...Array(5)].map((_, i) => (
                <Skeleton key={i} className="h-12 w-full" />
              ))}
            </div>
          ) : groups.length === 0 ? (
            <div className="text-center py-12 space-y-4">
              <Users className="mx-auto h-8 w-8 text-muted-foreground" />
              <p className="text-muted-foreground">No groups found</p>
              <Button asChild>
                <Link href="/dashboard/groups/create">
                  Create your first group
                </Link>
              </Button>
            </div>
          ) : (
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Group</TableHead>
                  <TableHead>Type</TableHead>
                  <TableHead>Members</TableHead>
                  <TableHead>Created</TableHead>
                  <TableHead>Status</TableHead>
                  <TableHead className="text-right">Actions</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {groups.map((group) => (
                  <TableRow key={group.id}>
                    <TableCell>
                      <div className="flex items-center gap-3">
                        <Avatar className="h-9 w-9">
                          <AvatarImage src={group.avatar} />
                          <AvatarFallback>
                            {group.name.charAt(0).toUpperCase()}
                          </AvatarFallback>
                        </Avatar>
                        <Link
                          href={`/dashboard/groups/${group.id}`}
                          className="font-medium hover:underline"
                        >
                          {group.name}
                        </Link>
                      </div>
                    </TableCell>
                    <TableCell>
                      <Badge variant={group.type === 'public' ? 'default' : 'secondary'}>
                        {group.type.charAt(0).toUpperCase() + group.type.slice(1)}
                      </Badge>
                    </TableCell>
                    <TableCell>
                      <div className="flex items-center gap-2">
                        <Users className="h-4 w-4" />
                        {group.memberCount}
                      </div>
                    </TableCell>
                    <TableCell>
                      {new Date(group.createdAt).toLocaleDateString()}
                    </TableCell>
                    <TableCell>
                      <Badge variant={group.isActive ? 'default' : 'destructive'}>
                        {group.isActive ? 'Active' : 'Inactive'}
                      </Badge>
                    </TableCell>
                    <TableCell className="text-right">
                      <DropdownMenu>
                        <DropdownMenuTrigger asChild>
                          <Button variant="ghost" size="icon">
                            <MoreVertical className="h-4 w-4" />
                          </Button>
                        </DropdownMenuTrigger>
                        <DropdownMenuContent align="end">
                          <DropdownMenuItem asChild>
                            <Link href={`/dashboard/groups/${group.id}`}>
                              <Edit className="mr-2 h-4 w-4" />
                              Manage
                            </Link>
                          </DropdownMenuItem>
                          <DropdownMenuItem
                            className="text-red-600"
                            onClick={() => deleteGroup(group.id)}
                            disabled={deletingId === group.id}
                          >
                            {deletingId === group.id ? (
                              <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                            ) : (
                              <Trash2 className="mr-2 h-4 w-4" />
                            )}
                            Delete
                          </DropdownMenuItem>
                        </DropdownMenuContent>
                      </DropdownMenu>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          )}
        </CardContent>
      </Card>
    </div>
  );
}