import { type NextRequest, NextResponse } from "next/server"

/**
 * GET /api/posts/all
 * Proxies to https://wisdom-walk-app.onrender.com/api/posts (based on postRoutes.js)
 */
export async function GET(request: NextRequest) {
  try {
    const qs = request.nextUrl.search // includes leading "?"
    const backendRes = await fetch(`https://wisdom-walk-app.onrender.com/api/posts${qs}`, {
      headers: { Authorization: request.headers.get("authorization") ?? "" },
      cache: "no-store",
    })

    const data = await backendRes.json()
    return NextResponse.json(data, { status: backendRes.status })
  } catch (error) {
    console.error("Posts proxy error:", error)
    return NextResponse.json({ success: false, message: "Unable to fetch posts." }, { status: 502 })
  }
}
