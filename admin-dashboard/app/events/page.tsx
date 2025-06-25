"use client"

import { useState } from "react"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { SidebarInset, SidebarTrigger } from "@/components/ui/sidebar"
import { Separator } from "@/components/ui/separator"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Badge } from "@/components/ui/badge"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog"
import { Label } from "@/components/ui/label"
import { Textarea } from "@/components/ui/textarea"
import { useToast } from "@/hooks/use-toast"
import { Calendar, Clock, MapPin, Users, Plus, Edit, Trash2, Eye } from "lucide-react"

interface Event {
  id: string
  title: string
  description: string
  date: string
  time: string
  location: string
  organizer: string
  capacity: number
  registered: number
  status: "upcoming" | "ongoing" | "completed" | "cancelled"
  category: string
}

const mockEvents: Event[] = [
  {
    id: "1",
    title: "Tech Conference 2024",
    description: "Annual technology conference featuring the latest innovations and trends in the tech industry.",
    date: "2024-03-15",
    time: "09:00",
    location: "Convention Center, Downtown",
    organizer: "Tech Community",
    capacity: 500,
    registered: 342,
    status: "upcoming",
    category: "Technology",
  },
  {
    id: "2",
    title: "Photography Workshop",
    description: "Learn advanced photography techniques from professional photographers.",
    date: "2024-02-20",
    time: "14:00",
    location: "Art Studio, Main Street",
    organizer: "Photo Club",
    capacity: 25,
    registered: 18,
    status: "upcoming",
    category: "Workshop",
  },
  {
    id: "3",
    title: "Community Meetup",
    description: "Monthly community gathering for networking and discussions.",
    date: "2024-01-25",
    time: "18:00",
    location: "Community Center",
    organizer: "Community Team",
    capacity: 100,
    registered: 87,
    status: "completed",
    category: "Community",
  },
  {
    id: "4",
    title: "Design Thinking Workshop",
    description: "Interactive workshop on design thinking methodologies and practices.",
    date: "2024-02-28",
    time: "10:00",
    location: "Innovation Hub",
    organizer: "Design Team",
    capacity: 30,
    registered: 22,
    status: "upcoming",
    category: "Design",
  },
  {
    id: "5",
    title: "Startup Pitch Night",
    description: "Evening event where startups present their ideas to investors and mentors.",
    date: "2024-03-05",
    time: "19:00",
    location: "Business Center",
    organizer: "Startup Incubator",
    capacity: 150,
    registered: 95,
    status: "upcoming",
    category: "Business",
  },
]

