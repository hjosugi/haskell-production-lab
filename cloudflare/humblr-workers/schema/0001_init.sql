create table if not exists articles (
  slug text primary key,
  title text not null,
  body text not null,
  created_at text not null
);

create index if not exists idx_articles_created_at on articles(created_at);
