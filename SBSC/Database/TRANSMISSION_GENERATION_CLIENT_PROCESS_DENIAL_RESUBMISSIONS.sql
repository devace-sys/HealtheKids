USE [spedmon]
GO

DROP PROCEDURE if exists [dbo].[TRANSMISSION_GENERATION_CLIENT_PROCESS_DENIAL_RESUBMISSIONS]
GO

CREATE PROCEDURE [dbo].[TRANSMISSION_GENERATION_CLIENT_PROCESS_DENIAL_RESUBMISSIONS] ( 
    @generationID	as bigint
  , @userID            as bigint
)
AS    
BEGIN     
    
SET NOCOUNT ON

declare @clientID		as bigint
declare @patientID		as bigint
declare @claimID		as bigint
declare @oldestDOS		as date
declare @newestDOS		as date
declare @oldestEntry	as date
declare @newestEntry	as date
declare @claimSource    as bigint
declare @claimSubSource as bigint

declare @minIdx              as bigint
declare @maxIdx              as bigint
declare @curIdx              as bigint 
declare @dispositionRecordID as bigint
declare @msg                 as varchar(255)
declare @errorstr            as varchar(255)
declare @today               as datetime

set @today = getdate()

select top 1 
	  @clientID		  = tg.clientID
	, @patientID	  = tg.patientID
	, @claimID		  = tg.claimID
	, @oldestDOS	  = tg.oldestDOS
	, @newestDOS	  = tg.newestDOS
	, @oldestEntry	  = tg.oldestEntry
	, @newestEntry	  = tg.newestEntry
    , @claimSource    = tg.claimSource
	, @claimSubSource = tg.claimSubSource
from dbo.TRANSMISSION_GENERATIONS as tg
where (tg.id = @generationID)
     
declare @userSelectedClaimsToReSubmit as table (
    IDX            bigint identity(1,1)
  , DISPOSITION_ID bigint
  , CLAIM_ID       bigint
)

declare @automaticSelectedClaimsToReSubmit as table (
    IDX            bigint identity(1,1)
  , CLAIM_ID       bigint
)

/*################################ User Selected ################################*/

if (@claimSource = 1)
begin

  exec dbo.PRINT_STATUS_MESSAGE 'Denial Resubmission - Searching for User Selected Denied Claims'

  insert into @userSelectedClaimsToReSubmit
  select 
      DISPOSITION_ID = cdrd.ID
    , CLAIM_ID       = cdrd.CLAIM_ID
  from dbo.CLAIM_Denied_Resubmit_Disposition as cdrd
  where (   
          (cdrd.CLIENT_ID                         = @clientID)
     and  (cdrd.FLAGGED_FOR_RESUBMIT              = 1)
     and  (cdrd.RESUBMITTED_AWAITING_ADJUDICATION = 0)
     and  (cdrd.FLAGGED_DISMISSED                 = 0)
  )

  set @maxIdx = 0
  select @minIdx = min(idx) from @userSelectedClaimsToReSubmit
  select @maxIdx = max(idx) from @userSelectedClaimsToReSubmit
  select @curIdx = @minIdx

  if (@maxIdx > 0) 
  begin
    exec dbo.PRINT_STATUS_MESSAGE 'Denial Resubmission - User Selected - Starting'
  end
  else
  begin
    exec dbo.PRINT_STATUS_MESSAGE 'Denial Resubmission - No User Selected Found'
  end

  while (@curIdx <= @maxIdx)
  begin
    select top 1 
        @dispositionRecordID = t1.DISPOSITION_ID
	  , @claimID             = t1.CLAIM_ID  
    from  @userSelectedClaimsToReSubmit as t1 
    where (t1.IDX = @curIdx)
    begin try
      set @msg = 'Denial Resubmission - User Selected - Resubmitting ' + convert(varchar(50), @curIdx) + ' of ' + convert(varchar(50),@maxIdx) + ' : ' + convert(varchar(50),@claimID)
	  exec dbo.PRINT_STATUS_MESSAGE @msg
      exec dbo.CLAIM_RESUBMIT_DENIED_CORE  @claimID, 1
    end try
    begin catch
      exec dbo.PRINT_STATUS_MESSAGE 'Denial Resubmission - User Selected - Could not resubmit this claim for unknown reasons'
    end catch
	
	exec dbo.PRINT_STATUS_MESSAGE 'Denial Resubmission - User Selected - Updating disposition data'

    update dbo.CLAIM_Denied_Resubmit_Disposition 
      set   RESUBMITTED_AWAITING_ADJUDICATION = 1 
          , LAST_MODIFIED                     = @today
	      , LAST_MODIFIED_BY                  = 0 /* System */       
    where (ID = @dispositionRecordID)

    set @curIdx = @curIdx + 1
  end
  exec dbo.PRINT_STATUS_MESSAGE 'Denial Resubmission - User Selected - Completed'
