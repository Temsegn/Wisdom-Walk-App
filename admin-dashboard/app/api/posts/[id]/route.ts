// app/api/posts/[id]/route.ts
import { type NextRequest, NextResponse } from "next/server"

export async function GET(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const token = request.headers.get("Authorization") || ""
    const backendUrl = `https://wisdom-walk-app.onrender.com/api/posts/${params.id}`

    const res = await fetch(backendUrl, {
      headers: { Authorization: token },
      cache: "no-store",
    })

    const data = await res.json()
    return NextResponse.json(data, { status: res.status })
  } catch (error) {
    console.error("Error fetching post:", error)
    return NextResponse.json(
      { success: false, message: "Failed to fetch post" },
      { status: 500 }
    )
  }
}

export async function DELETE(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const token = request.headers.get("Authorization") || ""
    const backendUrl = `https://wisdom-walk-app.onrender.com/api/posts/${params.id}`

    const res = await fetch(backendUrl, {
      method: "DELETE",
      headers: { Authorization: token },
    })

    const data = await res.json()
    return NextResponse.json(data, { status: res.status })
  } catch (error) {
    console.error("Error deleting post:", error)
    return NextResponse.json(
      { success: false, message: "Failed to delete post" },
      { status: 500 }
    )
  }
}

export async function PUT(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const token = request.headers.get("Authorization") || ""
    const body = await request.json()
    const backendUrl = `https://wisdom-walk-app.onrender.com/api/posts/${params.id}`

    const res = await fetch(backendUrl, {
      method: "PUT",
      headers: {
        Authorization: token,
        "Content-Type": "application/json",
      },
      body: JSON.stringify(body),
    })

    const data = await res.json()
    return NextResponse.json(data, { status: res.status })
  } catch (error) {
    console.error("Error updating post:", error)
    return NextResponse.json(
      { success: false, message: "Failed to update post" },
      { status: 500 }
    )
  }
}