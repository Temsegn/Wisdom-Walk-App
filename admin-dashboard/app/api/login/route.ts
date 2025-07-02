import { type NextRequest, NextResponse } from "next/server"

/**
 * Proxies the admin login request to the WisdomWalk backend.
 * Frontend 👉  POST /api/login  👉  Route Handler 👉  https://wisdom-walk-app.onrender.com/api/auth/login
 */
export async function POST(request: NextRequest) {
  try {
    const body = await request.json()
    const backendRes = await fetch("https://wisdom-walk-app.onrender.com/api/auth/login", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(body),
      // IMPORTANT: forward the client IP / cookies here if your backend needs them
    })

    const data = await backendRes.json()
    return NextResponse.json(data, { status: backendRes.status })
  } catch (error) {
    console.error("Login proxy error:", error)
    return NextResponse.json({ success: false, message: "Unable to reach authentication server." }, { status: 502 })
  }
}
