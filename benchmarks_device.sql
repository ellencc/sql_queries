select 
 op.industry_serviced as "Industry Serviced"
, io.cost_structure as "Cost Structure"
, io.io_currency as "Currency"
, d.platform as "Platform"
--, d.date as "Date"
, case when d.device0 in ('ipad','ipod','android_tablet','Tablets with full browsers') then 'Tablet'
       when d.device0 in ('iphone','android_smartphone','Mobile devices with full browsers') then 'Mobile'
       when d.device0 in ('desktop','Computers') then 'Desktop'
       when d.device0 in ('Devices streaming video content to TV screens') then 'TV Screens'
       else 'Other'
   end as "Device"
, case when c.video_ad_format = 'FB/IG' then d.platform 
       when (upper(c.campaign_name) like '%BUMPER%' or upper(c.ad_group) like '%BUMPER%') then 'Bumper'
       when (upper(c.campaign_name) like '%TRUEVIEWACTION%' or upper(c.ad_group) like '%TRUEVIEWACTION%') then 'TrueView for Action'
       when (upper(c.campaign_name) like '%TRUEVIEWFORACTION%' or upper(c.ad_group) like '%TRUEVIEWFORACTION%') then 'TrueView for Action'
       when (upper(c.campaign_name) like '%TVFORACTION%' or upper(c.ad_group) like '%TVFORACTION%') then 'TrueView for Action'
       when c.video_ad_format = 'INDISPLAY' then 'Discovery'
       when c.video_ad_format = 'INSTREAM' then 'InStream'
       when c.video_ad_format is null then 'InStream'
       else c.video_ad_format 
  end as "Ad Format"
, case when lower(c.ad_group) like '%placement%' then 'Placements'
       when lower(c.ad_group) like '%interest%' then 'Interests'
       when lower(c.ad_group) like '%topic%' then 'Topics'
       when lower(c.ad_group) like '%keyword%' then 'Keywords'
       when lower(c.ad_group) like '%affinity%' then 'Custom Affinity'
       when lower(c.ad_group) like '%intent%' then 'Custom Intent'
       when lower(c.ad_group) like '%crm%' then 'CRM'
       when lower(c.ad_group) like '%customerdata%' then 'CRM'
       when lower(c.ad_group) like '%channel%' then 'Channels'
       when lower(c.ad_group) like '%remarketing%' then 'Remarketing'
       when lower(c.ad_group) like '%inmarket%' then 'InMarket'
       when lower(c.ad_group) like '%in market%' then 'InMarket'
       when lower(c.ad_group) like '%place%' then 'Places'
       when lower(c.ad_group) like '%apps%' then 'Apps'
       when lower(c.ad_group) like '%lifeevent%' then 'LifeEvents'
       when lower(c.ad_group) like '%step 1%' then 'Step 1'
       when lower(c.ad_group) like '%step 2%' then 'Step 2'
       when lower(c.ad_group) like '%step 3%' then 'Step 3'
       when lower(c.ad_group) like '%step 4%' then 'Step 4'
       when lower(c.ad_group) like '%in-market%' then 'InMarket'
       else ''
       end as "Target"
, c.objective as "Objective"
, c.optimization as "Optimization"
, sum(d.impressions) as "Impressions"
, sum(d.video_views) as "Views"
, sum(d.spend) as "Spend"
, sum(d.clicks) as "Clicks"
, sum(d.video_p100_watched) as "Played To 100p"
, sum(d.engagements) as "Engagements"
, sum(d.conversions) as "Conversions"
, sum(d.conversions_registrations) as "Conversions Registrations"


from (select name, id, industry_serviced from salesforce.opportunity where stage_name = 'Closed Won' and flight_end_date >= '2017-01-01') as Op

left join (select campaign_name, opportunity_id, case when opportunity_id='0062A00000t69nYQAQ' then name else campaign_name end as join, cost_structure, io_currency from salesforce.iolineitem
where deleted = 'false' and source = 'SALESFORCE') as io
on Op.id=io.opportunity_id

left join(
Select 'yt_'||ag.aw_ad_group_id as id, campaign.name as campaign_name, ag.name as ad_group, case when account_id in('1933','1937','1936','2681','2682','1934','1935') then right(campaign.name,13) else split_part(campaign.name,'_',1) end as join, '' as optimization, '' as objective, ag.video_ad_format
from adwords.aw_campaign as campaign
left join (select campaign_id, ad_group_id, name, video_ad_format,aw_ad_group_id from adwords.aw_ad_group) as ag
on ag.campaign_id=campaign.campaign_id
where campaign.state not in ('REMOVED')
Union all
Select 'fb_'||ad_set_id as id, name as campaign_name,'' as ad_group, split_part(name,'_',1) as join, optimization_goal as optimization, fb_campaign.objective as objective, 'FB/IG' as video_ad_format
from facebook.fb_ad_set left join (select campaign_id, objective from facebook.fb_campaign) as fb_campaign on facebook.fb_ad_set.campaign_id=fb_campaign.campaign_id
) as c
on c.join=io.join

left join
(select 'yt_'||adgroupid as id, 'YouTube' as platform, device as device0, to_date(date) as date, clicks, impressions, cost/1000000 as spend, videoviews as video_views, ((videoquartile100rate/100)*impressions) as video_p100_watched, 0 as page_likes, 0 as post_likes, 0 as view_10sec, ifnull(conversions,0) as conversions, ifnull(conversions,0) as conversions_registrations, engagements
from adwords.aw_ad_group_devices where impressions > 0
Union all
Select 'fb_'||ad_set_id as id, case when placement like '%nstagram%' then 'Instagram' else 'Facebook' end as platform, impression_device as device0,  to_date(date) as date, actions_link_click as clicks, impressions, spend, actions_video_view as video_views, video_p100_watched, actions_like as page_likes, actions_post_reaction as post_likes, video_10_sec_watched_video_view as view_10sec, ifnull(actions_offsite_conversion_fb_pixel_purchase,0) as conversions, ifnull(actions_offsite_conversion_fb_pixel_complete_registration,0) as conversions_registrations, actions_post_engagement-actions_video_view as engagements
From facebook.fb_ad_set_summary_daily_placement where impressions > 0
) as d
on d.id=c.id

where d.date > '2017-01-01'

group by
op.industry_serviced
, io.cost_structure
, d.platform
, c.video_ad_format
, io.io_currency
, c.objective
, c.optimization
, "Ad Format"
, "Target"
, "Device"
--, d.date