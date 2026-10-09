USE SPEDMON
GO

/*-------------------------------
 * Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SVCJOURNAL_JOURNALS_AUTO_CLOSE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.SVCJOURNAL_JOURNALS_AUTO_CLOSE
GO

/*-------------------------------
 * Create 
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[SVCJOURNAL_JOURNALS_AUTO_CLOSE] 
AS    
BEGIN     
    
/***************************************************************************    
 * SVCJOURNAL_JOURNAL_AUTO_CLOSE */    
/**    
 * Performs autoclose of open journals
 *    
 ***************************************************************************/         
     
declare @journalsToClose as table (
    idx        bigint
  , journalID  bigint
  , clientID   bigint
  , clientName varchar(512)
  , patID      bigint
  , patName    varchar(512)
  , dos        date
  , userID     bigint
  , userGroup  int
  , userRank   int
  , userIP     varchar(500)
  , pracID     bigint
  unique clustered (idx)
)

declare @minIdx              as bigint
declare @maxIdx              as bigint
declare @curIdx              as bigint
declare @journalID           as bigint
declare @userID              as bigint
declare @userGroup           as int
declare @userRank            as int
declare @clientID            as BIGINT
declare @clientName          as varchar(512) 
declare @pracID              as BIGINT
declare @patID               as BIGINT
declare @patName             as varchar(512)
declare @dos                 as date
declare @reference           as VARCHAR(500)       
    
declare @editDelReason       as VARCHAR(7000)  = ''
declare @validateRec         as BIT            = 0
declare @saveType            as INT            = dbo.CONST_SAVE_TYPE_NEW()
declare @MsgNoRec            as VARCHAR(1000)  = 'No record found'
declare @MsgNoEdit           as VARCHAR(1000)  = 'Cannot edit or delete record'
declare @MsgDupRec           as VARCHAR(1000)  = 'Duplicate record'
declare @MsgDataError        as VARCHAR(1000)  = 'Data error'
declare @MsgNotActive        as VARCHAR(1000)  = 'Record not active'
declare @msgInvCombo         as VARCHAR(1000)  = 'Invalid prac, pat, svc data'
declare @MsgMinReq           as VARCHAR(1000)  = 'Minutes required'  
declare @MsgMinDef           as VARCHAR(1000)  = 'Less than 7 mins entered'
declare @MsgMilReq           as VARCHAR(1000)  = 'Miles required'
declare @MsgPatElg           as VARCHAR(1000)  = 'Patient may not be elig'
declare @MsgPatDOBGteDOS     as VARCHAR(1000)  = 'DOB is greater than DOS'
declare @MsgPatAbsent        as VARCHAR(1000)  = 'Patient is absent'
declare @MsgFutureDOS        as VARCHAR(1000)  = 'Dos cannot be in future'
declare @msgStatus           as varchar(8000)
declare @spDetails           as VARCHAR(8000)
declare @recordID            as BIGINT       
declare @sucCount            as bigint
declare @errCount            as bigint
declare @procLogRecID        as bigint
declare @openJournalData     as xml
declare @autoCloseLogRecId   as bigint
set NOCOUNT ON    

set @spDetails    = ''
set @recordID     = 0
set @sucCount     = 0
set @errCount     = 0
set @procLogRecID = null

RAISERROR ('Autoclose journals', 0, 1) WITH NOWAIT   
insert into dbo.SvcJournals_Auto_Close_Procedure_Log (runStartOn) values (GETDATE())
set @procLogRecID = SCOPE_IDENTITY()


RAISERROR ('Retrieving journals', 0, 1) WITH NOWAIT   
set @openJournalData = dbo.SvcJournal_Generate_Open_Journals_Data(null)
update dbo.SvcJournals_Auto_Close_Procedure_Log set openJournalData = @openJournalData where (id = @procLogRecID)

insert into @journalsToClose
select * from dbo.SvcJournal_Open_Journals_Data_Extract_Journals_To_Close(@openJournalData)

select @minIdx = isnull(MIN(idx),0) from @journalsToClose
select @maxIdx = isnull(MAX(idx),0) from @journalsToClose
set @curIdx = 1

