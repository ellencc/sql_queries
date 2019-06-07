select 
channel_name as "Channel"
, channel_id as "Channel ID"
, date_trunc('month', to_date(date,'yyyymmdd')) as "Month"
, case when device_type =100 then 'Unknown'
       when device_type =101 then 'Desktop'
       when device_type =102 then 'TV'
       when device_type =103 then 'Game console'
       when device_type =104 then 'Mobile phone'
       when device_type =105 then 'Tablet'
       end as "Device"
, sum((average_view_duration_percentage/100)*views) as "Weighted % Watched"
, sum(views) as "Views"

from thresher.yt_channel_management_devices

where channel_id = 'UCH1NCeEsEXr1UlnfK6ydiYQ'

group by 
channel_name
, channel_id
, "Month"
, "Device"