use SPEDMON
go

----------------------------- Udfs that depend on table variables types defined below  ---------------------------------------------

/*-------------------------------
 * Exists/Drop
 * (depreciated function)
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_WITH_RESPECT_TO_PLAN_DATES_VIEW_DATA_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_WITH_RESPECT_TO_PLAN_DATES_VIEW_DATA_CORE
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_BY_GRP_SVC_CLASS_SVC_TYPE_PLAN_TYPE_NAME_ID_SUMMARY_VIEW_DATA_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_BY_GRP_SVC_CLASS_SVC_TYPE_PLAN_TYPE_NAME_ID_SUMMARY_VIEW_DATA_CORE
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_NON_SPED_SERVICES_ORP_DOC_DETAILS_VIEW_DATA_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_NON_SPED_SERVICES_ORP_DOC_DETAILS_VIEW_DATA_CORE
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_SPED_SERVICES_PLAN_SUMMARY_VIEW_DATA_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_SPED_SERVICES_PLAN_SUMMARY_VIEW_DATA_CORE
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_SPED_SERVICES_PLAN_DETAILS_VIEW_DATA_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_SPED_SERVICES_PLAN_DETAILS_VIEW_DATA_CORE
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_PROMISED_SERVICES_CALC_EXPECTED_DATES_AND_MINUTES') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PATIENT_PROMISED_SERVICES_CALC_EXPECTED_DATES_AND_MINUTES
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_SPED_SERVICES_VIEW_DATA_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_SPED_SERVICES_VIEW_DATA_CORE
GO

--------------------------------------------------- Table variable types ---------------------------------------------
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
/* This is for cleanup*/

IF EXISTS (SELECT * FROM sys.table_types WHERE name = 'PatientPromisedServicesSvcMinsExpectedEntered')
DROP TYPE PatientPromisedServicesSvcMinsExpectedEntered
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.table_types WHERE name = 'PatientPromisedServicesDatePeriods')
DROP TYPE PatientPromisedServicesDatePeriods
GO

CREATE TYPE PatientPromisedServicesDatePeriods AS TABLE ( 
  n                 int
, startDate         datetime
, endDate           datetime
, expectedMinutes   int
, possibleDataEntryError bit default(0)

unique clustered (n)  

) /*WITH (MEMORY_OPTIMIZED = ON);*/
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.table_types WHERE name = 'PatientPromisedServicesSvcExceptionsEntered')
DROP TYPE PatientPromisedServicesSvcExceptionsEntered
GO

CREATE TYPE PatientPromisedServicesSvcExceptionsEntered AS TABLE ( 
      dosStart                          datetime
	, dosEnd                            datetime
	, numMins                           int
    , detailSlotSubFromMinutesExpected  bit 
    , detailSlotAddToMinutesSatisfied   bit 
	, idx                               bigint identity(1,1) 
  unique clustered (dosStart, dosEnd, idx)
) /*WITH (MEMORY_OPTIMIZED = ON);*/
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.table_types WHERE name = 'PatientPromisedServicesSvcMinsEntered')
DROP TYPE PatientPromisedServicesSvcMinsEntered
GO

CREATE TYPE PatientPromisedServicesSvcMinsEntered AS TABLE (
      dos                        datetime
	, numMinsSatisfied           int 
    , idx                        int identity(1,1) 
  unique clustered (dos, idx)
) /*WITH (MEMORY_OPTIMIZED = ON); */
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.table_types WHERE name = 'PatientPromisedServicesSvcMinsExpectedEnteredForVDC')
DROP TYPE PatientPromisedServicesSvcMinsExpectedEnteredForVDC
GO

CREATE TYPE PatientPromisedServicesSvcMinsExpectedEnteredForVDC AS TABLE ( 
    ppsIdx                            bigint
  , dosStart                          datetime
  , dosEnd                            datetime
  , minsProjectedForPlan              int default(0)
  , minsProjectedForBreak             int default(0)
  , minsDetectedForESY                int default(0)
  , svcExceptionMinsToSubFromExpected int default(0)
  , numMinsExpected                   int default(0)
  , numSvcMinsEntered                 int default(0)
  , svcExceptionMinsToAddToSatisfied  int default(0)
  , numMinsSatisfied                  int default(0)
  , nonPeriodicPlan                             bit default(0)
  , nonPeriodicPlanSvcMinsEnteredDuringDosRange int default(0) 
 unique clustered (dosStart, dosEnd, ppsIdx) 
) /*WITH (MEMORY_OPTIMIZED = ON); */
GO


