import { type NextRequest, NextResponse } from "next/server"

/**
 * DELETE /api/posts/[postId]
 * Proxies to https://wisdom-walk-app.onrender.com/api/posts/[postId]
 */
export async function DELETE(request: NextRequest, { params }: { params: { postId: string } }) {
  try {
    const backendRes = await fetch(`https://wisdom-walk-app.onrender.com/api/posts/${params.postId}`, {
      method: "DELETE",
      headers: { Authorization: request.headers.get("authorization") ?? "" },
    })

    const data = await backendRes.json()
    return NextResponse.json(data, { status: backendRes.status })
  } catch (error) {
    console.error("Delete-post proxy error:", error)
    return NextResponse.json({ success: false, message: "Unable to delete post." }, { status: 502 })
  }
}
