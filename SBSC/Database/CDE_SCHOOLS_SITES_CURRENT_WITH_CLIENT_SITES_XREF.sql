USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[CDE_SCHOOLS_SITES_CURRENT_WITH_CLIENT_SITES_XREF]'))
DROP VIEW [dbo].[CDE_SCHOOLS_SITES_CURRENT_WITH_CLIENT_SITES_XREF]
GO

CREATE VIEW [dbo].[CDE_SCHOOLS_SITES_CURRENT_WITH_CLIENT_SITES_XREF] 
AS 

/***************************************************************************    
 * CDE_SCHOOLS_SITES_CURRENT_WITH_CLIENT_SITES_XREF */
/**    
 *
 * @returns table
 ***************************************************************************/     


select
    *
  , CLIENT_SITE_HAS_CLIENT  =  convert(bit,case when (CLIENT_ID is null) then 0 else 1 end)
  , CLIENT_SITE_HAS_SITE    =  convert(bit,case when (SITE_ID is null) then 0 else 1 end)
  , CLIENT_SITE_HAS_ADDRESS =  convert(bit,case when ((CLIENT_SITE_ADDRESS_1 != '') and (CLIENT_SITE_CITY != '') and (CLIENT_SITE_STATE != '') and (CLIENT_SITE_ZIP5 != '')) then 1 else 0 end) 
  
from
(
  select 
      cde.*
    , cc.CLIENT_ID
    , CLIENT_ACTIVE_LEA = cc.LEA
    , CLIENT_ACTIVE_MAA = cc.MAA
    , ss.SITE_ID 
    , SITE_ACTIVE = ss.ACTIVE
    , sa.SITE_ADDRESS_ID
    , CLIENT_NAME            = ltrim(rtrim(isnull(cc.CLIENT_NAME,   '')))
    , SITE_NAME              = ltrim(rtrim(isnull(ss.SITE_NAME,     '')))
    , CLIENT_SITE_ADDRESS_1  = ltrim(rtrim(isnull(sa.ADDRESS_1,     '')))
    , CLIENT_SITE_ADDRESS_2  = ltrim(rtrim(isnull(sa.ADDRESS_2,     '')))
    , CLIENT_SITE_CITY       = ltrim(rtrim(isnull(sa.CITY,          '')))
    , CLIENT_SITE_STATE      = ltrim(rtrim(isnull(sa.STATE,         '')))
    , CLIENT_SITE_ZIP5       = ltrim(rtrim(isnull(sa.ZIP,           '')))
    , CLIENT_SITE_ZIP4       = ltrim(rtrim(isnull(sa.ZIP_PLUS_FOUR, '')))
 
  from      dbo.CDE_SCHOOLS_SITES_CURRENT as cde
  left join dbo.CLIENTS_CLIENT            as cc on  cc.CLIENT_CDS     = cde.CDSCodeFirst7 
  left join dbo.SITES_SITE                as ss on  ss.SITE_CLIENT_ID = cc.CLIENT_ID
                                                and ss.SITE_CDS       = cde.CDSCodeLast7
  left join dbo.SITES_ADDRESS             as sa on  sa.SITE_ID        = ss.SITE_ID

  where (cde.HasCDSCode = 1)
) as q0

GO
