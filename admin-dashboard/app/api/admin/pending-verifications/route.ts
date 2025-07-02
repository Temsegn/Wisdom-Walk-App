import { type NextRequest, NextResponse } from "next/server"

/**
 * GET /api/admin/pending-verifications
 * Proxies to https://wisdom-walk-app.onrender.com/api/admin/verifications/pending
 */
export async function GET(request: NextRequest) {
  try {
    const qs = request.nextUrl.search // includes leading "?"
    const backendRes = await fetch(`https://wisdom-walk-app.onrender.com/api/admin/verifications/pending${qs}`, {
      headers: { Authorization: request.headers.get("authorization") ?? "" },
      cache: "no-store",
    })

    const data = await backendRes.json()
    return NextResponse.json(data, { status: backendRes.status })
  } catch (error) {
    console.error("Pending-verifications proxy error:", error)
    return NextResponse.json({ success: false, message: "Unable to fetch pending verifications." }, { status: 502 })
  }
}
