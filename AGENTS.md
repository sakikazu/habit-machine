# Repository Guidelines

## 基本
- 回答は日本語でしてください

## プロジェクト構成
- Rails本体は`app/`配下（`controllers`/`models`/`views`/`assets`）。Vue関連は`app/javascript`に集約し、エントリは`packs/`、共通パーツは`components/`、ユーティリティは直下の`*.js`。
- スタイルは`app/assets/stylesheets`および`app/javascript/stylesheets`。静的ファイルは`public/`。
- テストは`spec/`（`models`、`requests`、`support`、`factories`）。単発スクリプトは`oneshot_scripts/`、インフラ関連は`ecs/`、`nginx/`、`doc/`。

## 開発・ビルド・テスト
- 依存起動: リポジトリ直下で`docker compose up`。
- 依存インストール: Rubyは`bundle install`、JSは`yarn install`（Node 14.17.x前提）。
- アプリ起動: `bin/rails s`（Web）＋`bin/webpack-dev-server`（Vue/webpackerのHMR）。
- DB: 初期化`bin/rails db:setup`、デモ投入`bin/rake db:seed_fu`。
- テスト: `bundle exec rspec`。Lint: `bundle exec rubocop`。
- デプロイ: `bundle exec cap production deploy`（linked_files/dirsは`config/deploy.rb`参照）。

## コーディングスタイル
- Rubyは2スペース・snake_case。`.rubocop_todo.yml`ベースのRubocopを採用するのでPR前に`bundle exec rubocop`。
- ViewはSlim優先、スタイルはSCSS/Sass。Bootstrap 4のコンポーネントを崩さず、インラインスタイルは最小限。
- VueコンポーネントはPascalCaseファイル名＋kebab-case props。共通JSは`app/javascript/*.js`に配置。
- 秘密情報はコミットしない。`.env.sample`をコピーして`.env`を用意し、必要なキーを追加。
- 追加したクラス、メソッドには概要のコメントを設ける。コメントの最後に「。」は不要
- 意図が明確ではないコードにはコメントを設ける

## デザイン
- レスポンシブデザインでPCとスマホ用のViewを実現

## テスト指針
- RSpec＋`factory_bot_rails`。モデルは`spec/models`、リクエスト/APIは`spec/requests`、共通ヘルパーは`spec/support`。
- ファイルは`*_spec.rb`命名で小さく切る。例: `bundle exec rspec spec/models/diary_spec.rb`。
- 実行前にマイグレーションを適用し、必要なら`bin/rails db:test:prepare`でテストDBを同期。

## コミット・PR
- コミットメッセージは短く命令形（英/日どちらでも可、プレフィックス不要）。例: `add ruby-lsp gem`。
- PRには目的、影響範囲、確認方法を明記し、UI変更はスクリーンショットやGIFを添付。関連Issueがあればリンク。
- 実行したコマンド（テスト/リント/シード等）を記載し、マイグレーションや新しい環境変数などレビュアーに必要な手順を列挙。
