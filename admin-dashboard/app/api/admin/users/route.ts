import { type NextRequest, NextResponse } from "next/server"

/**
 * Proxies GET /api/admin/users?… to
 * https://wisdom-walk-app.onrender.com/api/admin/users?…
 */
export async function GET(request: NextRequest) {
  try {
    const qs = request.nextUrl.search // includes leading "?"
    const backendRes = await fetch(`https://wisdom-walk-app.onrender.com/api/admin/users${qs}`, {
      headers: {
        // forward the Authorization token if present
        Authorization: request.headers.get("authorization") ?? "",
      },
      cache: "no-store",
    })

    const data = await backendRes.json()
    return NextResponse.json(data, { status: backendRes.status })
  } catch (error) {
    console.error("Users proxy error:", error)
    return NextResponse.json({ success: false, message: "Unable to fetch users." }, { status: 502 })
  }
}
