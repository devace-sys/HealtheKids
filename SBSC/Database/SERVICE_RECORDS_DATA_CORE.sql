USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_RECORDS_DATA_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SERVICE_RECORDS_DATA_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[SERVICE_RECORDS_DATA_CORE] (
	@userID				   as   bigint
  , @clientID              as   bigint
  , @groupSvcClassNameID   as   bigint
  , @pracID                as   bigint     
  , @patID                 as   bigint
  , @svcTypeID             as   bigint
  , @startDate             as   datetime
  , @endDate               as   datetime  
  , @startEntryDate        as   datetime
  , @endEntryDate          as   datetime      
  , @reference             as   varchar(500)
  , @recID                 as   bigint
)    
returns table     
as    
    
/***************************************************************************    
 * SERVICE_RECORDS_DATA_CORE */    
/**    
 * Service records core data.  Keep this in synch with the index    
 *     
 * @param  clientID        Client ID (required)    
 * @param  pracID          Practitioner ID    
 * @param  patID           PatientID    
 * @param  recID           Service record, record id (will only return one record)    
 * @return                 Service records    
 ***************************************************************************/     
    
return (    
with
cte_p1
as
(
  select   
      sr.*     
	, c.CLIENT_NAME
    , pr.LAST_NAME                                  as PR_LAST_NAME
    , pr.FIRST_NAME                                 as PR_FIRST_NAME    
    , pr.CONCAT_NAME                                as PR_CONCAT_NAME
    , pa.LAST_NAME                                  as PA_LAST_NAME   
    , pa.FIRST_NAME                                 as PA_FIRST_NAME    
    , pa.CONCAT_NAME                                as PA_CONCAT_NAME                       
    , pa.DATE_OF_BIRTH                              as PA_DOB
	, pa.CSIS                                       as PA_CSIS
	, convert(bit,iif((sjsr.id is null),0,1))       as svcJournalRelated
	, convert(bigint,isnull(sjsr.journalID,-1))     as svcJournalID
    , isnull(m.LastName,N'') + N', ' + isnull(m.FirstName,N'') as SR_ENTERED_BY_USER_LAST_FIRST 
    , m.SBSC_Employee                                          as SR_ENTERED_BY_PCAL_STAFF
	, convert(bit,iif((sr.userID = pr.UserID),1,0))            as SR_ENTERED_BY_PRAC
	, entryTypeIsSvcJournal          = convert(bit,(iif ((sr.entryType in (10,11)),1,0)))
	, entryTypeIsSvcJournalPatAbsent = convert(bit,(iif((sr.entryType=11),1,0)))

  from      dbo.SERVICE_RECORDS                   as sr    
  join      dbo.CLIENTS_CLIENT                    as c    on c.CLIENT_ID          = sr.clientID
  join      dbo.PATIENTS_Patient                  as pa   on pa.PATIENT_ID        = sr.patID     
  join      dbo.PRACTITIONER_Practitioner         as pr   on pr.PRACTITIONER_ID   = sr.pracID  
  join      users.dbo.Users                       as u    on u.userrid            = sr.userID
  join      users.dbo.Membership                  as m    on m.UserId             = u.UserId  
  left join dbo.SvcJournal_Service_Records        as sjsr on sjsr.svcRecID        = sr.id          /* Uses index */
  
  where ( 
          (1=1)
    and   ((@clientID is null)            or (sr.clientID = @clientID))    
	and   ((@groupSvcClassNameID is null) or (sr.pracGrpSvcClsNameID = @groupSvcClassNameID))
    and   ((@pracID is null)              or (sr.pracID = @pracID))    
    and   ((@patID  is null)              or (sr.patID  = @patID))
	and   ((@svcTypeID is null)           or (sr.svcType = @svcTypeID))    
    and   ((@reference is null)           or (reference = @reference))         
    and   ((@recID  is null)              or (sr.id     = @recID))
    and   (((@startDate is null) or (@endDate is null)) 
           or (sr.dos between @startDate and @endDate))
    and   (((@startEntryDate is null) or (@endEntryDate is null)) 
           or (sr.created between @startEntryDate and @endEntryDate)) 
    and   (sr.state != dbo.CONST_SVC_REC_STATE_DEL())
    and   (sr.state != dbo.CONST_SVC_REC_STATE_CIF())    
  )
)
,
cte_p2
as
(
  select 
	  sr.* 
    , [SVC_NAME]                 = dbo.BUILD_FULL_SERVICE_NAME_STRING (snlds.id, cip.NAME, cnp.NAME, ccy.NAME, cru.NAME, null, null, null, null, sr.svcType, gg.GROUP_BASE, sr.hasSvcDetFlags, sr.svcDetFlag1, sr.svcDetFlag2, sr.svcDetFlag3 , sr.svcDetFlag4 )
    , [PR_GROUP_NAME_ON_DOS]     = isnull(gg.GROUP_NAME,N'')   
	, [SR_ENTERED_BY_DIST_STAFF] = convert(bit,(iif (((sr.SR_ENTERED_BY_PCAL_STAFF = 0) and (sr.SR_ENTERED_BY_PRAC = 0)),1,0)))
	, enteringUserSig = iif ( (sr.SR_ENTERED_BY_PRAC = 1)
	                         , ('Electronically Signed By ' + SR_ENTERED_BY_USER_LAST_FIRST + ' (' + isnull(gg.GROUP_NAME,N'') + ') On ' + dbo.RPT_DATE_FMT(sr.created))							 
							 , 'See source documentation')

	, attendanceStatusSelectionID   = sras.id
	, attendanceStatusSelectionName = sras.[name]
	, svcNameListDataSourceID       = snlds.id
	, svcNameListDataSourceName     = snlds.name

  from cte_p1                          as sr
  
  left join dbo.GROUP_Group            as gg  on gg.GROUP_ID          = sr.groupID  
  
  left join dbo.CLAIM_IEPandIFSPNames  as cip on cip.IEP_IFSP_NAME_ID  = sr.nameID
  left join dbo.CLAIM_NoPlanNames      as cnp on cnp.NO_PLAN_NAME_ID   = sr.nameID 							 
  left join dbo.CLAIM_CYBHI_Names      as ccy on ccy.CYBHI_NAME_ID     = sr.nameID
  left join dbo.CLAIM_RU_HEALTH_NAMES  as cru on cru.RU_HEALTH_NAME_ID = sr.nameID

  join dbo.SERVICE_RECORD_ATTENDANCE_SELECTIONS as sras  on sras.id = sr.attendanceSelectionID
  join dbo.CLAIM_Svc_Names_List_Data_Sources    as snlds on ((snlds.isIEPOrIFSP = sr.isIFSPorIEP) and (snlds.billingProgramID = sr.billingProgramID))
       
)

select 
    p2.* 
  , srfbd2.*
  , svcNotesFormBuilderTextAndNotes = dbo.BUILD_SVC_NOTES_TEXT(srfbd2.patientGoalProgressText,srfbd2.svcNotesFormBuilderText,p2.notes)
  , calPads.calPadsCodeValueStr
  , minsSatisfied = dbo.CALC_PROMISED_MINS_SATISFIED (p2.numMins, p2.patAbsent, p2.pracAbsent, p2.makeupSession, 1, p2.attendanceSelectionID)
  , renderingPracSig = isnull(sra2.renderingPracSig, p2.enteringUserSig)
  , reviewingPracSig = isnull(sra2.reviewingPracSig,'')
  
from cte_p2 as p2
																				            																				   																				  																				   
outer apply (
  select top 1 
	  srfbd1.svcNotesFormBuilderQuestionsJSON
    , srfbd1.svcNotesFormBuilderAnswersJSON
	, srfbd1.patientGoalProgressJSON
	, [svcNotesFormBuilderText] = convert(varchar(max),(isnull(srfbd1.svcNotesFormBuilderTextSaved,N'')))
	, [patientGoalProgressText] = convert(varchar(max),(isnull(srfbd1.patientGoalProgressTextSaved,N'')))
	, [svcNotesPrivateFormBuilderText] = iif (dbo.SERVICE_RECORD_CAN_USER_VIEW_PRIVATE_NOTES(@userID, p2.userID, p2.pracID, p2.dos, p2.groupID, p2.pracGrpSvcClsNameID, p2.clientID) = 1
											 , convert(varchar(max),(isnull(srfbd1.svcNotesPrivateFormBuilderTextSaved,N''))) 
											 , ''
										)
      
	, srfbd1.hasFillablePdfSelections
	, srfbd1.fillablePdfSelectionsJSON
	, srfbd1.fillablePdfAnswersJSON

  from dbo.SERVICE_RECORDS_FORM_BUILDER_DATA as srfbd1
  where 
    (srfbd1.svcRecID = p2.id)
) as srfbd2


outer apply (
  select top 1 
    calPadsCodeValueStr = iif(xref1.spEdSvcCodeValue=-1,'',convert(varchar(25),xref1.spEdSvcCodeValue)) 
  from dbo.CLAIM_SERVICE_NAME_XREF_AND_FORM_DATA as xref1
  where (
        (xref1.planTypeID  = p2.planType)
    and (xref1.groupID     = p2.groupID)
    and (xref1.nameID      = p2.nameID)
	and (xref1.hasClientID = 0)
    and (xref1.isStandard = 1)
	and (xref1.active = 1)
  )
) as calPads


outer apply (
  /* Latest */

  select top 1
      renderingPracSig = 'Electronically Signed By ' + sra1.svcRecCreatedByName + ' (' + sra1.svcRecCreatedByTitle + ')' + ' On ' + dbo.RPT_DATE_FMT(sra1.createdOn)
	, reviewingPracSig = iif( ((sra1.reviewed = 1) and (sra1.approved = 1))
	                      , 'Electronically Approved By ' + sra1.reviewedByName + ' (' + sra1.reviewedByTitle + ')'+ ' On ' + dbo.RPT_DATE_FMT(sra1.reviewedOn)
						  , '')
  from dbo.SERVICE_RECORDS_APPROVAL as sra1
  where (
          (sra1.svcRecID = p2.id)
	  and (sra1.active = 1)
  )

  order by 
    sra1.id desc

) as sra2

)
GO
