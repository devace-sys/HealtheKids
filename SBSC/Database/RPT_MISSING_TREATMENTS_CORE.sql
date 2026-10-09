USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RPT_MISSING_TREATMENTS_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RPT_MISSING_TREATMENTS_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[RPT_MISSING_TREATMENTS_CORE] (
   @clientID             bigint  = null
 , @repID                bigint  = null  /* null = all reps */
 , @groupSvcClassNameID  bigint  = null
 , @spEdServiceCode      int     = null
 , @patHasBIC            bit     = null
 , @leaBopSvc            bit     = null
 , @missingTmt           bit     = null
 , @svcTrackingClass     int     = null
)
returns
table
as
return
(

select 
   
    clientName = clc.CLIENT_NAME
  , repID      = clc.REP_ID
  , repName    = clc.REP_NAME
  , mtdc2.*

from dbo.CLIENTS_Client_Active_LEA as clc

/*============================================================
 * Get data for each active client
 *===========================================================*/  

cross apply (
    select 
	  mtdc1.* 
	from dbo.RPT_MISSING_TREATMENTS_DATA_CORE (  clc.CLIENT_ID
	                                           , @groupSvcClassNameID
					 						   , @spEdServiceCode
					 						   , @patHasBIC
					 						   , @leaBopSvc
											   , @missingTmt
											   , @svcTrackingClass) as mtdc1   
) as mtdc2

where (
       (1=1)
  and ((@clientID is null) or (clc.CLIENT_ID = @clientID))
  and ((@repID    is null) or (clc.REP_ID    = @repID))
)

)
GO

/*-------------------------------
* User Permissions
*------------------------------*/

GRANT SELECT ON  dbo.RPT_MISSING_TREATMENTS_CORE TO [webuser]
GO