/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.table_types WHERE name = 'PatientPromisedServicesSvcMinsExpectedEnteredSummaryOrDetail')
DROP TYPE PatientPromisedServicesSvcMinsExpectedEnteredSummaryOrDetail
GO

CREATE TYPE PatientPromisedServicesSvcMinsExpectedEnteredSummaryOrDetail AS TABLE ( 
    ppsIdx                            bigint
  , dosStart                          datetime
  , dosEnd                            datetime
  , minsProjectedForPlan              int default(0)
  , minsProjectedForBreak             int default(0)
  , svcExceptionMinsToSubFromExpected int default(0)
  , numMinsExpected                   int default(0)
  , numSvcMinsEntered                 int default(0)
  , svcExceptionMinsToAddToSatisfied  int default(0)
  , numMinsSatisfied                  int default(0)
  , diffMinsExpectedSatisfied         int default(0)
  , lessThanExpected                  bit default(0)
  , nonPerPlanSvcMinsEntDurDosRange   int default(0)
  , totalMinutesSatisfiedUpToExpected int default(0)
  , pctExpectedSatisfied              real
  , potentialLostReimbursment         money
  , numPatAbsentTot                   int default(0)
  , numPracAbsentTot                  int default(0)
  , numSvcRecs                        int default(0)
  , idx                               bigint identity(1,1)
 
unique clustered (ppsIdx, idx)
) 
GO


/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.table_types WHERE name = 'PatientPromisedServicesPlans')
DROP TYPE PatientPromisedServicesPlans
GO

CREATE TYPE PatientPromisedServicesPlans AS TABLE
(
      idx                                  bigint identity(1,1) 
    , clientID                             int
    , patID                                int
	, patHasBIC                            bit
	, patHasSSID                           bit
    , spEdExitedSpEdDate                   date
    , spEdServiceCode                      int
    , spEdFreqCode                         int
    , minsPerFreq                          int
    , startDate                            date
    , endDate                              date
    , planStartDate                        date
    , planEndDate                          date
	, isNonPeriodicPlan                    bit    
	, avgRate                              money   
    , avgUnitPerMinFactor                  int
    , billableSvc                          bit
    unique clustered (idx)
   ,unique nonclustered (clientID, patID, spEdServiceCode, idx) /* Helps with reporting */
  
) /*WITH (MEMORY_OPTIMIZED = ON);  */
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.table_types WHERE name = 'PatientPromisedServicesBreaks')
DROP TYPE PatientPromisedServicesBreaks
GO

CREATE TYPE PatientPromisedServicesBreaks AS TABLE
(
    clientID   bigint   not null
  , siteID     bigint   not null
  , startDate  datetime not null
  , endDate    datetime not null
  unique clustered (startDate, endDate, clientID, siteID)
) /*WITH (MEMORY_OPTIMIZED = ON);  */
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.table_types WHERE name = 'PatientPromisedServicesSpEdSnx')
DROP TYPE PatientPromisedServicesSpEdSnx
GO

CREATE TYPE PatientPromisedServicesSpEdSnx AS TABLE
(
      spEdSvcCodeValue    int
    , groupID             int
    , planTypeID          int
    , nameID              int
    , groupSvcClassNameID bigint
	, rate                money
    , unitPerMinFactor    int
    , idx                 bigint identity(1,1)
  unique clustered (spEdSvcCodeValue, groupID, planTypeID, nameID, idx) 
) /*WITH (MEMORY_OPTIMIZED = ON);  */
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.table_types WHERE name = 'PatientPromisedServicesSpEdSvcs')
DROP TYPE PatientPromisedServicesSpEdSvcs
GO

CREATE TYPE PatientPromisedServicesSpEdSvcs AS TABLE
(
      spEdServiceCode     int
    , avgRate             money default 0
    , avgUnitPerMinFactor int   default 1
	, billableSvc         bit   default 0
  unique clustered (spEdServiceCode)
) /*WITH (MEMORY_OPTIMIZED = ON);  */
GO

