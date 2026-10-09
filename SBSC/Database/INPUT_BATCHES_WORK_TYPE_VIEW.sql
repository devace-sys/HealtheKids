USE [SPEDMON]
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.INPUT_BATCHES_WORK_TYPE_VIEW') AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.INPUT_BATCHES_WORK_TYPE_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[INPUT_BATCHES_WORK_TYPE_VIEW] (    
    @userID      BIGINT
  , @userGroup   INT   
  , @userRank    INT
  , @term		 varchar(256)
)
 
RETURNS TABLE      
    
AS RETURN(      
    
/*-------------------------------    
 * Retrieve records   
 *------------------------------*/  
  
  select top (dbo.CONST_MAX_ROWS())
     [id]   = tow.id
   , [name] = tow.WorkType
  from dbo.TYPE_OF_WORK as tow
  where (tow.Active = 1
	and ((@term is null) or (tow.WorkType like (('%' + @term + '%'))))
	)
  order by [name] asc

)
  
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[INPUT_BATCHES_WORK_TYPE_VIEW] TO [webuser]
GO   


