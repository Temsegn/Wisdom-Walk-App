import { type NextRequest, NextResponse } from "next/server"

export async function GET(
  request: NextRequest,
  { params }: { params: { groupId: string } }
) {
  try {
    const token = request.headers.get("Authorization") || ""
    const backendUrl = `https://wisdom-walk-app.onrender.com/api/groups/${params.groupId}/members`

    const res = await fetch(backendUrl, {
      headers: { Authorization: token },
      cache: "no-store",
    })

    const data = await res.json()
    return NextResponse.json(data, { status: res.status })
  } catch (error) {
    console.error("Error fetching group members:", error)
    return NextResponse.json(
      { success: false, message: "Failed to fetch group members" },
      { status: 500 }
    )
  }
}

export async function POST(
  request: NextRequest,
  { params }: { params: { groupId: string } }
) {
  try {
    const token = request.headers.get("Authorization") || ""
    const body = await request.json()
    const backendUrl = `https://wisdom-walk-app.onrender.com/api/groups/${params.groupId}/members`

    const res = await fetch(backendUrl, {
      method: "POST",
      headers: {
        Authorization: token,
        "Content-Type": "application/json",
      },
      body: JSON.stringify(body),
    })

    const data = await res.json()
    return NextResponse.json(data, { status: res.status })
  } catch (error) {
    console.error("Error adding group member:", error)
    return NextResponse.json(
      { success: false, message: "Failed to add group member" },
      { status: 500 }
    )
  }
}