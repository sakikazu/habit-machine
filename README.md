HabitMachine
====

日記機能と習慣化のための記録を行うサービス


## Features

* 日記はタグ対応（オートコンプリート）、markdown対応（JSによるmarkdown入力補助あり）
* 日記は多面的な閲覧が可能（検索、人生ハイライト、10年日記）
* 習慣の記録データはグラフ表示対応
* turbolinksによる高速表示
* レスポンシブデザインによるスマホView対応
* best_in_placeでインライン編集
* UIはまあまあ考えてある


## System dependencies

### Ruby version
* ruby 2.5
* rails 5.2

### ライブラリ
* Twitter bootstrap 4
* Font Awesome: https://fontawesome.com/v4.7.0/icons/#
* テンプレートエンジン: slim
* altCSS: scss

### ミドルウェア
* メール送信: postfix（死活監視はしていない）

### サービス
特になし


## Knowhow

* 日記のmarkdown入力補助はJSをjQueryモジュール化している
* 各所にCSS flexboxを用いてレイアウト
* turbolinksを意識したJSの記述方法（ソース参照）

## heroku

```
todo
```

## Deployment instructions
* config/deploy.rbに記載されているlinked_files, linkded_dirsに意識すればOK

## Backup
サーバー側のcronでDBのdumpを行い、
ローカルPCのcronでDB dumpとアップロードファイルをローカルPC内部に保存している


## Issues

* 基本的には、TODOはEvernoteに記載している。あとソース上にも。
* TDD
* 下記、旧TODO
```
・折れ線グラフの結果
・Habit、TagのデータはYAMLでエクスポートしてインポートできるようにする
　→とりあえずconsoleでできるように
  →うーん、初期データを一つのファイルにして一気に入れられるような仕組みかなぁ。。
  　タグ用のDiaryとか。今日の点数は俺用なのでいらんか

・複数人で使うようになったら、Diaryの_editにあるタグのAutoCompleteは、当人のdiariesから取得するようにする。今はTag.allなので。
　その際、予め使用するタグを決めたい場合は、タグ登録用のDiaryを作っておけばいいが、
　そのための機能を作る？全タグを登録した特別日記を作る。
・応援機能（？）
・リマインダ機能（？）
```


## OTHER

### bitbucket's README.md
https://bitbucket.org/tutorials/markdowndemo/src/master/

### エラー処理
* エラー時はexception_notificationによって、sakikazuのGmailにExceptionメールが送信される


## よく使うコマンド

### unicorn再起動
```
# 本番サーバーのRVMの問題か、unicorn:restartでは再起動できない場合がある
$ cap production unicorn:stop
$ cap production unicorn:start
```

