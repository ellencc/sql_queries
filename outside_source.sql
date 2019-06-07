select 
channel_name as "Channel"
, channel_id as "Channel ID"
, date_trunc('month', to_date(date,'yyyymmdd')) as "Month"
, case  when traffic_source_type = '0' then 'Direct or Unknown'
        when traffic_source_type = '1' then 'YouTube Advertising'
        when traffic_source_type = '3' then 'Browse Features'
        when traffic_source_type = '4' then 'YouTube Channels'
        when traffic_source_type = '5' then 'YouTube Search'
        when traffic_source_type = '7' then 'Suggested Videos'
        when traffic_source_type = '8' then 'Other YouTube Features'
        when traffic_source_type = '9' then 'External'
        when traffic_source_type = '11' then 'Video Cards And Annotations'
        when traffic_source_type = '14' then 'Playlists'
        when traffic_source_type = '17' then 'Notifications'
        when traffic_source_type = '18' then 'Playlist Pages'
        when traffic_source_type = '19' then 'Programming From Claimed Content'
        when traffic_source_type = '20' then 'Interactive Video Endscreen'
  end as "Traffic Source"
, sum((average_view_duration_percentage/100)*views) as "Weighted % Watched"
, sum(views) as "Views"
, sum(watch_time_minutes) as "Watch Time"

from thresher.yt_channel_management_sources

where channel_id = 'UCH1NCeEsEXr1UlnfK6ydiYQ'

group by 
channel_name
, channel_id
, "Month"
, "Traffic Source"
