USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_AUTHORIZATION_REQUESTS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SERVICE_AUTHORIZATION_REQUESTS_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[SERVICE_AUTHORIZATION_REQUESTS_VIEW] (
    @userID                            BIGINT
  , @userGroup                         INT  
  , @userRank                          INT
  , @clientID                          BIGINT
  , @startDate                         DATE
  , @endDate                           DATE
  , @currentResponseCode               bigint     
  , @closed                            BIT
  , @requestID                         bigint
  , @active                            BIT
  , @recID                             BIGINT
)    

RETURNS TABLE
 
 /***************************************************************************    
  * SERVICE_AUTHORIZATION_REQUESTS_VIEW */    
 /**    
  * Retuns a list of service authorization requests that userId is permitted
  * to view
  *
  * @return table 
  ***************************************************************************/                         
     
AS RETURN
(
  select top (dbo.CONST_MAX_ROWS())
  
    sarvc.* 
  
  from dbo.SERVICE_AUTHORIZATION_REQUESTS_VIEW_CORE (
      @userID
    , @userGroup
    , @userRank
	, @clientID  
    , @startDate
    , @endDate  
    , @currentResponseCode
	, @closed
	, @requestID
	, @active 
	, @recID ) as sarvc
	
	order by 

	  sarvc.clientName  asc	
	, sarvc.patName     asc
	, sarvc.created     asc
	, sarvc.id          asc

)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[SERVICE_AUTHORIZATION_REQUESTS_VIEW] TO [webuser]
GO  
