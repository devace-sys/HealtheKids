USE SPEDMON
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_DIAGNOSES_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PATIENT_DIAGNOSES_VIEW
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[PATIENT_DIAGNOSES_VIEW] (
    @userID                BIGINT    
  , @userGroup             INT    
  , @userRank              INT
  , @clientID			   bigint
  , @patID				   bigint
  , @recID                 bigint    
  , @canEdit               bit
  , @active                BIT
)
    
returns table     
as
 
return 
(    

select top (dbo.CONST_MAX_ROWS())  
    pd.*
  , diagnosisName   = icd10.code + ' - ' + icd10.[name]
  , icd10CMCodeName = icd10.[name]
  , icd10CMCode     = icd10.[code]  
  
from dbo.PATIENT_DIAGNOSES as pd
join dbo.ICD_10_CM_CODES   as icd10 on icd10.id = pd.diagnosisID

where (   
      (1=1)
  and (pd.clientID = @clientID)
  and (pd.patID    = @patID)
  and (pd.active   = 1)
  and ((@recID  is null) or (pd.id = @recID))
)
order by 
  pd.id desc /* Temporary until we get the diagnosis table done */

)
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PATIENT_DIAGNOSES_VIEW] TO [webuser]
GO