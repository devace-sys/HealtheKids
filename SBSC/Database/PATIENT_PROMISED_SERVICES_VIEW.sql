USE SPEDMON
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_PROMISED_SERVICES_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PATIENT_PROMISED_SERVICES_VIEW
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[PATIENT_PROMISED_SERVICES_VIEW] (
    @userID                BIGINT    
  , @userGroup             INT    
  , @userRank              INT     
  , @clientID              bigint     
  , @patID                 bigint
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
    ppsvc.*
  from dbo.PATIENT_PROMISED_SERVICES_VIEW_CORE (@clientID, @patID, null, @term, @refDate, @recID, @canEdit, @active, getdate()) as ppsvc
)

select top (dbo.CONST_MAX_ROWS())
    p1.*
from cte_p1 as p1 

order by 
  p1.spEdServiceCode asc
, p1.startDate       desc
, p1.endDate         desc
 
)
 
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PATIENT_PROMISED_SERVICES_VIEW] TO [webuser]
GO