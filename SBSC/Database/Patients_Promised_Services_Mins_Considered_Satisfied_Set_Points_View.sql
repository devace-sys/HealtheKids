USE [SPEDMON]
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Patients_Promised_Services_Mins_Considered_Satisfied_Set_Points_View') AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.Patients_Promised_Services_Mins_Considered_Satisfied_Set_Points_View
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[Patients_Promised_Services_Mins_Considered_Satisfied_Set_Points_View] (    
    @userID      bigint
  , @userGroup   int   
  , @userRank    int
  , @clientID    bigint
)
 
RETURNS TABLE      
    
AS RETURN(      

/*************************************************************************
 * view */
/**
 * Primary UDF for accessing this entities records.
 * 
 * NOTE: At present there is only one record per client.  This will change
 * when we can expand the management of this data.  At this time this note
 * should be removed.
 **************************************************************************/   
    
select top 1 /* Always only one record for now until management of this data is expanded */
    t1.*
  , [name]     = clc.CLIENT_NAME
  , clientName = clc.CLIENT_NAME
from dbo.Patients_Promised_Services_Mins_Considered_Satisfied_Set_Points as t1
join dbo.CLIENTS_Client                                                  as clc on clc.CLIENT_ID = t1.clientID
where (
      (t1.clientID = @clientID)
  and (t1.active = 1)
)

)
  
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[Patients_Promised_Services_Mins_Considered_Satisfied_Set_Points_View] TO [webuser]
GO   


