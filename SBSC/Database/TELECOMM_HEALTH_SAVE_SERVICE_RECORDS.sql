USE SPEDMON
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.TELECOMM_HEALTH_SAVE_SERVICE_RECORDS') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.TELECOMM_HEALTH_SAVE_SERVICE_RECORDS
GO


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TELECOMM_HEALTH_SAVE_SERVICE_RECORDS] (
    @userID                           BIGINT    
  , @userGroup                        INT    
  , @userRank                         INT 
  , @userIP                           varchar(500)
  , @userAgent						  varchar(8000)
  , @roomID                           varchar(256)
  , @email                            varchar(256)
  , @pin                              varchar(50)  
  , @formID                           varchar(256)
  , @formData                         varchar(max)
  , @editDelReason                    VARCHAR(7000)    
  , @validateRec               BIT    
  , @saveType                  INT    
  , @recID                     BIGINT    
  , @MsgNoRec                  VARCHAR(1000)    
  , @MsgNoEdit                 VARCHAR(1000) 
  , @MsgDupRec                 VARCHAR(1000)     
  , @MsgDataError              VARCHAR(1000)
  , @MsgNotActive              VARCHAR(1000)     

  , @msgInvCombo               varchar(1000)
  , @MsgMinReq                 varchar(1000)
  , @MsgMinDef                 varchar(1000)
  , @MsgMilReq                 varchar(1000)   
  , @MsgPatElg                 varchar(1000)
  , @MsgPatDOBGteDOS           varchar(1000)
  , @MsgPatAbsent              varchar(1000)
  , @MsgFutureDOS              varchar(1000)
  , @recordID                  BIGINT        OUTPUT  
  , @spDetails                 VARCHAR(8000) OUTPUT)    

AS    
BEGIN    
   
/***************************************************************************    
 * TELECOMM_HEALTH_SAVE_SERVICE_RECORDS */    
/**    
 * Creates a new or edits existing entity record    
 * and manages any associated records.    
 *    
 ***************************************************************************/        
     
SET NOCOUNT ON    
   
declare @today                 as datetime 
declare @tranOpen              as bit      = 0
declare @formDataRecID         as bigint   = null
declare @savedFormData         as varchar(max)
declare @clientID              as bigint
declare @pracID                as bigint
declare @groupID               as bigint
declare @serviceType           as bigint
declare @serviceSubType        as bigint
declare @dos                   as datetime
declare @telecommSessionID     as bigint
declare @telecommParticipantID as bigint
declare @recordedOn            as datetime
declare @reference             as varchar(500)
declare @purposeSpecificData   as varchar(max)
declare @svcDetails            as varchar(max)
declare @facilitatorUserID     as bigint
declare @facilitatorUserGroup  as bigint
declare @facilitatorUserRank   as int
declare @minIdx                as bigint 
declare @maxIdx                as bigint
declare @curIdx                as bigint
declare @patID                 as bigint
declare @patAbsent             as bit
declare @iep                   as bit
declare @startTime             as time(0)
declare @numMins               as int
declare @notes                 as varchar(max)
declare @nameID                as bigint
declare @batchID               as UNIQUEIDENTIFIER = null
declare @batchIDRecID          as BIGINT           = null

declare @svcRecID              as bigint
declare @spDetailsTemp         as varchar (8000)
declare @batchIDAssRecID       as bigint = null

declare @svcRecordEntryData as table (
    idx           bigint identity(1,1)
  , patAbsent     bit
  , patID         bigint
  , iep           bit
  , startTime     time(0)
  , numMins       int
  , notes         varchar(max)
  , nameID        bigint
  , participantID bigint
  , svcRecID      bigint
)

/*============================================================
 * Init
 *============================================================*/  

set @recordID  = 0
set @today     = GETDATE()    
set @spDetails = ''
set @tranOpen  = 0


BEGIN TRY    

/*============================================================
 * Verify parameters
 *============================================================*/  
   
        
BEGIN TRANSACTION
set @tranOpen = 1

/*============================================================
 * Save "final" form data
 *============================================================*/  

exec users.dbo.TELECOMM_SESSION_SAVE_FORM_DATA_CORE
    @userID  
  , @userGroup
  , @userRank 
  , @userIP  
  , @userAgent
  , @roomID   
  , @email  
  , @pin  
  , @formID 
  , @formData 
  , 1 /* Data finalized */
  , @editDelReason
  , @validateRec 
  , @saveType
  , @recID   
  , @MsgNoRec 
  , @MsgNoEdit
  , @MsgDupRec 
  , @MsgDataError 
  , @MsgNotActive 
  , @formDataRecID OUTPUT  
  , @spDetails     OUTPUT

