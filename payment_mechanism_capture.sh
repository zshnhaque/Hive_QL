create table aureus_temp.payment_mecha as 
select policytechnicalid,min(to_date(branchapprovaldate)) as first_branchapprovaldate
from mis_data.payment where paymentoperationtype in ('Initial Payment') 
and paymenttype in ('Money IN') and paymentvalid == 'True' and paymentstatus == 'Realised'
group by policytechnicalid;

insert overwrite table  aureus_temp.payment_mecha select distinct * from  aureus_temp.payment_mecha; 

create table aureus_temp.payment_mecha1 as 
select policytechnicalid, paymentmechanism ,branchapprovaldate,instrumentreceiveddate,paymentamount
from mis_data.payment 
where concat(policytechnicalid,'|',to_date(branchapprovaldate)) 
in (select concat(policytechnicalid,'|',first_branchapprovaldate) from aureus_temp.payment_mecha)
and paymentoperationtype in ('Initial Payment') 
and paymenttype in ('Money IN') and paymentvalid == 'True' and paymentstatus == 'Realised';

insert overwrite table  aureus_temp.payment_mecha1 select distinct * from  aureus_temp.payment_mecha1; 

create table aureus_temp.payment_mecha2 as
select policytechnicalid,to_date(branchapprovaldate) AS branchapprovaldate,min(to_date(instrumentreceiveddate)) as instrumentreceiveddate
from aureus_temp.payment_mecha1 
group by policytechnicalid , to_date(branchapprovaldate)

insert overwrite table  aureus_temp.payment_mecha2 select distinct * from  aureus_temp.payment_mecha2;

create table aureus_temp.payment_mecha3 as
select policytechnicalid, paymentmechanism ,branchapprovaldate,instrumentreceiveddate,paymentamount
from aureus_temp.payment_mecha1 
where concat(policytechnicalid,'|',to_date(branchapprovaldate),'|',to_date(instrumentreceiveddate))
in (select concat(policytechnicalid,'|',to_date(branchapprovaldate),'|',to_date(instrumentreceiveddate)) from aureus_temp.payment_mecha2);

insert overwrite table  aureus_temp.payment_mecha3 select distinct * from  aureus_temp.payment_mecha3;

create table aureus_temp.payment_mecha4 as
select policytechnicalid,branchapprovaldate,instrumentreceiveddate,max(paymentamount) as paymentamount
from aureus_temp.payment_mecha3  where paymentoperationtype in ('Initial Payment') 
and paymenttype in ('Money IN') and paymentvalid == 'True' and paymentstatus == 'Realised'
group by policytechnicalid,to_date(branchapprovaldate);

insert overwrite table  aureus_temp.payment_mecha4 select distinct * from  aureus_temp.payment_mecha4;

create table aureus_temp.payment_mecha5 as
select t.*,t1.paymentmechanism from 
aureus_temp.payment_mecha4 t left join
aureus_temp.payment_mecha3 t1
on concat(t.policytechnicalid,'|',to_date(t.branchapprovaldate),'|',to_date(t.instrumentreceiveddate),'|',cast(t.paymentamount as string)) =
  concat(t1.policytechnicalid,'|',to_date(t1.branchapprovaldate),'|',to_date(t1.instrumentreceiveddate),'|',cast(t1.paymentamount as string));

create table aureus_temp.payment_mecha5_req as
select * from aureus_temp.payment_mecha5 where
policytechnicalid in (select policytechnicalid from early_claim.apr18_may19_1);

select count(*) as total, count(distinct policytechnicalid) as distinct_pol from 
aureus_temp.payment_mecha5_req

select policytechnicalid, count(*) as freq
from aureus_temp.payment_mecha1 
group by policytechnicalid 
order by freq desc; 


###

select * from aureus_temp.payment_mecha where 
policytechnicalid in ('1X00606868','1BYA018784','35YA018733','35YA018767','44AB224842');

$$$

  select * from mis_data.payment where concat(policytechnicalid,':',to_date(branchapprovaldate)) in
  ('35YA018733:2015-11-16',
   '1X00606868:2015-11-26',
   '35YA018767:2015-11-16',
   '1BYA018784:2015-11-16',
   '44AB224842:2012-06-25')
and paymentoperationtype in ('Initial Payment') 
and paymenttype in ('Money IN') and paymentvalid == 'True'; 

select * from aureus_temp.payment_mecha where 
policytechnicalid in ('35YA018815','1BQY710015','1KAH613387','1KAL335981','53NA469678');

select * from mis_data.payment where concat(policytechnicalid,':',to_date(branchapprovaldate)) in 
('35YA018815:2015-11-16','1KAL335981:2015-12-31','53NA469678:2018-09-14','1BQY710015:2018-02-28','1KAH613387:2016-03-14')
and paymentoperationtype in ('Initial Payment') 
and paymenttype in ('Money IN') and paymentvalid == 'True'; 

select * from aureus_temp.payment_mecha1 where concat(policytechnicalid,':',to_date(branchapprovaldate)) in 
('35YA018815:2015-11-16','1KAL335981:2015-12-31','53NA469678:2018-09-14','1BQY710015:2018-02-28','1KAH613387:2016-03-14'); 