USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTICE_OFFICE_KIOSKS_DELETE') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.PRACTICE_OFFICE_KIOSKS_DELETE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

 CREATE PROCEDURE dbo.PRACTICE_OFFICE_KIOSKS_DELETE(
    @userID         BIGINT    
  , @userGroup      INT    
  , @userRank       INT   
  , @editDelReason VARCHAR(7000)
  , @groupSvcClassNameID BIGINT
  , @clientID      BIGINT     
  , @validateRec   BIT
  , @recID         BIGINT
  , @MsgNoRec      VARCHAR(1000)    
  , @MsgNoEdit     VARCHAR(1000)
  , @spDetails     VARCHAR(8000) OUTPUT
  , @recordID      BIGINT        OUTPUT)    
AS    
BEGIN  

SET NOCOUNT ON    
   
DECLARE @TranOpen     AS BIT    
DECLARE @saveType     AS INT
DECLARE @today        AS DATETIME          -- Current date/time stamp    
   
BEGIN TRY    
   
/*-------------------------------    
 * Init our output parameters    
 *------------------------------*/    
   
  
SET @recordID  = 0    
SET @spDetails = ''    
SET @saveType = dbo.CONST_SAVE_TYPE_DELETE()  
SET @today = GETDATE() 

/*-------------------------------    
 * Verify all parameters that    
 * indicate what type of operation    
 * to perform have been passed in    
 *------------------------------*/   
  
IF (@validateRec IS NULL) RAISERROR ('Validate flag required',  11, 1)    
IF (@recID       IS NULL) RAISERROR ('RecID is required', 11, 1)    
   

SELECT TOP 1 
    @recordID = pok.id 
FROM dbo.PRACTICE_OFFICE_KIOSKS AS pok
WHERE (    
     (pok.id = @recID)
 and (pok.clientID            = @clientID)            /* Per client access check */
 and (pok.groupSvcClassNameID = @groupSvcClassNameID) /* Practice family check */ 
 and (pok.active = 1)
)

/*-------------------------------    
 * If there are any problems    
 * exit quietly
 *------------------------------*/ 

IF (@recordID IS NULL) 
begin
  set @recordID = 0
  return(0)
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
  
  /*-------------------------------    
   * "Delete" existing entity record    
   *------------------------------*/   

UPDATE dbo.PRACTICE_OFFICE_KIOSKS 
  SET   active         = 0
	  , lastmodified   = @today
	  , lastModifiedBy = @userID
  WHERE (id = @recordID)    
  
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
     
  
  IF @TranOpen = 1 ROLLBACK TRANSACTION    
   
  DECLARE @ErrorMessage  AS NVARCHAR(4000)    
  DECLARE @ErrorSeverity AS INT    
  DECLARE @ErrorState    AS INT    
     
  SELECT  @ErrorMessage  = ERROR_MESSAGE(),    
          @ErrorSeverity = ERROR_SEVERITY(),    
          @ErrorState    = ERROR_STATE()    
   
  IF @ErrorSeverity > 11
    SET @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ']'    
   
     -- Reraise the error so it returns back to the server    

  RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)    
   
END CATCH    
END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/ 

GRANT EXECUTE ON  [dbo].[PRACTICE_OFFICE_KIOSKS_DELETE] TO [webuser]
GO