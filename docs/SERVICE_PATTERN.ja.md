<!-- i18n: language-switcher -->
[English](SERVICE_PATTERN.md) | [日本語](SERVICE_PATTERN.ja.md)

# サービス / ハンドルパターン

## ルール

ビジネスロジックは具体的なインフラストラクチャではなく、小さな関数の記録を呼び出すべきです。

例：

```haskell
data Handle k v = Handle
  { kvGet :: k -> IO (Maybe v)
  , kvPut :: k -> v -> IO ()
  , kvDelete :: k -> IO ()
  , kvList :: IO [(k, v)]
  }
```

その後、アプリは以下を使用できます：

- テスト用に `newMemoryHandle`
- ローカルデモ用に `newJsonFileHandle`
- PostgreSQL本番ストレージ用に `newPostgresHandle`
- Cloudflareエッジのサービスバインディングの背後にD1をバックエンドとしたデータベースワーカー

PostgreSQLアダプター、マイグレーションワークフロー、および障害セマンティクスについては
[POSTGRESQL_KV.md](POSTGRESQL_KV.md)に記載されています。

## これが面接で役立つ理由

簡潔な説明：

> ドメインロジックを純粋に保ちます。IOは小さなハンドルレコードの背後に隠されています。これによりテストが高速化され、ストレージやキューの切り替えが容易になり、API層を薄く保つことができます。

## 出現場所

- `HPS.Service.Logger`
- `HPS.Service.KV`
- `HPS.Service.Queue`
- `HPS.Service.EventStore`
- `HPS.Service.Metrics`