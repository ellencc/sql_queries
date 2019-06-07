select
case when seller.name in ('Chris Bennett','Michael Brown') then 'EMEA'
     else 'Americas'
  end as "Seller Region"
, case when seller.name in ('Chris Bennett','Michael Brown') then 'EMEA'
       when seller.name in ('Matthew Jackson') then 'US East'
       when seller.name in ('Ashley Murdter','Mallory Beausir') then 'US Mid West'
       when seller.name in ('Cindy Murphy','Jackie Mogol') then 'US West'
       when seller.name in ('Tammy Johnson') then 'Vertical'
       else 'Other'
   end as "Seller Team"
, seller.name as "Seller"
, cm.name as "Campaign Manager"
, am.name as "Account Manager"
, account.name as "Account"
, advertiser.name as "Advertiser"
, op.industry_serviced as "Industry"
, op.name as "Opportunity"
, op.stage_name as "Stage Name"
, op.project_number as "Project Number"
, op.amount as "Opportunity Amount"
, op.proposed_deal_margin as "Pre Sale Margin"
, op.sold_margin as "Sold Margin"
, ifnull(ifnull(io.contract_line_item,io.campaign_name),op.name)as "Contract Line Item"
, ifnull(io.campaign_name,op.name) as "Line Item"
, io.flight_start_date as "Line Item Flight Start"
, io.flight_end_date as "Line Item Flight End"
, ifnull(min(min(io.flight_start_date)) over (partition by ifnull(io.contract_line_item,to_char(op.project_number))),op.flight_start_date) as "Contract Line Flight Start"
, ifnull(max(max(io.flight_end_date)) over (partition by ifnull(io.contract_line_item,to_char(op.project_number))),op.flight_end_date)as "Contract Line Flight End"
, op.flight_start_date as "Opportunity Flight Start"
, op.flight_end_date as "Opportunity Flight End"
, case when op.stage_name = 'Closed Won' then case when io.cost_structure = '% of Spend - Customer Pays Media' then io.fee else io.cost end
       when (io.campaign_name is null or io.cost is null) then op.amount
       else case when io.cost_structure = '% of Spend - Customer Pays Media' then io.fee else io.cost end
  end as "Line Item Revenue"
, ifnull(io.io_currency,'USD') as "Currency"
, io.platform as "Platform"
, io.cost_structure as "Cost Structure"
, case when io.special_deal_margin is null then 'Performance Deal' else 'Special Deal' end as "Deal Type"
, io.special_deal_margin/100 as "Target Margin"
, case when io.cost_structure = '% of Spend' then 1+(io.fee/io.media_budget)
       when io.cost_structure = '% of Spend - Customer Pays Media' then io.fee/io.media_budget
       else io.rate
  end as "Contracted Rate"
, case when io.cost_structure in ('% of Spend - Customer Pays Media','% of Spend', 'Flat Fee') then io.media_budget
       else io.units 
  end as "Contracted Units" 
, io.media_budget as "Media Budget"
, io.fee as "Fee"
, date_trunc('quarter',case when op.stage_name = 'Closed Won' then ifnull(d.date,io.flight_start_date)
                            else op.flight_start_date
                       end) as "Quarter"
, case when op.stage_name != 'Closed Won' then 0
       when io.cost_structure = 'Insights Projects' then case when io.flight_end_date < current_date() then 1 else 0 end
       when io.cost_structure in ('% of Spend - Customer Pays Media','% of Spend', 'Flat Fee') then sum(d.spend)
       when io.cost_structure = 'CPV' then sum(d.video_views)
       when io.cost_structure = 'CPM' then sum(d.impressions)
       when io.cost_structure = 'CPC' then sum(d.clicks)
       when io.cost_structure = '10 second CPV' then sum(d.view_10sec)
       when io.cost_structure = 'CPL' then sum(d.post_reactions)
       when io.cost_structure = 'CPF' then sum(d.page_likes)
       when io.cost_structure = 'CPA' then case when account.name = 'Zipcar' then sum(d.conversions_registrations)
                                                else sum(d.conversions)
                                           end
       when io.cost_structure = 'ThruPlays' then sum(d.thruplays)
       else 0                                           
  end as "Units Delivered"
