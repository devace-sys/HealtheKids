USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_RECORDS_TO_CHANGE_BY_PRAC_ID_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SERVICE_RECORDS_TO_CHANGE_BY_PRAC_ID_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[SERVICE_RECORDS_TO_CHANGE_BY_PRAC_ID_VIEW_CORE] (
    @userID          BIGINT
  , @userGroup       INT  
  , @userRank        INT
  , @clientID        bigint
  , @pracID          bigint
  , @recID           bigint )
      
returns table     
as    
    
/***************************************************************************    
 * SERVICE_RECORDS_TO_CHANGE_BY_PRAC_ID_VIEW_CORE */    
/**    
 *     
 * @param  userID          User ID (Required)    
 * @param  userGroup       User group (Required)    
 * @param  userRank        User rank (Required)    
 * @param  clientID
 * @param  pracID
 * @param  approvingPracID
 * @param  pracID
 * @return                 Service records and svc notes
 ***************************************************************************/     
    
return (    

select *
from dbo.SERVICE_RECORDS_REVIEW_VIEW_CORE (@userID, @userGroup, @userRank, @clientID, null, @pracID, null, null, null, null, null, 1) as t1
where ((t1.pracID = @pracID) and (t1.SvcReviewState = 3)
  and ((@recID is null) or (id = @recID))
)
)  
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[SERVICE_RECORDS_TO_CHANGE_BY_PRAC_ID_VIEW_CORE] TO [webuser]
GO