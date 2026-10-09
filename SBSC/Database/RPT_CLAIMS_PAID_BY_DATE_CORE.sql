USE [SPEDMON]
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RPT_CLAIMS_PAID_BY_DATE_CORE') AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[RPT_CLAIMS_PAID_BY_DATE_CORE]
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[RPT_CLAIMS_PAID_BY_DATE_CORE]  (
     @clientID     INT
   , @startDateDOS DATETIME    
   , @endDateDOS   DATETIME     
   , @startDateDOW DATETIME    
   , @endDateDOW   DATETIME
 )
 RETURNS TABLE 
 
 /***************************************************************************    
  * RPT_CLAIMS_PAID_BY_DATE_CORE */    
 /**    
  * Generates data for claims paid for a given:
  *
  * - client 
  * - date of service (DOS) range
  * - date of warrant (DOW) range (check date)
  *    
  * @param  clientID      Client id
  * @param  startDateDOS  Starting DOS
  * @param  endDateDOS    Ending DOS
  * @param  startDateDOW  Starting DOW
  * @param  endDateDOW    Ending DOW
  * @return               Table 
  ***************************************************************************/  
 
AS RETURN(

with
cte_p0
as
(
  /* Only report out on one client */

  select top 1
      clc.CLIENT_ID 
    , START_DATE_DOS     = dbo.DATE_OR_MIN_MAX  (@startDateDOS, -1) 
    , END_DATE_DOS       = dbo.DATE_OR_MIN_MAX  (@endDateDOS,    1)             
    , START_DATE_DOW     = dbo.DATE_OR_MIN_MAX  (@startDateDOW, -1)
    , END_DATE_DOW       = dbo.DATE_OR_MIN_MAX  (@endDateDOW,    1)
	, LEA_RECOVERY_GOAL  = isnull(clc.LEARecoveryBudget,1)
	, SERVICES_ASSESS    = dbo.CONST_SERVICES_ASSESS()
	, SERVICES_TREATMENT = dbo.CONST_SERVICES_TREATMENT()
	, SERVICES_TRANSPORT = dbo.CONST_SERVICES_TRANSPORT()
	, SERVICES_TCM       = dbo.CONST_SERVICES_TCM()
  from dbo.CLIENTS_Client as clc
  where 
    (clc.CLIENT_ID = @clientID)
)
,
cte_p1
as
(
  /* Uses index : [FOR_RPT_CLAIMS_PAID_BY_DATE_CORE] */
  select 
      p0.*
    , ccp.POSTING_ID
  from cte_p0                  as p0                               
  join dbo.CLAIM_Claim_Posting as ccp on ((ccp.clientID = p0.CLIENT_ID)
                                      and (ccp.CHECK_DATE between p0.START_DATE_DOW and p0.END_DATE_DOW)	
									  and (ccp.POSTING_ID is not null))
)
,
cte_p2
as
(
  /* Uses following index : [FOR_RPT_CLAIMS_PAID_BY_DATE]*/

  select                   
	    p1.*
      , cca.CLAIM_ID
	  , cca.AMOUNT_PAID                                           as [AMOUNT_PAID]
      , cca.EDSPERCENT                                            as [PERCENTAGE_DISBURSED]        	 
      , CONVERT(NUMERIC(18,8),(cca.AMOUNT_PAID * cca.EDSPERCENT)) as [AMOUNT_DISBURSED]
  from cte_p1 as p1           
  join dbo.CLAIM_Claim_Adjudication as cca  on  ((cca.POSTING_ID = p1.POSTING_ID)
	                                        and (cca.DATE_ADJUDICATED between p1.START_DATE_DOW and p1.END_DATE_DOW)
											and (cca.ADJUDICATION_ID is not null))
  where (
    (cca.AMOUNT_PAID != 0)
  )
)
,
cte_p3
as
(
  /* Uses following index : [FOR_RPT_CLAIMS_PAID_BY_DATE]*/
  
  select 
        p2.* 
      , clm.PRACTITIONER_ID 
      , clm.PATIENT_ID   
      , clm.PROCEDURE_ID       
  from cte_p2             as p2
  join dbo.CLAIM_Claim    as clm  on  (     (clm.CLAIM_ID  = p2.CLAIM_ID)
	                                    and (clm.CLIENT_ID = p2.CLIENT_ID)
	                                    and (clm.IS_PROXY = 0)
	                                    and (clm.SERVICE_DATE between p2.START_DATE_DOS and p2.END_DATE_DOS))
)

select   
    p3.[CLIENT_ID]
  , p3.[PRACTITIONER_ID]
  , p3.[PATIENT_ID]
  , p3.[PROCEDURE_ID]        
  , [SERVICE_TYPE] = cp.SERVICE_TYPE_ID

  , [ASSESSMENTS]                 = iif ( (cp.SERVICE_TYPE_ID = p3.SERVICES_ASSESS)
                                         , p3.AMOUNT_DISBURSED
										 , 0.00 )
										           
  , [SERVICES_AND_TRANSPORTATION] = iif ((   (cp.SERVICE_TYPE_ID = p3.SERVICES_TREATMENT) 
                                          or (cp.SERVICE_TYPE_ID = p3.SERVICES_TRANSPORT))
										  , p3.AMOUNT_DISBURSED
										  , 0.00 )

  , [TCM]                         = iif (  (cp.SERVICE_TYPE_ID = p3.SERVICES_TCM)
                                          , p3.AMOUNT_DISBURSED
										  , 0.00)           

  , [ADJUSTEMENTS_AND_OTHER]      = iif ( (cp.SERVICE_TYPE_ID is NULL)
                                         , p3.AMOUNT_DISBURSED
										 , 0.00 )
           
  , p3.[AMOUNT_PAID]
  , p3.[PERCENTAGE_DISBURSED]
  , p3.[AMOUNT_DISBURSED]   
  , p3.[LEA_RECOVERY_GOAL]

from cte_p3               as p3
join dbo.CLAIM_Procedures as cp on cp.PROCEDURE_ID = p3.PROCEDURE_ID
  
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[RPT_CLAIMS_PAID_BY_DATE_CORE] TO [webuser]
GO   
