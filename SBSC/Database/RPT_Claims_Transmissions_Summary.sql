USE [SPEDMON]
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

 IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RPT_Claims_Transmissions_Summary') AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RPT_Claims_Transmissions_Summary
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION  [dbo].[RPT_Claims_Transmissions_Summary]
(
   @clientID  bigint
 , @repID     bigint
 , @startDate date
 , @endDate   date
)

RETURNS TABLE
 
 /***************************************************************************
 * RPT_Claims_Transmissions_Summary */
/**
 * Returns a table of report rows
 *
 * @param   client ID             filter by Client ID to get one client or all Clients.
 * @param   repID                 filter by Practical Consultant ID to get one or all Consultants,
 * @param   startDate             filter by Start Date.
 * @param   endDate               filter by End Date.
 * @return                        Table of report rows
 ***************************************************************************/
 
AS RETURN 
(

with
cte_p1
as
(
  select top (dbo.CONST_MAX_ROWS())    
      [TRANSMISSION_DATE_STR] = dbo.RPT_DATE_FMT(tsc.TRANSMISSION_DATE)
	, tsc.CLIENT_ID
    , fileName = isnull(tr.fileName,'')
    , tsc.TOTAL_NUMBER_CLAIMS
    , cd.ServiceUnits
    , tsc.TOTAL_DOLLAR_AMOUNT
    , WhenToInvoice = case when (ci.INVOICE_ID is null) then isnull(tsc.WhenToInvoice,'?') else 'Invoice# ' + convert(varchar,ci.INVOICE_NUMBER) end + ''
    , tsc.InvoiceRate
    , tsc.RevenueSharingCategoryLEA
   
  from      dbo.Transmission_Summary_By_Client_837  as tsc 
  join      dbo.Transmission_Records                as tr on tr.Transmission_ID = tsc.TRANSMISSION_RECORD_ID
  left join dbo.Client_Invoices                     as ci on ci.TRNLINE_837_ID  = tsc.TRANSMISSION_LINE_ID

  cross apply (
    select 
      ServiceUnits = sum(clms.SERVICE_UNITS) 
    from dbo.Transmission_Record_Claims as trc 
    join dbo.CLAIM_Claim                as clms on clms.CLAIM_ID = trc.claim_id
    where ((trc.transmission_id = tr.Transmission_ID))
  ) as cd

  where (
        (tsc.CLIENT_ID is not null) /* For index */
	and (tsc.TRANSMISSION_DATE between @startDate and @endDate)
    and (tr.UseForBilling = 1)
  )

  order by /* For index so we can use presort tx date.  Presort needed to get date tx aggregate order correct */
      tsc.CLIENT_ID
	, tsc.TRANSMISSION_DATE
)
,
cte_p2
as
(
  select 
	  p1.CLIENT_ID
	, p1.RevenueSharingCategoryLEA
	, p1.InvoiceRate
	, p1.WhenToInvoice
	, [TotalClaimsSubmitted]   = sum(p1.TOTAL_NUMBER_CLAIMS)
	, [TotalServiceUnits]      = sum(p1.ServiceUnits)
	, [TotalAmountSubmitted]   = sum(p1.TOTAL_DOLLAR_AMOUNT)	 
	, [DatesTransmitted]       = STRING_AGG(p1.TRANSMISSION_DATE_STR,', ')
	, [FilesTransmitted]       = STRING_AGG(p1.fileName,', ')    

  from cte_p1 as p1
  
  where (
        (1=1)
    and ((@clientID is null) or (p1.CLIENT_ID = @clientID))
  )

  group by 
	  p1.CLIENT_ID
	, p1.RevenueSharingCategoryLEA
	, p1.InvoiceRate
	, p1.WhenToInvoice	
	
)
,
cte_p3
as
(
  select 
      p2.DatesTransmitted
    , cca.CLIENT_NAME
    , cca.REP_NAME        
    , p2.FilesTransmitted
    , p2.TotalClaimsSubmitted
    , p2.TotalServiceUnits
    , p2.TotalAmountSubmitted
    , p2.WhenToInvoice
    , p2.InvoiceRate
    , p2.RevenueSharingCategoryLEA
	, @startDate as [start_date]
	, @endDate   as [end_date]
  from cte_p2 as p2
  join dbo.CLIENTS_Client_All as cca on cca.CLIENT_ID = p2.CLIENT_ID
  where (
        (1=1)
    and ((@repID is null) or (cca.REP_ID = @repID))
  )
)
select top (dbo.CONST_MAX_ROWS()) 
  * 
from cte_p3
order by 
  CLIENT_NAME
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[RPT_Claims_Transmissions_Summary] TO [webuser]
GO   