/*============================================================
 * Generate service record entry data from form data
 *============================================================*/  

/*-------------------------------    
 * Get the form data we just saved
 * along with client, practitioner
 * and group data
 *------------------------------*/  

select top 1   

    @clientID              = clc.CLIENT_ID
  , @pracID                = prp.PRACTITIONER_ID
  , @groupID               = gg.GROUP_ID
  , @dos                   = ts.meetingDate
  , @savedFormData         = tsfd.formData
  , @telecommSessionID     = ts.id
  , @purposeSpecificData   = ts.purposeSpecificData
  , @telecommParticipantID = tsfd.telecommSessionParticipantID  
  , @recordedOn            = tsfd.recordedOn
  , @facilitatorUserID     = ts.facilitatorUserID
  
from users.dbo.TELECOMM_SESSIONS_FORM_DATA as tsfd 
join users.dbo.TELECOMM_SESSIONS           as ts  on ts.id               = tsfd.telecommSessionID
join dbo.CLIENTS_Client                    as clc on clc.CLIENT_ID       = ts.clientID
join dbo.PRACTITIONER_Practitioner         as prp on prp.PRACTITIONER_ID = ts.facilitatorEntityID
join dbo.PRACTITIONER_GROUPS               as prg on prg.PRACTITIONER_ID = prp.PRACTITIONER_ID
join dbo.GROUP_Group                       as gg  on gg.GROUP_ID         = prg.GROUP_ID

where (
      (tsfd.id = @formDataRecID)
  and (prg.GROUP_TYPE in (1,2))
  and (gg.GROUP_TYPE in (1,2))
)

/*-------------------------------    
 * Get rest of userInfo for 
 * faciliator
 *------------------------------*/  

select top 1
    @facilitatorUserGroup = ua.userGroupID 
  , @facilitatorUserRank  = ua.userRank
from users.dbo.USERS_DATA_CORE(null,null,null,null,@facilitatorUserID) as ua

/*-------------------------------    
 * Extract the service type 
 * and subtype
 *------------------------------*/  

select top 1
   @serviceType    = t1.serviceType
 , @serviceSubType = t1.serviceSubType
from dbo.TELECOMM_HEALTH_DESERIALIZE_PURPOSE_SPECIFIC_DATA(@purposeSpecificData) as t1

/*-------------------------------    
 * Use the most recent
 * telecomm session log record
 * for this participant
 * to determine the document
 * reference we will use for the
 * service records
 *------------------------------*/  

select top 1 
  @reference = userIP
from users.dbo.TELECOMM_SESSIONS_LOG 
where 
      (telecommSessionID             = @telecommSessionID)
  and (telecommSessionParticipantID  = @telecommParticipantID)
  and (loggedOn >= convert(date,@recordedOn))
order by id desc

/*-------------------------------    
 * Extract and convert service
 * details
 *------------------------------*/  

select top 1 
  @svcDetails = [value] 
FROM OPENJSON(@savedFormData) as t1
where ([key] = 'details')

;with
cte_p1
as
(
  select 
      t2.patAbsent  
    , t2.patID
    , t2.iep
    , t2.startTime
    , t2.numMins
    , t2.notes
    , planType    = dbo.DOS_DOB_IEP_TO_PLAN_TYPE(@dos,pap.DATE_OF_BIRTH,t2.iep)

  FROM OPENJSON(@svcDetails,'$.svcDetails')
  WITH (
      patAbsent bit          '$.patAbsent'
    , patID     bigint       '$.patID'
    , iep       bit          '$.iep'
    , startTime time         '$.startTime'
    , numMins   int          '$.numMins'
    , notes     varchar(max) '$.notes' 
  ) as t2
  join dbo.PATIENTS_Patient as pap on pap.PATIENT_ID = t2.patID
)
,
cte_p2
as
(
  select 
    p1.*
  , svac2.nameID
  , participantID = tsp.id
  from cte_p1 as p1
  join users.dbo.TELECOMM_SESSIONS_PARTICIPANTS as tsp on tsp.entityID = p1.patID
  cross apply (
    select top 1 
	  nameID = svac1.SERVICE_NAME_ID 
	from dbo.SERVICES_VIEW_ALL_CORE ( @clientID, @groupID, p1.planType, @serviceType, null, 1, 1, @dos, 1) as svac1
    where 
	      (svac1.SERVICE_SUB_TYPE_1_ID = @serviceSubType)
	  and (svac1.PROCEDURE_NAME like 'TLHL%')
  ) as svac2
  where (tsp.telecommSessionID = @telecommSessionID)
)
  
