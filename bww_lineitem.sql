select
op.name as "Opportunity"
, op.project_number as "Opportunity Number"
, case when lower(io.campaign_name) like '%sportsfans%' then 'Sports Fans'
       when lower(io.campaign_name) like '%beerbar%' then 'Beer Bar'
       when lower(io.campaign_name) like '%wings%' then 'Wings'
       when lower(io.campaign_name) like '%sporsfans%' then 'Sports Fans'
  end as "Persona"
, split_part(io.campaign_name,'.',2) as "Geo"
, io.campaign_name as "Line Item"
, io.flight_start_date as "Flight Start"
, io.flight_end_date as "Flight End"
, io.cost as "Budget"
, io.cost_structure as "Cost Structure"
, io.units as "Contracted Units"
, daily.date as "Date"
, sum(daily.impressions) as "Impressions"
, sum(daily.clicks) as "Clicks"
, sum(daily.video_views) as "Views"
, case when sum(sum(daily.video_views*io.rate)) over (partition by io.campaign_name order by date) < io.cost then sum(daily.video_views*io.rate)
       else greatest(0,sum(daily.video_views*io.rate)-(sum(sum(daily.video_views*io.rate)) over (partition by io.campaign_name order by date)-io.cost))
  end as "Client Spend"
, sum(daily.spend) as "Actual Spend"
, sum(case when ad.video_ad_format = 'Discovery' then (daily.video_views*daily.played_to_25p)
           when ad.video_ad_format = 'Bumper' then video_views
           else (daily.impressions*daily.played_to_25p)
  end) as "Played to 25p"
, sum(case when ad.video_ad_format = 'Discovery' then (daily.video_views*daily.played_to_50p)
           when ad.video_ad_format = 'Bumper' then video_views
           else (daily.impressions*daily.played_to_50p)
      end) as "Played to 50p"
, sum(case when ad.video_ad_format = 'Discovery' then (daily.video_views*daily.played_to_75p)
           when ad.video_ad_format = 'Bumper' then video_views
           else (daily.impressions*daily.played_to_75p)
      end) as "Played to 75p"
, sum(case when ad.video_ad_format = 'Discovery' then (daily.video_views*daily.played_to_100p)
           when ad.video_ad_format = 'Bumper' then video_views
           else (daily.impressions*daily.played_to_100p)
      end) as "Played to 100p"
, sum(case when ad.video_ad_format = 'Discovery' then daily.video_views
                  else daily.impressions
   end) as "Quartile Denominator"
, sum(daily.conversions) as "Conversions"
, sum(daily.conversion_value) as "Conversion Value"
, sum(daily.engagements) as "Engagements"


from (select id, name, project_number from salesforce.opportunity where advertiser = '001F000001oXxC8IAK' and flight_end_date >= '2019-01-01' and stage_name = 'Closed Won') as op

left join (select campaign_name, opportunity_id, cost_structure, contract_line_item, min(flight_start_date) over (partition by contract_line_item) as contract_line_start, max(flight_end_date) over (partition by contract_line_item) as contract_line_end, sum(cost) over (partition by contract_line_item) as contract_line_budget
, flight_start_date, flight_end_date, units, cost, rate, media_budget, platform, fee from salesforce.iolineitem 
           where deleted='false') as io
on op.id=io.opportunity_id

left join(select campaign_id, name, split_part(name,'_',1) as join from adwords.aw_campaign) as campaign
on campaign.join=io.campaign_name

left join (select campaign_id, ad_group_ad_id, case when (youtube_video_duration/1000) <= 6 then 'Bumper' when video_ad_format = 'INDISPLAY' then 'Discovery' else initcap(video_ad_format) end as video_ad_format from adwords.aw_ad_group_ad) as ad
on ad.campaign_id=campaign.campaign_id

left join(
select ad_group_ad_id,to_date(date) as date, impressions, ifnull(clicks,0) as clicks, ifnull(video_views,0) as video_views, cost as spend, ifnull(video_played_to_25_percent/100,0) as played_to_25p
, ifnull(video_played_to_50_percent/100,0) as played_to_50p, ifnull(video_played_to_75_percent/100,0) as played_to_75p, ifnull(video_played_to_100_percent/100,0) as played_to_100p
, ifnull(conversions,0) as conversions,ifnull(conversions,0) as conversions_registrations,ifnull(view_through_conversions,0) as view_through_conversions, ifnull(conversion_value,0) as conversion_value
, engagements
from adwords.aw_ad_group_ad_summary_daily where impressions >0 and date >= '2019-01-01'
) as daily
on daily.ad_group_ad_id=ad.ad_group_ad_id

where daily.date <= current_date()

group by 
io.campaign_name
, io.flight_start_date
, io.flight_end_date
, io.cost
, io.cost_structure
, io.units
, io.rate
, op.name
, op.project_number
, daily.date

order by op.project_number, io.campaign_name, date