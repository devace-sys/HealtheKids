use SPEDMON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].CYBHI_TRANSMISSION_GENERATION_UPDATE_SERVICE_RECORDS_AND_CLAIMS') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop PROCEDURE dbo.CYBHI_TRANSMISSION_GENERATION_UPDATE_SERVICE_RECORDS_AND_CLAIMS
GO

/*---------------------------------------------------------------------------------------------------------*/

CREATE PROCEDURE dbo.CYBHI_TRANSMISSION_GENERATION_UPDATE_SERVICE_RECORDS_AND_CLAIMS (  
     @transmissionID bigint    
   , @userID         bigint   
)
AS
BEGIN

  set nocount on
  
  declare @today as datetime = getdate()
  
  declare @svcRecs as table (
     svcRecID bigint
	 unique clustered (svcRecID)     
  )

  declare @claims as table (
    claimID bigint     
    unique clustered (claimID)
  )

  /*---------------------------------------------------------------------------------------------------------*/

  exec dbo.PRINT_STATUS_MESSAGE 'Get distinct service records'

  insert into @svcRecs (svcRecID)
  select distinct
      t1.svcRecID    
  from dbo.CYBHI_TRANSMISSION_GENERATION_GET_CLAIMS (@transmissionID, 0 /* Claims not held*/) as t1
  option(recompile)

  /*---------------------------------------------------------------------------------------------------------*/

  exec dbo.PRINT_STATUS_MESSAGE 'Get distinct claim records'
  
  insert into @claims (claimID)
  select distinct
      t1.claimID
  from dbo.CYBHI_TRANSMISSION_GENERATION_GET_CLAIMS (@transmissionID, 0 /* Claims not held */) as t1
  option(recompile)

  /*---------------------------------------------------------------------------------------------------------*/
  
  set @today = getdate()
  
  /*---------------------------------------------------------------------------------------------------------*/
    
  exec dbo.PRINT_STATUS_MESSAGE 'Update claim record status'

  update clm
  set
      clm.txStatusCode     = 2
	, clm.lastModified     = @today
	, clm.lastModifiedBy   = @userID
	, clm.numOfSubmissions = clm.numOfSubmissions + 1
  from @claims            as t1
  join dbo.CYBHI_CLAIMS   as clm on clm.id = t1.claimID
  option(recompile)
        
  /*---------------------------------------------------------------------------------------------------------*/

  exec dbo.PRINT_STATUS_MESSAGE 'Update service record status'

  update sr     
  set 
      sr.state        = dbo.CONST_SVC_REC_STATE_SUB()
    , sr.lastmodified = @today        
  from @svcRecs            as trc
  join dbo.SERVICE_RECORDS as sr  on sr.id = trc.svcRecID
  option(recompile)

  /*---------------------------------------------------------------------------------------------------------*/
	      
  exec dbo.PRINT_STATUS_MESSAGE 'Update service record audit log'
      
  INSERT INTO dbo.SERVICE_RECORDS_AUDIT_LOG (
      svcRecID    
    , loggedOn    
    , userID   
    , [state]
  )    
  select     
       sr.svcRecID     as id
     , @today	 	   as loggedOn     
     , @userID	       as userID     
     , dbo.CONST_SVC_REC_STATE_SUB()	as [state]     
  from @svcRecs	as sr 
  option(recompile)

  /*---------------------------------------------------------------------------------------------------------*/

  exec dbo.PRINT_STATUS_MESSAGE 'Update resubmit log (if applicable)'
  
  update t1
  set 
      t1.resubmitted    = 1
    , t1.transmissionID = @transmissionID
    , t1.lastModified   = @today
    , t1.lastModifiedBy = @userID
  from CYBHI_RESUBMIT_LOG_PREVIOUSLY_ADJUDICATED_SERVICE_RECORD_CLAIMS as t1
  join @svcRecs                                                        as t2 on t2.svcRecID = t1.svcRecID
  where 
    (t1.resubmitted = 0)
  option(recompile)

  /*---------------------------------------------------------------------------------------------------------*/

  return(0)

END
GO
