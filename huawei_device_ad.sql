select 
op.name as "Opportunity"
, op.project_number as "Project Number"
, daily.date as "Date"
, io.campaign_name as "Line Item"
, io.flight_start_date as "Start Date"
, io.flight_end_date as "End Date"
, io.cost_structure as "Cost Structure"
, campaign.name as "Campaign"
, ag.name as "Ad Group"
, ad.name as "Ad Name"
, ad.video as "Video"
, daily.device as "Device"
, case when campaign.name like '%Bumper%' then 'Bumper' 
       when ag.video_ad_format = 'INDISPLAY' then 'Discovery'
       else 'InStream'
   end as "Video Ad Format"
, sum(daily.impressions) as "Impressions"
, sum(daily.video_views) as "Video Views"
, io.rate as "Avg. Cost Per View/Impression (USD)"
, io.cost as "Line Item Revenue"
, sum(daily.spend) as "Actual Spend"
, case when sum(sum(daily.video_views*io.rate)) over (partition by io.campaign_name order by date, ad.name, ad.video, campaign.name) <= io.cost then sum(daily.video_views*io.rate)
      else greatest(0,sum(daily.video_views*io.rate)-(sum(sum(daily.video_views*io.rate)) over (partition by io.campaign_name order by date, ad.name, ad.video, campaign.name)-io.cost))
   end as "Client Spend (USD)"
, case when sum(sum(daily.video_views*io.rate)) over (partition by io.campaign_name order by date, ad.name, ad.video, campaign.name) <= io.cost then 0
      else sum(daily.video_views*io.rate)-greatest(0,sum(daily.video_views*io.rate)-(sum(sum(daily.video_views*io.rate)) over (partition by io.campaign_name order by date, ad.name, ad.video, campaign.name)-io.cost))
  end as "Added Value (USD)"
, sum(daily.clicks) as "Clicks"
, sum(daily.engagements) as "Engagements"
, sum(daily.all_conversions) as "All Conversions"
, sum(case when ag.video_ad_format = 'INDISPLAY' then daily.played_to_25p*daily.video_views else daily.played_to_25p*daily.impressions end) as "Played To 25%"
, sum(case when ag.video_ad_format = 'INDISPLAY' then daily.played_to_50p*daily.video_views else daily.played_to_50p*daily.impressions end) as "Played To 50%"
, sum(case when ag.video_ad_format = 'INDISPLAY' then daily.played_to_75p*daily.video_views else daily.played_to_75p*daily.impressions end) as "Played To 75%"
, sum(case when ag.video_ad_format = 'INDISPLAY' then daily.played_to_100p*daily.video_views else daily.played_to_100p*daily.impressions end) as "Played To 100%"
, sum(case when ag.video_ad_format = 'INDISPLAY' then daily.video_views else daily.impressions end) as "Quartile Denominator"
, sum(earned.earned_subscribers) as "Earned Subscribers"
, sum(earned.earned_views) as "Earned Views"
, sum(earned.earned_playlist_additions) as "Earned Playlist Additions"
, sum(earned.earned_likes) as "Earned Likes"
, sum(earned.earned_shares) as "Earned Shares"

from (select id, name, project_number from salesforce.opportunity where advertiser = '0012A00002XDFqoQAH' and account_id = '001F000001I0YEgIAN' and flight_start_date >= '2019-01-01') as op

left join (select name, campaign_name, flight_start_date, flight_end_date, units, opportunity_id, cost_structure, cost, rate, media_budget, fee from salesforce.iolineitem where deleted = 'false') as io
on op.id=io.opportunity_id

left join(select campaign_id, name, right(name,13) as join, state from adwords.aw_campaign) as campaign
on campaign.join=io.name

left join (select campaign_id, ad_group_id, aw_ad_group_id, video_ad_format, name from adwords.aw_ad_group) as ag
on campaign.campaign_id=ag.campaign_id

left join (select ad_group_id, aw_ad_group_ad_id, youtube_video_title as video, name, youtube_video_duration as ad_length from adwords.aw_ad_group_ad) as ad
on ad.ad_group_id=ag.ad_group_id

left join(select adid as ad_group_ad_id, to_date(date) as date, case when device = 'Mobile devices with full browsers' then 'Mobile' when device = 'Tablets with full browsers' then 'Tablet' when device = 'Devices streaming video content to TV screens' then 'TV Screens' when device = 'Computers' then 'Desktop' else 'Other' end as device,
 impressions, ifnull(clicks,0) as clicks, ifnull(videoviews,0) as video_views, cost as spend, ifnull(videoquartile25rate/100,0) as played_to_25p, ifnull(videoquartile50rate/100,0) as played_to_50p, ifnull(videoquartile75rate/100,0) as played_to_75p, ifnull(videoquartile100rate/100,0) as played_to_100p, ifnull(conversions,0) as conversions,ifnull(conversions,0) as conversions_registrations,ifnull(viewthroughconversions,0) as view_through_conversions, ifnull(allconversions,0) as all_conversions, ifnull(conversionvalue,0) as conversion_value, engagements
from adwords.aw_ad_group_ad_devices where impressions > 0) as daily
on daily.ad_group_ad_id=ad.aw_ad_group_ad_id

left join (select adgroupadid, youtubeearnedsubscribers as earned_subscribers, youtubeearnedviews as earned_views, youtubeearnedplaylistadditions as earned_playlist_additions, youtubeearnedlikes as earned_likes, youtubeearnedshares as earned_shares
from adwords.aw_ad_group_ad_earned_metrics) as earned
on ag.ad_group_id=earned.adgroupadid

where impressions > 0 

group by 
 io.rate
, io.units
, io.cost
, io.campaign_name
, io.cost_structure
, daily.date
, io.flight_start_date
, io.flight_end_date
, io.cost_structure
, ag.name
, ad.name
, op.name
, op.project_number 
, campaign.name
,"Video Ad Format"
, daily.device
, ad.video
, ad.ad_length

order by "Line Item"