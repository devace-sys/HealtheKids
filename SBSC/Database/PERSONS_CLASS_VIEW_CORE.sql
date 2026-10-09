USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PERSONS_CLASS_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PERSONS_CLASS_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/


CREATE FUNCTION [dbo].[PERSONS_CLASS_VIEW_CORE] (
   @userID                 BIGINT    
 , @userGroup              INT
 , @userRank               INT
 , @classPartition         INT  
 , @parentID               BIGINT
 , @active                 BIT
 , @recID                  BIGINT
 
)

RETURNS TABLE
AS
RETURN
(  
  select  
    *
  from dbo.PERSONS_CLASS
  where ( 
        (1=1)
    and ((@classPartition is null) or (CLASS_PARTITION = @classPartition))
    and ((@parentID       is null) or (PARENT_ID       = @parentID))
    and ((@active         is null) or (ACTIVE          = @active))
    and ((@recID          is null) or (ID              = @recID))
  )  
)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PERSONS_CLASS_VIEW_CORE] TO [webuser]
GO