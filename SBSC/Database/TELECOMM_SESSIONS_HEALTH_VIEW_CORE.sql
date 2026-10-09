USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.TELECOMM_SESSIONS_HEALTH_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION TELECOMM_SESSIONS_HEALTH_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[TELECOMM_SESSIONS_HEALTH_VIEW_CORE] (
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
  * TELECOMM_SESSIONS_HEALTH_VIEW_CORE */    
 /**    
  * Returns a table of session data
  *    
  * @return                 Table 
  ***************************************************************************/     
 
AS RETURN
( 
  select 
      ts.*
	  ,psd2.*
  from users.dbo.TELECOMM_SESSIONS_VIEW (@userID, @userGroup , @userRank, 'spedcare', @clientID, 2, @pracID, @active, @recID) as ts
  
  cross apply (
    select top 1
       psd1.*
    from dbo.TELECOMM_HEALTH_DESERIALIZE_PURPOSE_SPECIFIC_DATA (ts.purposeSpecificData) as psd1
  ) as psd2
)

GO

GRANT SELECT ON  [dbo].[TELECOMM_SESSIONS_HEALTH_VIEW_CORE] TO [webuser]
GO
