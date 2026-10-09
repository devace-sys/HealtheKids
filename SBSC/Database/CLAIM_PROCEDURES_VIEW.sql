USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLAIM_PROCEDURES_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CLAIM_PROCEDURES_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[CLAIM_PROCEDURES_VIEW]    
(@userID       INT,    
 @userGroup    INT,    
 @userRank     INT, 
 @procCode     nchar(10),
 @procMod1     nchar(10), 
 @procMod2     nchar(10),
 @procMod3     nchar(10),
 @recID        INT,    
 @active       BIT,    
 @canEdit      BIT)    
 
 RETURNS TABLE AS
 
 /***************************************************************************    
  * CLAIM_PROCEDURES_VIEW */    
 /**    
  * Returns a table of CLAIMS_PROCEDURES that match the given parameters    
  *    
  * @param  userID          Callers user id    
  * @param  userGroup       Callers user group    
  * @param  userRank        Callers user rank     
  * @param  active          If procedure is active
  * @param  recID           record id    
  * @return                 Table of data    
  ***************************************************************************/     
  
RETURN

 (  select NO_PLAN_NAME                    AS noPlanNameID,
          IEP_IFSP_NAME                   AS IEP_IFSPNameID,
          PROCEDURE_ID                    AS id,
          PROCEDURE_CODE                  AS proccode,
          ISNULL(PROCEDURE_MODIFIER_1,'') AS procmod1,
          ISNULL(PROCEDURE_MODIFIER_2,'') AS procmod2,
          ISNULL(PROCEDURE_MODIFIER_3,'') AS procmod3,
          ISNULL(PROCEDURE_MODIFIER_3,'') AS procmod4,
          [PROCEDURE_NAME]                AS name,
          DATE_ADDED                      AS DATE_ADDED,
          DATE_MODIFIED                   AS DATE_MODIFIED,
          DATE_EFFECTIVE                  AS dateEffective,           
          DATE_EXPIRES                    AS dateExpires,
          IEP_REQUIRED                    AS IEPRequired,
          SERVICE_FEE                     AS svcFee,
          MAX_UNITS                       AS maxUnits,
          MAX_SERVICE_UNITS               AS maxSvcUnits,
          TCM_LOW_RATE                    AS TCMlowRate,
          TCM_MEDIUM_RATE                 AS TCMmedRate,
          TCM_HIGH_RATE                   AS TCMhighRate,
          OVER_17_FEE                     AS over17Fee,
          UNDER_18_FEE                    AS under18Fee,
          PAGE                            AS pageNum,
          DIAGNOSIS_CODE                  AS diagnosisCode,
          YEARLY_FLAG                     AS yearlyFlag,
          PUT_IN_837                      AS putIn837,
          COMBINE_INTO_PROXY              AS combIntoProxy,
          LINK_TO_SERVICE                 AS linkToSvc,
          cpe.ACTIVE                      AS active,
          cnp.NAME                        AS noPlanName,
          cie.NAME                        AS IEP_IFSPName 
     FROM      dbo.CLAIM_PROCEDURES      as cpe
     LEFT JOIN dbo.CLAIM_NoPlanNames     as cnp on cnp.NO_PLAN_NAME_ID  = cpe.NO_PLAN_NAME
     LEFT JOIN dbo.CLAIM_IEPandIFSPNames as cie on cie.IEP_IFSP_NAME_ID = cpe.IEP_IFSP_NAME
    where 
     ((@procCode is null) or (cpe.PROCEDURE_CODE like dbo.CREATE_NAME_PAT(@procCode))) and
     ((@procMod1 is null) or (isnull(cpe.PROCEDURE_MODIFIER_1,'') = isnull(@procMod1,''))) and
     ((@procMod2 is null) or (isnull(cpe.PROCEDURE_MODIFIER_2,'') = isnull(@procMod2,''))) and 
     ((@procMod3 is null) or (isnull(cpe.PROCEDURE_MODIFIER_3,'') = isnull(@procMod3,''))) and    
     ((@active   is null)  or (cpe.ACTIVE            = @active)) and 
     ((@recID    is null)  or (cpe.PROCEDURE_ID      = @recID)) 
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CLAIM_PROCEDURES_VIEW] TO [webuser]
GO
