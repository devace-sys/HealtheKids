USE SPEDMON
GO

/*-------------------------------
 * Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RMTS_PARTICIPATION_ROSTER_SAVE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.RMTS_PARTICIPATION_ROSTER_SAVE
GO


/*-------------------------------
 * Create 
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[RMTS_PARTICIPATION_ROSTER_SAVE] (
    @userID                            BIGINT
  , @userGroup                         INT
  , @userRank                          INT
  , @clientID                          BIGINT
  , @fyQuarterID                       BIGINT
  , @participantRosterJSON             varchar(max)
  , @participantRosterChangesJSON      varchar(max)
  , @editDelReason         VARCHAR(7000)
  , @validateRec           BIT
  , @saveType              INT
  , @recID                 BIGINT
  , @MsgNoRec              VARCHAR(1000)
  , @MsgNoEdit             VARCHAR(1000)
  , @MsgDupRec             VARCHAR(1000)
  , @MsgDataError          VARCHAR(1000)
  , @MsgNotActive          VARCHAR(1000)
  , @recordID              BIGINT        OUTPUT
  , @spDetails             VARCHAR(8000) OUTPUT )
AS    
BEGIN     
    
/***************************************************************************    
 * RMTS_PARTICIPATION_ROSTER_SAVE */    
/**    
 * Creates new or edits existing
 *    
 ***************************************************************************/         
     
SET NOCOUNT ON    

/*============================================================
 * Variables
 *============================================================*/  

declare @tranOpen                  as bit       -- Is a transaction open  
declare @today                     as datetime
declare @prevParticipantRosterJSON as varchar(max)
declare @fyID                      as bigint
declare @effectiveDateMin          as date
declare @effectiveDateMax          as date
declare @numPracsPassed            as int
declare @numPracsInDb              as int

declare @participants as table (
  pracID bigint
)

declare @participantChanges as table (
    pracID        bigint
  , participating bit
  , effectiveDate date
)

BEGIN TRY

/*============================================================
 * Init output parameters and worker variables
 *===========================================================*/  
    
SET @recordID   = 0    
SET @spDetails  = ''    
SET @today      = GETDATE()    
SET @tranOpen   = 0

/*============================================================
 * Verify incoming parameters that are essential for proper op
 *============================================================*/  
    
IF (@userGroup     IS NULL) RAISERROR ('userGroup is required',       11, 1)  
IF (@userID        IS NULL) RAISERROR ('user id is required',         11, 1)    
IF (@userRank      IS NULL) RAISERROR ('userRank is required',        11, 1)    
IF (@validateRec   IS NULL) RAISERROR ('Validate flag required',      11, 1)    
IF (@saveType      IS NULL) RAISERROR ('Save type is required',       11, 1)    
if (@clientID      is null) RAISERROR ('Client ID is required',       11, 1)  
if (@fyQuarterID   is null) RAISERROR ('Fiscal quarter is required',  11, 1)  
 
/*============================================================
 * Make sure client is valid
 *============================================================*/  

if not exists (
  select top 1 clc.CLIENT_ID from dbo.CLIENTS_Client as clc
  where (clc.CLIENT_ID = @clientID)
)
begin
  RAISERROR ('Invalid client id', 11, 1)  
end

/*============================================================
 * Retrieve data about quarter and return error 
 * if its not found
 *============================================================*/  
 
set @fyID = null

select top 1
  @fyID             = cfq.FY_ID
, @effectiveDateMin = cfq.QTR_START
, @effectiveDateMax = cfq.QTR_END    
from dbo.COMPANY_FISCAL_QUARTERS as cfq
where (cfq.ID = @fyQuarterID) 

if (@fyID is null) RAISERROR ('Invalid quarter', 11, 1)  

