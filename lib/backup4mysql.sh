#!/bin/sh

db='habitm'
user='root'
password_file='/usr/local/site/habit-machine/current/config/mysqldump.ini'

# バックアップファイルを何日分残しておくか
period=7
# バックアップファイルを保存するディレクトリ
dirpath='/home/sakikazu/bak'

# ファイル名を定義(※ファイル名で日付がわかるようにしておきます))
filename="$db"_`date +%y%m%d`

# mysqldump実行
# 「Using a password on the command line interface can be insecure」対応のため、パスワードはファイル指定
mysqldump --defaults-extra-file=$password_file -u $user $db | gzip -c > $dirpath/$filename.sql.gz

# パーミッション変更
#chmod 700 $dirpath/$filename.sql

# 古いバックアップファイルを削除
oldfile="$db"_`date --date "$period days ago" +%y%m%d`
rm -f $dirpath/$oldfile.sql.gz

# このシェルを実行したプログラムでバックアップファイル名を取得したい時のために、標準出力する
echo $dirpath/$filename.sql.gz
