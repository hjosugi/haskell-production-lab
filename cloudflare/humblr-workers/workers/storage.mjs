export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    const key = url.pathname.replace(/^\/uploads\//, "");

    if (request.method === "PUT") {
      await env.BUCKET.put(key, request.body);
      return Response.json({ key });
    }

    if (request.method === "GET") {
      const object = await env.BUCKET.get(key);
      if (!object) return new Response("not found", { status: 404 });
      return new Response(object.body, { headers: object.httpMetadata || {} });
    }

    return new Response("method not allowed", { status: 405 });
  }
};
