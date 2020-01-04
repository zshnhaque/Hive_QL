
create table aureus_temp.pol_dt1 as 
select trim(policytechnicalid) as policytechnicalid,
policyproposalnumber,policynumber,
policysumassured,to_date(policyriskcommencementdate) as policyriskcommencementdate,
policypaymentterm,policybenefitterm,
policycurrentstatus as status_as_of_sept2019,policycurrentstatussub as statussub_as_of_sept2019,
to_date(policycurrentstatusseffectdate) as policycurrentstatusseffectdate_sept2019 ,
premiumpaymentfrequency,
policyannualizedpremium,to_date(policyenddate) as policyenddate,
add_months(to_date(policyriskcommencementdate),12*cast(policypaymentterm as int)) as end_of_payterm_dt,
add_months(to_date(policyriskcommencementdate),12*cast(policybenefitterm as int)) as end_of_benefiterm_dt
from mis_data.policy where length(policyriskcommencementdate)>9 and 
to_date(proposalsubmissiondate) >= to_date('2001-05-01')   
and policytechnicalid is not null and policytechnicalid != '' and policytechnicalid != 'null'
and policytechnicalid not rlike '/\/\s+[A-Za-z]+/\/\s+' and to_date(policyriskcommencementdate)>=to_date('2013-03-01')
and to_date(policyriskcommencementdate)<to_date('2014-03-01');

drop table if exists aureus_temp.temp_stat0;

create table aureus_temp.temp_stat0 as
select policytechnicalid,o_edn,o_kdn,status_rev
from mis_data.all_status_change_combined where to_date(o_edn)< to_date('2018-04-01') and to_date(o_kdn)< to_date('2018-04-01')
and policytechnicalid in (select distinct policytechnicalid from aureus_temp.pol_dt1);

insert overwrite table aureus_temp.temp_stat0 select distinct * from aureus_temp.temp_stat0;

drop table if exists aureus_temp.temp_stat1;

create table aureus_temp.temp_stat1 as
select policytechnicalid as proposal_no,max(to_date(o_edn)) as o_edn
from aureus_temp.temp_stat0 group by policytechnicalid;

insert overwrite table aureus_temp.temp_stat1 select distinct * from aureus_temp.temp_stat1;

drop table if exists aureus_temp.temp_stat1_1;

create table aureus_temp.temp_stat1_1 as
select policytechnicalid as proposal_no,o_edn,max(to_date(o_kdn)) as o_kdn
from aureus_temp.temp_stat0 group by policytechnicalid,o_edn;

drop table if exists aureus_temp.temp_stat1_2;

create table aureus_temp.temp_stat1_2 as 
select proposal_no,o_edn,o_kdn from 
aureus_temp.temp_stat1_1 where 
concat(proposal_no,'|',o_edn) in (select concat(proposal_no,'|',o_edn) from aureus_temp.temp_stat1);

drop table if exists aureus_temp.temp_stat2;

create table aureus_temp.temp_stat2 as
select policytechnicalid as proposal_no,o_edn,o_kdn,status_rev 
from aureus_temp.temp_stat0 
where concat(policytechnicalid,'|',o_edn,'|',o_kdn) in (select concat(proposal_no,'|',o_edn,'|',o_kdn) from  aureus_temp.temp_stat1_2);

insert overwrite table aureus_temp.temp_stat2 select distinct * from aureus_temp.temp_stat2;

drop table if exists aureus_temp.temp_stat3;

create table aureus_temp.temp_stat3 as 
select * from aureus_temp.temp_stat2
where status_rev == 'Terminated or cannot be revived';

insert overwrite table aureus_temp.temp_stat3 select distinct * from aureus_temp.temp_stat3;

drop table if exists aureus_temp.temp_stat4;

create table aureus_temp.temp_stat4 as
select * from aureus_temp.temp_stat2 where
status_rev == 'Lapsed' and proposal_no not in (select distinct proposal_no from aureus_temp.temp_stat3);

insert overwrite table aureus_temp.temp_stat4 select distinct * from aureus_temp.temp_stat4;

drop table if exists aureus_temp.temp_stat5;

create table aureus_temp.temp_stat5 as
select * from aureus_temp.temp_stat2 where
status_rev == 'Tech Lapsed' and proposal_no not in (select distinct proposal_no from aureus_temp.temp_stat3 union select distinct proposal_no from  aureus_temp.temp_stat4);

insert overwrite table aureus_temp.temp_stat5 select distinct * from aureus_temp.temp_stat5;

drop table if exists aureus_temp.temp_stat6;

create table aureus_temp.temp_stat6 as
select * from aureus_temp.temp_stat2 where
status_rev == 'Inforce' and proposal_no not in (select distinct proposal_no from aureus_temp.temp_stat3 
                                                union select distinct proposal_no from  aureus_temp.temp_stat4
                                                union select distinct proposal_no from  aureus_temp.temp_stat5);

insert overwrite table aureus_temp.temp_stat6 select distinct * from aureus_temp.temp_stat6;

drop table if exists aureus_temp.eval_pol_tlapse;

create table aureus_temp.status_mar18 as
select proposal_no as pl_prop_num,status_rev as status_as_of_mar18,'2018-04-01' as evaluation_date from aureus_temp.temp_stat3
union
select proposal_no as pl_prop_num,status_rev as status_as_of_mar18,'2018-04-01' as evaluation_date from aureus_temp.temp_stat4
union
select proposal_no as pl_prop_num,status_rev as status_as_of_mar18,'2018-04-01' as evaluation_date from aureus_temp.temp_stat5
union
select proposal_no as pl_prop_num,status_rev as status_as_of_mar18,'2018-04-01' as evaluation_date from aureus_temp.temp_stat6;

drop table aureus_temp.temp_stat0;
drop table aureus_temp.temp_stat1;
drop table aureus_temp.temp_stat1_1;
drop table aureus_temp.temp_stat1_2;
drop table aureus_temp.temp_stat2;
drop table aureus_temp.temp_stat3;
drop table aureus_temp.temp_stat4;
drop table aureus_temp.temp_stat5;
drop table aureus_temp.temp_stat6;


drop table if exists aureus_temp.temp_stat0;

create table aureus_temp.temp_stat0 as
select policytechnicalid,o_edn,o_kdn,status_rev
from mis_data.all_status_change_combined where to_date(o_edn)< to_date('2018-05-01') and to_date(o_kdn)< to_date('2018-05-01')
and policytechnicalid in (select distinct policytechnicalid from aureus_temp.pol_dt1);

insert overwrite table aureus_temp.temp_stat0 select distinct * from aureus_temp.temp_stat0;

drop table if exists aureus_temp.temp_stat1;

create table aureus_temp.temp_stat1 as
select policytechnicalid as proposal_no,max(to_date(o_edn)) as o_edn
from aureus_temp.temp_stat0 group by policytechnicalid;

insert overwrite table aureus_temp.temp_stat1 select distinct * from aureus_temp.temp_stat1;

drop table if exists aureus_temp.temp_stat1_1;

create table aureus_temp.temp_stat1_1 as
select policytechnicalid as proposal_no,o_edn,max(to_date(o_kdn)) as o_kdn
from aureus_temp.temp_stat0 group by policytechnicalid,o_edn;

drop table if exists aureus_temp.temp_stat1_2;

create table aureus_temp.temp_stat1_2 as 
select proposal_no,o_edn,o_kdn from 
aureus_temp.temp_stat1_1 where 
concat(proposal_no,'|',o_edn) in (select concat(proposal_no,'|',o_edn) from aureus_temp.temp_stat1);

drop table if exists aureus_temp.temp_stat2;

