USE spedmon
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Import_From_Patient_Goal_Records_Save') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.Import_From_Patient_Goal_Records_Save
GO


/*-------------------------------
 * Create new
 *------------------------------*/

CREATE PROCEDURE [dbo].[Import_From_Patient_Goal_Records_Save] (
	  @userID           bigint
    , @userGroup        int
    , @userRank         int
    , @clientID			bigint
    , @importDataJSON	varchar(max)
    , @editDelReason    varchar(7000)
    , @validateRec      bit
    , @saveType         int
    , @recID            bigint
	, @MsgNoRec         varchar(1000)
    , @MsgNoEdit        varchar(1000)
    , @MsgDupRec        varchar(1000)
    , @MsgDataError     varchar(1000)
    , @MsgNotActive     varchar(1000)
    , @spDetails		varchar(8000) OUTPUT
    , @recordID			bigint OUTPUT
    , @jsonData			varchar(max) OUTPUT
)
AS

BEGIN
SET NOCOUNT ON
BEGIN TRY


/*############################################################################
 * Variables
 *############################################################################*/


DECLARE @tranOpen AS bit = 0
DECLARE @totalRows AS int = 0
DECLARE @patientMatchedRows AS int = 0
DECLARE @existingRows AS int = 0
DECLARE @rowsAvailableToImport AS int = 0
DECLARE @rowsImported AS int = 0

DECLARE @patientGoals AS TABLE
(
      idx            int            IDENTITY(1,1)
    , rowBad         bit				NOT NULL        DEFAULT(0)
    , rowNum         int
    , clientID       bigint				NOT NULL
    , patID          bigint				NULL
    , ssid           varchar(50)						DEFAULT('')
    , schoolCDSCode  varchar(50)						DEFAULT('')
    , startDate      date				NULL
    , endDate        date				NULL
    , seisID         varchar(50)						DEFAULT('')
    , districtID     varchar(50)						DEFAULT('')
    , lastName       varchar(100)						DEFAULT('')
    , firstName      varchar(100)						DEFAULT('')
    , birthdate      date				NULL
    , grade          varchar(50)						DEFAULT('')
    , schoolOfAttendance    varchar(256)				DEFAULT('')
    , districtOfService     varchar(256)				DEFAULT('')
    , caseManager	        varchar(256)				DEFAULT('')
    , iepDate				date		NULL
    , eligibilityStatus     varchar(100)				DEFAULT('')
    , areaOfNeed            varchar(256)				DEFAULT('')
    , goalNumber            varchar(50)					DEFAULT('')
    , baseline              varchar(max)				DEFAULT('')
    , goalText              varchar(max)				DEFAULT('')
    , purposeOfGoal         varchar(max)				DEFAULT('')
    , [standard]            varchar(1000)				DEFAULT('')
	, personResponsible     varchar(256)				DEFAULT('')

    , objective1	        varchar(max)				DEFAULT('')
    , objective1Met         varchar(50)					DEFAULT('')
    , objective1DateMet     date           NULL
    , objective2            varchar(max)				DEFAULT('')
    , objective2Met         varchar(50)					DEFAULT('')
    , objective2DateMet     date           NULL
    , objective3            varchar(max)				DEFAULT('')
    , objective3Met         varchar(50)					DEFAULT('')
    , objective3DateMet     date           NULL

    , annualReview          date           NULL
    , comments              varchar(max)				DEFAULT('')
    , goalMet               bit			   NOT NULL		DEFAULT(0)
    , addedOn               date           NULL
    , addedBy               varchar(256)				DEFAULT('')
    , updatedBy             varchar(256)				DEFAULT('')
    , updatedOn             date           NULL
    , lastAffirmedPR        date           NULL

    , patIDMatched          bit            NOT NULL     DEFAULT(0)
    , existingImportRecordFound     bit    NOT NULL     DEFAULT(0)
    , okToImport            bit            NOT NULL     DEFAULT(0)

    , importWasSuccessful   bit			   NOT NULL     DEFAULT(0)
    , patName               varchar(256)				DEFAULT('')
    , processingNotes       varchar(max)				DEFAULT('')

    UNIQUE CLUSTERED(idx)
)

