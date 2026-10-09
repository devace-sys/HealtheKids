USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_VIEW_KNOWN_BICS') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PATIENT_VIEW_KNOWN_BICS
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[PATIENT_VIEW_KNOWN_BICS] ( @patID bigint )
RETURNS 
TABLE 
AS
RETURN 
(


/* Note: The bic is being resized to VARCHAR(255) to leave open the possibility of using medical record ids from
 * other payers at a future date */

  select top 1 
      pap.PATIENT_ID
    , BIC = convert(varchar(255),pap.BIC)
  from dbo.PATIENTS_Patient as pap where PATIENT_ID = @patID

  union

  select 
      pba.PATIENT_ID
    , BIC = convert(varchar(255),pba.ARCHIVED_BIC )
  from dbo.PATIENT_BIC_ARCHIVE as pba where pba.PATIENT_ID = @patID
  
  union

  select distinct
     clm.PATIENT_ID
   , BIC = i835.[patient_bic_(2100_0300_NM1_109)]
  from dbo.CLAIM_Claim            as clm
  join dbo.[Import_From_837]      as i837    on i837.claim_id = clm.CLAIM_ID 
  join dbo.[Import_From_835_DS_002_Claim_Level_Claim_Payment_Info_Patient_Name_Claim_Dates] as i835 on i835.[claim_submitter_claim_tracking_id_(2100_0100_CLP_CLP01)] = i837.[claim_info_claim_submitter_claim_tracking_id (2300 1300 CLM CLM01)]

  where (clm.PATIENT_ID = @patID)

)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PATIENT_VIEW_KNOWN_BICS] TO [webuser]
GO   
