import { type NextRequest, NextResponse } from "next/server"

export async function PUT(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  const authHeader = request.headers.get("Authorization")
  
  if (!authHeader) {
    return NextResponse.json(
      { success: false, message: "Authorization header missing" },
      { status: 401 }
    )
  }

  try {
    // Verify the backend URL structure with your backend team
    const backendUrl = `https://wisdom-walk-app.onrender.com/api/admin/notifications/${params.id}/read`

    console.log('Making request to:', backendUrl) // Debug log

    const response = await fetch(backendUrl, {
      method: "PUT",
      headers: {
        Authorization: authHeader,
        "Content-Type": "application/json",
      },
    })

    console.log('Backend response status:', response.status) // Debug log

    if (!response.ok) {
      // Include more details in the error
      const errorData = await response.json().catch(() => ({}))
      throw new Error(
        `Backend responded with ${response.status}: ${JSON.stringify(errorData)}`
      )
    }

    const data = await response.json()
    return NextResponse.json(data)

  } catch (error) {
    console.error("Mark as read error:", error)
    return NextResponse.json(
      { 
        success: false, 
        message: "Failed to mark notification as read",
        error: error instanceof Error ? error.message : String(error)
      },
      { status: 500 }
    )
  }
}