USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTITIONER_CASELOAD_OR_PATIENT_GROUP_MEMBERS_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PRACTITIONER_CASELOAD_OR_PATIENT_GROUP_MEMBERS_VIEW_CORE
GO

/*###########################################################################
 *#                                                                         #
 *#             !!!!!!!!!!!!!!!! NOTICE !!!!!!!!!!!!!!!!!!                  #
 *#                                                                         #
 *# The value of planType is NOT our standard values for planType           #
 *#                                                                         #
 *# In this context.....                                                    #
 *#                                                                         #
 *# 1 = IEP or IFSP, 2 = No Plan, 3 = CYBHI                                 #
 *#                                                                         #
 *# Everywhere else                                                         #
 *#                                                                         #
 *#  1 = IFSP, 2 = IEP, 3 = No Plan, 4 = CYBHI                              #
 *###########################################################################*/

/*-------------------------------
 * Object Definition
 *------------------------------*/


CREATE FUNCTION [dbo].[PRACTITIONER_CASELOAD_OR_PATIENT_GROUP_MEMBERS_VIEW_CORE] (
   @userID                 BIGINT    
 , @userGroup              INT
 , @userRank               INT
 , @clientID               BIGINT
 , @pracID                 BIGINT
 , @fromWhatPracPatSource  INT
 , @pratPatGroupID         BIGINT
 , @term                   VARCHAR(500)
 , @iep                    BIT
 , @nameID                 BIGINT
 , @refDate                DATE
 , @recID                  INT
)

returns @recs table (
  id bigint
, name nvarchar(256)
, dob datetime
, dobStr varchar(50)
, siteName nvarchar(256)
, minsIndStr varchar(5)
, minsGrpStr varchar(5)
, minsAnnStr varchar(5)
, startDateTmtSvcsStr varchar(256)
, planTypeStr varchar(5)
, minsInd int
, minsGrp int
, minsAnn int
, startDateTmtSvcs date
, planType int
, weekdaysjson varchar(max)
, email nvarchar (256)
, phone  nvarchar(50)
, orpDocID          bigint
, promisedSvcCode   int
, planStartDate     date
, planEndDate       date
, ytdNumMinsStr varchar(5)
, mtdNumMinsStr varchar(5)
, ytdNumMins int
, mtdNumMins int
, ytdNumSvcsStr varchar(5)
, mtdNumSvcsStr varchar(5)
, ytdNumSvcs int
, mtdNumSvcs int
, ytdDosMinStr varchar(50)
, ytdDosMaxStr varchar(50)
, ytdDosMin date
, ytdDosMax date
, mtdDosMinStr varchar(50)
, mtdDosMaxStr varchar(50)
, mtdDosMin date
, mtdDosMax date

-- expected services related columns
, planStartDateStr  varchar(50)
, planStartDateStrYMD  varchar(50)
, planEndDateStr    varchar(50)
, planEndDateStrYMD    varchar(50)
, numMinsExpected   int
, numMinsApplicable int
, numMinsDiff       int
, pctExpectedApplicableStr varchar(50)
, promisedSvcID		bigint
, promisedSvcName	varchar(256)
, frequencyCode		int
, frequencyName     varchar(256)
, orpDocName        varchar(256)
, planTypeName	    varchar(256)
) 
  
as
begin

declare @pracGroupServiceClassNameID as bigint
declare @svcTypeID                   as int
declare @svcSubTypeID                as int
declare @startDateYtd                as date
declare @endDateYtd                  as date
declare @startDateMtd                as date
declare @endDateMtd                  as date
declare @today                       as date = convert(date,getdate())

declare @pracCaseloadOrGroupMembers as table (
    PATIENT_ID                   bigint
  , expectedMinsInd		         int
  , expectedMinsGrp		         int
  , expectedMinsSvcTmtAnn        int
  , startDateTmtSvcs	         date
  , planType					 int
  , daysOfWeekSvcTmtProvidedJSON varchar(max)
  , orpDocID					 bigint
  , promisedSvcCode              int
  , promisedSvcStartDate		 date
  , promisedSvcEndDate			 date
  UNIQUE CLUSTERED (
   PATIENT_ID
  )
)

