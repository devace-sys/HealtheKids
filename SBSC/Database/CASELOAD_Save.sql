USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CASELOAD_Save') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.CASELOAD_Save
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[CASELOAD_Save]     
 (@userID        BIGINT,    
  @userGroup     INT,    
  @userRank      INT,    
  @clientID      INT,    
  @pracID        INT,    
  @patID         INT,  
  @startDate     DATETIME,
  
  @asmtDueAnn    DATETIME,
  @asmtDueTriAnn DATETIME,

  @tmtEffDate DATETIME,
  
  @tmtFrqInd2 INT,
  @tmtDurInd2 INT,
  @tmtFrqGrp2 INT,
  @tmtDurGrp2 INT,

  @tmtFrqInd3 INT,
  @tmtDurInd3 INT,
  @tmtFrqGrp3 INT,
  @tmtDurGrp3 INT,

  @tmtFrqInd4 INT,
  @tmtDurInd4 INT,
  @tmtFrqGrp4 INT,
  @tmtDurGrp4 INT,

  @tmtFrqInd5 INT,
  @tmtDurInd5 INT,
  @tmtFrqGrp5 INT,
  @tmtDurGrp5 INT,

  @tmtFrqInd6 INT,
  @tmtDurInd6 INT,
  @tmtFrqGrp6 INT,
  @tmtDurGrp6 INT,
  
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
 * CASELOAD_SAVE */    
/**    
 * Creates a new caseload record or edits an exiting one
 *    
 * @param   userID          The userid of who saved the record    
 * @param   userGroup       Users group    
 * @param   userRank        User rank    
 * @param   clientID        Client id    
 * @param   pracID          Practitioner id
 * @param   patID           Patient id
 * @param   startDate       Relationship start
 * @param   endDate         Relationship end
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

DECLARE @TranOpen            AS BIT  
DECLARE @tempRecID           AS BIGINT           -- Used for determining if a rec exists    
DECLARE @tempActive          AS BIT
DECLARE @reactivate          AS BIT
DECLARE @reactivateID        AS BIGINT
DECLARE @startDateInUse      AS BIT
DECLARE @recCount            AS INT
DECLARE @tempSvcStartDate    as DATETIME
DECLARE @tempSvcEndDate      as DATETIME
DECLARE @tempRecCount        as INT
DECLARE @testDate1           as DATETIME 
DECLARE @testDate2           as DATETIME 
DECLARE @editSvcSchRec       as INT
DECLARE @today               as DATETIME
DECLARE @updateState         AS SMALLINT         -- Indicates what state the record is left in    
DECLARE @pracPatSvcSchRecID  AS BIGINT
DECLARE @pracPatDatesRecID   AS BIGINT
DECLARE @auditRecID          AS BIGINT
DECLARE @tempTmpTmtSchStr    AS VARCHAR(1000)
DECLARE @hasTmtSch           AS BIT
DECLARE @hasEffDate          AS BIT

BEGIN TRY    
    
/*-------------------------------    
 * Init our output parameters    
 *------------------------------*/    
    
SET @spDetails  = ''    
SET @recordID = NULL 
SET @today    = GETDATE()

/*-------------------------------    
 * Set defaults
 *------------------------------*/  

if @tmtFrqInd2 <= 0 set @tmtFrqInd2 = null
if @tmtDurInd2 <= 0 set @tmtDurInd2 = null
if @tmtFrqGrp2 <= 0 set @tmtFrqGrp2 = null
if @tmtDurGrp2 <= 0 set @tmtDurGrp2 = null

if @tmtFrqInd3 <= 0 set @tmtFrqInd3 = null
if @tmtDurInd3 <= 0 set @tmtDurInd3 = null
if @tmtFrqGrp3 <= 0 set @tmtFrqGrp3 = null
if @tmtDurGrp3 <= 0 set @tmtDurGrp3 = null

if @tmtFrqInd4 <= 0 set @tmtFrqInd4 = null
if @tmtDurInd4 <= 0 set @tmtDurInd4 = null
if @tmtFrqGrp4 <= 0 set @tmtFrqGrp4 = null
if @tmtDurGrp4 <= 0 set @tmtDurGrp4 = null

if @tmtFrqInd5 <= 0 set @tmtFrqInd5 = null
if @tmtDurInd5 <= 0 set @tmtDurInd5 = null
if @tmtFrqGrp5 <= 0 set @tmtFrqGrp5 = null
if @tmtDurGrp5 <= 0 set @tmtDurGrp5 = null

if @tmtFrqInd6 <= 0 set @tmtFrqInd6 = null
if @tmtDurInd6 <= 0 set @tmtDurInd6 = null
if @tmtFrqGrp6 <= 0 set @tmtFrqGrp6 = null
if @tmtDurGrp6 <= 0 set @tmtDurGrp6 = null

/*-------------------------------    
 * Verify all parameters that    
 * indicate what type of operation    
 * to perform have been passed in    
 * and any other parms that are    
 * neccessary for proper operation    
 *------------------------------*/    

IF (@userID      IS NULL) RAISERROR ('userID is required',   11, 1)      
IF (@userGroup   IS NULL) RAISERROR ('userGroup is required',   11, 1)    
IF (@userRank    IS NULL) RAISERROR ('userRank is required',    11, 1)    
IF (@validateRec IS NULL) RAISERROR ('Validate flag required',  11, 1)    
IF (@saveType    IS NULL) RAISERROR ('Save type is required',   11, 1)    
IF (@startDate   IS NULL) RAISERROR ('Start date is required',  11, 1)                                    

/*-------------------------------    
 * Verify client, practitioner,
 * and patient ids
 *------------------------------*/   

SET @recCount = null

select 
  @recCount = COUNT(cc.CLIENT_ID)  
from CLIENTS_Client      as cc
join PRACTITIONER_Client as prc on prc.CLIENT_ID = cc.CLIENT_ID
join PATIENTS_Client     as pac on pac.CLIENT_ID = cc.CLIENT_ID
where (cc.CLIENT_ID        = @clientID) and
      (prc.PRACTITIONER_ID = @pracID)   and
      (pac.PATIENT_ID      = @patID)
      
if (@recCount != 1)
  RAISERROR ('Invalid client, practitioner, or patient id', 11, 1) 

/*-------------------------------    
 * If this is a new record
 *------------------------------*/    

if (@saveType = dbo.CONST_SAVE_TYPE_NEW())
begin

  /*-------------------------------    
   * See if a record already 
   * exists
   *------------------------------*/    
     
  select 
    @tempRecID  = ID,
    @tempActive = ACTIVE
  from [PRACTITIONER_PATIENTS] 
  where 
    [CLIENT_ID]       = @clientID and 
    [PRACTITIONER_ID] = @pracID   and 
    [PATIENT_ID]      = @patID

  /*-------------------------------    
   * If a record like it already
   * exists
   *------------------------------*/    

  if (@tempRecID is not null) 
  begin

    /*-------------------------------    
     * If the record is active let
     * the user know and exit
     *------------------------------*/    
   
    if (@tempActive = 1)
    begin
      set @reactivate   = 0
      set @reactivateID = null
      RAISERROR (@MsgDupRec, 11, 1) 
    end
    else
  
    /*-------------------------------    
     * If the record is not active
     * we want to reactivate it
     *------------------------------*/    

    begin
      set @reactivate   = 1
      set @reactivateID = @tempRecID
    end
  
  end

  /*-------------------------------    
   * No record exists
   *------------------------------*/    

  else
  begin
    
    set @reactivate   = 0
    set @reactivateID = null
  end

end

/*-------------------------------    
 * Edit
 *------------------------------*/    

else if (@saveType = dbo.CONST_SAVE_TYPE_EDIT())
begin

  set @recordID = @recID
  
  /*-------------------------------    
   * Make sure record exists and
   * get record ids
   *------------------------------*/    
  
  set @tempRecID = null
     
  select 
     @tempRecID          = ID,
     @pracPatSvcSchRecID = [CUR_PRAC_PAT_SVC_SCH_ID],
     @pracPatDatesRecID  = [CUR_PRAC_PAT_DATES_ID]
  from [PRACTITIONER_PATIENTS] 
  where ID = @recID

  /*-------------------------------    
   * If no record exists get out
   *------------------------------*/    

  if (@tempRecID is null)
   RAISERROR (@MsgNoRec, 11, 1)
  
  /*-------------------------------    
   * See if effective date has
   * changed
   *------------------------------*/ 
   
   set    @tempRecID = null    
   select @testDate1 = dbo.DATE_ONLY(TmtEffectiveDate), @tempRecID = ID from PRACTITIONER_PATIENTS_SERVICE_SCHEDULE where ID = @pracPatSvcSchRecID
   set    @testDate2 = dbo.DATE_ONLY(@tmtEffDate)
   set    @editSvcSchRec = 1
 
   if (@tempRecID is null)                RAISERROR (@MsgDataError, 11, 1)   
   if (@tempRecID != @pracPatSvcSchRecID) RAISERROR (@MsgDataError, 11, 1)
   
   /*-------------------------------    
    * User entered nothing before
    * and still has entered nothing
    *------------------------------*/ 

   if ((@testDate1 is null) and (@testDate2 is null))
   begin
     set @editSvcSchRec = 1 -- Edit existing
   end
   
   /*-------------------------------   
    * User entered nothing before
    * but now has entered something
    *------------------------------*/ 

   else if ((@testDate1 is null) and (@testDate2 is not null))
   begin
     set @editSvcSchRec = 1 -- Edit existing
   end
   
   /*-------------------------------   
    * User entered something before
    * but now is wanting to change
    * this to nothing
    *------------------------------*/ 

   else if ((@testDate1 is not null) and (@testDate2 is null))
   begin
     set @editSvcSchRec = 0 -- Insert new
   end
   
   /*-------------------------------   
    * User entered something before
    * and is wanting to change this
    * to something else
    *------------------------------*/ 

   else if ((@testDate1 is not null) and (@testDate2 is not null))
   begin
   
     if (@testDate1 = @testDate2)
       set @editSvcSchRec = 1 -- Edit existing
     else
       set @editSvcSchRec = 0 -- Insert new
   end

end


/*-------------------------------    
 * Peform tests that are common
 * for both new records and
 * edits
 *------------------------------*/ 

if (@saveType != dbo.CONST_SAVE_TYPE_DELETE())
begin
  
  /*-------------------------------    
   * Test treatment schedule
   * The user can provide either
   * 
   * a null 
   *   effective date 
   *   + schedule  
   * 
   * or
   * 
   * a defined 
   *   effective date
   *   + schedule 
   *  
   * If either combo is partially
   * defined, the user gets a 
   * warning
   *-----------------------------*/   

  set @tempTmpTmtSchStr = dbo.RPT_TMT_SCHEDULE(@tmtFrqInd2,
                                               @tmtDurInd2,
                                               @TmtFrqGrp2,
                                               @TmtDurGrp2,
     
                                               @tmtFrqInd3,
                                               @tmtDurInd3,
                                               @tmtFrqGrp3,
                                               @tmtDurGrp3,

                                               @tmtFrqInd4,
                                               @tmtDurInd4,
                                               @tmtFrqGrp4,
                                               @tmtDurGrp4,

                                               @tmtFrqInd5,
                                               @tmtDurInd5,
                                               @tmtFrqGrp5,
                                               @tmtDurGrp5,

                                               @tmtFrqInd6,
                                               @tmtDurInd6,
                                               @tmtFrqGrp6,
                                               @tmtDurGrp6)


  if (@tempTmpTmtSchStr <> '') set @hasTmtSch = 1
  else                         set @hasTmtSch = 0

  if (@tmtEffDate is null)     set @hasEffDate = 0
  else                         set @hasEffDate = 1
  
  
  if (@hasTmtSch = 0)
  begin
    if (@hasEffDate = 1) RAISERROR ('You have provided an effective date but no treatment schedule', 11, 1) 
  end
  else
  begin
    if (@hasEffDate = 0)          RAISERROR ('You have provided a treatment schedule but no effective date', 11, 1) 
    if (@tmtEffDate < @startDate) RAISERROR ('The effective date cannot be before the IEF/IFSP services start date (Caseload start date)', 11, 1) 
  end

end

/*-------------------------------    
 * Validation    
 *------------------------------*/    
        
IF (@validateRec = 1) 
BEGIN    
  SET @recordID = 0
  RETURN(0)    
END        

/*-------------------------------    
 * Create or modify our     
 * caseload records
 *------------------------------*/    
    
BEGIN TRANSACTION    
    
  SET @TranOpen = 1    
        
  /*==============================    
   * New Record
   *
   * We are either establishing a 
   * new or renewing a past 
   * relatioship between practitioner
   * and patient
   *==============================*/    
  
  IF (@saveType = dbo.CONST_SAVE_TYPE_NEW())    
  BEGIN       
       
    if (@reactivate = 0)
    BEGIN
          
      /*-------------------------------    
       * This is a brand new 
       * relationship between this 
       * practitioner and patient.
       *
       * No relationship has existed
       * between these two entities
       * before.
       *------------------------------*/  

      SET @updateState = dbo.CONST_REC_STATE_NEW()

      INSERT INTO dbo.PRACTITIONER_PATIENTS
        (CLIENT_ID, 
         PRACTITIONER_ID, 
         PATIENT_ID,         
         CREATED_BY,
         CREATED_ON,
         LAST_MODIFIED_BY,
         LAST_MODIFIED_ON,         
         ACTIVE,
         CUR_PRAC_PAT_SVC_SCH_ID,
         CUR_PRAC_PAT_DATES_ID)    
      VALUES    
        (@clientID, 
         @pracID, 
         @patID, 
         @userID,
         @today,
         @userID,
         @today,
         1,
         0,
         0)  
 
      SET @recordID = SCOPE_IDENTITY()
                         
   END  
   ELSE IF (@reactivate = 1)
   BEGIN
     
     /*-------------------------------    
      * This is a past relationship
      * between this practitioner and 
      * patient that is being 
      * reestablished
      *------------------------------*/  
      
      SET @recordID    = @reactivateID
      SET @updateState = dbo.CONST_REC_STATE_MOD()
      
      UPDATE dbo.PRACTITIONER_PATIENTS
      SET 
        ACTIVE           = 1,
        LAST_MODIFIED_BY = @userID,
        LAST_MODIFIED_ON = @today      
      WHERE 
        ID = @recordID         
   END   
   ELSE 
   BEGIN
     RAISERROR ('Dont know what to do', 11, 1)  
   END
   
   /*-------------------------------    
    * Asmts and recurring service
    * schedule
    *------------------------------*/     
   
   INSERT INTO dbo.PRACTITIONER_PATIENTS_SERVICE_SCHEDULE (
     PRAC_PAT_ID,             
     
     AsmtDueAnn,
     AsmtDueTriAnn,         
     TmtEffectiveDate,
     
     TmtFrqInd1,
     TmtDurInd1,
     TmtFrqGrp1,
     TmtDurGrp1,

     TmtFrqInd2,
     TmtDurInd2,
     TmtFrqGrp2,
     TmtDurGrp2,

     TmtFrqInd3,
     TmtDurInd3,
     TmtFrqGrp3,
     TmtDurGrp3,

     TmtFrqInd4,
     TmtDurInd4,
     TmtFrqGrp4,
     TmtDurGrp4,

     TmtFrqInd5,
     TmtDurInd5,
     TmtFrqGrp5,
     TmtDurGrp5,

     TmtFrqInd6,
     TmtDurInd6,
     TmtFrqGrp6,
     TmtDurGrp6,
         
     TmtFrqInd7,
     TmtDurInd7,
     TmtFrqGrp7,
     TmtDurGrp7
   )
   VALUES(
     
     @recordID, 
       
     @asmtDueAnn,
     @asmtDueTriAnn,
     @tmtEffDate,
     
     null,
     null,
     null,
     null,
          
     @tmtFrqInd2,
     @tmtDurInd2,
     @tmtFrqGrp2,
     @tmtDurGrp2,

     @tmtFrqInd3,
     @tmtDurInd3,
     @tmtFrqGrp3,
     @tmtDurGrp3,

     @tmtFrqInd4,
     @tmtDurInd4,
     @tmtFrqGrp4,
     @tmtDurGrp4,

     @tmtFrqInd5,
     @tmtDurInd5,
     @tmtFrqGrp5,
     @tmtDurGrp5,

     @tmtFrqInd6,
     @tmtDurInd6,
     @tmtFrqGrp6,
     @tmtDurGrp6,

     null,
     null,
     null,
     null      
       
   )
   
   set @pracPatSvcSchRecID = SCOPE_IDENTITY()
   
   /*-------------------------------    
    * Relationship dates
    *------------------------------*/     
   
   INSERT INTO dbo.PRACTITIONER_PATIENTS_DATES (
     PRAC_PAT_ID,             
     START_DATE, 
     END_DATE
   )
   VALUES(     
     @recordID, 
     @startDate, 
     null
   )

   set @pracPatDatesRecID = SCOPE_IDENTITY()
  
   /*-------------------------------    
    * Update main record with 
    * service schedule and 
    * relationship date ids
    *------------------------------*/ 
    
   UPDATE dbo.PRACTITIONER_PATIENTS    
     SET [CUR_PRAC_PAT_SVC_SCH_ID] = @pracPatSvcSchRecID,
         [CUR_PRAC_PAT_DATES_ID]   = @pracPatDatesRecID
   WHERE ID = @recordID
      
 END       
  
 /*==============================    
  * Edit Record
  *==============================*/ 
 
 ELSE IF (@saveType = dbo.CONST_SAVE_TYPE_EDIT())
 BEGIN    
   
   /*-------------------------------    
    * Update main record
    *------------------------------*/  
      
    SET @recordID    = @recID
    SET @updateState = dbo.CONST_REC_STATE_MOD()
      
    UPDATE dbo.PRACTITIONER_PATIENTS
    SET 
      LAST_MODIFIED_BY = @userID,
      LAST_MODIFIED_ON = @today      
    WHERE 
      ID = @recordID         
   
   /*-------------------------------    
    * Either edit existing schedule
    * record or add a new one
    *------------------------------*/  
  
   if (@editSvcSchRec = 1)
   begin
    
     UPDATE 
       PRACTITIONER_PATIENTS_SERVICE_SCHEDULE      
     SET 
       AsmtDueAnn       = @asmtDueAnn,
       AsmtDueTriAnn    = @asmtDueTriAnn,
       TmtEffectiveDate = @tmtEffDate,     
    
       TmtFrqInd2 = @tmtFrqInd2,
       TmtDurInd2 = @tmtDurInd2,
       TmtFrqGrp2 = @tmtFrqGrp2,
       TmtDurGrp2 = @tmtDurGrp2,

       TmtFrqInd3 = @tmtFrqInd3,
       TmtDurInd3 = @tmtDurInd3,
       TmtFrqGrp3 = @tmtFrqGrp3,
       TmtDurGrp3 = @tmtDurGrp3,

       TmtFrqInd4 = @tmtFrqInd4,
       TmtDurInd4 = @tmtDurInd4,
       TmtFrqGrp4 = @tmtFrqGrp4,
       TmtDurGrp4 = @tmtDurGrp4,

       TmtFrqInd5 = @tmtFrqInd5,
       TmtDurInd5 = @tmtDurInd5,
       TmtFrqGrp5 = @tmtFrqGrp5,
       TmtDurGrp5 = @tmtDurGrp5,

       TmtFrqInd6 = @tmtFrqInd6,
       TmtDurInd6 = @tmtDurInd6,
       TmtFrqGrp6 = @tmtFrqGrp6,
       TmtDurGrp6 = @tmtDurGrp6
     WHERE
       ID = @pracPatSvcSchRecID
   end
   else 
   begin
   
     /*-------------------------------    
      * New asmts and recurring service
      * schedule record
      *------------------------------*/     
   
     INSERT INTO dbo.PRACTITIONER_PATIENTS_SERVICE_SCHEDULE (
       PRAC_PAT_ID,             
            
       AsmtDueAnn,
       AsmtDueTriAnn,         
       TmtEffectiveDate,
     
       TmtFrqInd1,
       TmtDurInd1,
       TmtFrqGrp1,
       TmtDurGrp1,

       TmtFrqInd2,
       TmtDurInd2,
       TmtFrqGrp2,
       TmtDurGrp2,

       TmtFrqInd3,
       TmtDurInd3,
       TmtFrqGrp3,
       TmtDurGrp3,

       TmtFrqInd4,
       TmtDurInd4,
       TmtFrqGrp4,
       TmtDurGrp4,

       TmtFrqInd5,
       TmtDurInd5,
       TmtFrqGrp5,
       TmtDurGrp5,

       TmtFrqInd6,
       TmtDurInd6,
       TmtFrqGrp6,
       TmtDurGrp6,
         
       TmtFrqInd7,
       TmtDurInd7,
       TmtFrqGrp7,
       TmtDurGrp7
     )
     VALUES(
     
       @recordID, 
       
       @asmtDueAnn,
       @asmtDueTriAnn,
       @tmtEffDate,
     
       null,
       null,
       null,
       null,
          
       @tmtFrqInd2,
       @tmtDurInd2,
       @tmtFrqGrp2,
       @tmtDurGrp2,

       @tmtFrqInd3,
       @tmtDurInd3,
       @tmtFrqGrp3,
       @tmtDurGrp3,

       @tmtFrqInd4,
       @tmtDurInd4,
       @tmtFrqGrp4,
       @tmtDurGrp4,

       @tmtFrqInd5,
       @tmtDurInd5,
       @tmtFrqGrp5,
       @tmtDurGrp5,

       @tmtFrqInd6,
       @tmtDurInd6,
       @tmtFrqGrp6,
       @tmtDurGrp6,

       null,
       null,
       null,
       null      
       
     )
   
     set @pracPatSvcSchRecID = SCOPE_IDENTITY()
   
     /*-------------------------------    
      * Update main record with 
      * new service schedule record id
     *------------------------------*/ 
    
     UPDATE dbo.PRACTITIONER_PATIENTS    
       SET [CUR_PRAC_PAT_SVC_SCH_ID] = @pracPatSvcSchRecID 
     WHERE ID = @recordID
   
   end
   

 END
 ELSE
 BEGIN
   RAISERROR ('Unknown or unsupported save type', 11, 1)             
 END
 
         
 /*-------------------------------    
  * Create audit record    
  *------------------------------*/    
       
 EXEC CASELOAD_Audit @recordID, @today, @userID, @saveType, @updateState, @editDelReason, @auditRecID OUTPUT    
 
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

GRANT EXECUTE ON  [dbo].[CASELOAD_Save] TO [webuser]
GO