/*############################################################################
 * Initialization
 *############################################################################*/

SET @tranOpen  = 0
SET @spDetails = ''
SET @recordID  = 0
SET @jsonData  = '{}'

/*############################################################################
 * Extract Structured Data Rows
 *############################################################################*/


INSERT INTO @patientGoals
(
      rowBad
    , rowNum
    , clientID
    , ssid
    , schoolCDSCode
    , startDate
    , endDate
    , seisID
    , districtID
    , lastName
    , firstName
    , birthdate
    , grade
    , schoolOfAttendance
    , districtOfService
    , caseManager
    , iepDate
    , eligibilityStatus
    , areaOfNeed
    , goalNumber
    , baseline
    , goalText
    , purposeOfGoal
    , [standard]
    , personResponsible
    , objective1
    , objective1Met
    , objective1DateMet
    , objective2
    , objective2Met
    , objective2DateMet
    , objective3
    , objective3Met
    , objective3DateMet
    , annualReview
    , comments
    , goalMet
    , addedOn
    , addedBy
    , updatedBy
    , updatedOn
    , lastAffirmedPR
)

SELECT
      rowBad 				= ISNULL(t1.rowBad,0)
    , rowNum 				= t1.rowNum
    , clientID 				= @clientID
    , ssid 					= TRIM(ISNULL(t1.ssid, ''))
    , schoolCDSCode 		= TRIM(ISNULL(t1.schoolCDSCode, ''))
    , startDate				= TRY_CONVERT(date, NULLIF(t1.startDate, ''))
	, endDate				= TRY_CONVERT(date, NULLIF(t1.endDate, ''))
    , seisID 				= TRIM(ISNULL(t1.seisID, ''))
    , districtID 			= TRIM(ISNULL(t1.districtID, ''))
    , lastName 				= TRIM(ISNULL(t1.lastName, ''))
    , firstName 			= TRIM(ISNULL(t1.firstName, ''))
    , birthdate 			= TRY_CONVERT(date,NULLIF(t1.birthdate, ''))
    , grade 				= TRIM(ISNULL(t1.grade, ''))
    , schoolOfAttendance 	= TRIM(ISNULL(t1.schoolOfAttendance, ''))
	, districtOfService 	= TRIM(ISNULL(t1.districtOfService, ''))
	, caseManager 			= TRIM(ISNULL(t1.caseManager,''))
	, iepDate 				= TRY_CONVERT(date,NULLIF(t1.iepDate, ''))
	, eligibilityStatus 	= TRIM(ISNULL(t1.eligibilityStatus, ''))
	, areaOfNeed 			= TRIM(ISNULL(t1.areaOfNeed, ''))
	, goalNumber 			= TRIM(ISNULL(t1.goalNumber, ''))
	, baseline 				= TRIM(ISNULL(t1.baseline, ''))
	, goalText 				= TRIM(ISNULL(t1.goalText, ''))
	, purposeOfGoal 		= TRIM(ISNULL(t1.purposeOfGoal, ''))
	, [standard] 			= TRIM(ISNULL(t1.[standard], ''))
	, personResponsible 	= TRIM(ISNULL(t1.personResponsible, ''))
	, objective1 			= TRIM(ISNULL(t1.objective1, ''))
	, objective1Met 		= TRIM(ISNULL(t1.objective1Met, ''))
	, objective1DateMet 	= TRY_CONVERT(date,NULLIF(t1.objective1DateMet, ''))
	, objective2 			= TRIM(ISNULL(t1.objective2, ''))
	, objective2Met 		= TRIM(ISNULL(t1.objective2Met, ''))
	, objective2DateMet 	= TRY_CONVERT(date,NULLIF(t1.objective2DateMet, ''))
	, objective3 			= TRIM(ISNULL(t1.objective3, ''))
	, objective3Met 		= TRIM(ISNULL(t1.objective3Met, ''))
	, objective3DateMet 	= TRY_CONVERT(date,NULLIF(t1.objective3DateMet, ''))
	, annualReview 			= TRY_CONVERT(date,NULLIF(t1.annualReview, ''))
	, comments 				= TRIM(ISNULL(t1.comments, ''))
	, goalMet				= CASE
								WHEN UPPER(TRIM(ISNULL(t1.goalMet, '')))
									 IN ('1', 'Y')
									THEN 1
								ELSE 0
							END
	, addedOn 				= TRY_CONVERT(date,NULLIF(t1.addedOn, ''))
	, addedBy 				= TRIM(ISNULL(t1.addedBy, ''))
	, updatedBy 			= TRIM(ISNULL(t1.updatedBy, ''))
	, updatedOn 			= TRY_CONVERT(date,NULLIF(t1.updatedOn, ''))
	, lastAffirmedPR 		= TRY_CONVERT(date,NULLIF(t1.lastAffirmedPR, ''))

