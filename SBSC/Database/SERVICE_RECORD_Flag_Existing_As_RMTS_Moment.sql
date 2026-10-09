USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_RECORD_Flag_Existing_As_RMTS_Moment') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.SERVICE_RECORD_Flag_Existing_As_RMTS_Moment
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[SERVICE_RECORD_Flag_Existing_As_RMTS_Moment] (
    @userID              BIGINT
  , @userGroup           INT
  , @userRank            INT 
  , @clientID            BIGINT
  , @pracID              bigint
  , @effectiveDate       datetime
  , @active              bit
  , @editDelReason	     VARCHAR(7000)
  , @validateRec		 BIT    
  , @recID			     BIGINT
  , @MsgNoRec		     VARCHAR(1000)   
  , @MsgNoEdit		     VARCHAR(1000)
  , @spDetails		     VARCHAR(8000) OUTPUT    
  , @recordID		   BIGINT        OUTPUT)    
AS    
BEGIN     
    
/***************************************************************************    
 * SERVICE_RECORD_Flag_Existing_As_RMTS_Moment */    
/**    
 * Creates a new RMTS moment service record if necccessary
 * 
 ***************************************************************************/         
     
SET NOCOUNT ON    

declare @today            as datetime
declare @srSvcTypeID      as int
declare @srSvcSubType1    as int
declare @srEntryType      as int
declare @srReference      as varchar(500)
declare @srClientID       as bigint
declare @srPatID          as bigint
declare @srPracID         as bigint
declare @srHasOrpDocID    as bit
declare @srOrpDocID       as  bigint
declare @srGroupID        as bigint
declare @srDOS            as datetime
declare @srNameID         as bigint
declare @srPlanType       as bigint
declare @srIsIEPOrIFSP    as bit
declare @srPatAbsent      as bit
declare @srPracAbsent     as bit
declare @srState          as int
declare @srNumMins        as int
declare @srStartTime      as time(0)      
declare @srHasSvcDetFlags as bit
declare @srSvcDetFlag1    as bit
declare @srSvcDetFlag2    as bit
declare @srSvcDetFlag3    as bit
declare @srSvcDetFlag4    as bit
declare @srUserID         as bigint

declare @userClientID       as bigint
declare @userPracID         as bigint

declare @srNotes          as varchar(max)
declare @rmtsNameID       as bigint
declare @rmtsSvcRecID     as bigint
declare @tranOpen         as bit            -- Is a transaction open    
declare @okForUserToFlag  as bit    = 0
declare @pcalStaff        as bit    = 0
declare @roleID           as bigint = 0

set @today     = getdate()
set @spDetails = ''
set @recordID  = 0

BEGIN TRY    

/*#########################################################################################################
  #                                  FIND SERVICE RECORD                                                  #
  #########################################################################################################*/

set @recordID = null

select top 1 

    @recordID       = sr.id 
  , @srReference    = sr.reference
  , @srEntryType    = sr.entryType
  , @srSvcTypeID    = sr.svcType
  , @srSvcSubType1  = sr.svcSubType1
  , @srClientID     = sr.clientID
  , @srPracID       = sr.pracID
  , @srPatID        = sr.patID
  , @srIsIEPOrIFSP  = sr.isIFSPorIEP
  , @srDOS          = sr.dos
  , @srStartTime    = sr.startTime
  , @srNumMins      = sr.numMins
  , @srNameID       = sr.nameID
  , @srPatAbsent    = sr.patAbsent
  , @srPracAbsent   = sr.pracAbsent
  , @srUserID       = sr.userID

from dbo.SERVICE_RECORDS as sr

where (
      (sr.id       = @recID)
  and (sr.clientID = @clientID)
  and (sr.pracID   = @pracID)
)

/*#########################################################################################################
  #                                    CHECK FOR INVALID CASES                                            #
  #########################################################################################################*/

if (@recordID is null)
  RAISERROR ('Service record not found or it cannot be flagged as an RMTS moment by you', 11, 1) 


/*============================================================
 * Look up info on the user who is calling this routine
 *============================================================*/ 

