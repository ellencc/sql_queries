select 
op.name as "Opportunity"
, io.campaign_name as "Line Item"
, io.flight_start_date as "Flight Start"
, io.flight_end_date as "Flight End"
, ifnull(daily.platform,io.io_platform) as "Platform"
, case when io.io_platform = 'Cross-Platform' then 'Facebook' else io.io_platform end as "Line Item Platform"
, io.cost_structure as "Cost Structure"
, io.rate as "Contracted Rate"
, campaign.name as "Campaign"
, campaign.ad_group as "Ad Group"
, ad.video_ad_format as "Ad Format"
, ad.name as "Ad Name"
, ad.video_name as "Video"
, ad.video_id as "Video ID"
, ad.ad_length as "Ad Length"
, date_trunc('week',daily.date) as "Week"
, date as "Date"
, sum(daily.impressions) as "Impressions SF"
, sum(daily.clicks) as "Clicks"
, case when io.cost_structure = 'CPV' then sum(daily.video_views)
       when io.cost_structure = 'CPM' then sum(daily.video_views)
       when io.cost_structure = 'ThruPlays (15 sec CPV)' then sum(daily.thruplays)
       when io.cost_structure = '10 second CPV' then sum(daily.view_10_sec)
  end as "Views SF"
, case when sum(sum(case when io.cost_structure = 'CPV' then daily.video_views*io.rate
                         when io.cost_structure = 'ThruPlays (15 sec CPV)' then daily.thruplays*io.rate
                         when io.cost_structure = '10 second CPV' then daily.view_10_sec*io.rate
                    end)) over (partition by io.campaign_name order by date, platform, campaign.name, campaign.ad_group, ad.name, ad.video_name) > io.cost
       then greatest(0,sum(case when io.cost_structure = 'CPV' then daily.video_views*io.rate
                                when io.cost_structure = 'ThruPlays (15 sec CPV)' then daily.thruplays*io.rate
                                when io.cost_structure = '10 second CPV' then daily.view_10_sec*io.rate
                           end) -
                      (sum(sum(case when io.cost_structure = 'CPV' then daily.video_views*io.rate
                                    when io.cost_structure = 'ThruPlays (15 sec CPV)' then daily.thruplays*io.rate
                                    when io.cost_structure = '10 second CPV' then daily.view_10_sec*io.rate
                               end)) over (partition by io.campaign_name order by date, platform, campaign.name, campaign.ad_group, ad.name, ad.video_name)
                      -io.cost)
                     )
       else sum(case when io.cost_structure = 'CPV' then daily.video_views*io.rate
                     when io.cost_structure = 'ThruPlays (15 sec CPV)' then daily.thruplays*io.rate
                     when io.cost_structure = '10 second CPV' then daily.view_10_sec*io.rate
                end)
  end as "Spend SF"
, sum(daily.spend) as "Pix Spend"
, case when ad.video_ad_format in ('FB/IG','Twitter') then sum(daily.played_to_25p)
       when ad.video_ad_format = 'Discovery' then sum(daily.video_views*daily.played_to_25p)
       when ad.video_ad_format = 'Bumper' then sum(video_views)
       else sum(daily.impressions*daily.played_to_25p)
  end as "Played to 25p"
, case when ad.video_ad_format in ('FB/IG','Twitter') then sum(daily.played_to_50p)
       when ad.video_ad_format = 'Discovery' then sum(daily.video_views*daily.played_to_50p)
       when ad.video_ad_format = 'Bumper' then sum(video_views)
       else sum(daily.impressions*daily.played_to_50p)
  end as "Played to 50p"
, case when ad.video_ad_format in ('FB/IG','Twitter') then sum(daily.played_to_75p)
       when ad.video_ad_format = 'Discovery' then sum(daily.video_views*daily.played_to_75p)
       when ad.video_ad_format = 'Bumper' then sum(video_views)
       else sum(daily.impressions*daily.played_to_75p)
  end as "Played to 75p"
, case when ad.video_ad_format in ('FB/IG','Twitter') then sum(daily.played_to_100p)
       when ad.video_ad_format = 'Discovery' then sum(daily.video_views*daily.played_to_100p)
       when ad.video_ad_format = 'Bumper' then sum(video_views)
       else sum(daily.impressions*daily.played_to_100p)
  end as "Played to 100p SF"
, case when ad.video_ad_format in ('FB/IG','Twitter') then sum(impressions)
       when ad.video_ad_format = 'Discovery' then sum(daily.video_views)
       when ad.video_ad_format = 'Bumper' then sum(video_views)
       else sum(daily.impressions)
  end as "Quartile Denominator"

