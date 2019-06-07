SELECT top_1_category_name,
   industry_serviced, 
   gender_groups_targeted,
   age_groups_targeted,
   AVG(VR) as VR,
   AVG(CPV) as CPV,
   AVG(CPM) as CPM,
   AVG(PVP) as PVP

from (

select 

   iab.top_1_category_name,
   opp.industry_serviced, 
   gender_table.gender_groups_targeted,
   age_table.age_groups_targeted,
   c.yt_channel_id,
   SUM(a.VIDEOVIEWS) / NULLIF(SUM(a.IMPRESSIONS), 0)   as VR,
   SUM(a.COST / 1000000.0)  / NULLIF(SUM(a.VIDEOVIEWS), 0) as CPV,
   AVG(c.paid_view_percentage) as PVP,
   SUM(a.COST / 1000000.0) / NULLIF(SUM(a.IMPRESSIONS),0) * 1000 as CPM,
   COUNT(*) as n
FROM adwords.aw_url_placements a 
join (select YT_VIDEO_ID, 'www.youtube.com/video/' || YT_VIDEO_ID as DISPLAYNAME, DESCRIPTION as video_description, TITLE as video_title, YT_TAGS as video_tags, VIDEO_STATS_DATA:views as video_views, VIDEO_STATS_DATA:paid_view_percentage as paid_view_percentage, CHANNEL_DATA:yt_channel_id as yt_channel_id from thresher.yt_video where video_views >= 500) c on a.DISPLAYNAME = c.DISPLAYNAME
join (select CHANNEL_NAME as channel_name, THUMBNAIL as channel_thumbnail, SUBSCRIBERS as channel_subscribers, TITLE as channel_title, YT_CHANNEL_ID as yt_channel_id, COUNTRY_CODE as channel_country_code from thresher.yt_channel where SUBSCRIBERS >= 2000) d on c.yt_channel_id = d.yt_channel_id

left join thresher.CATEGORY_VIDEO_IAB_SCORES_2 iab on iab.yt_video_id = c.yt_video_id

left join (select distinct aw_ad_group_id, ad_group_id as pix_ad_group_id from adwords.aw_ad_group ) as ad_grp_id_map_table 
    on a.adgroupid = ad_grp_id_map_table.aw_ad_group_id 
left join (select distinct aw_campaign_id, campaign_id as pix_campaign_id, SPLIT_PART(name, '_', 1) as campaign_set_name  from adwords.aw_campaign ) as cm_id_map_table 
    on a.campaignid = cm_id_map_table.aw_campaign_id

left join salesforce.iolineitem as iol on iol.campaign_name = cm_id_map_table.campaign_set_name
left join salesforce.opportunity as opp on opp.id = iol.opportunity_id   

left join 

(

    select ad_group_id, LISTAGG( age , ' | ') as age_groups_targeted from 
    (
        select 
        age_tbl.ad_group_id, 
        age_tbl.name as age
        from 
        (
        select age_daily.*, aw_age.name, 
        row_number() over (partition by date, campaign_id, ad_group_id, age_daily.age_id order by age_daily.version desc) as seqnum 
        from adwords.aw_age_summary_daily age_daily

        join adwords.aw_age 
        on aw_age.age_id = age_daily.age_id
        ) age_tbl

        where age_tbl.seqnum <=1 
        and YEAR(age_tbl.date) >= '2018'
        group by ad_group_id, age
        order by ad_group_id, age
    ) age_adgrp
    where age != 'Undetermined'
    group by ad_group_id

) as age_table on age_table.ad_group_id = ad_grp_id_map_table.pix_ad_group_id

left join

(

    select ad_group_id, LISTAGG( gender , ' | ') as gender_groups_targeted from 
    (
        select 
        gender_tbl.ad_group_id, 
        gender_tbl.name as gender
        from 
        (
        select gender_daily.*, aw_gender.name, 
        row_number() over (partition by date, campaign_id, ad_group_id, gender_daily.gender_id order by gender_daily.version desc) as seqnum 
        from adwords.aw_gender_summary_daily gender_daily

        join adwords.aw_gender
        on aw_gender.gender_id = gender_daily.gender_id
        ) gender_tbl

        where gender_tbl.seqnum <=1 
        and YEAR(gender_tbl.date) >= '2018'
        group by ad_group_id, gender
        order by ad_group_id, gender
    ) gender_adgrp
    where gender != 'Undetermined'
    group by ad_group_id

) as gender_table on gender_table.ad_group_id = ad_grp_id_map_table.pix_ad_group_id

group by iab.top_1_category_name, opp.industry_serviced,gender_table.gender_groups_targeted, age_table.age_groups_targeted,c.yt_channel_id
having SUM(IFNULL(a.VIDEOVIEWS,0)) > 30

                        ) 

                        group by top_1_category_name,industry_serviced, gender_groups_targeted, age_groups_targeted