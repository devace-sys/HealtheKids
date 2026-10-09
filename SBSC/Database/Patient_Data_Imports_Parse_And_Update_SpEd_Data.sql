USE spedmon
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Patient_Data_Imports_Parse_And_Update_SpEd_Data') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.Patient_Data_Imports_Parse_And_Update_SpEd_Data
GO

/***************************************************************************    
 * Patient_Data_Imports_Parse_And_Update_SpEd_Data */    
/**    
 * This routine completely replaces ALL records in PATIENTS_PROMISED_SERVICES
 * for a given @clientID using the data stored in 
 *
 *     [Import_From_A.5_SERVICES_From_Client_Files]     
 * and [Import_From_A.5_SERVICES_From_Client_File_Rows] 
 *
 * It is designed to fail silently if there is an issue and rollback
 * as to not disrupt other processes.
 *
 * IMPORTANT NOTE: Patients can have promised services with the same
 * spEd service code and date range but different frequencies and durations
 * This is usualy for seperate individual and group services.
 * 
 * The consolidation logic and overlap logic takes this into account
 ***************************************************************************/                         

CREATE PROCEDURE [dbo].[Patient_Data_Imports_Parse_And_Update_SpEd_Data] (
    @clientID          bigint
  , @completedNormally bit = 0 output
)
AS

BEGIN

/*###########################################################################*/
/*#  Init and setup                                                         #*/
/*###########################################################################*/

set nocount on

declare @userID as bigint = 0

set @completedNormally = 0
set @userID            = 0

begin try

exec dbo.PRINT_STATUS_MESSAGE 'Parsing and updating SpEd patient promised services'

/*###########################################################################*/
/*#  Setup working vars                                                     #*/
/*###########################################################################*/

declare @tranOpen     as bit          = 0
declare @today        as datetime     = getdate()
declare @minYear      as int          = 1988
declare @maxYear      as int          = 2100
declare @numRows      as int          = 0
declare @msg          as varchar(256) = ''

/*###########################################################################*/
/*#  Exit if no client                                                      #*/
/*###########################################################################*/

if (@clientID is null) 
begin
  set @completedNormally = 0
  exec dbo.PRINT_STATUS_MESSAGE 'Client not provided'
  return(0)
end

/*###########################################################################*/
/*#  Generate summary rows for any file that has not been pre-processed     #*/
/*###########################################################################*/

exec dbo.Patient_Data_Imports_Generate_SpEd_Data_File_Summary_Rows 
    @clientID
  , @minYear
  , @maxYear

/*###########################################################################*/
/*#  Setup Table Vars                                                       #*/
/*###########################################################################*/

/*------------------------------------*/
/* Holds all clean spEd services      */
/* promised for each patient          */
/* after the data has been            */
/* consolidated and normalized.       */
/* This data is used in compliance    */
/* calculations and is permamently    */
/* stored in patients promised        */
/* services                           */
/*------------------------------------*/

declare @spEdDataImportedAndCorrected as table (
    patID                     bigint
  , latestFileID              bigint
  , latestFileRowID           bigint
  , spEdSvcCode               int
  , spEdFreqCode              int
  , duration                  int
  , individualSvc             bit
  , groupSvc                  bit
  , startDate                 date
  , endDate                   date  
  , numSvcLines               int
  , svcLinesDetailsJSON       varchar(max)
  , spEdProviderCode          int 
  , spEdLocationCode          int
  , spEdDisabilityCode1       int
  , spEdDisabilityCode2       int
  , lastEvalDate              date
  , lastAnnIEPDate            date
  , nextAnnIEPDate            date
  , spEdSpecTransport         bit
  , caseManagerName           varchar(256)
  , exitedSpEdDate            date

unique clustered (
   patID        
 , latestFileID
 , latestFileRowID )

)

/*------------------------------------*/
/* Holds patient specific SpEd data   */
/* for the given client ID.           */
/*                                    */ 
/* This data is not used in           */
/* compliance calculations.           */
/*------------------------------------*/

declare @spEdDataImportedPatientData as table (
    patID                           bigint
  , latestFileID                    bigint
  , latestFileRowID                 bigint
  , latestSpEdProviderCode          int 
  , latestSpEdLocationCode          int
  , latestSpEdDisabilityCode1       int
  , latestSpEdDisabilityCode2       int
  , latestLastEval                  date
  , latestLastAnnIEP                date
  , latestNextAnnIEP                date
  , latestSpEdSpecialTransportation bit
  , latestCaseManagerName           varchar(256)
  , latestExitedSpEdDate            date
unique clustered (
   patID        
 , latestFileID
 , latestFileRowID )
)

