USE [SPEDMON]

GO
/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('RPT_SBSC_STAFF_HOURS_SUMMARY') AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[RPT_SBSC_STAFF_HOURS_SUMMARY]
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[RPT_SBSC_STAFF_HOURS_SUMMARY]
(@staffID       BIGINT,
 @oneWeekBack   date,
 @twoWeekBack   date,
 @threeWeekBack date,
 @fourWeekBack  date
)
RETURNS TABLE

AS
/***************************************************************************
 * RPT_SBSC_STAFF_HOURS_SUMMARY */
/**
 * Generates SBSC STAFF HOURS SUMMARY report of Promised hours, 
 * actual input hours worked and %promised hours worked for last four weeks
 * 
 * @param          staffID 
 * @oneWeekBack    start date of last work week
 * @twoWeekBack    start date of work week 2 weeks back
 * @threeWeekBack  start date of work week 3 weeks back
 * @fourWeekBack   start date of work week 4 weeks back    
 * @return Table
 ***************************************************************************/

RETURN(


with oneWeekBack_cte as
(
select isnull(a.STAFF_ID,b.staff_id ) as staff_ID, a.PromisedHours,B.ActualHours from
    (select sph.STAFF_ID,sum(sph.PROMISED_HOURS) as PromisedHours from dbo.STAFF_PROMISED_HOURS sph
	 where WEEKSTART_DATE = @oneWeekback
	 group by STAFF_ID) as a
	 full join (
	 select uc.userrid as staff_id,SUM(hours) as ActualHours from 
	 users.dbo.user_correlation  as uc 
	 left join [ST33\SQLEXPRESS].TTFN.dbo.timeentries as te on uc.TTFNID = te.Employee
	 where Date >= @oneWeekback and Date <= dateadd(dd,6,@oneWeekBack) and 
	       (task > 5) and (task not in (58,105,106,104))
     group by uc.userrid
	 ) as b on b.STAFF_ID = a.STAFF_ID
)

,twoWeekBack_cte as
(
select isnull(a.STAFF_ID,b.staff_id ) as staff_ID, a.PromisedHours,B.ActualHours from
    (select sph.STAFF_ID,sum(sph.PROMISED_HOURS) as PromisedHours from dbo.STAFF_PROMISED_HOURS sph
	 where WEEKSTART_DATE = @twoWeekback
	 group by STAFF_ID) as a
	 full join (
	 select uc.userrid as staff_id,SUM(hours) as ActualHours from 
	 users.dbo.user_correlation  as uc 
	 left join [ST33\SQLEXPRESS].TTFN.dbo.timeentries as te on uc.TTFNID = te.Employee
	 where Date >= @twoWeekback and Date <= dateadd(dd,6,@twoWeekBack) and 
	       (task > 5) and (task not in (58,105,106,104))
     group by uc.userrid
	 ) as b on b.STAFF_ID = a.STAFF_ID
)

,threeWeekBack_cte as
(
select isnull(a.STAFF_ID,b.staff_id ) as staff_ID, a.PromisedHours,B.ActualHours from
    (select sph.STAFF_ID,sum(sph.PROMISED_HOURS) as PromisedHours from dbo.STAFF_PROMISED_HOURS sph
	 where WEEKSTART_DATE = @threeWeekback
	 group by STAFF_ID) as a
	 full join (
	 select uc.userrid as staff_id,SUM(hours) as ActualHours from 
	 users.dbo.user_correlation  as uc 
	 left join [ST33\SQLEXPRESS].TTFN.dbo.timeentries as te on uc.TTFNID = te.Employee
	 where Date >= @threeWeekback and Date <= dateadd(dd,6,@threeWeekBack) and 
	       (task > 5) and (task not in (58,105,106,104))
     group by uc.userrid
	 ) as b on b.STAFF_ID = a.STAFF_ID
)

,fourWeekBack_cte as
(
select isnull(a.STAFF_ID,b.staff_id ) as staff_ID, a.PromisedHours,B.ActualHours from
    (select sph.STAFF_ID,sum(sph.PROMISED_HOURS) as PromisedHours from dbo.STAFF_PROMISED_HOURS sph
	 where WEEKSTART_DATE = @fourWeekback
	 group by STAFF_ID) as a
	 full join (
	 select uc.userrid as staff_id,SUM(hours) as ActualHours from 
	 users.dbo.user_correlation  as uc 
	 left join [ST33\SQLEXPRESS].TTFN.dbo.timeentries as te on uc.TTFNID = te.Employee
	 where Date >= @fourWeekback and Date <= dateadd(dd,6,@fourWeekBack) and 
	       (task > 5) and (task not in (58,105,106,104))
     group by uc.userrid
	 ) as b on b.STAFF_ID = a.STAFF_ID
)


,staff_cte as
(
select distinct staff_id from dbo.STAFF_PROMISED_HOURS
where WEEKSTART_DATE <= @oneWeekBack and WEEKSTART_DATE >= @fourWeekBack
and staff_id not in (812,828) -- Remove Erica and Rosilyn
)


SELECT st.STAFF_ID, u.firstname+' '+u.lastname as name                                                
                 , isnull(one.PromisedHours,0) as PHone  , isnull(one.ActualHours,0) as AHone,   
                 case when isnull(one.PromisedHours,0)>0 then isnull(one.ActualHours,0)/isnull(one.PromisedHours,0) 
                 else null end as '%One'
                  , isnull(two.PromisedHours,0) as PHtwo  , isnull(two.ActualHours,0) as AHtwo,  
                 case when isnull(two.PromisedHours,0)>0 then isnull(two.ActualHours,0)/isnull(two.PromisedHours,0) 
                 else null end as '%Two'
                  , isnull(thr.PromisedHours,0) as PHthree, isnull(thr.ActualHours,0) as AHthree, 
                 case when isnull(thr.PromisedHours,0)>0 then isnull(thr.ActualHours,0)/isnull(thr.PromisedHours,0) 
                 else null end   as '%Three'
                  , isnull(fr.PromisedHours,0)  as PHfour , isnull(fr.ActualHours,0) as AHfour,  
                 case when isnull(fr.PromisedHours,0)>0 then isnull(fr.ActualHours,0)/isnull(fr.PromisedHours,0)
                 else null end   as '%Four'
FROM staff_cte st
left join users.dbo.USERS_DATA_CORE(users.dbo.CONST_APP_NAME_SPEDCARE(),null,null,null,null) as u on u.id = st.staff_id
                                                                                             and u.userGroupID = users.dbo.CONST_USER_GROUP_SBS()
left join oneWeekBack_cte      one on one.staff_id = st.staff_id
left join twoWeekBack_cte      two on two.staff_id = st.staff_id
left join threeWeekBack_cte    thr on thr.staff_id = st.staff_id
left join fourWeekBack_cte     fr  on fr.staff_id  = st.staff_id
where u.active = 1

)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON [dbo].[RPT_SBSC_STAFF_HOURS_SUMMARY] TO [webuser]

GO

 

