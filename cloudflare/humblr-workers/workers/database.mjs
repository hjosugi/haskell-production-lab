const MAX_JSON_BYTES = 256 * 1024;
const ARTICLE_SLUG_PATTERN = /^[a-z0-9]+(?:-[a-z0-9]+)*$/;
const TOKEN_HASH_PATTERN = /^[a-f0-9]{64}$/;

class HttpError extends Error {
  /**
   * @param {number} status
   * @param {string} code
   * @param {string} message
   */
  constructor(status, code, message) {
    super(message);
    this.name = "HttpError";
    this.status = status;
    this.code = code;
  }
}

/** @type {ExportedHandler<DatabaseEnv>} */
const worker = {
  async fetch(request, env) {
    const url = new URL(request.url);

    try {
      if (url.pathname === "/api/articles") {
        if (request.method === "GET") return await listArticles(url, env.DB);
        if (request.method === "POST") return await createArticle(request, env.DB);
        throw new HttpError(405, "method_not_allowed", "method not allowed");
      }

      const commentsMatch = url.pathname.match(/^\/api\/articles\/([^/]+)\/comments$/);
      if (commentsMatch) {
        const slug = decodeSlug(commentsMatch[1]);
        if (request.method === "GET") return await listComments(slug, env.DB);
        if (request.method === "POST") return await createComment(slug, request, env.DB);
        throw new HttpError(405, "method_not_allowed", "method not allowed");
      }

      const articleMatch = url.pathname.match(/^\/api\/articles\/([^/]+)$/);
      if (articleMatch) {
        if (request.method !== "GET") {
          throw new HttpError(405, "method_not_allowed", "method not allowed");
        }
        return await getArticle(decodeSlug(articleMatch[1]), env.DB);
      }

      if (url.pathname === "/internal/sessions") {
        if (request.method === "POST") return await createSession(request, env.DB);
        throw new HttpError(405, "method_not_allowed", "method not allowed");
      }

      if (url.pathname === "/internal/sessions/lookup") {
        if (request.method === "POST") return await lookupSession(request, env.DB);
        throw new HttpError(405, "method_not_allowed", "method not allowed");
      }

      const sessionMatch = url.pathname.match(/^\/internal\/sessions\/([^/]+)$/);
      if (sessionMatch) {
        if (request.method !== "DELETE") {
          throw new HttpError(405, "method_not_allowed", "method not allowed");
        }
        return await deleteSession(decodePathPart(sessionMatch[1]), env.DB);
      }

      throw new HttpError(404, "not_found", "route not found");
    } catch (error) {
      return handleError(error, request);
    }
  },
};

export default worker;

/**
 * @param {URL} url
 * @param {D1Database} database
 */
async function listArticles(url, database) {
  const limit = parseLimit(url.searchParams.get("limit"));
  const result = await database
    .prepare(
      `SELECT slug, title, body, created_at AS createdAt
       FROM articles
       ORDER BY created_at DESC, slug ASC
       LIMIT ?1`,
    )
    .bind(limit)
    .all();
  return Response.json({ articles: result.results });
}

/**
 * @param {string} slug
 * @param {D1Database} database
 */
async function getArticle(slug, database) {
  const article = await database
    .prepare(
      `SELECT slug, title, body, created_at AS createdAt
       FROM articles
       WHERE slug = ?1`,
    )
    .bind(slug)
    .first();

  if (!article) throw new HttpError(404, "article_not_found", "article not found");
  return Response.json({ article });
}

/**
 * @param {Request} request
 * @param {D1Database} database
 */
async function createArticle(request, database) {
  const input = await readJsonObject(request);
  const slug = requireString(input, "slug", { maxLength: 120, pattern: ARTICLE_SLUG_PATTERN });
  const title = requireString(input, "title", { maxLength: 200 });
  const body = requireString(input, "body", { maxLength: 200_000, trim: false });
  const createdAt = new Date().toISOString();

  await database
    .prepare(
      `INSERT INTO articles (slug, title, body, created_at)
       VALUES (?1, ?2, ?3, ?4)`,
    )
    .bind(slug, title, body, createdAt)
    .run();

  return Response.json({ article: { slug, title, body, createdAt } }, { status: 201 });
}

/**
 * @param {string} slug
 * @param {D1Database} database
 */
async function listComments(slug, database) {
  const result = await database
    .prepare(
      `SELECT id, article_slug AS articleSlug, author_name AS authorName, body,
              created_at AS createdAt
       FROM comments
       WHERE article_slug = ?1
       ORDER BY created_at ASC, id ASC`,
    )
    .bind(slug)
    .all();
  return Response.json({ comments: result.results });
}

/**
 * @param {string} slug
 * @param {Request} request
 * @param {D1Database} database
 */
async function createComment(slug, request, database) {
  const input = await readJsonObject(request);
  const authorName = requireString(input, "authorName", { maxLength: 100 });
  const body = requireString(input, "body", { maxLength: 10_000, trim: false });
  const id = crypto.randomUUID();
  const createdAt = new Date().toISOString();

  await database
    .prepare(
      `INSERT INTO comments (id, article_slug, author_name, body, created_at)
       VALUES (?1, ?2, ?3, ?4, ?5)`,
    )
    .bind(id, slug, authorName, body, createdAt)
    .run();

  return Response.json(
    { comment: { id, articleSlug: slug, authorName, body, createdAt } },
    { status: 201 },
  );
}

/**
 * @param {Request} request
 * @param {D1Database} database
 */
