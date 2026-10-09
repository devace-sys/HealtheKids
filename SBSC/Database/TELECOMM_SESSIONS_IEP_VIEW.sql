USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.TELECOMM_SESSIONS_IEP_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION TELECOMM_SESSIONS_IEP_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[TELECOMM_SESSIONS_IEP_VIEW] (
    @userID              BIGINT
  , @userGroup           INT    
  , @userRank            INT 
  , @clientID            bigint
  , @patID               bigint
  , @active              bit
  , @recID               bigint
 )    
 
RETURNS TABLE
 
 /***************************************************************************    
  * TELECOMM_SESSIONS_IEP_VIEW */    
 /**    
  * Returns a table of session data
  *    
  * @return                 Table 
  ***************************************************************************/     
 
AS RETURN
( 
  select top (dbo.CONST_MAX_ROWS())
    tsivc.* 
  from dbo.TELECOMM_SESSIONS_IEP_VIEW_CORE (@userID, @userGroup, @userRank, @clientID, @patID, @active, @recID) as tsivc
  order by
      tsivc.meetingDate
	, tsivc.meetingTime
)

GO

GRANT SELECT ON  [dbo].[TELECOMM_SESSIONS_IEP_VIEW] TO [webuser]
GO