declare @patientData table (
    id  bigint
  , name nvarchar(200)
  , dob datetime
  , dobStr varchar(50)
  , siteName nvarchar(100)
  , minsIndStr	 varchar(5)
  , minsGrpStr	 varchar(5)
  , minsAnnStr	 varchar(15)
  , startDateTmtSvcsStr varchar(256)
  , planTypeStr  varchar(15)
  , minsInd		 int
  , minsGrp		 int
  , minsAnn		 int
  , startDateTmtSvcs    date
  , planType	 int
  , weekdaysjson varchar(max)
  , email nvarchar (256)
  , phone  nvarchar(50)
  , orpDocID bigint
  , promisedSvcCode int
  , promisedSvcStartDate date
  , promisedSvcEndDate	 date
    
  UNIQUE CLUSTERED (
   id
  )
)

declare @pracData table (
	id bigint,
	groupSvcClassNameID bigint
) 


/******************************************************************************
 * Populate Prac Data
 ******************************************************************************/

insert into @pracData (id, groupSvcClassNameID)
select 
	id = @pracID,
	groupSvcClassNameID   = png.GROUP_SERVICE_CLASS_NAME_ID
  from dbo.PRACTITIONER_Client           as pc
  join dbo.PRACTITIONER_Practitioner     as pp on pp.PRACTITIONER_ID  = pc.PRACTITIONER_ID
  join dbo.PRACTITIONER_GROUPS           as pg on  pg.PRACTITIONER_ID = pp.PRACTITIONER_ID
                                               and pg.GROUP_TYPE in (1,2)

  join dbo.GROUP_GROUP_SERVICE_CLASS_PARTITIONS_NAMES_GROUPS as png on  png.GROUP_SERVICE_CLASS_PARTITION_ID = 100
                                                                    and png.GROUP_SERVICE_CLASS_NAME_ID is not null
                                                                    and png.GROUP_ID = pg.GROUP_ID
  where (pc.CLIENT_ID = @clientID and pc.PRACTITIONER_ID = @pracID)

/******************************************************************************
 * If service data is passed, retrieve data we will need to calculate
 * mtd and ytd compliance totals
 ******************************************************************************/

if ((@nameID is not null) and (@iep is not null) and (@refDate is not null))
begin

  /******************************************************************************
   * Get class of group and service
   ******************************************************************************/

  select top 1 
      @pracGroupServiceClassNameID = GROUP_SERVICE_CLASS_NAME_ID
    , @svcTypeID                   = SERVICE_TYPE_ID
    , @svcSubTypeID                = SERVICE_SUB_TYPE_1_ID  
  from dbo.CLAIM_PROCEDURES_GROUPS_SERVICE_CLASS_DATA()
  where (
        (GROUP_SERVICE_CLASS_PARTITION_ID = 1)  /* Service compliance reporting */
    and (SERVICE_NAME_ID = @nameID) 
    and (IEP_OR_IFSP     = @iep)
  )

  /******************************************************************************
   * Get Dates
   ******************************************************************************/

  select top 1 
     @startDateYtd = FY_START
   , @endDateYtd   = FY_END
  from dbo.COMPANY_FISCAL_YEARS 
  where 
    (@refDate between FY_START and FY_END)

  set @startDateMtd =  convert ( date,dbo.DATE_MONTH_START_END ( @refDate,0 ) )
  set @endDateMtd   =  convert ( date,dbo.DATE_MONTH_START_END ( @refDate,1 ) )

end

/******************************************************************************
 * Get practitioner caseload or group members
 ******************************************************************************/

