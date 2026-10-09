USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CYBHI_Program_Health_Stats_View') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CYBHI_Program_Health_Stats_View
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[CYBHI_Program_Health_Stats_View] ( 
    @userID     bigint
  , @userGroup  bigint
  , @userRank   int
  , @clientID   bigint
)

/***************************************************************************    
 * CYBHI_Program_Health_Stats_View */    
/**    
 ***************************************************************************/            

returns @recs table (   
    clientID         bigint
  , code             int
  , label            varchar(256)
  , chartType		 tinyint
  , totNum           int
  , totAmt			 money
  , totAmtStr        varchar(100)
  , valuesJSON		 varchar(MAX)   
)
as
begin

/*###########################################################################*/
/*#                    Exit if client not passed                            #*/
/*###########################################################################*/

if (@clientID is null) return

/*###########################################################################*/
/*#                               Init                                      #*/
/*###########################################################################*/

declare @earliestDOS                 as datetime = convert(datetime,'7/1/2022')
declare @endDOS                      as datetime = convert(date,getdate())
declare @startDOS                    as datetime = null
declare @cybhiClient                 as bit      = null

declare @totNumMissingInsurance      as int = 0
declare @totNumMissingAddress        as int = 0
declare @totNumMissingFERPA          as int = 0
declare @totNumPrevReqRqrRev         as int = 0
declare @totNumSPIRosterAudit        as int = 0
declare @totNumBatchRegAudit         as int = 0

declare @numOfPublicInsuranceInfoResponsesToReview as int = 0
declare @numOfPublicInsuranceInfoResponsesAccepted as int = 0
declare @numOfPublicInsuranceInfoResponsesRejected as int = 0

declare @numSvcs        as int   = 0
declare @numPats        as int   = 0
declare @numPracs       as int   = 0
declare @numPatAbsent   as int   = 0
declare @numPracAbsent  as int   = 0

declare @totAmtClaimable               as money = 0
declare @totAmtEnteredNotSub           as money = 0
declare @totAmtWaitingSubWaitingForAdj as money = 0
declare @totAmtPaid                    as money = 0

declare @maxPaidPerSvc  as money = 0
declare @minPaidPerSvc  as money = 0
declare @avgPaidPerSvc  as money = 0
declare @avgPaidPerPat  as money = 0
declare @avgPaidPerPrac as money = 0

declare @avgMinsPerPat             as int   = 0
declare @svcsPaidHistoryJSON       as varchar(max) = '[]'
declare @svcsPaidByGroupJSON       as varchar(max) = '[]'
declare @svcsPaidByPracJSON        as varchar(max) = '[]'
declare @svcsPaidBySvcNameJSON     as varchar(max) = '[]'
declare @svcsProcessingSummaryJSON as varchar(max) = '[]'

declare @pats as table (
    patID                bigint
  , missingInsuranceInfo bit
  , missingAddressInfo   bit
  , missingFerpaConsent  bit
  , missingPGEmails		 bit
  , hasCurrentInfoRequest bit
  , hasPreviousInfoRequestThatRequiredReview bit
)

declare @svcs as table (
    svcRecID                        bigint
  , nameID                          bigint
  , dos                             date
  , patID                           bigint
  , pracID                          bigint
  , groupID		                    bigint
  , amountClaimed                   money
  , amountPaid                      money
  , numMins                         int
  , patAbsent                       bit
  , pracAbsent                      bit
  , svcClaimsHeld                   bit
  , holdCode                        smallint
  , svcClaimsSentToTPA              bit
  , svcClaimsWaitingForAdjudication bit
  , svcClaimsAdjudicated            bit
  , processingRemarkCode            smallint
  , processingRemark                varchar(2000)
)

/*###########################################################################*/
/*#           Get start dos and other client wide cybhi info                #*/
/*###########################################################################*/

set @cybhiClient = 0

select top 1 
    @cybhiClient = isnull(clc.cybhi,0)
  , @startDOS    = isnull(clc.cybhiTpaApprovedOn,@earliestDOS)
from dbo.CLIENTS_Client as clc
where 
  (clc.CLIENT_ID = @clientID)

/*###########################################################################*/
/*#              Exit if client is not CYBHI client                         #*/
/*###########################################################################*/

if (@cybhiClient = 0) return