async function createSession(request, database) {
  const input = await readJsonObject(request);
  const subject = requireString(input, "subject", { maxLength: 128 });
  const tokenHash = requireString(input, "tokenHash", { pattern: TOKEN_HASH_PATTERN, trim: false });
  const expiresAt = requireIsoDate(input, "expiresAt");
  const id = crypto.randomUUID();
  const createdAt = new Date().toISOString();

  await database
    .prepare(
      `INSERT INTO sessions (id, subject, token_hash, expires_at, created_at)
       VALUES (?1, ?2, ?3, ?4, ?5)`,
    )
    .bind(id, subject, tokenHash, expiresAt, createdAt)
    .run();

  return Response.json({ session: { id, subject, expiresAt, createdAt } }, { status: 201 });
}

/**
 * @param {Request} request
 * @param {D1Database} database
 */
async function lookupSession(request, database) {
  const input = await readJsonObject(request);
  const tokenHash = requireString(input, "tokenHash", { pattern: TOKEN_HASH_PATTERN, trim: false });
  const now = new Date().toISOString();
  const session = await database
    .prepare(
      `SELECT id, subject, expires_at AS expiresAt, created_at AS createdAt
       FROM sessions
       WHERE token_hash = ?1 AND expires_at > ?2`,
    )
    .bind(tokenHash, now)
    .first();

  if (!session) throw new HttpError(404, "session_not_found", "active session not found");
  return Response.json({ session });
}

/**
 * @param {string} id
 * @param {D1Database} database
 */
async function deleteSession(id, database) {
  await database.prepare("DELETE FROM sessions WHERE id = ?1").bind(id).run();
  return new Response(null, { status: 204 });
}

/**
 * @param {Request} request
 * @returns {Promise<Record<string, unknown>>}
 */
async function readJsonObject(request) {
  const contentType = request.headers.get("content-type") ?? "";
  if (!contentType.toLowerCase().includes("application/json")) {
    throw new HttpError(415, "unsupported_media_type", "content-type must be application/json");
  }

  const declaredLength = request.headers.get("content-length");
  if (declaredLength !== null && Number(declaredLength) > MAX_JSON_BYTES) {
    throw new HttpError(413, "payload_too_large", "JSON body is too large");
  }

  const text = await request.text();
  if (new TextEncoder().encode(text).byteLength > MAX_JSON_BYTES) {
    throw new HttpError(413, "payload_too_large", "JSON body is too large");
  }

  /** @type {unknown} */
  let value;
  try {
    value = JSON.parse(text);
  } catch {
    throw new HttpError(400, "invalid_json", "request body is not valid JSON");
  }

  if (!isRecord(value)) {
    throw new HttpError(400, "invalid_json", "request body must be a JSON object");
  }
  return value;
}

/**
 * @param {Record<string, unknown>} input
 * @param {string} field
 * @param {{maxLength?: number, pattern?: RegExp, trim?: boolean}} [options]
 */
function requireString(input, field, options = {}) {
  const raw = input[field];
  if (typeof raw !== "string") {
    throw new HttpError(400, "invalid_request", `${field} must be a string`);
  }

  const value = options.trim === false ? raw : raw.trim();
  if (value.trim().length === 0) {
    throw new HttpError(400, "invalid_request", `${field} must not be empty`);
  }
  if (options.maxLength !== undefined && value.length > options.maxLength) {
    throw new HttpError(400, "invalid_request", `${field} is too long`);
  }
  if (options.pattern && !options.pattern.test(value)) {
    throw new HttpError(400, "invalid_request", `${field} has an invalid format`);
  }
  return value;
}

/**
 * @param {Record<string, unknown>} input
 * @param {string} field
 */
function requireIsoDate(input, field) {
  const value = requireString(input, field, { maxLength: 40 });
  if (Number.isNaN(Date.parse(value))) {
    throw new HttpError(400, "invalid_request", `${field} must be an ISO 8601 timestamp`);
  }
  return value;
}

/** @param {string | null} raw */
function parseLimit(raw) {
  if (raw === null) return 50;
  if (!/^\d+$/.test(raw)) throw new HttpError(400, "invalid_limit", "limit must be an integer");
  const value = Number(raw);
  if (value < 1 || value > 100) {
    throw new HttpError(400, "invalid_limit", "limit must be between 1 and 100");
  }
  return value;
}

/** @param {string} encoded */
function decodeSlug(encoded) {
  const slug = decodePathPart(encoded);
  if (!ARTICLE_SLUG_PATTERN.test(slug)) {
    throw new HttpError(400, "invalid_slug", "article slug has an invalid format");
  }
  return slug;
}

/** @param {string} encoded */
function decodePathPart(encoded) {
  try {
    return decodeURIComponent(encoded);
  } catch {
    throw new HttpError(400, "invalid_path", "path segment is not valid URL encoding");
  }
}

/**
 * @param {unknown} value
 * @returns {value is Record<string, unknown>}
 */
function isRecord(value) {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

/**
 * @param {unknown} error
 * @param {Request} request
 */
function handleError(error, request) {
  if (error instanceof HttpError) {
    return Response.json({ error: { code: error.code, message: error.message } }, { status: error.status });
  }

  const message = error instanceof Error ? error.message : String(error);
  console.error(
    JSON.stringify({
      message: "database request failed",
      method: request.method,
      path: new URL(request.url).pathname,
      error: message,
    }),
  );

  if (message.includes("UNIQUE constraint failed")) {
    return Response.json(
      { error: { code: "conflict", message: "resource already exists" } },
      { status: 409 },
    );
  }
  if (message.includes("FOREIGN KEY constraint failed")) {
    return Response.json(
      { error: { code: "article_not_found", message: "article not found" } },
      { status: 404 },
    );
  }
  return Response.json(
    { error: { code: "internal_error", message: "internal database error" } },
    { status: 500 },
  );
}
