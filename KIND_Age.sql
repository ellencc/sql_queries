select
op.name as "Opportunity"
, op.project_number as "Project Number"
, io.campaign_name as "Line Item"
, io.flight_start_date as "Flight Start"
, io.flight_end_date as "Flight End"
, c.name as "Campaign"
, ag.name as "Ad Group"
, case when io.campaign_name like '%Bumper%' then 'Bumper' 
       else ag.video_ad_format 
  end as "Video Ad Format"
, age.name as "Age"
, d.date as "Date"
, sum(d.impressions) as "Impressions"
, sum(d.clicks) as "Clicks"
, sum(d.video_views) as "Views"
, sum(case when ag.video_ad_format = 'Discovery' then (d.video_played_to_25_percent/100)*d.video_views
           else (d.video_played_to_25_percent/100)*d.impressions 
      end) as "Played to 25%"
, sum(case when ag.video_ad_format = 'Discovery' then (d.video_played_to_50_percent/100)*d.video_views
           else (d.video_played_to_50_percent/100)*d.impressions 
      end) as "Played to 50%"
, sum(case when ag.video_ad_format = 'Discovery' then (d.video_played_to_75_percent/100)*d.video_views
           else (d.video_played_to_75_percent/100)*d.impressions 
      end) as "Played to 75%"
, sum(case when ag.video_ad_format = 'Discovery' then (d.video_played_to_100_percent/100)*d.video_views
           else (d.video_played_to_100_percent/100)*d.impressions 
      end) as "Played to 100%"
, sum(case when ag.video_ad_format = 'Discovery' then d.video_views
       else d.impressions
  end) as "Quartile Denominator"
  
from (select name, id, project_number from salesforce.opportunity where account_id in ('001F000001TSaQ3IAL','0012A00002Dosu1QAB')) as op

left join (select opportunity_id, campaign_name, contract_line_item, flight_start_date, flight_end_date, units, rate, media_budget, fee from salesforce.iolineitem where deleted = 'false') as io
on io.opportunity_id=op.id

left join (select split_part(name,'_',1) as line_item, name, campaign_id from adwords.aw_campaign) as c
on c.line_item=io.campaign_name

left join (select campaign_id, ad_group_id, name, case when video_ad_format ='INDISPLAY' then 'Discovery' else 'InStream' end as video_ad_format from adwords.aw_ad_group) as ag
on ag.campaign_id=c.campaign_id

left join (select ad_group_id, age_id, date, impressions, clicks, video_views, cost, video_played_to_25_percent, video_played_to_50_percent, video_played_to_75_percent, video_played_to_100_percent from adwords.aw_age_summary_daily where impressions >0 and date>= '2018-01-01') as d
on d.ad_group_id=ag.ad_group_id

left join (select  age_id, name from adwords.aw_age) as age
on age.age_id=d.age_id

where impressions >0

group by 
op.name
, op.project_number
, io.campaign_name
, io.flight_start_date
, io.flight_end_date
, c.name
, ag.name
,"Video Ad Format"
, d.date
,"Age"

