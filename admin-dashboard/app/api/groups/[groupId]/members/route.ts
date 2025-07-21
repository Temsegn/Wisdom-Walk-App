import { NextRequest, NextResponse } from 'next/server';

export async function GET(request: NextRequest, { params }: { params: Promise<{ groupId: string }> }) {
  try {
    const authHeader = request.headers.get('authorization');
    if (!authHeader) {
      return NextResponse.json(
        { success: false, message: 'Authorization header missing' },
        { status: 401 }
      );
    }

    const { groupId } = await params;

    if (!groupId || groupId === 'undefined') {
      return NextResponse.json(
        { success: false, message: 'Invalid group ID' },
        { status: 400 }
      );
    }

    const backendUrl = `https://wisdom-walk-app.onrender.com/api/groups/${groupId}/members`;
    const res = await fetch(backendUrl, {
      method: 'GET',
      headers: {
        'Authorization': authHeader,
        'Content-Type': 'application/json'
      },
      cache: 'no-store',
    });

    const data = await res.json();

    if (!res.ok) {
      return NextResponse.json(
        { success: false, message: data.message || 'Failed to fetch group members' },
        { status: res.status }
      );
    }

    return NextResponse.json(data, { status: 200 });
  } catch (error) {
    console.error('Error fetching group members:', error);
    return NextResponse.json(
      { success: false, message: 'Internal server error' },
      { status: 500 }
    );
  }
}

export async function POST(request: NextRequest, { params }: { params: Promise<{ groupId: string }> }) {
  try {
    const authHeader = request.headers.get('authorization');
    if (!authHeader) {
      return NextResponse.json(
        { success: false, message: 'Authorization header missing' },
        { status: 401 }
      );
    }

    const { groupId } = await params;

    if (!groupId || groupId === 'undefined') {
      return NextResponse.json(
        { success: false, message: 'Invalid group ID' },
        { status: 400 }
      );
    }

    const body = await request.json();

    const backendUrl = `https://wisdom-walk-app.onrender.com/api/groups/${groupId}/members`;
    const res = await fetch(backendUrl, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': authHeader
      },
      body: JSON.stringify(body),
    });

    const data = await res.json();

    if (!res.ok) {
      return NextResponse.json(
        { success: false, message: data.message || 'Failed to add group member' },
        { status: res.status }
      );
    }

    return NextResponse.json(data, { status: 200 });
  } catch (error) {
    console.error('Error adding group member:', error);
    return NextResponse.json(
      { success: false, message: 'Internal server error' },
      { status: 500 }
    );
  }
}

export async function DELETE(request: NextRequest, { params }: { params: Promise<{ groupId: string; memberId: string }> }) {
  try {
    const authHeader = request.headers.get('authorization');
    if (!authHeader) {
      return NextResponse.json(
        { success: false, message: 'Authorization header missing' },
        { status: 401 }
      );
    }

    const { groupId, memberId } = await params;

    if (!groupId || groupId === 'undefined' || !memberId) {
      return NextResponse.json(
        { success: false, message: 'Invalid group or member ID' },
        { status: 400 }
      );
    }

    const backendUrl = `https://wisdom-walk-app.onrender.com/api/parties/${groupId}/members/${memberId}`;
    const res = await fetch(backendUrl, {
      method: 'DELETE',
      headers: {
        'Authorization': authHeader
      },
    });

    const data = await res.json();

    if (!res.ok) {
      return NextResponse.json(
        { success: false, message: data.message || 'Failed to remove group member' },
        { status: res.status }
      );
    }

    return NextResponse.json(data, { status: 200 });
  } catch (error) {
    console.error('Error removing group member:', error);
    return NextResponse.json(
      { success: false, message: 'Internal server error' },
      { status: 500 }
    );
  }
}

export async function PATCH(request: NextRequest, { params }: { params: Promise<{ groupId: string; memberId: string }> }) {
  try {
    const authHeader = request.headers.get('authorization');
    if (!authHeader) {
      return NextResponse.json(
        { success: false, message: 'Authorization header missing' },
        { status: 401 }
      );
    }

    const { groupId, memberId } = await params;

    if (!groupId || groupId === 'undefined' || !memberId) {
      return NextResponse.json(
        { success: false, message: 'Invalid group or member ID' },
        { status: 400 }
      );
    }

    const body = await request.json();

    const backendUrl = `https://wisdom-walk-app.onrender.com/api/groups/${groupId}/members/${memberId}/role`;
    const res = await fetch(backendUrl, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': authHeader
      },
      body: JSON.stringify(body),
    });

    const data = await res.json();

    if (!res.ok) {
      return NextResponse.json(
        { success: false, message: data.message || 'Failed to update member role' },
        { status: res.status }
      );
    }

    return NextResponse.json(data, { status: 200 });
  } catch (error) {
    console.error('Error updating member role:', error);
    return NextResponse.json(
      { success: false, message: 'Internal server error' },
      { status: 500 }
    );
  }
}