select
stats.yt_channel_id as "YT Channel ID"
, stats.channel_title as "Channel Title"
, stats.video_title as "Video"
, stats.yt_video_id as "YT Video ID"
, stats.published_date as "Published Date"
, stats.month as "Month"
, stats.views as "Views (All Time)"
, lag(stats.views,-1) over (partition by stats.yt_video_id order by month desc) as "Previous Views (All Time)"
, stats.yt_likes as "Likes (All Time)"
, lag(stats.yt_likes,-1) over (partition by stats.yt_video_id order by month desc) as "Previous Likes (All Time)"
, stats.yt_dislikes as "Dislikes (All Time)"
, lag(stats.yt_dislikes,-1) over (partition by stats.yt_video_id order by month desc) as "Previous Dislikes (All Time)"
, stats.yt_comments as "Comments (All Time)"
, lag(stats.yt_comments,-1) over (partition by stats.yt_video_id order by month desc) as "Previous Comments (All Time)"
, pvp.pvp

from (select yt_channel_id
, channel_title
, video_title
, yt_video_id
, to_date(published_date) as published_date
, date_trunc('month',to_date(date)) as month
, ifnull(max(to_number(views)),0) as views
, ifnull(max(to_number(yt_likes)),0) as yt_likes
, ifnull(max(to_number(yt_dislikes)),0) as yt_dislikes
, ifnull(max(to_number(yt_comments)),0) as yt_comments
 from thresher.yt_video_stats_over_time
 where date >= '2018-10-01'
 and yt_channel_id in(
'UCsgTfnHjztU_6jSwYNgI7rg',
'UCg__God7HOZZDcRgWL7QDig',
'UCrwrkI-NNS9bd9ag7Q4T-Mg',
'UCzErnyi4D20tENhWNwKTEiA',
'UC23ZqC2LTzl7dfOi6EmwJhg',
'UC2iyoboMHmOubKYd73uYJwQ',
'UCFBF2c5VihWlngbB-ziMxYQ',
'UClrnM-TRoxc-Mv48wgkukrg',
'UCQXqDziZy-elQL6SnCVCF7A',
'UCqu56uzQXudA5dmBifP6DIQ',
'UCcC9j3rVfnpoiW0Hmdf0enA',
'UCO1328RJ5y-TrR2oRq9fBYw',
'UC6p8ND29iGJGr-Etl3-3PJA',
'UCnPsCURqHlcoRt-Vr7nEaEg',
'UCnPsCURqHlcoRt-Vr7nEaEg',
'UCUN4J9T7bggwD2MJSj2uJmw',
'UCKwGkHFAzXwZV_uy17rFFhA',
'UCHjjLvkV9fupzVMcG3XKsNg',
'UCKjEDIcmcU5AEEkOZTcQVzQ',
'UCY0Ad2H_36GDhtnt7LcLwFg',
'UCR8RWMHZcSgqjD0HiUiJ_cQ',
'UC2Lvkh9QtUTUcn5zr61h5bg',
'UCN6BqkKGqcvUkMF8Z8sgasA',
'UC6KZce9HxX5GQ1-xQCqjV1Q',
'UCzzVWkHCJjdinluij3PVKaA',
'UCRI5ZedBs0_BYY4PlxD6m7w',
'UCPp-1WEbN-ZSr90PFZzwxlg',
'UC_Daq1fn_jE8Q_1GyswYaGg',
'UClAeHT9HosrAVMTwCdqBUDw',
'UC4Qqag_OPteBcE_DrTe2qlg',
'UCAUsOKISDoLB82RF1xMr2pA',
'UCmHNk3DjDiDzuVrj0aiprZQ',
'UCBEZh6fiU1m_7uf3JnLObZQ',
'UCleaxi80gUutOZPYplLM4EQ',
'UCYGkTMJGxaVfR1RvQ_MWvpg',
'UCpRycHNXPaywifhbf9mf49Q',
'UCj4nCgtjKJppK_IZeY8TUJg',
'UC8inkpxtNUCYXK88Fs-aycA',
'UCRoNIIMxKS_LjPH8nAM25ag',
'UCGAWuGsaWysuMHbj0w2-Ffw',
'UC_oe3z-MmiibqNtRvBKZQig',
'UCxXHHbiGUO3RziA5kW0m1qw',
'UCySeCVl8B2kU8kC6StFplBw',
'UC5v8tFxTDjUDwOxUNaDlLYg',
'UCeSJqMdWCwfEPRlYF6T1ptA',
'UCvosDm9y9asCOt4d235yRIg',
'UCZJzQQHTr43nnaVgZciMp7g',
'UClAeHT9HosrAVMTwCdqBUDw',
'UCXsjDtgewwb8LHwJBfPHj_g',
'UCWOu1PYyLCWNgsC10KMR97w',
'UCoq3jKLmDNOwKJ0P-FonX4g',
'UCbMyYANczY_Eze_-CXrYyNA',
'UCqVPigYYshdm-xjaldCMyXw',
'UC9aIkmobBYtak1vOVrd6MGg',
'UChtMUHysfGfTPiWieYJY65g',
'UCJ0jFqwzEUT2zecm0G0LPJQ',
'UChGfFA4ktuNXW9cZJyggIeQ',
'UCU5vGl4m-4EqWQFUW_9ZwfA')

group by 
 yt_channel_id
, channel_title
, video_title
, yt_video_id
, month
, published_date

) as stats

left join (select yt_channel_id , yt_video_id, paid_view_percentage as pvp from thresher.yt_video_stats) as pvp
on pvp.yt_video_id=stats.yt_video_id


limit 10000