FROM OPENJSON
(
      @importDataJSON

    , '$."structuredDataRows"'
)

WITH
(

      rowBad				bit				'$."rowBad"'
    , rowNum				int				'$."rowNumIn"'
    , ssid					varchar(50)		'$."rowData"."ssid"'
    , schoolCDSCode			varchar(50)		'$."rowData"."schoolCDSCode"'
    , startDate				varchar(50)		'$."rowData"."startDate"'
	, endDate				varchar(50)		'$."rowData"."endDate"'
	, seisID				varchar(50)		'$."rowData"."seisID"'
	, districtID			varchar(50)		'$."rowData"."districtID"'
	, lastName				varchar(100)	'$."rowData"."lastName"'
	, firstName				varchar(100)	'$."rowData"."firstName"'
	, birthdate				varchar(50)		'$."rowData"."birthdate"'
	, grade					varchar(50)		'$."rowData"."grade"'
	, schoolOfAttendance	varchar(256)	'$."rowData"."schoolOfAttendance"'
	, districtOfService		varchar(256)	'$."rowData"."districtOfService"'
	, caseManager			varchar(256)	'$."rowData"."caseManager"'
	, iepDate				varchar(50)		'$."rowData"."iepDate"'
	, eligibilityStatus		varchar(100)	'$."rowData"."eligibilityStatus"'
	, areaOfNeed			varchar(256)	'$."rowData"."areaOfNeed"'
	, goalNumber			varchar(50)		'$."rowData"."goalNumber"'
	, baseline				varchar(max)	'$."rowData"."baseline"'
	, goalText				varchar(max)	'$."rowData"."goalText"'
	, purposeOfGoal			varchar(max)	'$."rowData"."purposeOfGoal"'
	, [standard]			varchar(1000)	'$."rowData"."standard"'
	, personResponsible		varchar(256)	'$."rowData"."personResponsible"'
	, objective1			varchar(max)	'$."rowData"."objective1"'
	, objective1Met			varchar(50)		'$."rowData"."objective1Met"'
	, objective1DateMet		varchar(50)		'$."rowData"."objective1DateMet"'
	, objective2			varchar(max)	'$."rowData"."objective2"'
	, objective2Met			varchar(50)		'$."rowData"."objective2Met"'
	, objective2DateMet		varchar(50)		'$."rowData"."objective2DateMet"'
	, objective3			varchar(max)	'$."rowData"."objective3"'
	, objective3Met			varchar(50)		'$."rowData"."objective3Met"'
	, objective3DateMet		varchar(50)		'$."rowData"."objective3DateMet"'
	, annualReview			varchar(50)		'$."rowData"."annualReview"'
	, comments				varchar(max)	'$."rowData"."comments"'
	, goalMet				varchar(10)		'$."rowData"."goalMet"'
	, addedOn				varchar(50)		'$."rowData"."addedOn"'
	, addedBy				varchar(256)	'$."rowData"."addedBy"'
	, updatedBy				varchar(256)	'$."rowData"."updatedBy"'
	, updatedOn				varchar(50)		'$."rowData"."updatedOn"'
	, lastAffirmedPR		varchar(50)		'$."rowData"."lastAffirmedPR"'

) AS t1


