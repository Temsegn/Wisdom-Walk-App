import { type NextRequest, NextResponse } from "next/server"

export async function GET(request: NextRequest) {
  const authHeader = request.headers.get("Authorization")
  
  if (!authHeader) {
    return NextResponse.json(
      { success: false, message: "Authorization header missing" },
      { status: 401 }
    )
  }

  try {
    const backendUrl = new URL("https://wisdom-walk-app.onrender.com/api/admin/notifications")
    
    // Forward query parameters
    request.nextUrl.searchParams.forEach((value, key) => {
      backendUrl.searchParams.append(key, value)
    })

    const response = await fetch(backendUrl.toString(), {
      headers: {
        Authorization: authHeader,
        "Content-Type": "application/json",
      },
      cache: "no-store",
    })

    if (!response.ok) {
      throw new Error(`Backend responded with ${response.status}`)
    }

    const data = await response.json()
    return NextResponse.json(data)

  } catch (error) {
    console.error("Notification fetch error:", error)
    return NextResponse.json(
      { success: false, message: "Failed to fetch notifications" },
      { status: 500 }
    )
  }
}