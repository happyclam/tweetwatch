json.array!(@tracks) do |track|
  json.extract! track, :id, :tag, :user_id
  json.url track_url(track, format: :json)
end