end

else if (@claimSource = 2)
begin
  exec dbo.PRINT_STATUS_MESSAGE 'Denial Resubmission - No User Selected Denied Claims for retroactive claims'
end

else if (@claimSource = 3)
begin
  exec dbo.PRINT_STATUS_MESSAGE 'Denial Resubmission - No User Selected Denied Claims for CIF voids'
end

else 
begin
  exec dbo.PRINT_STATUS_MESSAGE 'Denial Resubmission - No User Selected Denied Claims for this source of claims'
end


/*################################ Automatic ################################*/

if (@claimSource = 1)
begin

  exec dbo.PRINT_STATUS_MESSAGE 'Denial Resubmission - Searching for Automatically Selected Denied Claims For Current Year'

  insert into @automaticSelectedClaimsToReSubmit
  select distinct  
    t1.CLAIM_ID
  from dbo.CLAIMS_DENIED_POSSIBLE_RESUBMIT_AUTOMATICALLY_VIEW_CORE (@clientID, @oldestDOS, @newestDOS, null) as t1

end

else if (@claimSource = 2)
begin
  exec dbo.PRINT_STATUS_MESSAGE 'Denial Resubmission - No Automatically Selected Denied Claims for retroactive claims'
end

else if (@claimSource = 3)
begin
  exec dbo.PRINT_STATUS_MESSAGE 'Denial Resubmission - No Automatically Selected Denied Claims for CIF voids'
end

else 
begin
  exec dbo.PRINT_STATUS_MESSAGE 'Denial Resubmission - No Automatically Selected Denied Claims for this source of claims'
end

/*################################ Process Automatic  ################################*/

set @maxIdx = 0
select @minIdx = min(idx) from @automaticSelectedClaimsToReSubmit
select @maxIdx = max(idx) from @automaticSelectedClaimsToReSubmit
select @curIdx = @minIdx

if (@maxIdx > 0) 
begin
	exec dbo.PRINT_STATUS_MESSAGE 'Denial Resubmission - Automatically Selected - Starting'
end
else
begin
  exec dbo.PRINT_STATUS_MESSAGE 'Denial Resubmission - Automatically Selected - No Claims Found'
end

while (@curIdx <= @maxIdx)
begin
 select top 1 
	 @claimID = t1.CLAIM_ID  
  from  @automaticSelectedClaimsToReSubmit as t1 
  where (t1.IDX = @curIdx)
  begin try
    set @msg = 'Denial Resubmission - Automatically Selected - Resubmitting ' + convert(varchar(50), @curIdx) + ' of ' + convert(varchar(50),@maxIdx) + ' : ' + convert(varchar(50),@claimID)
	exec dbo.PRINT_STATUS_MESSAGE @msg
    exec dbo.CLAIM_RESUBMIT_DENIED_CORE @claimID, 1
  end try
  begin catch
    exec dbo.PRINT_STATUS_MESSAGE 'Denial Resubmission - Automatically Selected - Could not resubmit this claim for unknown reasons'
  end catch

  set @curIdx = @curIdx + 1
end
exec dbo.PRINT_STATUS_MESSAGE 'Denial Resubmission - Automatically Selected - Complete'

RETURN(0)    
END    
    
GO
