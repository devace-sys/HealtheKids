
/*########################################################
 *#  Core routine for viewing service records approval   #
 *########################################################*/

USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_RECORDS_REVIEW_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SERVICE_RECORDS_REVIEW_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[SERVICE_RECORDS_REVIEW_VIEW_CORE] (
    @userID          as  bigint
  , @userGroup       as  int
  , @userRank        as  int
  , @clientID        as  bigint
  , @groupID         as  bigint
  , @pracID          as  bigint
  , @patID           as  bigint
  , @startEntryDate  as  datetime
  , @endEntryDate    as  datetime
  , @reviewed        as  bit
  , @approved        as  bit
  , @active          as  bit )
      
returns table     
as    
    
/***************************************************************************    
 * SERVICE_RECORDS_REVIEW_VIEW_CORE */    
/**    
 *     
 * @param  userID          User ID (Required)    
 * @param  userGroup       User group (Required)    
 * @param  userRank        User rank (Required)    
 * @param  clientID
 * @param  pracID
 * @param  approvingPracID
 * @param  pracID
 * @return                 Service records and svc notes
 ***************************************************************************/     
    
return (    

with 
cte_p0
as
(
select top 1 
    oldestDosAllowed = dbo.CALC_OLDEST_DOS_ALLOWED(convert(date,getdate()))
  , today = getdate() 
)
,
cte_p1
as
(
select 
  q1.*
from cte_p0 as p0
cross apply (
  select top 1
    clc.CLIENT_ID
  , clc.CLIENT_NAME
  , srao.approvalSystem
  , oldestDosAllowed = p0.oldestDosAllowed
  , startEntryDate   = isnull(@startEntryDate,p0.oldestDosAllowed)
  , endEntryDate     = isnull(@endEntryDate,  p0.today)
  from  dbo.CLIENTS_Client                   as clc  
  join  dbo.SERVICE_RECORDS_APPROVAL_OPTIONS as srao on srao.clientID = clc.CLIENT_ID
  where  (
        (clc.CLIENT_ID = @clientID)
	and (srao.approvalSystem = 1)
  )
) as q1
)
,
cte_p2
as
(

select 
  
    p1.CLIENT_ID
  , p1.CLIENT_NAME
  , p1.approvalSystem
  , p1.oldestDosAllowed
  , sra2.*

from cte_p1 as p1

cross apply (

  select 
      sra1.id	
	, sra1.svcRecID	
    , sra1.reviewed
	, sra1.approved

    , [SvcReviewState] = case 
        when (sra1.reviewed = 1 and sra1.approved = 1)     then 1   /* Success = Service reviewed and approved */
        when (sra1.reviewed = 0 and sra1.approved is null) then 2   /* Warning = Service not reviwed yet */
        when (sra1.reviewed = 1 and sra1.approved = 0)     then 3   /* Critical = Service reviwed not approved */     
        else 4
      end 
    
	, sr.dos

  from dbo.SERVICE_RECORDS_APPROVAL as sra1    
 
  join dbo.SERVICE_RECORDS          as sr on 
  ( 
        (sr.id = sra1.svcRecID) 
    and ( (sr.[state] <> 99) and (sr.[state] <> 199) )
  )

  and (sr.dos >= p1.oldestDosAllowed)
  and ((@patID is null) or (sr.patID = @patID))   
  
  /* [CLIENT_ID_GROUP_ID_PRAC_ID_SVC_REC_ID_ID_WITH_REVIEWED_ACTIVE] */

  where ( 
        ((sra1.clientID = p1.CLIENT_ID)
    and ((@groupID is null)  or (sra1.groupID = @groupID))
    and ((@pracID  is null)  or (sra1.pracID  = @pracID))
    and (sra1.svcRecID is not null)
	and (sra1.svcRecCreatedOn between p1.startEntryDate and p1.endEntryDate)
    and (sra1.id       is not null))
    and ((@reviewed is null) or (sra1.reviewed = @reviewed))
	and ((@approved is null) or (sra1.approved = @approved))
	and ((@active   is null) or (sra1.active   = @active))
	
  )
) as sra2
)

select
 
    [ID]                    = p2.ID
  , [ClientName]            = p2.CLIENT_NAME
  , [PractitionerName]      = prp.CONCAT_NAME
  , [GroupName]             = gg.GROUP_NAME
  , [SvcDateStr]            = dbo.RPT_DATE_FMT(p2.dos)
  , [SvcDateVal]            = p2.dos
  , [PatientName]           = pap.CONCAT_NAME
  , [SvcName]               = vs.[SERVICE_NAME]  
  , [MinsOrMiles]           = dbo.RPT_MINUTES_OR_START_END_MILES (  sr.svcType
                                                                   , sr.numMins
                                                                   , sr.trip1Start
                                                                   , sr.trip1End 
                                                                   , sr.trip2Start
                                                                   , sr.trip2End
                                                                   , sr.trip3Start
                                                                   , sr.trip3End
                                                                   , sr.trip4Start
                                                                   , sr.trip4End) 
  , [SvcEnteredByUserID]     = sra.svcRecCreatedByUserID
  , [SvcEnteredByUserGroup]  = sra.svcRecCreatedByUserGroup
  , [SvcEnteredByUserName]   = u1.UserName
  , [SvcEnteredByUserEmail]  = m1.Email
  , [SvcEnteredByName]       = sra.svcRecCreatedByName
  , [SvcEnteredByTitle]      = sra.svcRecCreatedByTitle
  , [SvcEnteredOnStr]        = dbo.RPT_DATE_FMT(sr.created)
  , [SvcEnteredOnVal]        = sr.created
  , [SvcReviewedStr]         = dbo.RPT_BIT_TO_YN(sra.reviewed)
  , [SvcReviewedVal]         = sra.reviewed
  , [SvcReviewedOnStr]       = case when sra.reviewed = 0 then '' else dbo.RPT_DATE_FMT (sra.reviewedOn) end
  , [SvcReviewedOnVal]       = sra.reviewedOn
  , [SvcReviewedByUserID]    = sra.reviewedByUserID
  , [SvcReviewedByUserGroup] = sra.reviewedByUserGroup
  , [SvcReviewedByUserName]  = isnull(u2.UserName,'')
  , [SvcReviewedByUserEmail] = isnull(m2.Email,'')
  , [SvcReviewedByName]      = isnull(sra.reviewedByName,'')
  , [SvcReviewedByTitle]     = isnull(sra.reviewedByTitle,'')
  , [SvcApprovedStr]         = case when sra.approved is null then '' else dbo.RPT_BIT_TO_YN (sra.approved) end
  , [SvcApprovedVal]         = sra.approved
  , [SvcReviewNotes]         = isnull(sra.reviewNotes,'')
  
  , p2.[SvcReviewState] 

  , [svcFromJournal] = convert(bit,case when (sjsr.journalID is null) then 0 else 1 end)

  , [svcRecID]               = p2.svcRecID

  , [svcRecApprovalID]       = p2.id

  , [journalID]              = sjsr.journalID
  , [clientID]               = sr.clientID
  , [groupID]                = sr.groupID
  , [pracID]                 = sr.pracID
  , [patID]                  = sr.patID
  , [active]                 = sra.active
  
  , [planTypeSelectionName]  = case 
      when sr.planType = 1 then 'LEA BOP IEP / IFSP'
      when sr.planType = 2 then 'LEA BOP IEP / IFSP'
	  when sr.planType = 3 then 'LEA BOP Other (IHP, 504, Counseling, etc.)'
	  when sr.planType = 4 then 'CYBHI'
	  when sr.planType = 5 then 'RU Health'
	  else '' 
	end

  , [startTimeStr]           = dbo.RPT_TIME_FMT(sr.startTime, 0)   

  , [endTimeStr]             = dbo.RPT_TIME_FMT(
									iif((sr.startTime is not null),dateadd(minute, sr.numMins, sr.startTime),null)
									, 0
							   )
  , [numMins] = sr.numMins
   
   , [notes]    = iif( (sr.patAbsent = 1),'Patient absent ','') 
                  + dbo.BUILD_SVC_NOTES_TEXT (srfbd2.patientGoalProgressText, srfbd2.svcNotesFormBuilderText, sr.notes)
   
   , [privateNotes] = srfbd2.svcNotesPrivateFormBuilderText -- TODO: add code to pull this from SERVICE_RECORDS_DATA_CORE
   
   , p2.approvalSystem

   , [renderingPractitionerSignature] = 'Electronically Signed By ' 
									  + sra.svcRecCreatedByName 
									  + ' (' + sra.svcRecCreatedByTitle + ')' 
									  + ' On ' + dbo.RPT_DATE_FMT(sra.createdOn)
   , [reviewingPractitionerSignature] = iif( (sra.reviewed = 1)
										, 'Electronically ' + iif( (sra.approved=1),'Approved','Declined') 
										+ ' By '
										+ sra.reviewedByName 
										+ ' (' + sra.reviewedByTitle + ')'
										+ ' On ' + dbo.RPT_DATE_FMT(sra.reviewedOn)
										, '')
   , [reviewedByNameRefID] = sra.reviewedByNameRefID

   , [startTimeVal] = sr.startTime
   , [endTimeVal]   = sr.endTime

from cte_p2                       as p2
join dbo.SERVICE_RECORDS_APPROVAL as sra on sra.id  = p2.id
join dbo.SERVICE_RECORDS          as sr  on sr.id   = p2.svcRecID

join       dbo.GROUP_Group                  as gg   on gg.GROUP_ID         = sr.groupID
join       dbo.PRACTITIONER_Practitioner    as prp  on prp.PRACTITIONER_ID = sr.pracID
join       dbo.PATIENTS_Patient             as pap  on pap.PATIENT_ID      = sr.patID

join       users.dbo.Users                  as u1   on u1.userrid          = sra.svcRecCreatedByUserID
join       users.dbo.Membership             as m1   on m1.UserId           = u1.UserId

left join  dbo.SvcJournal_Service_Records   as sjsr on sjsr.svcRecId       = sr.id

left join  users.dbo.Users                  as u2   on u2.userrid          = sra.reviewedByUserID
left join  users.dbo.Membership             as m2   on m2.UserId           = u2.UserId

cross apply (
  select top 1 snl.* from dbo.SERVICE_NAME_LOOKUP (   sr.planType
                                                , sr.svcType
                                                , sr.nameID
                                                , sr.nameIDAliasID
                                                , sr.dos
                                                , sr.groupID 
                                                , sr.hasSvcDetFlags
                                                , sr.svcDetFlag1
                                                , sr.svcDetFlag2
                                                , sr.svcDetFlag3
                                                , sr.svcDetFlag4 ) as snl 
) as vs

outer apply (
  select top 1 
	  --srfbd1.svcNotesFormBuilderQuestionsJSON
    --, srfbd1.svcNotesFormBuilderAnswersJSON
	--, srfbd1.patientGoalProgressJSON
	  [svcNotesFormBuilderText] = convert(varchar(max),(isnull(srfbd1.svcNotesFormBuilderTextSaved,N'')))
	, [patientGoalProgressText] = convert(varchar(max),(isnull(srfbd1.patientGoalProgressTextSaved,N'')))
	, [svcNotesPrivateFormBuilderText] = iif (dbo.SERVICE_RECORD_CAN_USER_VIEW_PRIVATE_NOTES(@userID, sr.userID, sr.pracID, sr.dos, sr.groupID, sr.pracGrpSvcClsNameID, sr.clientID) = 1
											 , convert(varchar(max),(isnull(srfbd1.svcNotesPrivateFormBuilderTextSaved,N''))) 
											 , ''
										)
  from dbo.SERVICE_RECORDS_FORM_BUILDER_DATA as srfbd1
  where 
    (srfbd1.svcRecID = sr.id)
) as srfbd2

)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[SERVICE_RECORDS_REVIEW_VIEW_CORE] TO [webuser]
GO