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
, daily.device as "Device"
, sum(daily.impressions) as "Impressions"
, sum(daily.video_views) as "Video Views"
, sum(daily.clicks) as "Clicks"

from (select id, name, project_number from salesforce.opportunity where advertiser = '001F000001oXxC8IAK' and flight_start_date >= '2019-01-01') as op

left join (select campaign_name, flight_start_date, flight_end_date,contract_line_item, min(flight_start_date) over (partition by contract_line_item) as contract_line_start, max(flight_end_date) over (partition by contract_line_item) as contract_line_end
, units, opportunity_id, cost_structure, cost, rate, media_budget, fee
 from salesforce.iolineitem where deleted = 'false') as io
on op.id=io.opportunity_id

left join(select campaign_id, name, split_part(name,'_',1) as join, state from adwords.aw_campaign) as campaign
on campaign.join=io.campaign_name

left join (select campaign_id, ad_group_id, aw_ad_group_id, video_ad_format, name from adwords.aw_ad_group) as ag
on campaign.campaign_id=ag.campaign_id

left join(select adgroupid as ad_group_id, to_date(date) as date, case when device = 'Mobile devices with full browsers' then 'Mobile' when device = 'Tablets with full browsers' then 'Tablet' when device = 'Devices streaming video content to TV screens' then 'TV Screens' when device = 'Computers' then 'Desktop' else 'Other' end as device,
 impressions, ifnull(clicks,0) as clicks, ifnull(videoviews,0) as video_views, cost as spend, ifnull(videoquartile25rate/100,0) as played_to_25p, ifnull(videoquartile50rate/100,0) as played_to_50p, ifnull(videoquartile75rate/100,0) as played_to_75p, ifnull(videoquartile100rate/100,0) as played_to_100p, ifnull(conversions,0) as conversions,ifnull(conversions,0) as conversions_registrations,ifnull(viewthroughconversions,0) as view_through_conversions, ifnull(allconversions,0) as all_conversions, ifnull(conversionvalue,0) as conversion_value, engagements
from adwords.aw_ad_group_devices where impressions >0) as daily
on daily.ad_group_id=ag.aw_ad_group_id

where impressions > 0
and daily.date <= current_date()

group by 
 io.rate
, io.units
, io.cost
, io.campaign_name
, daily.date
, io.flight_start_date
, io.flight_end_date
, op.name
, op.project_number 
, daily.device
