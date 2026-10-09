USE SPEDMON
GO

/*-------------------------------
 * Exists drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLIENT_GROUP_SERVICE_CLASS_NAME_SPECIFIC_PRACTICE_RULES_UPDATE_RULE_SET') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.CLIENT_GROUP_SERVICE_CLASS_NAME_SPECIFIC_PRACTICE_RULES_UPDATE_RULE_SET
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 

CREATE PROCEDURE dbo.CLIENT_GROUP_SERVICE_CLASS_NAME_SPECIFIC_PRACTICE_RULES_UPDATE_RULE_SET( 
    @userID        BIGINT
  , @userGroup     INT  
  , @userRank      INT    
  , @editDelReason VARCHAR(7000)
  , @validateRec   BIT
  , @clientID      BIGINT
  , @recID         BIGINT   
  , @departmentHeadsCanViewSupervisedPracsPrivateNotes                             bit
  , @departmentHeadsCanViewSupervisedPracsStoredFiles                              bit
  , @departmentHeadsCanViewSupervisedPracsSvcRecs                                  bit
  , @onlyDepartmentHeadsCanManageDirectSupervisionAssignments                      bit
  , @departmentHeadsCanOnlyViewSupervisedPracsDataInTheirReportingGroup            bit
  , @departmentHeadsCanOnlyManageDirectSupervisionAssignmentsInTheirReportingGroup bit
  , @supervisingAndSupervisedPracsMustBeInSameReportingGroup                       bit
  , @departmentHeadsCanViewAllPracDataInTheirReportingGroup                        bit
  , @MsgNoRec      VARCHAR(1000)    
  , @MsgNoEdit     VARCHAR(1000)    
  , @spDetails     VARCHAR(8000) OUTPUT    
  , @recordID      BIGINT        OUTPUT)   

AS
BEGIN

/***************************************************************************    
 * CLIENT_GROUP_SERVICE_CLASS_NAME_SPECIFIC_PRACTICE_RULES_UPDATE_RULE_SET */ 
/**    
 * Update flag set
 *    
 ***************************************************************************/     

SET NOCOUNT ON    

DECLARE @today           AS DATETIME -- Current date/time stamp    
DECLARE @TranOpen        AS BIT = 0

BEGIN TRY    

/*============================================================
 * Init
 *============================================================*/     
   
SET @today       = GETDATE()    
SET @recordID    = 0    
SET @spDetails   = ''    
SET @TranOpen    = 0

/*============================================================
 * Verify incoming parameters that are essential for proper op
 *============================================================*/  
    
IF (@userID          IS NULL) RAISERROR ('userID is required',         11, 1)
IF (@userGroup       IS NULL) RAISERROR ('userGroup is required',      11, 1)    
IF (@userRank        IS NULL) RAISERROR ('userRank is required',       11, 1)    
IF (@validateRec     IS NULL) RAISERROR ('Validate flag required',     11, 1)    
IF (@clientID        IS NULL) RAISERROR ('Client id is required',      11, 1)
IF (@recID           IS NULL) RAISERROR ('Record id is required',      11, 1)

/*============================================================
 * Set defaults
 *============================================================*/  

set @departmentHeadsCanViewSupervisedPracsPrivateNotes        = isnull(@departmentHeadsCanViewSupervisedPracsPrivateNotes        ,0)
set @departmentHeadsCanViewSupervisedPracsStoredFiles         = isnull(@departmentHeadsCanViewSupervisedPracsStoredFiles         ,0)
set @departmentHeadsCanViewSupervisedPracsSvcRecs             = isnull(@departmentHeadsCanViewSupervisedPracsSvcRecs             ,0)
set @onlyDepartmentHeadsCanManageDirectSupervisionAssignments = isnull(@onlyDepartmentHeadsCanManageDirectSupervisionAssignments ,0)

