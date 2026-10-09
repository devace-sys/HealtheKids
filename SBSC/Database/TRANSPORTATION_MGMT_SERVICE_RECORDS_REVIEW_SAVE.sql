USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.TRANSPORTATION_MGMT_SERVICE_RECORDS_REVIEW_SAVE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.TRANSPORTATION_MGMT_SERVICE_RECORDS_REVIEW_SAVE
GO

IF EXISTS (SELECT * FROM sys.table_types WHERE name = 'TransportationMgmtServiceRecordReviewDetails')
DROP TYPE TransportationMgmtServiceRecordReviewDetails
GO

/*-------------------------------
 * Object Definitions
 *------------------------------*/

CREATE TYPE TransportationMgmtServiceRecordReviewDetails AS TABLE
(
    svcRecID       bigint        /* Label */
  , dosStr         varchar(50)   /* Label */
  , milesStr       varchar(50)   /* Label */
  , okToBill       bit
  , notes          varchar(max)  
)
GO

CREATE PROCEDURE [dbo].[TRANSPORTATION_MGMT_SERVICE_RECORDS_REVIEW_SAVE]     
 (@userID          BIGINT,    
  @userGroup       INT,    
  @userRank        INT,    
  @clientID        BIGINT,      
  @patID           BIGINT,
  @startDate       DATETIME,
  @endDate         DATETIME,  
  @svcDetails      TransportationMgmtServiceRecordReviewDetails READONLY,
  @editDelReason   VARCHAR(7000),    
  @validateRec     BIT,    
  @saveType        INT,    
  @recID           BIGINT,    
  @MsgNoRec        VARCHAR(1000),
  @MsgNoEdit       VARCHAR(1000),
  @MsgDupRec       VARCHAR(1000),
  @MsgDataError    VARCHAR(1000),
  @MsgNotActive    VARCHAR(1000),  
  @spDetails       VARCHAR(8000) OUTPUT,    
  @recordID        BIGINT        OUTPUT )    
AS    
BEGIN     
    
/***************************************************************************    
 * TRANSPORTATION_MGMT_SERVICE_RECORDS_REVIEW_SAVE */    
/**    
 *                         
 ***************************************************************************/         
     
SET NOCOUNT ON    
      
declare @tranOpen            as bit 
declare @today               as datetime
declare @detailMsg           as varchar (1000)
declare @detailsCount        as int

declare @svcDetailsWorking   as table (
    svcRecID       bigint       
  , dosStr         varchar(50)  
  , milesStr       varchar(50)
  , okToBill       bit
  , notes          varchar(max)
  , newDetail      bit) 

/*============================================================
 * Init
 *============================================================*/  

set @spDetails = ''
set @recordID  = 0
set @today     = GETDATE()

BEGIN TRY

/*============================================================
 * Count details provided
 * Get out if none
 *============================================================*/  
 
set @detailsCount = 0

select 
  @detailsCount = isnull(COUNT(svcRecID ),0)
from @svcDetails

if (@detailsCount = 0)
begin
  RAISERROR ('There were no details provided', 11, 1)
end

/*============================================================
 * Get working data
 *============================================================*/  

insert into @svcDetailsWorking
select 
   t1.*
  ,t2.newDetail 
from @svcDetails as t1
join dbo.TRANSPORTATION_MGMT_SERVICE_RECORDS_REVIEW_VIEW_CORE (
   @userID
  ,@userGroup
  ,@userRank 
  ,@clientID
  ,@patID 
  ,@startDate
  ,@endDate) as t2 on t2.svcRecID = t1.svcRecID

/*============================================================
 * Validation
 *============================================================*/  

if (@validateRec = 1) 
begin
  return (0)
end


SET @TranOpen = 1
BEGIN TRANSACTION

/*============================================================
 * Add review records that dont already exist
 *============================================================*/  

insert into dbo.TRANSPORTATION_MGMT_SERVICE_RECORDS_REVIEWED
select 
    CLIENT_ID   = @clientID 
  , PATIENT_ID  = @patID
  , SVC_REC_ID  = svcRecID
  , OK_TO_BILL  = okToBill
  , NOTES       = notes
  , REVIEWED_ON = @today
  , REVIEWED_BY = @userID
  , LAST_UPDATED_ON = null
  , LAST_UPDATED_BY = null
from  @svcDetailsWorking 
where (newDetail = 1)

delete @svcDetailsWorking where (newDetail = 1)

/*============================================================
 * And update existing records
 *============================================================*/  

UPDATE
    Table_A
SET
    Table_A.OK_TO_BILL = Table_B.okToBill
    ,Table_A.NOTES      = Table_B.notes
   , TABLE_A.LAST_UPDATED_ON = @today
   , TABLE_A.LAST_UPDATED_BY = @userID 
FROM
    dbo.TRANSPORTATION_MGMT_SERVICE_RECORDS_REVIEWED AS Table_A
    INNER JOIN @svcDetailsWorking AS Table_B ON Table_A.SVC_REC_ID = Table_B.svcRecID
WHERE
    (1=1)
COMMIT TRANSACTION
SET @TranOpen = 0    
RETURN(0)    

END TRY    

/*-------------------------------    
 * If we end up here something    
 * went wrong
 *------------------------------*/    

BEGIN CATCH    
  
  IF (@tranOpen = 1)
  BEGIN
    ROLLBACK TRANSACTION
    SET @tranOpen = 0
  END
  
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

GRANT EXECUTE ON TYPE::TransportationMgmtServiceRecordReviewDetails TO [webuser]
GRANT EXECUTE ON  [dbo].[TRANSPORTATION_MGMT_SERVICE_RECORDS_REVIEW_SAVE] TO [webuser]
GO
