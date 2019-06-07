select 
yt_channel_id as "YT Channel ID"
, yt_video_id as "YT Video ID"
, scheduled_start_time as "Scheduled Start Time"
, actual_start_time as "Actual Start Time"
, actual_end_time as "Actual End Time"
, to_timestamp_ntz(modified) as "Modified"
, concurrent_viewers as "Concurrent Viewers"

from thresher.live_yt_video_stats_history

where scheduled_start_time >= '2019-01-01'

order by yt_channel_id, yt_video_id, modified

