import { type NextRequest, NextResponse } from "next/server"

export async function GET(
  request: NextRequest,
  { params }: { params: { groupId: string } }
) {
  try {
    const token = request.headers.get("Authorization") || ""
    const backendUrl = `https://wisdom-walk-app.onrender.com/api/groups/${params.groupId}/settings`

    const res = await fetch(backendUrl, {
      headers: { Authorization: token },
      cache: "no-store",
    })

    const data = await res.json()
    return NextResponse.json(data, { status: res.status })
  } catch (error) {
    console.error("Error fetching group settings:", error)
    return NextResponse.json(
      { success: false, message: "Failed to fetch group settings" },
      { status: 500 }
    )
  }
}

export async function PATCH(
  request: NextRequest,
  { params }: { params: { groupId: string } }
) {
  try {
    const token = request.headers.get("Authorization") || ""
    const body = await request.json()
    const backendUrl = `https://wisdom-walk-app.onrender.com/api/groups/${params.groupId}/settings`

    const res = await fetch(backendUrl, {
      method: "PATCH",
      headers: {
        Authorization: token,
        "Content-Type": "application/json",
      },
      body: JSON.stringify(body),
    })

    const data = await res.json()
    return NextResponse.json(data, { status: res.status })
  } catch (error) {
    console.error("Error updating group settings:", error)
    return NextResponse.json(
      { success: false, message: "Failed to update group settings" },
      { status: 500 }
    )
  }
}