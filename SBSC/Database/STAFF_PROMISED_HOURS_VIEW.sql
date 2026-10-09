USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.STAFF_PROMISED_HOURS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.STAFF_PROMISED_HOURS_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[STAFF_PROMISED_HOURS_VIEW]    
(
 @recID        BIGINT,     
 @staffID      bigint,
 @startdate    date,
 @day          date,
 @active       BIT,    
 @canEdit      BIT)    
 
 RETURNS @promisedHours  TABLE(ID                 BIGINT,
                               Staff_ID           BIGINT,
                               NAME               VARCHAR(100),
                               WEEK_START         VARCHAR(50),
                               DAY                VARCHAR(10),
                               DateOfDay          date,
                               SHIFT_1            VARCHAR(20),
                               SHIFT_2            VARCHAR(20),
                               SHIFT_3            VARCHAR(20),                               
                               DAYHOURS           decimal(18,2),
                               WEEKHOURS          decimal(18,2),
                               ASSIGNEDHOURS      decimal(18,2),
                               LEFTOVERS          decimal(18,2),
                               PROMISED_HOURS     decimal(18,2),
                               NOTE               VARCHAR(MAX),
                               LAST_UPDATED       DATETIME)
  
 
 /***************************************************************************    
  * STAFF_PROMISED_HOURS_VIEW */    
 /**    
  * Returns a table of STAFF_PROMISED_HOURS that match the given parameters    
  *    
  * @param  staffID         staff ID  
  * @param  startdate       startdate of the work week     
  * @param  active          If client is active
  * @param  recID           Client record id    
  *
  * left over hours are calculated as of today.
  * @return                 Table of INPUT_BATCHES data    
  ***************************************************************************/     
  
AS 
begin  

if (@day is not null)
select @startdate = WEEKSTART_DATE from dbo.STAFF_PROMISED_HOURS where DAY = @day

declare @lastFriday as datetime
set @lastfriday =cast(DATEADD(day, -3 - (DATEPART(dw, GETDATE()) + @@DATEFIRST - 2) % 7, GETDATE()) as date)
set @lastfriday = DATEADD(hh,12,@lastfriday)

/*-------------------------------    
 * Retrieve records   
 *------------------------------*/     
 INSERT INTO @promisedHours
   SELECT st.ID                                        as ID,
          st.staff_id                                  as STAFF_ID,
          u.firstname+' '+u.lastname                   as STAFF_NAME,
          convert(varchar,WEEKSTART_DATE,101)          as WEEKSTART_DATE,                   
          DAYOFWEEK =CASE DATEPART(weekday,day)
                     WHEN 1 THEN 'Sunday'
					 WHEN 2 THEN 'Monday'
					 WHEN 3 THEN 'Tuesday'
					 WHEN 4 THEN 'Wednesday'
					 WHEN 5 THEN 'Thursday'
					 WHEN 6 THEN 'Friday'
					 WHEN 7 THEN 'Saturday'
					 END, 
          day                                          as DateOfDay,					                   
          convert(varchar,SHIFT1_START,100)+' - '+ convert(varchar,SHIFT1_END,100)
                                                       as SHIFT_1,
          convert(varchar,SHIFT2_START,100)+' - '+ convert(varchar,SHIFT2_END,100)
                                                       as SHIFT_2,
          convert(varchar,SHIFT3_START,100)+' - '+ convert(varchar,SHIFT3_END,100)
                                                       as SHIFT_3,
          convert(decimal(18,2),TOTAL_HOURS)           as TOTAL_DAY,
          convert(decimal(18,2),T.TotalWeekHours)      as TOTAL_WEEK,
          convert(decimal(18,2),isnull(ib.TotalHoursAssigned,0))
                                                       as TOTAL_ASSIGNED,
          isnull(ib1.leftovers,0)                      as LEFTOVERS, 
          PROMISED_HOURS,                                                    
          NOTE,
          st.LAST_UPDATED        
  FROM [SPEDMON].[dbo].[STAFF_PROMISED_HOURS] st
  left join users.dbo.USERS_DATA_CORE(users.dbo.CONST_APP_NAME_SPEDCARE(),null,null,null,null)
                                        as u on u.ID      = st.STAFF_ID
                                        and roleID IN (2,3,4,8)     
  left join (select sum(TOTAL_HOURS) as TotalWeekHours,staff_id from dbo.STAFF_PROMISED_HOURS
              where (@startdate is null or WEEKSTART_DATE = @startdate) group by staff_id) T on T.staff_id = sT.staff_id                                        
  left join (select Current_status_UserID2, sum(Estimated_Input_Hours) as TotalHoursAssigned from dbo.INPUT_BATCHES
               where Current_status_Code in (60,70)     
               group by Current_status_UserID2 ) ib
               on ib.Current_status_UserID2 = st.staff_id   
 left join (select ib.Current_status_UserID2, sum(Estimated_Input_Hours) as leftovers
			 from dbo.INPUT_BATCHES ib
			 join (select Min(date_updated) as dateupdated,Input_Batches_ID 
				  from input_batches_activity
				  where TO_STATUS = 60
				  group by Input_Batches_ID
				  having min(Date_Updated) < @lastFriday) as iba on  ib.id = iba.Input_Batches_ID
			 where ib.Current_status_Code in (60,70)
			 group by Current_status_UserID2) as ib1  on ib1.Current_status_UserID2 = st.staff_id 
  where ((@startdate is null) or (st.WEEKSTART_DATE = @startdate))
    and ((@day       is null) or (st.DAY            = @day))
    and ((@staffId   is null) or (st.staff_id       = @staffID))
    --and (total_hours > 0)
  order by u.lastname asc,u.firstname asc,day asc

RETURN
end
go
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[STAFF_PROMISED_HOURS_VIEW] TO [webuser]
GO

