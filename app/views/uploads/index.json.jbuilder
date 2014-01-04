json.array!(@uploads) do |upload|
  json.extract! upload, :id, :slug, :filename, :views
  json.url upload_url(upload, format: :json)
end
