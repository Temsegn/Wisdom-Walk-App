import { type NextRequest, NextResponse } from 'next/server'

const BASE_URL = 'https://wisdom-walk-app.onrender.com/api/events'

export async function GET(_: NextRequest, { params }: { params: { id: string } }) {
  try {
    const res = await fetch(`${BASE_URL}/${params.id}`, {
      method: 'GET',
      headers: { 'Content-Type': 'application/json' },
    })

    const data = await res.json()
    return NextResponse.json(data, { status: res.status })
  } catch (error) {
    console.error('Error fetching single event:', error)
    return NextResponse.json({ success: false, message: 'Failed to fetch event' }, { status: 502 })
  }
}

export async function PUT(request: NextRequest, { params }: { params: { id: string } }) {
  try {
      const awaitedParams = await params;

    const body = await request.json()
    const res = await fetch(`${BASE_URL}/${awaitedParams.id}`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(body),
    })

    const data = await res.json()
    return NextResponse.json(data, { status: res.status })
  } catch (error) {
    console.error('Error updating event:', error)
    return NextResponse.json({ success: false, message: 'Failed to update event' }, { status: 502 })
  }
}

export async function DELETE(_: NextRequest, { params }: { params: { id: string } }) {
  try {
          const awaitedParams = await params;

    const res = await fetch(`${BASE_URL}/${awaitedParams.id}`, {
      method: 'DELETE',
      headers: { 'Content-Type': 'application/json' },
    })

    const data = await res.json()
    return NextResponse.json(data, { status: res.status })
  } catch (error) {
    console.error('Error deleting event:', error)
    return NextResponse.json({ success: false, message: 'Failed to delete event' }, { status: 502 })
  }
}
