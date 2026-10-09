USE users
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.TELECOMM_SESSION_FORM_AND_SIGNATURE_DATA_VIEW_LATEST_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.TELECOMM_SESSION_FORM_AND_SIGNATURE_DATA_VIEW_LATEST_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[TELECOMM_SESSION_FORM_AND_SIGNATURE_DATA_VIEW_LATEST_CORE] ( 
  @sessionID    bigint
)
RETURNS TABLE 
AS
RETURN 
(

/***************************************************************************
 * TELECOMM_SESSION_FORM_AND_SIGNATURE_DATA_VIEW_LATEST_CORE*/
/**
 * Displays data
 *
 * @return                 Table
 ***************************************************************************/ 

with
cte_p1
as
(
select distinct  
    tss1.sigClassName
  , tss1.ctrlAdditionalDataID
from dbo.TELECOMM_SESSIONS_SIGNATURES as tss1
where 
  (tss1.telecommSessionID = @sessionID) and (sigClassName != 'attendanceroster')
)
,
cte_p2
as
(

select   
  
    formID   = tss1.ctrlAdditionalDataID
  , formData = tss2.sigAdditionalData

from cte_p1 as tss1

cross apply (
  select top 1
    tsfsvc.sigAdditionalData 
  from dbo.TELECOMM_SESSION_FORM_SIGNATURES_VIEW_CORE ( @sessionID, tss1.sigClassName) as tsfsvc  
  order by 
    tsfsvc.signatureID desc
) as tss2
)
,
cte_p3
as
(
  select top 1
      tsfd.formID
    , formDataJSON = tsfd.formData 
  from dbo.TELECOMM_SESSIONS_FORM_DATA as tsfd
  where 
    (tsfd.telecommSessionID = @sessionID)
  order by 
    tsfd.id desc
  union all

  select 
    p2.formID
  , formDataJSON = p2.formData
 from cte_p2 as p2
)
select * from cte_p3


)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON [dbo].[TELECOMM_SESSION_FORM_AND_SIGNATURE_DATA_VIEW_LATEST_CORE] TO [webuser]
GO


