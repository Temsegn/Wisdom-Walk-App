import { type NextRequest, NextResponse } from "next/server"

/**
 * POST /api/admin/users/[userId]/toggle-block
 * Proxies to https://wisdom-walk-app.onrender.com/api/admin/users/[userId]/block
 */
export async function POST(request: NextRequest, { params }: { params: { userId: string } }) {
  try {
    const body = await request.json()
    const backendRes = await fetch(`https://wisdom-walk-app.onrender.com/api/admin/users/${params.userId}/block`, {
      method: "POST",
      headers: {
        Authorization: request.headers.get("authorization") ?? "",
        "Content-Type": "application/json",
      },
      body: JSON.stringify(body),
    })

    const data = await backendRes.json()
    return NextResponse.json(data, { status: backendRes.status })
  } catch (error) {
    console.error("Toggle-block proxy error:", error)
    return NextResponse.json({ success: false, message: "Unable to toggle user block." }, { status: 502 })
  }
}
