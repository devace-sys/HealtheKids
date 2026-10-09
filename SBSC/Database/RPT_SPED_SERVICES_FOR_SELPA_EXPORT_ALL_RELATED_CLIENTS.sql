USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RPT_SPED_SERVICES_FOR_SELPA_EXPORT_ALL_RELATED_CLIENTS') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RPT_SPED_SERVICES_FOR_SELPA_EXPORT_ALL_RELATED_CLIENTS
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[RPT_SPED_SERVICES_FOR_SELPA_EXPORT_ALL_RELATED_CLIENTS] (  
    @userID                bigint
  , @userGroup             int
  , @userRank              int
  , @selpaCode             int
  , @startDate             DATETIME  /* Pass current window start */
  , @endDate               DATETIME  /* Pass current window end */
)
 
RETURNS TABLE
 
 /***************************************************************************    
  * RPT_SPED_SERVICES_FOR_SELPA_EXPORT_ALL_RELATED_CLIENTS */    
 /**    
  * Returns all active IEP/IFSP service records linked to CALPADS codes.  
  * Does not return synch data.  This is for cases where the SELPA will
  * completely replace their data with our data for a given period.
  *    
  * @return                 Table of report rows
  ***************************************************************************/     
 
AS RETURN (

select top (999999999) 
  sec2.*
from dbo.SELPA_RELATED_CLIENTS_VIEW_CORE (@selpaCode) as se 
cross apply (
  select sec1.* from dbo.RPT_SPED_SERVICES_FOR_SELPA_EXPORT_CORE (  @userID , @userGroup, @userRank, se.clientID, @startDate, @endDate) as sec1
) as sec2

order by 
  se.clientName
)

GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[RPT_SPED_SERVICES_FOR_SELPA_EXPORT_ALL_RELATED_CLIENTS] TO [webuser]
GO