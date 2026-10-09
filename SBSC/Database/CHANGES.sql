/* If you need to install recent changes that were in this script on 7/13/2025 but
   are are no longer in this script now please run 
   "C:\SBSC\Spedmon\Installers\PREV_CHANGES.sql" first. */

USE SPEDMON
GO


-------------------------------------------------------

USE [SPEDMON]
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PATIENT_INFO_REQUESTS_PUBLIC_FORM_OPTIONS]') AND type in (N'U'))
BEGIN
	CREATE TABLE [PATIENT_INFO_REQUESTS_PUBLIC_FORM_OPTIONS] (
            id					 						bigint 			IDENTITY(1,1),
			clientID 									bigint 			NOT NULL,
			insuranceInfoRequestMessageBodyContentEN 	varchar(max)	NULL,
			insuranceInfoRequestMessageBodyContentES 	varchar(max)	NULL,
			created 									datetime 		NULL,
			createdBy 									bigint			NULL,
			lastModified 								datetime 		NULL,
			lastModifiedBy 								bigint 			NULL,
			active 										bit 			default(1)

	) ON [PRIMARY]     	
END
GO


-------------------------------------------------------

USE [SPEDMON]
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PATIENT_INFO_REQUESTS_FORM_OPTIONS]') AND type in (N'U'))
BEGIN
	CREATE TABLE [PATIENT_INFO_REQUESTS_FORM_OPTIONS] (
            id					 						bigint 			IDENTITY(1,1),
			clientID 									bigint 			NOT NULL,
			insuranceInfoRequestMessageBodyContentEN 	varchar(max)	NULL,
			insuranceInfoRequestMessageBodyContentES 	varchar(max)	NULL,
			created 									datetime 		NULL,
			createdBy 									bigint			NULL,
			lastModified 								datetime 		NULL,
			lastModifiedBy 								bigint 			NULL,
			active 										bit 			default(1)

	) ON [PRIMARY]     	
END
GO


-------------------------------------------------------

USE [SPEDMON]
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PRACTITIONER_PATIENT_REFERRALS]') AND type in (N'U'))
BEGIN
	CREATE TABLE [PRACTITIONER_PATIENT_REFERRALS] (
            id					 	bigint 			IDENTITY(1,1),
			clientID 				bigint 			NOT NULL,
			patID 					bigint 			NOT NULL,
			pracID					bigint			NOT NULL,
			priority				tinyint         NOT NULL, 
			publicToken				varchar(512)    NOT NULL,
			pinParent				varchar(10)		NULL, 
			pinPract				varchar(10)		NULL, 
			referredToPracName		varchar(256)	NOT NULL,
			referredToOrgName		varchar(256)    NOT NULL,
			referredToPracEmail     varchar(256)	NOT NULL,
			referredToPracPhone     varchar(256)	NOT NULL,
			referredToClientID		bigint			NULL,
			referredToPracID		bigint			NULL,
			referredToPersonID		bigint			NULL,			
			parentGuardianConsent	bit				NULL,
			notes					varchar(max)    NULL,
			refFileID				varchar(max)	NULL,
			includeDiagnoses                              bit   NULL,
			includeOrdersOrPrescriptions                  bit   NULL,
			includeServiceRecordsTreatments               bit   NULL,
			includeServiceRecordsAssessementsOrScreenings bit   NULL,
			includeServiceNotesNonConfidential            bit   NULL,
			includeServiceNotesConfidential               bit   NULL,
			startDate				date			NULL,
			startTime				time(0)			NULL,
			expirationDate			date			NULL,
			expirationTime			time(0)			NULL,
			isUsed					bit				NULL,
			created 				datetime 		NULL,
			createdBy 				bigint			NULL,
			lastModified 			datetime 		NULL,
			lastModifiedBy 			bigint 			NULL,
			active 					bit 			default(1)

	) ON [PRIMARY]     	
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PRACTITIONER_PATIENT_REFERRALS]') 
         AND name = 'approvalRejectionDate'
)
BEGIN
    ALTER TABLE dbo.PRACTITIONER_PATIENT_REFERRALS
    ADD approvalRejectionDate DATE NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PRACTITIONER_PATIENT_REFERRALS]') 
         AND name = 'approvalRejectionTime'
)
BEGIN
    ALTER TABLE dbo.PRACTITIONER_PATIENT_REFERRALS
    ADD approvalRejectionTime TIME(0) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PRACTITIONER_PATIENT_REFERRALS]') 
         AND name = 'parentGuardianName'
)
BEGIN
    ALTER TABLE dbo.PRACTITIONER_PATIENT_REFERRALS
    ADD parentGuardianName VARCHAR(256) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PRACTITIONER_PATIENT_REFERRALS]') 
         AND name = 'parentGuardianRelationship'
)
BEGIN
    ALTER TABLE dbo.PRACTITIONER_PATIENT_REFERRALS
    ADD parentGuardianRelationship VARCHAR(256) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PRACTITIONER_PATIENT_REFERRALS]') 
         AND name = 'parentGuardianEmail'
)
BEGIN
    ALTER TABLE dbo.PRACTITIONER_PATIENT_REFERRALS
    ADD parentGuardianEmail VARCHAR(256) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PRACTITIONER_PATIENT_REFERRALS]') 
         AND name = 'parentGuardianPhone'
)
BEGIN
    ALTER TABLE dbo.PRACTITIONER_PATIENT_REFERRALS
    ADD parentGuardianPhone VARCHAR(256) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[KNOWN_HEALTH_PROBLEMS]') 
  AND name = 'belongsToHealthServices'              
)
  alter table dbo.KNOWN_HEALTH_PROBLEMS
  add belongsToHealthServices  bit  not null default(0);
go

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[KNOWN_HEALTH_PROBLEMS]') 
  AND name = 'belongsToMentalHealth'              
)
  alter table dbo.KNOWN_HEALTH_PROBLEMS
  add  belongsToMentalHealth  bit  not null default(0);
go

-----------------------------------------------------------------

USE SPEDMON
GO
 
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PATIENT_INFO_REQUESTS_PUBLIC_INSURANCE_FORMS]') AND type in (N'U'))
BEGIN
 
  CREATE TABLE dbo.[PATIENT_INFO_REQUESTS_PUBLIC_INSURANCE_FORMS] (
      id                               bigint       not null identity(1,1) primary key
    , clientID                         bigint   
        , publicToken                      varchar(512) not null
    , created                          datetime     not null
        , createdBy                        bigint       not null
        , lastModified                     datetime     null
        , lastModifiedBy                   bigint       null
        , active                           bit          not null default(1)
  ) ON [PRIMARY]        
 
  /* Prefill */
 
  declare @today       as datetime = getdate() 
  declare @userID      as bigint   = 805
  declare @curIdx      as int      = 0
  declare @maxIdx      as int      = 0
  declare @publicToken as varchar(512) = ''
 
  declare @clients as table (
      idx         int identity(1,1) primary key
    , clientID    bigint
    , publicToken varchar(512)
  unique clustered (idx)
  )
 
  insert into @clients (clientID)
  select 
    clientID = clc.CLIENT_ID
  from dbo.CLIENTS_Client as clc
  
  select @maxIdx = max(t1.idx) from @clients as t1
 
  while (@curIdx <= @maxIdx)
  begin
  
    set @publicToken = ''
  
    select top 1
      @publicToken = convert(varchar(256),t1.clientID) 
    from @clients as t1
    where 
      (t1.idx = @curIdx)                 
 
    /* Add unique id to reduce chance of collision and help hide clientid */
  
    select top 1
      @publicToken = @publicToken + gnui.NEW_UNIQUE_ID_STR_NO_DASH
    from GENERATE_NEW_UNIQUE_ID as gnui
 
    update @clients 
      set publicToken = @publicToken
    where (idx = @curIdx)  
  
    set @curIdx = @curIdx + 1
  end
 
  insert into dbo.PATIENT_INFO_REQUESTS_PUBLIC_INSURANCE_FORMS (
      clientID             
        , publicToken  
    , created   
        , createdBy
  )
  select t1.clientID, t1.publicToken, created = @today, createdBy = @userID
  from @clients as t1
        
END
GO
 
-------------------------------------------------------
 
USE SPEDMON
GO
/*
drop table PATIENT_INFO_REQUESTS_PUBLIC_INSURANCE_FORM_RESPONSES
*/ 
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PATIENT_INFO_REQUESTS_PUBLIC_INSURANCE_FORM_RESPONSES]') AND type in (N'U'))
BEGIN
  CREATE TABLE dbo.[PATIENT_INFO_REQUESTS_PUBLIC_INSURANCE_FORM_RESPONSES] (
      id                               bigint       not null identity(1,1) primary key
        , patInfoReqPublicInsuranceFormID  bigint       not null /* Form record */
        , patientFirstName                 nvarchar(50) not null
        , patientLastName                  nvarchar(50) not null
        , patientDOB                       datetime     not null
        , studentID                        nvarchar(50) 
        , insuranceCarrierID               bigint
        , memberID                         varchar(80)
        , noInsuranceOptionSelected        bit           not null default(0)
        , otherInsuranceOptionSelected     bit           not null default(0)
        , insuranceCarrierOtherName        varchar(256)
        , consentToReleaseOfChildHealthRecsAndOrBenefitInfo bit not null default(0)
        , responderIsParentGuardian                         bit not null default(1)
        , responderFirstName                                varchar(255)
        , responderLastName                                 varchar(255)
        , responderEmail                                    varchar(255)
        , responderPhone                                    varchar(255)
        , responderSignatureImgData        varchar(max)
        , responderUserIP                  varchar(500)
        , responderUserAgent               varchar(8000) 
        
        , clientID                         bigint       not null
        , patID                            bigint
      
  	    , created                          datetime  not null
        , createdBy                        bigint    not null

        , reviewed                         bit        default(0)   /* We set this to 1 once the user thumbs up or thumbs down */
		, reviewedOn                       datetime
        , reviewedBy                       bigint
        , accepted                         bit       default(0)   /* This will be 1 if thumbs up, 0 if thumbs down */

		, lastModified                     datetime  null
        , lastModifiedBy                   bigint    null
        
		, active                           bit not null default(1)
        
  ) ON [PRIMARY]        
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'deceased'
)
BEGIN
    ALTER TABLE [dbo].[PATIENTS_Patient]
    ADD deceased bit not null default 0
END
GO

-------------------------------------------------------

USE SPEDMON
GO


if not exists (select top 1 id from dbo.CYBHI_CLAIM_HOLD_CODES where holdCode = 530)
begin
  insert into dbo.CYBHI_CLAIM_HOLD_CODES (holdCode,holdReason,clientActionable)
  values (530,'FERPA Consent is No or Unknown',1)
end

go

-------------------------------------------------------

USE SPEDMON
GO

if not exists (select top 1 id from dbo.CYBHI_CLAIM_HOLD_CODES where holdCode = 540)
begin
  insert into dbo.CYBHI_CLAIM_HOLD_CODES (holdCode,holdReason,clientActionable)
  values (540,'Patient TPA Enrollment State is Accepted But Patient Enrollment Info Sent To TPA By Mistake (9)',1)
end

go


-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENT_INFO_REQUESTS_PUBLIC_INSURANCE_FORM_RESPONSES]') 
         AND name = 'patPerID'
)
BEGIN
    ALTER TABLE [dbo].[PATIENT_INFO_REQUESTS_PUBLIC_INSURANCE_FORM_RESPONSES]
    ADD patPerID bigint 
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENT_INFO_REQUESTS_PUBLIC_INSURANCE_FORM_RESPONSES]') 
         AND name = 'patientInsuranceCarrierRecID'
)
BEGIN
    ALTER TABLE [dbo].[PATIENT_INFO_REQUESTS_PUBLIC_INSURANCE_FORM_RESPONSES]
    ADD patientInsuranceCarrierRecID bigint 
END
GO

-------------------------------------------------------

USE [SPEDMON]
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PATIENT_PROFILE_PICTURES]') AND type in (N'U'))
BEGIN
CREATE TABLE [PATIENT_PROFILE_PICTURES]
(
      id                      bigint IDENTITY(1,1) not null primary key
    , clientID                bigint NOT NULL
    , patID                   bigint NOT NULL
    , [fileName]              varchar(256) not null
    , profilePictureImgData   varbinary(max) NOT NULL
    , originalSize            int      not NULL
    , compressedSize          int      not NULL
    , created                 datetime not null
    , createdBy               bigint not null
    , lastModified            datetime NULL
    , lastModifiedBy          bigint NULL
    , active                  bit not null default(1)
) ON [PRIMARY]
END
GO


-------------------------------------------------------

USE SPEDMON
GO

if not exists (select top 1 id from dbo.CYBHI_CLAIM_HOLD_CODES where holdCode = 510)
begin
  insert into dbo.CYBHI_CLAIM_HOLD_CODES (holdCode,holdReason,clientActionable)
  values (510,'Missing or incomplete patient address',1)
end

go

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[RMTS_Moments]') 
  AND name = 'deferralDate' 
)
begin
  alter table [dbo].[RMTS_Moments] 
  add deferralDate date null
end

go


IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[RMTS_Moments]') 
  AND name = 'deferredBy' 
)
begin
  alter table [dbo].[RMTS_Moments] 
  add deferredBy bigint null
end

go


IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[RMTS_Moments]') 
  AND name = 'deferralReason' 
)
begin
  alter table [dbo].[RMTS_Moments] 
  add deferralReason varchar(200) null
end

go

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[RMTS_Moments]') 
  AND name = 'deferralReasonNotes' 
)
begin
  alter table [dbo].[RMTS_Moments] 
  add deferralReasonNotes varchar(max) null
end

go


-------------------------------------------------------

USE SPEDMON
GO


IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[RMTS_PARTICIPANTS]') 
  AND name = 'deferralDate' 
)
begin
  alter table [dbo].[RMTS_PARTICIPANTS] 
  add deferralDate date null
end

go


IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[RMTS_PARTICIPANTS]') 
  AND name = 'deferredBy' 
)
begin
  alter table [dbo].[RMTS_PARTICIPANTS] 
  add deferredBy bigint null
end

go


IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[RMTS_PARTICIPANTS]') 
  AND name = 'deferralReason' 
)
begin
  alter table [dbo].[RMTS_PARTICIPANTS] 
  add deferralReason varchar(200) null
end

go


IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[RMTS_PARTICIPANTS]') 
  AND name = 'deferralReasonNotes' 
)
begin
  alter table [dbo].[RMTS_PARTICIPANTS] 
  add deferralReasonNotes varchar(max) null
end

go

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PRACTITIONER_PATIENT_REFERRALS]') 
         AND name = 'referralSourceName'
)
BEGIN
    ALTER TABLE dbo.PRACTITIONER_PATIENT_REFERRALS
    ADD referralSourceName VARCHAR(256) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PRACTITIONER_PATIENT_REFERRALS]') 
         AND name = 'referralSourceRole'
)
BEGIN
    ALTER TABLE dbo.PRACTITIONER_PATIENT_REFERRALS
    ADD referralSourceRole VARCHAR(256) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PRACTITIONER_PATIENT_REFERRALS]') 
         AND name = 'referralSourceEmail'
)
BEGIN
    ALTER TABLE dbo.PRACTITIONER_PATIENT_REFERRALS
    ADD referralSourceEmail VARCHAR(256) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PRACTITIONER_PATIENT_REFERRALS]') 
         AND name = 'referralSourcePhone'
)
BEGIN
    ALTER TABLE dbo.PRACTITIONER_PATIENT_REFERRALS
    ADD referralSourcePhone VARCHAR(256) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PRACTITIONER_PATIENT_REFERRALS]') 
         AND name = 'behavioralIsssuesConcerns'
)
BEGIN
    ALTER TABLE dbo.PRACTITIONER_PATIENT_REFERRALS
    ADD behavioralIsssuesConcerns bit 
END
GO
-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PRACTITIONER_PATIENT_REFERRALS]') 
         AND name = 'academicConcerns'
)
BEGIN
    ALTER TABLE dbo.PRACTITIONER_PATIENT_REFERRALS
    ADD academicConcerns bit 
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PRACTITIONER_PATIENT_REFERRALS]') 
         AND name = 'anxietyOrDepressionConcerns'
)
BEGIN
    ALTER TABLE dbo.PRACTITIONER_PATIENT_REFERRALS
    ADD anxietyOrDepressionConcerns bit 
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PRACTITIONER_PATIENT_REFERRALS]') 
         AND name = 'familyStressConcerns'
)
BEGIN
    ALTER TABLE dbo.PRACTITIONER_PATIENT_REFERRALS
    ADD familyStressConcerns bit 
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PRACTITIONER_PATIENT_REFERRALS]') 
         AND name = 'bullyingConcerns'
)
BEGIN
    ALTER TABLE dbo.PRACTITIONER_PATIENT_REFERRALS
    ADD bullyingConcerns bit 
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PRACTITIONER_PATIENT_REFERRALS]') 
         AND name = 'otherConcerns'
)
BEGIN
    ALTER TABLE dbo.PRACTITIONER_PATIENT_REFERRALS
    ADD otherConcerns VARCHAR(256)
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF EXISTS (
    SELECT 1
    FROM sys.columns 
    WHERE object_id = OBJECT_ID(N'[dbo].[PRACTITIONER_PATIENT_REFERRALS]')
      AND name = 'referredToPracPhone'
)
BEGIN
    ALTER TABLE dbo.PRACTITIONER_PATIENT_REFERRALS
    ALTER COLUMN referredToPracPhone VARCHAR(256) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF EXISTS (
    SELECT 1
    FROM sys.columns 
    WHERE object_id = OBJECT_ID(N'[dbo].[PRACTITIONER_PATIENT_REFERRALS]')
      AND name = 'referredToPracEmail'
)
BEGIN
    ALTER TABLE dbo.PRACTITIONER_PATIENT_REFERRALS
    ALTER COLUMN referredToPracEmail VARCHAR(256) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[STUDENT_INFORMATION_SYSTEMS]') AND type in (N'U'))
BEGIN
CREATE TABLE [STUDENT_INFORMATION_SYSTEMS]
(
      id                      bigint IDENTITY(1,1) not null primary key
    , [name]                  varchar(256) not null
	, additionalDataJSON	  varchar(max) not null default('{}')
    , created                 datetime     not null
    , createdBy               bigint       not null
    , lastModified            datetime     null
    , lastModifiedBy          bigint       null
    , active                  bit not null default(1)
) ON [PRIMARY]
END
GO

-------------------------------------------------------

USE SPEDMON
GO

if not exists (select top 1 id from dbo.STUDENT_INFORMATION_SYSTEMS where [name] = 'Aries')
begin
  insert into dbo.STUDENT_INFORMATION_SYSTEMS ([name], created, createdBy, active)
  values ('Aries', GETDATE(), 805, 1)
end
go
-------------------------------------------------------

/*USE SPEDMON
GO

if not exists (select top 1 id from dbo.STUDENT_INFORMATION_SYSTEMS where [name] = 'SEIS')
begin
  insert into dbo.STUDENT_INFORMATION_SYSTEMS ([name], created, createdBy, active)
  values ('SEIS', GETDATE(), 0, 1)
end
go
*/

-------------------------------------------------------

USE SPEDMON
GO

--drop table CLIENT_STUDENT_INFORMATION_SYSTEMS

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CLIENT_STUDENT_INFORMATION_SYSTEMS]') AND type in (N'U'))
BEGIN
CREATE TABLE [CLIENT_STUDENT_INFORMATION_SYSTEMS]
(
      id                      bigint IDENTITY(1,1) not null primary key
    , clientID                bigint               not null
    , studentInfoSystemID     bigint               not null
    , apiUrl                  varchar(1024)        not null 
    , apiToken                varchar(1024)        not null 
    , schoolNamesToExclude    varchar(max)  not null default('')
	, additionalDataJSON	  varchar(max)  not null default('{}')
    , [enabled]               bit           not null default(1)
	, created                 datetime not null
    , createdBy               bigint   not null
    , lastModified            datetime null
    , lastModifiedBy          bigint   null
    , active                  bit      not null default(1)
) ON [PRIMARY]
END
GO

-------------------------------------------------------

USE SPEDMON
GO

-- SITES_ADDRESS


IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[SITES_ADDRESS]') 
         AND name = 'PHONE_NUMBER'
)
BEGIN
    ALTER TABLE dbo.SITES_ADDRESS
    ADD PHONE_NUMBER varchar(50) 
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[CYBHI_CLAIM_TRANSMISSION_CLAIMS]') 
         AND name = 'siteID'
)
BEGIN
    ALTER TABLE dbo.CYBHI_CLAIM_TRANSMISSION_CLAIMS
    ADD siteID int 
END
GO

-------------------------------------------------------

USE SPEDMON
GO

if not exists (select top 1 id from dbo.CYBHI_CLAIM_HOLD_CODES where holdCode = 120)
begin
  insert into dbo.CYBHI_CLAIM_HOLD_CODES (holdCode,holdReason,clientActionable)
  values (120,'Site has incomplete name or address data',1)
end

go

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[SITES_Site]') 
         AND name = 'cybhiTpaApproved'
)
BEGIN
    ALTER TABLE [dbo].[SITES_Site]
    ADD cybhiTpaApproved bit not null default 0
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[SITES_Site]') 
         AND name = 'cybhiTpaApprovedOn'
)
BEGIN
    ALTER TABLE [dbo].[SITES_Site]
    ADD cybhiTpaApprovedOn date
END
GO


-------------------------------------------------------

USE SPEDMON
GO

if not exists (select top 1 id from dbo.CYBHI_CLAIM_HOLD_CODES where holdCode = 130)
begin
  insert into dbo.CYBHI_CLAIM_HOLD_CODES (holdCode,holdReason,clientActionable)
  values (130,'Site is not approved by TPA',0)
end

go
-------------------------------------------------------

USE SPEDMON
GO

IF EXISTS (
    SELECT 1
    FROM sys.columns 
    WHERE object_id = OBJECT_ID(N'[dbo].[PRACTITIONER_PATIENT_REFERRALS]')
      AND name = 'parentGuardianConsent'
)
BEGIN
    ALTER TABLE dbo.PRACTITIONER_PATIENT_REFERRALS
    ALTER COLUMN parentGuardianConsent tinyint NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PRACTITIONER_PATIENT_REFERRALS]') 
         AND name = 'referralType'
)
BEGIN
    ALTER TABLE dbo.PRACTITIONER_PATIENT_REFERRALS
    ADD referralType tinyint
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[INSURANCE_CARRIERS]') 
         AND name = 'cybhiRegisterPatInsuranceInfoWithTPA'
)
BEGIN
    ALTER TABLE dbo.INSURANCE_CARRIERS
    ADD cybhiRegisterPatInsuranceInfoWithTPA bit not null default(1)
END
GO

-------------------------------------------------------

USE SPEDMON
GO

update dbo.INSURANCE_CARRIERS
set 
    cybhiRegisterPatInsuranceInfoWithTPA = 0
  , lastModified                         = getdate()
  , lastModifiedBy                       = 805
where 
    planSupportedByCYBHI = 1
and active               = 1
and cybhiRegisterPatInsuranceInfoWithTPA = 1
and carrierCode in (
   'LA2'
  ,'PH9'
  ,'GCH'
  ,'SH7'
  ,'CU4'
)
go

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[CYBHI_CLAIM_TRANSMISSION_CLAIMS]') 
         AND name = 'useTpaIdAsInsuranceMemberID'
)
BEGIN
    ALTER TABLE dbo.CYBHI_CLAIM_TRANSMISSION_CLAIMS
    ADD useTpaIdAsInsuranceMemberID bit not null default(1)
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[CYBHI_CLAIM_TRANSMISSION_CLAIMS]') 
         AND name = 'patInsuranceCarrierID'
)
BEGIN
    ALTER TABLE dbo.CYBHI_CLAIM_TRANSMISSION_CLAIMS
    ADD patInsuranceCarrierID bigint 
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[CYBHI_CLAIM_TRANSMISSION_CLAIMS]') 
         AND name = 'patInsuranceMemberID'
)
BEGIN
    ALTER TABLE dbo.CYBHI_CLAIM_TRANSMISSION_CLAIMS
    ADD patInsuranceMemberID varchar(80) 
END
GO

-------------------------------------------------------

USE SPEDMON
GO

if not exists (select top 1 id from dbo.CYBHI_CLAIM_HOLD_CODES where holdCode = 520)
begin
  insert into dbo.CYBHI_CLAIM_HOLD_CODES (holdCode,holdReason,clientActionable)
  values (520,'No insurance carrier on file for patient or carrier is not supported by CYBHI program',0)
end
go

-------------------------------------------------------

USE SPEDMON
GO

if not exists (select top 1 id from dbo.CYBHI_CLAIM_HOLD_CODES where holdCode = 525)
begin
  insert into dbo.CYBHI_CLAIM_HOLD_CODES (holdCode,holdReason,clientActionable)
  values (525,'No insurance member ID on file for patient',0)
end
go

-------------------------------------------------------

------------------------------------------ Dedicated CYBHI fields for client ----------------------------

USE SPEDMON
GO
 
IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[CLIENTS_Client]') 
         AND name = 'cybhiClientName'
)
begin
  ALTER TABLE [dbo].[CLIENTS_Client] ADD cybhiClientName nvarchar(100)
end
go

-------------------------------------------------------

USE SPEDMON
GO
 
IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[CLIENTS_Client]') 
         AND name = 'cybhiNPI'
)
begin
  ALTER TABLE [dbo].[CLIENTS_Client] ADD cybhiNPI nchar(10)
end
go

-------------------------------------------------------

USE SPEDMON
GO
 
IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[CLIENTS_Client]') 
         AND name = 'cybhiTaxID'
)
begin
  ALTER TABLE [dbo].[CLIENTS_Client] ADD cybhiTaxID nchar(10)
end
go

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[CLIENTS_Client]') 
         AND name = 'cybhiAddress1'
)
begin
  ALTER TABLE [dbo].[CLIENTS_Client] ADD cybhiAddress1 nvarchar(256)
end
go

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[CLIENTS_Client]') 
         AND name = 'cybhiAddress2'
)
begin
  ALTER TABLE [dbo].[CLIENTS_Client] ADD cybhiAddress2 nvarchar(256)
end
go

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[CLIENTS_Client]') 
         AND name = 'cybhiCity'
)
begin
  ALTER TABLE [dbo].[CLIENTS_Client] ADD cybhiCity nvarchar(50)
end
go

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[CLIENTS_Client]') 
         AND name = 'cybhiState'
)
begin
  ALTER TABLE [dbo].[CLIENTS_Client] ADD cybhiState nvarchar(10)
end
go

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[CLIENTS_Client]') 
         AND name = 'cybhiZip5'
)
begin
  ALTER TABLE [dbo].[CLIENTS_Client] ADD cybhiZip5 nvarchar(5)
end
go

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[CLIENTS_Client]') 
         AND name = 'cybhiZip4'
)
begin
  ALTER TABLE [dbo].[CLIENTS_Client] ADD cybhiZip4 nvarchar(5)
end
go

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[CLIENTS_Client]') 
         AND name = 'cybhiGenerate837'
)
begin
  ALTER TABLE [dbo].[CLIENTS_Client] ADD cybhiGenerate837 bit not null default(1)