/*###########################################################################*/
/*#                    Get pats with missing info                           #*/
/*###########################################################################*/

insert into @pats (patID, missingInsuranceInfo, missingAddressInfo, missingFerpaConsent, missingPGEmails, hasCurrentInfoRequest, hasPreviousInfoRequestThatRequiredReview )
select    
    pwmi.patID
  , pwmi.missingInsuranceInfo
  , pwmi.missingAddressInfo   
  , pwmi.missingFerpaConsent
  , pwmi.missingPGEmails
  , pwmi.hasCurrentInfoRequest
  , pwmi.hasPreviousInfoRequestThatRequiredReview
from dbo.Patients_With_Missing_Info_View_Core (    
    @clientID
  , null /* @patID */
  , 1    /* @source 1 = CYBHI only */
  , null /* @missingInsuranceInfo */
  , null /* @missingAddressInfo */ 
  , null /* @missingOrNoFerpaConsent */
  , null /* @missingPGEmails     */
  , null /* @missingMcalParentConsent   */
  , null /*@hasCurrentInfoRequest */
  , null /*@hasCurrentInfoRequestWaitingForReview*/
  , null /* @hasPreviousInfoRequestThatRequiredReview */
  , 1 /* Limit to patients with missing info */
) as pwmi

/*###########################################################################*/
/*#             Compute stats based on pats with missing info               #*/
/*###########################################################################*/

select @totNumMissingInsurance = count(pats.patID) from @pats as pats where (pats.hasPreviousInfoRequestThatRequiredReview = 0) and (pats.missingInsuranceInfo = 1)
select @totNumMissingAddress   = count(pats.patID) from @pats as pats where (pats.hasPreviousInfoRequestThatRequiredReview = 0) and (pats.missingAddressInfo   = 1) 
select @totNumMissingFERPA     = count(pats.patID) from @pats as pats where (pats.hasPreviousInfoRequestThatRequiredReview = 0) and (pats.missingFerpaConsent  = 1)
select @totNumPrevReqRqrRev    = count(pats.patID) from @pats as pats where (pats.hasPreviousInfoRequestThatRequiredReview = 1) 

/*###########################################################################*/
/*#    Compute stats based on insurance info responses waiting for review.  #*/
/*###########################################################################*/

select 
	@numOfPublicInsuranceInfoResponsesToReview = count(t1.id) 
from dbo.PATIENT_INFO_REQUESTS_PUBLIC_INSURANCE_FORM_RESPONSES as t1 
where (
		(t1.clientID = @clientID) 
	and (t1.reviewed = 0)
	and (t1.active = 1)
)

/*select 
	@numOfPublicInsuranceInfoResponsesAccepted = count(t1.id) 
from dbo.PATIENT_INFO_REQUESTS_PUBLIC_INSURANCE_FORM_RESPONSES as t1
where (
		(t1.clientID = @clientID)
	and (t1.reviewed = 1 and t1.accepted = 1)
	and (t1.active = 1)
)

select 
	@numOfPublicInsuranceInfoResponsesRejected = count(t1.id) 
from dbo.PATIENT_INFO_REQUESTS_PUBLIC_INSURANCE_FORM_RESPONSES as t1
where (
		(t1.clientID = @clientID)
	and (t1.reviewed = 1 and t1.accepted = 0)
	and (t1.active = 1)
)
*/

/*###########################################################################*/
/*#        Get and compute stats based on CYBHI provider list               #*/
/*#                                                                         #*/
/*# We pass the generateRosterMode value as 0 because this is called from   #*/
/*# the cybhi dashboard and we need to keep that view partitioned           #*/
/*###########################################################################*/

select @totNumSPIRosterAudit = count(spi.RowNumber) from dbo.CYBHI_PROVIDER_LIST_RPT_CORE (@clientID,0) as spi where (spi.CanExportRow = 0) 

/*###########################################################################*/
/*#        Get and compute stats based on CYBHI patient list                #*/
/*#                                                                         #*/
/*# We pass the generateRosterMode value as 0 because this is called from   #*/
/*# the cybhi dashboard and we need to keep that view partitioned           #*/
/*###########################################################################*/

select @totNumBatchRegAudit = count(batreg.[Record Number]) from dbo.CYBHI_PAT_LIST_RPT_CORE (@clientID, 0) as batreg where (batreg.CanExportRow = 0) 

