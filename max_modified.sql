select 'iolineitem' as "table", max(to_timestamp_ntz(modified)) as "modified" from salesforce.iolineitem
union all
select 'opportunity' as "table", max(to_timestamp_ntz(modified)) as "modified" from salesforce.opportunity
union all
select 'aw_campaign' as "table", max(to_timestamp_ntz(modified)) as "modified" from adwords.aw_campaign
union all
select 'aw_campaign_summary_daily' as "table", max(to_timestamp_ntz(modified)) as "modified" from adwords.aw_campaign_summary_daily
union all
select 'aw_ad_group_ad' as "table", max(to_timestamp_ntz(modified)) as "modified" from adwords.aw_ad_group_ad
union all
select 'aw_aw_ad_group_ad_summary_daily' as "table", max(to_timestamp_ntz(modified)) as "modified" from adwords.aw_ad_group_ad_summary_daily
union all
select 'fb_ad_set' as "table", max(to_timestamp_ntz(modified)) as "modified" from facebook.fb_ad_set
union all
select 'fb_ad_set_summary_daily' as "table", max(to_timestamp_ntz(modified)) as "modified" from facebook.fb_ad_summary_daily
union all
select 'fb_ad' as "table", max(to_timestamp_ntz(modified)) as "modified" from facebook.fb_ad
union all
select 'fb_ad_summary_daily' as "table", max(to_timestamp_ntz(modified)) as "modified" from facebook.fb_ad_summary_daily;
;

select 'aw_campaign_summary_daily' as "table", max(to_timestamp_ntz(date)) as "max date" from adwords.aw_campaign_summary_daily
union all
select 'fb_ad_set_summary_daily' as "table", max(to_timestamp_ntz(date)) as "max date" from facebook.fb_ad_set_summary_daily
;