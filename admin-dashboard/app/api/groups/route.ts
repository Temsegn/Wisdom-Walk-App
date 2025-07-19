import { type NextRequest, NextResponse } from "next/server";

export async function GET(request: NextRequest) {
  try {
    const authHeader = request.headers.get('authorization');
    if (!authHeader) {
      return NextResponse.json(
        { success: false, message: "Authorization required", groups: [] },
        { status: 401 }
      );
    }

    const backendResponse = await fetch(`https://wisdom-walk-app.onrender.com/api/groups`, {
      headers: {
        'Authorization': authHeader,
        'Content-Type': 'application/json'
      },
      cache: 'no-store'
    });

    const data = await backendResponse.json();

    // Ensure consistent response format
    if (!backendResponse.ok) {
      return NextResponse.json(
        { 
          success: false,
          message: data.message || "Failed to fetch groups",
          groups: []
        },
        { status: backendResponse.status }
      );
    }

    return NextResponse.json({
      success: true,
      groups: data.groups || data || [] // Handle both response formats
    });

  } catch (error) {
    console.error('Groups API Error:', error);
    return NextResponse.json(
      { success: false, message: "Internal server error", groups: [] },
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
 