, case when op.stage_name != 'Closed Won' then 0
       when io.cost_structure = 'Channel Management' then io.cost*greatest(0, (datediff('day',io.flight_start_date,least(current_date(),io.flight_end_date))+1)/(datediff('day',io.flight_start_date,io.flight_end_date)+1))
       when io.cost_structure = 'Insights Projects' then case when io.flight_end_date < current_date() then io.cost else 0 end
       when io.platform in ('Hulu','OTT','Amazon','Pinterest','SnapChat','Linkedin','Pandora') then io.cost*greatest(0, (datediff('day',io.flight_start_date,least(current_date(),io.flight_end_date))+1)/(datediff('day',io.flight_start_date,io.flight_end_date)+1))
       when io.cost_structure = '% of Spend - Customer Pays Media' then (io.fee/io.media_budget)*sum(d.spend)
       when io.cost_structure in ('% of Spend', 'Flat Fee') then (1+(io.fee/io.media_budget))*sum(d.spend)
       when io.cost_structure = 'CPV' then io.rate*sum(d.video_views)
       when io.cost_structure = 'CPM' then io.rate*(sum(d.impressions)/1000)
       when io.cost_structure = 'CPC' then io.rate*sum(d.clicks)
       when io.cost_structure = '10 second CPV' then io.rate*sum(d.view_10sec)
       when io.cost_structure = 'CPL' then io.rate*sum(d.post_reactions)
       when io.cost_structure = 'CPF' then io.rate*sum(d.page_likes)
       when io.cost_structure = 'CPA' then io.rate*case when account.name = 'Zipcar' then sum(d.conversions_registrations)
                                                        else sum(d.conversions)
                                                   end
       when io.cost_structure = 'ThruPlays' then io.rate*sum(d.thruplays)
       else 0
  end as "Executed Revenue Uncapped"
