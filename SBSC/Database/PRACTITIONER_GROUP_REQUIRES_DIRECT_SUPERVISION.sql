USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTITIONER_GROUP_REQUIRES_DIRECT_SUPERVISION') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PRACTITIONER_GROUP_REQUIRES_DIRECT_SUPERVISION
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[PRACTITIONER_GROUP_REQUIRES_DIRECT_SUPERVISION] ( 
  @groupID bigint
)
RETURNS BIT
AS     
BEGIN    
  if exists (
   select top 1 
     ggdss.ID
   from dbo.GROUP_GROUP_DIRECT_SUPERVISED_SUPERVISOR as ggdss 
   where (
            (ggdss.SUPERVISED_GROUP_ID = @groupID)
        and (ggdss.approveServiceRecords = 0)
    )
  )
  begin
    return 1
  end

  return 0

END  
GO
