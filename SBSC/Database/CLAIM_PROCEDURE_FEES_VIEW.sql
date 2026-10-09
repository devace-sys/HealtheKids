USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLAIM_PROCEDURE_FEES_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CLAIM_PROCEDURE_FEES_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[CLAIM_PROCEDURE_FEES_VIEW]    
(@userID       INT,    
 @userGroup    INT,    
 @userRank     INT,   
 @recID        INT,     
 @procID       bigint,
 @procCode     nchar(10),
 @efctDate     DATETIME,
 @active       BIT,    
 @canEdit      BIT)   
 RETURNS TABLE as return(
 
 /***************************************************************************    
  * CLAIM_PROCEDURE_FEES_VIEW */    
 /**    
  * Returns a table of CLAIM_PROCEDURE_FEES_VIEW that match the given parameters    
  *    
  * @param  userID          Callers user id    
  * @param  userGroup       Callers user group    
  * @param  userRank        Callers user rank     
  * @param  procID          Required.  ID of procedure   
  * @param  efctDate        Effective date of the procedure fee   
  * @param  recID           record id    
  * @return                 Table of client data    
  ***************************************************************************/     
  
  select CPV.ID            AS procID,
         CPV.name          AS name,
         CPV.procCode      AS proccode,
         CPV.ProcMod1      AS procmod1,
         CPV.ProcMod2      AS procmod2,
         CPV.ProcMod3      AS procmod3,
         PF.FEE            AS fee,
         PF.Effective_Date As startDate,
         PF.ID             AS id,
         PF.active         AS active
    from procedure_fees PF join
         CLAIM_Procedures_view(@userID,@userGroup,@userRank,null,null,null,null,NULL,1,NULL) CPV -- GETTING ONLY ACTIVE PROCEDURES 
         ON CPV.ID = PF.PROCEDURE_ID
    where (1=1)
           and ((@procCode  is null) or (CPV.procCode    like dbo.CREATE_NAME_PAT(@procCode)))  
           and ((@efctDate  is null) or (PF.Effective_Date  = @efctDate))
           and ((@procID    is null) or (CPV.id             = @procID))
           and ((@active    is null) or (PF.ACTIVE          = @active)) 
           and ((@recID     is null) or (PF.ID              = @recID)) 
  )

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CLAIM_PROCEDURE_FEES_VIEW] TO [webuser]
GO