end
go

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[CLIENTS_Client]') 
         AND name = 'cybhiAutoGenerate837'
)
begin
  ALTER TABLE [dbo].[CLIENTS_Client] ADD cybhiAutoGenerate837 bit not null default(0)
end
go

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[CLIENTS_Client]') 
         AND name = 'cybhiNumDaysToHoldEnteredClaims'
)
begin
  ALTER TABLE [dbo].[CLIENTS_Client] ADD cybhiNumDaysToHoldEnteredClaims int not null default(7)
end
go

-------------------------------------------------------

USE SPEDMON
GO

if not exists (select top 1 id from dbo.CYBHI_CLAIM_HOLD_CODES where holdCode = 400)
begin
  insert into dbo.CYBHI_CLAIM_HOLD_CODES (holdCode,holdReason,clientActionable)
  values (400,'The claiming practitioner could not be determined.  Make sure the rendering practitioner has a supervisor (if neccessary) and that a CYBHI clinical supervisor is setup.',1)
end

if not exists (select top 1 id from dbo.CYBHI_CLAIM_HOLD_CODES where holdCode = 600)
begin
  insert into dbo.CYBHI_CLAIM_HOLD_CODES (holdCode,holdReason,clientActionable)
  values (600,'The claim was entered recently and the number of days to hold new claims has not yet elapsed.',1)
end

go
-------------------------------------------------------

USE SPEDMON
GO


IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[CYBHI_CLAIM_TRANSMISSION_CLAIMS]') 
  AND name = 'active'              
)
  alter table dbo.CYBHI_CLAIM_TRANSMISSION_CLAIMS
  add active bit not null default(1);
go

-------------------------------------------------------
 
USE SPEDMON
GO
IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[CLIENTS_Client]') 
         AND name = 'mba_bba_percent'
)
BEGIN
  alter table [dbo].[CLIENTS_Client]
  add mba_bba_percent  money not null default(5)
          -- TODO !!!!
		  -- not sure why we're using type MONEY instead of decimal
end
go
 
------------------------------------------------------------------------------
USE SPEDMON
GO
IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[CLIENTS_Client]') 
         AND name = 'mba_dg_percent'
)
BEGIN
  alter table [dbo].[CLIENTS_Client]
  add mba_dg_percent money not null default(5)
end
go
 
----------------------------------------------------------------------------------
 
USE SPEDMON
GO
IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[CLIENTS_Client]') 
         AND name = 'spEdCare_bba_percent'
)
BEGIN
  alter table [dbo].[CLIENTS_Client]
  add spEdCare_bba_percent  money not null default(1)
end
go
 
--------------------------------------------------------------------------------
 
USE SPEDMON
GO
IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[CLIENTS_Client]') 
         AND name = 'spEdCare_dg_percent'
)
BEGIN
  alter table [dbo].[CLIENTS_Client]
  add spEdCare_dg_percent money not null default(1)
end
go
 
---------------------------------------------------------------------------------------
 
USE SPEDMON
GO
IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[CLIENTS_Client]') 
         AND name = 'smaa_1_percent'
)
BEGIN
  alter table [dbo].[CLIENTS_Client]
  add smaa_1_percent  money not null default(0)
end
go
 
--------------------------------------------------------------------------------------
 
USE SPEDMON
GO
IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[CLIENTS_Client]') 
         AND name = 'smaa_2_percent'
)
BEGIN
  alter table [dbo].[CLIENTS_Client]
  add smaa_2_percent  money not null default(0)
end
go
 
-----------------------------------------------------------------------------------------
 
USE SPEDMON
GO
IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[CLIENTS_Client]') 
         AND name = 'smaa_3_percent'
)
BEGIN
  alter table [dbo].[CLIENTS_Client]
  add smaa_3_percent  money not null default(0)
end
go
 
--------------------------------------------------------------------------------------------
 
 
USE SPEDMON
GO
IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[CLIENTS_Client]') 
         AND name = 'mba_share'
)
BEGIN
  alter table [dbo].[CLIENTS_Client]
  add mba_share  money not null default(0)
end
go
-----------------------------------------------------------------------------------------------
 
USE SPEDMON
GO
IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[CLIENTS_Client]') 
         AND name = 'spEdCare_partners'
)
BEGIN
  alter table [dbo].[CLIENTS_Client]
  add spEdCare_partners  money not null default(0)
end
go
 
------------------------------------------------------------------------------------------------------
 
 
USE SPEDMON
GO
IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[CLIENTS_Client]') 
         AND name = 'spEdCare_partners'
)
BEGIN
  alter table [dbo].[CLIENTS_Client]
  add spEdCare_partners  money not null default(0)
end
go
 
------------------------------------------------------------------------------------------------------
 
USE SPEDMON
GO
IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[Client_Invoices]') 
         AND name = 'Distributed_Date'
)
BEGIN
  alter table [dbo].[Client_Invoices]
  add Distributed_Date  date null 
end
go


USE SPEDMON
GO
IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[Client_Invoices]') 
         AND name = 'Distribution_Notes'
)
BEGIN
  alter table [dbo].[Client_Invoices]
  add  [Distribution_Notes] [varchar](max) NULL
end
go

if not exists (select top 1 id from dbo.CYBHI_CLAIM_HOLD_CODES where holdCode = 300)
begin
  insert into dbo.CYBHI_CLAIM_HOLD_CODES (holdCode,holdReason,clientActionable)
  values 
   (300,	'The ORP practitioner could not be determined.  Make sure the rendering practitioner has a supervisor (if neccessary) and that a CYBHI clinical supervisor is setup.',1)
  ,(305,	'ORP practitioner submit claims is set to no',1)
  ,(310,	'ORP practitioner has no NPI on record',1)
  ,(350,	'ORP practitioner has no TPA registration or approval on record',1)
  ,(360,	'ORP practitioner has no TPA ID on record',1)
  ,(370,	'ORP practitioner has no ACES certification on record',1)
end

-------------------------------------------------------


use SPEDMON
go

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CYBHI_RESUBMIT_LOG_PREVIOUSLY_ADJUDICATED_SERVICE_RECORD_CLAIMS]') AND type in (N'U'))
BEGIN
	CREATE TABLE [CYBHI_RESUBMIT_LOG_PREVIOUSLY_ADJUDICATED_SERVICE_RECORD_CLAIMS] (
            
			  id					 	bigint 		IDENTITY(1,1)
			, clientID 				bigint 			not null
			, svcRecID                bigint        not null
			, claimID                 bigint        not null
            
			, resetForResubmission    bit           not null default(0)
			, resetForResubmissionOn  datetime      null
				
			, resubmitted             bit           not null default(0)
			, transmissionID          bigint        null

			, created 				  datetime 		not null
			, createdBy 			  bigint	    not null
			, lastModified 			  datetime 	    null
			, lastModifiedBy 		  bigint 	    null
			, active 				  bit           not null			default(1)

	) ON [PRIMARY]     	
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[CYBHI_CLAIMS]') 
         AND name = 'prevTxStatusCode'
)
BEGIN
    ALTER TABLE dbo.CYBHI_CLAIMS
    ADD prevTxStatusCode smallint null
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[INSURANCE_CARRIERS]') 
         AND name = 'cybhiRegisterPatInsuranceInfoWithTPAHasEndDate'
)
BEGIN
    ALTER TABLE dbo.INSURANCE_CARRIERS
    ADD cybhiRegisterPatInsuranceInfoWithTPAHasEndDate bit not null default(0)
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[INSURANCE_CARRIERS]') 
         AND name = 'cybhiRegisterPatInsuranceInfoWithTPAEndDate'
)
BEGIN
    ALTER TABLE dbo.INSURANCE_CARRIERS
    ADD cybhiRegisterPatInsuranceInfoWithTPAEndDate datetime null
END
GO

-------------------------------------------------------

USE SPEDMON
GO

-- 1357 (cal optima) , 12/14/2025
-- 1379 (Sutter Health), 12/31/2025


update ic
set 
    ic.lastModified                                   = getdate()
  , ic.lastModifiedBy                                 = 805
  , ic.cybhiRegisterPatInsuranceInfoWithTPA = 1
  , ic.cybhiRegisterPatInsuranceInfoWithTPAHasEndDate = 1
  , ic.cybhiRegisterPatInsuranceInfoWithTPAEndDate    = '12/14/2025'
from dbo.INSURANCE_CARRIERS as ic
where 
  (id = 1357)

/*-----------------------------------------------*/

update ic
set 
     ic.lastModified                                   = getdate()
  ,  ic.lastModifiedBy                                 = 805
  ,  ic.cybhiRegisterPatInsuranceInfoWithTPA = 1
  ,  ic.cybhiRegisterPatInsuranceInfoWithTPAHasEndDate = 1
  ,  ic.cybhiRegisterPatInsuranceInfoWithTPAEndDate    = '12/31/2025'
from dbo.INSURANCE_CARRIERS as ic
where 
  (id = 1379)

GO
-------------------------------------------------------

USE SPEDMON
GO


if not exists (select top 1 id from dbo.CYBHI_CLAIM_HOLD_CODES where holdCode = 580)
begin
  insert into dbo.CYBHI_CLAIM_HOLD_CODES (holdCode,holdReason,clientActionable)
  values 
   (580, 'Patient has aged out of program on or before date of service.',1)
end

GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.columns 
    WHERE object_id = OBJECT_ID(N'[dbo].[PRACTITIONER_PATIENT_REFERRALS]')
      AND name = 'referringByUserID'
)
BEGIN
    ALTER TABLE dbo.PRACTITIONER_PATIENT_REFERRALS
    ADD referringByUserID BIGINT NULL;
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF EXISTS (
    SELECT 1
    FROM sys.columns 
    WHERE object_id = OBJECT_ID(N'[dbo].[PRACTITIONER_PATIENT_REFERRALS]')
      AND name = 'patID'
)
BEGIN
	ALTER TABLE dbo.PRACTITIONER_PATIENT_REFERRALS
	ALTER COLUMN patID BIGINT NULL;
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF EXISTS (
    SELECT 1
    FROM sys.columns 
    WHERE object_id = OBJECT_ID(N'[dbo].[PRACTITIONER_PATIENT_REFERRALS]')
      AND name = 'pracID'
)
BEGIN
	ALTER TABLE dbo.PRACTITIONER_PATIENT_REFERRALS
	ALTER COLUMN pracID BIGINT NULL;
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF EXISTS (
    SELECT 1
    FROM sys.columns 
    WHERE object_id = OBJECT_ID(N'[dbo].[PRACTITIONER_PATIENT_REFERRALS]')
      AND name = 'referredToPracName'
)
BEGIN
	ALTER TABLE dbo.PRACTITIONER_PATIENT_REFERRALS
	ALTER COLUMN referredToPracName varchar(256) NULL;
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF EXISTS (
    SELECT 1
    FROM sys.columns 
    WHERE object_id = OBJECT_ID(N'[dbo].[PRACTITIONER_PATIENT_REFERRALS]')
      AND name = 'referredToOrgName'
)
BEGIN
	ALTER TABLE dbo.PRACTITIONER_PATIENT_REFERRALS
	ALTER COLUMN referredToOrgName varchar(256) NULL;
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[CYBHI_CLAIM_TRANSMISSION_CLAIMS]') 
         AND name = 'patInsuranceCarrierPcCode'
)
BEGIN
  alter table [dbo].[CYBHI_CLAIM_TRANSMISSION_CLAIMS]
  add patInsuranceCarrierPcCode varchar(50)
end
go

-------------------------------------------------------
 
USE SPEDMON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PRACTITIONER_PATIENT_REFERRALS_PUBLIC_MENTAL_HEALTH_REQUEST_REFERRAL_FORM_RESPONSES]') AND type in (N'U'))
BEGIN
  CREATE TABLE dbo.[PRACTITIONER_PATIENT_REFERRALS_PUBLIC_MENTAL_HEALTH_REQUEST_REFERRAL_FORM_RESPONSES] (
		id                               	bigint       	not null identity(1,1) primary key
        , reqRefFormID						bigint       	not null /* Form record */
        , patientFirstName                 	nvarchar(50) 	not null
        , patientLastName                  	nvarchar(50) 	not null
        , patientDOB                       	datetime     	not null
        , studentID                        	nvarchar(50) 
		, teacherName                       nvarchar(50) 
		, referralPriority					tinyint         NOT NULL
		, referralDetailNote               	varchar(8000) 
		
        , responderIsParentGuardian         bit 			not null default(1)
        , responderFirstName                varchar(255)
        , responderLastName                 varchar(255)
        , responderEmail                    varchar(255)
        , responderPhone                    varchar(255)
        , responderUserIP                  	varchar(500)
        , responderUserAgent               	varchar(8000) 
        
        , clientID                         	bigint       	not null
        , patID                            	bigint
		, referralID                    	bigint    		null
	  
  	    , created                          	datetime  		not null
        , createdBy                        	bigint    		not null
		, lastModified                     	datetime  		null
        , lastModifiedBy                   	bigint    		null
		, active                           	bit 			not null default(1)
		, patPerID 							bigint 
        
  ) ON [PRIMARY]        
END
GO

-------------------------------------------------------

USE [SPEDMON]
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PRACTITIONER_PATIENT_REFERRALS_PUBLIC_MENTAL_HEALTH_REQUEST_REFERRAL_FORMS]') AND type in (N'U'))
BEGIN
	CREATE TABLE [PRACTITIONER_PATIENT_REFERRALS_PUBLIC_MENTAL_HEALTH_REQUEST_REFERRAL_FORMS] (
            id 					bigint 			IDENTITY(1,1),
			clientID 			bigint 			NOT NULL,
			publicToken 		varchar(512) 	NOT NULL,
			created 			datetime 		NOT NULL,
			createdBy 			bigint 			NOT NULL,
			lastModified 		datetime 		NULL,
			lastModifiedBy 		bigint 			NULL,
			active 				bit 			default(1)

	) ON [PRIMARY]     	
