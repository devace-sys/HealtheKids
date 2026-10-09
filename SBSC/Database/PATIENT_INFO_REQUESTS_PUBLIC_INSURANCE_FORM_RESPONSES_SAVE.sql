USE SPEDMON
GO


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_INFO_REQUESTS_PUBLIC_INSURANCE_FORM_RESPONSES_SAVE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.PATIENT_INFO_REQUESTS_PUBLIC_INSURANCE_FORM_RESPONSES_SAVE
GO

CREATE PROCEDURE [dbo].[PATIENT_INFO_REQUESTS_PUBLIC_INSURANCE_FORM_RESPONSES_SAVE] (
     @userID                  bigint 
   , @userGroup               bigint
   , @userRank                int
   , @clientID                bigint
   , @patID                   bigint
   , @insuranceCarrierID	  bigint
   , @memberID				  varchar(80)
   , @ferpaConsent            bit
   , @editDelReason           varchar (7000)
   , @validateRec             bit
   , @saveType                int
   , @recID                   bigint
   , @MsgNoRec                VARCHAR(1000)
   , @MsgNoEdit               VARCHAR(1000)
   , @MsgDupRec               VARCHAR(1000)
   , @MsgDataError            VARCHAR(1000)
   , @MsgNotActive            VARCHAR(1000)
   , @recordID                BIGINT        OUTPUT
   , @spDetails               VARCHAR(8000) OUTPUT
) 
 AS    
BEGIN    

declare @tranOpen  as bit  
declare @today     as datetime  

set @recordID   = 0    
set @spDetails  = ''    
set @today      = GETDATE()    
set @tranOpen   = 0

BEGIN TRY


  IF (@saveType = dbo.CONST_SAVE_TYPE_EDIT())    
  BEGIN
    select top 1 
	  @recordID = pic.id
    from dbo.PATIENT_INFO_REQUESTS_PUBLIC_INSURANCE_FORM_RESPONSES as pic 
	where ( 
	      (pic.id       = @recID)    
	  and (pic.clientID    = @clientID)
	)

    if ( ISNULL(@recordID,0) = 0 )
	begin
      RAISERROR( 'Please select a valid record to edit', 11, 1)
	end

  END


  if ( @validateRec = 1) RETURN (0)

  SET @tranOpen = 1
  BEGIN TRANSACTION

  if (@saveType = dbo.CONST_SAVE_TYPE_EDIT())    
  begin

    update dbo.PATIENT_INFO_REQUESTS_PUBLIC_INSURANCE_FORM_RESPONSES
	set	    
        patID				                              = @patID
	  , insuranceCarrierId                                = @insuranceCarrierID
	  , memberID		                                  = @memberID   
	  , consentToReleaseOfChildHealthRecsAndOrBenefitInfo = @ferpaConsent                           
	  , lastModified		                              = @today
	  , lastModifiedBy	 	                              = @userID	  
	where 
	  (id = @recordID)

  end /* Edit */ 
  else 
  begin
    RAISERROR( 'Unknown or unsupported save type' , 11, 1)
  end

  COMMIT TRANSACTION
  SET @tranOpen = 0

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

GRANT EXECUTE ON  [dbo].[PATIENT_INFO_REQUESTS_PUBLIC_INSURANCE_FORM_RESPONSES_SAVE] TO [webuser]
GO
