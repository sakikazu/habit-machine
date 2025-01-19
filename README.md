HabitMachine
====

日々のいろんな記録ができるサービス。
基本プライベートで、特定機能は家族と共有できる。
主な機能は、日記、登録した項目の記録、目次付きノート、家族の記録、検索。
スマホView、PWA対応

## 機能の詳細（技術についてを含む）
* 日ごとのページに、日記、記録を設置して、日々の記録をやりやすく
* 日記はタグ付け、画像添付、markdown対応（markdown入力補助あり）
* 日記は多面的な閲覧が可能（「人生ハイライト」、「10年日記」、検索結果）
* 日記を固定表示にすることで、簡易的なTODOリストを作成可能
* 記録データはグラフ表示可能
* turbolinksを使っているが、Vue.jsが入ったページではOFF
* レスポンシブデザインによるスマホView対応
* Vue.jsでSPA
* 検索結果ページで検索ワードのハイライト
* ノートページはContentEditableを使ってhタグをリアルタイム反映、markdown入力補助、hタグから目次生成

## スクリーンキャプチャ
### 日ごとのページ
<img width="1175" alt="2023-02-19_HMキャプチャ（Github用）" src="https://user-images.githubusercontent.com/745130/219923097-3249e197-d0cd-41a3-8c36-ec5ce7182e90.png">


### ノートページ
<img width="1172" alt="image" src="https://user-images.githubusercontent.com/745130/219923297-419e8bd1-fd56-4c41-9a00-6d59faa08363.png">


### 検索結果ページ
<img width="1168" alt="image" src="https://user-images.githubusercontent.com/745130/219923506-d67a507c-8b8f-4205-9cf2-69bf6e56384d.png">


## 開発
```
$ docker compose up
$ bin/webpack-dev-server
```

## 本番デプロイ
```
# 意図せぬruby環境のcapを使用しないよう、bundle execをつける
$ bundle exec cap production deploy
```

## デモ環境
* ※現在は、必要なときにterraformでAWS ECSにデプロイしている

テストユーザー
| email            | password  |
| ---------------- | --------- |
| test@example.com | password  |


## System dependencies

* ruby 3.2系
* rails 6.1系
* Vue.js 2.6系
* JavaScript ES2015以降
* Node 14.17.0
  * v16にするとエラーになる

### 主なライブラリ
* Twitter bootstrap 4: https://getbootstrap.jp/docs/4.2/getting-started/introduction/
* Font Awesome: https://fontawesome.com/v4.7.0/icons/#
* テンプレートエンジン: slim
* altCSS: scss, sass

### ミドルウェア
* postfix（死活監視はなし）

### サービス
特になし


# 自分用メモ、古いメモ

## Knowhow

* 日記のmarkdown入力補助はJSをjQueryモジュール化している
* 各所にCSS flexboxを用いてレイアウト


## Deployment instructions
* config/deploy.rbに記載されているlinked_files, linkded_dirsに意識すればOK

## Backup
サーバー側のcronでDBのdumpを行い、
ローカルPCのcronでDB dumpとアップロードファイルをローカルPC内部に保存している


## Other

### bitbucket's README.md
https://bitbucket.org/tutorials/markdowndemo/src/master/

### エラー通知
* エラー時はexception_notificationによって、sakikazuのGmailにExceptionメールが送信される
* Exceptionメールが正しく動作しているかの確認は、「ActionController::InvalidAuthenticityToken」を出すのが手軽

### webプッシュ通知
* Firebase Cloud Messagingを使っている
* Service Workerのこととか不明点が多く、一応は動作しているが、今後もっと簡潔になったらリファクタリングしたい
* 柔軟にプッシュ通知を送るには（スケジュール機能作った場合にその期限日の通知など）、FCMのAPIにPOSTする仕組みを作ってやる必要あり
* このためにpublic配下に置く必要があった静的ファイルがあり、それを本番で読み込めるようにNginx confに特定の設定がされている

## よく使うコマンド

### デモデータ投入
```
$ bin/rake db:seed_fu
```


## TODO
* webpackerあたりでハマることが多いので脱却したい
  * rails7のesbuildへの移行
  * Viteの採用（HMR、Vue.jsとの相性が良い）
    * `vite_rails` gem

