USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_RECORD_VIEW_SVC_NOTE_UNFORMATTED_NOTE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SERVICE_RECORD_VIEW_SVC_NOTE_UNFORMATTED_NOTE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[SERVICE_RECORD_VIEW_SVC_NOTE_UNFORMATTED_NOTE] (
    @userID        as   bigint
  , @userGroup     as   int  
  , @userRank      as   int    
  , @clientID      as   bigint
  , @pracID        as   bigint
  , @patID         as   bigint
  , @recID         as   bigint
)    
returns table     
as    
    
/***************************************************************************    
 * SERVICE_RECORD_VIEW_SVC_NOTE_UNFORMATTED_NOTE */    
/**    
 *     
 * @param  userID          User ID (Required)    
 * @param  userGroup       User group (Required)    
 * @param  userRank        User rank (Required)    
 * @return                 Service records and svc notes
 ***************************************************************************/     
    
return (    

select top 1 
    id       = sr.id
  , svcRecID = sr.id
  , noteText = ltrim(rtrim(isnull(sr.notes,'')))
from dbo.SERVICE_RECORDS as sr
where  
  ((sr.id  = @recID)
  and  ((@clientID is null) or (sr.clientID  = @clientID))
  and  ((@pracID   is null) or (sr.pracID    = @pracID))
  and  ((@patID    is null) or (sr.patID     = @patID)))
  
)  
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[SERVICE_RECORD_VIEW_SVC_NOTE_UNFORMATTED_NOTE] TO [webuser]
GO