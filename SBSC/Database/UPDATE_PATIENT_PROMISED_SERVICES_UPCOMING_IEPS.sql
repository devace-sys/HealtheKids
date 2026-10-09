USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.UPDATE_PATIENT_PROMISED_SERVICES_UPCOMING_IEPS') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.UPDATE_PATIENT_PROMISED_SERVICES_UPCOMING_IEPS
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[UPDATE_PATIENT_PROMISED_SERVICES_UPCOMING_IEPS] (
  @clientIDIn bigint
) 

AS    

BEGIN     
    
/***************************************************************************    
 * UPDATE_PATIENT_PROMISED_SERVICES_UPCOMING_IEPS */    
/**    
 * 
 ***************************************************************************/         

SET NOCOUNT ON        

BEGIN TRY

exec dbo.PRINT_STATUS_MESSAGE 'Updating promised service upcoming IEP data'

declare @clientID    as bigint       = -1
declare @clientName  as varchar(512) = ''
declare @currentDate as date         = convert(date,getdate())
declare @maxIdx      as int          = 0
declare @curIdx      as int          = 0
declare @tranOpen    as bit          = 0
declare @msg         as varchar(512) = ''

declare @clients as table (
    idx        int identity(1,1)
  , clientID   bigint
  , clientName varchar(512)
  unique clustered (idx)
)

declare @newRecs as table (
	clientID                         bigint
  , patID                            bigint
  , currentDate                      date
  , nextIEPDate                      date
  , nextIEPInDays                    int
  , startDosToSearchForRecordedAmmts datetime
  , endDosToSearchForRecordedAssmts  datetime
  , numOfHealthSvcsReqAssmt          int 
  , numOfMentalHealthSvcsReqAssmt    int
  , numOfOTSvcsReqAssmt              int
  , numOfPTSvcsReqAssmt              int
  , numOfSpeechSvcsReqAssmt          int
  , numOfOMSvcsReqAssmt              int
  , appliesToGroupSvcClassNameID2    bit
  , appliesToGroupSvcClassNameID3    bit
  , appliesToGroupSvcClassNameID4    bit
  , appliesToGroupSvcClassNameID6    bit
  , appliesToGroupSvcClassNameID9    bit
  , appliesToGroupSvcClassNameID11   bit
) 

/*============================================================
 * Get clients
 *============================================================*/  

exec dbo.PRINT_STATUS_MESSAGE 'Getting active LEA clients'

insert into @clients (clientID, clientName)
select 
    clientID = clc.CLIENT_ID 
  , clientName = clc.CLIENT_NAME
from dbo.CLIENTS_Client as clc 
where ((clc.LEA = 1)
  and ((@clientIDIn is null) or (clc.CLIENT_ID = @clientIDIn))
)
order by 
  clc.CLIENT_NAME asc

/*============================================================
 * Get loop limits
 *============================================================*/  

set @curIdx    = 1
select @maxIdx = max(clc.idx) from @clients as clc

/*============================================================
 * For each active client
 *============================================================*/  

