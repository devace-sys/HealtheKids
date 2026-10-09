USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CYBHI_SITE_LIST_AUDIT_RPT') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CYBHI_SITE_LIST_AUDIT_RPT
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CYBHI_SITE_LIST_AUDIT_RPT] (
  @clientID  BIGINT
)

/***************************************************************************    
 * CYBHI_SITE_LIST_AUDIT_RPT */    
/**    
 * Returns complete list of sites that CYBHI services have been recorded at
 * and if the data we have for each site is complete
 *
 * This is essentially a pass through routine for dbo.CYBHI_SITES_VIEW_DATA_CORE
 * 
 * Notes: 
 *
 * 1. The TPA does not require the last 4 digits of the ZIP but the 837P spec requires it.
 * 2. The 837P spec does not require a phone number for the site but the TPA requiries it.
 ***************************************************************************/            

RETURNS TABLE

AS RETURN (
  with
  cte_p1
  as
  (
    select 
        t1.* 
      , cds7IsXCode = dbo.CDS_7_IS_X_CODE(t1.siteCDS)
	from dbo.CYBHI_SITES_VIEW_DATA_CORE (@clientID) as t1
  )

  select top (dbo.CONST_MAX_ROWS())
      [Client Name]            = t1.clientName
	, [Site Name]              = t1.siteNameStr    
    , [Data Complete]          = dbo.RPT_BIT_TO_YN (t1.dataComplete)
    , [District Internal Site] = dbo.RPT_BIT_TO_YN(t1.cds7IsXCode)
    , [CDS Code]               = iif((t1.cds7IsXCode = 0),(t1.clientCDS + t1.siteCDS),'')
    , [Address]                = t1.siteAddressStr 
    , [City]                   = t1.siteCityStr    
    , [State]                  = t1.siteStateStr   
    , [Zip Code]               = t1.siteZip5Str + t1.siteZip4Str  
    , [Phone]                  = t1.sitePhoneStr
    
    , [SpEdCare Site ID]       = t1.siteID
    , [SpEdCare ClientID]      = t1.clientID

  from cte_p1 as t1
  where 
    (t1.internalSite = 0)

  order by     	
	t1.siteNameStr  asc	
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[CYBHI_SITE_LIST_AUDIT_RPT] TO [webuser]
GO