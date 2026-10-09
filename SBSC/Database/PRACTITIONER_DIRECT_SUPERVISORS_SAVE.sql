USE SPEDMON
GO

/*-------------------------------
 * Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTITIONER_DIRECT_SUPERVISORS_SAVE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.PRACTITIONER_DIRECT_SUPERVISORS_SAVE
GO

/*-------------------------------
 * Create 
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[PRACTITIONER_DIRECT_SUPERVISORS_SAVE] (
    @userID                            BIGINT
  , @userGroup                         INT
  , @userRank                          INT
  , @clientID                          BIGINT
  , @pracID                            BIGINT
  , @supervisingPracDetailsJSON        varchar(max)
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
 * PRACTITIONER_DIRECT_SUPERVISORS_SAVE */    
/**    
 * Creates new or edits existing
 *    
 ***************************************************************************/         
     
SET NOCOUNT ON    

/*============================================================
 * Variables
 *============================================================*/  

declare @tranOpen  as bit       -- Is a transaction open  
declare @today     as datetime
declare @numDetailsIn                   as int
declare @numDetailsCheck                as int
declare @numSameGroupFamilyCheck        as int     = 0
declare @supervisedPracID               as bigint  = null
declare @supervisedPracDispGroupID      as bigint  = null
declare @supervisedPracGroupSvcNameID   as bigint = null
declare @numPracsMarkedAsSup            as int = 0
declare @numPracsAbleToSuperviseByGroup as int = 0

