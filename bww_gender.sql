select
op.name as "Opportunity"
, op.project_number as "Opportunity Number"
, case when lower(io.campaign_name) like '%sportsfans%' then 'Sports Fans'
       when lower(io.campaign_name) like '%beerbar%' then 'Beer Bar'
       when lower(io.campaign_name) like '%wings%' then 'Wings'
       when lower(io.campaign_name) like '%sporsfans%' then 'Sports Fans'
  end as "Campaign"
, split_part(io.campaign_name,'.',2) as "Geo"
, io.campaign_name as "Line Item"
, io.flight_start_date as "Flight Start"
, io.flight_end_date as "Flight End"
, daily.date as "Date"
, sum(daily.impressions) as "Impressions"
, sum(daily.clicks) as "Clicks"
, sum(daily.video_views) as "Views"


from (select id, project_number, name, advertiser, account_id from salesforce.opportunity 
        where deleted = 'false' and advertiser = '001F000001oXxC8IAK'and flight_start_date >= '2019-01-01') as op
        

left join (select campaign_name, opportunity_id, units, flight_start_date, flight_end_date, cost, cost_structure,contract_line_item, min(flight_start_date) over (partition by contract_line_item) as contract_line_start, max(flight_end_date) over (partition by contract_line_item) as contract_line_end
 from salesforce.iolineitem  where deleted = 'false') as io
on op.id=io.opportunity_id

left join (select name,split_part(name,'_',1) as join, campaign_id from adwords.aw_campaign) as c
on c.join=io.campaign_name

left join (select campaign_id, to_date(date) as date, gender_id, impressions, clicks, video_views from adwords.aw_gender_summary_daily) as daily
on daily.campaign_id=c.campaign_id

left join (select gender_id, name from adwords.aw_gender) as gender
on gender.gender_id=daily.gender_id

where impressions > 0

group by 
gender.name
, op.name
, io.campaign_name
, daily.date
, op.project_number
, io.flight_start_date
, io.flight_end_date
