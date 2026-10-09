USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CYBHI_SITES_VIEW_DATA_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CYBHI_SITES_VIEW_DATA_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CYBHI_SITES_VIEW_DATA_CORE] (
  @clientID  bigint  
)

RETURNS TABLE

/***************************************************************************    
 * CYBHI_SITES_VIEW_DATA_CORE */    
/**    
 * We determine what sites are cybhi sites based on service records
 * We also preformat the site data so its compatible with the SPI roster
 ***************************************************************************/            

AS RETURN (

with
cte_p1
as
(
  select top 1 
      clientID      = clc.CLIENT_ID
    , clientName    = clc.CLIENT_NAME
    , clientCDS     = trim(isnull(clc.CLIENT_CDS,N''))
    , startDOS      = convert(datetime, '7/1/2024')   /* Earliest claimable cybhi date */
	, charsToRemove = '~*:^'
  from dbo.CLIENTS_Client as clc
  where 
    (clc.CLIENT_ID = @clientID)
)
,
cte_p2
as
(
  select        
      p1.clientID
	, p1.clientName
	, p1.clientCDS
	, p1.charsToRemove
	, sr2.siteID
	, sr2.numSvcs
  from cte_p1 as p1
  cross apply (
    select 
	    sr1.siteID
      , numSvcs = count(sr1.id)
	from dbo.SERVICE_RECORDS as sr1
    where (
	  /* Uses index */
	      ((sr1.clientID = p1.clientID)
	  and (sr1.patID is not null)
	  and (sr1.dos >= p1.startDOS)
	  and (sr1.groupID is not null)
	  and (sr1.planType = 4)
	  and (sr1.nameID is not null)
	  and (sr1.id is not null))
	  and (sr1.state not in (99,199))
    )
    group by 
      sr1.siteID
  ) as sr2
)
,
cte_p3
as
(
  select 
     p2.clientID
   , p2.siteID
   , p2.numSvcs
   , p2.clientName
   , p2.clientCDS
   , siteCDS        = trim(isnull(ss.SITE_CDS,N''))
   , siteNameStr    = dbo.STRING_REMOVE_CHARS(dbo.STRING_REMOVE_NON_ALPHA_NUMERIC(ss.SITE_NAME,1,1,1,1,100),p2.charsToRemove,null)
   , siteAddressStr = dbo.STRING_REMOVE_CHARS(dbo.STRING_REMOVE_NON_ALPHA_NUMERIC(sa.ADDRESS_1,1,1,1,0,55),p2.charsToRemove,null)
   , siteCityStr    = dbo.STRING_REMOVE_CHARS(dbo.STRING_REMOVE_NON_ALPHA_NUMERIC(sa.CITY,1,1,1,0,30),p2.charsToRemove,null)
   , siteStateStr   = dbo.STRING_REMOVE_CHARS(dbo.STRING_REMOVE_NON_ALPHA_NUMERIC(sa.[STATE],0,0,1,0,2),p2.charsToRemove,null)
   , siteZip5Str    = dbo.STRING_REMOVE_CHARS(dbo.STRING_REMOVE_NON_ALPHA_NUMERIC(sa.ZIP,0,1,0,0,5),p2.charsToRemove,null)
   , siteZip4Str    = dbo.STRING_REMOVE_CHARS(dbo.STRING_REMOVE_NON_ALPHA_NUMERIC(sa.ZIP_PLUS_FOUR,0,1,0,0,4),p2.charsToRemove,null)
   , sitePhoneStr   = dbo.STRING_REMOVE_CHARS(dbo.STRING_REMOVE_NON_ALPHA_NUMERIC(sa.PHONE_NUMBER,0,1,0,0,10),p2.charsToRemove,null) 

from      cte_p2                 as p2
join      dbo.SITES_Site         as ss on ss.SITE_ID  = p2.siteID
left join dbo.SITES_ADDRESS      as sa on sa.SITE_ID = ss.SITE_ID

)

select

    p3.* 
  , t1.internalSite
  , t2.dataComplete

from cte_p3 as p3

cross apply (
  select top 1 
    internalSite = convert(bit, case 
      when p3.siteNameStr = dbo.CONST_UNKNOWN_SCHOOL_NAME()    then 1
      when p3.siteNameStr = dbo.CONST_NON_PUBLIC_SCHOOL_NAME() then 1
      else 0
   end )
) as t1

cross apply (
    select top 1 
      dataComplete = convert (bit, case 
        when p3.siteNameStr    = ''    then 0
	    when p3.siteAddressStr = ''    then 0
	    when p3.siteCityStr    = ''    then 0
	    when p3.siteStateStr   = ''    then 0
	    when p3.siteZip5Str    = ''    then 0
        when p3.siteZip4Str    = ''    then 0
	    when p3.sitePhoneStr   = ''    then 0
		else 1
   end )
  ) as t2

)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[CYBHI_SITES_VIEW_DATA_CORE] TO [webuser]
GO