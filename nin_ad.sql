select 
op.name as "Opportunity"
, op.project_number as "Project Number"
, daily.date as "Date"
, io.campaign_name as "Line Item"
, io.flight_start_date as "Start Date"
, io.flight_end_date as "End Date"
, io.cost_structure as "Cost Structure"
, campaign.name as "Campaign"
, ag.name as "Ad Group"
, ad.name as "Ad Name"
, ad.youtube_video_title as "Video"
, ad.youtube_video_id as "Video ID"
, ad.status as "Status"
, case when ad.ad_length <= 7 then 'Bumper' 
       when ad.video_ad_format = 'INDISPLAY' then 'Discovery'
       else 'InStream'
   end as "Video Ad Format"
, ad.ad_length as "Ad Length"
, ad.headline as "Headline"
, ad.description_1 as "Description Line 1"
, ad.description_2 as "Description Line 2"
, sum(daily.impressions) as "Impressions"
, sum(daily.video_views) as "Video Views"
, io.rate as "Avg. Cost Per View/Impression (USD)"
, io.cost as "Line Item Revenue"
, sum(daily.spend) as "Actual Spend"
, case when io.cost_structure = 'CPV' then  sum(daily.video_views)*
                least(io.rate,((io.cost*case when io.flight_start_date > current_date() then 0
                                             when io.flight_end_date < current_date() then 1
                                             else datediff('day',io.flight_start_date,current_date())/datediff('day',io.flight_start_date, io.flight_end_date) 
                                        end)  
                                  /(sum(sum(daily.video_views)) over (partition by io.campaign_name)))) -- least between contracted rate and (io cost * ideal pace) / views delivered, ecpv
        when io.cost_structure = 'CPM' then sum(daily.impressions/1000)*
                least(io.rate,((io.cost*case when io.flight_start_date > current_date() then 0
                                             when io.flight_end_date < current_date() then 1
                                             else datediff('day',io.flight_start_date, current_date())/datediff('day',io.flight_start_date, io.flight_end_date) 
                                        end)  
                                  /(sum(sum(daily.impressions/1000)) over (partition by io.campaign_name)))) -- least between contracted rate and (io cost * ideal pace) / imp delivered, ecpm
   end as "Client Spend (USD)"
, (case when io.cost_structure = 'CPV' then sum(daily.video_views*io.rate)
        when io.cost_structure = 'CPM' then sum((daily.impressions/1000)*io.rate)
   end) - 
   (case when io.cost_structure = 'CPV' then  sum(daily.video_views)*
                least(io.rate,((io.cost*case when io.flight_start_date > current_date() then 0
                                             when io.flight_end_date < current_date() then 1
                                             else datediff('day',io.flight_start_date, current_date())/datediff('day',io.flight_start_date, io.flight_end_date) 
                                        end)  
                                  /(sum(sum(daily.video_views)) over (partition by io.campaign_name)))) -- least between contracted rate and (io cost * ideal pace) / views delivered, ecpv
        when io.cost_structure = 'CPM' then sum(daily.impressions/1000)*
                least(io.rate,((io.cost*case when io.flight_start_date > current_date() then 0
                                             when io.flight_end_date < current_date() then 1
                                             else datediff('day',io.flight_start_date, current_date())/datediff('day',io.flight_start_date, io.flight_end_date) 
                                        end)  
                                  /(sum(sum(daily.impressions/1000)) over (partition by io.campaign_name)))) -- least between contracted rate and (io cost * ideal pace) / views delivered, ecpv
 
  end) as "Added Value (USD)"
, sum(daily.clicks) as "Clicks"
, sum(daily.all_conversions) as "All Conversions"
, sum(case when ag.video_ad_format = 'INDISPLAY' then daily.played_to_25p*daily.video_views else daily.played_to_25p*daily.impressions end) as "Played To 25%"
, sum(case when ag.video_ad_format = 'INDISPLAY' then daily.played_to_50p*daily.video_views else daily.played_to_50p*daily.impressions end) as "Played To 50%"
, sum(case when ag.video_ad_format = 'INDISPLAY' then daily.played_to_75p*daily.video_views else daily.played_to_75p*daily.impressions end) as "Played To 75%"
, sum(case when ag.video_ad_format = 'INDISPLAY' then daily.played_to_100p*daily.video_views else daily.played_to_100p*daily.impressions end) as "Played To 100%"
, sum(case when ag.video_ad_format = 'INDISPLAY' then daily.video_views else daily.impressions end) as "Quartile Denominator"
, sum(earned.youtubeearnedviews) as "Earned Views"

from (select id, name, project_number from salesforce.opportunity where advertiser = '001F000000ove3IIAQ' and stage_name = 'Closed Won' and flight_end_date >= '2019-01-01') as op

left join (select campaign_name, flight_start_date, flight_end_date, units, opportunity_id, cost_structure, cost, rate, media_budget, fee from salesforce.iolineitem where deleted = 'false') as io
on op.id=io.opportunity_id

left join(select campaign_id, name, split_part(name,'_',1) as join, state from adwords.aw_campaign) as campaign
on campaign.join=io.campaign_name

left join (select campaign_id, ad_group_id,video_ad_format, name from adwords.aw_ad_group) as ag
on campaign.campaign_id=ag.campaign_id

left join (select ad_group_id, ad_group_ad_id, name, youtube_video_title,video_ad_format, youtube_video_duration/1000 as ad_length, youtube_video_id, initcap(state) as status, headline, description_1, description_2 from adwords.aw_ad_group_ad) as ad
on ad.ad_group_id=ag.ad_group_id

left join(select ad_group_ad_id, to_date(date) as date, impressions, ifnull(clicks,0) as clicks, ifnull(video_views,0) as video_views, cost as spend, ifnull(video_played_to_25_percent/100,0) as played_to_25p, ifnull(video_played_to_50_percent/100,0) as played_to_50p, ifnull(video_played_to_75_percent/100,0) as played_to_75p, ifnull(video_played_to_100_percent/100,0) as played_to_100p, ifnull(conversions,0) as conversions,ifnull(conversions,0) as conversions_registrations,ifnull(view_through_conversions,0) as view_through_conversions, ifnull(all_conversions,0) as all_conversions, ifnull(conversion_value,0) as conversion_value, engagements
from adwords.aw_ad_group_ad_summary_daily where impressions >0) as daily
on daily.ad_group_ad_id=ad.ad_group_ad_id

left join (select adgroupadid as ad_group_ad_id, to_date(date) as date, youtubeearnedviews from adwords.aw_ad_group_ad_earned_metrics) as earned
on earned.ad_group_ad_id=daily.ad_group_ad_id and earned.date=daily.date

where impressions > 0
and daily.date <= current_date()

group by 
 ad.name
, ad.youtube_video_title 
, io.rate
, io.units
, io.cost
, io.campaign_name
, io.cost_structure
, daily.date
, io.flight_start_date
, io.flight_end_date
, io.cost_structure
, ag.name
, op.name
, op.project_number 
, campaign.name
,"Video Ad Format"
, ad.ad_length
, ad.youtube_video_id
, ad.status 
, ad.headline
, ad.description_1
, ad.description_2

order by "Line Item"