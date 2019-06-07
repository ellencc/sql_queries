select
c.name as "Campaign SF"
, c.ad_group as "Ad Group SF"
, ad.name as "Ad Name SF"
, ad.video as "Video SF"
, ad.ad_length as "Ad Length"
, ad.video_ad_format as  "Ad Format"
, d.platform as "Platform SF"
, d.date as "Date SF"
, sum(d.impressions) as "Impressions"
, sum(d.clicks) as "Clicks"
, case when platform = 'YouTube' then sum(d.video_views) 
       else sum(d.thruplays) 
  end as "Views"
, sum(case when platform = 'YouTube' then 0 else d.video_views end) as "FB 3 Sec View"
, sum(d.view_10sec) as "FB 10 Sec Views"
, sum(d.thruplays) as "FB ThruPlays"
, sum(d.spend) as "Spend"
, sum(d.conversions) as "Conversions"
, sum(d.conversions_registrations) as "Conversions Registrations"
, sum(d.engagements) as "Engagements"
, sum(d.post_reactions) as "Reactions"
, sum(d.page_likes) as "Page Likes"
, case when d.platform = 'YouTube' then
                case when ad.video_ad_format = 'Discovery' then sum(d.video_p25_watched*d.video_views)
                     else  sum(d.video_p25_watched*d.impressions)
                end
       else sum(d.video_p25_watched)
  end as "Played to 25p"
, case when d.platform = 'YouTube' then
                case when ad.video_ad_format = 'Discovery' then sum(d.video_p50_watched*d.video_views)
                     else  sum(d.video_p50_watched*d.impressions)
                end
       else sum(d.video_p50_watched)
  end as "Played to 50p"
, case when d.platform = 'YouTube' then
                case when ad.video_ad_format = 'Discovery' then sum(d.video_p75_watched*d.video_views)
                     else  sum(d.video_p75_watched*d.impressions)
                end
       else sum(d.video_p75_watched)
  end as "Played to 75p"
, case when d.platform = 'YouTube' then
                case when ad.video_ad_format = 'Discovery' then sum(d.video_p100_watched*d.video_views)
                     else  sum(d.video_p100_watched*d.impressions)
                end
       else sum(d.video_p100_watched)
  end as "Played to 100p"
, case when ad.video_ad_format = 'Discovery' then sum(d.video_views)
       else sum(d.impressions)
  end as "Quartile Denominator"
    
from
(select 'yt_'||ag.ad_group_id as id, name as name, ag.adgroup as ad_group
from adwords.aw_campaign as campaign
left join (select campaign_id, ad_group_id, name as adgroup from adwords.aw_ad_group) as ag
on ag.campaign_id=campaign.campaign_id
where name like '%XPStudy%'
union all
select 'fb_'||ad_set_id as id, name, name as ad_group
from facebook.fb_ad_set where name like '%XPStudy%'
) as c

left join
(select 'yt_'||ad_group_id as id, 'yt_'||ad_group_ad_id as ad_id, name, youtube_video_title as video, youtube_video_duration/1000 as ad_length, case when youtube_video_duration/1000 <= 7 then 'Bumper' when video_ad_format = 'INDISPLAY' then 'Discovery' else 'InStream' end as video_ad_format
from adwords.aw_ad_group_ad
union all
select 'fb_'||ad_set_id as id, 'fb_'||ad_id as ad_id, name, name as video, null as ad_length, 'FB/IG' as video_ad_format
from facebook.fb_ad
) as ad
on ad.id=c.id

left join
(select 'yt_'||ad_group_ad_id as ad_id, 'YouTube' as platform, to_date(date) as date, clicks, impressions, cost as spend, video_views, (video_played_to_25_percent/100) as video_p25_watched, (video_played_to_50_percent/100) as video_p50_watched, (video_played_to_75_percent/100) as video_p75_watched, (video_played_to_100_percent/100) as video_p100_watched,0 as page_likes, 0 as post_reactions, 0 as view_10sec, conversions, conversions as conversions_registrations, 0 as thruplays, engagements
from adwords.aw_ad_group_ad_summary_daily where impressions > 0 and date >= '2019-01-01'
Union all
Select 'fb_'||ad_id as ad_id, case when placement like '%nstagram%' then 'Instagram' else 'Facebook' end as platform, to_date(date) as date, actions_link_click as clicks, impressions, spend, actions_video_view as video_views, video_p25_watched, video_p50_watched, video_p75_watched, video_p100_watched, actions_like as page_likes, actions_post_reaction as post_reactions, video_10_sec_watched_video_view as view_10sec, actions_offsite_conversion_fb_pixel_purchase as conversions, actions_offsite_conversion_fb_pixel_complete_registration as conversions_registration, video_thruplay_watched as thruplays, 0 as engagements
From facebook.fb_ad_summary_daily_placement where impressions > 0 and date >= '2019-01-01'
) as d
on d.ad_id=ad.ad_id

where impressions > 0

group by
c.name 
, c.ad_group 
, ad.name 
, ad.video 
, d.date 
, d.platform 
, ad.video_ad_format 
, ad.ad_length

union all

select
NULL as "Campaign SF"
, NULL as "Ad Group SF"
, NULL as "Ad Name SF"
, NULL as "Video SF"
, NULL as "Ad Length"
, NULL as "Ad Format"
, 'OTT' as "Platform SF"
, NULL as "Date SF"
, NULL as "Impressions"
, NULL as "Clicks"
, NULL as "Views"
, NULL as "FB 3 Sec View"
, NULL as "FB 10 Sec Views"
, NULL as "FB ThruPlays"
, NULL as "Spend"
, NULL as "Conversions"
, NULL as "Conversions Registrations"
, NULL as "Engagements"
, NULL as "Reactions"
, NULL as "Page Likes"
, NULL as "Played to 25p"
, NULL as "Played to 50p"
, NULL as "Played to 75p"
, NULL as "Played to 100p"
, NULL as "Quartile Denominator"
  
from salesforce.user

group by "Platform SF"