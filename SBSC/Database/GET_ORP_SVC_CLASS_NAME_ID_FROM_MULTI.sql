USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.GET_ORP_SVC_CLASS_NAME_ID_FROM_MULTI') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.GET_ORP_SVC_CLASS_NAME_ID_FROM_MULTI
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[GET_ORP_SVC_CLASS_NAME_ID_FROM_MULTI] (
    @groupSvcClassNameID bigint
  , @groupID             bigint
  , @pracID              bigint
)
RETURNS bigint
AS     
BEGIN          
  if (@groupSvcClassNameID is not null)  return @groupSvcClassNameID
  if (@groupID             is not null)  return dbo.GET_ORP_SVC_CLASS_NAME_ID_FROM_GROUP_ID (@groupID)
  if (@pracID              is not null)  return dbo.GET_ORP_SVC_CLASS_NAME_ID_FROM_PRAC_ID  (@pracID)
  return null
END    
GO  
