USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLIENT_STUDENT_INFORMATION_SYSTEMS_SAVE') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.CLIENT_STUDENT_INFORMATION_SYSTEMS_SAVE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
   
CREATE PROCEDURE [dbo].[CLIENT_STUDENT_INFORMATION_SYSTEMS_SAVE]    
 (
    @userID                  BIGINT
  , @userGroup               INT   
  , @userRank                INT
  , @clientID                BIGINT
  , @studentInfoSystemID     BIGINT
  , @apiUrl                  VARCHAR(1024)
  , @apiToken                VARCHAR(1024)
  , @schoolNamesToExclude    varchar(max)
  , @enabled                 bit
  , @additionalDataJSON      VARCHAR(MAX)  
  , @editDelReason           VARCHAR(7000)
  , @validateRec             BIT
  , @saveType                INT
  , @recID                   BIGINT
  , @MsgNoRec                VARCHAR(1000)   
  , @MsgDupRec               VARCHAR(1000)
  , @MsgNoEdit               VARCHAR(1000)
  , @MsgNotActive            VARCHAR(1000)
  , @MsgDataError            VARCHAR(1000)  
  , @spDetails               VARCHAR(8000) OUTPUT
  , @recordID                BIGINT        OUTPUT )     
AS    
BEGIN    
   
/***************************************************************************    
 * CLIENT_STUDENT_INFORMATION_SYSTEMS_SAVE */    
/**    
 * Saves a client student information system record   
 *    
 * @param   userID                  The user id of who saved the record    
 * @param   userGroup               The user group
 * @param   userRank                The user rank
 * @param   clientID                The client id
 * @param   studentInfoSystemID     The student information system id
 * @param   apiUrl                  The API URL
 * @param   apiToken                The API token
 * @param   editDelReason           Reason for edit
 * @param   validateRec             1 = Performs data integrity validation tasks    
                                    Perform advisory validation tasks that can    
 *                                  only be conducted by referencing data from the    
 *                                  database and then exits WITHOUT saving the record    
 *                                  0 = Peform data integrity validation tasks and    
 *                                  if these tasks succeed performs the desired    
 *                                  operation (saveType) on the record and exits    
 * @param   saveType                Type of save operation (1=new, 2=edit)
 * @param   recID                   Record id of existing record to edit    
 *                                  (NULL or 0 for new record)    
 * @param   MsgDupRec               Desired error message for duplicate record    
 * @param   MsgNoRec                Desired error message for edit operations     
 *                                  when record is not found    
 * @param   MsgNoEdit               Desired error message for edit operations     
 *                                  if the record cannot be edited     
 * @returns spDetails               Validation or error details    
 * @returns recordID                New record id or record id that    
 *                                  was changed     
 ***************************************************************************/        
     
SET NOCOUNT ON    
   
DECLARE @TranOpen        AS BIT    
DECLARE @today           AS DATETIME          -- Current date/time stamp    
DECLARE @dupCheck        AS BIGINT
   
BEGIN TRY    
   
/*-------------------------------    
 * Init our output parameters    
 *------------------------------*/    
   
SET @recordID        = 0 
set @spDetails       = ''
SET @today           = GETDATE()       
   
/*-------------------------------    
 * Verify required parameters    
 *------------------------------*/    

IF (@userID              IS NULL) RAISERROR ('userID is required',      11, 1)    
IF (@userGroup           IS NULL) RAISERROR ('userGroup is required',   11, 1)    
IF (@userRank            IS NULL) RAISERROR ('userRank is required',    11, 1)       
IF (@validateRec         IS NULL) RAISERROR ('Validate flag required',  11, 1)    
IF (@saveType            IS NULL) RAISERROR ('Save type required',      11, 1)    
IF (@clientID            IS NULL) RAISERROR ('ClientID is required',    11, 1)    
IF (@studentInfoSystemID IS NULL) RAISERROR ('Student Information System ID is required', 11, 1)
IF (@apiUrl              IS NULL) RAISERROR ('API URL is required',   11, 1)
IF (@apiToken            IS NULL) RAISERROR ('API token is required', 11, 1)

/*-------------------------------    
 * Check for duplicate record
 * (same client and system)
 *------------------------------*/    

