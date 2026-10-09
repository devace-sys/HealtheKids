USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CYBHI_TRANSMISSION_GENERATION_GET_SITES') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CYBHI_TRANSMISSION_GENERATION_GET_SITES
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CYBHI_TRANSMISSION_GENERATION_GET_SITES] (
  @transmissionID bigint  
)

RETURNS TABLE

/***************************************************************************    
 * CYBHI_TRANSMISSION_GENERATION_GET_SITES */    
/**    
 * We get the site data based on the claims in the tx
 * We also preformat the site data so its compatible with the 837
 ***************************************************************************/            

AS RETURN (

with
cte_p1
as
(
  select 
      q1.siteID
    , charsToRemove = '~*:^'
  from
  (
    select distinct 
      cctc.siteID     
    from dbo.CYBHI_CLAIM_TRANSMISSION_CLAIMS as cctc
    where (
            ((cctc.transmissionID = @transmissionID) and (cctc.id > 0))
	    and (cctc.siteID is not null)
    )
  ) as q1
)
,
cte_p2
as
(
  select
      p1.siteID 
    , siteNameStr    = dbo.STRING_REMOVE_CHARS(dbo.STRING_REMOVE_NON_ALPHA_NUMERIC(ss.SITE_NAME,1,1,1,1,100),p1.charsToRemove,null)
    , siteAddressStr = dbo.STRING_REMOVE_CHARS(dbo.STRING_REMOVE_NON_ALPHA_NUMERIC(sa.ADDRESS_1,1,1,1,0,55),p1.charsToRemove,null)
    , siteCityStr    = dbo.STRING_REMOVE_CHARS(dbo.STRING_REMOVE_NON_ALPHA_NUMERIC(sa.CITY,1,1,1,0,30),p1.charsToRemove,null)
    , siteStateStr   = dbo.STRING_REMOVE_CHARS(dbo.STRING_REMOVE_NON_ALPHA_NUMERIC(sa.[STATE],0,0,1,0,2),p1.charsToRemove,null)
    , siteZip5Str    = dbo.STRING_REMOVE_CHARS(dbo.STRING_REMOVE_NON_ALPHA_NUMERIC(sa.ZIP,0,1,0,0,5),p1.charsToRemove,null)
	, siteZip4Str    = dbo.STRING_REMOVE_CHARS(dbo.STRING_REMOVE_NON_ALPHA_NUMERIC(sa.ZIP_PLUS_FOUR,0,1,0,0,4),p1.charsToRemove,null)
    , sitePhoneStr   = dbo.STRING_REMOVE_CHARS(dbo.STRING_REMOVE_NON_ALPHA_NUMERIC(sa.PHONE_NUMBER,0,1,0,0,10),p1.charsToRemove,null) 
    , siteApproved   = ss.cybhiTpaApproved

  from      cte_p1                 as p1
  join      dbo.SITES_Site         as ss on ss.SITE_ID  = p1.siteID
  left join dbo.SITES_ADDRESS      as sa on sa.SITE_ID  = ss.SITE_ID
)
,
cte_p3
as
(
  select 
      p2.* 
    , t1.internalSite
    , t2.dataComplete
  
  from cte_p2 as p2
  
  cross apply (
  
    select top 1 
      internalSite = convert(bit,case 
    when p2.siteNameStr = dbo.CONST_UNKNOWN_SCHOOL_NAME()    then 1
    when p2.siteNameStr = dbo.CONST_NON_PUBLIC_SCHOOL_NAME() then 1
    else 0
   end )
  ) as t1

  cross apply (
    select top 1 
      dataComplete = convert (bit, case 
        when p2.siteNameStr    = ''    then 0
	    when p2.siteAddressStr = ''    then 0
	    when p2.siteCityStr    = ''    then 0
	    when p2.siteStateStr   = ''    then 0
	    when p2.siteZip5Str    = ''    then 0
        when p2.siteZip4Str    = ''    then 0
	    else 1
   end)
  ) as t2
)
select 
  p3.* 
from cte_p3 as p3

)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[CYBHI_TRANSMISSION_GENERATION_GET_SITES] TO [webuser]
GO