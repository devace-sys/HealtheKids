USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SVCJOURNAL_JOURNAL_PRESCRIBED_ORDERS_Audit_View') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION SVCJOURNAL_JOURNAL_PRESCRIBED_ORDERS_Audit_View
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[SVCJOURNAL_JOURNAL_PRESCRIBED_ORDERS_Audit_View] (
    @userID         BIGINT    
  , @userGroup      BIGINT    
  , @userRank       INT
  , @modifiedBy     BIGINT
  , @recordID       BIGINT
)    
RETURNS 
TABLE
AS
RETURN
(
    select top (dbo.CONST_MAX_ROWS())
	    [name]   = ua.[userName]
	  , [action] = iif((spoa.SAVE_TYPE = 1),'Created','Modfied')
	  , [date]   = CONVERT(varchar(50), spoa.MODIFIED_ON)
	  --, [data]  = '{"data_before": "", "data_after": ""}' /* TODO: Remove this once its confirmed there are no remaining dependencies */

  from dbo.[SvcJournal_Prescribed_Orders_Audit] as spoa

  cross apply ( 
    select top 1 
	  ua1.userName 
	from [users].[dbo].USERS_ALL as ua1
	where 
	  (ua1.id = spoa.MODIFIED_BY)
  ) as ua     
    
  where ( 
        (1=1)
	and ((@recordID   is null) or (spoa.RECORD_ID   = @recordID))
    and ((@modifiedBy is null) or (spoa.MODIFIED_BY = @modifiedBy))
  )

  order by 
    spoa.id desc /* Latest entries first */
)
GO

GRANT SELECT ON  [dbo].[SVCJOURNAL_JOURNAL_PRESCRIBED_ORDERS_Audit_View] TO [webuser]
GO
