select *
from(
select
op.industry_serviced as "Client Industry"
, iab.top_1_category_name as "Category 1"
, iab.top_2_category_name as "Category 2"
, iab.top_3_category_name as "Category 3"
, case when ag.video_ad_format = 'INDISPLAY' then 'Discovery'
       when ag.video_ad_format = 'INSTREAM' then 'InStream'
       else initcap(ag.video_ad_format)
   end as "Ad Format"
, age.age as "Age"
, gender.gender as "Gender"
, d.displayname as "URL"
, sum(d.videoviews) as "Views"
, sum(d.impressions) as "Impressions"
, row_number() over (partition by op.industry_serviced, iab.top_1_category_name order by sum(d.impressions) desc) as impression_rank
, sum(d.clicks) as "Clicks"
, sum(d.spend) as "Spend"

from (select id, account_id, name, owner_id, account_manager, campaign_manager_id, stage_name, project_number, flight_start_date, flight_end_date, industry_serviced
        from salesforce.opportunity where stage_name = 'Closed Won' and source = 'SALESFORCE' and deleted = 'false' and flight_end_date >= '2018-04-01' and flight_start_date <= '2018-12-31') as Op

left join (select id, opportunity_id, case when opportunity_id in ('0062A00000uT23aQAC','0062A00000uSqBeQAK','0062A00000ti4XZQAY','0062A00000t69nYQAQ','0062A00000sBeimQAC','0062A00000tjiUZQAY') then name else campaign_name end as join,  campaign_name, cost_structure, media_budget, fee, cost, rate, units, media_type, special_deal_margin, flight_start_date, flight_end_date, platform,io_currency
      from salesforce.iolineitem where deleted = 'false' and cost_structure not in ('Insights Projects', 'Channel Management') and platform = 'YouTube') as io
on op.id=io.opportunity_id

left join (select case when externalcustomerid in ('5768111697','1172345766','6650346217','2711098858','6531459393','5068152415','3301946039','7798070101','6849642219','8162724672') then right(campaignname,13) else split_part(campaignname,'_',1) end as join, campaignname, campaignid, adgroupid, adgroupname, displayname, replace(displayname,'www.youtube.com/video/') as video_id,domain, to_date(date) as date, videoviews, impressions, clicks, cost/1000000 as spend
 from adwords.aw_url_placements where impressions > 0 ) as d
on d.join=io.join

left join(select ad_group_id, aw_ad_group_id, video_ad_format from adwords.aw_ad_group) as ag
on ag.aw_ad_group_id=d.adgroupid

left join(
select ad_group_id, listagg(age.name,',') as age
from(select ad_group_id, age_id from adwords.aw_age_summary_daily group by ad_group_id, age_id order by ad_group_id, age_id) as d
left join (select age_id, name from adwords.aw_age) as age on age.age_id=d.age_id
group by ad_group_id
) as age
on age.ad_group_id=ag.ad_group_id

left join(
select ad_group_id, listagg(gender.name,',') as gender
from(select ad_group_id, gender_id from adwords.aw_gender_summary_daily group by ad_group_id, gender_id order by ad_group_id, gender_id) as d
left join (select gender_id, name from adwords.aw_gender) as gender on gender.gender_id=d.gender_id
group by ad_group_id
) as gender
on gender.ad_group_id=ag.ad_group_id

left join thresher.category_video_iab_scores_2 as iab
on iab.yt_video_id=d.video_id

where (iab.top_1_category_name is not null or iab.top_2_category_name is not null or iab.top_3_category_name is not null)

group by 
op.industry_serviced 
, iab.top_1_category_name 
, iab.top_2_category_name 
, iab.top_3_category_name 
, age.age
, ag.video_ad_format
, gender.gender
, d.displayname
)sub
where impression_rank < 10
limit 100