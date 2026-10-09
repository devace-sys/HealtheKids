USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PUBLIC_SCHOOLS_IMPORT') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.PUBLIC_SCHOOLS_IMPORT
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
   
CREATE PROCEDURE dbo.PUBLIC_SCHOOLS_IMPORT (
  @filePath nvarchar(255)
)    
AS    
BEGIN

/***************************************************************************    
 * PUBLIC_SCHOOLS_IMPORT */    
/**    
 * Imports public schools data file from CDE
 *    
 * @param   filePath        Complete path + filename of incoming file
 *
 * IMPORTANT DEPLOYMENT NOTE :
 * 
 * The database MUST have Ad Hoc Distributed Queries turned ON
 * You can do this by running the following :
 *
 * exec sp_configure 'show advanced options', 1
 * GO
 * RECONFIGURE
 * GO
 * exec sp_configure 'Ad Hoc Distributed Queries', 1
 * GO
 * RECONFIGURE
 * GO
 ***************************************************************************/        
     
SET NOCOUNT ON    
declare @TranOpen as bit = 0

BEGIN TRY

RAISERROR ('Attempting to import CDE data', 0, 1) WITH NOWAIT 

/* Clean up incoming file path parameter */

set @filePath = ltrim(rtrim(isnull(@filePath,N'')))

RAISERROR (@filePath,0,1) WITH NOWAIT

/* If no file was provided get out! */ 

if (@filePath = '') RAISERROR ('File required', 11, 1)  

declare @sql as nvarchar(4000) = N''

IF OBJECT_ID('tempdb..#CDE_Sites_In') IS NOT NULL DROP TABLE #CDE_Sites_In

create table #CDE_Sites_In (
	[CDSCode] [nvarchar](255) NULL,
	[NCESDist] [nvarchar](255) NULL,
	[NCESSchool] [nvarchar](255) NULL,
	[StatusType] [nvarchar](255) NULL,
	[County] [nvarchar](255) NULL,
	[District] [nvarchar](255) NULL,
	[School] [nvarchar](255) NULL,
	[Street] [nvarchar](255) NULL,
	[StreetAbr] [nvarchar](255) NULL,
	[City] [nvarchar](255) NULL,
	[Zip] [nvarchar](255) NULL,
	[State] [nvarchar](255) NULL,
	[MailStreet] [nvarchar](255) NULL,
	[MailStrAbr] [nvarchar](255) NULL,
	[MailCity] [nvarchar](255) NULL,
	[MailZip] [nvarchar](255) NULL,
	[MailState] [nvarchar](255) NULL,
	[Phone] [nvarchar](255) NULL,
	[Ext] [nvarchar](255) NULL,
	[Website] [nvarchar](255) NULL,
	[OpenDate] [nvarchar](255) NULL,
	[ClosedDate] [nvarchar](255) NULL,
	[Charter] [nvarchar](255) NULL,
	[CharterNum] [nvarchar](255) NULL,
	[FundingType] [nvarchar](255) NULL,
	[DOC] [nvarchar](255) NULL,
	[DOCType] [nvarchar](255) NULL,
	[SOC] [nvarchar](255) NULL,
	[SOCType] [nvarchar](255) NULL,
	[EdOpsCode] [nvarchar](255) NULL,
	[EdOpsName] [nvarchar](255) NULL,
	[EILCode] [nvarchar](255) NULL,
	[EILName] [nvarchar](255) NULL,
	[GSoffered] [nvarchar](255) NULL,
	[GSserved] [nvarchar](255) NULL,
	[Virtual] [nvarchar](255) NULL,
	[Magnet]  [nvarchar](255) NULL,
	[Latitude] [nvarchar](255) NULL,
	[Longitude] [nvarchar](255) NULL,
	[AdmFName1] [nvarchar](255) NULL,
	[AdmLName1] [nvarchar](255) NULL,
	[AdmEmail1] [nvarchar](255) NULL,
	[AdmFName2] [nvarchar](255) NULL,
	[AdmLName2] [nvarchar](255) NULL,
	[AdmEmail2] [nvarchar](255) NULL,
	[AdmFName3] [nvarchar](255) NULL,
	[AdmLName3] [nvarchar](255) NULL,
	[AdmEmail3] [nvarchar](255) NULL,
	[LastUpdate] [nvarchar](255) NULL
)

declare @recInCount as bigint = 0;

set @sql = N'
insert into #CDE_Sites_In
select
    [CDSCode] 
  , [NCESDist] 
  , [NCESSchool]
  , [StatusType] 
  , [County] 
  , [District]
  , [School] 
  , [Street] 
  , [StreetAbr]
  , [City] 
  , [Zip] 
  , [State] 
  , [MailStreet] 
  , [MailStrAbr]
  , [MailCity] 
  , [MailZip]
  , [MailState] 
  , [Phone]
  , [Ext] 
  , [Website]
  , [OpenDate]
  , [ClosedDate]
  , [Charter]
  , [CharterNum]
  , [FundingType]
  , [DOC]
  , [DOCType]
  , [SOC] 
  , [SOCType]
  , [EdOpsCode]
  , [EdOpsName]
  , [EILCode]
  , [EILName]
  , [GSoffered]
  , [GSserved]
  , [Virtual] 
  , [Magnet] 
  , [Latitude]
  , [Longitude]
  , [AdmFName1]
  , [AdmLName1]
  , [AdmEmail1] 
  , [AdmFName2]
  , [AdmLName2] 
  , [AdmEmail2]
  , [AdmFName3]
  , [AdmLName3]
  , [AdmEmail3]
  , [LastUpdate]
from OPENROWSET( ''Microsoft.ACE.OLEDB.12.0''
                  ,''Excel 12.0;Database=' + @filePath + ';HDR=YES''
                  ,''SELECT * FROM [Public Schools and Districts$A6:AY]''
               );'


/* Note: We are using a range.  Importing rows 6 to end and columns A6 to AW.  Header row is row 6.*/
EXECUTE sp_executesql @sql
--EXEC (@sql)

/* Get record count */

set @recInCount = 0
select @recInCount = isnull(count(*),0) from #CDE_Sites_In

/* If there are no records this is a problem, get out! */

if (@recInCount = 0)  RAISERROR ('No CDE records', 11, 1)  

RAISERROR ('Data from file imported', 0, 1) WITH NOWAIT 


/* Otherwise pull them in */

BEGIN TRANSACTION   
  SET @TranOpen = 1 
  RAISERROR ('Replacing old data previously stored with new data', 0, 1) WITH NOWAIT    
  truncate table dbo.CDE_SCHOOLS_PUBLIC
  insert into dbo.CDE_SCHOOLS_PUBLIC
  select * from #CDE_Sites_In
COMMIT TRANSACTION


/* If we reach this point we are done and there were no problems */

SET @TranOpen = 0
IF OBJECT_ID('tempdb..#CDE_Sites_In') IS NOT NULL DROP TABLE #CDE_Sites_In
RAISERROR ('Done', 0, 1) WITH NOWAIT 
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
   
  IF @tranOpen = 1 ROLLBACK TRANSACTION    
   
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

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[PUBLIC_SCHOOLS_IMPORT] TO [webuser]
GO
