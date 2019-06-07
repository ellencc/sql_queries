select 
name as "Channel"
, channel as "Channel ID"
, date_trunc('month', to_date(day)) as "Month"
, sum(views) as "Views"
, sum((averageviewpercentage/100)*views) as "Weighted View % Watched"
, sum(estimatedminuteswatched) as "Minutes Watched"
, sum(subscribersgained) as "Subscribers Gained"
, sum(subscriberslost) as "Subscribers Lost"
, sum(likes) as "Likes"
, sum(comments) as "Comments"
, sum(cardclicks) as "Card Clicks"
, sum(shares) as "Shares"

from thresher.yt_channel_management_analytics

where channel = 'UCH1NCeEsEXr1UlnfK6ydiYQ'

group by name
, channel
, "Month"

union all

select 
channelname as "Channel"
, channelid as "Channel ID"
--, date_from_parts(left(month,4),right(month,2),1) as "Month"
, to_date(month,'yyyy-mm') as "Month"
, sum(views) as "Views"
, sum((averageviewpercentage/100)*views) as "Weighted View % Watched"
, sum(estimatedminuteswatched) as "Minutes Watched"
, sum(subscribersgained) as "Subscribers Gained"
, sum(subscriberslost) as "Subscribers Lost"
, sum(likes) as "Likes"
, sum(comments) as "Comments"
, sum(cardclicks) as "Card Clicks"
, sum(shares) as "Shares"

from thresher.yt_channel_management_data

where channelid = 'UCH1NCeEsEXr1UlnfK6ydiYQ'

group by channelname
, channelid
, "Month"

order by "Month"