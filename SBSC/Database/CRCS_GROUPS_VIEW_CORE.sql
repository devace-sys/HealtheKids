USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CRCS_GROUPS_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CRCS_GROUPS_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[CRCS_GROUPS_VIEW_CORE] (
	@grpSvcClassNameID bigint
)
     
RETURNS TABLE  
AS RETURN(

	select
		  grpSvcClassNameID = gg.GROUP_SERVICE_CLASS_NAME_ID
		, grpSvcClassName   = gg.GROUP_SERVICE_CLASS_NAME
		, displayOrder      = cgd.displayOrder
	from dbo.GROUP_GROUP_SERVICE_CLASS_NAMES as gg
	left join dbo.CRCS_GROUPS_DISPLAY_ORDER as cgd on cgd.grpSvcClassNameID = gg.GROUP_SERVICE_CLASS_NAME_ID
	where (
		( 
			exists (select top 1 GROUP_SERVICE_CLASS_NAME_ID from dbo.GROUP_GROUP_SERVICE_CLASS_PARTITIONS_NAMES_GROUPS
					where GROUP_SERVICE_CLASS_PARTITION_ID = 600
					and GROUP_SERVICE_CLASS_NAME_ID = gg.GROUP_SERVICE_CLASS_NAME_ID)		
		)
		and 
		(
			(@grpSvcClassNameID is null) or (gg.GROUP_SERVICE_CLASS_NAME_ID = @grpSvcClassNameID)
		)
	)
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CRCS_GROUPS_VIEW_CORE] TO [webuser]
GO