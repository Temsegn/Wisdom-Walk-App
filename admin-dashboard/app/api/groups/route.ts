import { type NextRequest, NextResponse } from "next/server"

/**
 * Handles all group-related requests
 */
import { type NextRequest, NextResponse } from "next/server"

export async function GET(request: NextRequest) {
  try {
    // Extract token from Authorization header
    const authHeader = request.headers.get('authorization');
    if (!authHeader) {
      return NextResponse.json(
        { error: 'Authorization header required' },
        { status: 401 }
      );
    }

    // Forward request to backend API
    const backendUrl = `https://wisdom-walk-app.onrender.com/api/groups${request.nextUrl.search}`;
    const response = await fetch(backendUrl, {
      headers: {
        'Authorization': authHeader,
        'Content-Type': 'application/json'
      },
      cache: 'no-store'
    });

    // Handle unauthorized responses
    if (response.status === 401) {
      return NextResponse.json(
        { error: 'Unauthorized - Invalid or expired token' },
        { status: 401 }
      );
    }

    // Return the backend response
    const data = await response.json();
    return NextResponse.json(data, { status: response.status });

  } catch (error) {
    console.error('Groups API Error:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
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
    const backendUrl = `https://wisdom-walk-app.onrender.com/api/groups`
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