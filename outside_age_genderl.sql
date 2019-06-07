select 
channel_name as "Channel"
, channel_id as "Channel ID"
, date_trunc('month',to_date(date,'yyyymmdd')) as "Month"
, case when replace(age_group,'AGE_','') = '65_' then '65+'
       else replace(replace(age_group,'AGE_',''),'_','-')
  end as "Age"
, case when gender = 'GENDER_OTHER' then 'Other'
       else initcap(gender) 
  end as "Gender"
, avg(views_percentage/100) as "Monthly Avg % Views"

from thresher.yt_channel_management_demographics

where channel_id = 'UCH1NCeEsEXr1UlnfK6ydiYQ'

group by 
channel_name
, channel_id
, "Month"
, age_group
, gender