"use client"

import { useEffect, useState } from "react"
import { useForm } from "react-hook-form"
import { z } from "zod"
import { zodResolver } from "@hookform/resolvers/zod"
import {
  Card,
  CardContent,
} from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogFooter,
  DialogClose,
} from "@/components/ui/dialog"
import { Input } from "@/components/ui/input"
import { Textarea } from "@/components/ui/textarea"
import { useToast } from "@/components/ui/use-toast"
import { CalendarDays, Pencil, Trash2, Eye } from "lucide-react"

// Validation schema using Zod
const formSchema = z.object({
  title: z.string().min(1, "Title is required"),
  description: z.string().min(1, "Description is required"),
  platform: z.enum(["Zoom", "Google Meet"]),
  date: z.string().min(1, "Date is required"),
  time: z.string().min(1, "Time is required"),
  duration: z.string().min(1, "Duration is required"),
  meetingLink: z.string().url("Must be a valid URL"),
})

type FormData = z.infer<typeof formSchema>

type Event = {
  _id: string
  title: string
  description: string
  platform: "Zoom" | "Google Meet"
  date: string
  time: string
  duration: number
  meetingLink: string
}

function isFutureEvent(eventDate: string): boolean {
  const today = new Date()
  const eventDateTime = new Date(eventDate)
  return eventDateTime > today
}