create table aureus_temp.temp_stat2 as
select policytechnicalid as proposal_no,o_edn,o_kdn,status_rev 
from aureus_temp.temp_stat0 
where concat(policytechnicalid,'|',o_edn,'|',o_kdn) in (select concat(proposal_no,'|',o_edn,'|',o_kdn) from  aureus_temp.temp_stat1_2);

insert overwrite table aureus_temp.temp_stat2 select distinct * from aureus_temp.temp_stat2;

drop table if exists aureus_temp.temp_stat3;

create table aureus_temp.temp_stat3 as 
select * from aureus_temp.temp_stat2
where status_rev == 'Terminated or cannot be revived';

insert overwrite table aureus_temp.temp_stat3 select distinct * from aureus_temp.temp_stat3;

drop table if exists aureus_temp.temp_stat4;

create table aureus_temp.temp_stat4 as
select * from aureus_temp.temp_stat2 where
status_rev == 'Lapsed' and proposal_no not in (select distinct proposal_no from aureus_temp.temp_stat3);

insert overwrite table aureus_temp.temp_stat4 select distinct * from aureus_temp.temp_stat4;

drop table if exists aureus_temp.temp_stat5;

create table aureus_temp.temp_stat5 as
select * from aureus_temp.temp_stat2 where
status_rev == 'Tech Lapsed' and proposal_no not in (select distinct proposal_no from aureus_temp.temp_stat3 union select distinct proposal_no from  aureus_temp.temp_stat4);

insert overwrite table aureus_temp.temp_stat5 select distinct * from aureus_temp.temp_stat5;

drop table if exists aureus_temp.temp_stat6;

create table aureus_temp.temp_stat6 as
select * from aureus_temp.temp_stat2 where
status_rev == 'Inforce' and proposal_no not in (select distinct proposal_no from aureus_temp.temp_stat3 
                                                union select distinct proposal_no from  aureus_temp.temp_stat4
                                                union select distinct proposal_no from  aureus_temp.temp_stat5);

insert overwrite table aureus_temp.temp_stat6 select distinct * from aureus_temp.temp_stat6;

drop table if exists aureus_temp.eval_pol_tlapse;

create table aureus_temp.status_apr18 as
select proposal_no as pl_prop_num,status_rev as status_as_of_apr18,'2018-05-01' as evaluation_date from aureus_temp.temp_stat3
union
select proposal_no as pl_prop_num,status_rev as status_as_of_apr18,'2018-05-01' as evaluation_date from aureus_temp.temp_stat4
union
select proposal_no as pl_prop_num,status_rev as status_as_of_apr18,'2018-05-01' as evaluation_date from aureus_temp.temp_stat5
union
select proposal_no as pl_prop_num,status_rev as status_as_of_apr18,'2018-05-01' as evaluation_date from aureus_temp.temp_stat6;

drop table aureus_temp.temp_stat0;
drop table aureus_temp.temp_stat1;
drop table aureus_temp.temp_stat1_1;
drop table aureus_temp.temp_stat1_2;
drop table aureus_temp.temp_stat2;
drop table aureus_temp.temp_stat3;
drop table aureus_temp.temp_stat4;
drop table aureus_temp.temp_stat5;
drop table aureus_temp.temp_stat6;

drop table if exists aureus_temp.temp_stat0;

create table aureus_temp.temp_stat0 as
select policytechnicalid,o_edn,o_kdn,status_rev
from mis_data.all_status_change_combined where to_date(o_edn)< to_date('2018-06-01') and to_date(o_kdn)< to_date('2018-06-01')
and policytechnicalid in (select distinct policytechnicalid from aureus_temp.pol_dt1);

insert overwrite table aureus_temp.temp_stat0 select distinct * from aureus_temp.temp_stat0;

drop table if exists aureus_temp.temp_stat1;

create table aureus_temp.temp_stat1 as
select policytechnicalid as proposal_no,max(to_date(o_edn)) as o_edn
from aureus_temp.temp_stat0 group by policytechnicalid;

insert overwrite table aureus_temp.temp_stat1 select distinct * from aureus_temp.temp_stat1;

drop table if exists aureus_temp.temp_stat1_1;

create table aureus_temp.temp_stat1_1 as
select policytechnicalid as proposal_no,o_edn,max(to_date(o_kdn)) as o_kdn
from aureus_temp.temp_stat0 group by policytechnicalid,o_edn;

drop table if exists aureus_temp.temp_stat1_2;

create table aureus_temp.temp_stat1_2 as 
select proposal_no,o_edn,o_kdn from 
aureus_temp.temp_stat1_1 where 
concat(proposal_no,'|',o_edn) in (select concat(proposal_no,'|',o_edn) from aureus_temp.temp_stat1);

drop table if exists aureus_temp.temp_stat2;

create table aureus_temp.temp_stat2 as
select policytechnicalid as proposal_no,o_edn,o_kdn,status_rev 
from aureus_temp.temp_stat0 
where concat(policytechnicalid,'|',o_edn,'|',o_kdn) in (select concat(proposal_no,'|',o_edn,'|',o_kdn) from  aureus_temp.temp_stat1_2);

insert overwrite table aureus_temp.temp_stat2 select distinct * from aureus_temp.temp_stat2;

drop table if exists aureus_temp.temp_stat3;

create table aureus_temp.temp_stat3 as 
select * from aureus_temp.temp_stat2
where status_rev == 'Terminated or cannot be revived';

insert overwrite table aureus_temp.temp_stat3 select distinct * from aureus_temp.temp_stat3;

drop table if exists aureus_temp.temp_stat4;

create table aureus_temp.temp_stat4 as
select * from aureus_temp.temp_stat2 where
status_rev == 'Lapsed' and proposal_no not in (select distinct proposal_no from aureus_temp.temp_stat3);

insert overwrite table aureus_temp.temp_stat4 select distinct * from aureus_temp.temp_stat4;

drop table if exists aureus_temp.temp_stat5;

create table aureus_temp.temp_stat5 as
select * from aureus_temp.temp_stat2 where
status_rev == 'Tech Lapsed' and proposal_no not in (select distinct proposal_no from aureus_temp.temp_stat3 union select distinct proposal_no from  aureus_temp.temp_stat4);

insert overwrite table aureus_temp.temp_stat5 select distinct * from aureus_temp.temp_stat5;

drop table if exists aureus_temp.temp_stat6;

create table aureus_temp.temp_stat6 as
select * from aureus_temp.temp_stat2 where
status_rev == 'Inforce' and proposal_no not in (select distinct proposal_no from aureus_temp.temp_stat3 
                                                union select distinct proposal_no from  aureus_temp.temp_stat4
                                                union select distinct proposal_no from  aureus_temp.temp_stat5);

insert overwrite table aureus_temp.temp_stat6 select distinct * from aureus_temp.temp_stat6;

drop table if exists aureus_temp.eval_pol_tlapse;

create table aureus_temp.status_may18 as
select proposal_no as pl_prop_num,status_rev as status_as_of_may18,'2018-06-01' as evaluation_date from aureus_temp.temp_stat3
union
select proposal_no as pl_prop_num,status_rev as status_as_of_may18,'2018-06-01' as evaluation_date from aureus_temp.temp_stat4
union
select proposal_no as pl_prop_num,status_rev as status_as_of_may18,'2018-06-01' as evaluation_date from aureus_temp.temp_stat5
union
select proposal_no as pl_prop_num,status_rev as status_as_of_may18,'2018-06-01' as evaluation_date from aureus_temp.temp_stat6;

drop table aureus_temp.temp_stat0;
drop table aureus_temp.temp_stat1;
drop table aureus_temp.temp_stat1_1;
drop table aureus_temp.temp_stat1_2;
drop table aureus_temp.temp_stat2;
drop table aureus_temp.temp_stat3;
drop table aureus_temp.temp_stat4;
drop table aureus_temp.temp_stat5;
drop table aureus_temp.temp_stat6;