while (@curIdx <= @maxIdx)
begin

  /* Get client to process*/

  select top 1 
     @clientID = clc.clientID 
   , @clientName = clc.clientName
  from @clients as clc 
  where 
    (clc.idx = @curIdx)

  /* Display status message */

  set @msg = 'Processing ' + convert(varchar(50),@curIdx) + ' of ' + convert(varchar(50),@maxIdx)
  exec dbo.PRINT_STATUS_MESSAGE @msg
  exec dbo.PRINT_STATUS_MESSAGE @clientName

  /* Remove old working data */
  
  exec dbo.PRINT_STATUS_MESSAGE 'Clearing old working data'
  delete @newRecs

  /* Generate updated data and save in table var.
   * Note: We do this instead of saving directly to the permanent table because
   * we want to make the clearing out of old data in the perm table and replacement with
   * new data as fast as possible.
   */
  
  exec dbo.PRINT_STATUS_MESSAGE 'Generating updated data and saving in working data'

  ;
  with
  cte_p1
  as
  (
    select 
        clientID                          = @clientID
      , patID                             = pap.PATIENT_ID
	  , currentDate                       = @currentDate
	  , nextIEPDate                       = pap.spEdNextAnnualIEPDate
      , nextIEPInDays                     = datediff(day,@currentDate,pap.spEdNextAnnualIEPDate)
	  , startDosToSearchForRecordedAmmts  = convert(datetime,(dateadd(day,-90,pap.spEdNextAnnualIEPDate)))
	  , endDosToSearchForRecordedAssmts   = convert(datetime,(pap.spEdNextAnnualIEPDate))
    from dbo.PATIENTS_Client  as pac
    join dbo.PATIENTS_Patient as pap on pap.PATIENT_ID = pac.PATIENT_ID
    where ( 
          (pac.CLIENT_ID  = @clientID)
      and (pap.spEdNextAnnualIEPDate is not null)
      and (pap.spEdNextAnnualIEPDate >= @currentDate)
      and (pap.ACTIVE = N'Y')
    )
  )
  ,
  cte_p2
  as
  (
    select 
        p1.*
	  , pps2.*
    from cte_p1 as p1
  
    /* Limits to patients that have promised service data */

    cross apply (
  
      select 
          pps1.numOfHealthSvcsReqAssmt       
	    , pps1.numOfMentalHealthSvcsReqAssmt 
	    , pps1.numOfOTSvcsReqAssmt      
	    , pps1.numOfPTSvcsReqAssmt     
        , pps1.numOfSpeechSvcsReqAssmt 
	    , pps1.numOfOMSvcsReqAssmt     
      from dbo.PATIENT_PROMISED_SERVICES_LATEST_DATA_SVCS_REQ_ASSMT (
          @clientID
        , p1.patID        
        , @currentDate
        , @currentDate) as pps1
    ) as pps2
    where
      (p1.nextIEPInDays between 0 and 45)
  )
  ,
  cte_p3
  as
  (
      select 
        p2.* 
      , appliesToGroupSvcClassNameID2  = convert(bit,(iif((p2.numOfMentalHealthSvcsReqAssmt > 0),1,0)))
      , appliesToGroupSvcClassNameID3  = convert(bit,(iif((p2.numOfHealthSvcsReqAssmt > 0),1,0)))
      , appliesToGroupSvcClassNameID4  = convert(bit,(iif((p2.numOfOTSvcsReqAssmt > 0),1,0)))
      , appliesToGroupSvcClassNameID6  = convert(bit,(iif((p2.numOfPTSvcsReqAssmt > 0),1,0)))
      , appliesToGroupSvcClassNameID9  = convert(bit,(iif((p2.numOfSpeechSvcsReqAssmt > 0),1,0)))
      , appliesToGroupSvcClassNameID11 = convert(bit,(iif((p2.numOfOMSvcsReqAssmt > 0),1,0)))
    from cte_p2 as p2
  )

  insert into @newRecs (
      clientID 
    , patID    
    , currentDate
    , nextIEPDate
    , nextIEPInDays
    , startDosToSearchForRecordedAmmts 
    , endDosToSearchForRecordedAssmts
    , numOfHealthSvcsReqAssmt 
    , numOfMentalHealthSvcsReqAssmt
    , numOfOTSvcsReqAssmt 
    , numOfPTSvcsReqAssmt 
    , numOfSpeechSvcsReqAssmt 
    , numOfOMSvcsReqAssmt 
    , appliesToGroupSvcClassNameID2
    , appliesToGroupSvcClassNameID3
    , appliesToGroupSvcClassNameID4
    , appliesToGroupSvcClassNameID6
    , appliesToGroupSvcClassNameID9
    , appliesToGroupSvcClassNameID11
  )
  select 
      clientID 
    , patID    
    , currentDate
    , nextIEPDate
    , nextIEPInDays
    , startDosToSearchForRecordedAmmts 
    , endDosToSearchForRecordedAssmts
    , numOfHealthSvcsReqAssmt 
    , numOfMentalHealthSvcsReqAssmt
    , numOfOTSvcsReqAssmt 
    , numOfPTSvcsReqAssmt 
    , numOfSpeechSvcsReqAssmt 
    , numOfOMSvcsReqAssmt  
    , appliesToGroupSvcClassNameID2 
    , appliesToGroupSvcClassNameID3 
    , appliesToGroupSvcClassNameID4 
    , appliesToGroupSvcClassNameID6 
    , appliesToGroupSvcClassNameID9 
    , appliesToGroupSvcClassNameID11
  from cte_p3 as p3

  begin transaction
    set @tranOpen = 1

    exec dbo.PRINT_STATUS_MESSAGE 'Deleting previous cached data'

    delete dbo.PATIENT_PROMISED_SERVICES_UPCOMING_IEPS
    where (clientID = @clientID)

    exec dbo.PRINT_STATUS_MESSAGE 'Saving new data'

    insert into dbo.PATIENT_PROMISED_SERVICES_UPCOMING_IEPS (
        clientID 
      , patID    
      , currentDate
      , nextIEPDate
      , nextIEPInDays
      , startDosToSearchForRecordedAmmts 
      , endDosToSearchForRecordedAssmts
      , numOfHealthSvcsReqAssmt 
      , numOfMentalHealthSvcsReqAssmt
      , numOfOTSvcsReqAssmt 
      , numOfPTSvcsReqAssmt 
      , numOfSpeechSvcsReqAssmt 
      , numOfOMSvcsReqAssmt 
      , appliesToGroupSvcClassNameID2
      , appliesToGroupSvcClassNameID3
      , appliesToGroupSvcClassNameID4
      , appliesToGroupSvcClassNameID6
      , appliesToGroupSvcClassNameID9
      , appliesToGroupSvcClassNameID11
    )
    select 
        clientID 
      , patID    
      , currentDate
      , nextIEPDate
      , nextIEPInDays
      , startDosToSearchForRecordedAmmts 
      , endDosToSearchForRecordedAssmts
      , numOfHealthSvcsReqAssmt 
      , numOfMentalHealthSvcsReqAssmt
      , numOfOTSvcsReqAssmt 
      , numOfPTSvcsReqAssmt 
      , numOfSpeechSvcsReqAssmt 
      , numOfOMSvcsReqAssmt  
      , appliesToGroupSvcClassNameID2 
      , appliesToGroupSvcClassNameID3 
      , appliesToGroupSvcClassNameID4 
      , appliesToGroupSvcClassNameID6 
      , appliesToGroupSvcClassNameID9 
      , appliesToGroupSvcClassNameID11
    from @newRecs
  commit transaction
  
  set @tranOpen = 0

  set @curIdx = @curIdx + 1

end /* While */ 

/*============================================================
 * Done
 *============================================================*/  

exec dbo.PRINT_STATUS_MESSAGE 'Done'

RETURN(0)    
END TRY    
BEGIN CATCH    
    
  /*-------------------------------    
   * If we end up here something    
   * went wrong.  Cancel any pending    
   * transactions and return any    
   * error any error messages to    
   * the caller    
   *------------------------------*/    

  if (@tranOpen = 1) rollback transaction

  -- Error or raise error with severity 11 to 19 will be caught here          
      
  DECLARE @ErrorMessage  AS NVARCHAR(4000)    
  DECLARE @ErrorSeverity AS INT    
  DECLARE @ErrorState    AS INT    
      
  SELECT  @ErrorMessage  = ERROR_MESSAGE(),    
          @ErrorSeverity = ERROR_SEVERITY(),    
          @ErrorState    = ERROR_STATE()    
      
  SET @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ']'    
      
  -- Reraise the error so it returns back to the server    
      
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
    
END CATCH    
END    
    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[UPDATE_PATIENT_PROMISED_SERVICES_UPCOMING_IEPS] TO [webuser]
GO
