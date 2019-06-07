select 
channel_name as "Channel"
, channel_id as "Channel ID"
, date_trunc('month', to_date(date,'yyyymmdd')) as "Month"
, sum(END_SCREEN_ELEMENT_CLICKS) as "End Screen Clicks"
, sum(END_SCREEN_ELEMENT_impressions) as "End Screen Impressions"

from thresher.yt_channel_management_end_screens

where channel_id = 'UCH1NCeEsEXr1UlnfK6ydiYQ'

group by 
channel_name
, channel_id
, "Month"
