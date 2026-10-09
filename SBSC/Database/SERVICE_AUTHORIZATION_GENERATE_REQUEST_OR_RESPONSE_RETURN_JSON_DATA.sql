USE SPEDMON
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_AUTHORIZATION_GENERATE_REQUEST_OR_RESPONSE_RETURN_JSON_DATA') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.SERVICE_AUTHORIZATION_GENERATE_REQUEST_OR_RESPONSE_RETURN_JSON_DATA
GO


/*-------------------------------
 * Create 
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[SERVICE_AUTHORIZATION_GENERATE_REQUEST_OR_RESPONSE_RETURN_JSON_DATA] (
    @init                                         bit     = 0
  , @userNeedsToDownloadRequest                   bit     = 0
  , @userNeedsToDownloadRequestID                 bigint  = 0
  , @userNeedsToDownloadRequestDialogTitle        varchar(1000) = ''
  , @userNeedsToDownloadRequestDialogContent      varchar(8000) = ''
  , @newUserAccountData NEW_USER_ACCOUNT_DATA     readonly
  , @messages           NOTIFICATION_MESSAGE_DATA readonly
  , @jsonData           varchar(max)  OUTPUT
)
AS    
BEGIN     
    
/***************************************************************************    
 * SERVICE_AUTHORIZATION_GENERATE_REQUEST_OR_RESPONSE_RETURN_JSON_DATA */    
/**    
 ***************************************************************************/         
     
SET NOCOUNT ON    

set @jsonData  = '{"userNeedsToDownloadRequest":false,"userNeedsToDownloadRequestID":0,"userNeedsToDownloadRequestURL":"","userNeedsToDownloadRequestDialogTitle":"","userNeedsToDownloadRequestDialogContent":"","accounts":[],"messages":[]}'
if (@init = 1) return(0)

declare @jsonDataAccounts as varchar(max) = '[]'
declare @jsonDataMessages as varchar(max) = '[]'

BEGIN TRY

if (exists (select top 1 1 from @newUserAccountData))
begin
  set @jsonDataAccounts = (select * from @newUserAccountData FOR JSON AUTO, INCLUDE_NULL_VALUES)
end


if (exists (select top 1 1 from @messages))
begin
  set @jsonDataMessages = (select * from @messages FOR JSON AUTO, INCLUDE_NULL_VALUES)
end


/*============================================================
 * Create json data 
 * for passing back in our return parameter.
 *===========================================================*/   
   
                   
set @jsonData = '{'
              + ' "userNeedsToDownloadRequest":'               + iif((@userNeedsToDownloadRequest = 1),'true','false')
			  + ',"userNeedsToDownloadRequestID":'             + convert(varchar(50), isnull(@userNeedsToDownloadRequestID,0))
			  + ',"userNeedsToDownloadRequestURL":""'            /* Populated in middleware */
			  + ',"userNeedsToDownloadRequestDialogTitle":"'   + STRING_ESCAPE(isnull(@userNeedsToDownloadRequestDialogTitle,''),'JSON')     + '"'
			  + ',"userNeedsToDownloadRequestDialogContent":"' + STRING_ESCAPE(isnull(@userNeedsToDownloadRequestDialogContent,''),'JSON')   + '"'
			  + ',"accounts":'
              + @jsonDataAccounts
			  + ',"messages":'
			  + @jsonDataMessages
			  + '}'

/*============================================================
 * All done
 *============================================================*/  
    
RETURN(0)    

END TRY  

/*============================================================
 * Exception handling
 *============================================================*/      

BEGIN CATCH    
    
  /*-------------------------------    
   * If we end up here something    
   * went wrong.  Cancel any pending    
   * transactions and return any    
   * error any error messages to    
   * the caller    
   *------------------------------*/    
       
  -- Error or raise error with severity 11 to 19 will be caught here    
            
  DECLARE @ErrorMessage  AS NVARCHAR(4000)    
  DECLARE @ErrorSeverity AS INT    
  DECLARE @ErrorState    AS INT    
      
  SELECT  @ErrorMessage  = ERROR_MESSAGE(),    
          @ErrorSeverity = ERROR_SEVERITY(),    
          @ErrorState    = ERROR_STATE()    
   
  -- Only send really bad exceptions back with sp details

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

GRANT EXECUTE ON  [dbo].[SERVICE_AUTHORIZATION_GENERATE_REQUEST_OR_RESPONSE_RETURN_JSON_DATA] TO [webuser]
GO
