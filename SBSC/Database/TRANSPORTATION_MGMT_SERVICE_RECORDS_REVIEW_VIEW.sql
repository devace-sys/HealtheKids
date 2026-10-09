USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.TRANSPORTATION_MGMT_SERVICE_RECORDS_REVIEW_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.TRANSPORTATION_MGMT_SERVICE_RECORDS_REVIEW_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[TRANSPORTATION_MGMT_SERVICE_RECORDS_REVIEW_VIEW] (
    @userID            BIGINT   
  , @userGroup         INT    
  , @userRank          INT
  , @clientID          BIGINT
  , @patID             BIGINT
  , @startDate         datetime
  , @endDate           datetime )
      
returns table     
as    
    
/***************************************************************************    
 * TRANSPORTATION_MGMT_SERVICE_RECORDS_REVIEW_VIEW */    
/**    
 *     
 * @return Service records
 ***************************************************************************/     
    
return 
(      

  select top (dbo.CONST_MAX_ROWS())
    *   
  from dbo.TRANSPORTATION_MGMT_SERVICE_RECORDS_REVIEW_VIEW_CORE (  
    @userID  
  , @userGroup
  , @userRank 
  , @clientID
  , @patID
  , @startDate
  , @endDate )
    
  order by 
  
      dosVal   desc
    , svcRecID desc

)  
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[TRANSPORTATION_MGMT_SERVICE_RECORDS_REVIEW_VIEW] TO [webuser]
GO