if (@fromWhatPracPatSource = 1)
begin  

  insert into @pracCaseloadOrGroupMembers
  
  select  
     ppc.patID as PATIENT_ID
   , ppc.expectedMinsInd
   , ppc.expectedMinsGrp
   , ppc.expectedMinsSvcTmtAnn
   , ppc.startDateTmtSvcs
   , ppc.planType
   , ppc.daysOfWeekSvcTmtProvidedJSON
   , iif(ppc.planType = 2, ppcod.orpDocID, null)	   -- only select this column if plan type is "Other"
   , iif(ppc.planType = 1, ppcps.spEdSvcCode , null)   -- only select this column if plan type is IEP/IFSP (if not, we will set it later in this module)
   , iif(ppc.planType = 1, ppcps.startDate	 , null)   -- only select this column if plan type is IEP/IFSP (if not, we will set it later in this module)
   , iif(ppc.planType = 1, ppcps.endDate	 , null)   -- only select this column if plan type is IEP/IFSP (if not, we will set it later in this module)
   from dbo.PRACTITIONER_PATIENT_CASELOAD as ppc
   left join dbo.PRACTITIONER_PATIENT_CASELOAD_PROMISED_SERVICES as ppcps on ppcps.caseloadEntryID = ppc.id
   left join dbo.PRACTITIONER_PATIENT_CASELOAD_ORP_DOCUMENTS as ppcod on ppcod.caseloadEntryID = ppc.id

   where
        (ppc.clientID = @clientID)
    and (ppc.pracID   = @pracID)
	and ((@recID is null) or (ppc.patID = @recID))
end

if (@fromWhatPracPatSource= 2)
begin
 
 insert into @pracCaseloadOrGroupMembers
 
  select 
     ppc.patID as PATIENT_ID
   , ppc.expectedMinsInd
   , ppc.expectedMinsGrp
   , ppc.expectedMinsSvcTmtAnn
   , ppc.startDateTmtSvcs
   , ppc.planType
   , ppc.daysOfWeekSvcTmtProvidedJSON
   , iif(ppc.planType = 2, ppcod.orpDocID, null)	   -- only select this column if plan type is "Other"
   , iif(ppc.planType = 1, ppcps.spEdSvcCode , null)   -- only select this column if plan type is IEP/IFSP (if not, we will set it later in this module)
   , iif(ppc.planType = 1, ppcps.startDate	 , null)   -- only select this column if plan type is IEP/IFSP (if not, we will set it later in this module)
   , iif(ppc.planType = 1, ppcps.endDate	 , null)   -- only select this column if plan type is IEP/IFSP (if not, we will set it later in this module)

  from dbo.PRACTITIONER_PATIENT_GROUP              as ppg
  join dbo.PRACTITIONER_PATIENT_GROUP_MEMBER       as ppgm  on  ppgm.pracPatGroupID = ppg.id
  join dbo.PRACTITIONER_PATIENT_CASELOAD           as ppc   on  ppc.patID           = ppgm.patID 
  left join dbo.PRACTITIONER_PATIENT_CASELOAD_PROMISED_SERVICES as ppcps on ppcps.caseloadEntryID = ppc.id
  left join dbo.PRACTITIONER_PATIENT_CASELOAD_ORP_DOCUMENTS as ppcod on ppcod.caseloadEntryID = ppc.id

  where (
        (ppg.clientID = @clientID)
    and (ppg.pracID   = @pracID)
    and (ppg.id       = @pratPatGroupID)
    and (ppc.clientID = @clientID)
    and (ppc.pracID   = @pracID)
	and ((@recID is null) or (ppc.patID = @recID))
  )
end

/******************************************************************************
 * Get common patient data
 ******************************************************************************/

