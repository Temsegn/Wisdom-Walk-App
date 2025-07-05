import { type NextRequest, NextResponse } from "next/server"

/**
 * GET /api/admin/notifications
 * Proxies to https://wisdom-walk-app.onrender.com/api/admin/notifications
 */
export async function GET(request: NextRequest) {
  try {
    const queryString = request.nextUrl.search // includes leading "?" if present
    const backendUrl = `https://wisdom-walk-app.onrender.com/api/admin/notifications`

    const backendRes = await fetch(backendUrl, {
      headers: {
        Authorization: request.headers.get("authorization") ?? "",
      },
      cache: "no-store",
    })

    const data = await backendRes.json()

    return NextResponse.json(data, {
      status: backendRes.status,
    })
  } catch (error) {
    console.error("Notifications proxy error:", error)
    return NextResponse.json(
      { success: false, message: "Unable to fetch notifications." },
      { status: 502 }
    )
  }
}
