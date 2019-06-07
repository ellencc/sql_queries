select 
channel_name as "Channel"
, channel_id as "Channel ID"
, date_trunc('month', to_date(date,'yyyymmdd')) as "Month"
, subtitle_language as "Subtitle Language"
, sum((average_view_duration_percentage/100)*views) as "Weighted % Watched"
, sum(views) as "Views"
, sum(watch_time_minutes) as "Watch Time"

from thresher.yt_channel_management_subtitles

where channel_id = 'UCH1NCeEsEXr1UlnfK6ydiYQ'

group by 
channel_name
, channel_id
, "Month"
, subtitle_language