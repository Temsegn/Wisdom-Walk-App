import { type NextRequest, NextResponse } from "next/server"

/**
 * Handles all group-related requests
 */
export async function GET(request: NextRequest) {
  try {
    // Get token from either Authorization header or cookie
    const token = getAuthToken(request)
    if (!token) {
      return unauthorizedResponse()
    }

    const qs = request.nextUrl.search // includes leading "?"
    const backendUrl = `https://wisdom-walk-app.onrender.com/api/groups${qs}`

    const res = await fetch(backendUrl, {
      headers: { 
        Authorization: token,
        'Content-Type': 'application/json'
      },
      cache: "no-store",
    })

    // Handle unauthorized (401) responses
    if (res.status === 401) {
      return unauthorizedResponse('Session expired, please login again')
    }

    const data = await res.json()
    return NextResponse.json(data, { status: res.status })
  } catch (error) {
    console.error("Error fetching groups:", error)
    return serverErrorResponse("Failed to fetch groups")
  }
}
 

export async function POST(request: Request) {
  try {
    // Get token from headers
    const authHeader = request.headers.get('authorization')
    if (!authHeader) {
      return NextResponse.json(
        { success: false, message: "Authorization header missing" },
        { status: 401 }
      )
    }

    // Forward to backend
    const backendUrl = `${process.env.BACKEND_URL || 'https://wisdom-walk-app.onrender.com'}/api/groups`
    const body = await request.json()
    
    const res = await fetch(backendUrl, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': authHeader
      },
      body: JSON.stringify(body)
    })

    // Handle backend errors
    if (!res.ok) {
      const errorData = await res.json()
      return NextResponse.json(
        { success: false, ...errorData },
        { status: res.status }
      )
    }

    return NextResponse.json(await res.json())
  } catch (error) {
    console.error('Group creation error:', error)
    return NextResponse.json(
      { success: false, message: "Unable to connect to backend service" },
      { status: 502 }
    )
  }
}
// Helper functions
function getAuthToken(request: NextRequest): string | null {
  return (
    request.headers.get("authorization") ??
    (request.cookies.get("adminToken") ? `Bearer ${request.cookies.get("adminToken")!.value}` : null)
  )
}

function unauthorizedResponse(message: string = "Authorization token required") {
  return NextResponse.json(
    { success: false, message },
    { status: 401 }
  )
}

function badRequestResponse(message: string) {
  return NextResponse.json(
    { success: false, message },
    { status: 400 }
  )
}

function serverErrorResponse(message: string) {
  return NextResponse.json(
    { success: false, message },
    { status: 500 }
  )
}