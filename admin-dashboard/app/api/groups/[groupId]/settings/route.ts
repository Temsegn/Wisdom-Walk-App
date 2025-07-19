import { NextRequest, NextResponse } from 'next/server';

export async function GET(request: NextRequest, { params }: { params: Promise<{ groupId: string }> }) {
  try {
    const { groupId } = await params;

    if (!groupId || groupId === 'undefined') {
      return NextResponse.json(
        { success: false, message: 'Invalid group ID' },
        { status: 400 }
      );
    }

    const token = request.headers.get('Authorization') || '';
    const adminRequest = request.headers.get('X-Admin-Request') || 'false';

    const backendUrl = `https://wisdom-walk-app.onrender.com/api/groups/${groupId}/settings`;
    const res = await fetch(backendUrl, {
      method: 'GET',
      headers: {
        Authorization: token,
        'X-Admin-Request': adminRequest,
      },
      cache: 'no-store',
    });

    const data = await res.json();

    if (!res.ok) {
      return NextResponse.json(
        { success: false, message: data.message || 'Failed to fetch group settings' },
        { status: res.status }
      );
    }

    return NextResponse.json(data, { status: 200 });
  } catch (error) {
    console.error('Error fetching group settings:', error);
    return NextResponse.json(
      { success: false, message: 'Internal server error' },
      { status: 500 }
    );
  }
}

export async function PATCH(request: NextRequest, { params }: { params: Promise<{ groupId: string }> }) {
  try {
    const { groupId } = await params;

    if (!groupId || groupId === 'undefined') {
      return NextResponse.json(
        { success: false, message: 'Invalid group ID' },
        { status: 400 }
      );
    }

    const token = request.headers.get('Authorization') || '';
    const adminRequest = request.headers.get('X-Admin-Request') || 'false';
    const body = await request.json();

    const backendUrl = `https://wisdom-walk-app.onrender.com/api/groups/${groupId}/settings`;
    const res = await fetch(backendUrl, {
      method: 'PATCH',
      headers: {
        Authorization: token,
        'X-Admin-Request': adminRequest,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(body),
    });

    const data = await res.json();

    if (!res.ok) {
      return NextResponse.json(
        { success: false, message: data.message || 'Failed to update group settings' },
        { status: res.status }
      );
    }

    return NextResponse.json(data, { status: 200 });
  } catch (error) {
    console.error('Error updating group settings:', error);
    return NextResponse.json(
      { success: false, message: 'Internal server error' },
      { status: 500 }
    );
  }
}