from (select id, name, project_number from salesforce.opportunity where advertiser = '0012A00002M78NMQAZ' and stage_name = 'Closed Won' and flight_end_date >= '2019-01-01') as op

left join (select campaign_name, opportunity_id, cost_structure, cost, rate, media_budget, fee, platform as io_platform, flight_start_date, flight_end_date from salesforce.iolineitem where deleted='false') as io
on op.id=io.opportunity_id

left join(
select 'yt_'||c.campaign_id as campaign_id, 'yt_'||ag.ad_group_id as id, c.name, ag.name as ad_group, split_part(c.name,'_',1) as join
from adwords.aw_campaign as c 
left join adwords.aw_ad_group as ag on ag.campaign_id=c.campaign_id
union all
select 'fb_'||ad_set_id as campaign_id, 'fb_'||ad_set_id as id, name,'' as ad_group, split_part(name,'_',1) as join
from facebook.fb_ad_set
where status!='ARCHIVED'
) as campaign
on campaign.JOIN=io.campaign_name

left join(
select 'yt_'||ad_group_id as id, 'yt_'||ad_group_ad_id as ad_id, name, youtube_video_title as video_name, youtube_video_duration as ad_length, youtube_video_id as video_id, case when (youtube_video_duration/1000) <= 6 then 'Bumper' when video_ad_format = 'INDISPLAY' then 'Discovery' else initcap(video_ad_format) end as video_ad_format
from adwords.aw_ad_group_ad
union all
select 'fb_'||ad_set_id as id,'fb_'||ad_id as ad_id, name, name as video_name, null as ad_length, ''  as video_id,  'FB/IG' as video_ad_format
from facebook.fb_ad
) as ad
on ad.id=campaign.id

left join(
select 'yt_'||campaign_id as campaign_id, 'yt_'||ad_group_ad_id as ad_id, 'YouTube' as platform,  to_date(date) as date, impressions, ifnull(clicks,0) as clicks, ifnull(video_views,0) as video_views, cost as spend, ifnull(video_played_to_25_percent/100,0) as played_to_25p, ifnull(video_played_to_50_percent/100,0) as played_to_50p, ifnull(video_played_to_75_percent/100,0) as played_to_75p, ifnull(video_played_to_100_percent/100,0) as played_to_100p, ifnull(conversions,0) as conversions,ifnull(conversions,0) as conversions_registrations,ifnull(view_through_conversions,0) as view_through_conversions, ifnull(conversion_value,0) as conversion_value, 0 as view_10_sec, 0 as thruplays
from adwords.aw_ad_group_ad_summary_daily where impressions >0
union all
select 'fb_'||ad_set_id as campaign_id , 'fb_'||ad_id as ad_id, case when placement like '%instagram%' then 'Instagram' else 'Facebook' end as platform, to_date(date) as date, impressions, ifnull(actions_link_click,0) as clicks, ifnull(video_10_sec_watched_video_view,0) as video_views, spend, ifnull(video_p25_watched,0) as played_to_25p, ifnull(video_p50_watched,0) as played_to_50p, ifnull(video_p75_watched,0) as played_to_75p, ifnull(video_p100_watched,0) as played_to_100p, ifnull(actions_offsite_conversion_fb_pixel_purchase,0) as conversions,ifnull(actions_offsite_conversion_fb_pixel_complete_registration,0) as conversions_registrations, 0 as view_through_conversions, ifnull(action_values_offsite_conversion_fb_pixel_purchase,0) as conversion_value, VIDEO_10_SEC_WATCHED_VIDEO_VIEW as view_10_sec, ifnull(video_thruplay_watched,0) as thruplays
from facebook.fb_ad_summary_daily_placement where impressions >0
) as daily
on daily.ad_id=ad.ad_id

where case when io.io_platform in ('YouTube', 'FaceBook', 'Instagram', 'Cross-Platform') then daily.date <= current_date()
           else io.flight_start_date <= current_date()
      end

group by 
op.name
, io.campaign_name
, campaign.name
, date
, io.cost
, daily.platform
, io.cost_structure
, ad.video_ad_format
, "Week"
, campaign.ad_group
, ad.name
, ad.video_name
, ad.ad_length
, io.io_platform
, io.rate
, io.flight_start_date
, io.flight_end_date 
, ad.video_id

order by io.campaign_name, date, platform, campaign.name, campaign.ad_group, ad.name, ad.video_name