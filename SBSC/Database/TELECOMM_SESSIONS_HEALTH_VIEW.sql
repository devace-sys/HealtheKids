USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.TELECOMM_SESSIONS_HEALTH_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION TELECOMM_SESSIONS_HEALTH_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[TELECOMM_SESSIONS_HEALTH_VIEW] (
    @userID              BIGINT
  , @userGroup           INT    
  , @userRank            INT 
  , @clientID            bigint
  , @pracID              bigint
  , @active              bit
  , @recID               bigint
 )    
 
RETURNS TABLE
 
 /***************************************************************************    
  * TELECOMM_SESSIONS_HEALTH_VIEW */    
 /**    
  * Returns a table of session data
  *    
  * @return                 Table 
  ***************************************************************************/     
 
AS RETURN
( 
  
  select top (dbo.CONST_MAX_ROWS()) 
    tshvc.*
  from dbo.TELECOMM_SESSIONS_HEALTH_VIEW_CORE (@userID,@userGroup,@userRank,@clientID,@pracID,@active,@recID) as tshvc
   order by
      tshvc.meetingDate
	, tshvc.meetingTime
)

GO

GRANT SELECT ON  [dbo].[TELECOMM_SESSIONS_HEALTH_VIEW] TO [webuser]
GO
