import { NextResponse } from "next/server";

const API_BASE_URL = process.env.API_BASE_URL || "http://localhost:4000";
const CRON_SECRET = process.env.CRON_SECRET || "";

export async function GET(request: Request) {
  // Verify the request comes from Vercel Cron
  const authHeader = request.headers.get("authorization");
  if (authHeader !== `Bearer ${CRON_SECRET}`) {
    return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
  }

  try {
    const res = await fetch(`${API_BASE_URL}/v1/snapshots/take-all`, {
      method: "POST",
      headers: { "x-cron-secret": CRON_SECRET },
    });

    const data = await res.json();

    if (!res.ok) {
      return NextResponse.json(
        { error: "Snapshot failed", details: data },
        { status: res.status },
      );
    }

    return NextResponse.json(data);
  } catch (err) {
    return NextResponse.json(
      { error: "Failed to call snapshot API" },
      { status: 500 },
    );
  }
}