, case when op.stage_name != 'Closed Won' then 0
       when io.cost_structure = 'Insights Projects' then case when io.flight_end_date < current_date() then io.cost else 0 end
       when io.cost_structure = 'Channel Management' then io.cost*greatest(0, (datediff('day',io.flight_start_date,least(current_date(),io.flight_end_date))+1)/(datediff('day',io.flight_start_date,io.flight_end_date)+1))
       when io.platform in ('Hulu','OTT','Amazon','Pinterest','SnapChat','Linkedin','Pandora') then io.cost*greatest(0, (datediff('day',io.flight_start_date,least(current_date(),io.flight_end_date))+1)/(datediff('day',io.flight_start_date,io.flight_end_date)+1))
       when io.cost_structure = '% of Spend - Customer Pays Media' then (io.fee/io.media_budget)*sum(sum(d.spend)) over (partition by ifnull(io.contract_line_item,io.campaign_name) order by date_trunc('quarter', case when stage_name = 'Closed Won' then ifnull(d.date,op.flight_start_date) else op.flight_end_date end),io.campaign_name)
       when io.cost_structure in ('% of Spend', 'Flat Fee') then (1+(io.fee/io.media_budget))*sum(sum(d.spend)) over (partition by ifnull(io.contract_line_item,io.campaign_name) order by date_trunc('quarter', case when stage_name = 'Closed Won' then ifnull(d.date,op.flight_start_date) else op.flight_end_date end),io.campaign_name)
       when io.cost_structure = 'CPV' then io.rate*sum(sum(d.video_views)) over (partition by ifnull(io.contract_line_item,io.campaign_name) order by date_trunc('quarter', case when stage_name = 'Closed Won' then ifnull(d.date,op.flight_start_date) else op.flight_end_date end),io.campaign_name)
       when io.cost_structure = 'CPM' then io.rate*(sum(sum(d.impressions)/1000)) over (partition by ifnull(io.contract_line_item,io.campaign_name) order by date_trunc('quarter', case when stage_name = 'Closed Won' then ifnull(d.date,op.flight_start_date) else op.flight_end_date end),io.campaign_name)
       when io.cost_structure = 'CPC' then io.rate*sum(sum(d.clicks)) over (partition by ifnull(io.contract_line_item,io.campaign_name) order by date_trunc('quarter', case when stage_name = 'Closed Won' then ifnull(d.date,op.flight_start_date) else op.flight_end_date end),io.campaign_name)
       when io.cost_structure = '10 second CPV' then io.rate*sum(sum(d.view_10sec)) over (partition by ifnull(io.contract_line_item,io.campaign_name) order by date_trunc('quarter', case when stage_name = 'Closed Won' then ifnull(d.date,op.flight_start_date) else op.flight_end_date end),io.campaign_name)
       when io.cost_structure = 'CPL' then io.rate*sum(sum(d.post_reactions)) over (partition by ifnull(io.contract_line_item,io.campaign_name) order by date_trunc('quarter', case when stage_name = 'Closed Won' then ifnull(d.date,op.flight_start_date) else op.flight_end_date end),io.campaign_name)
       when io.cost_structure = 'CPF' then io.rate*sum(sum(d.page_likes)) over (partition by ifnull(io.contract_line_item,io.campaign_name) order by date_trunc('quarter', case when stage_name = 'Closed Won' then ifnull(d.date,op.flight_start_date) else op.flight_end_date end),io.campaign_name)
       when io.cost_structure = 'CPA' then io.rate*sum(case when account.name = 'Zipcar' then sum(d.conversions_registrations) else sum(d.conversions) end) over (partition by ifnull(io.contract_line_item,io.campaign_name) order by date_trunc('quarter', case when stage_name = 'Closed Won' then ifnull(d.date,op.flight_start_date) else op.flight_end_date end),io.campaign_name)
       when io.cost_structure = 'CPV' then io.rate*sum(sum(d.thruplays)) over (partition by ifnull(io.contract_line_item,io.campaign_name) order by date_trunc('quarter', case when stage_name = 'Closed Won' then ifnull(d.date,op.flight_start_date) else op.flight_end_date end),io.campaign_name)
       else 0
  end as "Executed Revenue Uncapped RT"

, zeroifnull(case when op.stage_name != 'Closed Won' then 0
                  when io.platform in ('Hulu','OTT','Amazon','Pinterest','SnapChat','Linkedin','Pandora') then ifnull(io.media_budget,.8*io.cost)*greatest(0,(datediff('day',io.flight_start_date, least(current_date(),io.flight_end_date))+1)/(datediff('day',io.flight_start_date, io.flight_end_date)+1))
                  else sum(d.spend) 
             end) as "Platform Spend"
, zeroifnull(case when op.stage_name != 'Closed Won' then 0
                  when io.platform in ('Hulu','OTT','Amazon','Pinterest','SnapChat','Linkedin','Pandora') then ifnull(io.media_budget,.8*io.cost)*greatest(0, (datediff('day',io.flight_start_date, least(current_date(),io.flight_end_date))+1)/(datediff('day',io.flight_start_date, io.flight_end_date)+1))
                  when io.cost_structure = '% of Spend - Customer Pays Media' then 0
                  else sum(d.spend)
             end) as "Pix Spend"
, max(rfp.id) as "RFP ID"
, max(rfp.created) as "RFP Created"

from (select name, id, account_id, advertiser, project_number, flight_start_date, flight_end_date, stage_name, owner_id, sold_margin, proposed_deal_margin, amount, industry_serviced, account_manager, campaign_manager_id from salesforce.opportunity where stage_name not in ('Cancelled','Closed Lost') and deleted = 'false' and source = 'SALESFORCE' and flight_end_date >= '2018-01-01') as op

