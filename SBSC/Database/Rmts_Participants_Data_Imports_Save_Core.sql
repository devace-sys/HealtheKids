USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Rmts_Participants_Data_Imports_Save_Core') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.Rmts_Participants_Data_Imports_Save_Core
GO


/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[Rmts_Participants_Data_Imports_Save_Core] (
   @userID                 bigint
 , @userGroup              int
 , @userRank               int     
 , @clientID               bigint
 , @fyQuarterID			   bigint
 , @structuredDataImportID bigint
 , @validateRec            bit
 , @spDetails              VARCHAR(8000) OUTPUT    
 , @recordID               BIGINT        OUTPUT
)    
AS    
BEGIN     

     
SET NOCOUNT ON    

BEGIN TRY    

declare @today            as datetime
declare @importDataJSON   as varchar(max) = ''
declare @numImportRecords as int = 0

/*-------------------------------    
 * Init     
 *------------------------------*/    

set @today            = getdate()
set @spDetails        = ''    
set @recordID         = 0 
set @numImportRecords = 0

/*-------------------------------    
 * Verify all parameters that    
 * indicate what type of operation    
 * to perform have been passed in    
 * and any other parms that are    
 * neccessary for proper operation    
 *------------------------------*/    

IF (@userID      IS NULL) RAISERROR ('userID is required',      11, 1)      
IF (@userGroup   IS NULL) RAISERROR ('userGroup is required',   11, 1)    
IF (@userRank    IS NULL) RAISERROR ('userRank is required',    11, 1)    
IF (@validateRec IS NULL) RAISERROR ('Validate flag required',  11, 1)    

IF (@clientID               IS NULL) RAISERROR ('Client id is required',   11, 1)
IF (@fyQuarterID            IS NULL) RAISERROR ('Fiscal quarter id is required',   11, 1)
IF (@structuredDataImportID IS NULL) RAISERROR ('Structured data import id is required',   11, 1)

select top 1  
  @importDataJSON = sdi.importDataJSON
from dbo.Structured_Data_Imports as sdi
where (
      (sdi.id = @structuredDataImportID)
  and (sdi.clientID = @clientID)
)
  
/*-------------------------------    
 * Exit if we are validating
 *------------------------------*/    

if (@validateRec = 1)
begin
  return(0)
end

/*-------------------------------    
 * Save imported data header
 * record    
 *------------------------------*/    
  
INSERT INTO dbo.Rmts_Participants_Data_Imports (
    structuredDataImportID
  , clientID
  , fyQuarterID
  , fileAccepted
  , fileAcceptedOn  
  , fileProcessingCompleted
  , created
  , createdBy
  , active
) 
values (
    @structuredDataImportID
  , @clientID
  , @fyQuarterID
  , 1
  , @today
  , 0
  , @today
  , @userID
  , 1
)

declare @RmtsParticipantsDataImportID bigint = SCOPE_IDENTITY();
set @recordID = @RmtsParticipantsDataImportID;

/*-------------------------------    
 * Extract records and save
 *------------------------------*/    

insert into dbo.Rmts_Participants_Data_Imports_Records
(
	  dataImportID       
	, lastName  
	, firstName 
	, middleName
	, title
	, email
	, startDate
	, endDate
)
select
    dataImportID = @RmtsParticipantsDataImportID 
  , t1.lastName  
  , t1.firstName 
  , t1.middleName
  , t1.title
  , t1.email
  , t1.startDate
  , t1.endDate
FROM OPENJSON( @importDataJSON, '$."structuredDataRows"' ) 
WITH (
      [rowBad]             bit             '$."rowBad"'
	, [rowNum]             int             '$."rowNumIn"'
	, [participantPool]    nvarchar(50)    '$."rowData"."participantPool"'
    , [lastName]           nvarchar(50)    '$."rowData"."lastName"'
	, [firstName]          nvarchar(50)    '$."rowData"."firstName"'
	, [middleName]         nvarchar(50)    '$."rowData"."middleName"'
	, [title]              nvarchar(50)    '$."rowData"."title"'
	, [email]              nvarchar(50)    '$."rowData"."email"'
	, [startDate]          date            '$."rowData"."startDate"'
	, [endDate]            date            '$."rowData"."endDate"'
) as t1
where (
	   (t1.rowBad = 0)
   and ((isnull(t1.participantPool, '') = '') or (t1.participantPool like '%direct%'))
)

/*-------------------------------    
 * Count records extracted
 *------------------------------*/    

select @numImportRecords = count(pdi.id) 
from dbo.Rmts_Participants_Data_Imports_Records as pdi
join dbo.Rmts_Participants_Data_Imports as rdi on rdi.id = pdi.dataImportID
where (
      (pdi.dataImportID = @RmtsParticipantsDataImportID)
  and (rdi.clientID     = @clientID)
)

/*-------------------------------    
 * Save count and update status 
 *------------------------------*/    

set @today = getdate()

update dbo.Rmts_Participants_Data_Imports
  set 
    lastModified                = @today
  , lastModifiedBy              = @userID
  , numOfIncomingDataRecords    = @numImportRecords
where (
      (id = @RmtsParticipantsDataImportID)
  and (clientID = @clientID)
)

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
       
  -- Error or raise error with severity 11 to 19 will be caught here    
      
      
  DECLARE @ErrorMessage  AS  NVARCHAR(4000)    
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