insert into @svcRecordEntryData
select 
    patAbsent 
  , patID
  , iep
  , startTime
  , numMins
  , notes
  , nameID
  , participantID
  , svcRecID = null
from cte_p2 as p2


select 
    @minIdx = min(idx)
  , @maxIdx = max(idx) 
from @svcRecordEntryData

set @curIdx = @minIdx


if (@validateRec = 0)
begin

  /*-------------------------------    
   * Create unique batch ID
   *------------------------------*/

  exec SERVICE_RECORD_BATCH_ID_Create 
      @facilitatorUserID
    , @facilitatorUserGroup
    , @facilitatorUserRank
    , @saveType
    , @validateRec
    , @batchIDRecID OUTPUT 
    , @batchID      OUTPUT  

end
  
while (@curIdx <= @maxIdx)
begin
   
  select top 1 
	  @patAbsent = sred.patAbsent
	, @patID     = sred.patID
	, @iep       = sred.iep
    , @startTime = sred.startTime
	, @numMins   = sred.numMins
	, @notes     = sred.notes
	, @nameID    = nameID
  from @svcRecordEntryData as sred 
  where (idx = @curIdx)

  set @spDetailsTemp = ''
  set @svcRecID      = 0

  EXEC dbo.SERVICE_RECORD_Save_Core
      @facilitatorUserID    
    , @facilitatorUserGroup    
    , @facilitatorUserRank
	, 1
    , 64    
    , @reference           
    , null    
    , null    
    , @dos    
    , @clientID    
    , @pracID    
    , @patID
    , @iep    
    , @nameID
    , 0    /* hasORP Doc ID*/
    , null /* ORP Doc ID */
    , null /* ORP Npi */
    , 0
    , null
    , null
    , null
    , null    
    , @startTime
    , @numMins 
    , 0    
    , 0   
    , 0    
    , 0   
    , 0    
    , 0  
    , 0    
    , 0
    , @patAbsent
	, 0
	, 0 
	, null /* @attendanceSelectionID*/
    , @notes
	, null         /* formDataQuestions*/
	, null
	, null
	, 0 /* Patient goal tracking */
	, 1 /* Billing program */
	, 0    /* Has fillable pdf (TODO: Add these 3 parms) */
    , '[]' /* Fillable pdf selections */
	, '[]' /* Fillable pdf answers*/
    , ''           /* Edit/del reason*/    
    , @validateRec    
    , @saveType   
    , null        /* @recID */
    , @msgDupRec
    , @msgInvCombo    
    , @MsgNoRec     
    , @MsgNoEdit   
    , @MsgDataError    
    , @MsgMinReq    
    , @MsgMinDef     
    , @MsgMilReq    
    , @MsgPatElg
    , @MsgPatDOBGteDOS
    , @MsgNotActive 
    , @MsgPatAbsent
    , @MsgFutureDOS
    , @spDetailsTemp OUTPUT
    , @svcRecID      OUTPUT      
 
  
  set @spDetails = @spDetails + ltrim(rtrim(@spDetailsTemp))
  
  if (@validateRec = 0)
  begin

    /*-------------------------------    
     * Assign unique batch ID
     *------------------------------*/

    exec SERVICE_RECORD_BATCH_ID_Assign 
        @facilitatorUserID
      , @facilitatorUserGroup
      , @facilitatorUserRank
  	  , @saveType
	  , @validateRec
	  , @batchID
	  , @curIdx
	  , @svcRecID
	  , @batchIDAssRecID OUTPUT  
       
    update @svcRecordEntryData
      set svcRecID = @svcRecID
    where (idx = @curIdx)
  
  end

  set @curIdx = @curIdx + 1
end

if (@validateRec = 0)
begin

set @recordID = @batchIDRecID


  insert into dbo.TELECOMM_HEALTH_SERVICE_RECORD_ENTRY_DATA
  select 
      formDataID         = @formDataRecID
    , telecommSessionID  = @telecommSessionID 
    , t1.participantID
    , clientID           = @clientID
    , pracID             = @pracID
    , t1.patID        
    , t1.svcRecID     
    , created            = @today
  from @svcRecordEntryData as t1
 
end

set @tranOpen = 0
COMMIT TRANSACTION

RETURN(0)    

END TRY    
BEGIN CATCH    
   
if (@tranOpen  = 1) ROLLBACK TRANSACTION

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
     
   -- SET @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ']'    
     
  -- Reraise the error so it returns back to the server    
     
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
   
END CATCH    
END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[TELECOMM_HEALTH_SAVE_SERVICE_RECORDS] TO [webuser]
GO
