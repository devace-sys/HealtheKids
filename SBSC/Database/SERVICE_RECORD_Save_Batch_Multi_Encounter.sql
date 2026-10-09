USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_RECORD_Save_Batch_Multi_Encounter') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.SERVICE_RECORD_Save_Batch_Multi_Encounter
GO


IF EXISTS (SELECT * FROM sys.table_types WHERE name = 'SvcDetailsMultiEncounter')
DROP TYPE SvcDetailsMultiEncounter
GO

/*-------------------------------
 * Object Definitions
 *------------------------------*/

CREATE TYPE SvcDetailsMultiEncounter AS TABLE (
   dos         datetime
  ,nummins1    INT
  ,nummins2    INT
  ,nummins3    INT
  ,nummins4    INT
  ,nummins5    INT
  ,nummins6    INT
  ,nummins7    INT
  ,nummins8    INT
  ,nummins9    INT
  ,nummins10   INT
)
GO


CREATE PROCEDURE [dbo].[SERVICE_RECORD_Save_Batch_Multi_Encounter] (
    @userID        BIGINT
  , @userGroup     INT  
  , @userRank      INT    
  , @reference     VARCHAR(500)
  , @clientID      INT
  , @pracID        INT    
  , @patID         INT    
  , @isIFSPorIEP   BIT
  , @nameID        INT   
  
  , @hasOrpDocID   BIT
  , @orpDocID      BIGINT
 
  , @hasSvcDetailFlags BIT
  , @svcDetFlag1       BIT
  , @svcDetFlag2       BIT
  , @svcDetFlag3       BIT
  , @svcDetFlag4       BIT
  , @dosMulti      varchar(1000)   
  , @svcdetails    SvcDetailsMultiEncounter READONLY
  , @editDelReason VARCHAR(7000)
  , @validateRec   BIT
  , @saveType      INT
  , @recID         BIGINT
  , @msgDupRec          VARCHAR(1000)
  , @msgInvCombo        VARCHAR(1000)    
  , @MsgNoRec           VARCHAR(1000)     
  , @MsgNoEdit          VARCHAR(1000)     
  , @MsgDataError       VARCHAR(1000)    
  , @MsgMinReq          VARCHAR(1000)    
  , @MsgMinDef          VARCHAR(1000)     
  , @MsgMilReq          VARCHAR(1000)    
  , @MsgPatElg          VARCHAR(1000)
  , @MsgPatDOBGteDOS    VARCHAR(1000)
  , @MsgNotActive       VARCHAR(1000)
  , @MsgPatAbsent       VARCHAR(1000) 
  , @MsgFutureDOS       VARCHAR(1000)
  , @spDetails          VARCHAR(8000) OUTPUT
  , @recordID           BIGINT        OUTPUT)    
AS    
BEGIN     
    
/***************************************************************************    
 * SERVICE_RECORD_Save_Batch_Multi_Encounter */    
/**    
 ***************************************************************************/         
     
SET NOCOUNT ON    
      
DECLARE @tranOpen      AS BIT            -- Is a transaction open    
DECLARE @dosVal        AS DATETIME
DECLARE @numMin        AS INT
DECLARE @dosVals       AS TABLE([id] int, [date] datetime)  
DECLARE @encNum        AS INT
DECLARE @numDates      AS INT
DECLARE @notes         as varchar(7000)
DECLARE @spDetailsTemp AS VARCHAR(8000)
DECLARE @numDupDates   AS INT
DECLARE @retry         AS INT             -- Deadlock retry counter


SET @retry = 5

WHILE (@retry > 0)
BEGIN 

BEGIN TRY    

/*-------------------------------    
 * Create unique batch ID
 *------------------------------*/

DECLARE @batchID       AS UNIQUEIDENTIFIER = null
DECLARE @batchIDRecID  AS BIGINT           = null

exec SERVICE_RECORD_BATCH_ID_Create @userID, @userGroup, @userRank, @saveType, @validateRec, @batchIDRecID OUTPUT , @batchID OUTPUT  

/*-------------------------------    
 * Init our details return
 *------------------------------*/
 
SET @spDetails = ''

/*-------------------------------    
 * Check to see if multidate is
 * allowed for the save type
 *------------------------------*/
   
IF (@saveType <> dbo.CONST_SAVE_TYPE_NEW())  
  RAISERROR ('Multiple DOS entry is only allowed for new records', 11, 1)
   
/*-------------------------------    
 * Parse multidate value into
 * individual dates
 *------------------------------*/

INSERT INTO @dosVals
  SELECT [id],[date] FROM dbo.MULTI_DATE_PARSE(@dosMulti,',')

/*-------------------------------    
 * Get number of dates
 * Exit with an error if there
 * are none.
 *------------------------------*/

SELECT @numDates = COUNT(id) FROM @dosVals

IF (@numDates = 0) 
  RAISERROR ('One or more dates are required', 11, 1) 
  
/*-------------------------------    
 * Check for duplicate dates
 * Exit with an error if there
 * are dups.
 *------------------------------*/

SET @numDupDates = 0
SELECT @numDupDates = COUNT([id]) FROM @dosVals GROUP BY [date] HAVING COUNT([id]) > 1

IF (@numDupDates > 0) 
  RAISERROR ('Duplicate dates are not allowed', 11, 1) 
  
/*-------------------------------    
 * Normalize entry data
 * Note: Keep this in the retry 
 * loop as we need the declare
 * to reset the identity
 *------------------------------*/

declare @numDetails    as bigint
declare @minIdx        as bigint
declare @maxIdx        as bigint
declare @curIdx        as bigint

