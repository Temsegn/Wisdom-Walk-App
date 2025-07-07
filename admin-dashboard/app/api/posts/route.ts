// app/api/posts/route.ts
import { type NextRequest, NextResponse } from "next/server"

export async function GET(request: NextRequest) {
  try {
    const token = request.headers.get("Authorization") || ""
    const backendUrl = `https://wisdom-walk-app.onrender.com/api/posts/posts`

    const res = await fetch(backendUrl, {
      headers: { Authorization: token },
      cache: "no-store",
    })

    const data = await res.json()
    return NextResponse.json(data, { status: res.status })
  } catch (error) {
    console.error("Error fetching posts:", error)
    return NextResponse.json(
      { success: false, message: "Failed to fetch posts" },
      { status: 500 }
    )
  }
}