drop table if exists aureus_temp.temp_stat0;

create table aureus_temp.temp_stat0 as
select policytechnicalid,o_edn,o_kdn,status_rev
from mis_data.all_status_change_combined where to_date(o_edn)< to_date('2018-07-01') and to_date(o_kdn)< to_date('2018-07-01')
and policytechnicalid in (select distinct policytechnicalid from aureus_temp.pol_dt1);

insert overwrite table aureus_temp.temp_stat0 select distinct * from aureus_temp.temp_stat0;

drop table if exists aureus_temp.temp_stat1;

create table aureus_temp.temp_stat1 as
select policytechnicalid as proposal_no,max(to_date(o_edn)) as o_edn
from aureus_temp.temp_stat0 group by policytechnicalid;

insert overwrite table aureus_temp.temp_stat1 select distinct * from aureus_temp.temp_stat1;

drop table if exists aureus_temp.temp_stat1_1;

create table aureus_temp.temp_stat1_1 as
select policytechnicalid as proposal_no,o_edn,max(to_date(o_kdn)) as o_kdn
from aureus_temp.temp_stat0 group by policytechnicalid,o_edn;

drop table if exists aureus_temp.temp_stat1_2;

create table aureus_temp.temp_stat1_2 as 
select proposal_no,o_edn,o_kdn from 
aureus_temp.temp_stat1_1 where 
concat(proposal_no,'|',o_edn) in (select concat(proposal_no,'|',o_edn) from aureus_temp.temp_stat1);

drop table if exists aureus_temp.temp_stat2;

create table aureus_temp.temp_stat2 as
select policytechnicalid as proposal_no,o_edn,o_kdn,status_rev 
from aureus_temp.temp_stat0 
where concat(policytechnicalid,'|',o_edn,'|',o_kdn) in (select concat(proposal_no,'|',o_edn,'|',o_kdn) from  aureus_temp.temp_stat1_2);

insert overwrite table aureus_temp.temp_stat2 select distinct * from aureus_temp.temp_stat2;

drop table if exists aureus_temp.temp_stat3;

create table aureus_temp.temp_stat3 as 
select * from aureus_temp.temp_stat2
where status_rev == 'Terminated or cannot be revived';

insert overwrite table aureus_temp.temp_stat3 select distinct * from aureus_temp.temp_stat3;

drop table if exists aureus_temp.temp_stat4;

create table aureus_temp.temp_stat4 as
select * from aureus_temp.temp_stat2 where
status_rev == 'Lapsed' and proposal_no not in (select distinct proposal_no from aureus_temp.temp_stat3);

insert overwrite table aureus_temp.temp_stat4 select distinct * from aureus_temp.temp_stat4;

drop table if exists aureus_temp.temp_stat5;

create table aureus_temp.temp_stat5 as
select * from aureus_temp.temp_stat2 where
status_rev == 'Tech Lapsed' and proposal_no not in (select distinct proposal_no from aureus_temp.temp_stat3 union select distinct proposal_no from  aureus_temp.temp_stat4);

insert overwrite table aureus_temp.temp_stat5 select distinct * from aureus_temp.temp_stat5;

drop table if exists aureus_temp.temp_stat6;

create table aureus_temp.temp_stat6 as
select * from aureus_temp.temp_stat2 where
status_rev == 'Inforce' and proposal_no not in (select distinct proposal_no from aureus_temp.temp_stat3 
                                                union select distinct proposal_no from  aureus_temp.temp_stat4
                                                union select distinct proposal_no from  aureus_temp.temp_stat5);

insert overwrite table aureus_temp.temp_stat6 select distinct * from aureus_temp.temp_stat6;

drop table if exists aureus_temp.eval_pol_tlapse;

create table aureus_temp.status_june18 as
select proposal_no as pl_prop_num,status_rev as status_as_of_june18,'2018-07-01' as evaluation_date from aureus_temp.temp_stat3
union
select proposal_no as pl_prop_num,status_rev as status_as_of_june18,'2018-07-01' as evaluation_date from aureus_temp.temp_stat4
union
select proposal_no as pl_prop_num,status_rev as status_as_of_june18,'2018-07-01' as evaluation_date from aureus_temp.temp_stat5
union
select proposal_no as pl_prop_num,status_rev as status_as_of_june18,'2018-07-01' as evaluation_date from aureus_temp.temp_stat6;

drop table aureus_temp.temp_stat0;
drop table aureus_temp.temp_stat1;
drop table aureus_temp.temp_stat1_1;
drop table aureus_temp.temp_stat1_2;
drop table aureus_temp.temp_stat2;
drop table aureus_temp.temp_stat3;
drop table aureus_temp.temp_stat4;
drop table aureus_temp.temp_stat5;
drop table aureus_temp.temp_stat6;

drop table if exists aureus_temp.temp_stat0;

create table aureus_temp.temp_stat0 as
select policytechnicalid,o_edn,o_kdn,status_rev
from mis_data.all_status_change_combined where to_date(o_edn)< to_date('2018-08-01') and to_date(o_kdn)< to_date('2018-08-01')
and policytechnicalid in (select distinct policytechnicalid from aureus_temp.pol_dt1);

insert overwrite table aureus_temp.temp_stat0 select distinct * from aureus_temp.temp_stat0;

drop table if exists aureus_temp.temp_stat1;

create table aureus_temp.temp_stat1 as
select policytechnicalid as proposal_no,max(to_date(o_edn)) as o_edn
from aureus_temp.temp_stat0 group by policytechnicalid;

insert overwrite table aureus_temp.temp_stat1 select distinct * from aureus_temp.temp_stat1;

drop table if exists aureus_temp.temp_stat1_1;

create table aureus_temp.temp_stat1_1 as
select policytechnicalid as proposal_no,o_edn,max(to_date(o_kdn)) as o_kdn
from aureus_temp.temp_stat0 group by policytechnicalid,o_edn;

drop table if exists aureus_temp.temp_stat1_2;

create table aureus_temp.temp_stat1_2 as 
select proposal_no,o_edn,o_kdn from 
aureus_temp.temp_stat1_1 where 
concat(proposal_no,'|',o_edn) in (select concat(proposal_no,'|',o_edn) from aureus_temp.temp_stat1);

drop table if exists aureus_temp.temp_stat2;

create table aureus_temp.temp_stat2 as
select policytechnicalid as proposal_no,o_edn,o_kdn,status_rev 
from aureus_temp.temp_stat0 
where concat(policytechnicalid,'|',o_edn,'|',o_kdn) in (select concat(proposal_no,'|',o_edn,'|',o_kdn) from  aureus_temp.temp_stat1_2);

insert overwrite table aureus_temp.temp_stat2 select distinct * from aureus_temp.temp_stat2;

drop table if exists aureus_temp.temp_stat3;

create table aureus_temp.temp_stat3 as 
select * from aureus_temp.temp_stat2
where status_rev == 'Terminated or cannot be revived';

insert overwrite table aureus_temp.temp_stat3 select distinct * from aureus_temp.temp_stat3;

drop table if exists aureus_temp.temp_stat4;

create table aureus_temp.temp_stat4 as
select * from aureus_temp.temp_stat2 where
status_rev == 'Lapsed' and proposal_no not in (select distinct proposal_no from aureus_temp.temp_stat3);

insert overwrite table aureus_temp.temp_stat4 select distinct * from aureus_temp.temp_stat4;

drop table if exists aureus_temp.temp_stat5;

create table aureus_temp.temp_stat5 as
select * from aureus_temp.temp_stat2 where
status_rev == 'Tech Lapsed' and proposal_no not in (select distinct proposal_no from aureus_temp.temp_stat3 union select distinct proposal_no from  aureus_temp.temp_stat4);