declare @svcDetailsNormalized as table (
    idx       bigint identity(1,1)
  , dos       datetime
  , encounter int
  , nummins   int
)

insert into @svcDetailsNormalized
select 
     dos
   , encounter
   , nummins
from
(
            select dos, encounter=1,  nummins = nummins1  from @svcdetails
  union all select dos, encounter=2,  nummins = nummins2  from @svcdetails 
  union all select dos, encounter=3,  nummins = nummins3  from @svcdetails 
  union all select dos, encounter=4,  nummins = nummins4  from @svcdetails 
  union all select dos, encounter=5,  nummins = nummins5  from @svcdetails 
  union all select dos, encounter=6,  nummins = nummins6  from @svcdetails 
  union all select dos, encounter=7,  nummins = nummins7  from @svcdetails 
  union all select dos, encounter=8,  nummins = nummins8  from @svcdetails 
  union all select dos, encounter=9,  nummins = nummins9  from @svcdetails 
  union all select dos, encounter=10, nummins = nummins10 from @svcdetails 
) as t1
where (nummins is not null)
order by 
  dos
, encounter
  
/*-------------------------------    
 * If we have all blank num mins
 * for every detail, let the user 
 * know and get out
 *------------------------------*/

select @numDetails = COUNT(idx) from @svcDetailsNormalized

IF (@numDetails = 0) 
  RAISERROR ('All of the dates have no minutes', 11, 1) 

declare @numBlankDOS as int

select @numBlankDOS = COUNT (t1.id)
from @dosVals as t1  
left join  @svcDetailsNormalized as t2 on t2.dos = t1.date
where (t2.idx is null)

if (@numBlankDOS > 0)
  RAISERROR ('One or more dates has no minutes', 11, 1) 

select @minIdx     = min(idx) from @svcDetailsNormalized
select @maxIdx     = max(idx) from @svcDetailsNormalized 
set @curIdx  = @minIdx


/*-------------------------------    
 * If this is an actual save
 * or edit begin a transaction
 *------------------------------*/  

IF (@validateRec = 0)
BEGIN

  BEGIN TRANSACTION    
  SET @TranOpen  = 1
       
END
ELSE
  SET @TranOpen = 0  

/*-------------------------------    
 * Create service record(s)
 *------------------------------*/

while (@curIdx <= @maxIdx)
begin

  select top 1 
      @dosVal = dos
    , @encNum = encounter
    , @numMin = nummins
  from @svcDetailsNormalized
  where (idx = @curIdx)
      
  set @notes = ''
  --set @notes = 'ENC #: ' + CONVERT(varchar(50),@encNum)
  
  /*-------------------------------    
   * Create service record      
   *------------------------------*/  

  SET @spDetailsTemp = ''
  
  EXEC dbo.SERVICE_RECORD_Save_Core
      @userID 
    , @userGroup
    , @userRank
	, 1 /* Claimable */
    , 7
    , @reference
    , null
    , null  
    , @dosVal   
    , @clientID
    , @pracID    
    , @patID
    , @isIFSPorIEP
    , @nameID
    
    , @hasOrpDocID
    , @orpDocID 
    , null
    
    , @hasSvcDetailFlags
    , @svcDetFlag1
    , @svcDetFlag2
    , @svcDetFlag3
    , @svcDetFlag4
    , null
    , @numMin
    , null    
    , null    
    , null    
    , null    
    , null    
    , null    
    , null    
    , null
    , 0
	, 0
	, 0
	, null /* @attendanceSelectionID*/
    , @notes
	, null
	, null
	, null
	, 0 /* goal track*/
	, 1 /* Billing program id (TODO: Add this parm) */
	, 0    /* Has fillable pdf (TODO: Add these 3 parms) */
    , '[]' /* Fillable pdf selections */
	, '[]' /* Fillable pdf answers*/

    , @editDelReason
    , @validateRec
    , @saveType
    , @recID 
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
    , @recordID      OUTPUT 

  /*-------------------------------    
   * Assign unique batch ID
   *------------------------------*/

  DECLARE @batchIDAssRecID  AS BIGINT = null

  exec SERVICE_RECORD_BATCH_ID_Assign 
    @userID, @userGroup, @userRank, @saveType, @validateRec, @batchID, @curIdx, @recordID, @batchIDAssRecID OUTPUT  

   set @curIdx = @curIdx + 1
   set @spDetails = @spDetails + ltrim(rtrim(@spDetailsTemp))
        
end 

/*-------------------------------    
 * Return the number of records
 * created as the recordID
 *------------------------------*/  

set @recordID = @maxIdx

/*-------------------------------    
 * If this was an actual save
 * or edit commit the transaction
 *------------------------------*/  

IF (@TranOpen = 1) COMMIT TRANSACTION    

/*-------------------------------    
 * Reset our transaction flag and
 * retry counter
 *------------------------------*/  

SET @TranOpen = 0    
SET @retry    = 0
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
   * If the error is a deadlock 
   * retry until retrys are exhausted
   *------------------------------*/    
  
  IF (ERROR_NUMBER() = 1205)
     SET @retry = @retry - 1;
  ELSE
    SET @retry = -1;
  
  /*-------------------------------    
   * Return the error message to
   * the caller.  This includes
   * deadlocks that have been 
   * unresolved after retrying.
   *------------------------------*/    
 
  IF (@retry < 0) RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
    
END CATCH    
END -- while

END  
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON TYPE::SvcDetailsMultiEncounter TO [webuser]
GRANT EXECUTE ON  [dbo].[SERVICE_RECORD_Save_Batch_Multi_Encounter] TO [webuser]
GO
