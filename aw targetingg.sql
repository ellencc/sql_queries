select 
c.name as campaign
, ag.name as adgroup
, d.type
, ifnull(aud.name,d.name) as "Name"
, sum(impressions)

from adwords.aw_campaign as c

left join adwords.aw_ad_group as ag
on ag.campaign_id=c.campaign_id

left join 
(select interest_id as id,'' as  name, ad_group_id, 'interests' as type, impressions, video_views from adwords.aw_audience_summary_daily
union all 
select keyword_id as id,'' as  name, ad_group_id, 'keywords' as type, impressions, video_views from adwords.aw_keyword_summary_daily
union all 
select topic_id as id,'' as  name, ad_group_id, 'topic' as type, impressions, video_views from adwords.aw_topic_summary_daily
union all 
select  id, userlistname as  name, adgroupid as ad_group_id, 'remarketing' as type, impressions, videoviews as video_views from adwords.aw_remarketing_lists
) as d
on case when ag.name like '%emarketing%' then d.ad_group_id=ag.aw_ad_group_id else d.ad_group_id=ag.ad_group_id end

left join (
select interest_id as id, name from adwords.aw_interest 
union all
select keyword_id as id, text as name from adwords.aw_keyword
union all
select topic_id as id, name from adwords.aw_topic
)as aud
on aud.id=d.id

where c.name like '%10405%'
and ag.state = 'ENABLED'

group by 
"Name"
, c.name 
, ag.name 
, d.type
