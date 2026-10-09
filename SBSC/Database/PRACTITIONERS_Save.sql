USE SPEDMON
GO



/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTITIONERS_Save') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.PRACTITIONERS_Save
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[PRACTITIONERS_Save] (
    @userID                        BIGINT
  , @userGroup                     INT
  , @userRank                      INT
  , @clientID                      BIGINT
  , @lname                         NVARCHAR(50)
  , @fname                         NVARCHAR(50)
  , @groupIDDisp                   BIGINT
  , @employeeRelationship          BIGINT
  , @clientEmployeeID              varchar(500)
  , @startDate                     DATETIME
  , @endDate                       DATETIME
  , @cprCertEffectiveDate          DATE
  , @cprCertExpirationDate         DATE
  , @email                         NVARCHAR(50)
  , @phone                         NVARCHAR(14)
  , @fax                           NVARCHAR(14)
  , @street1                       varchar(1000)
  , @street2                       varchar(1000)
  , @city                          varchar(100)
  , @state                         varchar(2)
  , @zip5                          varchar(5)
  , @zip4                          varchar(4)
  , @npiNumber                     varchar(50)
  , @isValidMcalOrp                bit
  , @isValidMcalOrpLastValidated   datetime
  , @groupIDRept                   BIGINT
  , @incInFinRepts                 bit

  , @currentlyWithClient           bit

  , @participatesInLEABOP          bit
  , @participatesInLEABOPNonSpEd   bit
  , @participatesInCYBHI           bit
  , @participatesInRUHealth        bit

  , @submitClaims                  bit
  , @submitClaimsEffectiveDate     datetime
  , @claim_TCM                     BIT
  , @claim_TCMEffectiveDate        datetime
  , @cybhiTpaApproved			   BIT
  , @cybhiTpaApprovedOn			   DATE
  , @cybhiTpaID					   VARCHAR(256)
  , @cybhiSubmitClaims			   BIT
  , @notes                         NVARCHAR(MAX)
  , @qualificationsJSONData        VARCHAR(MAX)

  , @deptHead                                              bit
  , @deptHeadCanSeeEntirePracticeFamilyInDeptReviewReports bit

  , @displayPercent                BIT
  , @displayMoney                  BIT
  , @acesCertCompletedOn           DATE
  , @dob                           date
  , @gender                        varchar(1)
  , @ssn                           varchar(9)
  , @cybhiDegreeCode               varchar(256)
  , @cybhiDegreeCode2              varchar(256)
  , @cybhiDegreeCode3              varchar(256)
  , @cybhiSpecialtyCode            varchar(256)
  , @cybhiSpecialtyCode2           varchar(256)
  , @cybhiSpecialtyCode3           varchar(256)
  , @cybhiSpecialtyCode4           varchar(256)
  , @editDelReason                 VARCHAR(7000)
  , @validateRec                   BIT
  , @saveType                      INT
  , @recID                         BIGINT
  , @MsgNotActive                  VARCHAR(1000)
  , @MsgNoRec                      VARCHAR(1000)
  , @MsgNoEdit                     VARCHAR(1000)
  , @MsgNoFullEdit                 VARCHAR(1000)
  , @MsgDupRec                     VARCHAR(1000)
  , @MsgNoClient                   VARCHAR(1000)
  , @MsgNoGroup                    VARCHAR(1000)
  , @MsgDataError                  VARCHAR(1000)
  , @spDetails                     VARCHAR(8000) OUTPUT
  , @recordID                      BIGINT        OUTPUT)
AS
BEGIN

/***************************************************************************
 * PRACTITIONERS_SAVE */
/**
 * Creates a new or edits existing entity record
 * and manages any associated records.
 *
 * @param   userID          The userid of who saved the record
 * @param   userGroup       Users group
 * @param   userRank        User rank
 * @param   clientID        Practitioners client id
 * @param   groupIDDisp
 * @param   groupIDRept
 * @param   fname           Practitoners first name
 * @param   lname           Practitioners last name
 * @param   startDate       Practitioners start date
 * @param   email           Practitioners email ID
 * @param   phone           Practitioners phone number
 * @param   fax             Practitioners fax number
 * @param   claim_TCM       Claim TCM for reimbursement
 * @param   notes           Notes
 * @param   editDelReason   Reason for record edit or delete
 * @param   validateRec     1 = Performs data integrity validation tasks
                                Perform advisory validation tasks that can
 *                              only be conducted by referencing data from the
 *                              database and then exits WITHOUT saving the record
 *                          0 = Peform data integrity validation tasks and
 *                              if these tasks succeed peforms the desired
 *                              operation (saveType) on the record and exits
 * @param   saveType        Type of operation to perform
 *                          1 = New, 2 = Edit, 3 = Delete
 * @param   recID           Record id of existing practitioners record to edit or
 *                          delete.
 * @param   MsgNoRec        Desired error message if a recID is not found
 * @param   MsgNoEdit       Desired error message if a record cannot be edited
 * @param   MsgNoFullEdit   Desired error message if a record can only be partially edited
 * @param   MsgDupRec       Desired error message for duplicate detection
 * @param   MsgNoClient     Desired error message if a clientID is not found
 * @param   MsgNoGroup      Desired error message if a groupID is not found
 * @param   MsgDataError    Desired error message for data errors
 * @returns spDetails       Validation or error details
 * @returns recordID        New record id or record id of service record that
 *                          was changed or deleted
 ***************************************************************************/



