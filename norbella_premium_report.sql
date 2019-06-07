select
io.campaign_name as "Line Item"
, d.platform as "Platform"
, ad.video_ad_format as "Ad Format"
, ad.name as "Creative"
, d.date as "Date"
, sum(impressions) as "Impressions"
, sum(reach) as "Reach"
, sum(views) as "Views"
, sum(clicks) as "Clicks"
, case when d.platform in ('Facebook','Instagram') then sum(completed_view) 
       when ad.video_ad_format = 'Discovery' then sum(completed_view*views)
       else sum(completed_view*impressions)
  end as "Completed Views"
, case when sum(sum(d.views*io.rate)) over (partition by io.campaign_name order by d.date, d.platform, ad.name, ad.video_ad_format) < io.cost then sum(d.views*io.rate)
       else greatest(0,sum(d.views*io.rate)-(sum(sum(d.views*io.rate)) over (partition by io.campaign_name order by d.date, d.platform, ad.name, ad.video_ad_format)-io.cost))
       end as "Spend"
, case when ad.video_ad_format = 'Discovery' then sum(views)
       else sum(impressions)
  end as "Quartile Denominator"

from (select name, id from salesforce.opportunity where project_number = 10371) as op

left join (select campaign_name, opportunity_id, rate, units, cost from salesforce.iolineitem) as io
on io.opportunity_id=op.id

left join(
select split_part(name,'_',1) as lineitem, name, 'yt_'||campaign_id as id
from adwords.aw_campaign where name like '%10371%'
union all
select split_part(name,'_',1) as lineitem, name, 'fb_'||ad_set_id as id 
from facebook.fb_ad_set where name like '%10371%'
)as c
on c.lineitem=io.campaign_name

left join (
select 'yt_'||campaign_id as id, 'yt_'||ad_group_ad_id as ad_id, youtube_video_title as video, name, case when (youtube_video_duration/1000) < 7 then 'Bumper' when video_ad_format = 'INDISPLAY' then 'Discovery' else 'InStream' end as video_ad_format
from adwords.aw_ad_group_ad
union all
select 'fb_'||ad_set_id as id , 'fb_'||ad_id as ad_id, name as video, name, '' as video_ad_format
from facebook.fb_ad
) as ad
on ad.id=c.id

left join (
select 'yt_'||ad_group_ad_id as ad_id, to_date(date) as date, 'YouTube' as platform, ifnull(clicks,0) as clicks,ifnull(video_views,0) as views,  impressions, ifnull(video_played_to_100_percent/100,0) as completed_view, 0 as reach
from adwords.aw_ad_group_ad_summary_daily where impressions >0
union all 
select 'fb_'||ad_id as ad_id, to_date(date) as date, case when placement like '%nstagram%' then 'Instagram' else 'Facebook' end as platform, ifnull(actions_link_click,0) as clicks,ifnull(VIDEO_10_SEC_WATCHED_VIDEO_VIEW,0) as views,  impressions, ifnull(VIDEO_P100_WATCHED,0) as completed_view, reach
from facebook.fb_ad_summary_daily_placement where impressions >0
) as d
on d.ad_id=ad.ad_id

where d.date < current_date()

group by 
platform
, ad.name
, io.campaign_name
, io.cost
, io.rate
, d.date
, ad.video_ad_format