END
GO

-------------------------------------------------------

USE [SPEDMON]
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PRACTITIONER_PATIENT_REFERRAL_OPTIONS]') AND type in (N'U'))
BEGIN
	CREATE TABLE [PRACTITIONER_PATIENT_REFERRAL_OPTIONS] (
            id					 						bigint 			IDENTITY(1,1),
			clientID 									bigint 			NOT NULL,
			userIDForAllRoutineNotifications1 			bigint 			NULL,
			userIDForAllRoutineNotifications2  			bigint 			NULL,
			userIDForAllRoutineNotifications3  			bigint 			NULL,
			userIDForAllUrgentNotifications1   			bigint 			NULL,
			userIDForAllUrgentNotifications2   			bigint 			NULL,
			userIDForAllUrgentNotifications3   			bigint 			NULL,
			userIDForAllCrisisNotifications1   			bigint 			NULL,
			userIDForAllCrisisNotifications2   			bigint 			NULL,
			userIDForAllCrisisNotifications3   			bigint 			NULL,
			created 									datetime 		NULL,
			createdBy 									bigint			NULL,
			lastModified 								datetime 		NULL,
			lastModifiedBy 								bigint 			NULL,
			active 										bit 			default(1)

	) ON [PRIMARY]     	
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PRACTITIONER_PATIENT_REFERRALS_PUBLIC_MENTAL_HEALTH_REQUEST_REFERRAL_FORM_RESPONSES]') 
         AND name = 'responderRelationship'
)
BEGIN
    ALTER TABLE dbo.PRACTITIONER_PATIENT_REFERRALS_PUBLIC_MENTAL_HEALTH_REQUEST_REFERRAL_FORM_RESPONSES
    ADD responderRelationship VARCHAR(20) NOT NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PRACTITIONER_PATIENT_REFERRAL_OPTIONS]') 
         AND name = 'englishYesMessageTemplate'
)
BEGIN
    ALTER TABLE dbo.PRACTITIONER_PATIENT_REFERRAL_OPTIONS
    ADD englishYesMessageTemplate VARCHAR(max) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PRACTITIONER_PATIENT_REFERRAL_OPTIONS]') 
         AND name = 'spanishYesMessageTemplate'
)
BEGIN
    ALTER TABLE dbo.PRACTITIONER_PATIENT_REFERRAL_OPTIONS
    ADD spanishYesMessageTemplate VARCHAR(max) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PRACTITIONER_PATIENT_REFERRAL_OPTIONS]') 
         AND name = 'englishNoMessageTemplate'
)
BEGIN
    ALTER TABLE dbo.PRACTITIONER_PATIENT_REFERRAL_OPTIONS
    ADD englishNoMessageTemplate VARCHAR(max) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PRACTITIONER_PATIENT_REFERRAL_OPTIONS]') 
         AND name = 'spanishNoMessageTemplate'
)
BEGIN
    ALTER TABLE dbo.PRACTITIONER_PATIENT_REFERRAL_OPTIONS
    ADD spanishNoMessageTemplate VARCHAR(max) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CONTACT_METHODS]') AND type in (N'U'))
BEGIN
    CREATE TABLE dbo.CONTACT_METHODS
    (
         id					BIGINT			IDENTITY(1,1) NOT NULL primary key
        , code				INT							  NOT NULL 
        , name				VARCHAR(256)			      NOT NULL
        , created           DATETIME					  NOT NULL
		, createdBy         BIGINT						  NOT NULL
		, lastModified      DATETIME					  NULL
		, lastModifiedBy    BIGINT						  NULL
		, active            BIT							  NOT NULL DEFAULT(1)
    );
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'preferredContactMethodCode'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD preferredContactMethodCode INT NOT NULL DEFAULT(10)
END
GO

USE SPEDMON
GO

/*-------------------------------------------------------
 * Add relationshipTypeID column to practitioner supervision table
 * Default: 10 (Program Compliance)
 *-----------------------------------------------------*/

IF COL_LENGTH('dbo.PRACTITIONER_PRACTITIONER_DIRECT_SUPERVISED_SUPERVISOR','relationshipTypeID') IS NULL
BEGIN
    ALTER TABLE dbo.PRACTITIONER_PRACTITIONER_DIRECT_SUPERVISED_SUPERVISOR
    ADD relationshipTypeID tinyint NOT NULL
        CONSTRAINT DF_PPDS_RELTYPE DEFAULT(10);
END
GO
-------------------------------------------------------

USE SPEDMON
GO

/*-------------------------------------------------------
 * Add requireSvcRecApprovalForNonProgCompRels column to practitioner supervision table
 * Default: 1 (Yes, review required)
 *-----------------------------------------------------*/

IF COL_LENGTH('dbo.PRACTITIONER_PRACTITIONER_DIRECT_SUPERVISED_SUPERVISOR','requireSvcRecApprovalForNonProgCompRels') IS NULL
BEGIN
    ALTER TABLE dbo.PRACTITIONER_PRACTITIONER_DIRECT_SUPERVISED_SUPERVISOR
    ADD requireSvcRecApprovalForNonProgCompRels bit NOT NULL
        CONSTRAINT DF_PPDS_REQAPP DEFAULT(1);
END
GO

-------------------------------------------------------

USE SPEDMON
GO


/*-------------------------------------------------------
 * Create CYBHI_SERVICE_RECORDS_ORP_REVIEWS table
 *-----------------------------------------------------*/

/*
USE SPEDMON
GO

drop table dbo.CYBHI_SERVICE_RECORDS_ORP_REVIEWS
go
*/

IF OBJECT_ID('dbo.CYBHI_SERVICE_RECORDS_ORP_REVIEWS', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.CYBHI_SERVICE_RECORDS_ORP_REVIEWS (
        id                 bigint       IDENTITY(1,1) NOT NULL
      , clientID           bigint       not null
	  , renderingPracID    bigint       not null
      , assignedToPracID   bigint       NOT NULL
      , assignedOn         datetime     NOT NULL	  
	  , svcRecID           bigint       NOT NULL
      , reviewed           bit          NOT NULL DEFAULT(0)
      , reviewedOn         datetime     NULL
      , reviewedByPracID   bigint       NULL
      , reviewedByName     varchar(500) NULL
      , reviewedByTitle    varchar(500) NULL
      , notes              varchar(max) NOT NULL DEFAULT('')
      , approved           bit          NULL 
      , created            datetime     NOT NULL
      , createdBy          bigint       NOT NULL
      , lastModified       datetime     NULL
      , lastModifiedBy     bigint       NULL
      , active             bit          NOT NULL DEFAULT(1)
    )
END
GO

-------------------------------------------------------

/*
USE SPEDMON
GO
drop table dbo.SERVICE_RECORDS_INTERNAL_REVIEWS
go
*/

USE SPEDMON
GO

/*-------------------------------------------------------
 * Create SERVICE_RECORDS_INTERNAL_REVIEWS table
 *-----------------------------------------------------*/

IF OBJECT_ID('dbo.SERVICE_RECORDS_INTERNAL_REVIEWS', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.SERVICE_RECORDS_INTERNAL_REVIEWS (
        id                 bigint       IDENTITY(1,1) NOT NULL
      , clientID           bigint       not null
	  , renderingPracID    bigint       not null
      , assignedToPracID   bigint       NOT NULL
      , assignedOn         datetime     NOT NULL
	  , svcRecID           bigint       NOT NULL
      , reviewed           bit          NOT NULL DEFAULT(0)
      , reviewedOn         datetime     NULL
      , reviewedByPracID   bigint       NULL
      , reviewedByName     varchar(500) NULL
      , reviewedByTitle    varchar(500) NULL
      , notes              varchar(max) NOT NULL DEFAULT('')
      , approved           bit          null
      , created            datetime     NOT NULL
      , createdBy          bigint       NOT NULL
      , lastModified       datetime     NULL
      , lastModifiedBy     bigint       NULL
      , active             bit          NOT NULL DEFAULT(1)
    )
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[CLIENTS_Client]') 
         AND name = 'leaBopConsortiumLeadClientID'
)
BEGIN
    ALTER TABLE dbo.CLIENTS_Client
    ADD leaBopConsortiumLeadClientID bigint null
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[CLIENTS_Client]') 
         AND name = 'leaBopConsortiumBilling'
)
BEGIN
    ALTER TABLE dbo.CLIENTS_Client
    ADD leaBopConsortiumBilling  bit default (0) not null
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[CLIENTS_Client]') 
         AND name = 'cybhiConsortiumLeadClientID'
)
BEGIN
    ALTER TABLE dbo.CLIENTS_Client
    ADD cybhiConsortiumLeadClientID bigint null
END
GO


-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[CLIENTS_Client]') 
         AND name = 'cybhiConsortiumBilling'
)
BEGIN
    ALTER TABLE dbo.CLIENTS_Client
    ADD cybhiConsortiumBilling  bit default (0) not null
END
GO

-------------------------------------------------------

/* TODO: Remove this block (the 3 drops) after these changes go live. */

/*USE SPEDMON
GO

drop TABLE dbo.sped_assessment_tools 
drop table dbo.sped_baseline_units 
drop table dbo.sped_present_levels_sources 

go
*/
-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sped_assessment_tools]') AND type in (N'U'))
BEGIN
	CREATE TABLE dbo.sped_assessment_tools (
		  id              INT            IDENTITY(1,1) PRIMARY KEY
		, [name]          VARCHAR(256)   NOT NULL           /* Replaces tool_name   */
		, [class]         VARCHAR(50)    NULL               /* Replaces domain_code */
		, displayOrder    INT            NOT NULL DEFAULT 0 /* Replaces sort_order  */
		, created         DATETIME       NULL
		, createdBy       BIGINT         NULL
		, lastModified    DATETIME       NULL
		, lastModifiedBy  BIGINT         NULL
		, active          BIT            NOT NULL DEFAULT 1 /* Replaces is_active   */
	)

	INSERT INTO dbo.sped_assessment_tools ([name], [class], displayOrder) VALUES
		  ('DIBELS'                                        , 'READING'                     , 1)
		, ('Fountas & Pinnell BAS'                         , 'READING'                     , 2)
		, ('STAR Reading'                                  , 'READING'                     , 3)
		, ('DRA (Developmental Reading Assessment)'        , 'READING'                     , 4)
		, ('AIMSweb Reading'                               , 'READING'                     , 5)
		, ('Woodcock-Johnson (Reading)'                    , 'READING'                     , 6)
		, ('STAR Writing'                                  , 'WRITING'                     , 7)
		, ('AIMSweb Writing'                               , 'WRITING'                     , 8)
		, ('Woodcock-Johnson (Writing)'                    , 'WRITING'                     , 9)
		, ('Written Expression CBM'                        , 'WRITING'                     , 10)
		, ('STAR Math'                                     , 'MATH'                        , 11)
		, ('AIMSweb Math'                                  , 'MATH'                        , 12)
		, ('Woodcock-Johnson (Math)'                       , 'MATH'                        , 13)
		, ('KeyMath Diagnostic Assessment'                 , 'MATH'                        , 14)
		, ('CELF (Clinical Eval of Language Fundamentals)' , 'COMMUNICATION_DEV'           , 15)
		, ('PPVT (Peabody Picture Vocabulary Test)'        , 'COMMUNICATION_DEV'           , 16)
		, ('Goldman-Fristoe Test of Articulation'          , 'COMMUNICATION_DEV'           , 17)
		, ('Expressive Vocabulary Test (EVT)'              , 'COMMUNICATION_DEV'           , 18)
		, ('Bruininks-Oseretsky Test of Motor Proficiency' , 'GROSS_FINE_MOTOR'            , 19)
		, ('Beery VMI'                                     , 'GROSS_FINE_MOTOR'            , 20)
		, ('Peabody Developmental Motor Scales'            , 'GROSS_FINE_MOTOR'            , 21)
		, ('Health Assessment / Nursing Evaluation'        , 'HEALTH'                      , 22)
		, ('Vision Screening'                              , 'HEALTH'                      , 23)
		, ('Hearing Screening'                             , 'HEALTH'                      , 24)
		, ('BRIGANCE Transition Skills Inventory'          , 'VOCATIONAL'                  , 25)
		, ('Career Interest Inventory'                     , 'VOCATIONAL'                  , 26)
		, ('Vineland Adaptive Behavior Scales'             , 'ADAPTIVE_DAILY_LIVING'       , 27)
		, ('ABAS (Adaptive Behavior Assessment System)'    , 'ADAPTIVE_DAILY_LIVING'       , 28)
		, ('BASC (Behavior Assessment System for Children)', 'SOCIAL_EMOTIONAL_BEHAVIORAL' , 29)
		, ('Conners Rating Scale'                          , 'SOCIAL_EMOTIONAL_BEHAVIORAL' , 30)
		, ('Social Skills Improvement System (SSIS)'       , 'SOCIAL_EMOTIONAL_BEHAVIORAL' , 31)
		, ('Functional Behavior Assessment (FBA)'          , 'SOCIAL_EMOTIONAL_BEHAVIORAL' , 32)
		, ('Wechsler Intelligence Scale (WISC)'            , NULL                          , 33)
		, ('CAASPP / Smarter Balanced'                     , NULL                          , 34)
		, ('District Benchmark Assessment'                 , NULL                          , 35)
		, ('Teacher-Created Assessment'                    , NULL                          , 36)
		, ('Informal Observation'                          , NULL                          , 37)
		, ('Portfolio Review'                              , NULL                          , 38)
END

GO

-------------------------------------------------------