set @departmentHeadsCanOnlyViewSupervisedPracsDataInTheirReportingGroup            = isnull(@departmentHeadsCanOnlyViewSupervisedPracsDataInTheirReportingGroup,            0)
set @departmentHeadsCanOnlyManageDirectSupervisionAssignmentsInTheirReportingGroup = isnull(@departmentHeadsCanOnlyManageDirectSupervisionAssignmentsInTheirReportingGroup, 0)
set @supervisingAndSupervisedPracsMustBeInSameReportingGroup                       = isnull(@supervisingAndSupervisedPracsMustBeInSameReportingGroup,                       0)
set @departmentHeadsCanViewAllPracDataInTheirReportingGroup                        = isnull(@departmentHeadsCanViewAllPracDataInTheirReportingGroup,                        0)

/*============================================================
 * Find record
 *============================================================*/  

select top 1 
  @recordID = isnull(t1.id,0)
from dbo.CLIENT_GROUP_SERVICE_CLASS_NAME_SPECIFIC_PRACTICE_RULES as t1
where (
      (t1.id       = @recID)
  and (t1.clientID = @clientID)
  and (t1.active   = 1 )
)

/*============================================================
 * If not found get out
 *============================================================*/  

if (@recordID = 0)
begin
  RAISERROR (@MsgNoRec,11,1)
end

/*============================================================
 * If validating get out
 *============================================================*/  

if (@validateRec = 1) return(0)

/*============================================================
 * Begin a transaction
 *============================================================*/  

BEGIN TRANSACTION    
SET @TranOpen  = 1 

/*============================================================
 * Update rules
 *============================================================*/  

update dbo.CLIENT_GROUP_SERVICE_CLASS_NAME_SPECIFIC_PRACTICE_RULES
set 
    departmentHeadsCanViewSupervisedPracsPrivateNotes                             = @departmentHeadsCanViewSupervisedPracsPrivateNotes
  , departmentHeadsCanViewSupervisedPracsStoredFiles                              = @departmentHeadsCanViewSupervisedPracsStoredFiles
  , departmentHeadsCanViewSupervisedPracsSvcRecs                                  = @departmentHeadsCanViewSupervisedPracsSvcRecs
  , onlyDepartmentHeadsCanManageDirectSupervisionAssignments                      = @onlyDepartmentHeadsCanManageDirectSupervisionAssignments
  , departmentHeadsCanOnlyViewSupervisedPracsDataInTheirReportingGroup            = @departmentHeadsCanOnlyViewSupervisedPracsDataInTheirReportingGroup
  , departmentHeadsCanOnlyManageDirectSupervisionAssignmentsInTheirReportingGroup = @departmentHeadsCanOnlyManageDirectSupervisionAssignmentsInTheirReportingGroup
  , supervisingAndSupervisedPracsMustBeInSameReportingGroup                       = @supervisingAndSupervisedPracsMustBeInSameReportingGroup
  , departmentHeadsCanViewAllPracDataInTheirReportingGroup                        = @departmentHeadsCanViewAllPracDataInTheirReportingGroup

where 
  (id = @recordID)

/*============================================================
 * End transaction
 *============================================================*/     

IF (@TranOpen = 1) 
begin
  COMMIT TRANSACTION    
  SET @TranOpen = 0 
end

RETURN(0)    

END TRY    
   
BEGIN CATCH    
   
  /*-------------------------------    
   * If we end up here something    
   * went wrong.  Cancel any pending    
   * transactions and return any    
   * error any error messages to    
   * the caller    
   *------------------------------*/    
 
  IF @tranOpen = 1 ROLLBACK TRANSACTION    

  -- Error or raise error with severity 11 to 19 will be caught here    
      
  DECLARE @ErrorMessage  AS NVARCHAR(4000)    
  DECLARE @ErrorSeverity AS INT    
  DECLARE @ErrorState    AS INT    
     
  SELECT  @ErrorMessage  = ERROR_MESSAGE(),    
          @ErrorSeverity = ERROR_SEVERITY(),    
          @ErrorState    = ERROR_STATE()    
   
  --SET @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ']'    
   
  -- Reraise the error so it returns back to the server    
   
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
   
END CATCH    
END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[CLIENT_GROUP_SERVICE_CLASS_NAME_SPECIFIC_PRACTICE_RULES_UPDATE_RULE_SET] TO [webuser]
GO

