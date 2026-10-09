USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.HOURS_ASSIGNED') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.HOURS_ASSIGNED
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[HOURS_ASSIGNED]
(    
 @staffID    INT,    
 @friday datetime
)
     
/***************************************************************************    
 * HOURS_ASSIGNED */    
/**    
 * Returns a table that match the given parameters.
 *    
 * @param  staffID         ID of staff
 * @param  lastFriday      lastfriday date 
 *
 * calculates the sum of assigned hours for each staff that are assigned 
 * after 12pm last to last fridaty till 12pm last friday and any 
 * leftover hours from previous weeks
 * 
 * @return                 Table of data    
 ***************************************************************************/     

RETURNS TABLE 
AS 
RETURN(
	select Current_status_UserID2,sum(Estimated_Input_Hours) as TotalHoursAssigned  from dbo.INPUT_BATCHES ib1 
	join
	(select max(iba.Date_Updated) as dateupdated,ib.id,TO_STATUS
	from dbo.INPUT_BATCHES  as ib , Input_Batches_Activity iba
	where ib.id            = iba.Input_Batches_ID and 
	      ib.Active        = 1 and 
	      iba.AssignedTo   = ib.Current_status_UserID2 and	
	      iba.TO_STATUS    = 60 and 
	      iba.FROM_STATUS != iba.TO_STATUS
	      and Not exists 
	      (select 'x' from Input_Batches_Activity iba2
	        where iba2.Input_Batches_ID  = iba.Input_Batches_ID and 
	              iba2.TO_STATUS         = 100 and 
	              iba2.FROM_STATUS      != iba2.TO_STATUS
	              and iba2.Date_Updated <= DATEADD(dd,-7,DATEADD(HH,12,@friday)) )
	group by Ib.ID,TO_STATUS having MAX(Date_Updated) < DATEADD(HH,12,@friday)
	) ib2 on ib1.id = ib2.id 
	group by Current_status_UserID2
  )
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[HOURS_ASSIGNED] TO [webuser]
GO   
