USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENTS_STUDENTS_NO_LONGER_IN_ACTIVE_USE_DEACTIVATE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.PATIENTS_STUDENTS_NO_LONGER_IN_ACTIVE_USE_DEACTIVATE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

    
CREATE PROCEDURE [dbo].[PATIENTS_STUDENTS_NO_LONGER_IN_ACTIVE_USE_DEACTIVATE]     
(
   @clientID                as bigint ,
   @numOfMonthsOfInactivity as int
  )    
AS    
BEGIN     
     
SET NOCOUNT ON
declare @TranOpen as bit = 0

BEGIN TRY    

set @TranOpen = 0

exec dbo.PRINT_STATUS_MESSAGE 'Patients - Students No Longer In Active Use - Deactivate - Starting'

-- Defaults

set @numOfMonthsOfInactivity = isnull(@numOfMonthsOfInactivity,15)
if (@numOfMonthsOfInactivity <= 0) set @numOfMonthsOfInactivity = 15

declare @today as datetime = GETDATE() 

DECLARE @ErrorMessage  AS NVARCHAR(4000) = N''   

declare @dateMonthsAgo as date = cast( DATEADD( MONTH, ( -1 * @numOfMonthsOfInactivity ), @today ) as date)
  
declare @allClientsToProcess as table( idx bigint identity(1,1)
               , clientID   bigint not null
               , clientName varchar(512) not null
)

declare @printMsg as varchar(512) = ''


           
set @printMsg = 'Patients - Students No Longer In Active Use - Deactivate - Getting Active LEA Clients With Student Data Files Received On or After ' + convert(varchar,@dateMonthsAgo)
exec dbo.PRINT_STATUS_MESSAGE @printMsg

  INSERT INTO @allClientsToProcess (clientID, clientName)
  SELECT
      cc.CLIENT_ID
	, cc.CLIENT_NAME
  
  FROM dbo.CLIENTS_Client_Active_LEA cc

  OUTER APPLY (
        SELECT top 1 *
           FROM  [dbo].[Structured_Data_Imports] sdi
         WHERE  sdi.clientID = cc.CLIENT_ID
             AND
             (  sdi.fileSubClass = dbo.CONST_PATIENT_DATA_FILE_SUB_CLASS_TOTAL_POP() 
                OR
                sdi.fileSubClass = dbo.CONST_PATIENT_DATA_FILE_SUB_CLASS_SPEC_ED_SVCS()
             )
             AND
             sdi.created > @dateMonthsAgo
  ) sdi

  OUTER APPLY (
         SELECT top 1 *
           FROM  [dbo].[Import_From_A_From_Client_ToSPED_Files] i_a
         WHERE  i_a.client_id = cc.CLIENT_ID
             AND
             i_a.began_processing > @dateMonthsAgo
  ) i_a

  OUTER APPLY (
         SELECT top 1 *
           FROM  [dbo].[Import_From_A.5_SERVICES_From_Client_Files] i_a5
         WHERE i_a5.client_id = cc.CLIENT_ID
            AND
            i_a5.began_processing > @dateMonthsAgo
  ) i_a5

  WHERE (cc.CLIENT_ID = @clientID OR @clientID IS NULL)
        AND
        (
          sdi.id  IS NOT NULL
          OR
          i_a.id  IS NOT NULL
          OR
          i_a5.id IS NOT NULL
        )

  declare @currIdx_i bigint = 1
  declare @currCliID bigint = 0
  declare @maxIdx_i bigint = 0
  declare @currClientName as varchar(512)
  
  SELECT  @maxIdx_i = MAX(idx) FROM @allClientsToProcess

  SET @printMsg = 'deactivating old patient records for ' + CAST( @maxIdx_i as varchar ) + ' clients'

  exec dbo.PRINT_STATUS_MESSAGE @printMsg 
    
  declare @currIdx_j bigint = 1

  declare @currPatID bigint
  declare @maxIdx_j bigint
  declare @countPatsThisClient bigint

  declare @auditUpdateState int ;
  declare @auditSaveType int ;
  declare @auditRecordID int ;
  declare @auditEditDelReason varchar(180) ;

  -- for each client {

  while (@currIdx_i <= @maxIdx_i)
  begin

    declare @allPatsToDeacThisClient
          table( idx bigint identity(1,1)
               , patID   bigint not null)

    set @TranOpen = 0

	BEGIN TRY

    -- print status message with client name
   
    SELECT top 1
      @currCliID       = clientID 
    , @currClientName  = clientName
    FROM @allClientsToProcess WHERE idx = @currIdx_i

    SET @printMsg = 'Processing client ' + @currClientName
    exec dbo.PRINT_STATUS_MESSAGE @printMsg 

    -- get patients to deactivate and put into table variable
   
    INSERT INTO @allPatsToDeacThisClient(patID)
      SELECT
        PATIENT_ID

      FROM  [dbo].[PATIENT_FIND_RECORDS_TO_DEACTIVATE_DUE_TO_INACTIVITY_CORE] (
         @currCliID
       , @numOfMonthsOfInactivity
      ) 
  
    SELECT @maxIdx_j = MAX(idx) FROM @allPatsToDeacThisClient

    -- print status message with patient count
    
	SELECT top 1 @countPatsThisClient  = COUNT(*) FROM @allPatsToDeacThisClient

    SET @printMsg =  'Deactivating ' + CAST( @countPatsThisClient as varchar ) + ' patients for this client'
    exec dbo.PRINT_STATUS_MESSAGE @printMsg

    -- begin transaction
    BEGIN TRANSACTION    
    
      SET @TranOpen = 1 
	  
      UPDATE p_p
      SET
        active = N'N',
        LAST_UPDATED     = @today,   
        [state]          = dbo.CONST_SVC_REC_STATE_DEL()
      from  @allPatsToDeacThisClient as ap_c 
	  join  PATIENTS_Patient         as p_p on p_p.PATIENT_ID = ap_c.patID
      
    commit TRANSACTION
    SET @TranOpen = 0    

    END TRY    
    BEGIN CATCH

      -- if tranopen = 1 rollback trasaction
      IF @tranOpen = 1
      BEGIN
        ROLLBACK TRANSACTION
        SET @tranOpen = 0
      END  
      
      -- print error message

      SET @ErrorMessage = ERROR_MESSAGE() + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ']'
      print @ErrorMessage
  
    END CATCH

      DELETE FROM @allPatsToDeacThisClient  -- leaving this declare outside of the scope of the try/catch,
                                          -- since I've already tested it enough times to get it working
      SET @currIdx_i += 1

  
  end  /* Each client */
       
  exec dbo.PRINT_STATUS_MESSAGE 'Patients - Students No Longer In Active Use - Deactivate - Complete'

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

  DECLARE @ErrorSeverity AS INT    
  DECLARE @ErrorState    AS INT    
      
  SELECT  @ErrorMessage  = ERROR_MESSAGE(),    
          @ErrorSeverity = ERROR_SEVERITY(),    
          @ErrorState    = ERROR_STATE()    
      
  SET @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ']'    
      
  -- Reraise the error so it returns back to the server    
      
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
    
END CATCH    
END    
    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[PATIENTS_STUDENTS_NO_LONGER_IN_ACTIVE_USE_DEACTIVATE] TO [webuser]
GO
