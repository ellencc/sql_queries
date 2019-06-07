select 
op.name as "Opportunity"
, op.project_number as "Opportunity Number"
, case when lower(io.campaign_name) like '%sportsfans%' then 'Sports Fans'
       when lower(io.campaign_name) like '%beerbar%' then 'Beer Bar'
       when lower(io.campaign_name) like '%wings%' then 'Wings'
       when lower(io.campaign_name) like '%sporsfans%' then 'Sports Fans'
  end as "Campaign"
, split_part(io.campaign_name,'.',2) as "Geo"
, io.campaign_name as "Line Item"
, io.flight_start_date as "Flight Start"
, io.flight_end_date as "Flight End"
, daily.date as "Date"
, age.name as "Age"
, sum(daily.impressions) as "Impressions"
, sum(daily.video_views) as "Video Views"
, sum(daily.clicks) as "Clicks"
 

from (select id, name, project_number from salesforce.opportunity where advertiser = '001F000001oXxC8IAK' and flight_start_date >= '2019-01-01') as op

left join (select campaign_name, flight_start_date, flight_end_date,contract_line_item, min(flight_start_date) over (partition by contract_line_item) as contract_line_start, max(flight_end_date) over (partition by contract_line_item) as contract_line_end
, units, opportunity_id, cost_structure, cost, rate, media_budget, fee
 from salesforce.iolineitem where deleted = 'false') as io
on op.id=io.opportunity_id

left join (select name,split_part(name,'_',1) as join, campaign_id from adwords.aw_campaign) as campaign
on campaign.join=io.campaign_name

left join (select name, campaign_id, ad_group_id, video_ad_format from adwords.aw_ad_group) as ag
on ag.campaign_id=campaign.campaign_id

left join (select ad_group_id, to_date(date) as date, age_id, impressions, clicks, video_views, video_played_to_25_percent, video_played_to_50_percent, video_played_to_75_percent, video_played_to_100_percent, conversions from adwords.aw_age_summary_daily) as daily
on daily.ad_group_id=ag.ad_group_id

left join (select age_id, name from adwords.aw_age) as age
on age.age_id=daily.age_id

where impressions > 0 

group by
age.name
, op.name
, io.campaign_name
, daily.date
, op.project_number
, io.flight_start_date
, io.flight_end_date
