select
op.name as "Opportunity"
, 'https://na42.salesforce.com/'||op.id as "SF Link"
, op.project_number as "Project Number"
, io.campaign_name as "Line Item"
, io.flight_start_date as "Flight Start Date"
, io.flight_end_date as "Flight End Date"
, daily.date as "Date"
, io.cost as "IO Revenue"
, io.units as "Contracted Units"
, io.rate as "Contracted Rate"
, c.name as "Campaign"
, ag.name as "Ad Group"
, ad.name as "Ad"
, ad.video as "Video"
, ad.ad_length as "Ad Length"
, date_trunc('week',daily.date) as "Week"
, dayofweek(daily.date) as "Day Of Week"
, case when ag.video_ad_format = 'INDISPLAY' then 'Discovery' else initcap(ag.video_ad_format) end as "Video Ad Format"
, sum(daily.impressions) as "Impressions"
, sum(daily.video_views) as "Views"
, sum(daily.clicks) as "Clicks"
, case when ag.video_ad_format = 'INDISPLAY' then sum((daily.video_played_to_25_percent/100)*daily.video_views)
       else sum((daily.video_played_to_25_percent/100)*daily.impressions)
  end as "Video Watched 25%"
, case when ag.video_ad_format = 'INDISPLAY' then sum((daily.video_played_to_50_percent/100)*daily.video_views)
       else sum((daily.video_played_to_50_percent/100)*daily.impressions)
  end as "Video Watched 50%"
, case when ag.video_ad_format = 'INDISPLAY' then sum((daily.video_played_to_75_percent/100)*daily.video_views)
       else sum((daily.video_played_to_75_percent/100)*daily.impressions)
  end as "Video Watched 75%"
, case when ag.video_ad_format = 'INDISPLAY' then sum((daily.video_played_to_100_percent/100)*daily.video_views)
       else sum((daily.video_played_to_100_percent/100)*daily.impressions)
  end as "Video Watched 100%"
, case when ag.video_ad_format = 'INDISPLAY' then sum(daily.video_views)
       else sum(daily.impressions)
  end as "Quartile Denominator" 
, sum(daily.cost) as "Pix Spend"
, case when io.cost_structure = 'CPV' then sum(daily.video_views*io.rate) 
       when io.cost_structure = 'CPM' then sum((daily.impressions/1000)*io.rate) 
  end as "Client Spend"
, case when io.cost_structure = 'CPV' then sum(sum(daily.video_views)) over (partition by io.campaign_name)
       when io.cost_structure = 'CPM' then sum(sum(daily.impressions)) over (partition by io.campaign_name)
  end as "Line Item Delivery"
, case when sum(sum(daily.video_views)) over (partition by io.campaign_name) > io.units then io.cost/(sum(sum(daily.video_views)) over (partition by io.campaign_name))
       else io.rate
  end as "eCPV"
, case when io.cost_structure = 'CPV' then
         (case when sum(sum(daily.video_views)) over (partition by io.campaign_name) > io.units then io.cost/(sum(sum(daily.video_views)) over (partition by io.campaign_name))
            else io.rate
          end) * sum(daily.video_views)
       when io.cost_structure = 'CPM' then
         (case when sum(sum(daily.impressions)) over (partition by io.campaign_name) > io.units then io.cost/(sum(sum(daily.impressions/1000)) over (partition by io.campaign_name))
            else io.rate
          end) * sum(daily.impressions/1000) 
   end as "Capped Client Spend"
, sum(daily.all_conversions) as "All Conversions"

from (select id, name, project_number from salesforce.opportunity where project_number = '10098') as op

left join (select campaign_name, flight_start_date, flight_end_date, cost_structure, opportunity_id, cost, units, rate from salesforce.iolineitem where deleted = 'false') as io
on op.id=io.opportunity_id

left join (select campaign_id, name, split_part(name,'_',1) as join from adwords.aw_campaign) as c
on c.join=io.campaign_name

left join (select campaign_id, ad_group_id, name, video_ad_format from adwords.aw_ad_group) as ag
on ag.campaign_id=c.campaign_id

left join (select ad_group_id, ad_group_ad_id, name, youtube_video_title as video, video_ad_format, youtube_video_duration/1000 as ad_length from adwords.aw_ad_group_ad) as ad
on ag.ad_group_id=ad.ad_group_id

left join (select ad_group_ad_id, date, impressions, clicks, video_views, cost, video_played_to_25_percent, video_played_to_50_percent, video_played_to_75_percent, video_played_to_100_percent, conversions, all_conversions from adwords.aw_ad_group_ad_summary_daily where impressions >0) as daily
on daily.ad_group_ad_id=ad.ad_group_ad_id

where impressions > 0

group by c.name
, op.project_number
, ag.video_ad_format
, op.name
, io.campaign_name
, io.flight_start_date
, io.flight_end_date
, io.cost 
, io.units 
, io.rate 
, op.project_number
, c.name
, ag.name
, "Day Of Week"
, "Week"
, op.id
, daily.date
, ad.name
, ad.video
, ad.ad_length
, io.cost_structure

having sum(daily.impressions) > 0