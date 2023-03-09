json.record do
  json.id record.id
  json.value record.displaying_value
  json.memo record.memo
  json.markdowned_memo markdown(record.memo)
end
