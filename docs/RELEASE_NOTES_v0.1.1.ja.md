<!-- i18n: language-switcher -->
[English](RELEASE_NOTES_v0.1.1.md) | [日本語](RELEASE_NOTES_v0.1.1.ja.md)

# v0.1.1

Haskell Production Lab の PDF に基づくドキュメントリリース。

## 収録内容

- 3つの作業参考資料のローカル PDF ソース合成：
  `haskell book`、`Haskell.pdf`、および `FP pragpub0.pdf`。
- PDF資料から Servant API、サービスパターン、
  ピュアコア/IO の境界、型クラス、パース、シリアライズ、STM 並行処理、
  テスト、デプロイメントの領域へのトピックマッピング。
- ローカル PDF を未コミットの作業資料として記録したリファレンスドキュメント。
- プロパティテスト、パーサ演習、シリアライズ例、
  並行処理ドキュメント、API/ドメイン型のレビューに関するロードマップ項目。

## 検証方法

- `LD_LIBRARY_PATH=/usr/lib:$LD_LIBRARY_PATH cabal build all`
- `LD_LIBRARY_PATH=/usr/lib:$LD_LIBRARY_PATH cabal test all`

## 備考

- ソース PDF はローカルの追跡対象外ファイルのままであり、このリリースには含まれません。
- PDF からの長い逐語的抜粋は意図的に除外されています。