/*###########################################################################*/
/*#                Get and compute financial and delivery stats             #*/
/*###########################################################################-*/

insert into @svcs (
    svcRecID
  , nameID
  , dos
  , patID
  , pracID
  , groupID
  , amountClaimed
  , amountPaid
  , numMins
  , patAbsent
  , pracAbsent 
  , svcClaimsHeld 
  , holdCode   
  , svcClaimsSentToTPA
  , svcClaimsWaitingForAdjudication
  , svcClaimsAdjudicated
  , processingRemarkCode
  , processingRemark
  
)
select 
    t1.svcRecID
  , t1.nameID
  , t1.dos
  , t1.patID
  , t1.pracID
  , t1.groupID
  , t1.amountClaimed
  , t1.amountPaid
  , t1.numMins
  , t1.patAbsent
  , t1.pracAbsent 
  , svcClaimsHeld                   = t1.svcClaimHeld 
  , holdCode                        = t1.lastHoldCode   
  , svcClaimsSentToTPA              = t1.waitingForAdjudication
  , svcClaimsWaitingForAdjudication = t1.waitingForAdjudication
  , svcClaimsAdjudicated            = t1.adjudicationCompleted
  , t1.processingRemarkCode
  , t1.processingRemark

from dbo.CYBHI_SERVICE_RECORDS_WITH_CLAIM_PROCESSING_DETAILS_VIEW_CORE (
    @clientID
  , null /* group id*/
  , null /* prac id*/
  , null /* pat id */
  , null /* name id */
  , @startDOS 
  , @endDOS
  , null /* paid */
  , null /* @processingRemarkCode */
  , null /*@lastHoldCode */
  ) as t1

/* Calculate total number of cybhi services documented*/

select 
  @numSvcs = count(svcRecID) 
from @svcs
 
/* Calculate total amount claimable */

select
  @totAmtClaimable = sum(t1.amountClaimed)
from @svcs as t1

/* Calculate total amount that we have not transmitted yet for any reason*/

select 
  @totAmtEnteredNotSub = sum(t1.amountClaimed)
from @svcs as t1
where (
    (t1.svcClaimsHeld = 1)   
)

/* Calculate total amount that we are waiting for adjudication on */

select 
  @totAmtWaitingSubWaitingForAdj = sum(t1.amountClaimed)
from @svcs as t1

where (
  (svcClaimsWaitingForAdjudication = 1)  
)

/* Calc total amount paid */

select 
    @totAmtPaid    = sum(t1.amountPaid)
  , @avgPaidPerSvc = avg(t1.amountPaid)
  , @maxPaidPerSvc = max(t1.amountPaid)
  , @minPaidPerSvc = min(t1.amountPaid)
from @svcs as t1
 
/* Get total num of pats */

select 
  @numPats = count(q1.patID)
from
(
  select distinct 
    t1.patID
  from @svcs as t1
) as q1
 
/* Get total num of pracs */

select 
  @numPracs = count(q1.pracID)
from
(
  select distinct
    t1.pracID
  from @svcs as t1
) as q1

/* Calculate avg amts paid */
  
select @avgPaidPerPat  = iif((@numPats = 0),0,(@totAmtPaid / @numPats))
select @avgPaidPerPrac = iif((@numPracs = 0),0,(@totAmtPaid / @numPracs))

/* Calc mins per pat */

select 
  @avgMinsPerPat = avg(t1.numMins) 
from @svcs as t1
where 
  ((t1.patAbsent = 0) and (t1.pracAbsent = 0))

/* Calc absent stats */

select
  @numPatAbsent = count(t1.svcRecID)
from @svcs as t1
where 
  (t1.patAbsent = 1)

select
  @numPracAbsent = count(t1.svcRecID)
from @svcs as t1
where 
  (t1.pracAbsent = 1)

/*###########################################################################*/
/*#                  Generate summary data for amounts                      #*/
/*###########################################################################*/

