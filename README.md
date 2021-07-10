HabitMachine
====

日々の記録やTODO管理ができるプライベートなサービス。SNS要素なし。
主に日記、習慣化のための記録、TODOリスト、markdownメモ、検索機能。
スマホView対応、PWA対応


## Features

* 日ごとのページに、日記、記録、TODOリストを設置
* 日記はタグ付け可能、画像添付可能、markdown対応（JSによるmarkdown入力補助あり）
* 日記は多面的な閲覧が可能（検索結果、「人生ハイライト」、「10年日記」）
* 日記からTODOリストを作成可能
  * TODOも日々の記録という位置づけで、この時期にこんなTODOがあって、これだけ完了させたという情報を記録
  * 日ごとのページからTODOを更新可能
* 習慣の記録データはグラフ表示可能
* turbolinksとVue.jsを共存
* レスポンシブデザインによるスマホView対応
* Vue.jsでSPA
* 検索結果ページで検索ワードのハイライト
* メモページはContentEditableを使ってhタグをリアルタイム反映、markdown入力補助、hタグから目次生成

## スクリーンキャプチャ
### 日ごとのページ
![HM、dayページ、github用](https://user-images.githubusercontent.com/745130/124608007-54e40100-dea9-11eb-84e3-dd5dc405a416.jpg)


### メモページ
![HM、メモページ、github用](https://user-images.githubusercontent.com/745130/124608034-59a8b500-dea9-11eb-94a2-b4b01b5614bb.jpg)


### 検索結果ページ
![HM、検索結果ページ、github用](https://user-images.githubusercontent.com/745130/124608070-5f9e9600-dea9-11eb-8392-44af41d9f329.jpg)


## Demo (heroku)
https://hm-a-dan.herokuapp.com/

テストユーザー
| email            | password  |
| ---------------- | --------- |
| test@example.com | password  |


## System dependencies

* ruby 2.7系
* rails 5.2系
* Vue.js 2.6系
* JavaScript ES2015以降

### 主なライブラリ
* Twitter bootstrap 4
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

### unicorn再起動
```
# 本番サーバーのRVMの問題か、unicorn:restartでは再起動できない場合がある
$ cap production unicorn:stop
$ cap production unicorn:start
```

### herokuデプロイ
```
$ git push heroku master
$ heroku run rake db:migrate
$ heroku open
# 必要なら
$ heroku restart
# エラー時はlog --tailで調査
$ heroku logs --tail
```

