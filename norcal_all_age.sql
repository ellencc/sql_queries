select 
op.project_number
, op.name as opportunity
, age.name as age
, ag.ad_format
, sum(d.impressions) as impressions
, sum(d.clicks) as clicks
, sum(d.video_views) as views
, case when ag.ad_format = 'Discovery' then sum(d.video_views*d.played_to_25p)
       when ag.ad_format = 'Bumper' then sum(video_views)
       else sum(d.impressions*d.played_to_25p)
  end as played_to_25p
, case when ag.ad_format = 'Discovery' then sum(d.video_views*d.played_to_50p)
       when ag.ad_format = 'Bumper' then sum(video_views)
       else sum(d.impressions*d.played_to_50p)
  end as played_to_50p
, case when ag.ad_format = 'Discovery' then sum(d.video_views*d.played_to_75p)
       when ag.ad_format = 'Bumper' then sum(video_views)
       else sum(d.impressions*d.played_to_75p)
  end as played_to_75p
, case when ag.ad_format = 'Discovery' then sum(d.video_views*d.played_to_100p)
       when ag.ad_format = 'Bumper' then sum(video_views)
       else sum(d.impressions*d.played_to_100p)
  end as played_to_100p
, case when ag.ad_format = 'Discovery' then sum(d.video_views)
       else sum(d.impressions)
  end as quartile_denominator

from (select id, name, project_number from salesforce.opportunity where project_number in(10336,10337,10338,10339,10340)) as op

left join (select campaign_name, flight_start_date, flight_end_date, opportunity_id, platform, cost_structure, cost, rate, media_budget, fee from salesforce.iolineitem where deleted = 'false') as io
on op.id=io.opportunity_id

left join(select campaign_id, name, split_part(name,'_',1) as join from adwords.aw_campaign) as c 
on c.join=io.campaign_name

left join (select campaign_id, ad_group_id, case when video_ad_format = 'INDISPLAY' then 'Discovery' when video_ad_format = 'INSTREAM' then 'InStream' else initcap(video_ad_format) end as ad_format
from adwords.aw_ad_group
)as ag 
on c.campaign_id=ag.campaign_id

left join(
select ad_group_id, age_id,  to_date(date) as date, impressions, ifnull(clicks,0) as clicks, ifnull(video_views,0) as video_views, cost as spend, ifnull(video_played_to_25_percent/100,0) as played_to_25p, ifnull(video_played_to_50_percent/100,0) as played_to_50p, ifnull(video_played_to_75_percent/100,0) as played_to_75p, ifnull(video_played_to_100_percent/100,0) as played_to_100p
from adwords.aw_age_summary_daily  where impressions >0 ) as d
on d.ad_group_id=ag.ad_group_id

left join (select age_id, case when name = 'gt64' then '65+' else replace(name, 'to', '-') end as name from adwords.aw_age) as age 
on age.age_id=d.age_id

where  date_trunc('month',d.date) = timestampadd('month',-1,date_trunc('month',current_date()))

group by 
op.project_number
, ag.ad_format 
, age.name
, op.name 

order by op.project_number, age asc