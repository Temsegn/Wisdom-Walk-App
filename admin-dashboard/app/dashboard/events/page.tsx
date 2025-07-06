'use client'

import React, { useEffect, useState } from 'react'
import axios from 'axios'
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog'
import { Input } from '@/components/ui/input'
import { Button } from '@/components/ui/button'
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { z } from 'zod'
import { Pencil, Trash2, Eye } from 'lucide-react'
import { Textarea } from '@/components/ui/textarea'

const formSchema = z.object({
  title: z.string().min(1),
  description: z.string().min(1),
  platform: z.enum(['Zoom', 'Google Meet']),
  date: z.string(),
  time: z.string(),
  duration: z.string(),
  meetingLink: z.string().url(),
})

type FormData = z.infer<typeof formSchema>

export default function EventsPage() {
  const [events, setEvents] = useState<any[]>([])
  const [open, setOpen] = useState(false)
  const [viewMode, setViewMode] = useState<'create' | 'edit' | 'view'>('create')
  const [selectedEvent, setSelectedEvent] = useState<any | null>(null)

  const form = useForm<FormData>({
    resolver: zodResolver(formSchema),
    defaultValues: {
      title: '',
      description: '',
      platform: 'Zoom',
      date: '',
      time: '',
      duration: '',
      meetingLink: '',
    },
  })

  useEffect(() => {
    fetchEvents()
  }, [])

  const fetchEvents = async () => {
    const res = await axios.get('/api/admin/events')
    setEvents(res.data)
  }

  const onSubmit = async (data: FormData) => {
    try {
      if (viewMode === 'edit' && selectedEvent?._id) {
        await axios.put(`/api/admin/events/${selectedEvent._id}`, {
          ...data,
          duration: Number(data.duration),
        })
      } else {
        await axios.post('/api/admin/events', {
          ...data,
          duration: Number(data.duration),
        })
      }
      form.reset()
      setOpen(false)
      setSelectedEvent(null)
      fetchEvents()
    } catch (err) {
      console.error('Error saving event:', err)
    }
  }

  const handleDelete = async (id: string) => {
    if (confirm('Are you sure you want to delete this event?')) {
      await axios.delete(`/api/admin/events/${id}`)
      fetchEvents()
    }
  }

  const openCreateForm = () => {
    setViewMode('create')
    setSelectedEvent(null)
    form.reset()
    setOpen(true)
  }

  const openEditForm = (event: any) => {
    setViewMode('edit')
    setSelectedEvent(event)
    form.reset({
      ...event,
      duration: String(event.duration),
      date: event.date?.substring(0, 10),
    })
    setOpen(true)
  }

  const openViewDetails = (event: any) => {
    setViewMode('view')
    setSelectedEvent(event)
    setOpen(true)
  }

  return (
    <div className="p-6">
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-2xl font-bold">Admin Events</h1>
        <Button onClick={openCreateForm}>+ Create Event</Button>
      </div>

      <div className="overflow-x-auto">
        <table className="w-full bg-white rounded shadow">
          <thead className="bg-gray-100">
            <tr>
              <th className="text-left p-3">Title</th>
              <th>Date</th>
              <th>Platform</th>
              <th>Duration</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {events.map(event => (
              <tr key={event._id} className="border-t">
                <td className="p-3">{event.title}</td>
                <td>{new Date(event.date).toLocaleDateString()}</td>
                <td>{event.platform}</td>
                <td>{event.duration} min</td>
                <td className="space-x-2">
                  <Button size="sm" variant="outline" onClick={() => openViewDetails(event)}>
                    <Eye className="w-4 h-4" />
                  </Button>
                  <Button size="sm" variant="outline" onClick={() => openEditForm(event)}>
                    <Pencil className="w-4 h-4" />
                  </Button>
                  <Button size="sm" variant="destructive" onClick={() => handleDelete(event._id)}>
                    <Trash2 className="w-4 h-4" />
                  </Button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      <Dialog open={open} onOpenChange={setOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>
              {viewMode === 'create'
                ? 'Create Event'
                : viewMode === 'edit'
                ? 'Edit Event'
                : 'Event Details'}
            </DialogTitle>
          </DialogHeader>

          {viewMode === 'view' && selectedEvent ? (
            <div className="space-y-2">
              <div><strong>Title:</strong> {selectedEvent.title}</div>
              <div><strong>Description:</strong> {selectedEvent.description}</div>
              <div><strong>Platform:</strong> {selectedEvent.platform}</div>
              <div><strong>Date:</strong> {new Date(selectedEvent.date).toLocaleDateString()}</div>
              <div><strong>Time:</strong> {selectedEvent.time}</div>
              <div><strong>Duration:</strong> {selectedEvent.duration} minutes</div>
              <div><strong>Meeting Link:</strong> <a className="text-blue-500" href={selectedEvent.meetingLink} target="_blank">{selectedEvent.meetingLink}</a></div>
            </div>
          ) : (
            <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-3">
              <Input placeholder="Title" {...form.register('title')} />
              <Textarea placeholder="Description" {...form.register('description')} />
              <select {...form.register('platform')} className="w-full border p-2 rounded">
                <option value="Zoom">Zoom</option>
                <option value="Google Meet">Google Meet</option>
              </select>
              <Input type="date" {...form.register('date')} />
              <Input type="time" {...form.register('time')} />
              <Input type="number" placeholder="Duration (min)" {...form.register('duration')} />
              <Input placeholder="Meeting Link" {...form.register('meetingLink')} />
              <Button type="submit" className="w-full">
                {viewMode === 'edit' ? 'Update Event' : 'Create Event'}
              </Button>
            </form>
          )}
        </DialogContent>
      </Dialog>
    </div>
  )
}
