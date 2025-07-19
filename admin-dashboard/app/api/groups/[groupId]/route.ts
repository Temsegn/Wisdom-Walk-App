import { type NextRequest, NextResponse } from "next/server"

export async function GET(
  request: NextRequest,
  { params }: { params: { groupId: string } }
) {
  try {
    const token = request.headers.get("Authorization") || ""
    const backendUrl = `https://wisdom-walk-app.onrender.com/api/groups/${params.groupId}`

    const res = await fetch(backendUrl, {
      headers: { Authorization: token },
      cache: "no-store",
    })

    const data = await res.json()
    return NextResponse.json(data, { status: res.status })
  } catch (error) {
    console.error("Error fetching group:", error)
    return NextResponse.json(
      { success: false, message: "Failed to fetch group" },
      { status: 500 }
    )
  }
}

export async function PUT(
  request: NextRequest,
  { params }: { params: { groupId: string } }
) {
  try {
    const token = request.headers.get("Authorization") || ""
    const body = await request.json()
    const backendUrl = `https://wisdom-walk-app.onrender.com/api/groups/${params.groupId}`

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
    console.error("Error updating group:", error)
    return NextResponse.json(
      { success: false, message: "Failed to update group" },
      { status: 500 }
    )
  }
}

export async function DELETE(
  request: NextRequest,
  { params }: { params: { groupId: string } }
) {
  try {
    const token = request.headers.get("Authorization") || ""
    const backendUrl = `https://wisdom-walk-app.onrender.com/api/groups/${params.groupId}`

    const res = await fetch(backendUrl, {
      method: "DELETE",
      headers: { Authorization: token },
    })

    const data = await res.json()
    return NextResponse.json(data, { status: res.status })
  } catch (error) {
    console.error("Error deleting group:", error)
    return NextResponse.json(
      { success: false, message: "Failed to delete group" },
      { status: 500 }
    )
  }
}