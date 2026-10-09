USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RPT_POTENTIAL_LOST_REIMBURSEMENT_MISSING_ORP_DETAIL') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RPT_POTENTIAL_LOST_REIMBURSEMENT_MISSING_ORP_DETAIL
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[RPT_POTENTIAL_LOST_REIMBURSEMENT_MISSING_ORP_DETAIL] (  
    @clientID       bigint
  , @repID          bigint
)
 
RETURNS TABLE
 
 /***************************************************************************    
  * RPT_POTENTIAL_LOST_REIMBURSEMENT_MISSING_ORP_DETAIL */    
 /**    
  * Returns a table 
  *    
  * @param   userID         The userid of who is requesting the report
  * @param   userGroup      Users group    
  * @param   userRank       User rank
  * @param   clientID       Record ID of client to run report for
  * @param   startDate      Starting DOS
  * @param   endDate        Ending DOS      
  * @return                 Table of report rows
  ***************************************************************************/     
 
AS RETURN (


with
cte_p0
as
(
 select 
      ws.repName
    , ws.repEmail
    , ws.clientName  
    , ws.clientID
    , ws.patName	
	, ws.patBIC
    , pap.DATE_OF_BIRTH   as patDOB
	, isnull(pap.CSIS,'') as patCSIS
    , dbo.YN_TO_BIT(pap.ACTIVE) as patActive
	, ws.patID
    , ws.pracGroupFamilyName
    , scpng.GROUP_SERVICE_CLASS_NAME_ID as pracGroupFamilyNameID	
	, enteredUsing = case when sr.entryType = 10 then 'Service Journal' else 'Service Record' end
    , ws.dos
    , sr.id as svcRecID
	, canAutoMatch = convert(bit,(case when (scpng.GROUP_SERVICE_CLASS_NAME_ID = 3) then 0 else 1 end))
    , numOrpDocMatches = case when (scpng.GROUP_SERVICE_CLASS_NAME_ID = 3) then 0 else odm.numMatches end 
	, ws.REIMBURSE_ESTIMATE

  from  dbo.WAITING_SERVICES_DATA_TEMP_ACTIONABLE            as ws
  join dbo.GROUP_GROUP_SERVICE_CLASS_PARTITIONS_NAMES_GROUPS as scpng on  scpng.GROUP_SERVICE_CLASS_PARTITION_ID = 5 
                                                                      and scpng.GROUP_ID                         = ws.groupID
  join dbo.SERVICE_RECORDS                                   as sr    on  sr.id = ws.svcRecID  
  join dbo.PATIENTS_Patient                                  as pap   on  pap.PATIENT_ID = ws.patID

  outer apply (
    select 
	  numMatches = count(id)  
	from dbo.ORP_DOCUMENTS_DATA_CORE (ws.clientID, scpng.GROUP_SERVICE_CLASS_NAME_ID, ws.patID, ws.dos, 1,null,null)	
  ) as odm
  
  where (        
        (ws.orpRequired = 1)    
    and (ws.orpDocID is null)
    and (sr.orpDocID is null)	
  	and ((@clientID is null) or (ws.clientID = @clientID))
	and ((@repID    is null) or (ws.REP_ID    = @repID))

  )

)
,
cte_p1
as
(
  select 
      repName
	, repEmail
    , clientName  
    , clientID
    , patName
    , patCSIS
	, patBIC
	, patDOB
    , patID
	, patActive
    , pracGroupFamilyName
    , pracGroupFamilyNameID
	, enteredUsing
	, canAutoMatch
    , min(dos)     as startDateMin
    , max(dos)     as endDateMax
    , count(svcRecID)    as numSvcs
	, sum(numOrpDocMatches) as numOrpDocMatches
    , sum(REIMBURSE_ESTIMATE) as totReimburseEst
  from cte_p0

  group by

      repName
    , repEmail
	, clientName
    , clientID
    , patName
    , patCSIS
    , patBIC
    , patDOB
	, patID
	, patActive
    , pracGroupFamilyName
	, pracGroupFamilyNameID
    , enteredUsing
	, canAutoMatch	
)
,
cte_p2
as
(
  select   
    p1.* 
  , orpDocumentSelections = trim(isnull(orpDocs.orpDocumentSelections,''))
  from cte_p1 as p1
  outer apply (
    select orpDocumentSelections = 
	  stuff((select char(13) + char(10) + ods.orpDocumentSelection
	from
	(
	  select
	    orpDocumentSelection = 
	    + '* ' 
		+ od.name
		+ ' [Effective] : ' 
	    + dbo.RPT_DATE_FMT(od.startDate)
	    + ' - '
	    + dbo.RPT_DATE_FMT(od.endDate)
	    + ' [Ordered By] : '
		+ isnull(od.orpPracName,'')
		+ ' [NPI] : '
		+ isnull(od.orpPracNpiNumber,'')
		+ ' [Active] : ' 
	    + dbo.BIT_TO_YN(od.active)
    
	  from dbo.ORP_DOCUMENTS_VIEW_CORE ( null
	                                    , null
										,null
	                                    , p1.clientID
                                        , p1.pracGroupFamilyNameID
                                        , p1.patID
			     	  				    , null
                                        , null
										, null
										, null
										, null
										 ) as od
      ) as ods	
      FOR XML PATH(''),TYPE).value('text()[1]','nvarchar(max)'),1,1,N'')
) as orpDocs
)
select top (dbo.CONST_MAX_ROWS())
    repName 
  , repEmail
  , clientName
  , patName 
  , patID
  , patBIC	
  , patCSIS
  , [patDOB]    = dbo.RPT_DATE_FMT(patDOB)	              
  , [patActive] = dbo.BIT_TO_YN(patActive)
  , [renderedBy]   = pracGroupFamilyName
  , [enteredUsing] = enteredUsing
  , [numSvcs]      = numSvcs
  , [renderedBetween] = dbo.RPT_DATE_FMT(startDateMin)
              + ' - '
			  + dbo.RPT_DATE_FMT(endDateMax)

  , totReimburseEst
  , [canAutoMatchTheseSvcs]   = dbo.BIT_TO_YN(canAutoMatch)
  , [numPossibleAutoMatches] = numOrpDocMatches
  , [recommendedAction] = 
  
    (case when (patActive = 0) then 'Reactivate Patient & ' else '' end)
    +
	case       
	  when (canAutoMatch = 0) then 
	    case when enteredUsing = 'Service Journal' then 'Reopen Closed Journal & Edit Entries' else 'Edit Service Record' end	  	  
	  when (canAutoMatch = 1) then
	  case 
	    when numOrpDocMatches = 0 then 'Add Missing Document'
		when numOrpDocMatches > 0 then 'Consolidate Existing ORP Documents'
	  end
	end
  , [docsInSpEdCare] = orpDocumentSelections
  
from cte_p2
order by 
    repName
  , clientName
  , patName
  , pracGroupFamilyName

) 
 
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[RPT_POTENTIAL_LOST_REIMBURSEMENT_MISSING_ORP_DETAIL] TO [webuser]
GO