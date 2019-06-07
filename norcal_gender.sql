select
op.name as "Opportunity"
, op.project_number as "Opportunity Number"
, case when op.project_number in ('10336','10337','10338') then 'Core'
       when op.project_number in ('10339','10340') then 'Hispanic'
       when op.project_number in ('10365','10366','10367') then 'Valentine''s Day'
       when op.project_number in ('10400','10401') then 'Supplemental'
      when op.project_number in ('10425','10426') then 'Testimonials'
      when op.project_number in ('10450','10451') then 'Hispanic Supplemental'
  end as "Campaign"
, case when op.project_number in ('10336','10339','10365','10401','10425','10451') then 'San Francisco'
       when op.project_number in ('10338','10367') then 'Fresno'
       when op.project_number in ('10337','10340','10366','10400','10426','10450') then 'Sacramento'
  end as "Geo"
, case when io.campaign_name like '%Intender%' then 'Intender'
       when io.campaign_name like '%Boomer%' then 'Boomer/Millennial'
       else 'Intender'
  end as "Segment"
, io.contract_line_item as "Contract Line Item"
, io.contract_line_start as "Flight Start"
, io.contract_line_end as "Flight End"
, 'Flight '||dense_rank() over (partition by op.project_number order by io.contract_line_start) as "Flight"
, io.campaign_name as "Line Item"
, io.flight_start_date as "Line Item Start"
, io.flight_end_date as "Line Item End"
, daily.date as "Date"
, gender.name as "Gender"
, daily.date as "Date"
, sum(daily.impressions) as "Impressions"
, sum(daily.clicks) as "Clicks"
, sum(daily.video_views) as "Views"


from (select id, project_number, name, advertiser, account_id from salesforce.opportunity 
        where deleted = 'false' and advertiser = '0012A00002I3uveQAB'and flight_start_date >= '2019-01-01') as op
        

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
, io.contract_line_item
, io.contract_line_start
, io.contract_line_end