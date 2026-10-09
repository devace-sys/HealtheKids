USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RPT_SPED_SERVICES_FOR_SELPA_EXPORT') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RPT_SPED_SERVICES_FOR_SELPA_EXPORT
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[RPT_SPED_SERVICES_FOR_SELPA_EXPORT] (  
    @userID                bigint
  , @userGroup             int
  , @userRank              int
  , @clientID              int
  , @startDate             DATETIME  /* Pass current window start */
  , @endDate               DATETIME  /* Pass current window end */
)
 
RETURNS TABLE
 
 /***************************************************************************    
  * RPT_SPED_SERVICES_FOR_SELPA_EXPORT */    
 /**    
  * Returns all active IEP/IFSP service records linked to CALPADS codes.  
  * Does not return synch data.  This is for cases where the SELPA will
  * completely replace their data with our data for a given period.
  *    
  * @return                 Table of report rows
  ***************************************************************************/     
 
AS RETURN (
  select sec.* from dbo.RPT_SPED_SERVICES_FOR_SELPA_EXPORT_CORE (  @userID , @userGroup, @userRank, @clientID, @startDate, @endDate) as sec
)
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[RPT_SPED_SERVICES_FOR_SELPA_EXPORT] TO [webuser]
GO