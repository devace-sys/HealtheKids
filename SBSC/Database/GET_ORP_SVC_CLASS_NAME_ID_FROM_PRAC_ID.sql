USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.GET_ORP_SVC_CLASS_NAME_ID_FROM_PRAC_ID') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.GET_ORP_SVC_CLASS_NAME_ID_FROM_PRAC_ID
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[GET_ORP_SVC_CLASS_NAME_ID_FROM_PRAC_ID] (
  @pracID bigint
)
RETURNS bigint
AS     
BEGIN         
  declare @groupID as bigint = null
  set @groupID = dbo.GET_DISP_GROUP_FROM_PRAC_ID(@pracID)  
  return dbo.GET_ORP_SVC_CLASS_NAME_ID_FROM_GROUP_ID(@groupID)  
END    
GO  