insert overwrite table aureus_temp.temp_stat5 select distinct * from aureus_temp.temp_stat5;

drop table if exists aureus_temp.temp_stat6;

create table aureus_temp.temp_stat6 as
select * from aureus_temp.temp_stat2 where
status_rev == 'Inforce' and proposal_no not in (select distinct proposal_no from aureus_temp.temp_stat3 
                                                union select distinct proposal_no from  aureus_temp.temp_stat4
                                                union select distinct proposal_no from  aureus_temp.temp_stat5);

insert overwrite table aureus_temp.temp_stat6 select distinct * from aureus_temp.temp_stat6;

drop table if exists aureus_temp.eval_pol_tlapse;

create table aureus_temp.status_july18 as
select proposal_no as pl_prop_num,status_rev as status_as_of_july18,'2018-08-01' as evaluation_date from aureus_temp.temp_stat3
union
select proposal_no as pl_prop_num,status_rev as status_as_of_july18,'2018-08-01' as evaluation_date from aureus_temp.temp_stat4
union
select proposal_no as pl_prop_num,status_rev as status_as_of_july18,'2018-08-01' as evaluation_date from aureus_temp.temp_stat5
union
select proposal_no as pl_prop_num,status_rev as status_as_of_july18,'2018-08-01' as evaluation_date from aureus_temp.temp_stat6;

drop table aureus_temp.temp_stat0;
drop table aureus_temp.temp_stat1;
drop table aureus_temp.temp_stat1_1;
drop table aureus_temp.temp_stat1_2;
drop table aureus_temp.temp_stat2;
drop table aureus_temp.temp_stat3;
drop table aureus_temp.temp_stat4;
drop table aureus_temp.temp_stat5;
drop table aureus_temp.temp_stat6;

drop table if exists aureus_temp.temp_stat0;

create table aureus_temp.temp_stat0 as
select policytechnicalid,o_edn,o_kdn,status_rev
from mis_data.all_status_change_combined where to_date(o_edn)< to_date('2018-09-01') and to_date(o_kdn)< to_date('2018-09-01')
and policytechnicalid in (select distinct policytechnicalid from aureus_temp.pol_dt1);

insert overwrite table aureus_temp.temp_stat0 select distinct * from aureus_temp.temp_stat0;

drop table if exists aureus_temp.temp_stat1;

create table aureus_temp.temp_stat1 as
select policytechnicalid as proposal_no,max(to_date(o_edn)) as o_edn
from aureus_temp.temp_stat0 group by policytechnicalid;

insert overwrite table aureus_temp.temp_stat1 select distinct * from aureus_temp.temp_stat1;

drop table if exists aureus_temp.temp_stat1_1;

create table aureus_temp.temp_stat1_1 as
select policytechnicalid as proposal_no,o_edn,max(to_date(o_kdn)) as o_kdn
from aureus_temp.temp_stat0 group by policytechnicalid,o_edn;

drop table if exists aureus_temp.temp_stat1_2;

create table aureus_temp.temp_stat1_2 as 
select proposal_no,o_edn,o_kdn from 
aureus_temp.temp_stat1_1 where 
concat(proposal_no,'|',o_edn) in (select concat(proposal_no,'|',o_edn) from aureus_temp.temp_stat1);

drop table if exists aureus_temp.temp_stat2;

create table aureus_temp.temp_stat2 as
select policytechnicalid as proposal_no,o_edn,o_kdn,status_rev 
from aureus_temp.temp_stat0 
where concat(policytechnicalid,'|',o_edn,'|',o_kdn) in (select concat(proposal_no,'|',o_edn,'|',o_kdn) from  aureus_temp.temp_stat1_2);

insert overwrite table aureus_temp.temp_stat2 select distinct * from aureus_temp.temp_stat2;

drop table if exists aureus_temp.temp_stat3;

create table aureus_temp.temp_stat3 as 
select * from aureus_temp.temp_stat2
where status_rev == 'Terminated or cannot be revived';

insert overwrite table aureus_temp.temp_stat3 select distinct * from aureus_temp.temp_stat3;

drop table if exists aureus_temp.temp_stat4;

create table aureus_temp.temp_stat4 as
select * from aureus_temp.temp_stat2 where
status_rev == 'Lapsed' and proposal_no not in (select distinct proposal_no from aureus_temp.temp_stat3);

insert overwrite table aureus_temp.temp_stat4 select distinct * from aureus_temp.temp_stat4;

drop table if exists aureus_temp.temp_stat5;

create table aureus_temp.temp_stat5 as
select * from aureus_temp.temp_stat2 where
status_rev == 'Tech Lapsed' and proposal_no not in (select distinct proposal_no from aureus_temp.temp_stat3 union select distinct proposal_no from  aureus_temp.temp_stat4);

insert overwrite table aureus_temp.temp_stat5 select distinct * from aureus_temp.temp_stat5;

drop table if exists aureus_temp.temp_stat6;

create table aureus_temp.temp_stat6 as
select * from aureus_temp.temp_stat2 where
status_rev == 'Inforce' and proposal_no not in (select distinct proposal_no from aureus_temp.temp_stat3 
                                                union select distinct proposal_no from  aureus_temp.temp_stat4
                                                union select distinct proposal_no from  aureus_temp.temp_stat5);

insert overwrite table aureus_temp.temp_stat6 select distinct * from aureus_temp.temp_stat6;

drop table if exists aureus_temp.eval_pol_tlapse;

create table aureus_temp.status_aug18 as
select proposal_no as pl_prop_num,status_rev as status_as_of_aug18,'2018-09-01' as evaluation_date from aureus_temp.temp_stat3
union
select proposal_no as pl_prop_num,status_rev as status_as_of_aug18,'2018-09-01' as evaluation_date from aureus_temp.temp_stat4
union
select proposal_no as pl_prop_num,status_rev as status_as_of_aug18,'2018-09-01' as evaluation_date from aureus_temp.temp_stat5
union
select proposal_no as pl_prop_num,status_rev as status_as_of_aug18,'2018-09-01' as evaluation_date from aureus_temp.temp_stat6;

drop table aureus_temp.temp_stat0;
drop table aureus_temp.temp_stat1;
drop table aureus_temp.temp_stat1_1;
drop table aureus_temp.temp_stat1_2;
drop table aureus_temp.temp_stat2;
drop table aureus_temp.temp_stat3;
drop table aureus_temp.temp_stat4;
drop table aureus_temp.temp_stat5;
drop table aureus_temp.temp_stat6;

drop table if exists aureus_temp.temp_stat0;

create table aureus_temp.temp_stat0 as
select policytechnicalid,o_edn,o_kdn,status_rev
from mis_data.all_status_change_combined where to_date(o_edn)< to_date('2018-10-01') and to_date(o_kdn)< to_date('2018-10-01')
and policytechnicalid in (select distinct policytechnicalid from aureus_temp.pol_dt1);

insert overwrite table aureus_temp.temp_stat0 select distinct * from aureus_temp.temp_stat0;

drop table if exists aureus_temp.temp_stat1;

create table aureus_temp.temp_stat1 as
select policytechnicalid as proposal_no,max(to_date(o_edn)) as o_edn
from aureus_temp.temp_stat0 group by policytechnicalid;

insert overwrite table aureus_temp.temp_stat1 select distinct * from aureus_temp.temp_stat1;

drop table if exists aureus_temp.temp_stat1_1;

create table aureus_temp.temp_stat1_1 as
select policytechnicalid as proposal_no,o_edn,max(to_date(o_kdn)) as o_kdn
from aureus_temp.temp_stat0 group by policytechnicalid,o_edn;

drop table if exists aureus_temp.temp_stat1_2;

