import { type NextRequest, NextResponse } from "next/server"

export async function GET(request: NextRequest) {
  try {
    const token = request.headers.get("Authorization") || ""
    const backendUrl = `https://wisdom-walk-app.onrender.com/api/groups`

    const res = await fetch(backendUrl, {
      headers: { Authorization: token },
      cache: "no-store",
    })

    const data = await res.json()
    return NextResponse.json(data, { status: res.status })
  } catch (error) {
    console.error("Error fetching groups:", error)
    return NextResponse.json(
      { success: false, message: "Failed to fetch groups" },
      { status: 500 }
    )
  }
}

export async function POST(request: NextRequest) {
  try {
    const token = request.headers.get("Authorization") || "";
    if (!token) {
      return NextResponse.json(
        { success: false, message: "Authorization token required" },
        { status: 401 }
      );
    }

    const body = await request.json();
    
    // Add basic validation
    if (!body.name || !body.type) {
      return NextResponse.json(
        { success: false, message: "Group name and type are required" },
        { status: 400 }
      );
    }

    const backendUrl = `https://wisdom-walk-app.onrender.com/api/groups`;
    const res = await fetch(backendUrl, {
      method: "POST",
      headers: {
        Authorization: token,
        "Content-Type": "application/json",
      },
      body: JSON.stringify(body),
    });

    const data = await res.json();
    
    if (!res.ok) {
      return NextResponse.json(
        { success: false, message: data.message || "Failed to create group" },
        { status: res.status }
      );
    }

    return NextResponse.json(data, { status: res.status });
  } catch (error) {
    console.error("Error creating group:", error);
    return NextResponse.json(
      { 
        success: false, 
        message: error instanceof Error ? error.message : "Failed to create group" 
      },
      { status: 500 }
    );
  }
}