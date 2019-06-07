select 
 op.industry_serviced
, io.cost_structure
, io.io_currency
, d.platform
--, d.date
, case when ad.video_ad_format in ('FB', 'TW') then d.platform 
       when (ad.youtube_video_duration <= 7 and ad.youtube_video_duration > 0) then 'Bumper'
       when (upper(c.campaign_name) like '%TRUEVIEWACTION%' or upper(c.ad_group) like '%TRUEVIEWACTION%') then 'TrueView for Action'
       when (upper(c.campaign_name) like '%TRUEVIEWFORACTION%' or upper(c.ad_group) like '%TRUEVIEWFORACTION%') then 'TrueView for Action'
       when (upper(c.campaign_name) like '%TVFORACTION%' or upper(c.ad_group) like '%TVFORACTION%') then 'TrueView for Action'
       when ad.video_ad_format = 'INDISPLAY' then 'Discovery'
       when ad.video_ad_format = 'INSTREAM' then 'InStream'
       when ad.video_ad_format is null then 'InStream'
       else video_ad_format 
  end as ad_format
, case when c.ad_group like '%Placement%' then 'Placements'
       when c.ad_group like '%Interest%' then 'Interests'
       when c.ad_group like '%Topic%' then 'Topics'
       when c.ad_group like '%Keyword%' then 'Keywords'
       when c.ad_group like '%Affinity%' then 'Custom Affinity'
       when c.ad_group like '%Intent%' then 'Custom Intent'
       when c.ad_group like '%CRM%' then 'CRM'
       when c.ad_group like '%CustomerData%' then 'CRM'
       when c.ad_group like '%Channel%' then 'Channels'
       when c.ad_group like '%Remarketing%' then 'Remarketing'
       when c.ad_group like '%InMarket%' then 'InMarket'
       when c.ad_group like '%Place%' then 'Places'
       when c.ad_group like '%Apps%' then 'Apps'
       when c.ad_group like '%LifeEvent%' then 'LifeEvents'
       else c.ad_group
       end as "Target"
, c.objective
, c.optimization
, ad.youtube_video_duration as video_duration
, sum(d.impressions) as impressions
, sum(d.video_views) as views
, sum(d.spend) as spend
, sum(d.clicks) as clicks
, sum(d.video_p100_watched) as played_to_100p
, sum(d.engagements) as engagements
, sum(d.conversions) as conversions
, sum(d.conversions_registrations) as conversions_registrations


from (select name, id, industry_serviced from salesforce.opportunity where stage_name = 'Closed Won' and flight_end_date >= '2017-01-01') as Op

left join (select campaign_name, opportunity_id, case when opportunity_id='0062A00000t69nYQAQ' then name else campaign_name end as join, cost_structure, io_currency from salesforce.iolineitem
where deleted = 'false' and source = 'SALESFORCE') as io
on Op.id=io.opportunity_id

left join(
Select 'yt_'||ag.ad_group_id as id, campaign.name as campaign_name, ag.name as ad_group, case when account_id in('1933','1937','1936','2681','2682','1934','1935') then right(campaign.name,13) else split_part(campaign.name,'_',1) end as join, '' as optimization, '' as objective
from adwords.aw_campaign as campaign
left join (select campaign_id, ad_group_id, name from adwords.aw_ad_group) as ag
on ag.campaign_id=campaign.campaign_id
where campaign.state not in ('REMOVED')
Union all
Select 'fb_'||ad_set_id as id, name as campaign_name,'' as ad_group, split_part(name,'_',1) as join, optimization_goal as optimization, fb_campaign.objective as objective
from facebook.fb_ad_set left join (select campaign_id, objective from facebook.fb_campaign) as fb_campaign on facebook.fb_ad_set.campaign_id=fb_campaign.campaign_id
) as c
on c.join=io.join
         
left join(
Select 'yt_'||ad_group_id as id, 'yt_'||ad_group_ad_id as ad_id, youtube_video_duration/1000 as youtube_video_duration, video_ad_format
from adwords.aw_ad_group_ad
Union all
Select 'fb_'||ad_set_id as id, 'fb_'||ad_id as ad_id, 0 as youtube_video_duration, 'FB' as video_ad_format
from facebook.fb_ad) as ad
on c.id=ad.id 


left join
(select 'yt_'||ad_group_ad_id as ad_id, 'YouTube' as platform, to_date(date) as date, clicks, impressions, cost as spend, video_views, ((video_played_to_100_percent/100)*impressions) as video_p100_watched, 0 as page_likes, 0 as post_likes, 0 as view_10sec, ifnull(conversions,0) as conversions, ifnull(conversions,0) as conversions_registrations, engagements
from adwords.aw_ad_group_ad_summary_daily where impressions > 0
Union all
Select 'fb_'||ad_id as ad_id, case when placement like '%nstagram%' then 'Instagram' else 'Facebook' end as platform, to_date(date) as date, actions_link_click as clicks, impressions, spend, actions_video_view as video_views, video_p100_watched, actions_like as page_likes, actions_post_reaction as post_likes, video_10_sec_watched_video_view as view_10sec, ifnull(actions_offsite_conversion_fb_pixel_purchase,0) as conversions, ifnull(actions_offsite_conversion_fb_pixel_complete_registration,0) as conversions_registrations, actions_post_engagement-actions_video_view as engagements
From facebook.fb_ad_summary_daily_placement where impressions > 0
) as d
on d.ad_id=ad.ad_id

where d.date > '2017-01-01'

group by
-- d.date
 op.industry_serviced
, io.cost_structure
, d.platform
, ad.video_ad_format
, ad.youtube_video_duration
, io.io_currency
, c.objective
, c.optimization
, ad_format
, "Target"