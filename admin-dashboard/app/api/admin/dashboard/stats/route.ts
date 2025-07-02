import { type NextRequest, NextResponse } from "next/server"

/**
 * GET /api/admin/dashboard/stats  ⟶  https://wisdom-walk-app.onrender.com/api/admin/dashboard/stats
 */
export async function GET(request: NextRequest) {
  try {
    const token = request.headers.get("authorization") ?? ""

    const backendRes = await fetch("https://wisdom-walk-app.onrender.com/api/admin/dashboard/stats", {
      headers: {
        Authorization: token,
      },
      cache: "no-store",
    })

    const data = await backendRes.json()
    return NextResponse.json(data, { status: backendRes.status })
  } catch (error) {
    console.error("dashboard-stats proxy error:", error)
    return NextResponse.json({ success: false, message: "Unable to fetch dashboard stats." }, { status: 502 })
  }
}
