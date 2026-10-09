USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_RECORD_Delete_Inline') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.SERVICE_RECORD_Delete_Inline
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[SERVICE_RECORD_Delete_Inline] (
    @userID              BIGINT
  , @userGroup           INT
  , @userRank            INT 
  , @clientID            BIGINT
  , @editDelReason	     VARCHAR(7000)
  , @validateRec		 BIT    
  , @recID			     BIGINT
  , @MsgNoRec		     VARCHAR(1000)   
  , @MsgNoEdit		     VARCHAR(1000)
  , @spDetails		     VARCHAR(8000) OUTPUT    
  , @recordID		     BIGINT        OUTPUT)    
AS    
BEGIN     
    
/***************************************************************************    
 * SERVICE_RECORD_Delete_Inline */    
/**    
 * 
 * 
 ***************************************************************************/         
     
SET NOCOUNT ON    
      
declare @tranOpen           as BIT            -- Is a transaction open    
declare @today              as datetime
declare @srEntryType        as int
declare @srSvcTypeID        as int
declare @srUserID           as bigint
declare @srPracID           as bigint
declare @srState            as int
declare @okToCallDeleteCore as bit
declare @cifClaims          as bit
declare @clientIDOut        as bigint
declare @userClientID       as bigint
declare @userPracID         as bigint
declare @okForUserToDelete  as bit = 0
declare @pcalStaff          as bit = 0
declare @roleID             as bigint = 0
declare @cifRecID           as bigint
declare @cifSpDetails       as varchar(8000)
declare @cifRequestID       as bigint
declare @srJsonData         as varchar(max)
declare @userIsPcalStaff    as bit
declare @srUserIsPcalStaff  as bit

/* Used for sanity check for journal patient absent delete check */

declare @srPatAbsent        as bit    = 0
declare @srClaimID1         as bigint = 0

declare @srBillingProgram   as tinyint = 1

/*#########################################################################################################
  #                                        INIT CONTROL FIELDS
  #########################################################################################################*/

set @today              = getdate()
set @spDetails          = ''
set @recordID           = @recID
set @okToCallDeleteCore = 0
set @cifClaims          = 0

BEGIN TRY    

/*#########################################################################################################
  #                                        FIND SERVICE RECORD
  #########################################################################################################*/

select top 1 
    @recordID         = sr.id 
  , @srEntryType      = sr.entryType
  , @srSvcTypeID      = sr.svcType
  , @srUserID         = sr.userID 
  , @srState          = sr.state
  , @clientIDOut      = sr.clientID
  , @srPracID         = sr.pracID
  , @srPatAbsent      = sr.patAbsent
  , @srClaimID1       = isnull(sr.claimID1,0)
  , @srBillingProgram = sr.billingProgramID
from dbo.SERVICE_RECORDS as sr
where (
      (sr.id = @recID)
  and ((@clientID is null) or (sr.clientID = @clientID))
)

/*============================================================
 * If we cant find the record exit
 *============================================================*/ 

if (@recordID is null)
  RAISERROR ('Service record not found', 11, 1)

set @clientID = @clientIDOut

/*#########################################################################################################
  #                             CHECK FOR WHO CAN DELETE THIS
  #########################################################################################################*/

/*============================================================
 * Look up info on the user who is calling this routine
 *============================================================*/ 

select top 1 
    @pcalStaff    = ua.pcalStaff
  , @roleID       = ua.roleID 
  , @userPracID   = ua.pracID
  , @userClientID = ua.clientID
  , @userIsPcalStaff = ua.pcalStaff
from users.dbo.USERS_ALL as ua 
where ((ua.id = @userID) and (ua.appName = 'spedcare'))

/*============================================================
 * Look up info on the user who entered the service
 *============================================================*/ 

select top 1 
  @srUserIsPcalStaff = ua.pcalStaff
from users.dbo.USERS_ALL as ua 
where ((ua.id = @srUserID) and (ua.appName = 'spedcare'))

/*============================================================
 * Determine if the user can delete the service
 *============================================================*/ 

set @okForUserToDelete = 0

/* User who entered can delete */

if ((@okForUserToDelete = 0) and (@userID = @srUserID)) set @okForUserToDelete = 1

/* If the user is the practitioner who is the rendering practioner associated with the service record, they can delete
 * unless the record was entered by pcal then they can't delete */

if ((@okForUserToDelete = 0) and (@userPracID = @srPracID) and (@srUserIsPcalStaff = 0)) set @okForUserToDelete = 1

/* Practi-cal staff can delete */

if ((@okForUserToDelete = 0) and (@pcalStaff = 1)) set @okForUserToDelete = 1

/* LEA Input Staff and LEA Coordinators can delete */

if ((@okForUserToDelete = 0) and (@roleID in (5,10))) set @okForUserToDelete = 1

/*============================================================
 * Exit if delete is not allowed
 *============================================================*/ 

if (@okForUserToDelete = 0) 
  RAISERROR ('This service record cannot be deleted by this user', 11, 1) 
  
/*#########################################################################################################
  #                             CHECK FOR CASES WHERE WE CANNOT DELETE
  #########################################################################################################*/

/*============================================================
 * Journal
 *============================================================*/ 

/* Journal where patient was marked present.  Cannot delete. */

if (@srEntryType = 10) 
begin
  RAISERROR ('Deleting services that were created in a service journal are not supported on this screen yet', 11, 1) 
end

/* Journal where patient was marked absent.  Might be able to delete.*/
/* Note: These svc record entry types have no journal data, they are just documentation. */

