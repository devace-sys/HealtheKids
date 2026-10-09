/*########################################################
 *# Entry Point for Details - Review Non Health Services 
 *########################################################*/

USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_RECORDS_TO_APPROVE_BY_PRAC_ID_AND_SVC_REC_ID_VIEW_DETAIL') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SERVICE_RECORDS_TO_APPROVE_BY_PRAC_ID_AND_SVC_REC_ID_VIEW_DETAIL
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[SERVICE_RECORDS_TO_APPROVE_BY_PRAC_ID_AND_SVC_REC_ID_VIEW_DETAIL] (
    @userID          bigint
  , @userGroup       int  
  , @userRank        int
  , @clientID        bigint
  , @siteID          bigint
  , @approvingPracID bigint
  , @pracID          bigint
  , @startEntryDate  datetime
  , @endEntryDate    datetime
  , @patID           bigint
  , @svcRecID        bigint )
      
returns table     
as    
    
/***************************************************************************    
 * SERVICE_RECORDS_TO_APPROVE_BY_PRAC_ID_AND_SVC_REC_ID_VIEW_DETAIL */    
/**    
 *     
 * @param  userID          User ID (Required)    
 * @param  userGroup       User group (Required)    
 * @param  userRank        User rank (Required)    
 * @param  clientID
 * @param  reviewingUserID
 * @param  pracID
 * @return                 Service records and svc notes
 ***************************************************************************/     
    
return (    
  
  select
    t1.*   
  from dbo.SERVICE_RECORDS_TO_APPROVE_BY_PRAC_ID_VIEW_CORE (
    @userID
  , @userGroup
  , @userRank
  , @clientID
  , @siteID
  , @approvingPracID
  , @pracID
  , @patID
  , @startEntryDate
  , @endEntryDate
  , 0    /* reviewed*/
  , null /* approved*/
  , null /* assigned */) as t1
  
  where (
        (1=1)
	and ((@svcRecID  is null) or (t1.svcRecID = @svcRecID))
	and ((@pracID    is null) or (t1.pracID   = @pracID))
	and ((@patID     is null) or (t1.patID    = @patID))
  )
)  
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[SERVICE_RECORDS_TO_APPROVE_BY_PRAC_ID_AND_SVC_REC_ID_VIEW_DETAIL] TO [webuser]
GO