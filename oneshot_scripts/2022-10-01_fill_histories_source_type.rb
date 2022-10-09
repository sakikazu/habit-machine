# 既存のHistoryはすべてChildのため、Childとして設定
History.update_all(source_type: 'Child')
# アップロード画像のパスを変更
FileUtils.mv(Rails.root.join("public/upload/child_history"), Rails.root.join("public/upload/history"))

# HistoryのFamilyを設定
History.all.each do |history|
  family = if history.source.is_a?(Family)
             history.source
           else
             history.source.family
           end
  history.update(family: family)
end
