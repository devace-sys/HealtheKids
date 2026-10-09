USE [spedmon]
GO

DROP FUNCTION if exists [dbo].[CLAIM_Denied_Resubmit_Disposition_View]
GO


CREATE FUNCTION [dbo].[CLAIM_Denied_Resubmit_Disposition_View] (    
    @userID          BIGINT    
  , @userGroup       INT    
  , @userRank        INT 
  , @clientID        bigint
)
       

RETURNS TABLE 
AS 
RETURN
(
with

/* Claims we can still resubmit after correction excluding claims flagged as dismissed */

cte_p1
as
(
  select 
    t1.*
  from dbo.CLAIMS_DENIED_POSSIBLE_RESUBMIT_AFTER_CORRECTION_VIEW_CORE (
      @clientID
    , (dbo.CALC_OLDEST_DOS_ALLOWED(GETDATE()))
    , getdate()
    , null
   ) as t1
 
   left join dbo.CLAIM_Denied_Resubmit_Disposition as cdrd on cdrd.CLIENT_ID = @clientID
                                                           and cdrd.CLAIM_ID = t1.CLAIM_ID
                                                           and cdrd.FLAGGED_DISMISSED = 1 														 
   where 
     (cdrd.CLAIM_ID is null)
  )
  ,
  
  /* Everthing that comes out of p1 excluding claims that are flagged for resubmit */

  cte_p2
  as
  (
    select p1.* 
	from cte_p1 as p1
    left join dbo.CLAIM_Denied_Resubmit_Disposition as cdrd on cdrd.CLIENT_ID = @clientID
                                                           and cdrd.CLAIM_ID = p1.CLAIM_ID
                                                           and cdrd.FLAGGED_FOR_RESUBMIT = 1
	where 
      (cdrd.CLAIM_ID is null)													    														 

  )
  select top (dbo.CONST_MAX_ROWS()) 
      id               = p2.CLAIM_ID
	, clientID         = p2.CLIENT_ID
	, clientName       = cca.CLIENT_NAME
	, patID            = p2.PATIENT_ID 
	, patDhcsLastName  = p2.DHCS_LAST_NAME
	, patDhcsFirstName = p2.DHCS_FIRST_NAME
	, patDOB           = p2.DATE_OF_BIRTH
	, patDOBStr        = dbo.RPT_DATE_FMT(p2.DATE_OF_BIRTH)
	, patSex           = p2.SEX
	, patBIC           = p2.BIC
	, procProcModCombo = p2.PROC_MOD_COMBO
	, procName         = p2.PROCEDURE_NAME
	, procSvcDate      = p2.SERVICE_DATE_ONLY
	, procSvcDateStr   = dbo.RPT_DATE_FMT(p2.SERVICE_DATE)
    , denialCodeValue  = p2.CODE_VALUE
	, denialCodeText   = p2.DETAIL_TEXT
	, claimID          = p2.CLAIM_ID
  from cte_p2                 as p2
  join dbo.CLIENTS_Client_All as cca on cca.CLIENT_ID = p2.CLIENT_ID
  order by 
    p2.PATIENT_ID
   ,p2.PROC_MOD_COMBO
   ,p2.CLAIM_ID
 

)
GO

GRANT SELECT ON [dbo].[CLAIM_Denied_Resubmit_Disposition_View] TO webuser
GO