USE SPEDMON
GO


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sped_baseline_units]') AND type in (N'U'))
BEGIN
	CREATE TABLE dbo.sped_baseline_units (
		  id              INT            IDENTITY(1,1) PRIMARY KEY
		, [name]          VARCHAR(256)   NOT NULL           /* Replaces unit_name   */
		, [class]         VARCHAR(50)    NULL               /* Replaces domain_code */
		, displayOrder    INT            NOT NULL DEFAULT 0 /* Replaces sort_order  */
		, created         DATETIME       NULL
		, createdBy       BIGINT         NULL
		, lastModified    DATETIME       NULL
		, lastModifiedBy  BIGINT         NULL
		, active          BIT            NOT NULL DEFAULT 1 /* Replaces is_active   */
	)

	INSERT INTO dbo.sped_baseline_units ([name], [class], displayOrder) VALUES
		  ('Percent Correct'                , NULL      , 1)
		, ('Words Per Minute'               , 'READING' , 2)
		, ('Words Read Correctly'           , 'READING' , 3)
		, ('Lexile Level'                   , 'READING' , 4)
		, ('Grade Level Equivalent'         , NULL      , 5)
		, ('Standard Score'                 , NULL      , 6)
		, ('Percentile Rank'                , NULL      , 7)
		, ('Scaled Score'                   , NULL      , 8)
		, ('Age Equivalent'                 , NULL      , 9)
		, ('Stanine'                        , NULL      , 10)
		, ('Raw Score'                      , NULL      , 11)
		, ('T-Score'                        , NULL      , 12)
		, ('Rubric Score'                   , NULL      , 13)
		, ('Correct Digits Per Minute'      , 'MATH'    , 14)
		, ('Problems Correct Per Minute'    , 'MATH'    , 15)
		, ('Words Written Per Minute'       , 'WRITING' , 16)
		, ('Correct Writing Sequences'      , 'WRITING' , 17)
		, ('Rating Scale Score'             , NULL      , 18)
		, ('Frequency Count'                , NULL      , 19)
		, ('Duration (Minutes)'             , NULL      , 20)
		, ('Trials to Criterion'            , NULL      , 21)
		, ('Level of Independence'          , NULL      , 22)
		, ('Level of Prompting'             , NULL      , 23)
END

GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sped_present_levels_sources]') AND type in (N'U'))
BEGIN
	CREATE TABLE dbo.sped_present_levels_sources (
		  id              INT            IDENTITY(1,1) PRIMARY KEY
		, [name]          VARCHAR(256)   NOT NULL           /* Replaces source_name */
		, [class]         VARCHAR(50)    NULL               /* Replaces domain_code */
		, displayOrder    INT            NOT NULL DEFAULT 0 /* Replaces sort_order  */
		, created         DATETIME       NULL
		, createdBy       BIGINT         NULL
		, lastModified    DATETIME       NULL
		, lastModifiedBy  BIGINT         NULL
		, active          BIT            NOT NULL DEFAULT 1 /* Replaces is_active   */
	)

	INSERT INTO dbo.sped_present_levels_sources ([name], [class], displayOrder) VALUES
		  ('Parent/Guardian Input'          , NULL , 1)
		, ('Teacher Observation'            , NULL , 2)
		, ('Classroom Assessment'           , NULL , 3)
		, ('Standardized Testing'           , NULL , 4)
		, ('Progress Monitoring Data'       , NULL , 5)
		, ('Curriculum-Based Measurement'   , NULL , 6)
		, ('Clinical Assessment'            , NULL , 7)
		, ('Behavioral Observation'         , NULL , 8)
		, ('Student Interview'              , NULL , 9)
		, ('Work Samples'                   , NULL , 10)
		, ('Report Cards/Grades'            , NULL , 11)
		, ('Prior IEP Review'               , NULL , 12)
		, ('Medical Records'                , NULL , 13)
		, ('Outside Agency Report'          , NULL , 14)
		, ('Psychoeducational Evaluation'   , NULL , 15)
END

GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdAmendmentReasonsOtherOption'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdAmendmentReasonsOtherOption VARCHAR(MAX) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdMeetingPurposeOtherOption'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdMeetingPurposeOtherOption VARCHAR(MAX) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdFacilitatorUserID'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdFacilitatorUserID BIGINT NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdFacilitatorUserName'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdFacilitatorUserName VARCHAR(256) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdMeetingDate'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdMeetingDate DATE NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdMeetingDurationInMins'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdMeetingDurationInMins INT NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdMeetingTime'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdMeetingTime VARCHAR(50) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdMeetingTitle'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdMeetingTitle VARCHAR(256) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdDevAcaFunSkillsSocialEmotionalBehavioral'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdDevAcaFunSkillsSocialEmotionalBehavioral VARCHAR(MAX) NULL
END
GO
-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdProceduralSafeguardsSentDate'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdProceduralSafeguardsSentDate DATE NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdSpecialTransportationComments'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdSpecialTransportationComments VARCHAR(MAX) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdVehicleAdaptationType'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdVehicleAdaptationType INT NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'speciallyAdaptedVehicleForTransportation'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD speciallyAdaptedVehicleForTransportation BIT NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdCorrectionDetails'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdCorrectionDetails VARCHAR(MAX) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdPreferredLanguageCodeID'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdPreferredLanguageCodeID BIGINT NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdPresentLevelsDataJSON'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdPresentLevelsDataJSON VARCHAR(MAX) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdPresentLevelsPreparedBy'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdPresentLevelsPreparedBy BIGINT NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdPresentLevelsPreparedByName'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdPresentLevelsPreparedByName VARCHAR(200) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdStudentStrengthsSource'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdStudentStrengthsSource VARCHAR(100) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdStudentStrengthsSourceJSON'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdStudentStrengthsSourceJSON VARCHAR(MAX) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdStudentStrengthsImpact'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdStudentStrengthsImpact VARCHAR(MAX) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdParentConcernsSource'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdParentConcernsSource VARCHAR(100) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdParentConcernsSourceJSON'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdParentConcernsSourceJSON VARCHAR(MAX) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdReadingReviewedNA'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdReadingReviewedNA BIT NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdReadingSource'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdReadingSource VARCHAR(100) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdReadingSourceJSON'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdReadingSourceJSON VARCHAR(MAX) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdReadingBaselineValue'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdReadingBaselineValue VARCHAR(100) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdReadingBaselineUnit'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdReadingBaselineUnit VARCHAR(100) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdReadingToolsUsed'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdReadingToolsUsed VARCHAR(500) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdReadingToolsUsedJSON'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdReadingToolsUsedJSON VARCHAR(MAX) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdReadingBaselineDate'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdReadingBaselineDate DATE NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdReadingImpactSummary'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdReadingImpactSummary VARCHAR(MAX) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdWritingReviewedNA'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdWritingReviewedNA BIT NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdWritingSource'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdWritingSource VARCHAR(100) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdWritingSourceJSON'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdWritingSourceJSON VARCHAR(MAX) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdWritingBaselineValue'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdWritingBaselineValue VARCHAR(100) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdWritingBaselineUnit'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdWritingBaselineUnit VARCHAR(100) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdWritingToolsUsed'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdWritingToolsUsed VARCHAR(500) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdWritingToolsUsedJSON'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdWritingToolsUsedJSON VARCHAR(MAX) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdWritingBaselineDate'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdWritingBaselineDate DATE NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdWritingImpactSummary'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdWritingImpactSummary VARCHAR(MAX) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdMathReviewedNA'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdMathReviewedNA BIT NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdMathSource'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdMathSource VARCHAR(100) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdMathSourceJSON'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdMathSourceJSON VARCHAR(MAX) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdMathBaselineValue'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdMathBaselineValue VARCHAR(100) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdMathBaselineUnit'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdMathBaselineUnit VARCHAR(100) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdMathToolsUsed'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdMathToolsUsed VARCHAR(500) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdMathToolsUsedJSON'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdMathToolsUsedJSON VARCHAR(MAX) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdMathBaselineDate'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdMathBaselineDate DATE NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdMathImpactSummary'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdMathImpactSummary VARCHAR(MAX) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdCommunicationDevReviewedNA'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdCommunicationDevReviewedNA BIT NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdCommunicationDevSource'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdCommunicationDevSource VARCHAR(100) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdCommunicationDevSourceJSON'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdCommunicationDevSourceJSON VARCHAR(MAX) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdCommunicationDevBaselineValue'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdCommunicationDevBaselineValue VARCHAR(100) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdCommunicationDevBaselineUnit'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdCommunicationDevBaselineUnit VARCHAR(100) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdCommunicationDevToolsUsed'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdCommunicationDevToolsUsed VARCHAR(500) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdCommunicationDevToolsUsedJSON'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdCommunicationDevToolsUsedJSON VARCHAR(MAX) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdCommunicationDevBaselineDate'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdCommunicationDevBaselineDate DATE NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdCommunicationDevImpactSummary'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdCommunicationDevImpactSummary VARCHAR(MAX) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdGrossFineMotorReviewedNA'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdGrossFineMotorReviewedNA BIT NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdGrossFineMotorSource'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdGrossFineMotorSource VARCHAR(100) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdGrossFineMotorSourceJSON'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdGrossFineMotorSourceJSON VARCHAR(MAX) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdGrossFineMotorBaselineValue'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdGrossFineMotorBaselineValue VARCHAR(100) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdGrossFineMotorBaselineUnit'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdGrossFineMotorBaselineUnit VARCHAR(100) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdGrossFineMotorToolsUsed'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdGrossFineMotorToolsUsed VARCHAR(500) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdGrossFineMotorToolsUsedJSON'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdGrossFineMotorToolsUsedJSON VARCHAR(MAX) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdGrossFineMotorBaselineDate'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdGrossFineMotorBaselineDate DATE NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdGrossFineMotorImpactSummary'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdGrossFineMotorImpactSummary VARCHAR(MAX) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdHealthReviewedNA'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdHealthReviewedNA BIT NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdHealthSource'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdHealthSource VARCHAR(100) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdHealthSourceJSON'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdHealthSourceJSON VARCHAR(MAX) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdHealthBaselineValue'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdHealthBaselineValue VARCHAR(100) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdHealthBaselineUnit'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdHealthBaselineUnit VARCHAR(100) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdHealthToolsUsed'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdHealthToolsUsed VARCHAR(500) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdHealthToolsUsedJSON'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdHealthToolsUsedJSON VARCHAR(MAX) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdHealthBaselineDate'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdHealthBaselineDate DATE NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdHealthImpactSummary'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdHealthImpactSummary VARCHAR(MAX) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdVocationalReviewedNA'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdVocationalReviewedNA BIT NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdVocationalSource'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdVocationalSource VARCHAR(100) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdVocationalSourceJSON'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdVocationalSourceJSON VARCHAR(MAX) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdVocationalBaselineValue'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdVocationalBaselineValue VARCHAR(100) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdVocationalBaselineUnit'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdVocationalBaselineUnit VARCHAR(100) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdVocationalToolsUsed'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdVocationalToolsUsed VARCHAR(500) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdVocationalToolsUsedJSON'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdVocationalToolsUsedJSON VARCHAR(MAX) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdVocationalBaselineDate'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdVocationalBaselineDate DATE NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdVocationalImpactSummary'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdVocationalImpactSummary VARCHAR(MAX) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdAdaptiveDailyLivingReviewedNA'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdAdaptiveDailyLivingReviewedNA BIT NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdAdaptiveDailyLivingSource'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdAdaptiveDailyLivingSource VARCHAR(100) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdAdaptiveDailyLivingSourceJSON'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdAdaptiveDailyLivingSourceJSON VARCHAR(MAX) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdAdaptiveDailyLivingBaselineValue'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdAdaptiveDailyLivingBaselineValue VARCHAR(100) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdAdaptiveDailyLivingBaselineUnit'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdAdaptiveDailyLivingBaselineUnit VARCHAR(100) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdAdaptiveDailyLivingToolsUsed'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdAdaptiveDailyLivingToolsUsed VARCHAR(500) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdAdaptiveDailyLivingToolsUsedJSON'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdAdaptiveDailyLivingToolsUsedJSON VARCHAR(MAX) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdAdaptiveDailyLivingBaselineDate'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdAdaptiveDailyLivingBaselineDate DATE NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdAdaptiveDailyLivingImpactSummary'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdAdaptiveDailyLivingImpactSummary VARCHAR(MAX) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdSocialEmotionalBehavioralReviewedNA'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdSocialEmotionalBehavioralReviewedNA BIT NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdSocialEmotionalBehavioralSource'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdSocialEmotionalBehavioralSource VARCHAR(100) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdSocialEmotionalBehavioralSourceJSON'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdSocialEmotionalBehavioralSourceJSON VARCHAR(MAX) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdSocialEmotionalBehavioralBaselineValue'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdSocialEmotionalBehavioralBaselineValue VARCHAR(100) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdSocialEmotionalBehavioralBaselineUnit'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdSocialEmotionalBehavioralBaselineUnit VARCHAR(100) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdSocialEmotionalBehavioralToolsUsed'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdSocialEmotionalBehavioralToolsUsed VARCHAR(500) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdSocialEmotionalBehavioralToolsUsedJSON'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdSocialEmotionalBehavioralToolsUsedJSON VARCHAR(MAX) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdSocialEmotionalBehavioralBaselineDate'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdSocialEmotionalBehavioralBaselineDate DATE NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdSocialEmotionalBehavioralImpactSummary'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdSocialEmotionalBehavioralImpactSummary VARCHAR(MAX) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdStudentStrengthsSourceNames'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdStudentStrengthsSourceNames VARCHAR(MAX) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdParentConcernsSourceNames'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdParentConcernsSourceNames VARCHAR(MAX) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdReadingSourceNames'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdReadingSourceNames VARCHAR(MAX) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdWritingSourceNames'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdWritingSourceNames VARCHAR(MAX) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdMathSourceNames'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdMathSourceNames VARCHAR(MAX) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdCommunicationDevSourceNames'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdCommunicationDevSourceNames VARCHAR(MAX) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdGrossFineMotorSourceNames'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdGrossFineMotorSourceNames VARCHAR(MAX) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdHealthSourceNames'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdHealthSourceNames VARCHAR(MAX) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdVocationalSourceNames'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdVocationalSourceNames VARCHAR(MAX) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdAdaptiveDailyLivingSourceNames'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdAdaptiveDailyLivingSourceNames VARCHAR(MAX) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdSocialEmotionalBehavioralSourceNames'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdSocialEmotionalBehavioralSourceNames VARCHAR(MAX) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdReadingBaselineUnitName'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdReadingBaselineUnitName VARCHAR(256) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdWritingBaselineUnitName'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdWritingBaselineUnitName VARCHAR(256) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdMathBaselineUnitName'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdMathBaselineUnitName VARCHAR(256) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdCommunicationDevBaselineUnitName'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdCommunicationDevBaselineUnitName VARCHAR(256) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdGrossFineMotorBaselineUnitName'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdGrossFineMotorBaselineUnitName VARCHAR(256) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdHealthBaselineUnitName'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdHealthBaselineUnitName VARCHAR(256) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdVocationalBaselineUnitName'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdVocationalBaselineUnitName VARCHAR(256) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdAdaptiveDailyLivingBaselineUnitName'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdAdaptiveDailyLivingBaselineUnitName VARCHAR(256) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdSocialEmotionalBehavioralBaselineUnitName'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdSocialEmotionalBehavioralBaselineUnitName VARCHAR(256) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdReadingBaselineUnitNames'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdReadingBaselineUnitNames VARCHAR(256) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdWritingBaselineUnitNames'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdWritingBaselineUnitNames VARCHAR(256) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdMathBaselineUnitNames'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdMathBaselineUnitNames VARCHAR(256) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdCommunicationDevBaselineUnitNames'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdCommunicationDevBaselineUnitNames VARCHAR(256) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdGrossFineMotorBaselineUnitNames'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdGrossFineMotorBaselineUnitNames VARCHAR(256) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdHealthBaselineUnitNames'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdHealthBaselineUnitNames VARCHAR(256) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdVocationalBaselineUnitNames'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdVocationalBaselineUnitNames VARCHAR(256) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdAdaptiveDailyLivingBaselineUnitNames'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdAdaptiveDailyLivingBaselineUnitNames VARCHAR(256) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdSocialEmotionalBehavioralBaselineUnitNames'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdSocialEmotionalBehavioralBaselineUnitNames VARCHAR(256) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdReadingToolsUsedNames'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdReadingToolsUsedNames VARCHAR(MAX) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdWritingToolsUsedNames'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdWritingToolsUsedNames VARCHAR(MAX) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdMathToolsUsedNames'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdMathToolsUsedNames VARCHAR(MAX) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdCommunicationDevToolsUsedNames'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdCommunicationDevToolsUsedNames VARCHAR(MAX) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdGrossFineMotorToolsUsedNames'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdGrossFineMotorToolsUsedNames VARCHAR(MAX) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdHealthToolsUsedNames'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdHealthToolsUsedNames VARCHAR(MAX) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdVocationalToolsUsedNames'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdVocationalToolsUsedNames VARCHAR(MAX) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdAdaptiveDailyLivingToolsUsedNames'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdAdaptiveDailyLivingToolsUsedNames VARCHAR(MAX) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdSocialEmotionalBehavioralToolsUsedNames'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdSocialEmotionalBehavioralToolsUsedNames VARCHAR(MAX) NULL
END
GO
-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdCaseManagerUserID'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdCaseManagerUserID bigint NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'spEdCaseManagerUserName'
)
BEGIN
    ALTER TABLE dbo.PATIENTS_Patient
    ADD spEdCaseManagerUserName varchar(256) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENT_INFO_REQUESTS_RESPONSES_MASS_UPDATE_ROWS]') 
         AND name = 'okToCreateRequest'
)
BEGIN
    ALTER TABLE dbo.PATIENT_INFO_REQUESTS_RESPONSES_MASS_UPDATE_ROWS
    ADD okToCreateRequest bit not null default(1)
