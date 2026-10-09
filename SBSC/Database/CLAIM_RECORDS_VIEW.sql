USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLAIM_RECORDS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CLAIM_RECORDS_VIEW
GO
/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[CLAIM_RECORDS_VIEW] (
  @userID     INT,    
  @userGroup  INT,    
  @userRank   INT,    
  @clientID   INT,     
  @pracID     INT,    
  @patID      INT,    
  @startDate  DATETIME,    
  @endDate    DATETIME      
) 
    
RETURNS TABLE 
AS RETURN (       

select   

     clt.CLIENT_NAME          AS clientName
    ,prac.CONCAT_NAME         AS pracName
    ,pat.CONCAT_NAME          AS patName
    ,cr.SERVICE_DATE          AS dos
    ,cp.PROCEDURE_NAME        AS procName
    
    ,dbo.RPT_PROC_MOD_COMBO(   cp.PROCEDURE_CODE
                             , cp.PROCEDURE_MODIFIER_1
                             , cp.PROCEDURE_MODIFIER_2
                             , cp.PROCEDURE_MODIFIER_3
                             , cp.PROCEDURE_MODIFIER_4
                            ) as procModComboStr

    , isnull(cr.SERVICE_UNITS,0)                  AS units
    , pat.BIC                                     AS patBIC    
    , [patElgFlag] = case 
               when (pen.IS_ELIG = 1)    then dbo.CONST_PAT_ELIGIBILITY_FLAG_VALUE_YES()
               when (pen.IS_ELIG = 0)    then dbo.CONST_PAT_ELIGIBILITY_FLAG_VALUE_NO()
               when (pen.IS_ELIG = null) then dbo.CONST_PAT_ELIGIBILITY_FLAG_VALUE_UNK()
               else                           dbo.CONST_PAT_ELIGIBILITY_FLAG_VALUE_UNK()
      end
      
    , [statusStr] = dbo.CLAIM_STATUS_TO_NAME(cr.status)
    
    , [Comments] = case (cr.status)
      when dbo.CONST_CLAIM_STATUS_NOT_SUB()             THEN 'Claim Held : ' + dbo.RPT_BIT_TO_YN (cr.HOLD)
      when dbo.CONST_CLAIM_STATUS_SUB_PENDING()         THEN '' 
      when dbo.CONST_CLAIM_STATUS_CHILD_OF_SENT_PROXY() THEN ''
      when dbo.CONST_CLAIM_STATUS_SUB_PAID()            THEN ca.AMT_PAID
      when dbo.CONST_CLAIM_STATUS_RECV_PROXY_PAID()     THEN ca.AMT_PAID
      WHEN dbo.CONST_CLAIM_STATUS_SUB_REJECT()          THEN ccaDetails.ADJUDICATION_DETAILS
      when dbo.CONST_CLAIM_STATUS_RECV_PROXY_DENIED()   THEN ccaDetails.ADJUDICATION_DETAILS
    end

    ,cr.USER_ID               AS userID      
    ,cr.ENTRY_DATE            AS created
    ,cr.LAST_UPDATED          AS lastmodified
    ,cr.STATUS                AS status   
    ,cr.BATCH_NUMBER          AS batchNum
    ,cr.PAPER_CLAIM_NUMBER    AS paperClaimNum
    ,cr.CLAIM_ID              AS id    
    ,cr.CLIENT_ID             AS clientID    
    ,cr.PRACTITIONER_ID       AS pracID    
    ,cr.PATIENT_ID            AS patID     
    ,cr.PROCEDURE_ID          AS procID
    ,src.svcRecId             AS svcRecID
    
from      dbo.CLAIM_Claim                      as  cr     
join      dbo.CLIENTS_CLIENT                   as  clt  on   clt.CLIENT_ID        = cr.CLIENT_ID     
join      dbo.PRACTITIONER_Practitioner        as  prac on   prac.PRACTITIONER_ID = cr.PRACTITIONER_ID     
join      dbo.PATIENTS_Patient                 as  pat  on   pat.PATIENT_ID       = cr.PATIENT_ID    
join      dbo.CLAIM_Procedures                 as  cp   on   cp.PROCEDURE_ID      = cr.PROCEDURE_ID     
left join dbo.SERVICE_RECORD_CLAIMS            as  src  on   src.claimID          = cr.CLAIM_ID

outer apply (
  select top 1 * 
  from dbo.PATIENTS_ELIGIBILITY_NORMALIZED 
  where ( 
         (PATIENT_ID = cr.PATIENT_ID)
     and (convert(date,MONTH_DATE) = convert(date,(dbo.DATE_MONTH_START_END (cr.SERVICE_DATE, 0))))
  )
) as pen

outer apply (
  select top 1
    [AMT_PAID] = CONVERT(VARCHAR(100), CONVERT(money,(round((AMOUNT_PAID * EDSPERCENT),2))),1) 
  from dbo.CLAIM_Claim_Adjudication
  where (CLAIM_ID = cr.CLAIM_ID)
) as ca

outer apply (

  select 
     [ADJUDICATION_DETAILS] = stuff((select char(13) + ADJUDICATION_DETAIL 
  from
  (
    select
       ltrim(rtrim(isnull(cdc.CODE_VALUE + ' -- ','') + ' ' + isnull(cdc.DETAIL_TEXT,''))) as ADJUDICATION_DETAIL   
    from
    (
      select      
      
         ADJUDICATION_ID_FOR_STATUS = coalesce (   cca1.ADJUDICATION_ID
                                                 , cca2.ADJUDICATION_ID
                                                 , cca3.ADJUDICATION_ID )
                                                 
       from      dbo.CLAIM_Claim                as cc  
       left join dbo.CLAIM_Claim_Adjudication   as cca1 on cca1.CLAIM_ID  = cc.REFERENCE_CLAIM_ID_1
       left join dbo.CLAIM_Claim_Adjudication   as cca2 on cca2.CLAIM_ID  = cc.REFERENCE_CLAIM_ID_2
       left join dbo.CLAIM_Claim_Adjudication   as cca3 on cca3.CLAIM_ID  = cc.CLAIM_ID

       where (cc.CLAIM_ID = cr.CLAIM_ID)

     ) as q1 

    left join dbo.CLAIM_CLAIM_ADJUDICATION_DETAILS as ccad on ccad.ADJUDICATION_ID = q1.ADJUDICATION_ID_FOR_STATUS
    left join dbo.CLAIM_DETAIL_CODES               as cdc  on cdc.CODE_ID          = ccad.DETAIL_CODE_ID

  ) as q2
  FOR XML PATH(''),TYPE).value('text()[1]','nvarchar(max)'),1,1,N'')
) as ccaDetails

where (
      (cr.CLIENT_ID = @clientID)                                 
  and (cr.IS_PROXY  = 0)                                          
  and ((@pracID is null) or (cr.PRACTITIONER_ID  = @pracID))
  and ((@patID  is null) or (cr.PATIENT_ID       = @patID))  
  and (((@startDate is null) or (@endDate is null))
  or   (cr.SERVICE_DATE between @startDate and @endDate))
)

)    
GO
/*-------------------------------
 * User Permissions
 *------------------------------*/
GRANT SELECT ON  [dbo].[CLAIM_RECORDS_VIEW] TO [webuser]
GO