insert into @patientData
select
    pap.PATIENT_ID                      as id
  , pap.CONCAT_NAME                     as name
  , pap.DATE_OF_BIRTH                   as dob
  , dbo.RPT_DATE_FMT(pap.DATE_OF_BIRTH) as dobStr
  , psvc.SITE_NAME                      as siteName

  , convert(varchar(5),isnull(ppc.expectedMinsInd,'')) as minsIndStr
  , convert(varchar(5),isnull(ppc.expectedMinsGrp,'')) as minsGrpStr
  , convert(varchar(5),isnull(ppc.expectedMinsSvcTmtAnn,'')) as minsAnnStr
  , convert(varchar, ppc.startDateTmtSvcs, 23) as startDateTmtSvcsStr
  , convert(varchar(5),isnull(ppc.planType,'')) as planTypeStr
  , ppc.expectedMinsInd                        as minsInd
  , ppc.expectedMinsGrp                        as minsGrp
  , ppc.expectedMinsSvcTmtAnn                  as minsAnn
  , ppc.startDateTmtSvcs                       as startDateTmtSvcs
  , ppc.planType                               as planType
  , ppc.daysOfWeekSvcTmtProvidedJSON			  as weekdaysjson
  , [email] = ISNULL(pat_email.Email, N'')
  , [phone] = ISNULL(pat_phone.Phone, N'')
  , ppc.orpDocID
  , ppc.promisedSvcCode
  , ppc.promisedSvcStartDate
  , ppc.promisedSvcEndDate

from @pracCaseloadOrGroupMembers                 as ppc
join dbo.PATIENTS_PATIENT                        as pap   on  pap.PATIENT_ID   = ppc.PATIENT_ID
join dbo.PATIENTS_SITES_VIEW_CURRENT (@clientID) as psvc  on  psvc.PATIENT_ID  = ppc.PATIENT_ID


OUTER APPLY (SELECT top 1 pat_e.[Email] FROM dbo.[PATIENTS_Email] as pat_e WHERE pat_e.[PATIENT_ID] = pap.PATIENT_ID AND pat_e.ACTIVE = 1) as pat_email

OUTER APPLY (SELECT top 1 pat_ph.[Phone] FROM dbo.[PATIENTS_Phone] as pat_ph WHERE pat_ph.[PATIENT_ID] = pap.PATIENT_ID AND pat_ph.ACTIVE = 1) as pat_phone


where (
        (1=1)
    and ((@term is null) or (pap.CONCAT_NAME like (isnull(@term,'') + '%')))
)

/******************************************************************************
 * If we are calculating mtd and ytd compliance totals, calculate them and
 * add them to the output
 ******************************************************************************/

if ((@nameID is not null) and (@iep is not null) and (@refDate is not null))
begin

insert into @recs
select
    pd.*     
  , convert(varchar(5),isnull(ytd.TOT_MINS_PRESENT,''))      as ytdNumMinsStr
  , convert(varchar(5),isnull(mtd.TOT_MINS_PRESENT,''))      as mtdNumMinsStr
  , ytd.TOT_MINS_PRESENT                                     as ytdNumMins
  , mtd.TOT_MINS_PRESENT                                     as mtdNumMins
    
  , convert(varchar(5),isnull(ytd.NUM_SVCS_PRESENT,''))      as ytdNumSvcsStr
  , convert(varchar(5),isnull(mtd.NUM_SVCS_PRESENT,''))      as mtdNumSvcsStr
  , ytd.NUM_SVCS_PRESENT                                     as ytdNumSvcs
  , mtd.NUM_SVCS_PRESENT                                     as mtdNumSvcs
    
  , dbo.RPT_DATE_FMT(ytd.MIN_DOS)                        as ytdDosMinStr
  , dbo.RPT_DATE_FMT(ytd.MAX_DOS)                        as ytdDosMaxStr  
  , ytd.MIN_DOS                                          as ytdDosMin
  , ytd.MAX_DOS                                          as ytdDosMax
    
  , dbo.RPT_DATE_FMT(mtd.MIN_DOS)                        as mtdDosMinStr
  , dbo.RPT_DATE_FMT(mtd.MAX_DOS)                        as mtdDosMaxStr  
  , mtd.MIN_DOS                                           as mtdDosMin
  , mtd.MAX_DOS                                          as mtdDosMax
    
  , null												 as planStartDateStr  
  , null												 as planStartDateStrYMD
  , null												 as planEndDateStr   
  , null												 as planEndDateStrYMD  
  , null                                                 as numMinsExpected   
  , null                                                 as numMinsApplicable 
  , null                                                 as numMinsDiff       
  , null                                                 as pctExpectedApplicableStr 
  , null												 as promisedSvcID
  , null												 as promisedSvcName	
  , null												 as frequencyCode
  , null												 as frequencyName
  , null												 as orpDocName
  , null											     as planTypeName
