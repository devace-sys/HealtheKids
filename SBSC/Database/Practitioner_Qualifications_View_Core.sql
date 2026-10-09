USE SPEDMON
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Practitioner_Qualifications_View_Core') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.Practitioner_Qualifications_View_Core
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[Practitioner_Qualifications_View_Core] (
    @clientID                bigint
  , @pracID                  bigint
  , @clientActive            bit
  , @pracCurrentlyWithClient bit
  , @pracActive              bit
)
    
returns table     
as
 
return 
(    
with
cte_p0
as
(
  select top 1
      q1.*
    , defaultExpiresInDays = datediff(day,q1.currentDate,q1.minDate)
  from
  (
    select top 1 
      currentDate = convert(date,getdate())
    , minDate     = convert(date,'1/1/1900')
	, maxDate     = convert(date,'12/31/9999')
  ) as q1

)
,
cte_p1
as
(

select 
    p0.* 
  , t1.*

from cte_p0 as p0

cross apply (
    select 
        clientID   = clc.CLIENT_ID
	  , clientName = clc.CLIENT_NAME 
    from dbo.CLIENTS_Client as clc
    where ( 
          (1=1)
      and ((@clientID     is null) or (clc.CLIENT_ID = @clientID))
      and ((@clientActive is null) or (clc.LEA       = @clientActive))      
	)
  ) as t1
)
,
cte_p2
as
(
  select 
	  
	  p1.*
    , t1.*

  from cte_p1 as p1
  
  cross apply ( 
  
   select 
        pracID        = prp.PRACTITIONER_ID
	  , lastName      = prp.LAST_NAME
	  , firstName     = prp.FIRST_NAME
	  , dispGroupID   = pgd.GROUP_ID
	  , dispGroupName = ggd.GROUP_NAME   
      , npiNumber     = isnull(prp.npiNumber,'')
	  , prp.employeeRelationshipID
	  , leaBopSubmitClaims = prp.SUBMIT_CLAIMS
	  , prp.cybhiSubmitClaims
	  , qualificationsJSONData = isnull(prp.qualificationsJSONData,'[]')
      , pracCreatedOn = prp.DATE_CREATED
	  
	from dbo.PRACTITIONER_Client       as prc
	join dbo.PRACTITIONER_Practitioner as prp on prp.PRACTITIONER_ID = prc.PRACTITIONER_ID
    join dbo.PRACTITIONER_GROUPS       as pgd on (     (pgd.PRACTITIONER_ID = prp.PRACTITIONER_ID)
                                                   and (pgd.GROUP_TYPE in (1,2))
                                                   and (pgd.GROUP_ID           is not null)
                                                   and (pgd.PRACTITIONER_GROUP is not null))
		  							               and (pgd.ACTIVE = 1)

    join dbo.GROUP_Group as ggd on ggd.GROUP_ID = pgd.GROUP_ID
	
	where (
	      ((prc.CLIENT_ID = p1.clientID)
	  and ((@pracID     is null)              or (prc.PRACTITIONER_ID = @pracID)))
      and ((@pracActive is null)              or (prp.ACTIVE          = @pracActive))
	  and ((@pracCurrentlyWithClient is null) or (prp.currentlyWithClient = @pracCurrentlyWithClient))
	  --and (pgd.GROUP_ID not in (8,12,52,28,54,274,275,276)) /* Exclude disps that dont have quals */
    )
  ) as t1
)
select 
       p2.* 
     , hasQualificationsData = convert(bit,iif(p2.qualificationsJSONData = '[]',0,1))
     , primaryQualification  = isnull(t2.primaryQualification,1)
	 , pracTypeID            = isnull(t2.pracTypeID, p2.dispGroupID)   
	 , pracTypeName          = isnull(t2.pracTypeName, p2.dispGroupName)  
	 , licenseNum            = isnull(t2.licenseNum,'')
	 , startDate             = isnull(t2.startDate,p2.minDate) 
     , endDate               = isnull(t2.endDate,  p2.minDate)
	 , fullName      = isnull(t2.fullName, '')
	 , isLifetime    = isnull(t2.isLifetime,0)
     , expiresInDays = isnull(t2.expiresInDays, p2.defaultExpiresInDays)
	 , ranking       = isnull(t2.ranking,1) 
from cte_p2 as p2

outer apply (
    select 
      t1.*
    from dbo.Practitioner_Qualifications_Parse_JSON_Data_Core (   p2.currentDate
	                                                            , p2.minDate
																, p2.maxDate
																, p2.dispGroupID
																, p2.qualificationsJSONData) as t1
) as t2

)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[Practitioner_Qualifications_View_Core] TO [webuser]
GO
