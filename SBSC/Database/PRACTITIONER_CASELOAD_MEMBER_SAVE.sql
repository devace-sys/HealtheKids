/* TODO: This is being deprecated.  Make sure we remove all calls to this. */


USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTITIONER_CASELOAD_MEMBER_SAVE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.PRACTITIONER_CASELOAD_MEMBER_SAVE
GO


/*###########################################################################
 *#                                                                         #
 *#             !!!!!!!!!!!!!!!! NOTICE !!!!!!!!!!!!!!!!!!                  #
 *#                                                                         #
 *# The value of planType is NOT our standard values for planType           #
 *#                                                                         #
 *# In this context.....                                                    #
 *#                                                                         #
 *# 1 = IEP or IFSP, 2 = No Plan, 3 = CYBHI                                 #
 *#                                                                         #
 *# Everywhere else                                                         #
 *#                                                                         #
 *#  1 = IFSP, 2 = IEP, 3 = No Plan, 4 = CYBHI                              #
 *###########################################################################*/

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[PRACTITIONER_CASELOAD_MEMBER_SAVE]     
 (@userID        BIGINT,    
  @userGroup     INT,    
  @userRank      INT,    
  @clientID      BIGINT,    
  @pracID        BIGINT,    
  @patID         BIGINT,  
  @minsInd       INT,
  @minsGrp       INT,
  @minsAnn       INT,
  @startDateTmtSvcs     DATE,
  @planType      INT,
  @weekDaysJSON  VARCHAR(max),
  @promisedSvcStartDate Date,
  @promisedSvcEndDate   Date,  
  @promisedSvcCode   Int,    
  @orpDocID		 bigint,
  @editDelReason VARCHAR(7000),    
  @validateRec   BIT,    
  @saveType      INT,    
  @recID         INT,    
  @MsgNoRec      VARCHAR(1000),    
  @MsgNoEdit     VARCHAR(1000), 
  @MsgDupRec     VARCHAR(1000),     
  @MsgDataError  VARCHAR(1000),
  @MsgNotActive  VARCHAR(1000),     
  @spDetails     VARCHAR(8000) OUTPUT,    
  @recordID      BIGINT        OUTPUT)    
AS    
BEGIN     
    
/***************************************************************************    
 * PRACTITIONER_CASELOAD_MEMBER_SAVE */    
/**    
 * Creates a new caseload record or edits an exiting one
 *    
 * @param   userID          The userid of who saved the record    
 * @param   userGroup       Users group    
 * @param   userRank        User rank    
 * @param   clientID        Client id    
 * @param   pracID          Practitioner id
 * @param   patID           Patient id
 * @param   minsInd
 * @param   minsGrp
 * @param   minsAnn
 * @param   startDateTmtSvcs
 * @param   planType
 * @param   weekDaysJSON
 * @param   editDelReason   Reason for record edit or delete    
 * @param   validateRec     1 = Performs data integrity validation tasks    
                                Perform advisory validation tasks that can    
 *                              only be conducted by referencing data from the    
 *                              database and then exits WITHOUT saving the record    
 *                          0 = Peform data integrity validation tasks and    
 *                              if these tasks succeed peforms the desired    
 *                              operation (saveType) on the record and exits    
 * @param   saveType        Type of operation to perform    
 *                          1 = New, 2 = Edit, 3 = Delete    
 * @param   recID           Record id of existing patient record to edit or    
 *                          delete.    
 * @param   MsgNoRec        Desired error message if a recID is not found    
 * @param   MsgNoEdit       Desired error message if a record cannot be edited    
 * @param   MsgDupRec       Desired error message for duplicate detection    
 * @param   MsgNoClient     Desired error message if a clientID is not found    
 * @param   MsgNoSite       Desired error message if a siteID is not found     
 * @param   MsgDataError    Desired error message for data errors    
 * @returns spDetails       Validation or error details    
 * @returns recordID        New record id or record id of service record that    
 *                          was changed or deleted     
 ***************************************************************************/         
     
SET NOCOUNT ON    

DECLARE @TranOpen                 as BIT  = 0
declare @groupID                  as bigint
declare @pracGrpSvcClsNameID      as bigint
declare @clientIdOut              as bigint
declare @pracIdOut                as bigint
declare @patIdOut                 as bigint

BEGIN TRY    
    
/*-------------------------------    
 * Init our output parameters    
 *------------------------------*/    
    
SET @spDetails  = ''    
SET @recordID = 0 
set @TranOpen = 0

IF (@userID      IS NULL) RAISERROR ('userID is required',   11, 1)      
IF (@userGroup   IS NULL) RAISERROR ('userGroup is required',   11, 1)    
IF (@userRank    IS NULL) RAISERROR ('userRank is required',    11, 1)    
IF (@validateRec IS NULL) RAISERROR ('Validate flag required',  11, 1)    
IF (@saveType    IS NULL) RAISERROR ('Save type is required',   11, 1)    
					     

/*-------------------------------    
 * Validation    
 *------------------------------*/    
        
IF (@validateRec = 1) 
BEGIN    
  SET @recordID = 0
  RETURN(0)    
END        
    
/***************************************************************************    
 *                        Manage caseload data                             *
 ***************************************************************************/         

BEGIN TRANSACTION    
    
SET @TranOpen = 1    
        
exec dbo.PRACTITIONER_CASELOAD_MEMBER_Save_Core 
    @userID
  , @clientID
  , @pracID
  , @patID
  , @planType
  , @promisedSvcCode
  , @orpDocID
  , @promisedSvcStartDate
  , @promisedSvcEndDate
  , null
  , null
  , @minsInd
  , @minsGrp
  , @weekDaysJSON
  , 1
  , @validateRec
  , @clientIdOut         output
  , @pracIdOut           output
  , @patIdOut            output
  , @groupID             output
  , @pracGrpSvcClsNameID output
  , @recordID            output

/*-------------------------------    
 * If we reach this point    
 * everything is OK, commit our    
 * changes and exit    
 *------------------------------*/    
    
COMMIT TRANSACTION    
SET @TranOpen = 0    
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
       
  -- Error or raise error with severity 11 to 19 will be caught here    
      
  IF @tranOpen = 1 ROLLBACK TRANSACTION    
      
  DECLARE @ErrorMessage  AS NVARCHAR(4000)    
  DECLARE @ErrorSeverity AS INT    
  DECLARE @ErrorState    AS INT    
      
  SELECT  @ErrorMessage  = ERROR_MESSAGE(),    
          @ErrorSeverity = ERROR_SEVERITY(),    
          @ErrorState    = ERROR_STATE()    
   
   if (@ErrorSeverity > 11)    
     SET @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ']'    
      
  -- Reraise the error so it returns back to the server    
      
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
    
END CATCH    
END    
    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[PRACTITIONER_CASELOAD_MEMBER_SAVE] TO [webuser]
GO