/*############################################################################
 * Add a processing note for rows already rejected by Structured Data
 *############################################################################*/


UPDATE @patientGoals

SET
    processingNotes =
        processingNotes
        +
        ' Structured data validation failed.'

WHERE
    rowBad = 1


/*############################################################################
 * Validate SSID
 *############################################################################*/


UPDATE @patientGoals

SET
      rowBad = 1
    , processingNotes = processingNotes + ' No SSID was provided.'

WHERE
    LEN(TRIM(ISNULL(ssid, ''))) = 0


update t1
set
    t1.patID        = pap.PATIENT_ID
  , t1.patName      = pap.CONCAT_NAME
  , t1.patIDMatched = 1
from @patientGoals        as t1
join dbo.PATIENTS_Patient as pap on pap.CSIS = t1.ssid
join dbo.PATIENTS_Client  as pac on pac.CLIENT_ID = @clientID and pap.PATIENT_ID = pap.PATIENT_ID
where
(
  (LEN(t1.ssid) > 0) and (pap.ACTIVE != N'N')
)

UPDATE @patientGoals

SET
      processingNotes = processingNotes + ' No patient was found with the SSID ' + ssid + '.'
WHERE
(
    LEN(ssid) > 0
    AND patIDMatched = 0
)


/*############################################################################
 * Existing Import Record Check
 *############################################################################*/


UPDATE t1

SET
      t1.existingImportRecordFound = 1
    , t1.processingNotes = t1.processingNotes + ' Patient goal import record already exists.'

FROM @patientGoals AS t1


WHERE
(
    t1.patIDMatched = 1
    AND EXISTS
    (
        SELECT TOP 1
            t2.id
        FROM
            dbo.Import_From_Patient_Goal_Records
            AS t2
        WHERE
        (
				t2.clientID = t1.clientID
			AND t2.patID = t1.patID
            AND (t2.iepDate = t1.iepDate
                OR
                (t2.iepDate IS NULL
                AND t1.iepDate IS NULL
                )
            )
            AND ISNULL(t2.goalNumber, '') = ISNULL(t1.goalNumber, '')
            AND ISNULL(t2.goalText, '') = ISNULL(t1.goalText, '')
        )
    )
)


/*############################################################################
 * Determine Rows That Can Be Imported
 *############################################################################*/


UPDATE @patientGoals

SET
    okToImport = 1
WHERE
(
        rowBad = 0
    AND patIDMatched = 1
    AND existingImportRecordFound = 0
)


/*############################################################################
 * Validation Only
 *############################################################################*/


IF
(
    @validateRec = 1
)
BEGIN

    UPDATE @patientGoals

    SET
          importWasSuccessful = 1
        , processingNotes =
              processingNotes
            + ' Patient goal record can be imported.'

    WHERE
        okToImport = 1

END


/*############################################################################
 * Import Records
 *############################################################################*/