select @svcsPaidHistoryJSON = convert(varchar(max),(
select
  q2.*
from
(
  select
      q1.*
	, totAmountClaimableRunning = sum(q1.totAmountClaimableForDOS) over(order by q1.dos rows unbounded preceding) 
	, totAmountPaidRunning      = sum(q1.totAmountPaidForDOS)      over(order by q1.dos rows unbounded preceding) 
  from 
  (
    select 
        t1.dos
	  , totAmountClaimableForDOS = sum(t1.amountClaimed)
	  , totAmountPaidForDOS      = sum(t1.amountPaid)
    from @svcs as t1
    group by 
      t1.dos
  ) as q1
) as q2
order by 
  q2.dos
FOR JSON AUTO
))

/*###########################################################################*/
/*#                  Generate summary data for disp groups                  #*/
/*###########################################################################*/

select @svcsPaidByGroupJSON = convert(varchar(max),(
	select
		  q2.groupID
		, q2.dispGroup
		, q2.numSvcs
		, q2.totMins
		, totAmtClaimable = (q2.totAmtClaimable - q2.totAmtPaid)
		, q2.totAmtPaid
	from 
	(
		select 
		      p1.groupID
			, dispGroup = ggd.GROUP_NAME
			, p1.numSvcs
			, p1.totMins
			, p1.totAmtClaimable
			, p1.totAmtPaid
			
		from (
			select 
				  t1.groupID 
				, numSvcs         = count(t1.svcRecID)                
				, totMins         = sum(t1.numMins)
				, totAmtClaimable = sum(t1.amountClaimed)
				, totAmtPaid      = sum(t1.amountPaid)
				
			from @svcs as t1
			group by 
				t1.groupID
		) as p1 
		join dbo.GROUP_Group as ggd on ggd.GROUP_ID = p1.groupID
	) as q2
	order by 
		q2.dispGroup
	FOR JSON AUTO
))


/*###########################################################################*/
/*#                  Generate summary data for pracs                        #*/
/*###########################################################################*/

select @svcsPaidByPracJSON = convert(varchar(max),(
	select
		q2.*
	from 
	(
		select 
		      p1.pracID
			, p1.groupID
			, pracName  = prp.CONCAT_NAME
			, groupName = ggd.GROUP_NAME
			, npi       = isnull(prp.npiNumber, '')
			, tpaID     = isnull(prp.cybhiTpaID,'')
			, p1.numSvcs
			, p1.totMins
			, totAmtClaimable = (p1.totAmtClaimable - p1.totAmtPaid)
			, p1.totAmtPaid
			
		from (
			select 
				  t1.pracID
				, t1.groupID
				, numSvcs         = count(t1.svcRecID)                
				, totMins         = sum(t1.numMins)
				, totAmtClaimable = sum(t1.amountClaimed)
				, totAmtPaid      = sum(t1.amountPaid)
				
			from @svcs as t1
			group by 
				 t1.pracID
				,t1.groupID
		) as p1 
		join dbo.PRACTITIONER_Practitioner as prp on prp.PRACTITIONER_ID = p1.pracID
		join dbo.GROUP_Group               as ggd on ggd.GROUP_ID = p1.groupID

	) as q2
	order by 
		 q2.groupName
		,q2.pracName
	FOR JSON AUTO
))

/*###########################################################################*/
/*#                  Generate summary data for svc name                     #*/
/*###########################################################################*/

select @svcsPaidBySvcNameJSON = convert(varchar(max),(
	select
		q2.*
	from 
	(
		select 
		      p1.nameID
			, svcName = ccn.NAME
			, p1.numSvcs
			, p1.totMins
			, totAmtClaimable = (p1.totAmtClaimable - p1.totAmtPaid)
			, p1.totAmtPaid
			
		from (
			select 
				  t1.nameID				
				, numSvcs         = count(t1.svcRecID)                
				, totMins         = sum(t1.numMins)
				, totAmtClaimable = sum(t1.amountClaimed)
				, totAmtPaid      = sum(t1.amountPaid)				
			from @svcs as t1
			group by 
				t1.nameID
		) as p1 
		join dbo.CLAIM_CYBHI_Names as ccn on ccn.CYBHI_NAME_ID = p1.nameID

	) as q2
	order by 
		q2.svcName		
	FOR JSON AUTO
))


/*###########################################################################*/
/*#            Generate summary data for processing status                  #*/
/*###########################################################################*/