END

GO

-------------------------------------------------------

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENT_INFO_REQUESTS_RESPONSES_MASS_UPDATE_ROWS]') 
         AND name = 'errorMessage'
)
BEGIN
    ALTER TABLE dbo.PATIENT_INFO_REQUESTS_RESPONSES_MASS_UPDATE_ROWS
    ADD errorMessage NVARCHAR(4000) NULL
END
GO

-------------------------------------------------------

USE SPEDMON
GO

-- drop table PATIENTS_USER_ACCOUNTS
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PATIENTS_USER_ACCOUNTS]') AND type IN (N'U'))
BEGIN
        CREATE TABLE [PATIENTS_USER_ACCOUNTS] (            
                          id                                      bigint                    IDENTITY(1,1) NOT NULL
            , userIDInt               bigint            NOT NULL
                        , userIDUid               uniqueidentifier  NOT NULL
                        , clientID                                bigint                        NOT NULL
                        , patID                   bigint            NOT NULL
                        , created                                 datetime                  NOT NULL
                        , createdBy                       bigint                NOT NULL
                        , lastModified                    datetime              NULL
                        , lastModifiedBy                  bigint                NULL
                        , active                                  bit               NOT NULL DEFAULT(1)
        ) ON [PRIMARY]          
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PATIENT_INFO_PARENT_GUARDIAN_PORTAL_RESPONSES]') AND type in (N'U'))
BEGIN
	CREATE TABLE dbo.PATIENT_INFO_PARENT_GUARDIAN_PORTAL_RESPONSES (
		  id                         bigint			IDENTITY(1,1) NOT NULL PRIMARY KEY
		, clientID                   bigint			NOT NULL
		, patID                      bigint			NOT NULL
		, patPerID                   bigint			NULL
		, ferpaConsent               bit			NULL
		, responderSignatureImgData  varchar(max)	NULL
		, active                     bit			NOT NULL DEFAULT(1)
		, created                    datetime		NOT NULL
		, createdBy                  bigint			NOT NULL
		, lastModified               datetime		NULL
		, lastModifiedBy             bigint			NULL
	) ON [PRIMARY]
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PATIENT_INFO_RESPONSES_FROM_PARENT_GUARDIAN_PORTAL_INSURANCE]') AND type in (N'U'))
BEGIN
	CREATE TABLE dbo.PATIENT_INFO_RESPONSES_FROM_PARENT_GUARDIAN_PORTAL_INSURANCE (
		  id                         bigint			IDENTITY(1,1) NOT NULL PRIMARY KEY
		, portalResponseID           bigint			NOT NULL
		, insuranceType              varchar(20)	NOT NULL  -- 'Primary' / 'Secondary'
		, insuranceOrder             tinyint		NOT NULL  -- 1 / 2
		, insuranceCarrierID         bigint			NULL
		, beneficiaryFirstName       nvarchar(50)	NULL
		, beneficiaryLastName        nvarchar(60)	NULL
		, memberID                   varchar(80)	NULL
		, policyGroupID              varchar(80)	NULL
		, policyHolderName           nvarchar(255)	NULL
		, insuranceCarrierOtherName  varchar(256)	NULL
		, active                     bit			NOT NULL DEFAULT (1)
		, created                    datetime		NOT NULL
		, createdBy                  bigint			NOT NULL
		, lastModified               datetime		NULL
		, lastModifiedBy             bigint			NULL
	) ON [PRIMARY]
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CLAIM_Claim_Posting_Rollback]') AND type IN (N'U'))
BEGIN

CREATE TABLE [dbo].[CLAIM_Claim_Posting_Rollback](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[postingDate] [datetime] NULL,
	[jsonClaimPostings] [varchar](max) NULL,
	[jsonClaimPostingAdjustements] [varchar](max) NULL,
	[jsonClaimAdjudications] [varchar](max) NULL,
	[jsonClaimAdjudicationDetails] [varchar](max) NULL,
	[jsonPaymentSummary] [varchar](max) NULL,
	[jsonClaimsStandAlone] [varchar](max) NULL,
	[jsonClaimsProxyParent] [varchar](max) NULL,
	[jsonClaimsProxyChild] [varchar](max) NULL,
	[createdBy] [bigint] NOT NULL,
	[createdOn] [datetime] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[CYBHI_CLAIM_POSTINGS]') 
         AND name = 'hasRemitAdviceForOtherSubmiters'
)
BEGIN
    ALTER TABLE [dbo].[CYBHI_CLAIM_POSTINGS]
    ADD hasRemitAdviceForOtherSubmiters bit not null default(0)
END
GO

------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[CYBHI_CLAIM_POSTINGS]') 
         AND name = 'remitAdviceForOtherSubmitersCheckAmount'
)
BEGIN
    ALTER TABLE [dbo].[CYBHI_CLAIM_POSTINGS]
    ADD remitAdviceForOtherSubmitersCheckAmount  money not null default(0)
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CYBHI_CLAIM_POSTING_SERVICE_RECORD_PREVIOUS_ADJUDICATION_EXCEPTIONS]') AND type IN (N'U'))
BEGIN

  CREATE TABLE [dbo].[CYBHI_CLAIM_POSTING_SERVICE_RECORD_PREVIOUS_ADJUDICATION_EXCEPTIONS](
	  [id]             bigint   IDENTITY(1,1) NOT NULL
	, [postingID]      bigint   NOT NULL
	, [svcRecID]       bigint   NOT NULL
	, [prevPostingID]  bigint   not null
	, [prevSraID]      bigint   not null
	, [exceptionCode]  smallint not null default(1) /* 1= Same CCN, Amount, RefID, Payer Status Code */ 
	, [resolved]       bit not null default(0)
	, [resolvedOn]     datetime null
	, [resolvedBy]     bigint   null
	, [resolvedNotes]  varchar(max) null
	, [created]        datetime NOT NULL
	, [createdBy]      bigint   NOT NULL
	, [lastModified]   datetime NULL
	, [lastModifiedBy] bigint  NULL
	
	, [active]         bit NOT NULL default(1)
  ) ON [PRIMARY]

END
GO

------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENT_INSURANCE_CARRIERS]') 
         AND name = 'primaryCarrier'
)
BEGIN
    ALTER TABLE [dbo].[PATIENT_INSURANCE_CARRIERS]
    ADD primaryCarrier bit not null default(0)
END
GO


-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[FILE_UPLOADS]') 
         AND name = 'okToShareFileWithParentGuardian'
)
BEGIN
    ALTER TABLE dbo.FILE_UPLOADS
    ADD okToShareFileWithParentGuardian bit not null default(0)
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[FILE_UPLOADS]') 
         AND name = 'okToShareFileWithPatient'
)
BEGIN
    ALTER TABLE dbo.FILE_UPLOADS
    ADD okToShareFileWithPatient bit not null default(0)
END
GO

----------------------------------------------------------------------------------
 
USE SPEDMON
GO
IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[CLIENTS_Client]') 
         AND name = 'spEdCare_bba_percent'
)
BEGIN
  alter table [dbo].[CLIENTS_Client]
  add spEdCare_bba_percent  money not null default(1)
end
go
 
---------------------------------------------------------------------------------------
 
USE SPEDMON
GO
IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[CLIENTS_Client]') 
         AND name = 'smaa_1_percent'
)
BEGIN
  alter table [dbo].[CLIENTS_Client]
  add smaa_1_percent  money not null default(0)
end
go
 
--------------------------------------------------------------------------------------
 
USE SPEDMON
GO
IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[CLIENTS_Client]') 
         AND name = 'smaa_2_percent'
)
BEGIN
  alter table [dbo].[CLIENTS_Client]
  add smaa_2_percent  money not null default(0)
end
go
 
-----------------------------------------------------------------------------------------
 
USE SPEDMON
GO
IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[CLIENTS_Client]') 
         AND name = 'smaa_3_percent'
)
BEGIN
  alter table [dbo].[CLIENTS_Client]
  add smaa_3_percent  money not null default(0)
end
go
 
--------------------------------------------------------------------------------------------
 
USE SPEDMON
GO
IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[CLIENTS_Client]') 
         AND name = 'mba_share'
)
BEGIN
  alter table [dbo].[CLIENTS_Client]
  add mba_share  money not null default(0)
end
go
-----------------------------------------------------------------------------------------------
 
USE SPEDMON
GO
IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[CLIENTS_Client]') 
         AND name = 'spEdCare_partners'
)
BEGIN
  alter table [dbo].[CLIENTS_Client]
  add spEdCare_partners  money not null default(0)
end
go
 
------------------------------------------------------------------------------------------------------
 
USE SPEDMON
GO
IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[CLIENTS_Client]') 
         AND name = 'spEdCare_partners'
)
BEGIN
  alter table [dbo].[CLIENTS_Client]
  add spEdCare_partners  money not null default(0)
end
go
 
------------------------------------------------------------------------------------------------------
 
USE SPEDMON
GO
IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[Client_Invoices]') 
         AND name = 'Distributed_Date'
)
BEGIN
  alter table [dbo].[Client_Invoices]
  add Distributed_Date  date null 
end
go

------------------------------------------------------------------------------------------------------

USE SPEDMON
GO
IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[Client_Invoices]') 
         AND name = 'Distribution_Notes'
)
BEGIN
  alter table [dbo].[Client_Invoices]
  add  [Distribution_Notes] [varchar](max) NULL
end
go

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'minorConsent'
)
BEGIN
    ALTER TABLE [dbo].[PATIENTS_Patient]
    ADD minorConsent bit default(0) with values
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PATIENTS_Patient]') 
         AND name = 'minorConsentEffectiveDate'
)
BEGIN
    ALTER TABLE [dbo].[PATIENTS_Patient]
    ADD minorConsentEffectiveDate date null
