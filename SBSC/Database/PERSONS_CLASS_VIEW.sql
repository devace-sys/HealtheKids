USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PERSONS_CLASS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PERSONS_CLASS_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/


CREATE FUNCTION [dbo].[PERSONS_CLASS_VIEW] (
   @userID                 BIGINT    
 , @userGroup              INT
 , @userRank               INT
 , @classPartition         INT  
 , @parentID               BIGINT
 , @term                   varchar(256)
 , @active                 BIT
 , @recID                  BIGINT
 
)

RETURNS TABLE
AS
RETURN
(  
select top (dbo.CONST_MAX_ROWS())
       id             = ID
	, name           = NAME
	, description    = DESCRIPTION
	, classPartition = CLASS_PARTITION
	, parentID       = PARENT_ID
	, active         = ACTIVE
from dbo.PERSONS_CLASS_VIEW_CORE(@userID, @userGroup, @userRank, @classPartition, @parentID, @active, @recID)  
where (
      (1=1)
  and ((@term is null) or (NAME like (isnull(@term,'') + '%')))  
)
order by 
  name
)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PERSONS_CLASS_VIEW] TO [webuser]
GO