create table aureus_temp.temp_stat1_2 as 
select proposal_no,o_edn,o_kdn from 
aureus_temp.temp_stat1_1 where 
concat(proposal_no,'|',o_edn) in (select concat(proposal_no,'|',o_edn) from aureus_temp.temp_stat1);

drop table if exists aureus_temp.temp_stat2;

create table aureus_temp.temp_stat2 as
select policytechnicalid as proposal_no,o_edn,o_kdn,status_rev 
from aureus_temp.temp_stat0 
where concat(policytechnicalid,'|',o_edn,'|',o_kdn) in (select concat(proposal_no,'|',o_edn,'|',o_kdn) from  aureus_temp.temp_stat1_2);

insert overwrite table aureus_temp.temp_stat2 select distinct * from aureus_temp.temp_stat2;

drop table if exists aureus_temp.temp_stat3;

create table aureus_temp.temp_stat3 as 
select * from aureus_temp.temp_stat2
where status_rev == 'Terminated or cannot be revived';

insert overwrite table aureus_temp.temp_stat3 select distinct * from aureus_temp.temp_stat3;

drop table if exists aureus_temp.temp_stat4;

create table aureus_temp.temp_stat4 as
select * from aureus_temp.temp_stat2 where
status_rev == 'Lapsed' and proposal_no not in (select distinct proposal_no from aureus_temp.temp_stat3);

insert overwrite table aureus_temp.temp_stat4 select distinct * from aureus_temp.temp_stat4;

drop table if exists aureus_temp.temp_stat5;

create table aureus_temp.temp_stat5 as
select * from aureus_temp.temp_stat2 where
status_rev == 'Tech Lapsed' and proposal_no not in (select distinct proposal_no from aureus_temp.temp_stat3 union select distinct proposal_no from  aureus_temp.temp_stat4);

insert overwrite table aureus_temp.temp_stat5 select distinct * from aureus_temp.temp_stat5;

drop table if exists aureus_temp.temp_stat6;

create table aureus_temp.temp_stat6 as
select * from aureus_temp.temp_stat2 where
status_rev == 'Inforce' and proposal_no not in (select distinct proposal_no from aureus_temp.temp_stat3 
                                                union select distinct proposal_no from  aureus_temp.temp_stat4
                                                union select distinct proposal_no from  aureus_temp.temp_stat5);

insert overwrite table aureus_temp.temp_stat6 select distinct * from aureus_temp.temp_stat6;

drop table if exists aureus_temp.eval_pol_tlapse;

create table aureus_temp.status_sept18 as
select proposal_no as pl_prop_num,status_rev as status_as_of_sept18,'2018-10-01' as evaluation_date from aureus_temp.temp_stat3
union
select proposal_no as pl_prop_num,status_rev as status_as_of_sept18,'2018-10-01' as evaluation_date from aureus_temp.temp_stat4
union
select proposal_no as pl_prop_num,status_rev as status_as_of_sept18,'2018-10-01' as evaluation_date from aureus_temp.temp_stat5
union
select proposal_no as pl_prop_num,status_rev as status_as_of_sept18,'2018-10-01' as evaluation_date from aureus_temp.temp_stat6;

drop table aureus_temp.temp_stat0;
drop table aureus_temp.temp_stat1;
drop table aureus_temp.temp_stat1_1;
drop table aureus_temp.temp_stat1_2;
drop table aureus_temp.temp_stat2;
drop table aureus_temp.temp_stat3;
drop table aureus_temp.temp_stat4;
drop table aureus_temp.temp_stat5;
drop table aureus_temp.temp_stat6;

drop table if exists aureus_temp.temp_stat0;

create table aureus_temp.temp_stat0 as
select policytechnicalid,o_edn,o_kdn,status_rev
from mis_data.all_status_change_combined where to_date(o_edn)< to_date('2018-11-01') and to_date(o_kdn)< to_date('2018-11-01')
and policytechnicalid in (select distinct policytechnicalid from aureus_temp.pol_dt1);

insert overwrite table aureus_temp.temp_stat0 select distinct * from aureus_temp.temp_stat0;

drop table if exists aureus_temp.temp_stat1;

create table aureus_temp.temp_stat1 as
select policytechnicalid as proposal_no,max(to_date(o_edn)) as o_edn
from aureus_temp.temp_stat0 group by policytechnicalid;

insert overwrite table aureus_temp.temp_stat1 select distinct * from aureus_temp.temp_stat1;

drop table if exists aureus_temp.temp_stat1_1;

create table aureus_temp.temp_stat1_1 as
select policytechnicalid as proposal_no,o_edn,max(to_date(o_kdn)) as o_kdn
from aureus_temp.temp_stat0 group by policytechnicalid,o_edn;

drop table if exists aureus_temp.temp_stat1_2;

create table aureus_temp.temp_stat1_2 as 
select proposal_no,o_edn,o_kdn from 
aureus_temp.temp_stat1_1 where 
concat(proposal_no,'|',o_edn) in (select concat(proposal_no,'|',o_edn) from aureus_temp.temp_stat1);

drop table if exists aureus_temp.temp_stat2;

create table aureus_temp.temp_stat2 as
select policytechnicalid as proposal_no,o_edn,o_kdn,status_rev 
from aureus_temp.temp_stat0 
where concat(policytechnicalid,'|',o_edn,'|',o_kdn) in (select concat(proposal_no,'|',o_edn,'|',o_kdn) from  aureus_temp.temp_stat1_2);

insert overwrite table aureus_temp.temp_stat2 select distinct * from aureus_temp.temp_stat2;

drop table if exists aureus_temp.temp_stat3;

create table aureus_temp.temp_stat3 as 
select * from aureus_temp.temp_stat2
where status_rev == 'Terminated or cannot be revived';

insert overwrite table aureus_temp.temp_stat3 select distinct * from aureus_temp.temp_stat3;

drop table if exists aureus_temp.temp_stat4;

create table aureus_temp.temp_stat4 as
select * from aureus_temp.temp_stat2 where
status_rev == 'Lapsed' and proposal_no not in (select distinct proposal_no from aureus_temp.temp_stat3);

insert overwrite table aureus_temp.temp_stat4 select distinct * from aureus_temp.temp_stat4;

drop table if exists aureus_temp.temp_stat5;

create table aureus_temp.temp_stat5 as
select * from aureus_temp.temp_stat2 where
status_rev == 'Tech Lapsed' and proposal_no not in (select distinct proposal_no from aureus_temp.temp_stat3 union select distinct proposal_no from  aureus_temp.temp_stat4);

insert overwrite table aureus_temp.temp_stat5 select distinct * from aureus_temp.temp_stat5;

drop table if exists aureus_temp.temp_stat6;

create table aureus_temp.temp_stat6 as
select * from aureus_temp.temp_stat2 where
status_rev == 'Inforce' and proposal_no not in (select distinct proposal_no from aureus_temp.temp_stat3 
                                                union select distinct proposal_no from  aureus_temp.temp_stat4
                                                union select distinct proposal_no from  aureus_temp.temp_stat5);

insert overwrite table aureus_temp.temp_stat6 select distinct * from aureus_temp.temp_stat6;

drop table if exists aureus_temp.eval_pol_tlapse;

create table aureus_temp.status_oct18 as
select proposal_no as pl_prop_num,status_rev as status_as_of_oct18,'2018-11-01' as evaluation_date from aureus_temp.temp_stat3
union
select proposal_no as pl_prop_num,status_rev as status_as_of_oct18,'2018-11-01' as evaluation_date from aureus_temp.temp_stat4
union
select proposal_no as pl_prop_num,status_rev as status_as_of_oct18,'2018-11-01' as evaluation_date from aureus_temp.temp_stat5
union
select proposal_no as pl_prop_num,status_rev as status_as_of_oct18,'2018-11-01' as evaluation_date from aureus_temp.temp_stat6;

