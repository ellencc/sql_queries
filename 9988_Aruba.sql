select
io.campaign_name as "Line Item"
, campaign.name as "AW Campaign"
, case when io.campaign_name like '%AddedValue%' then 'AV Campaign' 
       else 'Paid Campaign'
  end as "Campaign"
, ag.name as "Ad Group"
, case when campaign.name like '%AffluentTravelers%' then 'Affluent Travelers'
       when campaign.name like '%AffluentMillennials%' then 'Affluent Millennials'
       when campaign.name like '%AffluentMillenial%' then 'Affluent Millennials'
       when campaign.name like '%Retargeting%' then 'Retargeting'
       when campaign.name like '%LightTVViewers%' then 'Light TV Viewers'
       when campaign.name like '%CustomSearchIntent%' then 'Custom Search Intent'
       when campaign.name like '%FamilyTravelers%' then 'Family Travelers'
end as "Audience"
, case when campaign.name like '%TrueViewAction%' then 'Action'
       when ag.video_ad_format = 'INSTREAM' then 'Instream'
       when ag.video_ad_format = 'INDISPLAY' then 'Discovery'
       else ag.video_ad_format
  end as "Ad Format"
, case when campaign.name like '%Lilian%' then 'Lilian'
       when campaign.name like '%Vanessa%' then 'Vanessa'
       when campaign.name like '%Samil%' then 'Samil'
       else split_part(campaign.name,'_',4)
  end as "Video"
-- , daily.device as "Device"
, date_trunc('month',daily.date) as "Month"
, sum(daily.impressions) as "Impressions"
, sum(daily.video_views) as"Views"
, sum(daily.clicks) as "Clicks"
, sum(case when ag.video_ad_format = 'INDISPLAY' then (daily.video_played_to_25_percent/100)*daily.video_views
       else (daily.video_played_to_25_percent/100)*daily.impressions
  end) as "Played to 25p"
, sum(case when ag.video_ad_format = 'INDISPLAY' then (daily.video_played_to_50_percent/100)*daily.video_views
       else (daily.video_played_to_50_percent/100)*daily.impressions
  end) as "Played to 50p"
, sum(case when ag.video_ad_format = 'INDISPLAY' then (daily.video_played_to_75_percent/100)*daily.video_views
       else (daily.video_played_to_75_percent/100)*daily.impressions
  end) as "Played to 75p"
, sum(case when ag.video_ad_format = 'INDISPLAY' then (daily.video_played_to_100_percent/100)*daily.video_views
       else (daily.video_played_to_100_percent/100)*daily.impressions
  end) as "Played to 100p"
, sum(case when ag.video_ad_format = 'INDISPLAY' then daily.video_views
       else daily.impressions
  end) as "Quartile Denominator"
, case when io.cost = 0 then 0
       when sum(sum(daily.video_views*io.rate)) over (partition by io.campaign_name order by date_trunc('month',daily.date), campaign.name, ag.name) < io.cost 
            then sum(daily.video_views*io.rate)
       else greatest(0,sum(daily.video_views*io.rate)-(sum(sum(daily.video_views*io.rate)) over (partition by io.campaign_name order by date_trunc('month',daily.date), campaign.name, ag.name)-io.cost))
  end as "Spend"

from (select name, id from salesforce.opportunity where project_number = 9988) as op

left join (select opportunity_id, campaign_name, cost_structure, cost, units, rate from salesforce.iolineitem where deleted = 'false') as io
on io.opportunity_id=op.id

left join (select name, campaign_id, split_part(name,'_',1) as join from adwords.aw_campaign) as campaign
on campaign.join=io.campaign_name

left join (select campaign_id, ad_group_id, aw_ad_group_id, video_ad_format, name from adwords.aw_ad_group) as ag
on ag.campaign_id=campaign.campaign_id


left join (select ad_group_id, to_date(date) as date, impressions, clicks, video_views, video_played_to_25_percent, video_played_to_50_percent, video_played_to_75_percent, video_played_to_100_percent from adwords.aw_ad_group_summary_daily where impressions >0 and date>='2019-01-01') as daily
on daily.ad_group_id=ag.ad_group_id

-- left join (select adgroupid as ad_group_id, case when device like '%Mobile%' then 'Mobile' when device like '%Tablet%' then 'Tablet' when device = 'Computers' then 'Desktop' when device like '%TV%' then 'TV Screens' else 'Other' end as device, to_date(date) as date, impressions, clicks, videoviews as video_views, videoquartile25rate as video_played_to_25_percent, videoquartile50rate as video_played_to_50_percent, videoquartile75rate as video_played_to_75_percent, videoquartile100rate as video_played_to_100_percent from adwords.aw_ad_group_devices where impressions >0 and date>='2019-01-01') as daily
-- on daily.ad_group_id=ag.aw_ad_group_id

where daily.date < '2019-05-01'

group by 
io.campaign_name
, io.cost_structure
, io.cost
, campaign.name
, ag.name
, "Ad Format"
-- , daily.device
,"Month"

 order by io.campaign_name, date_trunc('month',daily.date), campaign.name, ag.name