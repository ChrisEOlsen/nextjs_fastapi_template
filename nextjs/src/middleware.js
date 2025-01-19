import { getToken } from "next-auth/jwt";
import { NextResponse } from "next/server";

export async function middleware(req) {
  const token = await getToken({ req, secret: process.env.NEXTAUTH_SECRET });

  if (!token || !token.isAdmin) {
    const loginUrl = req.nextUrl.clone();
    loginUrl.pathname = "/login";
    return NextResponse.redirect(loginUrl);
  }

  return NextResponse.next();
}

// Apply the middleware to both /admin and /api/admin routes
export const config = {
  matcher: [
    "/admin/:path*",      // Matches all routes under /admin
    "/api/admin/:path*",  // Matches all routes under /api/admin
  ],
};