if (@srEntryType = 11)
begin 
  
  /* Sanity checks.  The following cases should never happen but just in case...*/
  
  if (@srPatAbsent = 0) 
  begin
    /*If the service record does not have the patient marked as absent then get out*/
      RAISERROR ('Deleting services that were created in a service journal are not supported on this screen yet', 11, 1) 
  end
  
  if (@srClaimID1  != 0) 
  begin
    /* If the service record has claims, get out */
    RAISERROR ('Deleting services that were created in a service journal are not supported on this screen yet', 11, 1) 
  end

  /* If we reach this point it is probably OK to delete as long as we dont fail any other checks. */
end

/*============================================================
 * Already deleted
 *============================================================*/ 

if (@srState = 99)  
  RAISERROR ('Service has already been been deleted',        11, 1) 

/*============================================================
 * Already CIFd
 *============================================================*/ 

if (@srState = 199) 
  RAISERROR ('Service can no longer be deleted because it has been marked for CIF', 11, 1) 


/*#########################################################################################################
  #                      CHECK IF SERVICE CAN BE DELETED THROUGH NORMAL PROCEDURE
  #########################################################################################################*/
  
if (dbo.SERVICE_STATE_TO_CAN_STILL_EDIT_FLAG(@srState) = 1)
begin
  set @okToCallDeleteCore       = 1
  set @cifClaims                = 0
end

/*============================================================
 * If not then CIF
 *============================================================*/ 

else if (@srState = 20)
begin

  if (@srBillingProgram = 2) 
  begin
    RAISERROR ('CYBHI services cannot be deleted after they are billed.', 11, 1) 
  end

  set @okToCallDeleteCore       = 0
  set @cifClaims                = 1
end

/*============================================================
 * If not CIF then this service must be in a state that is
 * cannot be deleted (HEBS claims port, etc)
 *============================================================*/ 

else
begin
  RAISERROR ('This service cannot be deleted', 11, 1) 
end

/*#########################################################################################################
  #                           GET SERVICE RECORD DATA FOR ARCHIVE PURPOSES
  #########################################################################################################*/

set @srJsonData = convert (  varchar(max)
                           ,(select sr.* from dbo.SERVICE_RECORDS as sr 
						     where sr.id = @recordID FOR JSON AUTO, INCLUDE_NULL_VALUES)
						  )

/*#########################################################################################################
  #                                           RECORD OPS
  #########################################################################################################*/

BEGIN TRANSACTION

set @tranOpen = 1

/*#########################################################################################################
  #                                                  CIF
  #########################################################################################################*/

if (@cifClaims = 1)
begin

  set @cifSpDetails = ''
  set @okToCallDeleteCore = 0

  /* Call existing CIF initiate logic.  The table CLAIMS_LIST_DO_NOT_RESUBMIT is updated with new claims in this logic. */
  
  exec dbo.SERVICE_RECORD_INITIATE_CIF_Core @userID,@userGroup,@userRank,@editDelReason,0,@clientID,@recordID, @today,@spDetails output, @cifRecID output
  
  
  /* Create our CIF request record */

  insert into dbo.CIF_REQUESTS (
      clientID
	, svcRecID
	, saveTypeID
	, reason
	, svcRecData
	, createdOn
	, createdBy)
   
   values (  
       @clientID
     , @recordID
	 , dbo.CONST_SAVE_TYPE_DELETE()
     , 'Service record deleted'
     , @srJsonData
     , @today
     , @userID
   ) 

   set @cifRequestID = SCOPE_IDENTITY()
   
   insert into dbo.CIF_REQUESTS_CLAIMS (     
        cifRequestID
	  , svcRecID
	  , claimID )
   select  
       cifRequestID = @cifRequestID
	  , src.svcRecID
	  , src.claimID
   from dbo.SERVICE_RECORD_CLAIMS as src
   where (src.svcRecID = @recordID)

end


/*#########################################################################################################
  #                                          DELETE CORE
  #########################################################################################################*/

if (@okToCallDeleteCore = 1)
begin

exec dbo.SERVICE_RECORD_Delete_Core
   @userID            
 , @userGroup         
 , @userRank          
 , @editDelReason     
 , @validateRec       
 , @clientID          
 , @recID             
 , 0 /*@applyEditDelRules */
 , @today             
 , @MsgNoRec          
 , @MsgNoEdit         
 , @spDetails         OUTPUT    
 , @recordID          OUTPUT
    
end

/*-------------------------------    
 * If this was an actual save
 * or edit commit the transaction
 *------------------------------*/  

IF (@TranOpen  = 1) COMMIT TRANSACTION    

/*-------------------------------    
 * And we are done
 *------------------------------*/  

SET @TranOpen = 0    
RETURN(0)    

END TRY    

/*-------------------------------    
 * If we end up here something    
 * went wrong
 *------------------------------*/    

BEGIN CATCH    
  
  -- Error or raise error with severity 11 to 19 will be caught here    
    
  /*-------------------------------    
   * Cancel any pending    
   * transactions  
   *------------------------------*/    
      
  IF @tranOpen = 1 ROLLBACK TRANSACTION    
      
  /*-------------------------------    
   * Identify error
   *------------------------------*/    
  
  DECLARE @ErrorMessage  AS NVARCHAR(4000)    
  DECLARE @ErrorSeverity AS INT    
  DECLARE @ErrorState    AS INT    
      
  SELECT  @ErrorMessage  = ERROR_MESSAGE(),    
          @ErrorSeverity = ERROR_SEVERITY(),    
          @ErrorState    = ERROR_STATE()    
      
  SET @ErrorMessage = @ErrorMessage 
      
 /*-------------------------------    
   * Return the error message to
   * the caller. 
   *------------------------------*/    
 
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
    
END CATCH    

END  
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[SERVICE_RECORD_Delete_Inline] TO [webuser]
GO