left join (select id, source, campaign_name, contract_line_item, case when opportunity_id in ('0062A00000uT23aQAC','0062A00000uSqBeQAK','0062A00000ti4XZQAY','0062A00000t69nYQAQ','0062A00000sBeimQAC','0062A00000tjiUZQAY') then name else campaign_name end as join, opportunity_id, cost_structure, platform, io_currency, rate, units, fee, media_budget, media_type, cost, special_deal_margin, deleted, flight_start_date, flight_end_date
           from salesforce.iolineitem where deleted = 'false' and source = 'SALESFORCE') as io
on op.id=io.opportunity_id


left join(
select 'yt_'||campaign_id as id, name as campaign_name, account_id, case when account_id in('2885','2861','1933','1937','1936','2681','2682','1934','1935','1890') then right(name,13) else split_part(name,'_',1) end as join
from adwords.aw_campaign where state not in ('REMOVED')
Union all
Select 'fb_'||ad_set_id as id, name as campaign_name,account_id, split_part(name,'_',1) as join
from facebook.fb_ad_set
Union All
Select 'tw_'||campaign_id as id, name as campaign_name, 0 AS account_id, split_part(name,'_', 1) as join
from twitter.tw_campaign) as c
on c.join = io.join

left join
(select 'yt_'||campaign_id as id, to_date(date) as date, clicks, impressions, cost as spend, video_views, ((video_played_to_100_percent/100)*impressions) as video_p100_watched, 0 as page_likes, 0 as post_reactions, 0 as view_10sec, zeroifnull(conversions) as conversions, zeroifnull(conversions) as conversions_registrations, 0 as thruplays
from adwords.aw_campaign_summary_daily where impressions > 0
Union all
Select 'fb_'||ad_set_id as id, to_date(date) as date, actions_link_click as clicks, impressions, spend, actions_video_view as video_views, video_p100_watched, actions_like as page_likes, actions_post_reaction as post_reactions, video_10_sec_watched_video_view as view_10sec, zeroifnull(actions_offsite_conversion_fb_pixel_purchase) as conversions, zeroifnull(actions_offsite_conversion_fb_pixel_complete_registration) as conversions_registrations, video_thruplay_watched as thruplays
From facebook.fb_ad_set_summary_daily where impressions > 0
Union all
Select 'tw_'||campaign_id as id, to_date(date) as date, clicks as clicks, impressions, (_billed_charge_local_micro/1000000) AS spend, video_3s100pct_views AS video_views, video_views_100 AS video_p100_watched, 0 as page_likes, 0 AS post_reactions, 0 as view_10sec, 0 as conversions, 0 as conversions_registrations, 0 as thruplays
FROM twitter.tw_campaign_summary_daily where impressions > 0)as d
on d.id=c.id

left join (select id, name from salesforce.account) as account
on account.id=op.account_id

left join (select id, name from salesforce.account) as advertiser
on advertiser.id=op.advertiser

left join (select id, first_name||' '||last_name as name from salesforce.user) as seller
on seller.id=op.owner_id

left join (select id, first_name||' '||last_name as name from salesforce.user) as am
on am.id=op.account_manager

left join (select id, first_name||' '||last_name as name from salesforce.user) as cm
on cm.id=op.campaign_manager_id

left join (select opportunity_id , min(id) as id, min(created) as created from salesforce.rfp_requests group by opportunity_id) as rfp
on op.id=rfp.opportunity_id

where account.name != 'Jimmy''s Widgets'
and op.flight_end_date >= '2018-01-01'


group by 
seller.name
, am.name
, cm.name
, account.name
, advertiser.name
, op.name
, op.stage_name
, op.project_number
, op.amount
, op.proposed_deal_margin
, op.sold_margin
, io.contract_line_item
, io.campaign_name
, io.flight_start_date
, io.flight_end_date
, op.flight_start_date
, op.flight_end_date
, io.cost_structure
, io.io_currency
, io.platform
, io.fee
, io.cost
, io.special_deal_margin
, io.media_budget
, io.rate
, io.units
, "Quarter"
, date_trunc('quarter', case when stage_name = 'Closed Won' then ifnull(d.date,op.flight_start_date) else op.flight_end_date end)
, op.industry_serviced

order by op.name, io.contract_line_item, "Quarter", io.campaign_name