USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_RECORDS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SERVICE_RECORDS_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[SERVICE_RECORDS_VIEW] (
    @userID                BIGINT
  , @userGroup             INT
  , @userRank              INT
  , @recID                 bigint
  , @clientID              bigint
  , @groupSvcClassNameID   bigint
  , @pracID                bigint
  , @patID                 bigint
  , @svcTypeID             bigint
  , @reference             VARCHAR(500)
  , @startDate             DATETIME
  , @endDate               DATETIME
  , @startEntryDate        DATETIME
  , @endEntryDate          DATETIME
  , @active                BIT
  , @canEdit               BIT
  , @applyEditDelViewRules BIT )

returns table
as

/***************************************************************************
 * SERVICE_RECORDS_VIEW */
/**
 * View services records
 *
 * @param  userID          User id of who is viewing services
 * @param  userGroup       1 = Client, 2 = SBSC (from users db)
 * @param  userRank        Users role ranking
 * @param  recID           Service record, record id (will only return one record)
 * @param  clientID        Client ID
 * @param  pracID          Practitioner ID
 * @param  patID           PatientID
 * @param  recUserID       User id of user who created record
 * @param  reference       Source document reference
 * @param  canEdit         1 = Return all records that can be edited
 * @param  startDate       Start date of service
 * @param  endDate         End date of service
 * @return                 Service records
 ***************************************************************************/

