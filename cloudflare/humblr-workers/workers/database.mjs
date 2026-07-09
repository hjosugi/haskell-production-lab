export default {
  async fetch(request, env) {
    const url = new URL(request.url);

    if (request.method === "GET" && url.pathname === "/api/articles") {
      const result = await env.DB.prepare("select slug, title, body, created_at from articles order by created_at desc limit 50").all();
      return Response.json(result.results);
    }

    if (request.method === "POST" && url.pathname === "/api/articles") {
      const body = await request.json();
      await env.DB.prepare("insert into articles(slug, title, body, created_at) values(?1, ?2, ?3, datetime('now'))")
        .bind(body.slug, body.title, body.body)
        .run();
      return Response.json({ ok: true }, { status: 201 });
    }

    return Response.json({ error: "not found" }, { status: 404 });
  }
};
