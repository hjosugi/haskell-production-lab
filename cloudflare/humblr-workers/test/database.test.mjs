import { env, exports } from "cloudflare:workers";
import { beforeEach, describe, expect, it } from "vitest";

const jsonHeaders = { "content-type": "application/json" };

beforeEach(async () => {
  await env.DB.batch([
    env.DB.prepare("DELETE FROM comments"),
    env.DB.prepare("DELETE FROM sessions"),
    env.DB.prepare("DELETE FROM articles"),
  ]);
});

describe("Humblr D1 adapter", () => {
  it("applies migrations for articles, comments, and sessions", async () => {
    const result = await env.DB.prepare(
      "SELECT name FROM sqlite_master WHERE type = 'table' AND name IN ('articles', 'comments', 'sessions') ORDER BY name",
    ).all();

    expect(result.results).toEqual([{ name: "articles" }, { name: "comments" }, { name: "sessions" }]);
  });

  it("creates and reads articles and comments through prepared D1 statements", async () => {
    const articleResponse = await exports.default.fetch("https://database.internal/api/articles", {
      method: "POST",
      headers: jsonHeaders,
      body: JSON.stringify({ slug: "typed-workers", title: "Typed Workers", body: "D1 article" }),
    });
    expect(articleResponse.status).toBe(201);

    const commentResponse = await exports.default.fetch(
      "https://database.internal/api/articles/typed-workers/comments",
      {
        method: "POST",
        headers: jsonHeaders,
        body: JSON.stringify({ authorName: "Ada", body: "Looks good" }),
      },
    );
    expect(commentResponse.status).toBe(201);

    const article = await exports.default.fetch("https://database.internal/api/articles/typed-workers");
    expect(article.status).toBe(200);
    expect(await article.json()).toMatchObject({
      article: { slug: "typed-workers", title: "Typed Workers", body: "D1 article" },
    });

    const comments = await exports.default.fetch(
      "https://database.internal/api/articles/typed-workers/comments",
    );
    expect(comments.status).toBe(200);
    expect(await comments.json()).toMatchObject({
      comments: [{ articleSlug: "typed-workers", authorName: "Ada", body: "Looks good" }],
    });
  });

  it("stores only a session token hash and supports lookup and deletion", async () => {
    const tokenHash = "a".repeat(64);
    const createResponse = await exports.default.fetch("https://database.internal/internal/sessions", {
      method: "POST",
      headers: jsonHeaders,
      body: JSON.stringify({
        subject: "user-123",
        tokenHash,
        expiresAt: "2099-01-01T00:00:00.000Z",
      }),
    });
    expect(createResponse.status).toBe(201);
    const created = await createResponse.json();
    expect(created).not.toHaveProperty("session.tokenHash");

    const row = await env.DB.prepare("SELECT token_hash, subject FROM sessions").first();
    expect(row).toEqual({ token_hash: tokenHash, subject: "user-123" });

    const lookupResponse = await exports.default.fetch(
      "https://database.internal/internal/sessions/lookup",
      {
        method: "POST",
        headers: jsonHeaders,
        body: JSON.stringify({ tokenHash }),
      },
    );
    expect(lookupResponse.status).toBe(200);
    expect(await lookupResponse.json()).toMatchObject({ session: { subject: "user-123" } });

    const session = await env.DB.prepare("SELECT id FROM sessions").first("id");
    const deleteResponse = await exports.default.fetch(
      `https://database.internal/internal/sessions/${session}`,
      { method: "DELETE" },
    );
    expect(deleteResponse.status).toBe(204);
    expect(await env.DB.prepare("SELECT COUNT(*) AS count FROM sessions").first("count")).toBe(0);
  });

  it("returns structured validation and conflict errors", async () => {
    const invalid = await exports.default.fetch("https://database.internal/api/articles", {
      method: "POST",
      headers: jsonHeaders,
      body: JSON.stringify({ slug: "Invalid Slug", title: "Title", body: "Body" }),
    });
    expect(invalid.status).toBe(400);
    expect(await invalid.json()).toMatchObject({ error: { code: "invalid_request" } });

    const article = { slug: "duplicate", title: "Title", body: "Body" };
    await exports.default.fetch("https://database.internal/api/articles", {
      method: "POST",
      headers: jsonHeaders,
      body: JSON.stringify(article),
    });
    const duplicate = await exports.default.fetch("https://database.internal/api/articles", {
      method: "POST",
      headers: jsonHeaders,
      body: JSON.stringify(article),
    });
    expect(duplicate.status).toBe(409);
    expect(await duplicate.json()).toMatchObject({ error: { code: "conflict" } });

    const missingArticle = await exports.default.fetch(
      "https://database.internal/api/articles/missing/comments",
      {
        method: "POST",
        headers: jsonHeaders,
        body: JSON.stringify({ authorName: "Ada", body: "No parent article" }),
      },
    );
    expect(missingArticle.status).toBe(404);
    expect(await missingArticle.json()).toMatchObject({ error: { code: "article_not_found" } });
  });
});
