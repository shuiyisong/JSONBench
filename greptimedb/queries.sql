SELECT commit_collection AS event, count(1) AS cnt FROM jsontable GROUP BY event ORDER BY cnt DESC;
SELECT commit_collection AS event, count(1) AS cnt, count(DISTINCT did) AS users FROM jsontable WHERE kind = 'commit' AND commit_operation = 'create' GROUP BY event ORDER BY cnt DESC;
SELECT commit_collection AS event, date_part('hour', time_us) AS hour_of_day, count(1) AS cnt FROM jsontable WHERE kind = 'commit' AND commit_operation = 'create' AND commit_collection IN('app.bsky.feed.post', 'app.bsky.feed.repost', 'app.bsky.feed.like') GROUP BY event, hour_of_day ORDER BY hour_of_day, event;
SELECT did AS user_id, min(time_us) AS first_post_ts FROM jsontable WHERE kind = 'commit' AND commit_operation = 'create' AND commit_collection = 'app.bsky.feed.post' GROUP BY user_id ORDER BY first_post_ts ASC LIMIT 3;
SELECT did AS user_id, date_part('millisecond',(max(time_us) - min(time_us))) AS activity_span FROM jsontable WHERE kind = 'commit' AND commit_operation = 'create' AND commit_collection = 'app.bsky.feed.post' GROUP BY user_id ORDER BY activity_span DESC LIMIT 3;