/*============================================================
 * Duplication check
 * One roster per client + quarter is all that is allowed
 *============================================================*/  

 if (@saveType = dbo.CONST_SAVE_TYPE_NEW()) 
 begin
   if exists (
     select top 1 t1.id from dbo.RMTS_PARTICIPATION_ROSTER as t1 
     where ((t1.clientID = @clientID) and (t1.quarterID  = @fyQuarterID))
   )
   begin
     RAISERROR (@MsgDupRec, 11, 1)  
   end
 end
 
 else if (@saveType = dbo.CONST_SAVE_TYPE_EDIT())
 begin
 
	RAISERROR('Edits are no longer supported from this function', 11, 1)
	  
   /*============================================================
    * Retrieve previous participant data
	*============================================================*/  

  -- select top 1 
  --   @prevParticipantRosterJSON = rpr.participantRosterJSON 
  -- from dbo.RMTS_PARTICIPATION_ROSTER as rpr
  -- where (
  --       (clientID = @clientID)
  --   and (id = @recID)
  -- )

  -- /*============================================================
  --  * Deserialize changes passsed in
  --  *============================================================*/  

  -- insert into @participantChanges
  -- select 
  --    [pracID]        = convert(bigint,t1.pracIDStr)
  --  , [participating] = convert(bit,t1.partStr)
  --  , [effectiveDate] = convert(date,t1.effDateStr)
  -- FROM OPENJSON(@participantRosterChangesJSON,'$')
  -- WITH (
  --     effDateStr varchar(256) '$.effectiveDate' 
	 --, partStr    varchar(256) '$.participating'
  --   , pracIDStr  varchar(256) '$.participantObj.id'
  -- ) as t1


  --/*============================================================
  -- * Make sure each participant change passed in has a valid 
  -- * practitioner record
  -- *============================================================*/  

  --set @numPracsPassed = 0
  --set @numPracsInDb   = 0

  --/*-------------------------------
  -- * Count number of pracs passed
  -- *------------------------------*/

  --select 
  --  @numPracsPassed = count(t1.pracID) 
  --from @participantChanges as t1

  --/*-------------------------------
  -- * Count number of pracs passed
  -- * who have a valid prac record
  -- *------------------------------*/

  --select 
  --  @numPracsInDb = count(prp.PRACTITIONER_ID) 
  --from @participantChanges           as t1
  --join dbo.PRACTITIONER_Client       as prc on  prc.CLIENT_ID       = @clientID
  --                                          and prc.PRACTITIONER_ID = t1.pracID
  --join dbo.PRACTITIONER_Practitioner as prp on  prp.PRACTITIONER_ID = prc.PRACTITIONER_ID

  --/*-------------------------------
  -- * Exit with error if both counts
  -- * are not equal
  -- *------------------------------*/

  --if (@numPracsPassed != @numPracsInDb)
  --begin
  --  RAISERROR ('One or more of the practitioners in the roster changes have practitioner records in SpEdCare', 11, 1)  
  --end

  --/*-------------------------------
  -- * Now check for invalid effective
  -- * dates
  -- *------------------------------*/
  
  --if exists (
  --  select 
  --    t1.pracID
  --  from @participantChanges           as t1
  --  where (t1.effectiveDate not between @effectiveDateMin and @effectiveDateMax)
  --)
  --begin
  --  RAISERROR ('One or more of the practitioners in the roster changes have invalid effective dates', 11, 1)      
  --end

end
 
/*============================================================
 * Deserialize participant data passed in
 *============================================================*/  

insert into @participants
select 
  pracID   = t1.id 
FROM OPENJSON(@participantRosterJSON,'$')
WITH (
    id bigint '$.id' 
) as t1

/*============================================================
 * Make sure each participant passed in has a valid 
 * practitioner record
 *============================================================*/  

set @numPracsPassed = 0
set @numPracsInDb   = 0

/*-------------------------------
 * Count number of pracs passed
 *------------------------------*/

select 
  @numPracsPassed = count(t1.pracID) 
from @participants as t1

/*-------------------------------
 * Count number of pracs passed
 * who have a valid prac record
 *------------------------------*/

select 
  @numPracsInDb = count(prp.PRACTITIONER_ID) 
from @participants                 as t1
join dbo.PRACTITIONER_Client       as prc on  prc.CLIENT_ID       = @clientID
                                          and prc.PRACTITIONER_ID = t1.pracID
