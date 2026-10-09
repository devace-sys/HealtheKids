use SPEDMON 
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CYBHI_SERVICE_RECORDS_WITH_CLAIM_PROCESSING_DETAILS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CYBHI_SERVICE_RECORDS_WITH_CLAIM_PROCESSING_DETAILS_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION dbo.CYBHI_SERVICE_RECORDS_WITH_CLAIM_PROCESSING_DETAILS_VIEW (
    @userID             bigint
  , @userGroup          int
  , @userRank           int
  , @clientID           bigint  
  , @groupID            bigint
  , @pracID             bigint
  , @patID              bigint
  , @nameID             bigint
  , @startDOS           datetime
  , @endDOS             datetime 
  , @paid               bit
)
RETURNS 
TABLE
AS
RETURN
(
select 
    id = t1.svcRecID
  , t1.clientID
  , clientName      = clc.CLIENT_NAME

  , t1.pracID
  , pracName        = prp.CONCAT_NAME
  , pracNPI         = isnull(prp.npiNumber,N'')
  , pracTpaApproved = prp.cybhiTpaApproved
  , pracTpaID       = isnull(prp.cybhiTpaID,'')

  , t1.groupID
  , groupName       = gg.GROUP_NAME

  , t1.patID
  , patName         = pap.CONCAT_NAME
  , patSSID         = isnull(pap.CSIS,N'')
  , patTpaApproved  = pap.cybhiTpaApproved
  , patTpaID        = isnull(pap.cybhiTpaID,'')

  , t1.dos
  , dosStr = dbo.RPT_DATE_FMT(t1.dos)

  , t1.numMins

  , svcNameID                 = t1.nameID
  , svcName                   = ccn.NAME

  , svcIsClaimable            = t1.billableSvc
  , patOrPracAbsentSoNoClaim  = t1.svcAbsent
  , notEnoughMinsToClaim      = t1.belowThresholdToTx
  , t1.amountClaimed
  , t1.amountPaid
  , t1.processingRemark

  , patAbsentYN   = [dbo].[RPT_BIT_TO_YN]( patAbsent ) 
  , pracAbsentYN  = [dbo].[RPT_BIT_TO_YN]( pracAbsent ) 
  , svcAbsentYN   = [dbo].[RPT_BIT_TO_YN]( svcAbsent ) 

  , waitingForAdjudicationYN   = [dbo].[RPT_BIT_TO_YN]( waitingForAdjudication ) 
  , adjudicationCompletedYN    = [dbo].[RPT_BIT_TO_YN]( adjudicationCompleted ) 
  , paidYN                     = [dbo].[RPT_BIT_TO_YN]( paid ) 
  , svcClaimHeldYN             = [dbo].[RPT_BIT_TO_YN]( svcClaimHeld ) 

  , billableSvcYN              = [dbo].[RPT_BIT_TO_YN]( billableSvc ) 


from dbo.CYBHI_SERVICE_RECORDS_WITH_CLAIM_PROCESSING_DETAILS_VIEW_CORE ( 
    @clientID     
  , @groupID     
  , @pracID      
  , @patID       
  , @nameID
  , @startDOS    
  , @endDOS
  , @paid 
  , null
  , null
  ) as t1

join dbo.CLIENTS_Client            as clc on clc.CLIENT_ID        = t1.clientID
join dbo.PATIENTS_Patient          as pap on pap.PATIENT_ID       = t1.patID
join dbo.PRACTITIONER_Practitioner as prp on prp.PRACTITIONER_ID  = t1.pracID
join dbo.CLAIM_CYBHI_Names         as ccn on ccn.CYBHI_NAME_ID    = t1.nameID
join dbo.GROUP_Group               as gg  on gg.GROUP_ID          = t1.groupID

order by 
    clc.CLIENT_NAME
  , prp.CONCAT_NAME
  , t1.pracID
  , pap.CONCAT_NAME
  , t1.patID
  , t1.dos

offset 0 rows 
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[CYBHI_SERVICE_RECORDS_WITH_CLAIM_PROCESSING_DETAILS_VIEW] TO [webuser]
GO
