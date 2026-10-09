USE SPEDMON
GO

IF EXISTS (
    SELECT * 
    FROM sys.objects 
    WHERE object_id = OBJECT_ID('dbo.PATIENT_INFO_REQUESTS_RESPONSES_MASS_REQUEST_SAVE') 
      AND type IN (N'P', N'PC')
)
begin
  DROP PROCEDURE dbo.PATIENT_INFO_REQUESTS_RESPONSES_MASS_REQUEST_SAVE
end

GO

CREATE PROCEDURE dbo.PATIENT_INFO_REQUESTS_RESPONSES_MASS_REQUEST_SAVE (
      @userID             bigint
    , @userGroup          int
    , @userRank           int
    , @clientID           bigint
	, @source             tinyint  /* 0 = Entire district 1 = CYBHI Only */
	, @requesterName      varchar(512)
    , @requesterEmail     varchar(256)
    , @requesterPhone     varchar(256)
	, @requestBaseUrl     varchar(1000)	
	, @editDelReason	  varchar(7000)
    , @validateRec        bit
    , @recID              bigint
    , @MsgNoRec           VARCHAR(1000)
    , @MsgDupRec          VARCHAR(1000)
    , @MsgNoEdit          VARCHAR(1000)
    , @MsgNotActive       VARCHAR(1000)
    , @MsgDataError       VARCHAR(1000)
    , @saveType           SMALLINT             /* Note: Used differently than standard in this procedure */
    , @spDetails          VARCHAR(8000) OUTPUT
    , @recordID           BIGINT        OUTPUT
)
AS
BEGIN
   
set nocount on

declare @tranOpen            as bit     
declare @today               as datetime
declare @numOfPats           as int
declare @numOfPatPers        as int

declare @patsWithMissingInfo as table (
	patID          bigint
  , patPerIDs      varchar(max)
  , numOfPatPers   smallint
)
 
/*============================================================
 * Init
 *============================================================*/
    
set @recordID        = 0
set @spDetails       = ''
set @tranOpen        = 0
set @today           = getdate()
set @numOfPats       = 0
set @numOfPatPers    = 0

BEGIN TRY

/*============================================================
 * If a bulk request already exists and its currently being
 * processed (emails being distributed) exit.
 *============================================================*/
 	
if exists (
  select top 1 
    t1.id 
  from dbo.PATIENT_INFO_REQUESTS_RESPONSES_MASS_UPDATES as t1
  where (
        (t1.clientID   = @clientID)
    and (t1.completed  = 0)
    and (t1.active     = 1)
  )
  order by 
    t1.id desc
)
begin
  RAISERROR ('A bulk student information request is currently being processed.  Please wait for a minute then try again.', 11, 1)
  return(0)
end

/*============================================================
 * Find all patients with missing info that have parent 
 * guardian emails
 *============================================================*/

insert into @patsWithMissingInfo (	      
    patID
  , patPerIDs
)
select 	     
    t1.patID
  , t1.patPerIDs
from dbo.Patients_With_Missing_Info_View_Core (
    @clientID      
  , null    /*@patID    */
  , @source            
  , null    /* @missingInsuranceInfo */
  , null    /* @missingAddressInfo */
  , null    /* @missingOrNoFerpaConsent*/
  , 0       /* @missingPGEmails */
  , null   /* @missingMcalParentConsent */
  , 0       /* @hasCurrentInfoRequest */
  , 0       /* @hasCurrentInfoRequestWaitingForReview */ 
  , 0       /* @hasPreviousInfoRequestThatRequiredReview */
  , 1       /* Limit to patients with missing info */) as t1
where (
     (t1.missingInsuranceInfo = 1)
  or (t1.missingFerpaConsent  = 1)
)

/*============================================================
 * No patients found.  Get out silently.  Nothing to do.
 *
 * Note: This case should not happen under normal operations
 *============================================================*/

select @numOfPats = count(t1.patID) from @patsWithMissingInfo as t1

if (@numOfPats = 0)
begin
  RAISERROR ('There are currently no students that we can send requests for information for.  Please check that all parent/guardian data is complete and that at least one of the parent/guardian(s) has an email address.', 11, 1)
  return(0)
end
 
/*============================================================
 * Get number of patient persons (parent guardians) per row
 *============================================================*/

update t1
set 
  t1.numOfPatPers = isnull(t4.numOf,0)
from @patsWithMissingInfo as t1
outer apply (
  select       
    numOf = count(t3.[value]) 
  from
  (
    select     
	  t2.[value]	   
    from STRING_SPLIT(t1.patPerIDs,',') as t2
  ) as t3
) as t4

/*============================================================
 * Get total number of patient persons
 *============================================================*/

select @numOfPatPers = sum(t1.numOfPatPers) from @patsWithMissingInfo as t1

/*============================================================
 * If validating exit
 *============================================================*/

if (@validateRec = 1)
begin
  return(0)
end

/*============================================================
 * Save 
 *============================================================*/

set @tranOpen = 0

begin transaction	
set @tranOpen = 1
    	
insert into dbo.PATIENT_INFO_REQUESTS_RESPONSES_MASS_UPDATES (             
	clientID  
  , [source]  
  , requesterName
  , requesterEmail
  , requesterPhone
  , requestBaseUrl
  , saveType  
  , numOfPats
  , numOfPatPers  
  , completed 			
  , created 	
  , createdBy 
  , active
)
values (
    @clientID
  , @source
  , @requesterName
  , @requesterEmail
  , @requesterPhone
  , @requestBaseUrl
  , @saveType
  , @numOfPats
  , @numOfPatPers    
  , 0        /* completed */
  , @today   
  , @userID  
  , 1        /* active*/
)

set @recordID = SCOPE_IDENTITY()

insert into dbo.PATIENT_INFO_REQUESTS_RESPONSES_MASS_UPDATE_ROWS (        
    pirrMassUpdateID  
  , patID    
  , patPerIDs
  , numOfPatPers
  , processed
)
select 
    pirrMassUpdateID = @recordID
  , t1.patID 
  , t1.patPerIDs
  , t1.numOfPatPers
  , processed = 0
from @patsWithMissingInfo as t1
	
commit transaction
set @tranOpen = 0
	    
RETURN(0)

END TRY
BEGIN CATCH

/*-------------------------------
 * If we end up here something went 
 * wrong. Cancel any pending 
 * transactions and return any error
 * messages to the caller
 *------------------------------*/
 
IF @tranOpen = 1 ROLLBACK TRANSACTION
		
DECLARE @ErrorMessage  NVARCHAR(4000)
DECLARE @ErrorSeverity INT
DECLARE @ErrorState    INT

SELECT  @ErrorMessage  = ERROR_MESSAGE(),
        @ErrorSeverity = ERROR_SEVERITY(),
        @ErrorState    = ERROR_STATE()

RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)
END CATCH
END
GO

GRANT EXECUTE ON dbo.PATIENT_INFO_REQUESTS_RESPONSES_MASS_REQUEST_SAVE TO webuser
GO

