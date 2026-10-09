USE users
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.TELECOMM_SESSION_VALIDATE_SHARED_FILE_ADD') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.TELECOMM_SESSION_VALIDATE_SHARED_FILE_ADD
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TELECOMM_SESSION_VALIDATE_SHARED_FILE_ADD] (
    @roomID                   varchar(256)
  , @email                    varchar(256)
  , @pin                      varchar(50)  
  , @userIP                   varchar(500)
  , @userAgent                varchar(8000)
  , @accessGranted            bit           output
  , @participantClientID      bigint        output
  , @teleCommSessionID        bigint        output
  , @teleCommServerSessionID  varchar(256)  output
  , @appName                  varchar(50)   output
  , @userID                   bigint        output
  , @userGroup                int           output
  , @userRank                 int           output
  , @fileClassStr             varchar(1000) output
  , @fileNameSpace            varchar(500)  output
  , @fileSource               varchar(500)  output
  , @clientIDStr              varchar(1000) output
  , @pracIDStr                varchar(1000) output
  , @patIDStr                 varchar(1000) output
)    

AS    
BEGIN    
   
/***************************************************************************    
 * TELECOMM_SESSION_VALIDATE_SHARED_FILE_ADD */    
/**    
 *    
 ***************************************************************************/        
     
SET NOCOUNT ON    

declare @tranOpen               as  bit  = 0
declare @today                  as  datetime
declare @sessionOK              as  bit    
declare @sessionID              as  bigint 
declare @participantID          as  bigint 
declare @purposeID              as  bigint
declare @isSessionFacilitator   as  bit 
declare @facilitatorEntityID    as bigint

set @today                   = GETDATE()
set @tranOpen                = 0
set @isSessionFacilitator    = 0
set @accessGranted           = 0
set @participantClientID     = -1
set @teleCommSessionID       = -1
set @teleCommServerSessionID = ''
set @appName                 = ''
set @userID                  = -1     
set @userGroup               = -1  
set @userRank                = -1   
set @fileClassStr            = '' 
set @fileNameSpace           = ''
set @fileSource              = ''
set @clientIDStr             = ''
set @pracIDStr               = ''
set @patIDStr                = ''

BEGIN TRY    

BEGIN TRANSACTION

set @tranOpen             = 1
set @accessGranted        = 0
set @sessionOK            = 0
set @isSessionFacilitator = 0

/*============================================================
 * Validate caller
 *============================================================*/  

exec dbo.TELECOMM_SESSION_VALIDATE_CORE 
    @roomID 
  , @email 
  , @pin     
  , @today

  , 0 --@skipMeetingHasNotStartedCheck

  , @sessionOK                output
  , @sessionID                output
  , @participantClientID      output 
  , @participantID            output
  , @isSessionFacilitator     output

/*============================================================
 * If access is granted and the participant is a faciliator
 * we can retrieve the additional data needed
 *============================================================*/  

if ((@sessionOK = 1) and (@isSessionFacilitator = 1))
begin

  set @accessGranted     = 1  
  set @teleCommSessionID = @sessionID
     
  /*-------------------------------    
    * Get various entities involved
	* based on telecomm meeting
	* purpose.
	*
	* Note: We return empty strings
	* for entities that are not 
    * involved so we can pass this
	* data straight to the stored
	* file save
    *------------------------------*/ 
  
  select top 1 

      @appName                 = ts.appName
    , @userID                  = coalesce (ts.lastModifedBy, ts.createdBy)
	, @teleCommServerSessionID = ts.serverSessionID
	, @clientIDStr             = convert(varchar,ts.clientID)
    , @fileClassStr            = convert(varchar,tsp.fileClass)
	, @fileNameSpace           = tsp.fileNameSpace
	, @fileSource              = tsp.fileSource
	
	/* TODO: To expand, add additional logic to extract pracID for different meeting purposes */

	, @pracIDStr = iif((ts.purposeID = 2)
	                    ,convert(varchar,ts.facilitatorEntityID)
						,'')
    
	/* TODO: To expand, add additional logic to extract pracID for different meeting purposes */

	, @patIDStr   = iif((ts.purposeID = 3)
	                     , (select top 1 patIDStr = convert(varchar,psd.patID) from OPENJSON(ts.purposeSpecificData) WITH (patID bigint '$.patID') as psd)
	                     , '')
								   	
  from dbo.TELECOMM_SESSIONS        as ts
  join dbo.TELECOMM_SESSION_PURPOSE as tsp on tsp.id = ts.purposeID

  where (ts.id = @sessionID)
   
   /*-------------------------------    
    * Get rest of userInfo 
    *------------------------------*/  

  select top 1
      @userGroup = ua.userGroupID 
    , @userRank  = ua.userRank
  from dbo.USERS_DATA_CORE(@appName,null,null,null,@userID) as ua
  
  /*-------------------------------    
   * All set
   *------------------------------*/  
  
  set @accessGranted = 1

end

/*============================================================
 * Log it
 *============================================================*/  

declare @logID    as bigint = null
declare @jsonData as varchar(max) = ''
 
set @jsonData  = '{'	       
               + '" participantClientID:"' + convert(varchar,isnull(@participantClientID,-1)) + '"'
			   + '",accessGranted":"'      + convert(varchar,isnull(@accessGranted,0))        + '"'
			   + '}'

exec dbo.TELECOMM_SESSION_CREATE_LOG_ENTRY_CORE
      @sessionID
	, @today
	, @participantID
	, 'Add File Share' 
	, @userIP
	, @userAgent
	, @jsonData
	, @logID output

/*============================================================
 * Done
 *============================================================*/  

COMMIT TRANSACTION
set @tranOpen = 0
RETURN(0)    


END TRY    
BEGIN CATCH    

  if (@tranOpen = 1) ROLLBACK TRANSACTION

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
               
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
   
END CATCH    
END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[TELECOMM_SESSION_VALIDATE_SHARED_FILE_ADD] TO [webuser]
GO
