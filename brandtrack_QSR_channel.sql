select
hist.yt_channel_id as "YT Channel ID"
, hist.channel_name as "Channel Name"
, hist.title as "Title"
, to_date(hist.modified) as "Date"
, max(hist.subscribers) as "Subscribers"
, max(hist.total_videos) as "Videos"
, max(hist.total_views) as "Views"
, max(pvp.pvp)*max(hist.total_views) as "Paid Views"

from thresher.yt_channel_history as hist

left join (select yt_channel_id , case when sum(views) = 0 then 0 else sum(paid_view_percentage*views)/sum(views) end as pvp from thresher.yt_video_stats group by yt_channel_id) as pvp
on pvp.yt_channel_id=hist.yt_channel_id

where hist.yt_channel_id in (
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
hist.yt_channel_id
, hist.channel_name
, hist.title
, "Date"