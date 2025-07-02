import { type NextRequest, NextResponse } from "next/server"

/**
 * Proxies GET /api/admin/users?… to
 * https://wisdom-walk-app.onrender.com/api/admin/users?…
 */
export async function GET(request: NextRequest) {
  try {
    const qs = request.nextUrl.search // includes leading "?"

    // Grab token from header OR cookie
    const bearer =
      request.headers.get("authorization") ??
      (request.cookies.get("adminToken") ? `Bearer ${request.cookies.get("adminToken")!.value}` : "")

    const backendRes = await fetch(`https://wisdom-walk-app.onrender.com/api/admin/users${qs}`, {
      headers: { Authorization: bearer },
      cache: "no-store",
    })

    const data = await backendRes.json()
    return NextResponse.json(data, { status: backendRes.status })
  } catch (error) {
    console.error("Users proxy error:", error)
    return NextResponse.json({ success: false, message: "Unable to fetch users." }, { status: 502 })
  }
}
