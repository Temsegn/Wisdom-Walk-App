"use client"
import { useState, useEffect } from 'react'
import { useRouter } from 'next/navigation'
import { ArrowLeft, PlusCircle, Loader2 } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Textarea } from '@/components/ui/textarea'
import { Label } from '@/components/ui/label'
import { RadioGroup, RadioGroupItem } from '@/components/ui/radio-group'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { toast } from 'sonner'
import { Switch } from '@/components/ui/switch'

export default function CreateGroupPage() {
  const router = useRouter()
  const [formData, setFormData] = useState({
    name: '',
    description: '',
    type: 'public',
    isActive: true
  })
  const [errors, setErrors] = useState<Record<string, string>>({})
  const [loading, setLoading] = useState(false)
  const [isMounted, setIsMounted] = useState(false)

  useEffect(() => {
    setIsMounted(true)
    const token = localStorage.getItem('adminToken')
    if (!token) {
      toast.error('Please login to continue')
      router.push('/login')
    }
  }, [router])

  const validateForm = () => {
    const newErrors: Record<string, string> = {}
    
    if (!formData.name.trim()) {
      newErrors.name = 'Group name is required'
    } else if (formData.name.length > 50) {
      newErrors.name = 'Name must be 50 characters or less'
    }
    
    if (formData.description.length > 500) {
      newErrors.description = 'Description must be 500 characters or less'
    }
    
    setErrors(newErrors)
    return Object.keys(newErrors).length === 0
  }
  const handleSubmit = async (e: React.FormEvent) => {
  e.preventDefault();
  
  if (!validateForm()) return;

  setLoading(true);

  try {
    const token = localStorage.getItem('adminToken');
    if (!token) {
      throw new Error('Authentication token missing - please login again');
    }

    // Debug log the request payload
    console.log('Submitting group data:', formData);

    const response = await fetch('/api/groups', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`
      },
      body: JSON.stringify({
        name: formData.name.trim(),
        description: formData.description.trim(),
        type: formData.type,
        isActive: formData.isActive
      })
    });

    const data = await response.json();
    console.log('Backend response:', data); // Debug log

    if (!response.ok) {
      // Enhanced error extraction
      const serverError = data.error || data.message || 'Unknown server error';
      throw new Error(`Server responded with ${response.status}: ${serverError}`);
    }

    toast.success('Group created successfully!');
    router.push(`/dashboard/groups/${data.id || data._id}`);
    
  } catch (error) {
    console.error('Group creation failed:', error);
    
    let errorMessage = 'Failed to create group';
    if (error instanceof Error) {
      errorMessage = error.message;
      
      // Handle specific error cases
      if (error.message.toLowerCase().includes('unauthorized') || 
          error.message.includes('401')) {
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
    
    toast.error(errorMessage, {
      action: {
        label: 'Retry',
        onClick: () => handleSubmit(e)
      },
      duration: 10000 // Longer duration for error messages
    });
  } finally {
    if (isMounted) {
      setLoading(false);
    }
  }
};

  if (!isMounted) return null

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
        <h1 className="text-2xl font-bold">Create New Group</h1>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Group Details</CardTitle>
        </CardHeader>
        <CardContent>
          <form onSubmit={handleSubmit} className="space-y-6">
            <div className="space-y-2">
              <Label htmlFor="name">Group Name *</Label>
              <Input
                id="name"
                value={formData.name}
                onChange={(e) => {
                  setFormData({...formData, name: e.target.value})
                  if (errors.name) setErrors({...errors, name: ''})
                }}
                required
                placeholder="e.g. Wisdom Walk Support"
                disabled={loading}
                className={errors.name ? 'border-red-500' : ''}
              />
              {errors.name && (
                <p className="text-sm text-red-500 mt-1">{errors.name}</p>
              )}
            </div>

            <div className="space-y-2">
              <Label htmlFor="description">Description</Label>
              <Textarea
                id="description"
                value={formData.description}
                onChange={(e) => {
                  setFormData({...formData, description: e.target.value})
                  if (errors.description) setErrors({...errors, description: ''})
                }}
                placeholder="What's this group about?"
                rows={3}
                disabled={loading}
                className={errors.description ? 'border-red-500' : ''}
              />
              {errors.description && (
                <p className="text-sm text-red-500 mt-1">{errors.description}</p>
              )}
            </div>

            <div className="space-y-2">
              <Label>Group Type</Label>
              <RadioGroup
                value={formData.type}
                onValueChange={(value) => setFormData({...formData, type: value as 'public' | 'private'})}
                className="grid grid-cols-2 gap-4"
                disabled={loading}
              >
                <div className="flex items-center space-x-2">
                  <RadioGroupItem value="public" id="public" />
                  <Label htmlFor="public">Public</Label>
                </div>
                <div className="flex items-center space-x-2">
                  <RadioGroupItem value="private" id="private" />
                  <Label htmlFor="private">Private</Label>
                </div>
              </RadioGroup>
            </div>

            <div className="flex items-center justify-between rounded-lg border p-4">
              <div className="space-y-0.5">
                <Label>Group Status</Label>
                <p className="text-sm text-muted-foreground">
                  Active groups are visible to members
                </p>
              </div>
              <Switch
                checked={formData.isActive}
                onCheckedChange={(value) => setFormData({...formData, isActive: value})}
                disabled={loading}
              />
            </div>

            <div className="flex justify-end gap-4">
              <Button 
                variant="outline" 
                type="button" 
                onClick={() => router.push('/dashboard/groups')}
                disabled={loading}
              >
                Cancel
              </Button>
              <Button type="submit" disabled={loading}>
                {loading ? (
                  <>
                    <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                    Creating...
                  </>
                ) : (
                  <>
                    <PlusCircle className="mr-2 h-4 w-4" />
                    Create Group
                  </>
                )}
              </Button>
            </div>
          </form>
        </CardContent>
      </Card>
    </div>
  )
}