drop table aureus_temp.temp_stat0;
drop table aureus_temp.temp_stat1;
drop table aureus_temp.temp_stat1_1;
drop table aureus_temp.temp_stat1_2;
drop table aureus_temp.temp_stat2;
drop table aureus_temp.temp_stat3;
drop table aureus_temp.temp_stat4;
drop table aureus_temp.temp_stat5;
drop table aureus_temp.temp_stat6;

drop table if exists aureus_temp.temp_stat0;

create table aureus_temp.temp_stat0 as
select policytechnicalid,o_edn,o_kdn,status_rev
from mis_data.all_status_change_combined where to_date(o_edn)< to_date('2018-12-01') and to_date(o_kdn)< to_date('2018-12-01')
and policytechnicalid in (select distinct policytechnicalid from aureus_temp.pol_dt1);

insert overwrite table aureus_temp.temp_stat0 select distinct * from aureus_temp.temp_stat0;

drop table if exists aureus_temp.temp_stat1;

create table aureus_temp.temp_stat1 as
select policytechnicalid as proposal_no,max(to_date(o_edn)) as o_edn
from aureus_temp.temp_stat0 group by policytechnicalid;

insert overwrite table aureus_temp.temp_stat1 select distinct * from aureus_temp.temp_stat1;

drop table if exists aureus_temp.temp_stat1_1;

create table aureus_temp.temp_stat1_1 as
select policytechnicalid as proposal_no,o_edn,max(to_date(o_kdn)) as o_kdn
from aureus_temp.temp_stat0 group by policytechnicalid,o_edn;

drop table if exists aureus_temp.temp_stat1_2;

create table aureus_temp.temp_stat1_2 as 
select proposal_no,o_edn,o_kdn from 
aureus_temp.temp_stat1_1 where 
concat(proposal_no,'|',o_edn) in (select concat(proposal_no,'|',o_edn) from aureus_temp.temp_stat1);

drop table if exists aureus_temp.temp_stat2;

create table aureus_temp.temp_stat2 as
select policytechnicalid as proposal_no,o_edn,o_kdn,status_rev 
from aureus_temp.temp_stat0 
where concat(policytechnicalid,'|',o_edn,'|',o_kdn) in (select concat(proposal_no,'|',o_edn,'|',o_kdn) from  aureus_temp.temp_stat1_2);

insert overwrite table aureus_temp.temp_stat2 select distinct * from aureus_temp.temp_stat2;

drop table if exists aureus_temp.temp_stat3;

create table aureus_temp.temp_stat3 as 
select * from aureus_temp.temp_stat2
where status_rev == 'Terminated or cannot be revived';

insert overwrite table aureus_temp.temp_stat3 select distinct * from aureus_temp.temp_stat3;

drop table if exists aureus_temp.temp_stat4;

create table aureus_temp.temp_stat4 as
select * from aureus_temp.temp_stat2 where
status_rev == 'Lapsed' and proposal_no not in (select distinct proposal_no from aureus_temp.temp_stat3);

insert overwrite table aureus_temp.temp_stat4 select distinct * from aureus_temp.temp_stat4;

drop table if exists aureus_temp.temp_stat5;

create table aureus_temp.temp_stat5 as
select * from aureus_temp.temp_stat2 where
status_rev == 'Tech Lapsed' and proposal_no not in (select distinct proposal_no from aureus_temp.temp_stat3 union select distinct proposal_no from  aureus_temp.temp_stat4);

insert overwrite table aureus_temp.temp_stat5 select distinct * from aureus_temp.temp_stat5;

drop table if exists aureus_temp.temp_stat6;

create table aureus_temp.temp_stat6 as
select * from aureus_temp.temp_stat2 where
status_rev == 'Inforce' and proposal_no not in (select distinct proposal_no from aureus_temp.temp_stat3 
                                                union select distinct proposal_no from  aureus_temp.temp_stat4
                                                union select distinct proposal_no from  aureus_temp.temp_stat5);

insert overwrite table aureus_temp.temp_stat6 select distinct * from aureus_temp.temp_stat6;

drop table if exists aureus_temp.eval_pol_tlapse;

create table aureus_temp.status_nov18 as
select proposal_no as pl_prop_num,status_rev as status_as_of_nov18,'2018-12-01' as evaluation_date from aureus_temp.temp_stat3
union
select proposal_no as pl_prop_num,status_rev as status_as_of_nov18,'2018-12-01' as evaluation_date from aureus_temp.temp_stat4
union
select proposal_no as pl_prop_num,status_rev as status_as_of_nov18,'2018-12-01' as evaluation_date from aureus_temp.temp_stat5
union
select proposal_no as pl_prop_num,status_rev as status_as_of_nov18,'2018-12-01' as evaluation_date from aureus_temp.temp_stat6;

drop table aureus_temp.temp_stat0;
drop table aureus_temp.temp_stat1;
drop table aureus_temp.temp_stat1_1;
drop table aureus_temp.temp_stat1_2;
drop table aureus_temp.temp_stat2;
drop table aureus_temp.temp_stat3;
drop table aureus_temp.temp_stat4;
drop table aureus_temp.temp_stat5;
drop table aureus_temp.temp_stat6;

drop table if exists aureus_temp.temp_stat0;

create table aureus_temp.temp_stat0 as
select policytechnicalid,o_edn,o_kdn,status_rev
from mis_data.all_status_change_combined where to_date(o_edn)< to_date('2019-01-01') and to_date(o_kdn)< to_date('2019-01-01')
and policytechnicalid in (select distinct policytechnicalid from aureus_temp.pol_dt1);

insert overwrite table aureus_temp.temp_stat0 select distinct * from aureus_temp.temp_stat0;

drop table if exists aureus_temp.temp_stat1;

create table aureus_temp.temp_stat1 as
select policytechnicalid as proposal_no,max(to_date(o_edn)) as o_edn
from aureus_temp.temp_stat0 group by policytechnicalid;

insert overwrite table aureus_temp.temp_stat1 select distinct * from aureus_temp.temp_stat1;

drop table if exists aureus_temp.temp_stat1_1;

create table aureus_temp.temp_stat1_1 as
select policytechnicalid as proposal_no,o_edn,max(to_date(o_kdn)) as o_kdn
from aureus_temp.temp_stat0 group by policytechnicalid,o_edn;

drop table if exists aureus_temp.temp_stat1_2;

create table aureus_temp.temp_stat1_2 as 
select proposal_no,o_edn,o_kdn from 
aureus_temp.temp_stat1_1 where 
concat(proposal_no,'|',o_edn) in (select concat(proposal_no,'|',o_edn) from aureus_temp.temp_stat1);

drop table if exists aureus_temp.temp_stat2;

create table aureus_temp.temp_stat2 as
select policytechnicalid as proposal_no,o_edn,o_kdn,status_rev 
from aureus_temp.temp_stat0 
where concat(policytechnicalid,'|',o_edn,'|',o_kdn) in (select concat(proposal_no,'|',o_edn,'|',o_kdn) from  aureus_temp.temp_stat1_2);

insert overwrite table aureus_temp.temp_stat2 select distinct * from aureus_temp.temp_stat2;

drop table if exists aureus_temp.temp_stat3;

create table aureus_temp.temp_stat3 as 
select * from aureus_temp.temp_stat2
where status_rev == 'Terminated or cannot be revived';

insert overwrite table aureus_temp.temp_stat3 select distinct * from aureus_temp.temp_stat3;

drop table if exists aureus_temp.temp_stat4;

create table aureus_temp.temp_stat4 as
select * from aureus_temp.temp_stat2 where
status_rev == 'Lapsed' and proposal_no not in (select distinct proposal_no from aureus_temp.temp_stat3);

