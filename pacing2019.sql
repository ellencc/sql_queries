select
case when am.name = 'Heather Peterson' then account_level_am.name
       else am.name
  end as "Account Manager"
, cm.name as "Campaign Manager"
, seller.name as "Seller"
, Account.name as "Account"
, Op.name as "Opportunity"
, op.project_number as "Project Number"
, io.campaign_name as "Line Item"
, io.id as "Line Item ID"
, case when max(coe.enable) > 0 then 'Yes'
       else 'No'
  end as "On COE" 
, io.cost_structure as "Cost Structure" 
, io.media_type as "Media Type"
, io.flight_start_date as "Flight Start"
, io.flight_end_date as "Flight End"
, case when io.flight_end_date < current_date() then 'Ended'
       when io.flight_start_date > current_date() then 'Not Started'
       when datediff('day',current_date(),io.flight_end_date)+1 <= 4 then 'Ending Soon'
       else 'Running'
  end as "Status"
, case when datediff('day',current_date(),io.flight_end_date)+1 < 0 then ''
       when datediff('day',current_date(),io.flight_end_date)+1<= 4 then 'Ending'
       else ''
  end as "Ending Soon"
, io.platform as "Platform"
, case when io.cost_structure = '% of Spend - Customer Pays Media' then io.fee 
       else io.cost 
  end as "Line Item Value"
, ifnull(io.io_currency,'USD') as "IO Currency"
, io.special_deal_margin/100 as "Special Deal Margin"
, case when io.special_deal_margin is null then 'Performance Deal'
       else 'Special Deal'
  end as "Deal Type"
, case when io.cost_structure = '% of Spend' then 1+(io.fee/io.media_budget)
       when io.cost_structure = '% of Spend - Customer Pays Media' then (io.fee/io.media_budget)
       else io.rate
  end as "Contracted Rate" 
, case when io.cost_structure = '% of Spend' then io.media_budget
       when io.cost_structure = '% of Spend - Customer Pays Media' then io.media_budget
       else io.units
  end as "Contracted Units" 
, io.media_budget as "Media Budget"
, io.fee as "Fee"
, case when io.cost_structure in ('% of Spend','% of Spend - Customer Pays Media') then sum(daily.spend)
       when io.cost_structure = 'CPV' then sum(daily.video_views)
       when io.cost_structure = 'CPM' then sum(daily.impressions)
       when io.cost_structure = 'CPC' then sum(daily.clicks)
       when io.cost_structure = '10 second CPV' then sum(daily.view_10sec)
       when io.cost_structure = 'CPL' then sum(daily.post_likes)
       when io.cost_structure = 'CPF' then sum(daily.page_likes) 
       when io.cost_structure = 'CPA' then case when io.campaign_name like '%Zipcar%' then sum(daily.conversions_registrations) else sum(daily.conversions) end
       when io.cost_structure = 'ThruPlays' then sum(daily.thruplays)
  end as "Units Delivered"
, sum(daily.spend) as "Spend"
, sum(case when daily.date = current_date() then daily.spend else 0 end) as "Today's Spend"
, sum(case when daily.date = timestampadd('day',-1,current_date()) then daily.spend else 0 end) as "Yesterday's Spend"
, sum(daily.video_views) as "Views"
, sum(daily.impressions) as "Impressions"
, sum(daily.clicks) as "Clicks"
, sum(daily.video_p100_watched) as "Completed Views"
, current_timestamp() as "Current Time"
,'https://na42.salesforce.com/'||op.id as "Salesforce Link"
, timestampadd('hour',-5,max(daily.modified)) as "Last Updated"


from (select id, account_id, name, owner_id, account_manager, campaign_manager_id, stage_name, project_number, flight_start_date, flight_end_date
        from salesforce.opportunity where stage_name = 'Closed Won' and source = 'SALESFORCE' and deleted = 'false' and flight_end_date >= '2019-01-01') as Op

left join (select id, opportunity_id, case when opportunity_id in ('0062A00000uT23aQAC','0062A00000uSqBeQAK','0062A00000ti4XZQAY','0062A00000t69nYQAQ','0062A00000sBeimQAC','0062A00000tjiUZQAY') then name else campaign_name end as join,  campaign_name, cost_structure, media_budget, fee, cost, rate, units, media_type, special_deal_margin, flight_start_date, flight_end_date, platform,io_currency
      from salesforce.iolineitem where deleted = 'false' and cost_structure not in ('Insights Projects', 'Channel Management') and platform not in('Amazon','OTT','Hulu','Pinterest')) as io
on op.id=io.opportunity_id

left join
(Select 'yt_'||campaign_id as id, name, case when account_id in ('2885','2861','1933','1937','1936','2681','2682','1934','1935','1890') then right(name,13) else split_part(name,'_',1) end as join
from adwords.aw_campaign
Union all
Select 'fb_'||ad_set_id as id, name, split_part(name,'_',1) as join
from facebook.fb_ad_set
) as campaign
on campaign.join=io.join

left join
(select 'yt_'||campaign_id as id, to_date(date) as date, clicks, impressions, cost as spend, video_views, to_timestamp_ntz(modified) as modified, ((video_played_to_100_percent/100)*impressions) as video_p100_watched,0 as page_likes, 0 as post_likes, 0 as view_10sec, conversions, conversions as conversions_registrations, 0 as thruplays
from adwords.aw_campaign_summary_daily where impressions > 0
Union all
Select 'fb_'||ad_set_id as id,to_date(date) as date, actions_link_click as clicks, impressions, spend, actions_video_view as video_views, to_timestamp_ntz(modified) as modified, video_p100_watched, actions_like as page_likes, actions_post_reaction as post_likes, video_10_sec_watched_video_view as view_10sec, actions_offsite_conversion_fb_pixel_purchase as conversions, actions_offsite_conversion_fb_pixel_complete_registration as conversions_registration, video_thruplay_watched as thruplays
From facebook.fb_ad_set_summary_daily where impressions > 0
) as daily
on daily.id=campaign.id

left join (select id, name, account_manager_id from salesforce.Account) as Account
on Account.id=Op.account_id
left join (select id, first_name||' '||last_name as name from salesforce.user) as cm
on cm.Id=Op.campaign_manager_id
left join (select id, first_name||' '||last_name as name from salesforce.User) as seller
on seller.Id=Op.owner_id
left join (select id, first_name||' '||last_name as name from salesforce.User) as am
on am.id=Op.account_manager
left join(select id, first_name||' '||last_name as name from salesforce.user) as account_level_am
on account_level_am.id=account.account_manager_id

left join (select iolineitem_id, max(enable) as enable from coe.coe_aw_campaign_set group by iolineitem_id)  as coe
on coe.IOLineItem_id=io.id

where io.cost_structure not in ('Insights Projects', 'Channel Management')
and date_trunc('quarter',op.flight_start_date) <= date_trunc('quarter',current_date())
and date_trunc('quarter',op.flight_end_date) >= timestampadd('day',-14,date_trunc('quarter',current_date()))
and account.name not in ('Jimmy''s Widgets') 

group by
"Account Manager"
, cm.name
, seller.name 
, account.name
, op.name 
, op.project_number 
, op.id
, io.campaign_name 
, io.cost_structure 
, io.media_type
, io.flight_start_date
, io.flight_end_date
, io.platform
, io_currency
, io.special_deal_margin
, io.cost
, io.units
, io.rate
, io.media_budget
, io.fee
, io.id