return
(

with
cte_p1
as
(

select
   sr.id
 , sr.reference                                    as reference
 , sr.CLIENT_NAME                                  as clientName
 , sr.PR_CONCAT_NAME                               as pracName
 , sr.PA_CONCAT_NAME                               as patName
 , sr.PA_DOB                                       as patDOBVal
 , sr.patDOBStr
 , sr.PA_CSIS                                      as patCSIS
 , sr.dos
 , sr.dosStr
 , sr.dosStrYMD
 , sr.isIFSPorIEP
 , sr.SVC_NAME                               as svcName
 , sr.startTime                              as startTimeVal
 , sr.startTimeStr
 , sr.startTimeStrHHMM
 , sr.numMins
 , sr.tripsMiles
 , sr.minutesStartEndMiles
 , sr.trip1Start
 , sr.trip1End
 , sr.trip2Start
 , sr.trip2End
 , sr.trip3Start
 , sr.trip3End
 , sr.trip4Start
 , sr.trip4End
 , ISNULL(sr.patAbsent, 0)      as patAbsent
 , isnull(sr.pracAbsent,    0)  as pracAbsent
 , isnull(sr.makeupSession, 0)  as makeupSession
 , sr.attendanceStatusSelectionID
 , sr.attendanceStatusSelectionName 
 , sr.notes
 , sr.userID
 , sr.created
 , ISNULL(sr.SRL_LOGGED_ON,sr.created)  AS lastModified
 , ISNULL(sr.SRL_USER_ID,0)             AS lastModifiedBy
 , sr.canEdit
 , sr.svcType
 , sr.planType
 , sr.clientID
 , ISNULL(sr.siteID,0) as siteID
 , sr.pracID
 , ISNULL(sr.groupID,0) as groupID
 , sr.patID
 , sr.nameID
 , isnull(sr.hasSvcDetFlags,0) as hasSvcDetFlags
 , sr.svcDetFlag1
 , sr.svcDetFlag2
 , sr.svcDetFlag3
 , sr.svcDetFlag4
 , sr.claimID1
 , sr.claimID2
 , sr.claimID3
 , sr.claimID4
 , isnull(sr.hasOrpDocID,0) as hasOrpDocID
 , sr.orpDocID
 , orpDocLabel = isnull(sr.orpDocLabel,'')
 , sr.orpRequired
 , sr.endTimeStr
 , sr.endTimeVal
 , sr.isIFSPorIEPStr
 , sr.svcSubType1
 , viaTelehealth
 , viaTelehealthStr
   /* TODO: Refactor to use a lookup table */
 , planTypeSelectionName = case 
      when sr.planType = 1 then 'IEP / IFSP'
      when sr.planType = 2 then 'IEP / IFSP'
	  when sr.planType = 3 then 'Other (IHP, 504, Counseling, etc.)'
	  when sr.planType = 4 then 'CYBHI'
	  when sr.planType = 5 then 'RU Health'
	  else 'Unknown' 
   end
 , sr.pracGrpSvcClsNameID
 , sr.pracGrpSvcClsName
 , sr.groupName
 , sr.entryType
 , sr.entryTypeName
 , sr.rmtsMomentVal
 , sr.rmtsMomentStr
 , sr.svcNotesFormBuilderQuestionsJSON
 , sr.svcNotesFormBuilderAnswersJSON
 , sr.svcNotesFormBuilderText
 , sr.svcNotesFormBuilderTextAndNotes
 , sr.svcNotesPrivateFormBuilderText
 , sr.hasPatientGoalTrackingData
 , sr.patientGoalProgressJSON
 , sr.svcJournalRelated
 , sr.svcJournalID
 , sr.calPadsCodeValueStr
 , sr.minsSatisfied
 , sr.renderingPracSig 
 , sr.reviewingPracSig 
 , sr.SR_ENTERED_BY_USER_LAST_FIRST as enteredByUserLastFirst
 , sr.SR_ENTERED_BY_PCAL_STAFF      as enteredByPcalStaff
 , sr.SR_ENTERED_BY_PRAC            as enteredByPrac
 , sr.SR_ENTERED_BY_DIST_STAFF      as enteredByDistStaff
 , sr.nameIDAltModality
 , sr.svcNameWithoutInPersonOrTelehealthText
 , sr.entryTypeIsSvcJournal
 , sr.entryTypeIsSvcJournalPatAbsent
 , sr.svcNameListDataSourceID
 , sr.svcNameListDataSourceName
 , sr.hasFillablePdfSelections
 , sr.fillablePdfSelectionsJSON
 , sr.fillablePdfAnswersJSON

from dbo.SERVICE_RECORDS_VIEW_CORE (
    @userID
  , @userGroup
  , @userRank
  , @clientID
  , @groupSvcClassNameID
  , @pracID
  , @patID
  , @svcTypeID
  , @startDate
  , @endDate
  , @startEntryDate
  , @endEntryDate
  , @reference
  , @canEdit
  , @applyEditDelViewRules
  , @recID) as sr
)
,
cte_p2
as
(
 select
   p1.*
 , case p1.svcType when dbo.CONST_SERVICES_TRANSPORT() then tripsMiles else CONVERT(VARCHAR(20), numMins) end as [numMins_tripsMiles]
 , cfq2.*
 , rmr2.WhoWereYouWith
 , rmr2.WhatWereYouDoing
 , RmtsAuditReqID  = rmr2.id
 , rmr2.svcrecIsAutoMatched

 from cte_p1 as p1

 cross apply (
   select top 1
       [quarterID]        = cfq1.ID
	 , [quarter]          = QTR_DEFINITION
	 , [quarterStartDate] = cfq1.QTR_END
	 , [quarterEndDate]   = cfq1.QTR_END
   from dbo.COMPANY_FISCAL_QUARTERS as cfq1
   where
     (p1.dos between cfq1.QTR_START and cfq1.QTR_END)
 )  as cfq2

 outer apply (
   select top 1
     rmr1.*
   from dbo.RMTS_Moments  as rmr1 
   where rmr1.svcRecID = p1.id
 ) as rmr2

)

/*-------------------------------
 * Retrieve records
 *------------------------------*/

select top (dbo.CONST_MAX_ROWS())
  p2.*
from cte_p2 as p2

)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[SERVICE_RECORDS_VIEW] TO [webuser]
GO
