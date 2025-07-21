import { type NextRequest, NextResponse } from "next/server"

export async function DELETE(
  request: NextRequest,
  { params }: { params: { groupId: string; memberId: string } }
) {
  try {
    const token = request.headers.get("Authorization") || ""
    const backendUrl = `https://wisdom-walk-app.onrender.com/api/groups/${params.groupId}/members/${params.memberId}`

    const res = await fetch(backendUrl, {
      method: "DELETE",
      headers: { Authorization: token },
    })

    const data = await res.json()
    return NextResponse.json(data, { status: res.status })
  } catch (error) {
    console.error("Error removing group member:", error)
    return NextResponse.json(
      { success: false, message: "Failed to remove group member" },
      { status: 500 }
    )
  }
}

export async function PUT(
  request: NextRequest,
  { params }: { params: { groupId: string; memberId: string } }
) {
  try {
    const token = request.headers.get("Authorization") || ""
    const body = await request.json()
    const backendUrl = `https://wisdom-walk-app.onrender.com/api/groups/${params.groupId}/members/${params.memberId}`

    const res = await fetch(backendUrl, {
      method: "PUT",
      headers: {
        Authorization: token,
        "Content-Type": "application/json",
      },
      body: JSON.stringify(body),
    })

    const data = await res.json()
    return NextResponse.json(data, { status: res.status })
  } catch (error) {
    console.error("Error updating group member:", error)
    return NextResponse.json(
      { success: false, message: "Failed to update group member" },
      { status: 500 }
    )
  }
}