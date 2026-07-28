<!-- i18n: language-switcher -->
[English](POSTGRESQL_KV.md) | [日本語](POSTGRESQL_KV.ja.md)

# PostgreSQL KVアダプター

`HPS.Service.KV.Postgres`は、既存の`Handle Text v`インターフェースのPostgreSQL実装を提供します。値はAesonでエンコードされ、`hps_kv.kv_value`のJSONB列に格納されます。

## 前提条件

- PostgreSQL 14以上
- ビルド時にPostgreSQLクライアントヘッダーとpkg-config（Ubuntuでは`libpq-dev`と`pkg-config`）
- `psql`または他のマイグレーションランナー

ローカル開発のために、Composeデータベースを起動し、マイグレーションを適用します。

```bash
docker compose up -d postgres
docker compose exec -T postgres \
  psql -U hps -d hps < migrations/postgresql/0001_hps_kv.sql
```

デフォルトのローカル接続文字列は次のとおりです。

```text
postgresql://hps:hps@localhost:5432/hps
```

## ハンドルの構築

アプリケーションはコネクションプールを所有します。アダプターは操作ごとに1つのコネクションをチェックアウトし、プール自体を閉じることはありません。

```haskell
import qualified Data.ByteString.Char8 as BS8
import Data.Pool (defaultPoolConfig, newPool)
import Data.Text (Text)
import Database.PostgreSQL.Simple (close, connectPostgreSQL)
import HPS.Service.KV (Handle)
import HPS.Service.KV.Postgres (newPostgresHandle)

pool <- newPool $ defaultPoolConfig
  (connectPostgreSQL (BS8.pack databaseUrl))
  close
  30 -- アイドル秒数
  10 -- 最大コネクション数

let store = newPostgresHandle pool :: Handle Text MyValue
```

`kvPut`は`INSERT ... ON CONFLICT`を使用しているため、既存のキーを書き込むと値を置き換え、`updated_at`を更新します。`kvList`はキーで順序付けられ、決定的な結果を保証します。各操作はアトミックですが、ハンドル呼び出しのシーケンスはトランザクションではありません。

## 障害時の動作

| 障害 | 動作 | 呼び出し側の対応 |
|---|---|---|
| マイグレーションがない | PostgreSQLの`SqlError`（通常SQLSTATE`42P01`）が伝播 | トラフィックを提供する前に`0001_hps_kv.sql`を実行してください |
| コネクション/クエリの失敗 | 元の`postgresql-simple`例外が伝播; `withResource`は失敗したコネクションを破棄 | 一時的なSQLSTATEクラスのみリトライし、バウンデッドバックオフを使用 |
| プールが枯渇 | `withResource`がコネクションを待つ | プールのサイズを調整し、リクエストレベルのタイムアウトを追加 |
| 格納されたJSONが`v`と一致しない | `PostgresKVDecodeError`に影響を受けたキーとAesonメッセージを含む | 行を修復/マイグレーションし、盲目的にリトライしない |
| `kvList`中の1つの不正な行 | 全リスト操作が`PostgresKVDecodeError`で失敗 | 名前付き行を修復するか、スキーママイグレーションを提供 |
| PostgreSQLがNULを含むテキストキーを拒否 | 元の`SqlError`が伝播 | アプリケーションの境界でキーを検証 |

この表は一般的なものですが、ハンドルはすべての行が同じHaskell値の型`v`を持つことを前提としています。明示的なエンベロープやバージョンフィールドなしに、無関係な値スキーマ用に`hps_kv`テーブルを使用しないでください。JSONスキーマの進化は、新しい形状を必要とする読者に展開される前にデータマイグレーションとともに行う必要があります。

アダプターはコネクション文字列や値をログに記録しません。資格情報は`DATABASE_URL`やシークレットマネージャに保持し、ソースコード管理には含めないでください。

## テスト

デフォルトのテストスイートは常に成功および拒否されたJSONBコーデックパスをチェックします。`HPS_TEST_DATABASE_URL`を設定して、隔離されたスキーマにマイグレーションを適用し、実際のPostgreSQLサーバーに対して挿入、取得、順序付きリスト、更新、削除を行います。

```bash
HPS_TEST_DATABASE_URL=postgresql://hps:hps@localhost:5432/hps cabal test all
```

この統合テストは専用の`hps_kv_integration_test`スキーマの作成と削除のみを行います。CIはこの統合パスをエフェメラルなPostgreSQLサービスに対して実行します。