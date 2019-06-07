select
op.name as "Opportunity"
, io.campaign_name as "Line Item"
, c.name as "Campaign"
, ag.name as "Ad Group"
, case when ag.video_ad_format = 'INDISPLAY' then 'Discovery' else initcap(ag.video_ad_format) end as "Video Ad Format"
, keyword.text as "Keyword"
, row_number() over(partition by c.name, ag.name order by sum(d.video_views)/sum(d.impressions)) as "Keyword Rank"
, sum(d.impressions) as "Impressions"
, sum(d.clicks) as "Clicks"
, sum(d.video_views) as "Views"
, case when ag.video_ad_format = 'INDISPLAY' then sum((d.video_played_to_25_percent/100)*d.video_views)
       else sum((d.video_played_to_25_percent/100)*d.impressions)
  end as "Video Watched 25%"
, case when ag.video_ad_format = 'INDISPLAY' then sum((d.video_played_to_50_percent/100)*d.video_views)
       else sum((d.video_played_to_50_percent/100)*d.impressions)
  end as "Video Watched 50%"
, case when ag.video_ad_format = 'INDISPLAY' then sum((d.video_played_to_75_percent/100)*d.video_views)
       else sum((d.video_played_to_75_percent/100)*d.impressions)
  end as "Video Watched 75%"
, case when ag.video_ad_format = 'INDISPLAY' then sum((d.video_played_to_100_percent/100)*d.video_views)
       else sum((d.video_played_to_100_percent/100)*d.impressions)
  end as "Video Watched 100%"
, case when ag.video_ad_format = 'INDISPLAY' then sum(d.video_views)
       else sum(d.impressions)
  end as "Quartile Denominator" 
, sum(d.cost) as "Pix Spend"
, case when io.cost_structure = 'CPV' then sum(d.video_views*io.rate) 
       when io.cost_structure = 'CPM' then sum((d.impressions/1000)*io.rate) 
  end as "Client Spend"
, case when io.cost_structure = 'CPV' then sum(sum(d.video_views)) over (partition by io.campaign_name)
       when io.cost_structure = 'CPM' then sum(sum(d.impressions)) over (partition by io.campaign_name)
  end as "Line Item Delivery"
, case when sum(sum(d.video_views)) over (partition by io.campaign_name) > io.units then io.cost/(sum(sum(d.video_views)) over (partition by io.campaign_name))
       else io.rate
  end as "eCPV"
, case when io.cost_structure = 'CPV' then
         (case when sum(sum(d.video_views)) over (partition by io.campaign_name) > io.units then io.cost/(sum(sum(d.video_views)) over (partition by io.campaign_name))
            else io.rate
          end) * sum(d.video_views)
       when io.cost_structure = 'CPM' then
         (case when sum(sum(d.impressions)) over (partition by io.campaign_name) > io.units then io.cost/(sum(sum(d.impressions/1000)) over (partition by io.campaign_name))
            else io.rate
          end) * sum(d.impressions/1000) 
   end as "Capped Client Spend"
, sum(d.all_conversions) as "All Conversions"

from (select id, name, project_number from salesforce.opportunity where project_number = '10098') as op

left join (select campaign_name, opportunity_id, flight_start_date, flight_end_date, platform, cost_structure, cost, rate, units, media_budget, fee from salesforce.iolineitem where deleted = 'false') as io
on op.id=io.opportunity_id

left join(select campaign_id, name, split_part(name,'_',1) as join from adwords.aw_campaign) as c 
on c.join=io.campaign_name

left join (select campaign_id, ad_group_id, video_ad_format, name from adwords.aw_ad_group) as ag 
on c.campaign_id=ag.campaign_id

left join(select ad_group_id, keyword_id,  date, impressions, clicks, video_views, cost, video_played_to_25_percent, video_played_to_50_percent, video_played_to_75_percent, video_played_to_100_percent, conversions, all_conversions
 from adwords.aw_keyword_summary_daily where impressions > 0 and date >= '2019-01-01') as d 
on d.ad_group_id=ag.ad_group_id

left join (select keyword_id, text from adwords.aw_keyword) as keyword 
on d.keyword_id=keyword.keyword_id

where d.impressions > 0

group by 
op.name 
, io.campaign_name 
, c.name
, ag.name 
, ag.video_ad_format
, keyword.text
, io.cost_structure
, io.units
, io.rate
, io.cost

having sum(d.impressions) > 0