END
GO

-------------------------------------------------------


USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PRACTITIONER_Practitioner]') 
         AND name = 'cybhiDegreeCode2'
)
BEGIN
    ALTER TABLE [dbo].[PRACTITIONER_Practitioner]
    ADD cybhiDegreeCode2 varchar(256) null
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PRACTITIONER_Practitioner]') 
         AND name = 'cybhiDegreeCode3'
)
BEGIN
    ALTER TABLE [dbo].[PRACTITIONER_Practitioner]
    ADD cybhiDegreeCode3 varchar(256) null
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PRACTITIONER_Practitioner]') 
         AND name = 'cybhiSpecialtyCode2'
)
BEGIN
    ALTER TABLE [dbo].[PRACTITIONER_Practitioner]
    ADD cybhiSpecialtyCode2 varchar(256) null
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PRACTITIONER_Practitioner]') 
         AND name = 'cybhiSpecialtyCode3'
)
BEGIN
    ALTER TABLE [dbo].[PRACTITIONER_Practitioner]
    ADD cybhiSpecialtyCode3 varchar(256) null
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[PRACTITIONER_Practitioner]') 
         AND name = 'cybhiSpecialtyCode4'
)
BEGIN
    ALTER TABLE [dbo].[PRACTITIONER_Practitioner]
    ADD cybhiSpecialtyCode4 varchar(256) null
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[CYBHI_CLAIM_TRANSMISSIONS]') 
         AND name = 'billingClientID'
)
BEGIN
    ALTER TABLE [dbo].[CYBHI_CLAIM_TRANSMISSIONS]
    ADD billingClientID bigint not null default(0)
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[CYBHI_CLAIM_TRANSMISSIONS]') 
         AND name = 'consortium'
)
BEGIN
    ALTER TABLE [dbo].[CYBHI_CLAIM_TRANSMISSIONS]
    ADD consortium bit not null default(0)
END
GO

-------------------------------------------------------

USE SPEDMON
GO

update dbo.CYBHI_CLAIM_TRANSMISSIONS set billingClientID = clientID where consortium = 0
go

------------------------------------------------------

USE SPEDMON
GO
 
IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[CLIENTS_Client]') 
         AND name = 'cybhiSendElibilityDataMatchRequestsToDHCSForMCAL'
)
begin
  ALTER TABLE [dbo].[CLIENTS_Client] ADD cybhiSendElibilityDataMatchRequestsToDHCSForMCAL bit not null default(0)
end
go

------------------------------------------------------

USE SPEDMON
GO
 
IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[CLAIM_Procedures]') 
         AND name = 'excludeFromServiceRecordImport'
)
begin
  ALTER TABLE [dbo].[CLAIM_Procedures] ADD excludeFromServiceRecordImport bit not null default(0)
end
go

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sped_vehicle_adaptations]') AND type in (N'U'))
BEGIN
	 
CREATE TABLE dbo.sped_vehicle_adaptations (
        id						INT           IDENTITY(1,1) PRIMARY KEY
      , [name]					VARCHAR(256)  NOT NULL       /* Replaces adaptation name*/
      , [class]					varchar(50)   null /* Replaces domain code */
      , displayOrder            INT           NOT NULL DEFAULT 0 /* Replaces sort_order */
      , created                 DATETIME      NULL
      , createdBy               BIGINT        NULL
      , lastModified            DATETIME      NULL
      , lastModifiedBy          BIGINT        NULL
      , active                  BIT           NOT NULL DEFAULT 1 /* Replaces is_active*/  
    )

    INSERT INTO dbo.sped_vehicle_adaptations ([name], [class], displayOrder) VALUES
        ('Wheelchair Lift & Securement'                 , NULL , 1)
      , ('Ramp'                                         , NULL , 2)
      , ('Specialized Harness'                          , NULL , 3)
      , ('Specialized Restraint / Safety Vest'          , NULL , 4)
      , ('Specialized Car Seat / Positioning Seat'      , NULL , 5)
      , ('Lap Tray / Positioning Support'               , NULL , 6)
      , ('Specialized Environmental Controls'           , NULL , 7)
      , ('Specialized Suspension System'                , NULL , 8)
      , ('Oxygen Accommodations & Storage'              , NULL , 9)
      , ('Ventilator / Medical Equipment Accommodation' , NULL , 10)
      , ('Electrical Power / Charging Support'          , NULL , 11)
      , ('Stretcher / Gurney Accommodations'            , NULL , 12)
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PATIENTS_Accommodations]') AND type in (N'U'))
BEGIN
    CREATE TABLE dbo.PATIENTS_Accommodations (
        id                      BIGINT        IDENTITY(1,1) PRIMARY KEY
      , patID                   BIGINT        NOT NULL
      , recordType              INT           NOT NULL DEFAULT 1
      , category                INT           NULL
      , categoryName            VARCHAR(256)  NULL
      , accommodation           VARCHAR(512)  NULL
      , details                 VARCHAR(MAX)  NULL
      , appliesTo               VARCHAR(MAX)  NULL
      , appliesToNames          VARCHAR(MAX)  NULL
      , startDate               DATE          NULL
      , endDate                 DATE          NULL
      , frequency               INT           NULL
      , frequencyName           VARCHAR(256)  NULL
      , duration                VARCHAR(512)  NULL
      , location                INT           NULL
      , locationName            VARCHAR(256)  NULL
      , locationOther           VARCHAR(512)  NULL
      , linkedAreaOfNeed        VARCHAR(MAX)  NULL
      , linkedAreaOfNeedNames   VARCHAR(MAX)  NULL
      , alignedGoal             VARCHAR(MAX)  NULL
      , alignedGoalNames        VARCHAR(MAX)  NULL
      , staffResponsible        VARCHAR(MAX)  NULL
      , staffResponsibleNames   VARCHAR(MAX)  NULL
      , status                  INT           NOT NULL DEFAULT 1
      , discontinueReason       VARCHAR(7000) NULL
      , created                 DATETIME      NULL
      , createdBy               BIGINT        NULL
      , lastModified            DATETIME      NULL
      , lastModifiedBy          BIGINT        NULL
      , active                  BIT           NOT NULL DEFAULT 1
    )
END
GO

-------------------------------------------------------
USE SPEDMON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sped_vehicle_adaptations]') AND type in (N'U'))
BEGIN
	 
CREATE TABLE dbo.sped_vehicle_adaptations (
        id						INT           IDENTITY(1,1) PRIMARY KEY
      , [name]					VARCHAR(256)  NOT NULL       /* Replaces adaptation name*/
      , [class]					varchar(50)   null /* Replaces domain code */
      , displayOrder            INT           NOT NULL DEFAULT 0 /* Replaces sort_order */
      , created                 DATETIME      NULL
      , createdBy               BIGINT        NULL
      , lastModified            DATETIME      NULL
      , lastModifiedBy          BIGINT        NULL
      , active                  BIT           NOT NULL DEFAULT 1 /* Replaces is_active*/  
    )

    INSERT INTO dbo.sped_vehicle_adaptations ([name], [class], displayOrder) VALUES
        ('Wheelchair Lift & Securement'                 , NULL , 1)
      , ('Ramp'                                         , NULL , 2)
      , ('Specialized Harness'                          , NULL , 3)
      , ('Specialized Restraint / Safety Vest'          , NULL , 4)
      , ('Specialized Car Seat / Positioning Seat'      , NULL , 5)
      , ('Lap Tray / Positioning Support'               , NULL , 6)
      , ('Specialized Environmental Controls'           , NULL , 7)
      , ('Specialized Suspension System'                , NULL , 8)
      , ('Oxygen Accommodations & Storage'              , NULL , 9)
      , ('Ventilator / Medical Equipment Accommodation' , NULL , 10)
      , ('Electrical Power / Charging Support'          , NULL , 11)
      , ('Stretcher / Gurney Accommodations'            , NULL , 12)
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sped_accommodation_categories]') AND type in (N'U'))
BEGIN
	CREATE TABLE dbo.sped_accommodation_categories (
        id						INT           IDENTITY(1,1) PRIMARY KEY
      , [name]					VARCHAR(256)  NOT NULL
      , [class]					VARCHAR(50)   NULL  /*replaces domain_code */
      , displayOrder			INT           NOT NULL DEFAULT 0
      , created                 DATETIME      NULL
      , createdBy               BIGINT        NULL
      , lastModified            DATETIME      NULL
      , lastModifiedBy          BIGINT        NULL
      , active                  BIT           NOT NULL DEFAULT 1 /* Replaces is_active*/
    )

    INSERT INTO dbo.sped_accommodation_categories ([name], [class], displayOrder, active) VALUES
        ('Instruction'                          , 'ACCOMMODATION' ,  1 , 1)
      , ('Assignments'                          , 'ACCOMMODATION' ,  2 , 1)
      , ('Testing'                              , 'ACCOMMODATION' ,  3 , 1)
      , ('Communication'                        , 'ACCOMMODATION' ,  4 , 1)
      , ('Behavior / Regulation'                , 'ACCOMMODATION' ,  5 , 1)
      , ('Sensory / Environmental'              , 'ACCOMMODATION' ,  6 , 1)
      , ('Organization / Executive Functioning' , 'ACCOMMODATION' ,  7 , 1)
      , ('Assistive Technology'                 , 'ACCOMMODATION' ,  8 , 1)
      , ('Health / Medical Access'              , 'ACCOMMODATION' ,  9 , 1)
      , ('Transportation / Access'              , 'ACCOMMODATION' , 10 , 1)
      , ('English Learner / Language Access'    , 'ACCOMMODATION' , 11 , 1)
      , ('Motor / Physical Access'              , 'ACCOMMODATION' , 12 , 1)
      , ('Vision'                               , 'ACCOMMODATION' , 13 , 1)
      , ('Hearing'                              , 'ACCOMMODATION' , 14 , 1)
      , ('Personnel Support'                    , 'ACCOMMODATION' , 15 , 1)
      , ('Curriculum / Content'                 , 'MODIFICATION'  , 16 , 1)
      , ('Output / Response'                    , 'MODIFICATION'  , 17 , 1)
      , ('Performance Expectations'             , 'MODIFICATION'  , 18 , 1)
      , ('Pacing / Load'                        , 'MODIFICATION'  , 19 , 1)
      , ('Assessment Modification'              , 'MODIFICATION'  , 20 , 1)
      , ('Consultation / Coaching'              , 'PERSONNEL'     , 21 , 1)
      , ('Training'                             , 'PERSONNEL'     , 22 , 1)
      , ('Planning Support'                     , 'PERSONNEL'     , 23 , 1)
      , ('Classroom Implementation Support'     , 'PERSONNEL'     , 24 , 1)
      , ('Communication Support'                , 'PERSONNEL'     , 25 , 1)
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sped_accommodation_applies_to]') AND type in (N'U'))
BEGIN
	CREATE TABLE dbo.sped_accommodation_applies_to (
        id					    INT           IDENTITY(1,1) PRIMARY KEY
      , [name]				    VARCHAR(256)  NOT NULL
      , displayOrder            INT           NOT NULL DEFAULT 0
      , created                 DATETIME      NULL
      , createdBy               BIGINT        NULL
      , lastModified            DATETIME      NULL
      , lastModifiedBy          BIGINT        NULL
      , active                  BIT           NOT NULL DEFAULT 1 /* Replaces is_active*/     
    )

    INSERT INTO dbo.sped_accommodation_applies_to ([name], displayOrder, active) VALUES
        ('Classroom'                                ,  1 , 1)
      , ('Assessments'                              ,  2 , 1)
      , ('Classroom and Assessments'                ,  3 , 1)
      , ('Recess / Lunch'                           ,  4 , 1)
      , ('PE'                                       ,  5 , 1)
      , ('Transportation'                           ,  6 , 1)
      , ('Home / School Communication'              ,  7 , 1)
      , ('Community-Based Instruction'              ,  8 , 1)
      , ('Virtual Instruction'                      ,  9 , 1)
      , ('Extracurricular / Nonacademic Activities' , 10 , 1)
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sped_accommodation_frequencies]') AND type in (N'U'))
BEGIN
	CREATE TABLE dbo.sped_accommodation_frequencies (
        id						 INT          IDENTITY(1,1) PRIMARY KEY
      , [name]					VARCHAR(256)  NOT NULL
      , displayOrder            INT           NOT NULL DEFAULT 0
      , created                 DATETIME      NULL
      , createdBy               BIGINT        NULL
      , lastModified            DATETIME      NULL
      , lastModifiedBy          BIGINT        NULL
      , active                  BIT           NOT NULL DEFAULT 1 /* Replaces is_active*/     
    )
 
    INSERT INTO dbo.sped_accommodation_frequencies ([name], displayOrder, active) VALUES
        ('Daily'               ,  1 , 1)
      , ('Weekly'              ,  2 , 1)
      , ('Monthly'             ,  3 , 1)
      , ('Per Test'            ,  4 , 1)
      , ('Per Assignment'      ,  5 , 1)
      , ('Per Class Period'    ,  6 , 1)
      , ('As Needed'           ,  7 , 1)
      , ('One Time'            ,  8 , 1)
      , ('Quarterly'           ,  9 , 1)
      , ('Each Grading Period' , 10 , 1)
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sped_accommodation_locations]') AND type in (N'U'))
BEGIN
	CREATE TABLE dbo.sped_accommodation_locations (
        id						INT           IDENTITY(1,1) PRIMARY KEY
      , [name]					VARCHAR(256)  NOT NULL
      , displayOrder			INT	          NOT NULL DEFAULT 0
      , created                 DATETIME      NULL
      , createdBy               BIGINT        NULL
      , lastModified            DATETIME      NULL
      , lastModifiedBy          BIGINT        NULL
      , active                  BIT           NOT NULL DEFAULT 1 /* Replaces is_active*/     
 
    )
    INSERT INTO dbo.sped_accommodation_locations ([name], displayOrder, active) VALUES
        ('General Education Classroom' ,  1 , 1)
      , ('Special Education Classroom' ,  2 , 1)
      , ('Testing Center'              ,  3 , 1)
      , ('Resource Room'               ,  4 , 1)
      , ('Speech Room'                 ,  5 , 1)
      , ('OT Room'                     ,  6 , 1)
      , ('PT Area'                     ,  7 , 1)
      , ('Counseling Office'           ,  8 , 1)
      , ('Campus-Wide'                 ,  9 , 1)
      , ('Playground / Recess Area'    , 10 , 1)
      , ('Cafeteria'                   , 11 , 1)
      , ('Bus / Transportation'        , 12 , 1)
      , ('Home'                        , 13 , 1)
      , ('Community Setting'           , 14 , 1)
      , ('Virtual / Online'            , 15 , 1)
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sped_accommodation_areas_of_need]') AND type in (N'U'))
BEGIN
	CREATE TABLE dbo.sped_accommodation_areas_of_need (
        id						INT          IDENTITY(1,1) PRIMARY KEY
      , [name]					VARCHAR(256)  NOT NULL
      , displayOrder			INT           NOT NULL DEFAULT 0
      , created                 DATETIME      NULL
      , createdBy               BIGINT        NULL
      , lastModified            DATETIME      NULL
      , lastModifiedBy          BIGINT        NULL
      , active                  BIT           NOT NULL DEFAULT 1 /* Replaces is_active*/     
 
    )

    INSERT INTO dbo.sped_accommodation_areas_of_need ([name], displayOrder, active) VALUES
        ('Reading'                           ,  1 , 1)
      , ('Writing'                           ,  2 , 1)
      , ('Math'                              ,  3 , 1)
      , ('Communication'                     ,  4 , 1)
      , ('Social / Emotional'                ,  5 , 1)
      , ('Behavior'                          ,  6 , 1)
      , ('Attention / Executive Functioning' ,  7 , 1)
      , ('Sensory'                           ,  8 , 1)
      , ('Motor'                             ,  9 , 1)
      , ('Health'                            , 10 , 1)
      , ('Adaptive / Daily Living'           , 11 , 1)
      , ('Transition'                        , 12 , 1)
      , ('English Language Development'      , 13 , 1)
      , ('Vision'                            , 14 , 1)
      , ('Hearing'                           , 15 , 1)
      , ('Attendance / Access'               , 16 , 1)