SET NOCOUNT ON

DECLARE @today              AS DATETIME       -- Current date/time stamp
DECLARE @tranOpen           AS BIT            -- Is a transaction open
DECLARE @dupCount           AS INT            -- Duplicate counter used for validation
DECLARE @updateState        AS SMALLINT       -- Indicates what state the record is left in
DECLARE @auditRecID         AS BIGINT         -- Audit record id
DECLARE @canEdit            AS BIT            -- If the record is inactive it cannot be edited
DECLARE @isActive           AS BIT            -- Is this record active?
DECLARE @noFullEdit         AS BIT
DECLARE @tempRecID          AS BIGINT         -- Used for determining if a rec exists
DECLARE @rptGroupType       AS INT
DECLARE @dspGroupType       AS INT
DECLARE @dspGroupIDParent   AS BIGINT
DECLARE @concat_name        AS NVARCHAR(100)  -- Last name + first name
DECLARE @msg                as VARCHAR(1000)

/*-------------------------------
 * Various record keys used
 * for proper editing
 *------------------------------*/

DECLARE @pracNoteRecID      AS INT
DECLARE @pracClientRecID    AS INT
DECLARE @pracGroupDispRecID AS INT
DECLARE @pracGroupReptRecID AS INT

declare @pracNameChanged as bit = 0
declare @saveCprCertHistoryData as bit = 0

declare @qualifData as table (
    GROUP_ID                   bigint
  , PRAC_NAME_ON_QUALIFICATION varchar(512)
  , QUALIFICATION_NUMBER       varchar(512)
  , ISSUANCE_DATE              date
  , EXPIRATION_DATE            date
  , LIFE_TIME_QUALIFICATION    bit
)

BEGIN TRY

/*-------------------------------
 * Init our output parameters
 *------------------------------*/

SET @recordID   = 0
SET @spDetails  = ''

/*-------------------------------
 * Verify all parameters that
 * indicate what type of operation
 * to perform have been passed in
 * and any other parms that are
 * neccessary for proper operation
 *------------------------------*/

IF (@userGroup   IS NULL) RAISERROR ('userGroup is required',   11, 1)
IF (@userRank    IS NULL) RAISERROR ('userRank is required',    11, 1)
IF (@validateRec IS NULL) RAISERROR ('Validate flag required',  11, 1)
IF (@clientID    IS NULL) RAISERROR ('Client ID is required',   11, 1)
IF (@saveType    IS NULL) RAISERROR ('Save type is required',   11, 1)
IF (@groupIDDisp IS NULL) RAISERROR ('groupIDDisp is required', 11, 1)
IF (@fname       IS NULL) RAISERROR ('First Name is required',  11, 1)
IF (@lname       IS NULL) RAISERROR ('Last Name is required',   11, 1)

IF ((@saveType = dbo.CONST_SAVE_TYPE_EDIT()) AND (@recID IS NULL))
  RAISERROR ('updateRecID is required', 11, 1)

/*-------------------------------
 * Verify client id exists
 *-------------------------------*/

SET @tempRecID = NULL

SELECT top 1
  @tempRecID = clc.CLIENT_ID
FROM dbo.CLIENTS_CLIENT as clc
WHERE (clc.CLIENT_ID = @ClientID)
option (recompile)

IF (@tempRecID <> @clientID) RAISERROR (@MsgNoClient, 11, 1)

/*-------------------------------
 * Verify group id (discipline)
 * exists
 *-------------------------------*/

SET @tempRecID = NULL
SELECT top 1
    @tempRecID = groupid
  , @dspGroupType = groupType
FROM dbo.GROUP_DISP_VIEW_ALL(null)
WHERE groupid = @groupIDDisp
option (recompile)

IF ((@tempRecID is null) or (@tempRecID <> @groupIDDisp)) RAISERROR (@MsgNoGroup, 11, 1)

/*-------------------------------
 * Verify employement relationship
 * id exists
 *-------------------------------*/

SET @tempRecID = NULL
select top 1
  @tempRecID = er.[TYPE_ID]
from dbo.EMPLOYMENT_RELATIONSHIPS as er
where
  (er.TYPE_ID = @employeeRelationship)
option (recompile)

IF (@tempRecID is null) RAISERROR ('Invalid employment relationship', 11, 1)


/*-------------------------------
 * If no reporting group is provided
 * select the default
 * (if one is available)
 *-------------------------------*/

if (@groupIDRept is null)
begin
  set @groupIDRept = dbo.GROUP_FIND_PARENT(@groupIDDisp)
  if (@groupIDRept IS NULL) RAISERROR ('groupIDRept is required', 11, 1)
end

/*-------------------------------
 * Verify group id (report)
 * exists
 *-------------------------------*/

SET @tempRecID = NULL
SELECT
    @tempRecID = groupid
  , @rptGroupType = groupType
