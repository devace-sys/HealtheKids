USE SPEDMON
GO

/*-------------------------------
 * Consulidate later
 *------------------------------*/

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLAIM_SERVICE_NAME_XREF_AND_FORM_DATA_SINGLE_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CLAIM_SERVICE_NAME_XREF_AND_FORM_DATA_SINGLE_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/    
    
CREATE FUNCTION [dbo].[CLAIM_SERVICE_NAME_XREF_AND_FORM_DATA_SINGLE_VIEW] (     
    @userID              BIGINT
  , @userGroup           INT    
  , @userRank            INT
  , @clientID            BIGINT
  , @planTypeID          BIGINT
  , @groupID             BIGINT
  , @nameID              BIGINT
  , @active              BIT 
  , @recID               BIGINT 
) 
RETURNS TABLE 
AS RETURN
(      

with
cte_client_specific
as
(
 select top 1 
     t1.*
   , displayOrder = 1 
 from dbo.CLAIM_SERVICE_NAME_XREF_AND_FORM_DATA_VIEW_CORE (@clientID,@planTypeID, @groupID, @nameID, null, 1, @active, @recID) as t1
)
,
cte_general
as
(
  select top 1 
      t2.*
	, displayOrder = 2
  from dbo.CLAIM_SERVICE_NAME_XREF_AND_FORM_DATA_VIEW_CORE (null, @planTypeID, @groupID, @nameID, null, 0, @active, @recID) as t2
)
,

cte_combine 
as
(
  select top 1 t1.* from cte_client_specific as t1
  union all
  select top 1 t2.* from cte_general         as t2

)

select top 1 
  cc.*
from cte_combine as cc
order by 
  displayOrder asc
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CLAIM_SERVICE_NAME_XREF_AND_FORM_DATA_SINGLE_VIEW] TO [webuser]
GO