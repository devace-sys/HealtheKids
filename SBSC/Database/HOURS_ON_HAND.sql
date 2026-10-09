USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.HOURS_ON_HAND') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.HOURS_ON_HAND
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[HOURS_ON_HAND]
(    
 @clientID   INT,    
 @endDate    datetime
)
     
/***************************************************************************    
 * HOURS_ON_HAND */    
/**    
 * Returns a table that match the given parameters.
 *    
 * @param  clientID        ID of client    
 * @param  startDate       Start date    
 * @param  endDate         End date
 *
 * calculates the sum of estimated hours for each client from the input batch files having the 
 * Ready to assign status till the noon of given @enddate and excluding any files 
 * that are changed from CIS to Ready to assign.
 * 
 * @return                 Table of data    
 ***************************************************************************/     

RETURNS TABLE 
AS 
RETURN(

	select top (dbo.CONST_MAX_ROWS()) cc.CLIENT_ID,
	       isnull(a.HoursOnHand,0)+isnull(b.HoursOnHand,0) as HoursOnHand,
	       case when a.OldestDateOfService IS NOT NULL AND 
	                 b.OldestDateOfService IS NOT NULL AND 
	                 a.OldestDateOfService < b.OldestDateOfService then a.OldestDateOfService
	            when a.OldestDateOfService IS NOT NULL AND 
	                 b.OldestDateOfService IS NOT NULL AND 
	                 a.OldestDateOfService > b.OldestDateOfService then b.OldestDateOfService 
	            else coalesce(a.OldestDateOfService,b.OldestDateOfService) end                  as OldestDateOfService,
	       case when a.OldestRecievedDate IS NOT NULL AND 
	                 b.OldestRecievedDate IS NOT NULL AND 
	                 a.OldestRecievedDate < b.OldestRecievedDate then a.OldestRecievedDate
	            when a.OldestRecievedDate IS NOT NULL AND 
	                 b.OldestRecievedDate IS NOT NULL AND 
	                 a.OldestRecievedDate > b.OldestRecievedDate then b.OldestRecievedDate 
	            else coalesce(a.OldestRecievedDate,b.OldestRecievedDate) end                   as OldestRecievedDate 
	  from
	
	(select ClientID ,sum(isnull(Estimated_Input_Hours,0)) as HoursOnHand,
	                  min(Oldest_DOS)                      as OldestDateOfService, 
	                  min(Date_Recieved)                   as OldestRecievedDate 
	   from INPUT_BATCHES
	   where  Current_status_Code  in (50) AND 
	          Date_Recieved <= DATEADD(HH,12,@endDate)
	   group by ClientID
		) a
	right join CLIENTS_Client cc on cc.CLIENT_ID = a.ClientID

	left join
	(select ClientID,sum(isnull(Estimated_Input_Hours,0)) as HoursOnHand,
	                 min(Oldest_DOS)                      as OldestDateOfService, 
	                 min(Date_Recieved)                   as OldestRecievedDate
	   from INPUT_BATCHES ib
	 where exists -- Include the files that are assigned or changed to another status after @enddate
	 
	   (select iba.Input_Batches_ID,min(iba.date_updated) from Input_Batches_Activity iba 
	     where iba.Input_Batches_ID = ib.ID and 	           
	           FROM_STATUS = 50 and to_STATUS > 50
	    group by Iba.Input_Batches_ID
	    having min(iba.Date_Updated) > DATEADD(HH,12,@endDate) 
       ) and 
       not exists --excluding any files that are changed from CIS to Ready to assign.
       (select Input_Batches_ID,min(iba2.date_updated) from Input_Batches_Activity iba2
         where iba2.Input_Batches_ID = ib.ID and                 
               FROM_STATUS = 90 and to_STATUS = 50
        group by Iba2.Input_Batches_ID
    	having min(iba2.Date_Updated) > DATEADD(HH,12,@endDate) 
       ) and 
     Date_Recieved <= DATEADD(HH,12,@endDate) 
	 group by ClientID
	) b on b.clientID = cc.client_ID 	 
	where LEA = 1
	)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[HOURS_ON_HAND]          TO [webuser]
GRANT SELECT ON  [dbo].[CLIENTS_Client_Reps]    TO [webuser]
GRANT SELECT ON  [dbo].[Input_Batches_Activity] TO [webuser]

GO   
