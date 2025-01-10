import NextAuth from "next-auth";
import GoogleProvider from "next-auth/providers/google";

export default NextAuth({
  providers: [
    GoogleProvider({
      clientId: process.env.GOOGLE_CLIENT_ID,
      clientSecret: process.env.GOOGLE_CLIENT_SECRET,
    }),
  ],
  callbacks: {
    async jwt({ token, user }) {
      if (user?.email) {
        token.email = user.email;

        // Dynamically query the FastAPI backend for admin status
        try {
          const response = await fetch(`${process.env.FASTAPI_URL}/check-admin`, {
            method: "POST",
            headers: {
              "Content-Type": "application/json",
            },
            body: JSON.stringify({ email: user.email }),
          });

          if (response.ok) {
            token.isAdmin = true; // Mark as admin if the email exists in the database
          } else {
            token.isAdmin = false; // Not an admin
          }
        } catch (error) {
          console.error("Error checking admin status:", error);
          token.isAdmin = false; // Default to non-admin on error
        }
      }
      return token;
    },
    async session({ session, token }) {
      session.user.email = token.email;
      session.user.isAdmin = token.isAdmin;
      return session;
    },
  },
});