/*###########################################################################*/
/*#  Load, Parse, and Correct Service Date                                  #*/
/*###########################################################################*/

exec dbo.PRINT_STATUS_MESSAGE 'Loading, parsing, and correcting SpEd data that involves promised service metrics'

insert into @spEdDataImportedAndCorrected (
    patID
  , latestFileID
  , latestFileRowID 
  , spEdSvcCode
  , spEdFreqCode
  , duration 
  , individualSvc
  , groupSvc
  , startDate
  , endDate  
  , numSvcLines
  , svcLinesDetailsJSON
  , spEdProviderCode 
  , spEdLocationCode 
  , spEdDisabilityCode1
  , spEdDisabilityCode2
  , lastEvalDate 
  , lastAnnIEPDate
  , nextAnnIEPDate 
  , spEdSpecTransport
  , caseManagerName  
  , exitedSpEdDate 

)
select  
    t1.patID
  , t1.latestFileID 
  , t1.latestFileRowID 
  , t1.spEdSvcCode
  , t1.spEdFreqCode
  , t1.duration
  , t1.individualSvc
  , t1.groupSvc
  , t1.startDate
  , t1.endDate
  , t1.numSvcLines
  , t1.svcLinesDetailsJSON
  , t3.spEdProviderCode 
  , t3.spEdLocationCode
  , t3.spEdDisabilityCode1
  , t3.spEdDisabilityCode2 
  , t3.lastEvalDate
  , t3.lastAnnIEPDate
  , t3.nextAnnIEPDate 
  , t3.spEdSpecTransport
  , t3.caseManagerName
  , t3.exitedSpEdDate
from dbo.Patient_Data_Imports_Parse_SpEd_Data_File_Summary_Rows_Into_Promised_Services_Core (@clientID, null) as t1
cross apply (
  select top 1 
      t2.spEdProviderCode 
    , t2.spEdLocationCode
    , t2.spEdDisabilityCode1
    , t2.spEdDisabilityCode2 
    , t2.lastEvalDate
    , t2.lastAnnIEPDate
    , t2.nextAnnIEPDate 
    , t2.spEdSpecTransport
    , t2.caseManagerName
    , t2.exitedSpEdDate
 from dbo.Patient_Data_Imports_Parse_SpEd_Data_File_Row_Parse_Svc_Lines_Details_JSON (
   t1.svcLinesDetailsJSON
 ) as t2
) as t3
option(recompile)

/*###########################################################################*/
/*#  Get common SpEd values per patient                                     #*/
/*###########################################################################*/

exec dbo.PRINT_STATUS_MESSAGE 'Get patient specific SpEd data (common to all services)'

/*------------------------------------*/
/* First get a distinct list of       */
/* patID,latestFileID,latestFileRowID */
/* Note: This is the common key       */
/*------------------------------------*/

insert into @spEdDataImportedPatientData (
    patID
  , latestFileID
  , latestFileRowID
)
select 
    t1.patID
  , latestFileID    = max(t1.latestFileID)
  , latestFileRowID = max(t1.latestFileRowID)
from @spEdDataImportedAndCorrected as t1
group by 
  t1.patID
option (recompile)

/*------------------------------------*/
/* Then using this list update        */
/*------------------------------------*/

update t2
set
    t2.latestSpEdDisabilityCode1       = t1.spEdDisabilityCode1
  , t2.latestSpEdDisabilityCode2       = t1.spEdDisabilityCode2
  , t2.latestLastEval                  = t1.lastEvalDate
  , t2.latestLastAnnIEP                = t1.lastAnnIEPDate
  , t2.latestNextAnnIEP                = t1.nextAnnIEPDate
  , t2.latestSpEdSpecialTransportation = t1.spEdSpecTransport
  , t2.latestCaseManagerName           = t1.caseManagerName
  , t2.latestExitedSpEdDate            = t1.exitedSpEdDate

from @spEdDataImportedAndCorrected as t1
join @spEdDataImportedPatientData  as t2 on  ((t2.patID           = t1.patID)
                                         and (t2.latestFileID    = t1.latestFileID)
                                         and (t2.latestFileRowID = t1.latestFileRowID))
option(recompile)

begin transaction
set @tranOpen = 1

/*###########################################################################*/
/*#  Update patient promised service data                                   #*/
/*###########################################################################*/

exec dbo.PRINT_STATUS_MESSAGE 'Updating promised service data'

/*------------------------------------*/
/* Update timestamp                   */
/*------------------------------------*/

set @today = getdate()

/*------------------------------------*/
/* Remove previous data               */
/*------------------------------------*/

