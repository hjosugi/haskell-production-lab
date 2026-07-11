<!-- i18n: language-switcher -->
[English](RUNBOOK.md) | [日本語](RUNBOOK.ja.md)

# 実行手順書

## ローカルAPIの起動

```bash
cabal run hps-api
```

## スモークテスト

```bash
curl localhost:8080/health
curl localhost:8080/metrics
curl localhost:8080/lab/stats
```

管理UIを開く：

```text
http://localhost:8080/lab
```

## ラボプロジェクトの追加

```bash
curl -X POST localhost:8080/lab/projects \
  -H 'content-type: application/json' \
  -d '{"projectNameSeed":"Typed calculator","projectSummarySeed":"純粋な計算コアとCLIラッパー。","projectRepoSeed":null,"projectDemoSeed":null,"projectTagsSeed":["calculator","types"]}'
```

## 学習記録のログ

```bash
curl -X POST localhost:8080/lab/learning \
  -H 'content-type: application/json' \
  -d '{"learningTopicSeed":"Servant API types","learningNotesSeed":"APIの形は型であり、ハンドラーの順序は型に従う。","learningLinksSeed":[],"learningOutcomeSeed":"実践済み"}'
```

## 記事の追加

```bash
curl -X POST localhost:8080/articles \
  -H 'content-type: application/json' \
  -d '{"seedTitle":"Hello","seedSlug":"hello","seedBody":"body","seedTags":["demo"]}'
```

## デバッグキュー

```bash
cabal run hps-worker
```

## よくある失敗ケース

### Cabalのソルバーが失敗

次のコマンドを実行：

```bash
cabal update
cabal clean
cabal build all --allow-newer
```

その後、`cabal.project.freeze`でバージョンを固定。

### ポートが既に使用中

```bash
PORT=9000 cabal run hps-api
```

### Cloudflare Workerバンドルが大きすぎる

Haskell/WASMの依存関係を減らし、シンボルを除去し、サービスを分割し、重いレンダリング処理をレイテンシーに敏感なWorkersの外側に置く。