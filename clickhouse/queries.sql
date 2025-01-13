SELECT data.commit.collection AS event, count() AS count, uniqExact(data.did) AS users FROM bluesky WHERE data.kind = 'commit' AND data.commit.operation = 'create' GROUP BY event ORDER BY count DESC;
SELECT data.commit.collection AS event, toHour(fromUnixTimestamp64Micro(data.time_us)) as hour_of_day, count() AS count FROM bluesky WHERE data.kind = 'commit' AND data.commit.operation = 'create' AND data.commit.collection in ['app.bsky.feed.post', 'app.bsky.feed.repost', 'app.bsky.feed.like'] GROUP BY event, hour_of_day ORDER BY hour_of_day, event;
SELECT data.did::String as user_id, min(fromUnixTimestamp64Micro(data.time_us)) as first_post_ts FROM bluesky WHERE data.kind = 'commit' AND data.commit.operation = 'create' AND data.commit.collection = 'app.bsky.feed.post' GROUP BY user_id ORDER BY first_post_ts ASC LIMIT 3;
SELECT data.did::String as user_id, date_diff( 'milliseconds', min(fromUnixTimestamp64Micro(data.time_us)), max(fromUnixTimestamp64Micro(data.time_us))) AS activity_span FROM bluesky WHERE data.kind = 'commit' AND data.commit.operation = 'create' AND data.commit.collection = 'app.bsky.feed.post' GROUP BY user_id ORDER BY activity_span DESC LIMIT 3;