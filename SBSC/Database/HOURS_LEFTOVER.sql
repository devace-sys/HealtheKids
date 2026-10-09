USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.HOURS_LEFTOVER') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.HOURS_LEFTOVER
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[HOURS_LEFTOVER]
(    
 @staffID   INT,    
 @friday    datetime
)
     
/***************************************************************************    
 * HOURS_LEFTOVER */    
/**    
 * Returns a table that match the given parameters.
 *    
 * @param  staffID        ID of staff
 * @param  friday         Last friday's date
 *
 * calculates the sum of leftover hours for each staff.
 * 
 * @return                 Table of data    
 ***************************************************************************/     

RETURNS TABLE 
AS 
RETURN(
	
   select sum(Estimated_Input_Hours) as LeftoverHours from dbo.INPUT_BATCHES ib
      join (select Min(date_updated) as dateupdated,Input_Batches_ID,AssignedTo 
		      from input_batches_activity iba1
		     where TO_STATUS  = 60 and 
		           TO_STATUS != FROM_STATUS
		           and Not exists
		           (select 'x' from Input_Batches_Activity iba2
		             where iba2.Input_Batches_ID  = iba1.Input_Batches_ID and 
		                   TO_STATUS             >= 100 and 
		                   TO_STATUS             != FROM_STATUS and
		                   Date_Updated          <= DATEADD(HH,12,@friday))
		     group by Input_Batches_ID,AssignedTo having min(Date_Updated) < DATEADD(HH,12,@friday)
		   ) as iba on  iba.Input_Batches_ID      = ib.id and   
		                ib.Current_status_UserID2 = iba.AssignedTo
   where ib.Active = 1	
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[HOURS_LEFTOVER] TO [webuser]
GO   