select top 1 
    @pcalStaff    = ua.pcalStaff
  , @roleID       = ua.roleID 
  , @userPracID   = ua.pracID
  , @userClientID = ua.clientID

from users.dbo.USERS_ALL as ua 
where ((ua.id = @userID) and (ua.appName = 'spedcare'))

set @okForUserToFlag = 0

/*============================================================
 * Determine if the user can flag this service
 *============================================================*/ 

if ((@okForUserToFlag = 0) and (@userID = @srUserID))     set @okForUserToFlag = 1
if ((@okForUserToFlag = 0) and (@userPracID = @srPracID)) set @okForUserToFlag = 1
if ((@okForUserToFlag = 0) and (@pcalStaff = 1))          set @okForUserToFlag = 0 /* Our staff cant because we need a input batch */
if ((@okForUserToFlag = 0) and (@roleID    = 5))          set @okForUserToFlag = 1

if (@okForUserToFlag = 0)
  RAISERROR ('This service record cannot be flagged as an RMTS moment by this user', 11, 1) 

if (@srSvcTypeID = dbo.CONST_SERVICES_TRANSPORT()) 
  RAISERROR ('Transportation services cannot be flagged as an RMTS momemts', 11, 1) 

if ((@srSvcTypeID = 5) and (@srSvcSubType1 = 5001))
begin
  RAISERROR ('You cannot flag an RMTS moment service record as an RMTS moment', 11, 1)
end

if (@srState = 99)  
  RAISERROR ('Service record can no longer be flagged as an RMTS momemt because it has been deleted',        11, 1) 

if (@srState = 199) 
  RAISERROR ('Service record can no longer be flagged as an RMTS momemt because it has been marked for CIF', 11, 1) 
	 
if ((@active = 1) and (@srStartTime is null))
begin
  RAISERROR ('Please edit the service record and add a start time before flagging as an RMTS moment.', 11, 1)
end

BEGIN TRANSACTION
set @tranOpen = 1

/*#########################################################################################################
  #                                SET FLAG AS RMTS MOMENT                                                #
  #########################################################################################################*/

if (@active = 1)
begin

set @rmtsNameID = iif((@srIsIEPOrIFSP = 1),192,110)