declare @supDetails as table (    
    SUPERVISING_PRAC_ID bigint
  , START_DATE          datetime
  , END_DATE            datetime
  , SHARE_NOTES         bit
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
if (@pracID        is null) RAISERROR ('Prac id is required',  11, 1)  
 
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
 * Make sure practitioner is valid
 * and get their discipline group id
 *============================================================*/  
 
select top 1 
    @supervisedPracID          = prp.PRACTITIONER_ID
  , @supervisedPracDispGroupID = pg.GROUP_ID
from.PRACTITIONER_Client           as prc                                         
join dbo.PRACTITIONER_Practitioner as prp on prp.PRACTITIONER_ID = prc.PRACTITIONER_ID
join dbo.PRACTITIONER_GROUPS       as pg  on pg.PRACTITIONER_ID = prp.PRACTITIONER_ID  

where (
        (prc.CLIENT_ID = @clientID) 
    and (prc.PRACTITIONER_ID = @pracID) 
    and (prp.PRACTITIONER_ID = @pracID)
	and (pg.GROUP_TYPE in (1,2))
)

if (@supervisedPracID is null)
begin
  RAISERROR ('Invalid supervised practitioner id', 11, 1)  
end

/*============================================================
 * Get group family for the supervised prac
 *============================================================*/  

select top 1
  @supervisedPracGroupSvcNameID = png.GROUP_SERVICE_CLASS_NAME_ID
from dbo.GROUP_GROUP_SERVICE_CLASS_PARTITIONS_NAMES_GROUPS as png
where (
      (png.GROUP_SERVICE_CLASS_PARTITION_ID = 100)
  and (png.GROUP_ID = @supervisedPracDispGroupID)
)
/*============================================================
 * Duplication check
 * One record per client + supervised practitioner is all 
 * that is allowed
 *============================================================*/  

 if (@saveType = dbo.CONST_SAVE_TYPE_NEW()) 
 begin
   if exists (
     select top 1 
	   t1.id 
	 from dbo.PRACTITIONER_PRACTITIONER_DIRECT_SUPERVISORS as t1 
     where ((t1.clientID = @clientID) and (t1.pracID = @pracID))
   )
   begin
     RAISERROR (@MsgDupRec, 11, 1)  
   end
 end

/*============================================================
 * Deserialize supervision details
 *============================================================*/  

insert into @supDetails
select 
    SUPERVISING_PRAC_ID = case when trim(t1.supervisingPracIDStr) = '' then null else convert (bigint,  t1.supervisingPracIDStr) end
  , START_DATE          = case when trim(t1.startDateStr)         = '' then null else convert (datetime,t1.startDateStr)         end
  , END_DATE            = case when trim(t1.endDateStr)           = '' then null else convert (datetime,t1.endDateStr)           end
  , SHARE_NOTES         = t1.shareNotes
FROM OPENJSON(@supervisingPracDetailsJSON,'$')
WITH (
       supervisingPracIDStr varchar(256) '$.supervisingPracID' 
	 , startDateStr    varchar(256) '$.startDate'
     , endDateStr      varchar(256) '$.endDate'
	 , shareNotes      bit          '$.shareNotes'
) as t1


/*============================================================
 * Validate supervision details
 *============================================================*/  

 select @numDetailsIn = count(*) from @supDetails

/*-------------------------------
 * Do all of the supervising prac 
 * ids exist and are they 
 * associated with the client?  
 * If not exit with error.
 *------------------------------*/

 set @numDetailsCheck = 0
 
 select 
   @numDetailsCheck = count (*)
 from @supDetails                   as t1
 join dbo.PRACTITIONER_Practitioner as prp on prp.PRACTITIONER_ID  = t1.SUPERVISING_PRAC_ID
 join PRACTITIONER_Client           as prc on  prc.CLIENT_ID       = @clientID
                                           and prc.PRACTITIONER_ID = prp.PRACTITIONER_ID
 
if (@numDetailsIn != @numDetailsCheck)
begin
  RAISERROR ('One or more invalid supervising practitioner id(s)', 11, 1)  
end

/*-------------------------------
 * All practitioners involved
 * must be in the same group 
 * family
 *------------------------------*/

 select 
   @numSameGroupFamilyCheck = count (SUPERVISING_PRAC_ID)
 from @supDetails                     as sd
 join dbo.PRACTITIONER_GROUPS         as pg   on pg.PRACTITIONER_ID = sd.SUPERVISING_PRAC_ID
 join dbo.GROUP_GROUP_SERVICE_CLASS_PARTITIONS_NAMES_GROUPS as png on png.GROUP_ID = pg.GROUP_ID
 where (
       (pg.GROUP_TYPE in (1,2))
   and (png.GROUP_SERVICE_CLASS_PARTITION_ID = 100)
   and (png.GROUP_SERVICE_CLASS_NAME_ID = @supervisedPracGroupSvcNameID)
 )

if (@numDetailsIn != @numSameGroupFamilyCheck)
begin
  RAISERROR ('All practitioners must be within the same practice family', 11, 1)  
end

/*-------------------------------
 * All practitioners listed as
 * supervisors (note sharing = 0)
 * must be qualified to supervise
 * the supervised practitioner
 *------------------------------*/

/* Get a count of pracs where note sharing is false */

select 
  @numPracsMarkedAsSup = count(sd.SUPERVISING_PRAC_ID)
from @supDetails as sd 
where (sd.SHARE_NOTES = 0)

/* Get a count of the same who are qualified to supervise */

select 
   @numPracsAbleToSuperviseByGroup = count(sd.SUPERVISING_PRAC_ID)

from @supDetails                                           as sd
join dbo.PRACTITIONER_GROUPS                               as pg   on pg.PRACTITIONER_ID = sd.SUPERVISING_PRAC_ID
join dbo.GROUP_GROUP_SERVICE_CLASS_PARTITIONS_NAMES_GROUPS as png on png.GROUP_ID = pg.GROUP_ID
 
cross apply (
  select top 1 
    canSupervise = 1 
  from dbo.GROUP_GROUP_DIRECT_SUPERVISED_SUPERVISOR as ggdss1
  where (
        (ggdss1.SUPERVISED_GROUP_ID = @supervisedPracDispGroupID)
    and (ggdss1.SUPERVISING_GROUP_ID = png.GROUP_ID))
) as ggdss2

where (
       (pg.GROUP_TYPE in (1,2))
   and (png.GROUP_SERVICE_CLASS_PARTITION_ID = 100)
   and (sd.SHARE_NOTES = 0)
   and (ggdss2.canSupervise = 1)
)
 
/* If the counts dont match get out */

if (@numPracsAbleToSuperviseByGroup !=  @numPracsMarkedAsSup )
begin
	RAISERROR ('One or more invalid supervising practitioners', 11, 1)  
end

/*-------------------------------
 * Are there any invalid
 * dates? 
 *------------------------------*/

/*-------------------------------
 * Are there any invalid
 * dates ranges? 
 *------------------------------*/

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
 * Create new supervision tracking record
 *============================================================*/  

if (@saveType = dbo.CONST_SAVE_TYPE_NEW())
begin

  insert into dbo.PRACTITIONER_PRACTITIONER_DIRECT_SUPERVISORS (
     clientID
   , pracID
   , supervisingPracDetailsJSON 
   , created  
   , createdBy )
   
   values (

     @clientID
   , @pracID
   , @supervisingPracDetailsJSON 
   , @today
   , @userID )

  set @recordID = SCOPE_IDENTITY()
 
end

/*============================================================
 * Update existing 
 *============================================================*/  

else if (@saveType = dbo.CONST_SAVE_TYPE_EDIT())
begin
  
   set @recordID = @recID

   update dbo.PRACTITIONER_PRACTITIONER_DIRECT_SUPERVISORS
   set
       supervisingPracDetailsJSON = @supervisingPracDetailsJSON
     , lastModified               = @today  
     , lastModifedBy              = @userID
   where (
         (id       = @recordID)
     and (clientID = @clientID))
end
else
begin
   RAISERROR ('Unsupported save type', 11, 1)  
end

/*============================================================
 * Track revisions
 *============================================================*/  

insert into dbo.PRACTITIONER_PRACTITIONER_DIRECT_SUPERVISORS_REVISIONS (
     [pracPracDirSupID]
   , [supervisingPracDetailsJSON] 
   , [recordedOn]   
   , [recordedBy] )
values (
    @recordID
  , @supervisingPracDetailsJSON
  , @today
  , @userID
)

/*============================================================
 * Update the previous table we used to track this data
 *============================================================*/  

delete dbo.PRACTITIONER_PRACTITIONER_DIRECT_SUPERVISED_SUPERVISOR
where ( 
      (CLIENT_ID          = @clientID) 
  and (SUPERVISED_PRAC_ID = @pracID)
)

insert into [dbo].[PRACTITIONER_PRACTITIONER_DIRECT_SUPERVISED_SUPERVISOR] (
    CLIENT_ID
  , SUPERVISING_PRAC_ID
  , SUPERVISED_PRAC_ID
  , START_DATE
  , END_DATE
  , CREATED_ON
  , CREATED_BY
  , ACTIVE
  , SHARE_NOTES
)
select 
    [CLIENT_ID]            = @clientID
  , t2.SUPERVISING_PRAC_ID
  , [SUPERVISED_PRAC_ID]   = @pracID
  , t2.START_DATE
  , t2.END_DATE
  , [CREATED_ON]           = @today
  , [CREATED_BY]           = @userID
  , [ACTIVE]               = 1
  , t2.SHARE_NOTES
from @supDetails as t2


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

GRANT EXECUTE ON  [dbo].[PRACTITIONER_DIRECT_SUPERVISORS_SAVE] TO [webuser]
GO