from @patientData as pd

outer apply (

  select top 1
  
    TOT_MINS_PRESENT
  , NUM_SVCS_PRESENT
  , MIN_DOS
  , MAX_DOS
  
  from dbo.SERVICES_RENDERED_COMPLIANCE_STATS_BY_PRAC_GROUP_FOR_PATIENT_CORE (
   
     null
   , null
   , null
   , @clientID
   , pd.id
   , @startDateYtd
   , @endDateYtd
   , @pracGroupServiceClassNameID
  )
  where (
        (IEP_OR_IFSP         = @iep)
    and (SERVICE_TYPE_ID     = @svcTypeID)
    and (SERVICE_SUB_TYPE_ID = @svcSubTypeID)
  )
) as ytd


outer apply (

  select top 1
  
    TOT_MINS_PRESENT
  , NUM_SVCS_PRESENT
  , MIN_DOS
  , MAX_DOS
  
  from dbo.SERVICES_RENDERED_COMPLIANCE_STATS_BY_PRAC_GROUP_FOR_PATIENT_CORE (
   
     null
   , null
   , null
   , @clientID
   , pd.id
   , @startDateMtd
   , @endDateMtd
   , @pracGroupServiceClassNameID
  )
  where (
        (IEP_OR_IFSP         = @iep)
    and (SERVICE_TYPE_ID     = @svcTypeID)
    and (SERVICE_SUB_TYPE_ID = @svcSubTypeID)
  )
) as mtd

end

/******************************************************************************
 * If we are not calculating compliance totals just return the patient data
 * and blanks for the compliance data
 ******************************************************************************/

else
begin

  insert into @recs
  select
      pd.*  
    , ''      as ytdNumMinsStr
    , ''      as mtdNumMinsStr
    , null    as ytdNumMins
    , null    as mtdNumMins
    , ''      as ytdNumSvcsStr
    , ''      as mtdNumSvcsStr
    , null    as ytdNumSvcs
    , null    as mtdNumSvcs
    , ''      as ytdDosMinStr
    , ''      as ytdDosMaxStr  
    , null    as ytdDosMin
    , null    as ytdDosMax  
    , ''      as mtdDosMinStr
    , ''      as mtdDosMaxStr  
    , null    as mtdDosMin
    , null    as mtdDosMax
	  
    , null												   as planStartDateStr  
	, null												   as planStartDateStrYMD
    , null												   as planEndDateStr   
    , null												   as planEndDateStrYMD    	 
    , null                                                 as numMinsExpected   
    , null                                                 as numMinsApplicable 
    , null                                                 as numMinsDiff       
    , null                                                 as pctExpectedApplicableStr 
	, null												   as promisedSvcID
	, null												   as promisedSvcName
	, null												   as frequencyCode		
	, null												   as frequencyName
	, null												   as orpDocName
	, null												   as planTypeName

  from @patientData as pd

end

/******************************************************************************
 * Get missing services details
 ******************************************************************************/

