import { type NextRequest, NextResponse } from 'next/server'

const BACKEND_URL = 'https://wisdom-walk-app.onrender.com/api/events'

export async function GET() {
  try {
    const res = await fetch(BACKEND_URL, {
      method: 'GET',
      headers: { 'Content-Type': 'application/json' },
    })
    const data = await res.json()
    return NextResponse.json(data, { status: res.status })
  } catch (error) {
    console.error('Error fetching events:', error)
    return NextResponse.json({ success: false, message: 'Failed to fetch events' }, { status: 502 })
  }
}

export async function POST(request: NextRequest) {
  try {
    const body = await request.json()
    const res = await fetch(BACKEND_URL, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(body),
    })
    const data = await res.json()
    return NextResponse.json(data, { status: res.status })
  } catch (error) {
    console.error('Error creating event:', error)
    return NextResponse.json({ success: false, message: 'Failed to create event' }, { status: 502 })
  }
}
