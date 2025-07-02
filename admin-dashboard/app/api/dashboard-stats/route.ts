import { type NextRequest, NextResponse } from "next/server"

/**
 * GET /api/dashboard-stats
 * Proxies to https://wisdom-walk-app.onrender.com/api/admin/dashboard/stats
 */
export async function GET(request: NextRequest) {
  try {
    const backendRes = await fetch("https://wisdom-walk-app.onrender.com/api/admin/dashboard/stats", {
      headers: { Authorization: request.headers.get("authorization") ?? "" },
      cache: "no-store",
    })

    const data = await backendRes.json()
    return NextResponse.json(data, { status: backendRes.status })
  } catch (error) {
    console.error("Dashboard-stats proxy error:", error)
    return NextResponse.json({ success: false, message: "Unable to fetch dashboard stats." }, { status: 502 })
  }
}
