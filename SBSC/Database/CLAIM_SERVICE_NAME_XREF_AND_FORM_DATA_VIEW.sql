USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLAIM_SERVICE_NAME_XREF_AND_FORM_DATA_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CLAIM_SERVICE_NAME_XREF_AND_FORM_DATA_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/    
    
CREATE FUNCTION [dbo].[CLAIM_SERVICE_NAME_XREF_AND_FORM_DATA_VIEW] (     
    @userID              BIGINT
  , @userGroup           INT    
  , @userRank            INT
  , @clientID            BIGINT
  , @planTypeID          BIGINT
  , @groupID             BIGINT
  , @nameID              BIGINT
  , @groupSvcClassNameID BIGINT
  , @svcTypeID           int
  , @term                varchar(255)
  , @hasClientID         BIT
  , @active              BIT 
  , @recID               BIGINT 
) 
RETURNS TABLE 


AS RETURN (      

with
cte_p1
as
(
select 
     t1.*
   , groupRequiresSupervisionStr = dbo.RPT_BIT_TO_YN(t1.groupRequiresSupervision)

from dbo.CLAIM_SERVICE_NAME_XREF_AND_FORM_DATA_VIEW_CORE (     
    @clientID 
  , @planTypeID
  , @groupID
  , @nameID
  , @groupSvcClassNameID
  , @hasClientID
  , @active
  , @recID) as t1
  where (
         (1=1)
     and ((@svcTypeID is null) or (t1.svcTypeId = @svcTypeID))
  )
)
,
cte_p2
as
(
select
    p1.* 
  , [name] =  p1.groupName 
            + '<br>'
			+ p1.[planTypeName]
			+ ' > ' 
			+ p1.svcName
from cte_p1 as p1
where ( 
       (1=1)
  and ((@term is null) or (p1.[svcNameWithCalpadsCode] like ('%' + trim(isnull(@term,'')) + '%')))
)
)
select top (dbo.CONST_MAX_ROWS()) 
  p2.*
from cte_p2 as p2
order by 
  p2.name asc
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CLAIM_SERVICE_NAME_XREF_AND_FORM_DATA_VIEW] TO [webuser]
GO