export default function EventsPage() {
  const { toast } = useToast()
  const [events, setEvents] = useState<Event[]>([])
  const [loading, setLoading] = useState(true)
  const [selectedEvent, setSelectedEvent] = useState<Event | null>(null)
  const [viewMode, setViewMode] = useState<"create" | "edit" | "view">("create")
  const [dialogOpen, setDialogOpen] = useState(false)

  const form = useForm<FormData>({
    resolver: zodResolver(formSchema),
    defaultValues: {
      title: "",
      description: "",
      platform: "Zoom",
      date: "",
      time: "",
      duration: "",
      meetingLink: "",
    },
  })

  // Fetch all events on mount
  useEffect(() => {
    fetchEvents()
  }, [])

  async function fetchEvents() {
    setLoading(true)
    try {
      const res = await fetch("/api/events")
      const json = await res.json()

      if (!json.success) {
        throw new Error("Failed to fetch events")
      }

      setEvents(json.data)
    } catch (error) {
      toast({
        title: "Error",
        description: "Failed to load events.",
        variant: "destructive",
      })
    } finally {
      setLoading(false)
    }
  }

  function openCreate() {
    setViewMode("create")
    setSelectedEvent(null)
    form.reset()
    setDialogOpen(true)
  }

  function openEdit(event: Event) {
    setViewMode("edit")
    setSelectedEvent(event)
    form.reset({
      ...event,
      duration: event.duration.toString(),
      date: event.date.substring(0, 10), // format YYYY-MM-DD
    })
    setDialogOpen(true)
  }

  function openView(event: Event) {
    setViewMode("view")
    setSelectedEvent(event)
    setDialogOpen(true)
  }

  async function onSubmit(data: FormData) {
    try {
      const method = viewMode === "edit" ? "PUT" : "POST"
      const url =
        viewMode === "edit" && selectedEvent?._id
          ? `/api/events/${selectedEvent._id}`
          : "/api/events"

      const res = await fetch(url, {
        method,
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          ...data,
          duration: Number(data.duration),
        }),
      })

      if (!res.ok) throw new Error("Failed to save event")

      toast({
        title: "Success",
        description: `Event ${viewMode === "edit" ? "updated" : "created"} successfully.`,
      })

      form.reset()
      setDialogOpen(false)
      fetchEvents()
    } catch (error) {
      toast({
        title: "Error",
        description: "Failed to save event.",
        variant: "destructive",
      })
    }
  }

  async function handleDelete(id: string) {
    if (!confirm("Are you sure you want to delete this event?")) return

    try {
      const res = await fetch(`/api/events/${id}`, {
        method: "DELETE",
      })

      if (!res.ok) throw new Error("Failed to delete event")

      toast({
        title: "Deleted",
        description: "Event deleted successfully.",
      })
      fetchEvents()
    } catch (error) {
      toast({
        title: "Error",
        description: "Failed to delete event.",
        variant: "destructive",
      })
    }
  }

  return (
    <div className="container mx-auto py-10 px-4">
      <header className="flex justify-between items-center mb-8">
        <h1 className="text-3xl font-bold">📅 Admin Events</h1>
        <Button onClick={openCreate}>+ Create Event</Button>
      </header>

      <main className="space-y-4">
        {loading ? (
          <p>Loading events...</p>
        ) : events.length === 0 ? (
          <p className="text-center py-12 text-muted-foreground">No events available.</p>
        ) : (
          events.map((event) => (
            <Card
              key={event._id}
              className="shadow-sm border cursor-pointer hover:bg-slate-50 transition-all"
            >
              <CardContent className="p-5">
                <div className="flex items-start gap-4">
                  <CalendarDays className="h-5 w-5 text-purple-500 mt-1" />
                  <div className="flex-grow space-y-2">
                    <div className="flex justify-between">
                      <div className="flex items-center gap-2">
                        <h2 className="text-lg font-semibold text-gray-900">{event.title}</h2>
                        {isFutureEvent(event.date) && (
                          <span className="inline-flex items-center rounded-md bg-green-50 px-2 py-1 text-xs font-medium text-green-700 ring-1 ring-inset ring-green-600/20">
                            Upcoming
                          </span>
                        )}
                      </div>
                      <div className="flex gap-2">
                        <Button size="sm" variant="outline" onClick={() => openView(event)}>
                          <Eye className="h-4 w-4" />
                        </Button>
                        <Button size="sm" variant="outline" onClick={() => openEdit(event)}>
                          <Pencil className="h-4 w-4" />
                        </Button>
                        <Button
                          size="sm"
                          variant="destructive"
                          onClick={() => handleDelete(event._id)}
                        >
                          <Trash2 className="h-4 w-4" />
                        </Button>
                      </div>
                    </div>
                    <p className="text-sm text-gray-700 line-clamp-2">{event.description}</p>
                    <div className="text-xs text-muted-foreground pt-2">
                      📅 {new Date(event.date).toLocaleDateString()} @ {event.time} ({event.platform})
                    </div>
                  </div>
                </div>
              </CardContent>
            </Card>
          ))
        )}
      </main>

      <Dialog open={dialogOpen} onOpenChange={setDialogOpen}>
        <DialogContent className="max-w-xl">
          <DialogHeader>
            <DialogTitle> 
              {viewMode === "create"
                ? "Create Event"
                : viewMode === "edit"
                ? "Edit Event"
                : "Event Details"}
            </DialogTitle>
          </DialogHeader>

          {viewMode === "view" && selectedEvent ? (
            <div className="space-y-3 text-sm text-gray-800">
              <p>
                <strong>Title:</strong> {selectedEvent.title}
              </p>
              <p>
                <strong>Description:</strong> {selectedEvent.description}
              </p>
              <p>
                <strong>Platform:</strong> {selectedEvent.platform}
              </p>
              <p>
                <strong>Date:</strong> {new Date(selectedEvent.date).toLocaleDateString()}
              </p>
              <p>
                <strong>Time:</strong> {selectedEvent.time}
              </p>
              <p>
                <strong>Duration:</strong> {selectedEvent.duration} minutes
              </p>
              <p>
                <strong>Meeting Link:</strong>{" "}
                <a
                  href={selectedEvent.meetingLink}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="text-blue-500"
                >
                  {selectedEvent.meetingLink}
                </a>
              </p>
            </div>
          ) : (
            <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-3">
              <Input placeholder="Title" {...form.register("title")} />
              <Textarea placeholder="Description" {...form.register("description")} />
              <select {...form.register("platform")} className="w-full border p-2 rounded">
                <option value="Zoom">Zoom</option>
                <option value="Google Meet">Google Meet</option>
              </select>
              <Input type="date" {...form.register("date")} />
              <Input type="time" {...form.register("time")} />
              <Input type="number" placeholder="Duration (minutes)" {...form.register("duration")} />
              <Input placeholder="Meeting Link" {...form.register("meetingLink")} />
              <Button type="submit" className="w-full">
                {viewMode === "edit" ? "Update Event" : "Create Event"}
              </Button>
            </form>
          )}

          <DialogFooter className="mt-4">
            <DialogClose asChild>
              <Button variant="ghost">Close</Button>
            </DialogClose>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  )
}