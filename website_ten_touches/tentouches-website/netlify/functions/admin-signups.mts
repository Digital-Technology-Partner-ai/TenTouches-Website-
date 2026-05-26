import type { Context } from "@netlify/functions";
import { getStore } from "@netlify/blobs";

const STORE_NAME = "beta-signups";
const ARCHIVE_PREFIX = "archived-";
const ADMIN_PASSWORD = process.env.ADMIN_PASSWORD || "tentouches-admin";

interface Signup {
  key: string;
  name: string;
  email: string;
  mobile: string | null;
  timestamp: string;
  archived?: boolean;
  archivedAt?: string;
}

const handler = async (req: Request, _context: Context) => {
  // Check password
  const password = req.headers.get("X-Admin-Password");
  
  if (password !== ADMIN_PASSWORD) {
    return new Response(
      JSON.stringify({ error: "Unauthorized" }),
      { status: 401, headers: { "Content-Type": "application/json" } }
    );
  }

  // Handle DELETE request (soft delete/archive)
  if (req.method === "DELETE") {
    try {
      const { key } = await req.json() as { key: string };
      
      if (!key) {
        return new Response(
          JSON.stringify({ error: "Key is required" }),
          { status: 400, headers: { "Content-Type": "application/json" } }
        );
      }

      const store = getStore({ name: STORE_NAME, consistency: "strong" });
      
      // Get the existing signup
      const data = await store.get(key, { type: "json" }) as {
        name: string;
        email: string;
        mobile: string | null;
        timestamp: string;
      };

      if (!data) {
        return new Response(
          JSON.stringify({ error: "Signup not found" }),
          { status: 404, headers: { "Content-Type": "application/json" } }
        );
      }

      // Create archived version with metadata
      const archivedKey = `${ARCHIVE_PREFIX}${key}`;
      await store.setJSON(archivedKey, {
        ...data,
        archived: true,
        archivedAt: new Date().toISOString(),
      });

      // Delete the original
      await store.delete(key);

      return new Response(
        JSON.stringify({ success: true, message: "Signup archived" }),
        { status: 200, headers: { "Content-Type": "application/json" } }
      );
    } catch (err) {
      console.error("admin-signups delete error:", err);
      return new Response(
        JSON.stringify({ error: "Failed to archive signup" }),
        { status: 500, headers: { "Content-Type": "application/json" } }
      );
    }
  }

  // Handle GET request (list signups)
  if (req.method === "GET") {
    try {
      const url = new URL(req.url);
      const showArchived = url.searchParams.get("archived") === "true";
      
      const store = getStore({ name: STORE_NAME, consistency: "strong" });
      
      const prefix = showArchived ? ARCHIVE_PREFIX : "signup-";
      const { blobs } = await store.list({ prefix });
      
      const signups: Signup[] = [];
      
      for (const blob of blobs) {
        try {
          const data = await store.get(blob.key, { type: "json" }) as {
            name: string;
            email: string;
            mobile: string | null;
            timestamp: string;
            archived?: boolean;
            archivedAt?: string;
          };
          
          if (data && data.email) {
            signups.push({
              key: blob.key,
              name: data.name,
              email: data.email,
              mobile: data.mobile,
              timestamp: data.timestamp,
              archived: data.archived,
              archivedAt: data.archivedAt,
            });
          }
        } catch (e) {
          console.error(`Error reading blob ${blob.key}:`, e);
        }
      }

      // Sort by timestamp (newest first)
      signups.sort((a, b) => 
        new Date(b.timestamp).getTime() - new Date(a.timestamp).getTime()
      );

      return new Response(
        JSON.stringify({ signups, count: signups.length }),
        { status: 200, headers: { "Content-Type": "application/json" } }
      );
    } catch (err) {
      console.error("admin-signups error:", err);
      return new Response(
        JSON.stringify({ error: "Internal server error" }),
        { status: 500, headers: { "Content-Type": "application/json" } }
      );
    }
  }

  return new Response(
    JSON.stringify({ error: "Method not allowed" }),
    { status: 405, headers: { "Content-Type": "application/json" } }
  );
};

export default handler;