IF
(
    @validateRec = 0

    AND EXISTS
    (
        SELECT TOP 1
            idx
        FROM
            @patientGoals
        WHERE
            okToImport = 1
    )
)
BEGIN

    BEGIN TRANSACTION

    SET @tranOpen = 1

    DECLARE @insertedRecords AS TABLE
    (
        id bigint
    )

    INSERT INTO dbo.Import_From_Patient_Goal_Records
    (
          clientID
        , patID
        , ssid
        , schoolCDSCode
        , startDate
        , endDate
        , seisID
        , districtID
        , lastName
        , firstName
        , birthdate
        , grade
        , schoolOfAttendance
        , districtOfService
        , caseManager
        , iepDate
        , eligibilityStatus
        , areaOfNeed
        , goalNumber
        , baseline
        , goalText
        , purposeOfGoal
        , [standard]
        , personResponsible
        , objective1
        , objective1Met
        , objective1DateMet
        , objective2
        , objective2Met
        , objective2DateMet
        , objective3
        , objective3Met
        , objective3DateMet
        , annualReview
        , comments
        , goalMet
        , addedOn
        , addedBy
        , updatedBy
        , updatedOn
        , lastAffirmedPR
        , created
        , createdBy
        , lastModified
        , lastModifiedBy
        , active
    )
    OUTPUT
        INSERTED.id
    INTO
        @insertedRecords
        (
            id
        )
    SELECT
          clientID
        , patID
        , ssid
        , schoolCDSCode
        , startDate
        , endDate
        , seisID
        , districtID
        , lastName
        , firstName
        , birthdate
        , grade
        , schoolOfAttendance
        , districtOfService
        , caseManager
        , iepDate
        , eligibilityStatus
        , areaOfNeed
        , goalNumber
        , baseline
        , goalText
        , purposeOfGoal
        , [standard]
        , personResponsible
        , objective1
        , objective1Met
        , objective1DateMet
        , objective2
        , objective2Met
        , objective2DateMet
        , objective3
        , objective3Met
        , objective3DateMet
        , annualReview
        , comments
        , goalMet
        , addedOn
        , addedBy
        , updatedBy
        , updatedOn
        , lastAffirmedPR
        , GETDATE()
        , @userID
        , GETDATE()
        , @userID
        , 1
    FROM
        @patientGoals
    WHERE
        okToImport = 1

    UPDATE @patientGoals
    SET
          importWasSuccessful = 1
        , processingNotes = processingNotes + ' Patient goal record has been imported.'
    WHERE
        okToImport = 1

    SELECT
        @recordID = ISNULL(MIN(id), 0)
    FROM
        @insertedRecords

    COMMIT TRANSACTION

    SET @tranOpen = 0


END


/*############################################################################
 * Calculate Import Statistics
 *############################################################################*/


SELECT
    @totalRows = COUNT(*)
FROM
    @patientGoals

SELECT
    @patientMatchedRows = COUNT(*)
FROM
    @patientGoals
WHERE
    patIDMatched = 1


SELECT
    @existingRows = COUNT(*)
FROM
    @patientGoals
WHERE
    existingImportRecordFound = 1


SELECT
    @rowsAvailableToImport = COUNT(*)
FROM
    @patientGoals
WHERE
    okToImport = 1


SELECT
    @rowsImported = COUNT(*)
FROM
    @patientGoals
WHERE
    importWasSuccessful = 1


/*############################################################################
 * Return SP Details
 *############################################################################*/


SET @spDetails = ''


/*############################################################################
 * Clean Processing Notes
 *############################################################################*/


UPDATE @patientGoals

SET
    processingNotes = TRIM(processingNotes)


/*############################################################################
 * Return JSON
 *############################################################################*/

declare @exportDataJSON varchar(max)

select
    @exportDataJSON =
    (
        select
            *
        from @patientGoals
        order by idx
        for json path, include_null_values
    )

set @jsonData =
      '{"importData":'
    + isnull(nullif(@importDataJSON, ''), '{}')
    + ',"exportData":'
    + isnull(@exportDataJSON, '[]')
    + '}'

RETURN(0)


END TRY


BEGIN CATCH


/*############################################################################
 * Rollback Transaction
 *############################################################################*/


IF
(
    @tranOpen = 1
)
BEGIN

    ROLLBACK TRANSACTION

    SET @tranOpen = 0

END


/*############################################################################
 * Return SQL Error
 *############################################################################*/


  DECLARE @ErrorMessage  AS varchar(4000)
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

GRANT EXECUTE ON [dbo].[Import_From_Patient_Goal_Records_Save] TO [webuser]
GO
