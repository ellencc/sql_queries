select
io.campaign_name as "Line Item"
, io.flight_start_date as "Flight Start"
, io.flight_end_date as "Flight End"
, c.name as "Campaign"
, c.campaign_id as "Campaign ID"
, ag.name as "Ad Group"
, ag.ad_group_id as "Ad Group ID"
, d.date as "Date"
, ag_hist.bid as "Bid"
, lag(ag_hist.bid,1) over (partition by io.campaign_name, c.name, ag.name order by d.date) as "Previous Bid"
, ifnull(ag_hist.bid, lag(ag_hist.bid,1) over (partition by io.campaign_name, c.name, ag.name order by d.date)) as bid2
, ifnull(ag_hist.bid, lag(ag_hist.bid,-1) over (partition by io.campaign_name, c.name, ag.name order by d.date)) as first_bid
, sum(d.impressions) as "Impressions"
, sum(d.clicks) as "Clicks"
, sum(d.video_views) as "Views"
, case when sum(sum(d.video_views*io.rate)) over (partition by io.campaign_name order by d.date, c.name, ag.name)  < io.cost then sum(d.video_views*io.rate)
       else greatest(0,sum(d.video_views*io.rate)-((sum(sum(d.video_views*io.rate)) over (partition by io.campaign_name order by d.date, c.name, ag.name))-io.cost))
  end as "Client Spend"
, sum(d.played_to_25) as "Played to 25p"
, sum(d.played_to_50) as "Played to 50p"
, sum(d.played_to_75) as "Played to 75p"
, sum(d.played_to_100) as "Played to 100p"


from (select * from salesforce.opportunity where project_number = 10464) as op

left join (select opportunity_id, campaign_name, flight_start_date, flight_end_date, units, cost, rate from salesforce.iolineitem where deleted='false') as io
on io.opportunity_id=op.id

left join adwords.aw_campaign as c
on split_part(c.name,'_',1)=io.campaign_name

left join adwords.aw_ad_group as ag
on ag.campaign_id=c.campaign_id

left join (select ad_group_id, to_date(date) as date, impressions, video_views, clicks, cost as spend, video_played_to_25_percent/100 as played_to_25, video_played_to_50_percent/100 as played_to_50 , video_played_to_75_percent/100 as played_to_75 , video_played_to_100_percent/100 as played_to_100  from adwords.aw_ad_group_summary_daily where impressions >0) as d
on ag.ad_group_id=d.ad_group_id

left join(select ad_group_id, to_date(modified) as date, max(max_cpv) as bid from adwords.aw_ad_group_history group by ad_group_id, date) as ag_hist
on ag_hist.ad_group_id=d.ad_group_id and ag_hist.date=d.date

left join(select campaign_id, to_date(modified) as date, max(budget) as budget from adwords.aw_campaign_history group by campaign_id, date) as c_hist
on ag_hist.ad_group_id=d.ad_group_id and ag_hist.date=d.date

where impressions > 0

group by 
io.campaign_name
, io.flight_start_date
, io.flight_end_date
, c.name 
, ag.name 
, d.date
, ag_hist.date
, ag_hist.bid
, io.cost
, c.campaign_id
, ag.ad_group_id

order by 
io.campaign_name
, c.name
, ag.name
, d.date