END
GO

-------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sped_accommodation_staff_roles]') AND type in (N'U'))
BEGIN
   CREATE TABLE dbo.sped_accommodation_staff_roles (
        id						INT           IDENTITY(1,1) PRIMARY KEY
      , [name]					VARCHAR(256)  NOT NULL
      , displayOrder            INT           NOT NULL DEFAULT 0
      , created                 DATETIME      NULL
      , createdBy               BIGINT        NULL
      , lastModified            DATETIME      NULL
      , lastModifiedBy          BIGINT        NULL
      , active                  BIT           NOT NULL DEFAULT 1   
	  )

    INSERT INTO dbo.sped_accommodation_staff_roles ([name], displayOrder, active) VALUES
        ('General Education Teacher' ,  1 , 1)
      , ('Special Education Teacher' ,  2 , 1)
      , ('Case Manager'              ,  3 , 1)
      , ('School Psychologist'       ,  4 , 1)
      , ('SLP'                       ,  5 , 1)
      , ('OT'                        ,  6 , 1)
      , ('PT'                        ,  7 , 1)
      , ('APE Teacher'               ,  8 , 1)
      , ('Counselor'                 ,  9 , 1)
      , ('Nurse'                     , 10 , 1)
      , ('Behavior Specialist'       , 11 , 1)
      , ('Paraeducator / Aide'       , 12 , 1)
      , ('Testing Coordinator'       , 13 , 1)
      , ('Administrator'             , 14 , 1)
      , ('Transportation Staff'      , 15 , 1)
END
GO
------------------------------------------------------

USE SPEDMON
GO
 
IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[ORP_DOCUMENT_STANDARD_SELECTION_NAMES]') 
         AND name = 'formBuilderContentForServiceJournalEntryNotesJSON'
)
begin
  ALTER TABLE [dbo].[ORP_DOCUMENT_STANDARD_SELECTION_NAMES] ADD formBuilderContentForServiceJournalEntryNotesJSON varchar(max) not null default('{}')
end
go

------------------------------------------------------

USE SPEDMON
GO
 
IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[ORP_DOCUMENT_STANDARD_SELECTION_NAMES]') 
         AND name = 'serviceJournalAssociatedEventTypeID'
)
begin
  ALTER TABLE [dbo].[ORP_DOCUMENT_STANDARD_SELECTION_NAMES] ADD serviceJournalAssociatedEventTypeID bigint not null default(5)
end
go

------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Import_From_Patient_Goal_Records]') AND type IN (N'U'))
BEGIN

  CREATE TABLE [dbo].[Import_From_Patient_Goal_Records](
          id                    bigint         IDENTITY(1,1) NOT NULL
        , clientID              bigint         NOT NULL
        , patID                 bigint         NOT NULL
        , ssid                  varchar(50)    NOT NULL
        , schoolCDSCode         varchar(50)    NULL
        , startDate             date	       NULL
        , endDate               date	       NULL
        , seisID                varchar(50)    NULL
        , districtID            varchar(50)    NULL
        , lastName              varchar(100)   NULL
        , firstName             varchar(100)   NULL
        , birthdate             date           NULL
        , grade                 varchar(50)    NULL
        , schoolOfAttendance    varchar(256)   NULL
        , districtOfService     varchar(256)   NULL
        , caseManager           varchar(256)   NULL
        , iepDate               date		   NULL
        , eligibilityStatus     varchar(100)   NULL
        , areaOfNeed            varchar(256)   NULL
        , goalNumber            varchar(50)    NULL
        , baseline              varchar(max)   NULL
        , goalText              varchar(max)   NULL
        , purposeOfGoal         varchar(max)   NULL
        , standard              varchar(1000)  NULL
        , personResponsible     varchar(256)   NULL
		
        , objective1            varchar(max)   NULL
        , objective1Met         varchar(50)    NULL
        , objective1DateMet     date		   NULL

        , objective2            varchar(max)   NULL
        , objective2Met         varchar(50)    NULL
        , objective2DateMet     date		   NULL

        , objective3            varchar(max)   NULL
        , objective3Met         varchar(50)    NULL
        , objective3DateMet     date		   NULL

        , annualReview          date		   NULL
        , comments              varchar(max)   NULL
        , goalMet               bit			   NOT NULL DEFAULT(0)
        , addedOn               date		   NULL
        , addedBy               varchar(256)   NULL
        , updatedBy             varchar(256)   NULL
        , updatedOn             date		   NULL
        , lastAffirmedPR        date		   NULL

        , created               datetime       NOT NULL
        , createdBy             bigint         NOT NULL
        , lastModified	        datetime       NULL
        , lastModifiedBy        bigint         NULL
        , active                bit            NOT NULL DEFAULT(1)
  ) ON [PRIMARY]

END
GO

------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
    SELECT *
    FROM sys.columns
    WHERE object_id = OBJECT_ID(N'[dbo].[PATIENT_GOALS]')
      AND name = 'goalMetOn'
)
BEGIN
    ALTER TABLE dbo.PATIENT_GOALS ADD goalMetOn date null
END
GO

------------------------------------------------------

IF NOT EXISTS (
    SELECT *
    FROM sys.columns
    WHERE object_id = OBJECT_ID(N'[dbo].[PATIENT_GOALS]')
      AND name = 'backgroundText'
)
BEGIN
    ALTER TABLE dbo.PATIENT_GOALS ADD backgroundText varchar(max) not null default('')
END
GO

------------------------------------------------------

IF NOT EXISTS (
    SELECT *
    FROM sys.columns
    WHERE object_id = OBJECT_ID(N'[dbo].[PATIENT_GOALS]')
      AND name = 'notes'
)
BEGIN
    ALTER TABLE dbo.PATIENT_GOALS ADD notes varchar(max) not null default('')
END
GO

------------------------------------------------------

IF NOT EXISTS (
    SELECT *
    FROM sys.columns
    WHERE object_id = OBJECT_ID(N'[dbo].[PATIENT_GOALS]')
      AND name = 'hasObjectives'
)
BEGIN
    ALTER TABLE dbo.PATIENT_GOALS ADD hasObjectives bit not null default(0)
END
GO

------------------------------------------------------

IF NOT EXISTS (
    SELECT *
    FROM sys.columns
    WHERE object_id = OBJECT_ID(N'[dbo].[PATIENT_GOALS]')
      AND name = 'hasObjective1'
)
BEGIN
    ALTER TABLE dbo.PATIENT_GOALS ADD hasObjective1 bit not null default(0)
END
GO

------------------------------------------------------

IF NOT EXISTS (
    SELECT *
    FROM sys.columns
    WHERE object_id = OBJECT_ID(N'[dbo].[PATIENT_GOALS]')
      AND name = 'objective1Text'
)
BEGIN
    ALTER TABLE dbo.PATIENT_GOALS ADD objective1Text varchar(max) not null default('')
END
GO

------------------------------------------------------

IF NOT EXISTS (
    SELECT *
    FROM sys.columns
    WHERE object_id = OBJECT_ID(N'[dbo].[PATIENT_GOALS]')
      AND name = 'objective1Met'
)
BEGIN
    ALTER TABLE dbo.PATIENT_GOALS ADD objective1Met bit not null default(0)
END
GO

------------------------------------------------------

IF NOT EXISTS (
    SELECT *
    FROM sys.columns
    WHERE object_id = OBJECT_ID(N'[dbo].[PATIENT_GOALS]')
      AND name = 'objective1MetOn'
)
BEGIN
    ALTER TABLE dbo.PATIENT_GOALS ADD objective1MetOn date null
END
GO

------------------------------------------------------

IF NOT EXISTS (
    SELECT *
    FROM sys.columns
    WHERE object_id = OBJECT_ID(N'[dbo].[PATIENT_GOALS]')
      AND name = 'hasObjective2'
)
BEGIN
    ALTER TABLE dbo.PATIENT_GOALS ADD hasObjective2 bit not null default(0)
END
GO

------------------------------------------------------

IF NOT EXISTS (
    SELECT *
    FROM sys.columns
    WHERE object_id = OBJECT_ID(N'[dbo].[PATIENT_GOALS]')
      AND name = 'objective2Text'
)
BEGIN
    ALTER TABLE dbo.PATIENT_GOALS ADD objective2Text varchar(max) not null default('')
END
GO

------------------------------------------------------

IF NOT EXISTS (
    SELECT *
    FROM sys.columns
    WHERE object_id = OBJECT_ID(N'[dbo].[PATIENT_GOALS]')
      AND name = 'objective2Met'
)
BEGIN
    ALTER TABLE dbo.PATIENT_GOALS ADD objective2Met bit not null default(0)
END
GO

------------------------------------------------------

IF NOT EXISTS (
    SELECT *
    FROM sys.columns
    WHERE object_id = OBJECT_ID(N'[dbo].[PATIENT_GOALS]')
      AND name = 'objective2MetOn'
)
BEGIN
    ALTER TABLE dbo.PATIENT_GOALS ADD objective2MetOn date null
END
GO

------------------------------------------------------

IF NOT EXISTS (
    SELECT *
    FROM sys.columns
    WHERE object_id = OBJECT_ID(N'[dbo].[PATIENT_GOALS]')
      AND name = 'hasObjective3'
)
BEGIN
    ALTER TABLE dbo.PATIENT_GOALS ADD hasObjective3 bit not null default(0)
END
GO

------------------------------------------------------

IF NOT EXISTS (
    SELECT *
    FROM sys.columns
    WHERE object_id = OBJECT_ID(N'[dbo].[PATIENT_GOALS]')
      AND name = 'objective3Text'
)
BEGIN
    ALTER TABLE dbo.PATIENT_GOALS ADD objective3Text varchar(max) not null default('')
END
GO

------------------------------------------------------

IF NOT EXISTS (
    SELECT *
    FROM sys.columns
    WHERE object_id = OBJECT_ID(N'[dbo].[PATIENT_GOALS]')
      AND name = 'objective3Met'
)
BEGIN
    ALTER TABLE dbo.PATIENT_GOALS ADD objective3Met bit not null default(0)
END
GO

------------------------------------------------------

IF NOT EXISTS (
    SELECT *
    FROM sys.columns
    WHERE object_id = OBJECT_ID(N'[dbo].[PATIENT_GOALS]')
      AND name = 'objective3MetOn'
)
BEGIN
    ALTER TABLE dbo.PATIENT_GOALS ADD objective3MetOn date null
END
GO

------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
    SELECT *
    FROM sys.columns
    WHERE object_id = OBJECT_ID(N'[dbo].[PATIENT_GOALS_PROGRESS]')
      AND name = 'progressTrackingForWhat'
)
BEGIN
    ALTER TABLE dbo.PATIENT_GOALS_PROGRESS ADD progressTrackingForWhat smallint not null default(1)
END
GO

------------------------------------------------------

USE SPEDMON
GO

IF NOT EXISTS (
    SELECT *
    FROM sys.columns
    WHERE object_id = OBJECT_ID(N'[dbo].[SERVICE_RECORD_DATA_INCOMPLETE]')
      AND name = 'svcRecID'
)
BEGIN
    ALTER TABLE dbo.SERVICE_RECORD_DATA_INCOMPLETE ADD svcRecID bigint null
END
GO

------------------------------------------------------

USE SPEDMON
GO