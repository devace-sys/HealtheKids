USE SPEDMON
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_ACCOMMODATIONS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PATIENT_ACCOMMODATIONS_VIEW
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[PATIENT_ACCOMMODATIONS_VIEW] (
    @userID                BIGINT    
  , @userGroup             INT    
  , @userRank              INT     
  , @clientID              bigint     
  , @patID                 bigint
  , @recordType            int
  , @refDate               date
  , @term				   VARCHAR(50)
  , @recID                 bigint    
  , @canEdit               bit
  , @active                BIT
)
    
returns table     
as
 
return 
(    
with
cte_p1
as
(
  select 
    pavc.*
  from dbo.PATIENT_ACCOMMODATIONS_VIEW_CORE (@clientID, @patID, @recordType, @term, @refDate, @recID, @canEdit, @active, getdate()) as pavc
)
select top (dbo.CONST_MAX_ROWS())
    p1.*
from cte_p1 as p1 
order by 
  p1.recordType   asc
, p1.categoryName  asc
, p1.accommodation asc
 
)
 
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PATIENT_ACCOMMODATIONS_VIEW] TO [webuser]
GO