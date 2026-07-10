PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS comments (
  id TEXT PRIMARY KEY,
  article_slug TEXT NOT NULL,
  author_name TEXT NOT NULL CHECK (length(author_name) BETWEEN 1 AND 100),
  body TEXT NOT NULL CHECK (length(body) BETWEEN 1 AND 10000),
  created_at TEXT NOT NULL,
  FOREIGN KEY (article_slug) REFERENCES articles(slug) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_comments_article_created_at
  ON comments(article_slug, created_at, id);

CREATE TABLE IF NOT EXISTS sessions (
  id TEXT PRIMARY KEY,
  subject TEXT NOT NULL CHECK (length(subject) BETWEEN 1 AND 128),
  token_hash TEXT NOT NULL UNIQUE CHECK (length(token_hash) = 64),
  expires_at TEXT NOT NULL,
  created_at TEXT NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_sessions_expires_at ON sessions(expires_at);
