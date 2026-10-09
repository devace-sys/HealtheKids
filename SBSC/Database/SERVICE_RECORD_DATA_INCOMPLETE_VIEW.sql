USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_RECORD_DATA_INCOMPLETE_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SERVICE_RECORD_DATA_INCOMPLETE_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[SERVICE_RECORD_DATA_INCOMPLETE_VIEW] ( 
	   @userID            BigInt    
	 , @userGroup         Int    
	 , @userRank          Int 
	 , @clientID          BigInt    	 
	 , @recID             Bigint
)
     
RETURNS TABLE  

AS RETURN (

 /* Note: Support provided for LEA BOP services only and only services where patient was present
  * Basically the fields that the pcal input staff would be able to input.
  */   

with
cte_p1
as
(
  select 
	  srdi.[id]
	, srdi.clientID	
	, srdi.reference	
	, srdi.svcRecJSON
	, svcRecBatchID = srdi.batchID  /* Originally flagged for qform as part of this service record entry session */
	, srdi.svcRecID                 /* When missing info is succesfully completed the svc rec id that is generated goes here */
	, createdOn         = srdi.created
	, createdOnYMD      = dbo.RPT_DATE_FMT_YYYY_MM_DD(srdi.created)
	, createdByUserID   = srdi.createdBy
	, createdByUserName = u.UserName
	, inputBatchID      = isnull(relatedInputBatch.id,-1)
	, inputBatchNotes   = isnull(relatedInputBatch.Notes,'')
	
  from dbo.SERVICE_RECORD_DATA_INCOMPLETE as srdi
  join users.dbo.Users                    as u on u.userrid = srdi.createdBy

  /* Related input batch: matched filename since SERVICE_RECORD_DATA_INCOMPLETE.reference
	 stores the batch's filename rather than a foreign key to INPUT_BATCHES. */
  
  outer apply (
      select top 1 
		  ib.Notes
	    , ib.id
	  from dbo.INPUT_BATCHES as ib 
	  where /* Uses [FILE_NAME_WITH_ID_CLIENT_ID_PARENT_ID] index */
	    ((((ib.File_Name = srdi.reference) or (ib.File_Name = srdi.reference + '.pdf')) and (ib.id > 0)) and (ib.ClientID = srdi.clientID))
	  order by 
	    ib.id asc
  ) as relatedInputBatch

  where ( 
	    (1=1)
    and ((@clientID is null) or (srdi.clientID = @clientID))
    and ((@recID    is null) or (srdi.[id]     = @recID))
	and (srdi.active = 1)
  )
)
,
cte_p2
as
(
  select 
      p1.* 
    , parsedRec.pracID
	, parsedRec.groupID
	, parsedRec.patID
	, parsedRec.nameID
	, parsedRec.viaTelehealth
	, parsedRec.isIEPOrIFSP
	, parsedRec.numMins
	, parsedRec.notes
	, parsedRec.dos
	, dosStrYMD = dbo.RPT_DATE_FMT_YYYY_MM_DD(parsedRec.dos)
	, parsedRec.hasSvcDetFlags
	, parsedRec.svcDetFlag1
	, parsedRec.svcDetFlag2
	, parsedRec.svcDetFlag3
	, parsedRec.svcDetFlag4
	, parsedRec.hasOrpDocID
	, parsedRec.orpDocID

  from cte_p1 as p1

  cross apply (
    select 
	   t1.pracID
	 , t1.groupID
	 , t1.patID
	 , t1.nameID
	 , t1.viaTelehealth
	 , t1.isIEPOrIFSP
	 , t1.startTime
	 , t1.numMins
	 , t1.notes
	 , t1.dos
	 , t1.hasSvcDetFlags
	 , t1.svcDetFlag1
	 , t1.svcDetFlag2
	 , t1.svcDetFlag3
	 , t1.svcDetFlag4
	 , t1.hasOrpDocID
	 , t1.orpDocID

    from OPENJSON ( p1.svcRecJSON )  
	
	with (   
			pracID                           bigint       '$.pracID'
		  , groupID                          bigint       '$.groupID'
		  , patID                            bigint       '$.patID'
		  , nameID                           bigint       '$.nameID'
		  , viaTelehealth                    bit          '$.viaTelehealth' 
		  , isIEPOrIFSP                      bit          '$.isIEPOrIFSP'
		  , startTime                        time(0)      '$.startTime'
		  , numMins                          int          '$.numMins' 
		  --, sessionDeliveryStatus            int          '$.sessionDeliveryStatus'
		  , notes                            varchar(max) '$.notes' 
		  --, svcNotesFormBuilderQuestionsJSON varchar(max) '$.svcNotesFormBuilderQuestionsJSON' 
		  --, svcNotesFormBuilderAnswersJSON   varchar(max) '$.svcNotesFormBuilderAnswersJSON' 
		  --, patientGoalProgressJSON          varchar(max) '$.patientGoalProgressJSON'  
		  --, hasPatientGoalTrackingData       bit          '$.hasPatientGoalTrackingData'
		  , dos                              datetime     '$.dateOfService'
		  , hasSvcDetFlags                   bit          '$.hasSvcDetFlags'  
		  , svcDetFlag1                      bit          '$.svcDetFlag1'
		  , svcDetFlag2                      bit          '$.svcDetFlag2'
		  , svcDetFlag3                      bit          '$.svcDetFlag3'
		  , svcDetFlag4                      bit          '$.svcDetFlag4' 
		  , hasOrpDocID                      bit          '$.hasOrpDocID'   
		  , orpDocID                         bigint       '$.orpDocID'
		 -- , RMTSMoment                       bit          '$.RMTSMoment'
		 -- , patAbsent                        bit          '$.patAbsent'
		 -- , pracAbsent                       bit          '$.pracAbsent'
		 -- , makeupSession                    bit          '$.makeupSession'     
	   ) as t1
	) as parsedRec
)
,
cte_p3
as
(
  select 
      p2.*
	, clientName = clc.CLIENT_NAME
	, pracName   = pp.CONCAT_NAME
	, groupName  = gg.GROUP_NAME
	, patName    = pap.CONCAT_NAME 


	, svcNamesListDataSourceID = snlds.id
	, snlds.billingProgramID

	, svcName = dbo.BUILD_FULL_SERVICE_NAME_STRING (  snlds.id
	                                                , cip.NAME
										            , cnp.NAME
										            , ccy.NAME
										            , cru.NAME
										            , null, null, null, null
													, null /*svcType*/
										            , gg.GROUP_BASE
										            , p2.hasSvcDetFlags
										            , p2.svcDetFlag1
										            , p2.svcDetFlag2
										            , p2.svcDetFlag3
										            , p2.svcDetFlag4 )
	, orpDocLabel = isnull(odssn.[NAME],'')	
  
  from cte_p2             as p2
  join dbo.CLIENTS_Client as clc on clc.CLIENT_ID = p2.clientID
  
  left join PRACTITIONER_Practitioner  as pp  on pp.PRACTITIONER_ID    = p2.pracID
  left join PATIENTS_Patient           as pap on pap.PATIENT_ID        = p2.patID
  left join dbo.GROUP_Group            as gg  on gg.GROUP_ID           = p2.groupID  
  left join dbo.CLAIM_IEPandIFSPNames  as cip on cip.IEP_IFSP_NAME_ID  = p2.nameID
  left join dbo.CLAIM_NoPlanNames      as cnp on cnp.NO_PLAN_NAME_ID   = p2.nameID 
  left join dbo.CLAIM_CYBHI_Names      as ccy on ccy.CYBHI_NAME_ID     = p2.nameID
  left join dbo.CLAIM_RU_HEALTH_NAMES  as cru on cru.RU_HEALTH_NAME_ID = p2.nameID

  left join dbo.ORP_DOCUMENTS                         as od    on od.[id]    = p2.orpDocID
  left join dbo.ORP_DOCUMENT_STANDARD_SELECTION_NAMES as odssn on odssn.[id] = od.ORP_DOCUMENT_STANDARD_SELECTION_NAME_ID
  left join dbo.CLAIM_Svc_Names_List_Data_Sources     as snlds on ((snlds.isIEPOrIFSP = p2.isIEPOrIFSP) and (snlds.billingProgramID = 1 /* LEA Bop*/))

)

select top (dbo.CONST_MAX_ROWS())
  p3.* 
from cte_p3 as p3
order by 
    p3.clientName asc
  , p3.id         asc

) 
     
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[SERVICE_RECORD_DATA_INCOMPLETE_VIEW] TO [webuser]
GO