join dbo.PRACTITIONER_Practitioner as prp on  prp.PRACTITIONER_ID = prc.PRACTITIONER_ID

/*-------------------------------
 * Exit with error if both counts
 * are not equal
 *------------------------------*/

if (@numPracsPassed != @numPracsInDb)
begin
  RAISERROR ('One or more of the practitioners in the roster do not have practitioner records in SpEdCare', 11, 1)  
end



/*============================================================
 * Validation Only Exit
 *============================================================*/  

IF (@validateRec = 1) 
BEGIN  
  RETURN(0)    
END        

/*============================================================
 * Save data
 *============================================================*/  

BEGIN TRANSACTION

SET @tranOpen = 1

/*============================================================
 * Create new roster
 *============================================================*/  

if (@saveType = dbo.CONST_SAVE_TYPE_NEW())
begin

  insert into dbo.RMTS_PARTICIPATION_ROSTER (
      [clientID] 
	, [quarterID]
	, [participantRosterJSON] 
	, [created] 
    , [createdBy] 
  )
  values (
     @clientID
   , @fyQuarterID
   , @participantRosterJSON
   , @today
   , @userID
  )
  
  set @recordID = SCOPE_IDENTITY()

end

/*============================================================
 * Update existing roster
 * No longer supported because the participants are now added
 * one at a time from the RMTS screen
 *============================================================*/  

else if (@saveType = dbo.CONST_SAVE_TYPE_EDIT())
begin
	RAISERROR('Edits are no longer supported from this function', 11, 1)
--  set @recordID = @recID

--  update dbo.RMTS_PARTICIPATION_ROSTER 
--  set
--	  [participantRosterJSON]        = @participantRosterJSON
--    , [participantRosterChangesJSON] = @participantRosterChangesJSON
--	, [lastModified]                 = @today
--    , [lastModifiedBy]               = @userID
--  where (id = @recordID)
 
--/*============================================================
-- * Add to our deserialized list of participant changes
-- *============================================================*/  

-- insert into dbo.RMTS_PARTICIPANTS_CHANGES
-- select 
--    [rosterID]      = @recordID
--  , [pracID]        = t1.pracID
--  , [participating] = t1.participating
--  , [effectiveDate] = t1.effectiveDate
--  , [recordedOn]    = @today
--  , [recordedBy]    = @userID
-- FROM @participantChanges as t1
end


else
begin
   RAISERROR ('Unsupported save type', 11, 1)  
end


/*============================================================
 * Update our deserialized list of current participants
 *============================================================*/  

delete from dbo.[RMTS_PARTICIPANTS] where (rosterID = @recordID)

insert into dbo.[RMTS_PARTICIPANTS] (
  rosterID  
, pracID    
, startDate 
, endDate   
, created   
, createdBy 
)
select 
  rosterID  = @recordID
, pracID    = t1.pracID
, startDate = fyq.QTR_START	  -- since this is only used for add new, we can hardcode these values
, endDate   = fyq.QTR_END	  -- since this is only used for add new, we can hardcode these values
, created   = @today
, createdBy = @userID
from @participants as t1
join dbo.COMPANY_FISCAL_QUARTERS as fyq on fyq.ID = @fyQuarterID

/*============================================================
 * Track revisions
 *============================================================*/  

insert into dbo.[RMTS_PARTICIPATION_ROSTER_REVISIONS] (
    [rosterID]
  , [participantRosterJSON] 
  , [participantRosterChangesJSON]
  , [recordedOn]   
  , [recordedBy] 
)
values (
    @recordID
  , @participantRosterJSON
  , @participantRosterChangesJSON
  , @today
  , @userID
)

/*============================================================
 * All done, commit changes and get out
 *============================================================*/  
    
COMMIT TRANSACTION    
SET @tranOpen = 0    
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
      
  IF @tranOpen = 1 ROLLBACK TRANSACTION    
      
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

GRANT EXECUTE ON  [dbo].[RMTS_PARTICIPATION_ROSTER_SAVE] TO [webuser]
GO