IF (@saveType = dbo.CONST_SAVE_TYPE_NEW())
begin
    select top 1
        @dupCheck = csis.id 
    FROM dbo.CLIENT_STUDENT_INFORMATION_SYSTEMS AS csis
    WHERE (
            (csis.clientID = @clientID)
        AND (csis.studentInfoSystemID = @studentInfoSystemID)
        AND (csis.active = 1)
    )
    
    IF (@dupCheck IS NOT NULL)
    begin
        RAISERROR (@MsgDupRec, 11, 1)   -- Duplicate record    
    end
end

/*-------------------------------    
 * If editing, verify record exists
 * and check for duplicates
 *------------------------------*/    

IF (@saveType = dbo.CONST_SAVE_TYPE_EDIT())
begin
    IF ((@recID IS NULL) OR (@recID = 0))
    begin
        RAISERROR ('Record ID required for edit', 11, 1)
    end
    
    select top 1
        @recordID = csis.id 
    FROM dbo.CLIENT_STUDENT_INFORMATION_SYSTEMS AS csis
    WHERE (
            (csis.id = @recID)
        AND (csis.clientID = @clientID)
        AND (csis.active = 1)
    )
    
    IF (@recordID = 0)
    begin
        RAISERROR (@MsgNoRec, 11, 1)   -- Record not found    
    end
    
    /*-------------------------------    
     * Check for duplicate on edit
     * (changing to a system already assigned)
     *------------------------------*/
    
    select top 1
        @dupCheck = csis.id 
    FROM dbo.CLIENT_STUDENT_INFORMATION_SYSTEMS AS csis
    WHERE (
            (csis.clientID = @clientID)
        AND (csis.studentInfoSystemID = @studentInfoSystemID)
        AND (csis.id <> @recID)
        AND (csis.active = 1)
    )
    
    IF (@dupCheck IS NOT NULL)
    begin
        RAISERROR (@MsgDupRec, 11, 1)   -- Duplicate record    
    end
end

/*-------------------------------    
 * If we are just validating    
 * get out now    
 *------------------------------*/    
     
IF (@validateRec = 1) RETURN(0)    
   
/*-------------------------------    
 * Write changes to the data    
 *------------------------------*/    
   
BEGIN TRANSACTION    
   
    SET @TranOpen = 1    
   
    IF (@saveType = dbo.CONST_SAVE_TYPE_NEW())
    begin
        /*-------------------------------    
         * Insert new record    
         *------------------------------*/       
        
        INSERT INTO dbo.CLIENT_STUDENT_INFORMATION_SYSTEMS (
              clientID
            , studentInfoSystemID
            , apiUrl
            , apiToken
			, schoolNamesToExclude
			, [enabled]
			, additionalDataJSON
            , created
            , createdBy
            , active
        )
        VALUES (
              @clientID
            , @studentInfoSystemID
            , @apiUrl
            , @apiToken
			, @schoolNamesToExclude
			, @enabled
			, @additionalDataJSON
            , @today
            , @userID
            , 1
        )
        
        SET @recordID = SCOPE_IDENTITY()
    end

    ELSE IF (@saveType = dbo.CONST_SAVE_TYPE_EDIT())
    begin
    
	    /*-------------------------------    
         * Update existing record    
         *------------------------------*/       
  
        UPDATE dbo.CLIENT_STUDENT_INFORMATION_SYSTEMS 
        set   studentInfoSystemID  = @studentInfoSystemID
            , apiUrl               = @apiUrl
            , apiToken             = @apiToken
			, schoolNamesToExclude = @schoolNamesToExclude 
			, [enabled]            = @enabled
			, additionalDataJSON   = @additionalDataJSON 
            , lastModified         = @today
            , lastModifiedBy       = @userID
        WHERE (id = @recID)    
    end
  
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
   
    IF @tranOpen = 1 ROLLBACK TRANSACTION    
   
    DECLARE @ErrorMessage  AS NVARCHAR(4000)    
    DECLARE @ErrorSeverity AS INT    
    DECLARE @ErrorState    AS INT    
     
    SELECT  @ErrorMessage  = ERROR_MESSAGE(),    
            @ErrorSeverity = ERROR_SEVERITY(),    
            @ErrorState    = ERROR_STATE()    
   
    SET @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ']'    
   
    -- Reraise the error so it returns back to the server    
   
    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)    
   
END CATCH    

END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[CLIENT_STUDENT_INFORMATION_SYSTEMS_SAVE] TO [webuser]
GO