select @svcsProcessingSummaryJSON = convert(varchar(max),(
	select
		q2.*
	from 
	(
		select 			 
		      p1.processingRemarkCode
			, p1.processingRemark
			, p1.holdCode			
			, p1.numSvcs
			, p1.totMins
			, p1.totAmtClaimable
			
		from (
			select 
				  t1.processingRemarkCode
				, t1.processingRemark
				, t1.holdCode
				, numSvcs         = count(t1.svcRecID)                
				, totMins         = sum(t1.numMins)
				, totAmtClaimable = sum(t1.amountClaimed)
			    
			from @svcs as t1
			
			group by 
				  t1.processingRemarkCode
				, t1.processingRemark
				, t1.holdCode
		) as p1 
		
	) as q2
	order by 
		  q2.processingRemarkCode
		, q2.processingRemark
		, q2.holdCode
	FOR JSON AUTO
))


/*###########################################################################*/
/*#                    Insert and return stats                              #*/
/*#                                                                         #*/
/*#           Note: Keep codes in synch with middlware                      #*/
/*###########################################################################*/

/*

Chart Type

1 = Big totNum
2 = Big totAmt 
3 = Dial totNum
4 = Dial totAmt
5 = Line jsonData
6 = Table jsonData

*/

insert into @recs (
  clientID
, code
, label
, chartType
, totNum
, totAmt
, totAmtStr
, valuesJSON
) 
values 
  ( @clientID, 2000, 'Missing Insurance',1
  , @totNumMissingInsurance, 0,'','[]')

, (@clientID, 2010, 'Missing Address',1
  , @totNumMissingAddress, 0,'','[]')

, (@clientID, 2020, 'Missing FERPA Consent',1
   , @totNumMissingFERPA, 0,'','[]')

, (@clientID, 2030, 'Missing Info Followup',1
   , @totNumPrevReqRqrRev, 0,'','[]')
   
, (@clientID, 2040, 'Insurance Submissions',1
  , @numOfPublicInsuranceInfoResponsesToReview, 0,'','[]')

/*, (@clientID, 2050, 'Insurance Info Accepted',1
  , @numOfPublicInsuranceInfoResponsesAccepted, 0,'','[]')

, (@clientID, 2060, 'Insurance Info Rejected',1
  , @numOfPublicInsuranceInfoResponsesRejected, 0,'','[]')
*/  
, (@clientID, 5000, 'SPI Roster Audit',1
   , @totNumSPIRosterAudit, 0,'','[]')

, (@clientID, 5010, 'Batch Registration Audit', 1
  , @totNumBatchRegAudit, 0,'','[]')

, (@clientID, 6000, 'Services Documented',1
   , @numSvcs,0,'','[]')

, (@clientID, 6010, 'Num Of Clients',1
 , @numPats, 0,'','[]')

, (@clientID, 6020, 'Num Of Practitioners',1
  , @numPracs,			0,	'', '[]')

, (@clientID, 6030, 'Avg Mins Per Client', 1	
  , @avgMinsPerPat,	0, '','[]')

, (@clientID, 6040, 'Practitioners Absent', 1	
  , @numPracAbsent,	0, '','[]')

, (@clientID, 6050, 'Clients Absent', 1	
  , @numPatAbsent,	0, '','[]')

, (@clientID, 7010, 'Avg $ Per Client',	4
   , 0,@avgPaidPerPat, dbo.RPT_ROUND_FMT(@avgPaidPerPat),'[]')

, (@clientID, 7020, 'Avg $ Per Practitioner',4
  , 0, @avgPaidPerPrac, dbo.RPT_ROUND_FMT(@avgPaidPerPrac), '[]')

, (@clientID, 9000, 'Services Paid By DOS',5
  , 0,0,'',@svcsPaidHistoryJSON)

, (@clientID, 9010, 'Services Paid By Group',6
  , 0,0,'',@svcsPaidByGroupJSON)

, (@clientID, 9020, 'Services Paid By Practitioner',6
  , 0,0,'',@svcsPaidByPracJSON)

, (@clientID, 9030, 'Services Paid By Service Name',6
  , 0,0,'',@svcsPaidBySvcNameJSON)

, (@clientID, 9040, 'Service Processing Summary',6
  , 0,0,'',@svcsProcessingSummaryJSON)

return

end
     
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CYBHI_Program_Health_Stats_View] TO [webuser]
GO

