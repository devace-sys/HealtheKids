USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.GET_PLAN_WRITER_SVC_CLASS_NAME_ID_FROM_GROUP_ID') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.GET_PLAN_WRITER_SVC_CLASS_NAME_ID_FROM_GROUP_ID
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[GET_PLAN_WRITER_SVC_CLASS_NAME_ID_FROM_GROUP_ID] (
  @groupID bigint
)

RETURNS bigint
WITH SCHEMABINDING 
AS     
BEGIN        
 
  declare @rdrGroupSvcClassNameID as bigint = null 
  select top 1       
     @rdrGroupSvcClassNameID = png.GROUP_SERVICE_CLASS_NAME_ID      
  from dbo.GROUP_GROUP_SERVICE_CLASS_PARTITIONS_NAMES_GROUPS as png     
  where ( 
       (png.GROUP_SERVICE_CLASS_PARTITION_ID = 4)
   and (png.GROUP_ID                         = @groupID)
  )
  return @rdrGroupSvcClassNameID 
END    
GO  