insert overwrite table aureus_temp.temp_stat4 select distinct * from aureus_temp.temp_stat4;

drop table if exists aureus_temp.temp_stat5;

create table aureus_temp.temp_stat5 as
select * from aureus_temp.temp_stat2 where
status_rev == 'Tech Lapsed' and proposal_no not in (select distinct proposal_no from aureus_temp.temp_stat3 union select distinct proposal_no from  aureus_temp.temp_stat4);

insert overwrite table aureus_temp.temp_stat5 select distinct * from aureus_temp.temp_stat5;

drop table if exists aureus_temp.temp_stat6;

create table aureus_temp.temp_stat6 as
select * from aureus_temp.temp_stat2 where
status_rev == 'Inforce' and proposal_no not in (select distinct proposal_no from aureus_temp.temp_stat3 
                                                union select distinct proposal_no from  aureus_temp.temp_stat4
                                                union select distinct proposal_no from  aureus_temp.temp_stat5);

insert overwrite table aureus_temp.temp_stat6 select distinct * from aureus_temp.temp_stat6;

drop table if exists aureus_temp.eval_pol_tlapse;

create table aureus_temp.status_dec18 as
select proposal_no as pl_prop_num,status_rev as status_as_of_dec18,'2019-01-01' as evaluation_date from aureus_temp.temp_stat3
union
select proposal_no as pl_prop_num,status_rev as status_as_of_dec18,'2019-01-01' as evaluation_date from aureus_temp.temp_stat4
union
select proposal_no as pl_prop_num,status_rev as status_as_of_dec18,'2019-01-01' as evaluation_date from aureus_temp.temp_stat5
union
select proposal_no as pl_prop_num,status_rev as status_as_of_dec18,'2019-01-01' as evaluation_date from aureus_temp.temp_stat6;

drop table aureus_temp.temp_stat0;
drop table aureus_temp.temp_stat1;
drop table aureus_temp.temp_stat1_1;
drop table aureus_temp.temp_stat1_2;
drop table aureus_temp.temp_stat2;
drop table aureus_temp.temp_stat3;
drop table aureus_temp.temp_stat4;
drop table aureus_temp.temp_stat5;
drop table aureus_temp.temp_stat6;


drop table if exists aureus_temp.temp_stat0;

create table aureus_temp.temp_stat0 as
select policytechnicalid,o_edn,o_kdn,status_rev
from mis_data.all_status_change_combined where to_date(o_edn)< to_date('2019-02-01') and to_date(o_kdn)< to_date('2019-02-01')
and policytechnicalid in (select distinct policytechnicalid from aureus_temp.pol_dt1);

insert overwrite table aureus_temp.temp_stat0 select distinct * from aureus_temp.temp_stat0;

drop table if exists aureus_temp.temp_stat1;

create table aureus_temp.temp_stat1 as
select policytechnicalid as proposal_no,max(to_date(o_edn)) as o_edn
from aureus_temp.temp_stat0 group by policytechnicalid;

insert overwrite table aureus_temp.temp_stat1 select distinct * from aureus_temp.temp_stat1;

drop table if exists aureus_temp.temp_stat1_1;

create table aureus_temp.temp_stat1_1 as
select policytechnicalid as proposal_no,o_edn,max(to_date(o_kdn)) as o_kdn
from aureus_temp.temp_stat0 group by policytechnicalid,o_edn;

drop table if exists aureus_temp.temp_stat1_2;

create table aureus_temp.temp_stat1_2 as 
select proposal_no,o_edn,o_kdn from 
aureus_temp.temp_stat1_1 where 
concat(proposal_no,'|',o_edn) in (select concat(proposal_no,'|',o_edn) from aureus_temp.temp_stat1);

drop table if exists aureus_temp.temp_stat2;

create table aureus_temp.temp_stat2 as
select policytechnicalid as proposal_no,o_edn,o_kdn,status_rev 
from aureus_temp.temp_stat0 
where concat(policytechnicalid,'|',o_edn,'|',o_kdn) in (select concat(proposal_no,'|',o_edn,'|',o_kdn) from  aureus_temp.temp_stat1_2);

insert overwrite table aureus_temp.temp_stat2 select distinct * from aureus_temp.temp_stat2;

drop table if exists aureus_temp.temp_stat3;

create table aureus_temp.temp_stat3 as 
select * from aureus_temp.temp_stat2
where status_rev == 'Terminated or cannot be revived';

insert overwrite table aureus_temp.temp_stat3 select distinct * from aureus_temp.temp_stat3;

drop table if exists aureus_temp.temp_stat4;

create table aureus_temp.temp_stat4 as
select * from aureus_temp.temp_stat2 where
status_rev == 'Lapsed' and proposal_no not in (select distinct proposal_no from aureus_temp.temp_stat3);

insert overwrite table aureus_temp.temp_stat4 select distinct * from aureus_temp.temp_stat4;

drop table if exists aureus_temp.temp_stat5;

create table aureus_temp.temp_stat5 as
select * from aureus_temp.temp_stat2 where
status_rev == 'Tech Lapsed' and proposal_no not in (select distinct proposal_no from aureus_temp.temp_stat3 union select distinct proposal_no from  aureus_temp.temp_stat4);

insert overwrite table aureus_temp.temp_stat5 select distinct * from aureus_temp.temp_stat5;

drop table if exists aureus_temp.temp_stat6;

create table aureus_temp.temp_stat6 as
select * from aureus_temp.temp_stat2 where
status_rev == 'Inforce' and proposal_no not in (select distinct proposal_no from aureus_temp.temp_stat3 
                                                union select distinct proposal_no from  aureus_temp.temp_stat4
                                                union select distinct proposal_no from  aureus_temp.temp_stat5);

insert overwrite table aureus_temp.temp_stat6 select distinct * from aureus_temp.temp_stat6;

drop table if exists aureus_temp.eval_pol_tlapse;

create table aureus_temp.status_jan19 as
select proposal_no as pl_prop_num,status_rev as status_as_of_jan19,'2019-02-01' as evaluation_date from aureus_temp.temp_stat3
union
select proposal_no as pl_prop_num,status_rev as status_as_of_jan19,'2019-02-01' as evaluation_date from aureus_temp.temp_stat4
union
select proposal_no as pl_prop_num,status_rev as status_as_of_jan19,'2019-02-01' as evaluation_date from aureus_temp.temp_stat5
union
select proposal_no as pl_prop_num,status_rev as status_as_of_jan19,'2019-02-01' as evaluation_date from aureus_temp.temp_stat6;

drop table aureus_temp.temp_stat0;
drop table aureus_temp.temp_stat1;
drop table aureus_temp.temp_stat1_1;
drop table aureus_temp.temp_stat1_2;
drop table aureus_temp.temp_stat2;
drop table aureus_temp.temp_stat3;
drop table aureus_temp.temp_stat4;
drop table aureus_temp.temp_stat5;
drop table aureus_temp.temp_stat6;

drop table if exists aureus_temp.temp_stat0;

create table aureus_temp.temp_stat0 as
select policytechnicalid,o_edn,o_kdn,status_rev
from mis_data.all_status_change_combined where to_date(o_edn)< to_date('2019-03-01') and to_date(o_kdn)< to_date('2019-03-01')
and policytechnicalid in (select distinct policytechnicalid from aureus_temp.pol_dt1);

insert overwrite table aureus_temp.temp_stat0 select distinct * from aureus_temp.temp_stat0;

drop table if exists aureus_temp.temp_stat1;

create table aureus_temp.temp_stat1 as
select policytechnicalid as proposal_no,max(to_date(o_edn)) as o_edn
from aureus_temp.temp_stat0 group by policytechnicalid;

