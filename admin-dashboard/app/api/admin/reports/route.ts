import { type NextRequest, NextResponse } from "next/server"

/**
 * GET /api/admin/reports
 * Proxies to https://wisdom-walk-app.onrender.com/api/admin/reports
 */
export async function GET(request: NextRequest) {
  try {
    const qs = request.nextUrl.search // includes leading "?"
    const backendRes = await fetch(`https://wisdom-walk-app.onrender.com/api/admin/reports${qs}`, {
      headers: { Authorization: request.headers.get("authorization") ?? "" },
      cache: "no-store",
    })

    const data = await backendRes.json()
    return NextResponse.json(data, { status: backendRes.status })
  } catch (error) {
    console.error("Reports proxy error:", error)
    return NextResponse.json({ success: false, message: "Unable to fetch reports." }, { status: 502 })
  }
}
