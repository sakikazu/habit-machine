# HabitMachine

日記や習慣など、日々の記録をまとめるプライベート向けサービスです。
一部の記録は家族と共有できます。レスポンシブ表示とPWAに対応しています。

## 主な機能

- 日ごとの日記・習慣記録
- 日記のタグ付け、画像添付、Markdown入力補助
- 日記の固定表示、人生ハイライト、10年日記、全文検索
- 記録データのグラフ表示
- ContentEditableを使った目次付きノート
- 家族の記録と一部データの共有
- YouTube動画・音声・コメントのアーカイブ
- レスポンシブ表示、PWA

画面遷移にはTurbolinksを使用し、操作量の多い画面へVue 2コンポーネントをページ単位で組み込んでいます。全面的なSPAではありません。

## スクリーンキャプチャ
### 日ごとのページ
![image](https://github.com/user-attachments/assets/467ae51a-ce8c-456b-9593-f947c110616b)

### ノートページ
<img width="1172" alt="image" src="https://user-images.githubusercontent.com/745130/219923297-419e8bd1-fd56-4c41-9a00-6d59faa08363.png">


### 検索結果ページ
<img width="1168" alt="image" src="https://user-images.githubusercontent.com/745130/219923506-d67a507c-8b8f-4205-9cf2-69bf6e56384d.png">


## 開発

### 必要な環境

- Ruby 3.2.6
- Rails 7.2.3
- Node.js 23.5.0
- Yarn 1.x
- MySQL

RubyとNode.jsのバージョンは`.tool-versions`を参照してください。

### セットアップ

`.env.sample`をコピーして、環境に合わせた値を設定します。

```bash
cp .env.sample .env
bin/setup
```

`config/database.yml`のdevelopment設定はローカルMySQLを使用します。ユーザー名やパスワードは必要に応じて調整してください。

### 起動

RailsサーバーとJavaScriptのwatchビルドを同時に起動します。

```bash
bin/dev
```

個別に起動する場合:

```bash
bin/rails server
bin/webpack-watch
```

JavaScriptはWebpack 5でビルドし、`app/javascript/entrypoints`から`app/assets/builds`へ出力します。Webpackerは使用していません。

### テスト・静的解析

```bash
bundle exec rspec
bundle exec rubocop
yarn build
```

テストDBの同期が必要な場合は、先に次を実行します。

```bash
bin/rails db:test:prepare
```

### 任意機能の設定

YouTubeコメント取得には`YOUTUBE_API_KEY`が必要です。動画・音声ダウンロードには`yt-dlp`、`ffmpeg`、`ffprobe`をインストールしてください。`yt-dlp`がPATHにない場合は`YT_DLP_PATH`で実行ファイルを指定できます。

```dotenv
YOUTUBE_API_KEY=your_youtube_api_key
YT_DLP_PATH=/path/to/yt-dlp
```

Capistranoデプロイでは`.env`がlinked fileになっているため、本番環境の`shared/.env`へ必要な値を設定します。

## 本番デプロイ

```bash
bundle exec cap production deploy
```

## デモ環境

* ※現在は、必要なときにterraformでAWS ECSにデプロイしている

テストユーザー

| email            | password  |
| ---------------- | --------- |
| test@example.com | password  |


## 主な技術

- Rails 7.2
- MySQL
- Vue.js 2.6
- Webpack 5 / jsbundling-rails
- Turbolinks 5
- Bootstrap 4.6
- Font Awesome 4
- Slim
- Sass / SCSS
- RSpec / factory_bot


## 運用メモ

### Knowhow

* 日記のMarkdown入力補助はJavaScriptをjQueryモジュール化している
* 各所にCSS flexboxを用いてレイアウト


### Deployment instructions
* `config/deploy.rb`に記載されているlinked_files、linked_dirsを確認する

### Backup
サーバー側のcronでDBのdumpを行い、
ローカルPCのcronでDB dumpとアップロードファイルをローカルPC内部に保存している


### エラー通知
* エラー時はexception_notificationによって、sakikazuのGmailにExceptionメールが送信される
* Exceptionメールが正しく動作しているかの確認は、「ActionController::InvalidAuthenticityToken」を出すのが手軽

### Webプッシュ通知
* Firebase Cloud Messagingを使っている
* Service Workerのこととか不明点が多く、一応は動作しているが、今後もっと簡潔になったらリファクタリングしたい
* 柔軟にプッシュ通知を送るには（スケジュール機能作った場合にその期限日の通知など）、FCMのAPIにPOSTする仕組みを作ってやる必要あり
* このためにpublic配下に置く必要があった静的ファイルがあり、それを本番で読み込めるようにNginx confに特定の設定がされている

### よく使うコマンド

#### デモデータ投入
```bash
bin/rake db:seed_fu
```
