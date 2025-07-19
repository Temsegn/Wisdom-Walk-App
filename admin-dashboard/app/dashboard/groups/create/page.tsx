"use client"
import { useState } from 'react'
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
  const [loading, setLoading] = useState(false)
const handleSubmit = async (e: React.FormEvent) => {
  e.preventDefault()
  setLoading(true)

  try {
    const token = localStorage.getItem('token') // Get token from storage
    if (!token) {
      throw new Error('Authentication token missing')
    }

    const response = await fetch('/api/groups', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}` // Add auth header
      },
      body: JSON.stringify({
        ...formData,
        members: [] // Add empty members array to match schema
      })
    })

    if (!response.ok) {
      const errorData = await response.json() // Get detailed error from backend
      throw new Error(errorData.message || 'Failed to create group')
    }

    // ... rest of your success handling
  } catch (error) {
    console.error('Group creation error:', error)
    const errorMessage = (error instanceof Error) ? error.message : 'Failed to create group'
    toast.error(errorMessage) // Show actual error message
  } finally {
    setLoading(false)
  }
}
  return (
    <div className="space-y-6">
      <div className="flex items-center gap-4">
        <Button variant="outline" size="icon" onClick={() => router.back()}>
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
                onChange={(e) => setFormData({...formData, name: e.target.value})}
                required
                placeholder="e.g. Wisdom Walk Support"
              />
            </div>

            <div className="space-y-2">
              <Label htmlFor="description">Description</Label>
              <Textarea
                id="description"
                value={formData.description}
                onChange={(e) => setFormData({...formData, description: e.target.value})}
                placeholder="What's this group about?"
                rows={3}
              />
            </div>

            <div className="space-y-2">
              <Label>Group Type</Label>
              <RadioGroup
                defaultValue="public"
                value={formData.type}
                onValueChange={(value) => setFormData({...formData, type: value as 'public' | 'private'})}
                className="grid grid-cols-2 gap-4"
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
              />
            </div>

            <div className="flex justify-end gap-4">
              <Button variant="outline" type="button" onClick={() => router.push('/dashboard/groups')}>
                Cancel
              </Button>
              <Button type="submit" disabled={loading}>
                {loading ? (
                  <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                ) : (
                  <PlusCircle className="mr-2 h-4 w-4" />
                )}
                Create Group
              </Button>
            </div>
          </form>
        </CardContent>
      </Card>
    </div>
  )
}