select 
account.name as "Account"
, case when account.name = 'Centro CHI' then 'Centro CHI'
      else advertiser.name
 end as "Advertiser"
, op.name as "Opportunity"
 , op.id as "Opportunity ID"
, op.flight_start_date as "Opp. Flight Start"
, op.flight_end_date as "Opp. Flight End"
, to_date(op.created) as "Opp. Created"
, date_trunc('quarter',op.created) as "Quarter Opp. Created"
, op.close_date as "Opp. Close Date"
, 1 as "Opp. Count"
, op.amount as "Opp. Amount"
, ifnull(op.industry_serviced,'None') as "Vertical"
, op.stage_name as "Stage Name"
, seller.name as "Seller"
, rfp.assigned_to as "RFP Assigned To"
, rfp.id as "RFP ID"
, to_date(rfp.created) as "RFP Created"
, to_date(rfp.due_date) as "RFP Due Date"
, case when rfp.id is not null then 1
       else 0
  end as "RFP Count"
, case when min(case when stage_name = 'Closed Won' then to_date(ifnull(op.flight_start_date,op.created)) else null end) over (partition by advertiser.name) is null then case when rfp.id is null then 'New - No RFP' else 'New' end
       when ifnull(op.flight_start_date,op.created) < min(case when stage_name = 'Closed Won' then to_date(ifnull(op.flight_start_date,op.created))else null end) over (partition by advertiser.name) then case when rfp.id is null then 'New - No RFP' else 'New' end
       when ifnull(op.flight_start_date,op.created) = min(case when stage_name = 'Closed Won' then to_date(ifnull(op.flight_start_date,op.created))else null end) over (partition by advertiser.name) then 
               case when op.created <= min(case when stage_name = 'Closed Won' then to_date(op.created) else null end) over (partition by advertiser.name, op.flight_start_date)  then case when rfp.id is null then 'New - No RFP' else 'New' end
                     else case when rfp.id is null then 'Returning - No RFP' else 'Returning' end
                 end       
       else case when rfp.id is null then 'Returning - No RFP' else 'Returning' end
  end as "Advertiser Type"
, case when min(case when stage_name = 'Closed Won' then to_date(ifnull(op.flight_start_date,op.created)) else null end) over (partition by account.name) is null then case when rfp.id is null then 'New - No RFP' else 'New' end
       when ifnull(op.flight_start_date,op.created) < min(case when stage_name = 'Closed Won' then to_date(ifnull(op.flight_start_date,op.created))else null end) over (partition by account.name) then case when rfp.id is null then 'New - No RFP' else 'New' end
       when ifnull(op.flight_start_date,op.created) = min(case when stage_name = 'Closed Won' then to_date(ifnull(op.flight_start_date,op.created))else null end) over (partition by account.name) then 
               case when op.created <= min(case when stage_name = 'Closed Won' then to_date(op.created) else null end) over (partition by account.name, op.flight_start_date)  then case when rfp.id is null then 'New - No RFP' else 'New' end
                     else case when rfp.id is null then 'Returning - No RFP' else 'Returning' end
                 end
       else case when rfp.id is null then 'Returning - No RFP' else 'Returning' end
  end as "Account Type"
    
from (select name, id, stage_name, flight_start_date, flight_end_date, account_id, advertiser, owner_id, to_date(created) as created, to_date(close_date) as close_date, amount, industry_serviced from salesforce.opportunity where source = 'SALESFORCE' and deleted = 'false'and ifnull(flight_start_date,created) >= '2017-01-01')as op

left join (select id, created, assigned_to, due_date, opportunity_id from salesforce.rfp_requests) as rfp
on op.id=rfp.opportunity_id

left join (select id, first_name||' '||last_name as name from salesforce.user) as seller
on seller.id=op.owner_id

left join (select id, name from salesforce.account) as advertiser
on advertiser.id=op.advertiser

left join (select id, name from salesforce.account) as account
on account.id=op.account_id

where case when account.name is null then account.name is null 
           else account.name not in ('Jimmy''s Widgets', 'TEST ACCOUNT')
      end
and op.stage_name is not null

order by "Account", op.flight_start_date, op.created