EXEC dbo.SERVICE_RECORD_Save_Core
    @userID                --@userID                              
  , @userGroup    		--@userGroup  
  , @userRank			    --@userRank   
  , 1                      -- @generateClaims
  , @srEntryType     		        --@entryType  
  , @srReference           --@reference  
  , null    				--@batchNum   
  , null    				--@papClmNum  
  , @srDos    				--@dos        
  , @srClientID     		    --@clientID   
  , @srPracID    			--@pracID     
  , @srPatID    			    --@patID      
  , @srIsIEPOrIFSP		    --@isIFSPorIEP
  , @rmtsNameID            --@nameID    
  , 0          --@hasOrpDocID
  , null 		    --@orpDocID   
  , null				    --@orpNPI     
  , 0              -- @hasSvcDetailFlag
  , null 		    --@svcDetFlag1    
  , null		    --@svcDetFlag2    
  , null		    --@svcDetFlag3    
  , null		    --@svcDetFlag4    
  , @srStartTime			    --@startTime     
  , @srNumMins    		    --@numMin        
  , 0    				    --@trip1Start    
  , 0    				    --@trip1End      
  , 0    				    --@trip2Start    
  , 0    				    --@trip2End      
  , 0    				    --@trip3Start    
  , 0    				    --@trip3End      
  , 0    				    --@trip4Start    
  , 0					    --@trip4End      
  , 0 --@patAbsent        
  , 0 --@pracAbsent
  , 0 --@makeupSession
  , null /* @attendanceSelectionID*/
  , @srNotes                  --@notes    
  , null
  , null     
  , null
  , 0 /* goal track */
  , 1 /* Billing program id (TODO: Add this parm) */
  , 0 /* Has fillable pdf*/
  ,	'[]' /* Fillable pdf selections */
  ,	'[]' /* Fillable pdf answers*/
  , ''   	     --@editDelReason 
  , 0     		 --@validateRec   
  , 1     		     --@saveType      
  , 0   			     --@recID         
  , 'There was a problem flagging this sevice as an RMTS moment'			 --@msgDupRec     
  , 'There was a problem flagging this sevice as an RMTS moment'    		 --@msgInvCombo   
  , 'There was a problem flagging this sevice as an RMTS moment'     		 --@MsgNoRec      
  , 'There was a problem flagging this sevice as an RMTS moment'     		 --@MsgNoEdit     
  , 'There was a problem flagging this sevice as an RMTS moment'       	 --@MsgDataError  
  , 'There was a problem flagging this sevice as an RMTS moment'   		     --@MsgMinReq      
  , 'There was a problem flagging this sevice as an RMTS moment'   		 --@MsgMinDef      
  , 'There was a problem flagging this sevice as an RMTS moment'   		     --@MsgMilReq      
  , 'There was a problem flagging this sevice as an RMTS moment'			     --@MsgPatElg      
  , 'There was a problem flagging this sevice as an RMTS moment'	 --@MsgPatDOBGteDOS
  , 'There was a problem flagging this sevice as an RMTS moment'  		 --@MsgNotActive   
  , 'There was a problem flagging this sevice as an RMTS moment'		     --@MsgPatAbsent   
  , 'There was a problem flagging this sevice as an RMTS moment'		     --@MsgFutureDOS    
  , @spDetails OUTPUT        --@spDetails 
  , @rmtsSvcRecID  OUTPUT     --@recordID  


 insert into dbo.SERVICE_RECORDS_RMTS_MOMENTS (
   clientID, svcRecSvcProvided, svcRecRMTSMoment)
 values 
   (@clientID, @recordID, @rmtsSvcRecID) 


end /* Flag */
else 

/*#########################################################################################################
  #                                REMOVE FLAG AS RMTS MOMENT                                             #
  #########################################################################################################*/

begin

/* Find all instances where this has been flagged... there may be cases of double flagging */

declare @rmtsSvcRecs as table (
   idx              bigint identity(1,1)
 , id               bigint
 , svcRecRMTSMoment bigint
)

insert into @rmtsSvcRecs
select 
   t1.id
 , t1.svcRecRMTSMoment  
from dbo.SERVICE_RECORDS_RMTS_MOMENTS as t1
where (
      (clientID = @clientID) 
  and (svcRecSvcProvided = @recordID)
)

/* Delete service records that are RMTS moment service names */

declare @currIdx               as bigint
declare @maxIdx                as bigint
declare @xRefID                as bigint
declare @delRmtsMomSvcRecIdOut as bigint

set @currIdx = 1
select @maxIdx = max(t2.idx) from @rmtsSvcRecs as t2

while (@currIdx <= @maxIdx)
begin

  select top 1 
     @xRefID       = t3.id
    ,@rmtsSvcRecID = t3.svcRecRMTSMoment
  from @rmtsSvcRecs as t3  
  where (t3.idx = @currIdx)

  exec dbo.SERVICE_RECORD_Delete_Core
   @userID            
 , @userGroup         
 , @userRank          
 , @editDelReason     
 , @validateRec       
 , @clientID          
 , @rmtsSvcRecID            
 , 0 /*@applyEditDelRules */
 , @today             
 , 'There was a problem unflagging this sevice record as an RMTS moment' -- @MsgNoRec          
 , 'There was a problem unflagging this sevice record as an RMTS moment' -- @MsgNoEdit         
 , @spDetails                      OUTPUT    
 , @delRmtsMomSvcRecIdOut          OUTPUT
    
 /* Delete cross ref to service record this references */

 delete dbo.SERVICE_RECORDS_RMTS_MOMENTS where id = @xRefID

 set @currIdx = @currIdx + 1

end


end /* Unflag */

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
 
GRANT EXECUTE ON  [dbo].[SERVICE_RECORD_Flag_Existing_As_RMTS_Moment] TO [webuser]
GO
