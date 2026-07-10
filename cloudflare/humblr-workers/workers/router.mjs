/** @type {ExportedHandler<RouterEnv>} */
const worker = {
  async fetch(request, env) {
    const url = new URL(request.url);

    try {
      if (url.pathname === "/api/health") {
        return Response.json({ service: "humblr-router", status: "ok" });
      }

      if (url.pathname === "/api/articles" || url.pathname.startsWith("/api/articles/")) {
        return await env.DATABASE.fetch(request);
      }

      if (url.pathname === "/uploads" || url.pathname.startsWith("/uploads/")) {
        return await env.STORAGE.fetch(request);
      }

      if (url.pathname === "/images" || url.pathname.startsWith("/images/")) {
        return await env.IMAGES.fetch(request);
      }

      // SSR fallback. A future Haskell/WASM module can render the same route contract.
      return await env.SSR.fetch(request);
    } catch (error) {
      const message = error instanceof Error ? error.message : String(error);
      console.error(
        JSON.stringify({
          message: "service binding request failed",
          method: request.method,
          path: url.pathname,
          error: message,
        }),
      );
      return Response.json(
        { error: { code: "upstream_error", message: "upstream service unavailable" } },
        { status: 502 },
      );
    }
  },
};

export default worker;