FROM dbo.GROUP_REPT_VIEW_ALL(@clientID, null)
WHERE groupid = @groupIDRept
option (recompile)

IF ((@tempRecID is null) or (@tempRecID <> @groupIDRept)) RAISERROR (@MsgNoGroup, 11, 1)

/*-------------------------------
 * Verify CPR dates
 *-------------------------------*/

if ((@cprCertEffectiveDate is null) and (@cprCertExpirationDate is null))
begin
	set @saveCprCertHistoryData = 0
end
if ((@cprCertEffectiveDate is not null) and (@cprCertExpirationDate is null))
begin
	RAISERROR ('Please provide a CPR expiration date',   11, 1)
end
else if ((@cprCertEffectiveDate is null) and (@cprCertExpirationDate is not null))
begin
	RAISERROR ('Please provide a CPR effective date',   11, 1)
end

else if ((@cprCertEffectiveDate is not null) and (@cprCertExpirationDate is not null))
begin
	if (@cprCertExpirationDate <= @cprCertEffectiveDate)
	begin
		RAISERROR ('The CPR expiration date cannot be before or the same as the effective date',   11, 1)
	end
	set @saveCprCertHistoryData = 1
end

/*-------------------------------
 * Default value for gender
 *------------------------------*/

if (trim((isnull(@gender,''))) = '') set @gender = 'U'

/*-------------------------------
 * Replace ' with ` for name
 *------------------------------*/