update rr
Set	 
	  planStartDateStr         = dbo.RPT_DATE_FMT(rr.planStartDate)           
	, planStartDateStrYMD      = dbo.RPT_DATE_FMT_YYYY_MM_DD(rr.planStartDate)
	, planEndDateStr           = dbo.RPT_DATE_FMT(rr.planEndDate)             
	, planEndDateStrYMD        = dbo.RPT_DATE_FMT_YYYY_MM_DD(rr.planEndDate)  
	, numMinsExpected  		   = rmt.totMinsExpected  		  
	, numMinsApplicable		   = rmt.totMinsApplicable		  
	, numMinsDiff      		   = rmt.totMinsDiff      		  
	, pctExpectedApplicableStr = convert(varchar(50), dbo.CALC_PERCENTAGE(rmt.totMinsApplicable, rmt.totMinsExpected, 1 , 1 , 0)) + '%'
	, promisedSvcID			   = pps.id
	, promisedSvcName		   = isnull(convert(varchar, ss.codeValue) + ' ' + ss.[name], '')
	, frequencyCode            = ssf.codeValue
	, frequencyName            = ssf.[name]
	, planTypeName			   = iif(rr.planType = 1, 'IEP / IFSP', 'Other (IHP, 504, Counseling, etc.)')
	, minsAnn				   = pps.minsPerFreq
from @recs as rr
left join dbo.PATIENTS_Promised_Services as pps on pps.spEdServiceCode = rr.promisedSvcCode and pps.startDate = rr.planStartDate and pps.endDate = rr.planEndDate
left join dbo.SpEd_Service as ss on ss.codeValue = rr.promisedSvcCode
left join dbo.SpEd_Service_Frequency as ssf on ssf.codeValue = pps.spEdFreqCode
outer apply @pracData as pd
outer apply ( 
  select 
      totMinsExpected   = sum(pdc1.totalMinutesExpected)
    , totMinsApplicable = sum(pdc1.totalMinutesSatisfied)
    , totMinsDiff       = sum(pdc1.diffMinutesExpectedSatified)
  
  /* Realtime compliance by CALPADS code to date */
  
  from dbo.PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_SPED_SERVICES_PLAN_SUMMARY_VIEW_DATA_CORE (
     @clientID                   
    , rr.id -- patID
	, null -- pracID
    , rr.promisedSvcCode
	, null
	, null
    , null -- freqCode
	, null -- mins per freq
	, null -- mins per freq assigned
	, rr.planStartDate
    , @today /*rr.planEndDate*/
    , null   /*@patHasBIC*/
    , null   /*@patHasSSID*/
    , null   /*@billableSvcs*/
    , 1      /*@limitCalcToEndDate*/ 
    , 0      /*@calcPctExpectedSatisfied */
    , 0      /*@calcPotLostReimbursement */
	, 0
	, 1 
	, 0 /*@usePpsSvcTermsProvided*/
	, 1 /* Pat absent counts as mins satisfied */
	, 0 /* exit without calc */
  ) as pdc1

  group by 
      pdc1.clientID
	, pdc1.patID
) as rmt
where rr.planType = 1

update rr
Set	 
	  planStartDate            = odd.planStartDate											
	, planStartDateStr         = dbo.RPT_DATE_FMT(odd.planStartDate)           				
	, planStartDateStrYMD      = dbo.RPT_DATE_FMT_YYYY_MM_DD(odd.planStartDate)				
	, planEndDate              = odd.planEndDate											
	, planEndDateStr           = dbo.RPT_DATE_FMT(odd.planEndDate)             				 
	, planEndDateStrYMD        = dbo.RPT_DATE_FMT_YYYY_MM_DD(odd.planEndDate)  				
	, orpDocName			   = odd.ORP_DOCUMENT_STANDARD_SELECTION_NAME					
	, frequencyCode            = odd.frequency												
	, frequencyName			   = odd.frequencyName	
	, planTypeName			   = iif(rr.planType = 1, 'IEP / IFSP', 'Other (IHP, 504, Counseling, etc.)')
	, minsAnn				   = odd.projectedMinutes
from @recs as rr																			
outer apply dbo.ORP_DOCUMENTS_DATA_CORE(@clientID, null, null, null, null, isnull(rr.orpDocID, -1), null) as odd
where rr.planType = 2

/******************************************************************************
 * Get ORP Document details
 ******************************************************************************/

return

end
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[PRACTITIONER_CASELOAD_OR_PATIENT_GROUP_MEMBERS_VIEW_CORE] TO [webuser]
GO