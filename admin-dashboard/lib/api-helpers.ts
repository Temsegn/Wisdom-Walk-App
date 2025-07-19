import { type NextRequest, NextResponse } from "next/server"

// Shared helper functions
export function getAuthToken(request: NextRequest): string | null {
  return (
    request.headers.get("authorization") ??
    (request.cookies.get("adminToken") ? `Bearer ${request.cookies.get("adminToken")!.value}` : null)
  )
}

export function unauthorizedResponse(message: string = "Authorization token required") {
  return NextResponse.json(
    { success: false, message },
    { status: 401 }
  )
}

export function badRequestResponse(message: string) {
  return NextResponse.json(
    { success: false, message },
    { status: 400 }
  )
}

export function serverErrorResponse(message: string) {
  return NextResponse.json(
    { success: false, message },
    { status: 500 }
  )
}