export default function EventsPage() {
  const [events, setEvents] = useState<Event[]>(mockEvents)
  const [isCreateDialogOpen, setIsCreateDialogOpen] = useState(false)
  const [isEditDialogOpen, setIsEditDialogOpen] = useState(false)
  const [isViewDialogOpen, setIsViewDialogOpen] = useState(false)
  const [isDeleteDialogOpen, setIsDeleteDialogOpen] = useState(false)
  const [selectedEvent, setSelectedEvent] = useState<Event | null>(null)
  const [newEvent, setNewEvent] = useState<Partial<Event>>({})
  const { toast } = useToast()

  const handleCreateEvent = () => {
    if (newEvent.title && newEvent.date && newEvent.time && newEvent.location) {
      const event: Event = {
        id: Date.now().toString(),
        title: newEvent.title,
        description: newEvent.description || "",
        date: newEvent.date,
        time: newEvent.time,
        location: newEvent.location,
        organizer: newEvent.organizer || "Admin",
        capacity: newEvent.capacity || 50,
        registered: 0,
        status: "upcoming",
        category: newEvent.category || "General",
      }
      setEvents([...events, event])
      setNewEvent({})
      setIsCreateDialogOpen(false)
      toast({
        title: "Event Created",
        description: "New event has been successfully created.",
      })
    }
  }

  const handleDeleteEvent = () => {
    if (selectedEvent) {
      setEvents(events.filter((event) => event.id !== selectedEvent.id))
      setIsDeleteDialogOpen(false)
      toast({
        title: "Event Deleted",
        description: "Event has been permanently deleted.",
        variant: "destructive",
      })
    }
  }

  const getStatusBadge = (status: string) => {
    switch (status) {
      case "upcoming":
        return <Badge className="bg-blue-100 text-blue-800 hover:bg-blue-100">Upcoming</Badge>
      case "ongoing":
        return <Badge className="bg-green-100 text-green-800 hover:bg-green-100">Ongoing</Badge>
      case "completed":
        return <Badge className="bg-gray-100 text-gray-800 hover:bg-gray-100">Completed</Badge>
      case "cancelled":
        return <Badge className="bg-red-100 text-red-800 hover:bg-red-100">Cancelled</Badge>
      default:
        return <Badge variant="outline">{status}</Badge>
    }
  }

  const getCapacityColor = (registered: number, capacity: number) => {
    const percentage = (registered / capacity) * 100
    if (percentage >= 90) return "text-red-600"
    if (percentage >= 70) return "text-orange-600"
    return "text-green-600"
  }

  return (
    <SidebarInset>
      <header className="flex h-16 shrink-0 items-center gap-2 border-b px-4">
        <SidebarTrigger className="-ml-1" />
        <Separator orientation="vertical" className="mr-2 h-4" />
        <h1 className="text-lg font-semibold">Event Management</h1>
      </header>

      <div className="flex-1 space-y-4 p-4 md:p-8 pt-6">
        <Card>
          <CardHeader>
            <div className="flex items-center justify-between">
              <div>
                <CardTitle>Event Management</CardTitle>
                <CardDescription>Create, manage, and track events and schedules</CardDescription>
              </div>
              <Button onClick={() => setIsCreateDialogOpen(true)}>
                <Plus className="h-4 w-4 mr-2" />
                Create Event
              </Button>
            </div>
          </CardHeader>
          <CardContent>
            {/* Events Table */}
            <div className="rounded-md border">
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Event</TableHead>
                    <TableHead>Date & Time</TableHead>
                    <TableHead>Location</TableHead>
                    <TableHead>Organizer</TableHead>
                    <TableHead>Capacity</TableHead>
                    <TableHead>Status</TableHead>
                    <TableHead>Actions</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {events.map((event) => (
                    <TableRow key={event.id}>
                      <TableCell>
                        <div>
                          <p className="font-medium">{event.title}</p>
                          <p className="text-sm text-muted-foreground truncate max-w-xs">{event.description}</p>
                          <Badge variant="outline" className="mt-1">
                            {event.category}
                          </Badge>
                        </div>
                      </TableCell>
                      <TableCell>
                        <div className="flex items-center space-x-2 text-sm">
                          <Calendar className="h-4 w-4 text-muted-foreground" />
                          <span>{new Date(event.date).toLocaleDateString()}</span>
                        </div>
                        <div className="flex items-center space-x-2 text-sm text-muted-foreground">
                          <Clock className="h-4 w-4" />
                          <span>{event.time}</span>
                        </div>
                      </TableCell>
                      <TableCell>
                        <div className="flex items-center space-x-2 text-sm">
                          <MapPin className="h-4 w-4 text-muted-foreground" />
                          <span>{event.location}</span>
                        </div>
                      </TableCell>
                      <TableCell>{event.organizer}</TableCell>
                      <TableCell>
                        <div className="flex items-center space-x-2">
                          <Users className="h-4 w-4 text-muted-foreground" />
                          <span className={getCapacityColor(event.registered, event.capacity)}>
                            {event.registered}/{event.capacity}
                          </span>
                        </div>
                        <div className="w-full bg-gray-200 rounded-full h-2 mt-1">
                          <div
                            className="bg-blue-600 h-2 rounded-full"
                            style={{ width: `${(event.registered / event.capacity) * 100}%` }}
                          ></div>
                        </div>
                      </TableCell>
                      <TableCell>{getStatusBadge(event.status)}</TableCell>
                      <TableCell>
                        <div className="flex items-center space-x-2">
                          <Button
                            variant="ghost"
                            size="sm"
                            onClick={() => {
                              setSelectedEvent(event)
                              setIsViewDialogOpen(true)
                            }}
                          >
                            <Eye className="h-4 w-4" />
                          </Button>
                          <Button
                            variant="ghost"
                            size="sm"
                            onClick={() => {
                              setSelectedEvent(event)
                              setNewEvent(event)
                              setIsEditDialogOpen(true)
                            }}
                          >
                            <Edit className="h-4 w-4" />
                          </Button>
                          <Button
                            variant="ghost"
                            size="sm"
                            onClick={() => {
                              setSelectedEvent(event)
                              setIsDeleteDialogOpen(true)
                            }}
                            className="text-red-600 hover:text-red-700"
                          >
                            <Trash2 className="h-4 w-4" />
                          </Button>
                        </div>
                      </TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            </div>
          </CardContent>
        </Card>

        {/* Create Event Dialog */}
        <Dialog open={isCreateDialogOpen} onOpenChange={setIsCreateDialogOpen}>
          <DialogContent className="max-w-2xl">
            <DialogHeader>
              <DialogTitle>Create New Event</DialogTitle>
              <DialogDescription>Fill in the details to create a new event</DialogDescription>
            </DialogHeader>
            <div className="grid grid-cols-2 gap-4">
              <div className="col-span-2">
                <Label htmlFor="title">Event Title</Label>
                <Input
                  id="title"
                  value={newEvent.title || ""}
                  onChange={(e) => setNewEvent({ ...newEvent, title: e.target.value })}
                  placeholder="Enter event title"
                />
              </div>
              <div className="col-span-2">
                <Label htmlFor="description">Description</Label>
                <Textarea
                  id="description"
                  value={newEvent.description || ""}
                  onChange={(e) => setNewEvent({ ...newEvent, description: e.target.value })}
                  placeholder="Enter event description"
                />
              </div>
              <div>
                <Label htmlFor="date">Date</Label>
                <Input
                  id="date"
                  type="date"
                  value={newEvent.date || ""}
                  onChange={(e) => setNewEvent({ ...newEvent, date: e.target.value })}
                />
              </div>
              <div>
                <Label htmlFor="time">Time</Label>
                <Input
                  id="time"
                  type="time"
                  value={newEvent.time || ""}
                  onChange={(e) => setNewEvent({ ...newEvent, time: e.target.value })}
                />
              </div>
              <div>
                <Label htmlFor="location">Location</Label>
                <Input
                  id="location"
                  value={newEvent.location || ""}
                  onChange={(e) => setNewEvent({ ...newEvent, location: e.target.value })}
                  placeholder="Enter location"
                />
              </div>
              <div>
                <Label htmlFor="organizer">Organizer</Label>
                <Input
                  id="organizer"
                  value={newEvent.organizer || ""}
                  onChange={(e) => setNewEvent({ ...newEvent, organizer: e.target.value })}
                  placeholder="Enter organizer name"
                />
              </div>
              <div>
                <Label htmlFor="capacity">Capacity</Label>
                <Input
                  id="capacity"
                  type="number"
                  value={newEvent.capacity || ""}
                  onChange={(e) => setNewEvent({ ...newEvent, capacity: Number.parseInt(e.target.value) })}
                  placeholder="Enter capacity"
                />
              </div>
              <div>
                <Label htmlFor="category">Category</Label>
                <Input
                  id="category"
                  value={newEvent.category || ""}
                  onChange={(e) => setNewEvent({ ...newEvent, category: e.target.value })}
                  placeholder="Enter category"
                />
              </div>
            </div>
            <DialogFooter>
              <Button variant="outline" onClick={() => setIsCreateDialogOpen(false)}>
                Cancel
              </Button>
              <Button onClick={handleCreateEvent}>Create Event</Button>
            </DialogFooter>
          </DialogContent>
        </Dialog>

        {/* View Event Dialog */}
        <Dialog open={isViewDialogOpen} onOpenChange={setIsViewDialogOpen}>
          <DialogContent className="max-w-2xl">
            <DialogHeader>
              <DialogTitle>Event Details</DialogTitle>
              <DialogDescription>View complete event information</DialogDescription>
            </DialogHeader>
            {selectedEvent && (
              <div className="space-y-4">
                <div>
                  <h3 className="text-lg font-semibold">{selectedEvent.title}</h3>
                  <Badge variant="outline" className="mt-1">
                    {selectedEvent.category}
                  </Badge>
                </div>
                <div>
                  <p className="text-sm text-muted-foreground">{selectedEvent.description}</p>
                </div>
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <Label>Date & Time</Label>
                    <div className="flex items-center space-x-2 mt-1">
                      <Calendar className="h-4 w-4 text-muted-foreground" />
                      <span className="text-sm">{new Date(selectedEvent.date).toLocaleDateString()}</span>
                      <Clock className="h-4 w-4 text-muted-foreground ml-2" />
                      <span className="text-sm">{selectedEvent.time}</span>
                    </div>
                  </div>
                  <div>
                    <Label>Location</Label>
                    <div className="flex items-center space-x-2 mt-1">
                      <MapPin className="h-4 w-4 text-muted-foreground" />
                      <span className="text-sm">{selectedEvent.location}</span>
                    </div>
                  </div>
                  <div>
                    <Label>Organizer</Label>
                    <p className="text-sm mt-1">{selectedEvent.organizer}</p>
                  </div>
                  <div>
                    <Label>Registration</Label>
                    <div className="flex items-center space-x-2 mt-1">
                      <Users className="h-4 w-4 text-muted-foreground" />
                      <span className="text-sm">
                        {selectedEvent.registered}/{selectedEvent.capacity}
                      </span>
                    </div>
                  </div>
                  <div>
                    <Label>Status</Label>
                    <div className="mt-1">{getStatusBadge(selectedEvent.status)}</div>
                  </div>
                </div>
              </div>
            )}
          </DialogContent>
        </Dialog>

        {/* Delete Event Dialog */}
        <Dialog open={isDeleteDialogOpen} onOpenChange={setIsDeleteDialogOpen}>
          <DialogContent>
            <DialogHeader>
              <DialogTitle>Delete Event</DialogTitle>
              <DialogDescription>
                Are you sure you want to permanently delete this event? This action cannot be undone.
              </DialogDescription>
            </DialogHeader>
            <DialogFooter>
              <Button variant="outline" onClick={() => setIsDeleteDialogOpen(false)}>
                Cancel
              </Button>
              <Button variant="destructive" onClick={handleDeleteEvent}>
                Delete Event
              </Button>
            </DialogFooter>
          </DialogContent>
        </Dialog>
      </div>
    </SidebarInset>
  )
}
