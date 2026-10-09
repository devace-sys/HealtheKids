USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.FILE_CLASS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.FILE_CLASS_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[FILE_CLASS_VIEW] (    
   @userID      BIGINT
 , @userGroup   INT  
 , @userRank    INT
 , @recID       BIGINT
 , @canEdit     BIT
 , @active      BIT
 , @name        varchar(50)
)    

RETURNS TABLE
 
 /***************************************************************************    
  * FILE_CLASS_VIEW */    
 /**    
  * Returns a list of file classes for uploads
  *
  * @return table 
  ***************************************************************************/                         
     
AS RETURN
(

select top (dbo.CONST_MAX_ROWS()) 
  * 
from dbo.FILE_CLASSES
where (
      (1=1)
  and ((@recID is null)   or (id = @recID))
  and ((@name  is null)   or (name like ltrim(rtrim(isnull(@name,'') + '%'))))
  
)
order by name

)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[FILE_CLASS_VIEW] TO [webuser]
GO   
