USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.TELECOMM_SESSIONS_IEP_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION TELECOMM_SESSIONS_IEP_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[TELECOMM_SESSIONS_IEP_VIEW_CORE] (
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
  * TELECOMM_SESSIONS_IEP_VIEW_CORE */    
 /**    
  * Returns a table of session data
  *    
  * @return                 Table 
  ***************************************************************************/     
 
AS RETURN
( 
  select 
      ts.*
	, psd2.patID
	, patName = pap.CONCAT_NAME
	, psd2.iepFormType
	, iepFormTypeName = tit.name
  from users.dbo.TELECOMM_SESSIONS_VIEW (@userID, @userGroup , @userRank, 'spedcare', @clientID,3,null,@active, @recID) as ts
  
  cross apply (
    select top 1
       psd1.patID  
	  ,psd1.iepFormType
    from dbo.TELECOMM_IEP_DESERIALIZE_PURPOSE_SPECIFIC_DATA (ts.purposeSpecificData) as psd1
  ) as psd2
  
  join dbo.TELECOMM_IEP_TYPES as tit on tit.id         = psd2.iepFormType
  join dbo.PATIENTS_PATIENT   as pap on pap.PATIENT_ID = psd2.patID

  where (        
        (1=1)
    and ((@patID is null) or (psd2.patID  = @patID))
  )
)

GO

GRANT SELECT ON  [dbo].[TELECOMM_SESSIONS_IEP_VIEW_CORE] TO [webuser]
GO