insert overwrite table aureus_temp.temp_stat1 select distinct * from aureus_temp.temp_stat1;

drop table if exists aureus_temp.temp_stat1_1;

create table aureus_temp.temp_stat1_1 as
select policytechnicalid as proposal_no,o_edn,max(to_date(o_kdn)) as o_kdn
from aureus_temp.temp_stat0 group by policytechnicalid,o_edn;

drop table if exists aureus_temp.temp_stat1_2;

create table aureus_temp.temp_stat1_2 as 
select proposal_no,o_edn,o_kdn from 
aureus_temp.temp_stat1_1 where 
concat(proposal_no,'|',o_edn) in (select concat(proposal_no,'|',o_edn) from aureus_temp.temp_stat1);

drop table if exists aureus_temp.temp_stat2;

create table aureus_temp.temp_stat2 as
select policytechnicalid as proposal_no,o_edn,o_kdn,status_rev 
from aureus_temp.temp_stat0 
where concat(policytechnicalid,'|',o_edn,'|',o_kdn) in (select concat(proposal_no,'|',o_edn,'|',o_kdn) from  aureus_temp.temp_stat1_2);

insert overwrite table aureus_temp.temp_stat2 select distinct * from aureus_temp.temp_stat2;

drop table if exists aureus_temp.temp_stat3;

create table aureus_temp.temp_stat3 as 
select * from aureus_temp.temp_stat2
where status_rev == 'Terminated or cannot be revived';

insert overwrite table aureus_temp.temp_stat3 select distinct * from aureus_temp.temp_stat3;

drop table if exists aureus_temp.temp_stat4;

create table aureus_temp.temp_stat4 as
select * from aureus_temp.temp_stat2 where
status_rev == 'Lapsed' and proposal_no not in (select distinct proposal_no from aureus_temp.temp_stat3);

insert overwrite table aureus_temp.temp_stat4 select distinct * from aureus_temp.temp_stat4;

drop table if exists aureus_temp.temp_stat5;

create table aureus_temp.temp_stat5 as
select * from aureus_temp.temp_stat2 where
status_rev == 'Tech Lapsed' and proposal_no not in (select distinct proposal_no from aureus_temp.temp_stat3 union select distinct proposal_no from  aureus_temp.temp_stat4);

insert overwrite table aureus_temp.temp_stat5 select distinct * from aureus_temp.temp_stat5;

drop table if exists aureus_temp.temp_stat6;

create table aureus_temp.temp_stat6 as
select * from aureus_temp.temp_stat2 where
status_rev == 'Inforce' and proposal_no not in (select distinct proposal_no from aureus_temp.temp_stat3 
                                                union select distinct proposal_no from  aureus_temp.temp_stat4
                                                union select distinct proposal_no from  aureus_temp.temp_stat5);

insert overwrite table aureus_temp.temp_stat6 select distinct * from aureus_temp.temp_stat6;

drop table if exists aureus_temp.eval_pol_tlapse;

create table aureus_temp.status_feb19 as
select proposal_no as pl_prop_num,status_rev as status_as_of_feb19,'2019-03-01' as evaluation_date from aureus_temp.temp_stat3
union
select proposal_no as pl_prop_num,status_rev as status_as_of_feb19,'2019-03-01' as evaluation_date from aureus_temp.temp_stat4
union
select proposal_no as pl_prop_num,status_rev as status_as_of_feb19,'2019-03-01' as evaluation_date from aureus_temp.temp_stat5
union
select proposal_no as pl_prop_num,status_rev as status_as_of_feb19,'2019-03-01' as evaluation_date from aureus_temp.temp_stat6;

drop table aureus_temp.temp_stat0;
drop table aureus_temp.temp_stat1;
drop table aureus_temp.temp_stat1_1;
drop table aureus_temp.temp_stat1_2;
drop table aureus_temp.temp_stat2;
drop table aureus_temp.temp_stat3;
drop table aureus_temp.temp_stat4;
drop table aureus_temp.temp_stat5;
drop table aureus_temp.temp_stat6;

select count(*) from aureus_temp.pol_dt1;


create table aureus_temp.pol_dt2 as
select t.*,t1.status_as_of_mar18 
from aureus_temp.pol_dt2 t left join
aureus_temp.status_mar18 t1
on t.policytechnicalid = t1.pl_prop_num;

select count(*) from aureus_temp.pol_dt2;

create table aureus_temp.pol_dt3 as
select t.*,t1.status_as_of_apr18 
from aureus_temp.pol_dt2 t left join
aureus_temp.status_apr18 t1
on t.policytechnicalid = t1.pl_prop_num;

select count(*) from aureus_temp.pol_dt3;

create table aureus_temp.pol_dt4 as
select t.*,t1.status_as_of_may18 
from aureus_temp.pol_dt3 t left join
aureus_temp.status_may18 t1
on t.policytechnicalid = t1.pl_prop_num;

select count(*) from aureus_temp.pol_dt4;

create table aureus_temp.pol_dt5 as
select t.*,t1.status_as_of_june18 
from aureus_temp.pol_dt4 t left join
aureus_temp.status_june18 t1
on t.policytechnicalid = t1.pl_prop_num;

select count(*) from aureus_temp.pol_dt5;

create table aureus_temp.pol_dt6 as
select t.*,t1.status_as_of_july18 
from aureus_temp.pol_dt5 t left join
aureus_temp.status_july18 t1
on t.policytechnicalid = t1.pl_prop_num;

select count(*) from aureus_temp.pol_dt6;

create table aureus_temp.pol_dt7 as
select t.*,t1.status_as_of_aug18 
from aureus_temp.pol_dt6 t left join
aureus_temp.status_aug18 t1
on t.policytechnicalid = t1.pl_prop_num;

select count(*) from aureus_temp.pol_dt7;

create table aureus_temp.pol_dt8 as
select t.*,t1.status_as_of_sept18 
from aureus_temp.pol_dt7 t left join
aureus_temp.status_sept18 t1
on t.policytechnicalid = t1.pl_prop_num;

select count(*) from aureus_temp.pol_dt8;

create table aureus_temp.pol_dt9 as
select t.*,t1.status_as_of_oct18 
from aureus_temp.pol_dt8 t left join
aureus_temp.status_oct18 t1
on t.policytechnicalid = t1.pl_prop_num;

select count(*) from aureus_temp.pol_dt9;

create table aureus_temp.pol_dt10 as
select t.*,t1.status_as_of_nov18 
from aureus_temp.pol_dt9 t left join
aureus_temp.status_nov18 t1
on t.policytechnicalid = t1.pl_prop_num;

select count(*) from aureus_temp.pol_dt10;

create table aureus_temp.pol_dt11 as
select t.*,t1.status_as_of_dec18 
from aureus_temp.pol_dt10 t left join
aureus_temp.status_dec18 t1
on t.policytechnicalid = t1.pl_prop_num;

select count(*) from aureus_temp.pol_dt11;

create table aureus_temp.pol_dt12 as
select t.*,t1.status_as_of_jan19 
from aureus_temp.pol_dt11 t left join
aureus_temp.status_jan19 t1
on t.policytechnicalid = t1.pl_prop_num;

select count(*) from aureus_temp.pol_dt12;

create table aureus_temp.pol_dt13 as
select t.*,t1.status_as_of_feb19 
from aureus_temp.pol_dt12 t left join
aureus_temp.status_feb19 t1
on t.policytechnicalid = t1.pl_prop_num;

select count(*) from aureus_temp.pol_dt13;

create table aureus_temp.pol_dt14 as
select t.*, t1.surrender_dt_sel
from aureus_temp.pol_dt13 t left join
surrender_temp.surrender_sel t1 on 
t.policytechnicalid = t1.policytechnicalid;

select count(*) from aureus_temp.pol_dt14;