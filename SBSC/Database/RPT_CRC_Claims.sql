USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RPT_CRCS_Claims') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RPT_CRCS_Claims
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[RPT_CRCS_Claims]
(    
 @clientID   INT,    
 @startDate  datetime,
 @endDate    datetime,
 @procCode   NCHAR(10),
 @procMod1   NCHAR(10),
 @procMod2   NCHAR(10),
 @procMod3   NCHAR(10)
)
     
/***************************************************************************    
 * CRC_Claims */    
/**    
 * Returns a table of claims that match the given parameters.
 *    
 * @param  clientID        Required.  ID of client    
 * @param  startDate       Start date    
 * @param  endDate         End date
 * @param  @procCode	   PROCEDURE_CODE  
 * @param  @procMod1	   PROCEDURE_MODIFIER_1	
 * @param  @procMod2	   PROCEDURE_MODIFIER_2
 * @param  @procMod3       PROCEDURE_MODIFIER_3
 * @return                 Table of data    
 ***************************************************************************/     

RETURNS TABLE 
AS 
RETURN(

select top (dbo.CONST_MAX_ROWS())

  q1.PROC_CODE_MOD_COMBO,
  q1.DOCUMENT_REFERENCE,
  q1.AMOUNT_ALLOWED,
  q1.NUMBER_OF_UNITS,
  q1.PATIENT,
  q1.PRACTITIONER,
  q1.PRACTITIONER_ID,
  q1.GROUP_NAME,
  q1.CERTIFICATION_TYPE,
  q1.SERVICE_DATE,
  '' as [space space] -- to have an empty column in the display       
from
(
  select   
  
    /*-------------------------------
     * For report generation purposes
     * we want to present a 
     * proc+mod combo
     *------------------------------*/

    dbo.RPT_PROC_MOD_COMBO(cp.PROCEDURE_CODE,
                           cp.PROCEDURE_MODIFIER_1,
                           cp.PROCEDURE_MODIFIER_2,
                           cp.PROCEDURE_MODIFIER_3,
                           cp.PROCEDURE_MODIFIER_4) as [PROC_CODE_MOD_COMBO],
    
    /*-------------------------------
     * Legacy claims do not have a 
     * service records so we present
     * the equivalant column
     *------------------------------*/
    
    coalesce(sr.reference, c.PAPER_CLAIM_NUMBER)    as DOCUMENT_REFERENCE,
    
    ca.AMOUNT_PAID                                  as AMOUNT_ALLOWED,      -- Amount Allowed (Paid)

    c.SERVICE_UNITS                                 as NUMBER_OF_UNITS,
    p.CONCAT_NAME                                   as PATIENT,
    pp.CONCAT_NAME                                  as PRACTITIONER,
    pp.PRACTITIONER_ID                              as [PRACTITIONER_ID],
    g.GROUP_NAME                                    as [GROUP_NAME],
    
    /* TODO: When certification types are available, include*/
    
    ''                                              as CERTIFICATION_TYPE,
    
    c.SERVICE_DATE                                  as SERVICE_DATE,   
    
    /*-------------------------------
     * We want to include proxy
     * claims in the output but
     * exclude proxy children
     *------------------------------*/

    case
      when (c.HAS_PROXY = 0) and (c.IS_PROXY = 0) then 1 /* Regular claims, yes*/
      when (c.HAS_PROXY = 0) and (c.IS_PROXY = 1) then 1 /* Proxies, yes */
      when (c.HAS_PROXY = 1) and (c.IS_PROXY = 0) then 0 /* Proxy children, no */
      when (c.HAS_PROXY = 1) and (c.IS_PROXY = 1) then 0 /* Not possible and no */
    end as [IncludeInOutput]
  
    from CLAIM_Claim                     as c 
    join CLAIM_Claim_Adjudication        as ca  on  ca.CLAIM_ID        = c.CLAIM_ID and ca.AMOUNT_PAID != 0                                               
    join CLAIM_Procedures                as cp  on  cp.PROCEDURE_ID    = c.PROCEDURE_ID  
    join PATIENTS_Patient                as p   on   c.PATIENT_ID      = p.PATIENT_ID   
    join PRACTITIONER_Practitioner       as pp  on   c.PRACTITIONER_ID = pp.PRACTITIONER_ID  
    join PRACTITIONER_GROUPS_VIEW_DISP() as gd  on  gd.PRACTITIONER_ID = pp.PRACTITIONER_ID
    join GROUP_GROUP                     as g   on   g.GROUP_ID        = gd.GROUP_ID
    left join SERVICE_RECORD_CLAIMS      as src on src.claimID         = c.CLAIM_ID 
    left join SERVICE_RECORDS            as sr  on  sr.id              = src.svcRecID                                                     
  
    where         
      
      /*-------------------------------
       * Required parms
       *------------------------------*/

          c.CLIENT_ID = @clientID 
      and c.SERVICE_DATE between dbo.DATE_ONLY(@startDate) and dbo.DATE_ONLY(@endDate)

      /*-------------------------------
       * Optional parms
       *------------------------------*/
  
      and ((@procCode is null) or (cp.PROCEDURE_CODE       = upper(@procCode)))
	  and ((@procMod1 is null) or (cp.PROCEDURE_MODIFIER_1 = upper(@procMod1)))
      and ((@procMod2 is null) or (cp.PROCEDURE_MODIFIER_2 = upper(@procMod2)))
      and ((@procMod3 is null) or (cp.PROCEDURE_MODIFIER_3 = upper(@procMod3)))
  ) as q1  
  
  where
    [IncludeInOutput] = 1
  
  order by
    q1.PROC_CODE_MOD_COMBO,
    q1.SERVICE_DATE
  
)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[RPT_CRCS_Claims] TO [webuser]
GO   
