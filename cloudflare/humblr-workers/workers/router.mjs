export default {
  async fetch(request, env, ctx) {
    const url = new URL(request.url);

    if (url.pathname === "/api/health") {
      return Response.json({ service: "humblr-router", status: "ok" });
    }

    if (url.pathname.startsWith("/api/articles")) {
      return env.DATABASE.fetch(request);
    }

    if (url.pathname.startsWith("/uploads")) {
      return env.STORAGE.fetch(request);
    }

    if (url.pathname.startsWith("/images")) {
      return env.IMAGES.fetch(request);
    }

    // SSR fallback. A future Haskell/WASM module can render the same route contract.
    return env.SSR.fetch(request);
  }
};
