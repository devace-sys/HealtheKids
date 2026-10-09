
use SPEDMON
GO

if  exists (select * from dbo.sysobjects where id = object_id(N'[dbo].PATIENT_DATA_IMPORT_TO_DHCS') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop PROCEDURE PATIENT_DATA_IMPORT_TO_DHCS
GO

CREATE PROCEDURE PATIENT_DATA_IMPORT_TO_DHCS
(
    @istestrun   bit
  , @outfilepath varchar(500)
  , @ignorePreviousNcountEligTransmissionsForThisClient int
  , @includePatientsAlreadyAwaitingEligMatchInfo bit
)
AS
BEGIN

LINENO 17

  --print '@istestrun = ' + CAST( @istestrun as varchar )
  --print '@outfilepath = ' + CAST( @outfilepath as varchar )
  --print '@ignorePreviousNcountEligTransmissionsForThisClient = ' + CAST( @ignorePreviousNcountEligTransmissionsForThisClient as varchar )
  --print '@includePatientsAlreadyAwaitingEligMatchInfo = ' + CAST( @includePatientsAlreadyAwaitingEligMatchInfo as varchar )

declare @importsToProcessPerClient table (
  --idx int identity(1,1),
  clientID bigint not null,
  patientImportRowID bigint not null,
  fileSubClass      varchar(256) not null,
  [fileName]        varchar(256) not null
  )

declare @clientsToProcess table (
  idx int identity(1,1),
  clientID bigint not null,
  clientCDS7 nchar(7) not null,
  clientName varchar(200) not null,
  patientImportRowIDsJSONArr nvarchar(max) not null
  )

INSERT INTO @importsToProcessPerClient
  SELECT
    cc.CLIENT_ID,
    pdi.id,
    sdi.fileSubClass,
    sdi."fileName"

  FROM Patient_Data_Imports pdi
  JOIN CLIENTS_Client cc ON pdi.clientID = cc.CLIENT_ID
  JOIN Structured_Data_Imports sdi ON sdi.id = pdi.structuredDataImportID
  WHERE
  (
    pdi.generateEligibilityMatchFile = 1

	--AND pdi.eligibilityMatchFileGenerated = 0
        -- commenting this; perhaps we want to re-generate a TO_DHCS file, again, even after one has been generated

    AND pdi.fileAccepted = 1
	AND pdi.fileProcessingCompleted = 1
	AND pdi.fileProcessingError = 0
	AND pdi.importRolledBack = 0
	--and cc.LEA = 1
	and cc.sendElibilityDataMatchRequestsToDHCS = 1
                         -- NOTE: this fileProcessingCompleted bit means the batch import and match/update is complete; does not mean "complete" is the ultimate sense.
                         --       Same with fileProcessingError; indicates the presence or absence of an error in import... possibly the match/update, I don't recall.
                         --       If it were up to me I would re-name these cols with the benefit of hindsight.
  )

INSERT INTO @clientsToProcess
  SELECT
    cc.CLIENT_ID,
    cc.CLIENT_CDS,

    cc.ShortName, -- don't know if the full name, with spaces and punctuation, will work

    '[' +
      STRING_AGG(
      '{ "patientDataImportID": ' + CAST( file_waitlist.patientImportRowID AS varchar )
      ,
      '},'
      ) + '}]' importIDsJSONArr


  FROM @importsToProcessPerClient file_waitlist
  JOIN CLIENTS_Client cc ON file_waitlist.clientID = cc.CLIENT_ID
  GROUP BY cc.CLIENT_ID,
           cc.CLIENT_CDS,
           cc.ShortName

--select * from @clientsToProcess
--select * from @importsToProcessPerClient
--raiserror(N'', 9, -1)

declare @currIdx int = 1
declare @maxIdx int;

select @maxIdx=COUNT(*) FROM @clientsToProcess;

if ( @maxIdx = 0)
  return (0)

declare @today datetime = GETDATE()

--declare @rightnow datetime2 = SYSDATETIME()


declare @currIdj int = 1
declare @maxIdj int;


while ( @currIdx <= @maxIdx )
begin

  declare @clientID bigint
  declare @clientCDS7 nchar(7)
  declare @patientImportRowIDsJSONArr varchar(max)

  declare @clientName varchar(200)

  declare @outgoingFileNameAndPath  varchar(max)

  SELECT top 1

    @clientID   =  clientID   ,
    @clientCDS7 =  clientCDS7 ,
    @patientImportRowIDsJSONArr = patientImportRowIDsJSONArr,

    @clientName =  clientName


  FROM @clientsToProcess
  WHERE idx = @currIdx

  --declare @currIdj int = 1
  --declare @maxIdj int;

  declare @importsToProcessPerClient_j table (  -- declaring the table var here, inside the @currIdx loop
  idj int identity(1,1),                        -- resets @currIdj back to 1, for every iteration
  clientID bigint not null,                     -- CORRECTION: hah no it don't
  patientImportRowID bigint not null,
  fileSubClass      varchar(256) not null,
  [fileName]        varchar(256) not null
  )

  INSERT INTO @importsToProcessPerClient_j
    select *
    FROM @importsToProcessPerClient
    WHERE clientID = @clientID;

  --SELECT * FROM @importsToProcessPerClient_j
  --raiserror(N'', 9, -1)

  select @maxIdj=COUNT(*) FROM @importsToProcessPerClient_j;

  while ( @currIdj <= @maxIdj )
  begin

    declare @patientImportRowID bigint,
            @fileSubClass       varchar(256),
            @fileName           varchar(256)

    SELECT top 1

      @patientImportRowID = patientImportRowID,
      @fileSubClass       = fileSubClass,
      @fileName           = [fileName]

    FROM @importsToProcessPerClient_j
    WHERE idj = @currIdj ;


    SET  @outgoingFileNameAndPath =
        @outfilepath +
        'PDItoDHCS_' +  -- 10 characters
        @clientName +    -- 7-ish characters
        REPLACE( CAST( CAST( @today as date) as varchar ) , '-', '') + -- 8 or ten chars
        + '_' + @fileSubClass  -- 7 characters

        -- NOTE: the inner sproc dbo.TO_DHCS appends additional characters to the filename



    print '@currIdx ' + CAST (@currIdx as varchar) + ' @currIdj ' + cast(@currIdj as varchar)
    print 'Attempting to create file ' + @outgoingFileNameAndPath

    exec dbo.TO_DHCS
        @clientCDS7,
        @isTestRun,
        @outgoingFileNameAndPath,
        0,
        @ignorePreviousNcountEligTransmissionsForThisClient,
        @includePatientsAlreadyAwaitingEligMatchInfo,

        @patientImportRowID,
        @fileSubClass

/*
  exec dbo.TO_DHCS @clientCDS7, 1, @outgoingFileNameAndPath, 0, @ignorePreviousNcountEligTransmissionsForThisClient, 1
                    -- TODO: Testing with @includeAlreadyAwaiting = 1, from the batch file, without actually hardcoding it in the batch file.
                    --       hopefully I won't forget to un-hardcode it here before submitting for code review!!
*/

    SET @currIdj = @currIdj + 1;

  end

  UPDATE Patient_Data_Imports
  SET
    generateEligibilityMatchFile = 0,
    eligibilityMatchFileGenerated = 1,
    eligibilityMatchFileGeneratedOn = @today
  WHERE
    id IN (
      SELECT
        patientDataImportID
      FROM OPENJSON ( @patientImportRowIDsJSONArr )
           WITH
           (
             patientDataImportID bigint '$."patientDataImportID"'
           )
    )

  SET @currIdx = @currIdx + 1;

end

END

GRANT EXECUTE ON  [dbo].[TO_DHCS] TO [webuser]
GO