set @msgStatus = CONVERT(varchar(1000),@maxIdx) + ' journals to close'
RAISERROR (@msgStatus, 0, 1) WITH NOWAIT   
update dbo.SvcJournals_Auto_Close_Procedure_Log set totalCount = @maxIdx where (id = @procLogRecID)


while (@curIdx <= @maxIdx)
begin
  
  begin try
  
    set @spDetails = ''
    set @msgStatus = ''
    set @recordID  = 0

    select top 1
        @journalID  = journalID
      , @userID     = userID
      , @userGroup  = userGroup
      , @userRank   = userRank
      , @clientID   = clientID
      , @clientName = clientName
      , @pracID     = pracID
      , @patID      = patID
      , @patName    = patName
      , @dos        = dos
      , @reference  = userIP
    from @journalsToClose 
    where (idx = @curIdx)
  
    set @msgStatus = 'Closing '
                   + ' - ' + @clientName 
                   + ' - ' + @patName 
                   + ' - ' + dbo.RPT_DATE_FMT(@dos) 
                   + ' - ' + CONVERT(varchar,@journalID)
    
    RAISERROR (@msgStatus, 0, 1) WITH NOWAIT   
    
    set @autoCloseLogRecId = null
    
    insert into dbo.SvcJournal_Auto_Close_Log (
    
      procedureRunLogID
    , countIdx
    , journalID
    , startedCloseOn
    , statusMsg ) 
    
    values (
        @procLogRecID
      , @curIdx
      , @journalID
      , GETDATE()
      , @msgStatus
    ) 
    
    set @autoCloseLogRecId = SCOPE_IDENTITY()
    
    exec SVCJOURNAL_JOURNAL_CLOSE     
        @userID              
      , @userGroup           
      , @userRank            
      , @clientID            
      , @pracID              
      , @patID               
      , @reference           
      , @editDelReason       
      , @validateRec         
      , @saveType            
      , @journalID               
      , @MsgNoRec            
      , @MsgNoEdit           
      , @MsgDupRec           
      , @MsgDataError        
      , @MsgNotActive        
      , @msgInvCombo         
      , @MsgMinReq           
      , @MsgMinDef           
      , @MsgMilReq           
      , @MsgPatElg           
      , @MsgPatDOBGteDOS     
      , @MsgPatAbsent        
      , @MsgFutureDOS        
      , @spDetails       OUTPUT    
      , @recordID        OUTPUT
    
      update dbo.SvcJournal_Auto_Close_Log
      set 
          spDetails = @spDetails
        , retState  = dbo.CONST_RET_SUCCESS()
      where (id = @autoCloseLogRecId)
       
      set @sucCount = @sucCount + 1

    end try
    
    
    begin catch
      
      set @errCount = @errCount + 1
      
      declare @ErrorMessage  as NVARCHAR(4000)    
      declare @ErrorSeverity as INT    
      declare @ErrorState    as INT    
      
      set @ErrorMessage = ''
      
      select  @ErrorMessage  = ERROR_MESSAGE(),    
              @ErrorSeverity = ERROR_SEVERITY(),    
              @ErrorState    = ERROR_STATE()    
   
      
      set @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ']'    
      
      print @ErrorMessage
      
      update dbo.SvcJournal_Auto_Close_Log
      set 
          errorMessage = @ErrorMessage
        , retState  = dbo.CONST_RET_ERR()
      where (id = @autoCloseLogRecId)
            
    end catch

    update dbo.SvcJournal_Auto_Close_Log 
      set completedCloseOn = GETDATE() 
    where (id = @autoCloseLogRecId)

    set @curIdx = @curIdx + 1

end

update dbo.SvcJournals_Auto_Close_Procedure_Log 
set 
   successCount = @sucCount
 , errorCount   = @errCount
,  runEndOn     = getdate()
where (id = @procLogRecID)

if (@errCount > 0) RETURN(1)
RETURN(0)    

END    
    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[SVCJOURNAL_JOURNALS_AUTO_CLOSE] TO [webuser]
GO