exec dbo.PRINT_STATUS_MESSAGE 'Removing previous data'

delete pps
from @spEdDataImportedPatientData   as ipd
join dbo.PATIENTS_Promised_Services as pps on pps.patID = ipd.patID
option(recompile)

/*------------------------------------*/
/* Replace with updated data          */
/*------------------------------------*/

exec dbo.PRINT_STATUS_MESSAGE 'Replacing promised service data'

insert into dbo.PATIENTS_Promised_Services (
    patID
  , spEdServiceCode
  , spEdProviderCode
  , spEdFreqCode
  , spEdLocationCode
  , startDate
  , endDate
  , individualDelivery
  , groupDelivery
  , minsPerFreq
  , fromSpEdDataFiles
  , latestFileRowID
  , doNotReplace
  , created
  , createdBy
  , active
  , numSvcLines
  , hasSvcLinesDetails
  , svcLinesDetailsJSON 
)
select 
    sdi.patID
  , sdi.spEdSvcCode
  , sdi.spEdProviderCode
  , sdi.spEdFreqCode
  , sdi.spEdLocationCode
  , sdi.startDate
  , sdi.endDate
  , individualDelivery = sdi.individualSvc
  , groupDelivery      = sdi.groupSvc
  , minsPerFreq        = sdi.duration
  , fromSpEdDataFiles  = 1
  , sdi.latestFileRowID
  , doNotReplace       = 0
  , created            = @today
  , createdBy          = @userID
  , active             = 1
  , sdi.numSvcLines
  , 1  /*hasSvcLinesDetails */
  , sdi.svcLinesDetailsJSON

from @spEdDataImportedAndCorrected as sdi        

option(recompile)

/*###########################################################################*/
/*#  Update patient common spEd data                                        #*/
/*###########################################################################*/

exec dbo.PRINT_STATUS_MESSAGE 'Updating patient common spEd data'

update pap
set
    pap.spEdLastEvalDate          = ipd.latestLastEval
  , pap.spEdLastAnnualIEPDate     = ipd.latestLastAnnIEP
  , pap.spEdNextAnnualIEPDate     = ipd.latestNextAnnIEP
  , pap.spEdSpecialTransportation = ipd.latestSpEdSpecialTransportation
  , pap.spEdDisability1Code       = ipd.latestSpEdDisabilityCode1
  , pap.spEdDisability2Code       = ipd.latestSpEdDisabilityCode2
  , pap.spEdCaseManagerName       = ipd.latestCaseManagerName
  , pap.spEdExitedSpEdDate        = ipd.latestExitedSpEdDate
  , pap.LAST_UPDATED              = @today

from @spEdDataImportedPatientData as ipd
join dbo.PATIENTS_Patient         as pap on pap.PATIENT_ID = ipd.patID
option(recompile)

/*###########################################################################*/
/*#  Update caseload data                                                   #*/
/*###########################################################################*/

exec dbo.PRINT_STATUS_MESSAGE 'Updating caseload data'

declare @spDetails as varchar(max) = ''
declare @recordID  as bigint = 0

exec dbo.PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_UPDATE_PLAN_INFO_ALL_CORE 
    @userID 
  , @clientID
  , null -- @pracID 
  , null -- @patID
  , null -- @spEdSvcCode
  , 0    -- @updateToNewerPlan 
  , 0    -- @validateRec
  , @spDetails    OUTPUT
  , @recordID     OUTPUT

commit transaction
set @tranOpen = 0

exec dbo.PRINT_STATUS_MESSAGE 'Completed normally'
set @completedNormally = 1
return(0)

end try

/*###########################################################################*/
/*#  Exception handling                                                     #*/
/*###########################################################################*/

begin catch

  /*------------------------------------*/
  /* Rollback if neccessary             */
  /*------------------------------------*/

  if (@tranOpen = 1)
  begin
    ROLLBACK TRANSACTION
	set @tranOpen = 0
  end

  /*------------------------------------*/
  /* Let caller know we had problem     */
  /*------------------------------------*/
  
  set @completedNormally = 0
  
  print ERROR_MESSAGE()  
  exec dbo.PRINT_STATUS_MESSAGE 'Completed with errors'
  exec dbo.PRINT_STATUS_MESSAGE 'Updates not committed'

  return(0)
  
end catch

/*------------------------------------*/
/* Should never get here but          */
/* if we do its not normal            */
/*------------------------------------*/

set @completedNormally = 0
return(0)


END
GO

GRANT EXECUTE ON  [dbo].[Patient_Data_Imports_Parse_And_Update_SpEd_Data] TO [webuser]
GO
