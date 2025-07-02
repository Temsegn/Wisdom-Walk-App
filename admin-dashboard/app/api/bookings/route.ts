import { type NextRequest, NextResponse } from "next/server"

/**
 * GET /api/bookings
 * Proxies to https://wisdom-walk-app.onrender.com/api/bookings (based on bookingRoute.js)
 */
export async function GET(request: NextRequest) {
  try {
    const backendRes = await fetch("https://wisdom-walk-app.onrender.com/api/bookings/bookings", {
      headers: { Authorization: request.headers.get("authorization") ?? "" },
      cache: "no-store",
    })

    const data = await backendRes.json()
    return NextResponse.json(data, { status: backendRes.status })
  } catch (error) {
    console.error("Bookings proxy error:", error)
    return NextResponse.json({ success: false, message: "Unable to fetch bookings." }, { status: 502 })
  }
}
