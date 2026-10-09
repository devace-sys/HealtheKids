USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLIENT_COMPLIANCE_ITEMS_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION CLIENT_COMPLIANCE_ITEMS_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[CLIENT_COMPLIANCE_ITEMS_VIEW_CORE] (
    @taskID	bigint
  , @active bit
  , @recID  bigint

)    
 
RETURNS TABLE
  
AS RETURN
( 
  select
	  cci.id

	, taskID   = cct.id
	, taskName = cct.[name]
	
	, dueDate		  = cci.dueDate
	, dueDateStr	  = dbo.RPT_DATE_FMT(cci.dueDate)
	, dueDateStrYMD   = dbo.RPT_DATE_FMT_YYYY_MM_DD(cci.dueDate)
	 
	, dateToShowOnDashboard		  = cci.dateToShowOnDashboard
	, dateToShowOnDashboardStr	  = dbo.RPT_DATE_FMT(cci.dateToShowOnDashboard)
	, dateToShowOnDashboardStrYMD = dbo.RPT_DATE_FMT_YYYY_MM_DD(cci.dateToShowOnDashboard)


  from dbo.CLIENT_COMPLIANCE_ITEMS as cci
  join dbo.CLIENT_COMPLIANCE_TASKS as cct on cct.id = cci.taskID


  where (
		 (1=1)
	 and (( @taskID is null)        OR (cci.taskID = @taskID))
	 and (( @active is null)        OR (cci.active = @active))
	 and (( @recID is null)         OR (cci.id = @recID))

  )
)

GO

GRANT SELECT ON  [dbo].[CLIENT_COMPLIANCE_ITEMS_VIEW_CORE] TO [webuser]
GO
