History.update_all(source_type: 'Child')
# アップロード画像のパスを変更
FileUtils.mv(Rails.root.join("public/upload/child_history"), Rails.root.join("public/upload/history"))