set @lname  = replace (@lname,  N'''', N'`')
set @fname  = replace (@fname,  N'''', N'`')

/*-------------------------------
 * Prep worker variables
 *------------------------------*/

SET @today           = GETDATE()
SET @isActive        = 1
SET @msg             = ''
set @pracNameChanged = 0

/*-------------------------------
 * Check to see if start date and
 * end date combo is valid
 *------------------------------*/

if ((@startDate is not null) and (@endDate is not null))
begin
  if (@startDate > @endDate) RAISERROR ('Start date cannot be before end date', 11, 1)
end

/*-------------------------------
 * Set default values
 *------------------------------*/

--IF @startDate IS NULL SET @startDate = @today
IF @notes IS NULL SET @notes = ''

/*-------------------------------
 * Generate derived values
 *------------------------------*/

SET @concat_name = @lname + N', ' + @fname

/*-------------------------------
 * If this is an edit
 * perform edit sanity checks
 *------------------------------*/

IF (@saveType = dbo.CONST_SAVE_TYPE_EDIT())
BEGIN

  declare @tempClientID    int
  declare @tempGroupDispID int
  declare @tempGroupRpt    int
  declare @activeClaimRecs int
  declare @activeSvcRecs   int
  declare @prevConcatName  as nvarchar(100)

  SET @recordID   = NULL
  SET @canEdit    = 0
  SET @noFullEdit = 0
  SET @msg        = @MsgNoFullEdit

  /*-------------------------------
   * Does the record exist and if
   * so can it be edited
   *------------------------------*/

  SELECT top 1
    @recordID           = id,
    @canEdit            = canEdit,
    @isActive           = active,
    @tempClientID       = clientID,
    @tempGroupDispID    = groupID,
    @tempGroupRpt       = groupIDRept,
    @pracClientRecID    = pracClientRecID,
    @pracNoteRecID      = pracNoteRecID,
    @pracGroupDispRecID = pracGroupDispRecID,
    @pracGroupReptRecID = pracGroupReptRecID

  FROM
    dbo.PRACTITONERS_VIEW(@userID,@userGroup,@userRank,0,@recID,null,null,null, null,null,null,null,null,1,null)
  option (recompile)

  /*-------------------------------
   * If the record does not exist
   * or it cannot be edited
   * exit and let the user know
   *------------------------------*/

  IF (@recordID IS NULL) RAISERROR (@MsgNoRec,  11, 1)
  IF (@canEdit = 0)      RAISERROR (@MsgNoEdit, 11, 1)

  /*-------------------------------
   * See if this record has any
   * service records or claim
   * records.  If they have either
   * then this may prevent us from
   * allowing a full edit
   *------------------------------*/

    select
      @activeSvcRecs = COUNT(sr.id)
	from dbo.SERVICE_RECORDS as sr
	where (
	      ((sr.pracID = @recID)
	  and (sr.dos is not null)
	  and (sr.id > 0))
	  and (sr.[state] not in (99,199))
	) /* Uses [PRAC_DOS_W_STATE] */
	option (recompile)

  select
    @activeClaimRecs = COUNT(clm.CLAIM_ID)
  from dbo.CLAIM_Claim as clm
  where (
    clm.PRACTITIONER_ID = @recID
  ) /* Uses [PRACID_CLIENTID,W_DOS]*/
  option (recompile)

  /*-------------------------------
   * If the record has service or
   * claim records then there are
   * some columns can not be edited
   * other columns that can be
   * conditionally edited.
   *------------------------------*/

  IF (@activeClaimRecs > 0) OR (@activeSvcRecs > 0)
  BEGIN

    /*-------------------------------
     * User is requesting a group
     * change.
     *
     * Service and or claim records
     * exist for this record but
     * this change may still be
     * allowed.
     *------------------------------*/

    IF (@groupIDDisp != @tempGroupDispID)
    BEGIN

      declare @oldDispGroupID as int
      declare @oldGroupName   as varchar(500)

      /*-------------------------------
       * Get their current discipline
       * group
       *------------------------------*/

      set @oldDispGroupID = @tempGroupDispID

      /*-------------------------------
       * If their current discipline
       * group is cred/lic not verifed
       * see if we can find out
       * what their last disp. group
       * was.
       *------------------------------*/

      if (@tempGroupDispID = dbo.CONST_PRAC_GROUP_CRE_LIC_NOT_VER_ID())
      begin

        /*-------------------------------
         * Find the LAST discipline group
         * this prac. used.
         *------------------------------*/

        select top 1
          @oldDispGroupID = ISNULL(GROUP_ID,0),
          @oldGroupName   = ISNULL(GROUP_NAME,'')
        from dbo.PRACTITIONER_VIEW_GROUP_HISTORY(@recordID)
        where (GROUP_TYPE = 2 or GROUP_TYPE = 1)
        order by LAST_USED desc
		option (recompile)

        /*-------------------------------
         * If we could not find the group
         * setup the group id so it will
         * fail the next test
         *------------------------------*/

        if (@oldDispGroupID is null)
        begin
          SET @oldDispGroupID = 0
        end

       end

       /*-------------------------------
        * Make sure discipline group
        * change is permitted
        *
        * Discipline group changes are
        * allowed within the same group
        * base ("group team").
        *
        * This includes MAA to not MAA
        * changes.
        *------------------------------*/

       IF (dbo.IS_PRAC_GROUP_SAME_BASE(@groupIDDisp, @oldDispGroupID) = 0)
       BEGIN

         /*-------------------------------
          * Discipline group change is
          * not permitted
          *------------------------------*/

         SET @msg = 'Practitioner type cannot be changed.  Please contact IT@practi-cal.com with the CURRENT and NEW practitioner types.'
         SET @noFullEdit = 1

       END
    END

    /*-------------------------------
     * Client change
     *
     * The user is requesting a client
     * change... this is not allowed
     * if service and/or claim records
     * exist.
     *------------------------------*/

    IF (@clientID != @tempClientID)
    BEGIN
      SET @msg = 'Client cannot be changed.  Please contact IT@practi-cal.com.'
      SET @noFullEdit = 1
    END

  END

  /*-------------------------------
   * If the user attempted to change
   * columns that cannot be changed
   * let them know and exit.
   *------------------------------*/

  IF (@noFullEdit = 1)
    RAISERROR (@Msg, 11, 1)

  /*-------------------------------
   * Check if practitioner name has
   * been changed
   *------------------------------*/

   select top 1
     @prevConcatName = prp.CONCAT_NAME
   from dbo.PRACTITIONER_Practitioner as prp
   where prp.PRACTITIONER_ID = @recID
   option (recompile)

   if (@prevConcatName != @concat_name) set @pracNameChanged = 1


END

/*============================================================
 * Deserialize qualification data
 *============================================================*/

insert into @qualifData
SELECT
  GROUP_ID = t1.groupIDVal
, PRAC_NAME_ON_QUALIFICATION = trim(isnull(t1.fullName,''))
, QUALIFICATION_NUMBER = trim(isnull(t1.licenseNum,''))
, ISSUANCE_DATE = case when trim(isnull(t1.startDateStr,'')) = '' then NULL else convert (date,t1.startDateStr) end
, EXPIRATION_DATE = case when trim(isnull(t1.endDateStr,'')) = '' then NULL else convert (date,t1.endDateStr) end
, LIFE_TIME_QUALIFICATION = t1.isLifetimeVal
FROM OPENJSON(@qualificationsJSONData,'$')
WITH (
groupIDVal bigint '$.pracTypeID'
, fullName varchar(512) '$.fullName'
, licenseNum varchar(512) '$.licenseNum'
, startDateStr varchar(256) '$.startDate'
, endDateStr varchar(256) '$.endDate'
, isLifetimeVal bit '$.isLifetime'
) AS t1
option (recompile)

/*-------------------------------
 * Verify qualification data
 *------------------------------*/

IF EXISTS (SELECT 1 FROM @qualifData)
BEGIN

	IF EXISTS (SELECT * FROM @qualifData WHERE GROUP_ID is null)
		RAISERROR ('Invalid qualification group id', 11, 1)

	IF NOT EXISTS (SELECT * FROM @qualifData WHERE GROUP_ID > 0)
		RAISERROR ('Invalid qualification group id', 11, 1)

	IF ((select count(*) from @qualifData as qd
					JOIN dbo.GROUP_Group as gg on gg.GROUP_ID = qd.GROUP_ID
					WHERE ((gg.ACTIVE = 1) AND (gg.GROUP_TYPE = 1 OR gg.GROUP_TYPE = 2)))
		!= (select count(*) from @qualifData))

		RAISERROR ('Invalid qualification group id', 11, 1)

	IF EXISTS(SELECT * FROM @qualifData
	WHERE ((ISSUANCE_DATE is not null) and (EXPIRATION_DATE is null) and (LIFE_TIME_QUALIFICATION = 0)))
		RAISERROR ('Qualification expiration date is required if qualification is not lifetime', 11, 1)

	IF EXISTS(SELECT * FROM @qualifData
	WHERE ((ISSUANCE_DATE is null) and (EXPIRATION_DATE is not null)))
		RAISERROR ('Please provide a qualification issuance date', 11, 1)

	IF EXISTS(SELECT * FROM @qualifData
	WHERE (
			((ISSUANCE_DATE is not null) and (EXPIRATION_DATE is not null))
		    and (EXPIRATION_DATE <= ISSUANCE_DATE)
		  ))
		RAISERROR ('Qualification expiration date cannot be before or the same as issuance date', 11, 1)

END


/*-------------------------------
 * Validation
 *------------------------------*/

IF (((@saveType = dbo.CONST_SAVE_TYPE_NEW()) OR
     (@saveType = dbo.CONST_SAVE_TYPE_EDIT())))
BEGIN


  /*-------------------------------
   * Advisement validation
   * Advisement does not prohibit
   * a record save.
   *------------------------------*/

  IF (@validateRec = 1)
  BEGIN

    /*-------------------------------
     * Verify that clientEmployeeID
     * (if provided) is not used by
     * another active practitioner
     * within the same client scope.
     *-------------------------------*/

    set @clientEmployeeID = ltrim(rtrim(isnull(@clientEmployeeID,'')))

    if (@clientEmployeeID != '')
    begin
      if ( exists (
            select top 1
             1
            from dbo.PRACTITIONER_Client       as prc
            join dbo.PRACTITIONER_Practitioner as prp on prp.PRACTITIONER_ID = prc.PRACTITIONER_ID
            where (
                   (prp.ACTIVE = 1)
               and ((@recID IS NULL) or (prc.PRACTITIONER_ID != @recID))
               and (prc.CLIENT_ID = @clientID)
               and (prp.clientEmployeeID is not null)
               and (prp.clientEmployeeID != '')
               and (prp.clientEmployeeID = @clientEmployeeID)
        )
      ))
      begin
	   SET @spDetails = dbo.UPDATE_DETAILS(@spDetails,'One or more active practitioners have already have been assigned this employee id', dbo.CONST_RET_WARN())
      end
    end

    /*-------------------------------
     * Verify that NPI#
     * (if provided) is not used by
     * another active practitioner
     * within the same client scope.
     *-------------------------------*/

    set @npiNumber = ltrim(rtrim(isnull(@npiNumber,'')))

    if (@npiNumber != '')
    begin
      if ( exists (
            select top 1
              1
            from dbo.PRACTITIONER_Client       as prc
            join dbo.PRACTITIONER_Practitioner as prp on prp.PRACTITIONER_ID = prc.PRACTITIONER_ID
            where (
                   (prp.ACTIVE = 1)
               and ((@recID IS NULL) or (prc.PRACTITIONER_ID != @recID))
               and (prc.CLIENT_ID = @clientID)
               and (prp.npiNumber is not null)
               and (prp.npiNumber != '')
               and (prp.npiNumber = @npiNumber)
        )
      ))
      begin
        SET @spDetails = dbo.UPDATE_DETAILS(@spDetails,'One or more active practitioners have already been assigned this NPI#', dbo.CONST_RET_WARN())
      end
    end

    /*-------------------------------
     * Look for duplicate
     * records excluding the record
     * specified by recid
     *------------------------------*/

    SET @dupCount = 0

    /*-------------------------------
     * For duplicate checking
     * We can rely on always having
     * the following fields:
     *
     *   clientid
     *   lastname
     *   firstname
     *   groupIDDisp
     *------------------------------*/

    SELECT
      @dupCount = COUNT(pv.id)
    FROM
      dbo.PRACTITONERS_VIEW_CORE(0, @clientID, null,null, @lname, @fname, null, null, null, null,null) as pv
    WHERE
      (pv.groupIDDisp = @groupIDDisp) AND ((@recID IS NULL) OR (pv.id != @recID))
    option (recompile)

    IF @dupCount > 0
    BEGIN
      SET @msgDupRec = dbo.STRING_CREATE(@msgDupRec, CONVERT(VARCHAR(10),@dupCount), NULL, NULL)
      SET @spDetails = dbo.UPDATE_DETAILS(@spDetails,@msgDupRec,dbo.CONST_RET_DUP_RECORD())
    END

    /*-------------------------------
     * If we are editing and the
     * record we are editing is not
     * active warn the user
     *------------------------------*/

    IF ((@isActive = 0) AND (@saveType = dbo.CONST_SAVE_TYPE_EDIT()))
      SET @spDetails = dbo.UPDATE_DETAILS(@spDetails,@MsgNotActive, dbo.CONST_RET_WARN())


    /*-------------------------------
     * If we are providing advisement
     * validation exit now
     *------------------------------*/

    RETURN(0)

  END
END

/*-------------------------------
 * Create or modify our
 * practitioner record
 *------------------------------*/

BEGIN TRANSACTION

  SET @TranOpen = 1

  /*-------------------------------
   * New entity record
   *------------------------------*/

  IF (@saveType = dbo.CONST_SAVE_TYPE_NEW())
  BEGIN

    SET @updateState = dbo.CONST_REC_STATE_NEW()
    if (@submitClaims is null) set @submitClaims = 1

    /*-------------------------------
     * Practitioner
     *------------------------------*/

    INSERT INTO dbo.PRACTITIONER_Practitioner
    (
      LAST_NAME,
      FIRST_NAME,
      PHONE_NUMBER,
      FAX_NUMBER,
      CONCAT_NAME,
      DATE_CREATED,
      DATE_MODIFIED,
      EMAIL,
      ACTIVE,
      state,
      createdByUserID,

      participatesInLEABOP ,
	  participatesInLEABOPNonSpEd,
      participatesInCYBHI  ,
	  participatesInRUHealth,

      Submit_Claims,
      clientEmployeeID,
      claim_TCM,
      submitClaimsEffectiveDate,
      claim_TCMEffectiveDate,
	  cybhiTpaApproved,
	  cybhiTpaApprovedOn,
      cybhiTpaID,
	  cybhiSubmitClaims,
      npiNumber,
      isValidMcalOrp,
      isValidMcalOrpLastValidated,
      employeeRelationshipID,
      includeInFinRepts,
      street1,
      street2,
      city,
      [usState],
      zip5,
      zip4,
	  cprCertEffectiveDate,
	  cprCertExpirationDate,
	  qualificationsJSONData,
	  deptHead,
	  displayPercent,
	  displayMoney,
	  acesCertCompletedOn,
	  deptHeadCanSeeEntirePracticeFamilyInDeptReviewReports,
	  dob,
	  gender,
      ssn,

      cybhiDegreeCode,
      cybhiDegreeCode2,
      cybhiDegreeCode3,
      cybhiSpecialtyCode,
      cybhiSpecialtyCode2,
      cybhiSpecialtyCode3,
      cybhiSpecialtyCode4,

      currentlyWithClient

    )
    VALUES
    (
      @lname,
      @fname,
      @phone,
      @fax,
      @concat_name,
      @today,
      @today,
      @email,
      1,
      @updateState,
      @userID,

      @participatesInLEABOP ,
	  @participatesInLEABOPNonSpEd ,
      @participatesInCYBHI  ,
	  @participatesInRUHealth,

      @submitClaims,
      @clientEmployeeID,
      @claim_TCM,
      @submitClaimsEffectiveDate,
      @claim_TCMEffectiveDate,
	  @cybhiTpaApproved,
	  @cybhiTpaApprovedOn,
	  @cybhiTpaID,
	  @cybhiSubmitClaims,
      @npiNumber,
      @isValidMcalOrp,
      @isValidMcalOrpLastValidated,
      @employeeRelationship,
      @incInFinRepts,
      @street1,
      @street2,
      @city,
      @state,
      @zip5,
      @zip4,
	  @cprCertEffectiveDate,
	  @cprCertExpirationDate,
	  @qualificationsJSONData,
	  @deptHead,
	  @displayPercent,
	  @displayMoney,
	  @acesCertCompletedOn,
	  @deptHeadCanSeeEntirePracticeFamilyInDeptReviewReports,
	  @dob,
	  @gender,
      @ssn,
	  @cybhiDegreeCode,
      @cybhiDegreeCode2,
      @cybhiDegreeCode3,
      @cybhiSpecialtyCode,
      @cybhiSpecialtyCode2,
      @cybhiSpecialtyCode3,
      @cybhiSpecialtyCode4,

      @currentlyWithClient


    )

    SET @recordID = SCOPE_IDENTITY()

   /*-------------------------------
    * Practitioner client
    *------------------------------*/

   INSERT INTO dbo.PRACTITIONER_Client
   (
     PRACTITIONER_ID,
     CLIENT_ID,
     DATE_START,
     DATE_END
   )
   VALUES
   (
     @recordID,
     @clientID,
     @startDate,
     @endDate
   )

   /*-------------------------------
    * Practitioner allied discipline
    * group
    *------------------------------*/

  INSERT INTO dbo.PRACTITIONER_GROUPS
   (
     GROUP_ID,
     PRACTITIONER_ID,
     GROUP_TYPE,
     ACTIVE
   )
   VALUES
   (  @groupIDDisp,
      @recordID,
      @dspGroupType,
      1
   )

   /*-------------------------------
    * Practitioner reporting group
    *------------------------------*/

  IF @groupIDRept IS NOT NULL

  INSERT INTO dbo.PRACTITIONER_GROUPS
  (
    GROUP_ID,
    PRACTITIONER_ID,
    GROUP_TYPE,
    ACTIVE)
   VALUES
   (
     @groupIDRept,
     @recordID,
     @rptGroupType,
     1
   )

  /*-------------------------------
   * Practitioner notes
   *------------------------------*/

  INSERT INTO PRACTITIONER_Note
  (
    NOTE_PRACTITIONER_ID,
    NOTE
  )
  VALUES
  (
    @recordID,
    @notes
  )

  END

  ELSE IF (@saveType = dbo.CONST_SAVE_TYPE_EDIT())
  BEGIN

    /*-------------------------------
     * Edit existing entity record
     *------------------------------*/

     SET @updateState = dbo.CONST_REC_STATE_MOD()


     UPDATE dbo.PRACTITIONER_Practitioner
     SET
       LAST_NAME                   = @lname,
       FIRST_NAME                  = @fname,
       PHONE_NUMBER                = @phone,
       FAX_NUMBER                  = @fax,
       CONCAT_NAME                 = @concat_name,
       DATE_MODIFIED               = @today,
       EMAIL                       = @email,
       state                       = @updateState,

       participatesInLEABOP        = @participatesInLEABOP ,
	   participatesInLEABOPNonSped = @participatesInLEABOPNonSpEd,
       participatesInCYBHI         = @participatesInCYBHI  ,
	   participatesInRUHealth      = @participatesInRUHealth,

	   Submit_Claims               = @submitClaims,
       clientEmployeeID            = @clientEmployeeID,
       claim_TCM                   = @claim_TCM,
       submitClaimsEffectiveDate   = @submitClaimsEffectiveDate,
       claim_TCMEffectiveDate      = @claim_TCMEffectiveDate,
	   cybhiTpaApproved			   = @cybhiTpaApproved,
	   cybhiTpaApprovedOn		   = @cybhiTpaApprovedOn,
	   cybhiTpaID			       = @cybhiTpaID,
	   cybhiSubmitClaims		   = @cybhiSubmitClaims,
       npiNumber                   = @npiNumber,
       isValidMcalOrp              = @isValidMcalOrp,
       isValidMcalOrpLastValidated = @isValidMcalOrpLastValidated,
       employeeRelationshipID      = @employeeRelationship,
       includeInFinRepts           = @incInFinRepts,
       street1                     = @street1,
       street2                     = @street2,
       city                        = @city,
       [usState]                   = @state,
       zip5                        = @zip5,
       zip4                        = @zip4,
	   cprCertEffectiveDate        = @cprCertEffectiveDate,
	   cprCertExpirationDate       = @cprCertExpirationDate,
	   qualificationsJSONData      = @qualificationsJSONData,
	   deptHead                    = @deptHead,
	   displayPercent              = @displayPercent,
	   displayMoney                = @displayMoney,
	   acesCertCompletedOn         = @acesCertCompletedOn,
	   deptHeadCanSeeEntirePracticeFamilyInDeptReviewReports = @deptHeadCanSeeEntirePracticeFamilyInDeptReviewReports,
	   dob                = @dob,
	   gender             = @gender,
       ssn                = @ssn,
       cybhiDegreeCode     = @cybhiDegreeCode,
       cybhiDegreeCode2    = @cybhiDegreeCode2,
       cybhiDegreeCode3    = @cybhiDegreeCode3,
       cybhiSpecialtyCode  = @cybhiSpecialtyCode,
       cybhiSpecialtyCode2 = @cybhiSpecialtyCode2,
       cybhiSpecialtyCode3 = @cybhiSpecialtyCode3,
       cybhiSpecialtyCode4 = @cybhiSpecialtyCode4,

       currentlyWithClient  = @currentlyWithClient

     WHERE (PRACTITIONER_ID = @recordID)

     /*-------------------------------
      * Practitioner client
      *------------------------------*/

     UPDATE dbo.PRACTITIONER_Client
     SET
       CLIENT_ID = @clientID,
       DATE_START = @startDate,
       DATE_END   = @endDate
     WHERE (PRACCLIENT_ID = @pracClientRecID)

     /*-------------------------------
      * Edit Practitioner allied
      * discipline group
      *------------------------------*/

     UPDATE PRACTITIONER_GROUPS
     SET GROUP_ID = @groupIDDisp,GROUP_TYPE = @dspGroupType
     WHERE (PRACTITIONER_GROUP = @pracGroupDispRecID)

    /*----------------------------------
     * Edit Practitioner reporting group
     *----------------------------------*/

    IF (@groupIDRept IS NOT NULL) and ((@tempGroupRpt is null) or (@tempGroupRpt = 0))

      /*----------------------------------
       * Practitioner is having a report
       * group initially assigned to them
       * so we have to actually insert a
       * new record vs an update because
       * the reporting group is not required
       * as part of a new practitioner record
       * so the record may not exist yet.
       *----------------------------------*/

      INSERT INTO dbo.PRACTITIONER_GROUPS
	  (
		GROUP_ID,
		PRACTITIONER_ID,
		GROUP_TYPE,
		ACTIVE)
	   VALUES
	   (
		 @groupIDRept,
		 @recordID,
		 @rptGroupType,
		 1
	   )

    IF (@groupIDRept IS NOT NULL) and (@tempGroupRpt is not null)

      /*----------------------------------
       * Editing report group
       *----------------------------------*/

      UPDATE dbo.PRACTITIONER_GROUPS
      SET GROUP_ID = @groupIDRept,GROUP_TYPE = @rptGroupType
      WHERE (PRACTITIONER_GROUP = @pracGroupReptRecID)

    /*-------------------------------
     * Edit Practitioner notes
     *------------------------------*/

    UPDATE dbo.PRACTITIONER_Note
    SET NOTE = @notes
    WHERE (NOTE_ID = @pracNoteRecID)

	/*-------------------------------
     * Update cached RMTS
	 * participation data if the
     * practitioner name changes
     * NOTE: THIS UPDATES THE ENTIRE
	 * ROSTER THE PRAC IS A PART OF
	 * BE VERY CAREFUL WITH CHANGES
	 * TO THIS CODE.
	 *------------------------------*/
    if (@pracNameChanged = 1)
	begin

	/* Find rosters that prac is a part of and extract each participant into their own row*/

    ;with
    cte_update_rmts_1
    as
    (
      select
         t2.id
       , t2.clientID
       , t2.quarterID
       , t3.[key]
       , t3.[value]
      from dbo.RMTS_PARTICIPANTS         as t1
      join dbo.RMTS_PARTICIPATION_ROSTER as t2 on t2.id = t1.rosterID
      cross apply OPENJSON(t2.participantRosterJSON) as t3
      where (
            (t1.pracID   = @recID)
        and (t2.clientID = @clientID)
      )
    )
    ,

	/* Extracting prac ID from roster data */

	cte_update_rmts_2
    as
    (
      select
        p1.id
      , p1.clientID
      , p1.quarterID
      , p1.[key]
      , pracID = JSON_VALUE(p1.[value], '$.id')
      , p1.[value]
      from cte_update_rmts_1 as p1
    )
    ,
    /* Recreate each participant row being sure to replace the practioners name that changed */
	cte_update_rmts_3
    as
    (
      select
        p2.*
      , [correctedValue] = JSON_MODIFY(p2.[value], '$.name', iif(p2.pracID = @recID, @concat_name, prp.CONCAT_NAME))
      from cte_update_rmts_2             as p2
      join dbo.PRACTITIONER_Practitioner as prp on prp.PRACTITIONER_ID = p2.pracID
    )
    /* Update JUST the rosters we found in p1 */
	update rmtspr
    set
      [participantRosterJSON] = isnull((select '[' + STRING_AGG(correctedValue, ',') + ']' from cte_update_rmts_3 as p3 where p3.id = rmtspr.id),'[]')
    from dbo.RMTS_PARTICIPATION_ROSTER as rmtspr
    join (
      select distinct
        p1_1.id
      from cte_update_rmts_1 as p1_1
    ) as p1_2 on p1_2.id = rmtspr.id

  end

  END
  ELSE
  BEGIN
    RAISERROR ('Unknown save type', 11, 1)
  END

  if (@saveCprCertHistoryData = 1)
  begin

    if not exists (
		select top 1 ID from dbo.PRACTITIONER_CPR_CERTIFICATION as t1
		where ((t1.CLIENT_ID = @clientID) and (t1.PRACTITIONER_ID = @recordID) and (t1.EFFECTIVE_DATE = @cprCertEffectiveDate) and (t1.EXPIRATION_DATE = @cprCertExpirationDate))
		)
    begin

      INSERT INTO dbo.PRACTITIONER_CPR_CERTIFICATION
	  (
		  CLIENT_ID
		, PRACTITIONER_ID
		, EFFECTIVE_DATE
		, EXPIRATION_DATE
		, CREATED_ON
		, CREATED_BY
	  )
	   VALUES
	   (
		  @clientID
		, @recordID
		, @cprCertEffectiveDate
		, @cprCertExpirationDate
		, @today
		, @userID
	   )

    end
  end

  /*============================================================
   * Update the previous table we used to track the qualification data
   *============================================================*/

  delete dbo.PRACTITIONER_QUALIFICATIONS
  where  PRACTITIONER_ID = @recordID

  insert into [dbo].[PRACTITIONER_QUALIFICATIONS] (
      PRACTITIONER_ID
	, GROUP_ID
	, PRAC_NAME_ON_QUALIFICATION
	, QUALIFICATION_NUMBER
	, ISSUANCE_DATE
	, EXPIRATION_DATE
	, LIFE_TIME_QUALIFICATION
	, CREATED_LAST_MODIFIED_BY
	, CREATED_LAST_MODIFIED_ON
	, ACTIVE
  )
  select
      @recordID
    , t2.GROUP_ID
	, t2.PRAC_NAME_ON_QUALIFICATION
	, t2.QUALIFICATION_NUMBER
	, t2.ISSUANCE_DATE
	, t2.EXPIRATION_DATE
	, t2.LIFE_TIME_QUALIFICATION
    , [CREATED_LAST_MODIFIED_BY] = @userID
    , [CREATED_LAST_MODIFIED_ON] = @today
    , [ACTIVE]                   = 1
  from @qualifData as t2


  /*-------------------------------
   * Create audit record
   *------------------------------*/

   EXEC dbo.PRACTITIONERS_Audit @recordID, @today, @userID, @saveType, @updateState, @editDelReason, @auditRecID OUTPUT

/*-------------------------------
 * If we reach this point
 * everything is OK, commit our
 * changes and exit
 *------------------------------*/

COMMIT TRANSACTION
SET @TranOpen = 0
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

  -- Reraise the error so it returns back to the server

  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)

END CATCH
END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[PRACTITIONERS_Save] TO [webuser]
GO
