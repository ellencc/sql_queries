select
op.name as "Opportunity"
, op.project_number as "Opportunity Number"
, case when lower(io.campaign_name) like '%sportsfans%' then 'Sports Fans'
       when lower(io.campaign_name) like '%beerbar%' then 'Beer Bar'
       when lower(io.campaign_name) like '%wings%' then 'Wings'
       when lower(io.campaign_name) like '%sporsfans%' then 'Sports Fans'
  end as "Campaign"
, split_part(io.campaign_name,'.',2) as "Geo"
, case when ag.name like '%nterest%' then 'Interests'
       when ag.name like '%eyword%' then 'Keyword'
       when ag.name like '%opic%' then 'Topics'
       when ag.name like '%lacement%' then 'Placements'
       when ag.name like '%Affinity%' then 'Custom Affinity'
       else ag.name
  end as "Target"
, io.campaign_name as "Line Item"
, io.flight_start_date as "Flight Start"
, io.flight_end_date as "Flight End"
, io.cost as "Budget"
, io.cost_structure as "Cost Structure"
, io.units as "Contracted Units"
, ad.name as "Ad Name"
, ad.video_name as "Video"
, ad.video_ad_format as "Ad Format"
, daily.date as "Date"
, sum(daily.impressions) as "Impressions"
, sum(daily.video_views) as "Views"

from (select id, name, project_number from salesforce.opportunity where advertiser = '001F000001oXxC8IAK' and flight_end_date >= '2019-01-01' and stage_name = 'Closed Won') as op


left join (select campaign_name, flight_start_date, flight_end_date, opportunity_id, contract_line_item, min(flight_start_date) over (partition by contract_line_item) as contract_line_start, max(flight_end_date) over (partition by contract_line_item) as contract_line_end
, cost_structure, cost, units, rate, media_budget, fee from salesforce.iolineitem where deleted='false') as io
on op.id=io.opportunity_id

left join(select campaign_id, name, split_part(name,'_',1) as join from adwords.aw_campaign) as campaign
on campaign.join=io.campaign_name

left join (select campaign_id, ad_group_id, name from adwords.aw_ad_group) as ag
on campaign.campaign_id=ag.campaign_id

left join(select ad_group_id, ad_group_ad_id, name, youtube_video_title as video_name, case when (youtube_video_duration/1000) <= 6 then 'Bumper' when video_ad_format = 'INDISPLAY' then 'Discovery' else initcap(video_ad_format) end as video_ad_format
from adwords.aw_ad_group_ad) as ad
on ad.ad_group_id=ag.ad_group_id

left join(select ad_group_ad_id, to_date(date) as date, impressions,ifnull(video_views,0) as video_views, ifnull(clicks,0) as clicks, cost as spend, ifnull(video_played_to_25_percent/100,0) as played_to_25p
, ifnull(video_played_to_50_percent/100,0) as played_to_50p, ifnull(video_played_to_75_percent/100,0) as played_to_75p, ifnull(video_played_to_100_percent/100,0) as played_to_100p
 from adwords.aw_ad_group_ad_summary_daily where impressions >0 and date >= '2019-01-01') as daily
on daily.ad_group_ad_id=ad.ad_group_ad_id

where daily.date <= current_date()

group by 
io.campaign_name
, ad.name
, io.cost_structure
, ad.video_ad_format
, ad.video_name
, io.cost
, op.name
, op.project_number
, io.contract_line_item
, "Target"
, io.units
, io.contract_line_start
, io.contract_line_end
, daily.date
, io.flight_start_date
, io.flight_end_date