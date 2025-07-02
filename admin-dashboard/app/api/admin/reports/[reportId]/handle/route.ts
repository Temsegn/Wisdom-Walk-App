import { type NextRequest, NextResponse } from "next/server"

/**
 * POST /api/admin/reports/[reportId]/handle
 * Proxies to https://wisdom-walk-app.onrender.com/api/admin/reports/[reportId]/handle
 */
export async function POST(request: NextRequest, { params }: { params: { reportId: string } }) {
  try {
    const body = await request.json()
    const backendRes = await fetch(`https://wisdom-walk-app.onrender.com/api/admin/reports/${params.reportId}/handle`, {
      method: "POST",
      headers: {
        Authorization: request.headers.get("authorization") ?? "",
        "Content-Type": "application/json",
      },
      body: JSON.stringify(body),
    })

    const data = await backendRes.json()
    return NextResponse.json(data, { status: backendRes.status })
  } catch (error) {
    console.error("Handle-report proxy error:", error)
    return NextResponse.json({ success: false, message: "Unable to handle report." }, { status: 502 })
  }
}
