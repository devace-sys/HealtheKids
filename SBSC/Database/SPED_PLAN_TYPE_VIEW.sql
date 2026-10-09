USE [SPEDMON]
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SPED_PLAN_TYPE_VIEW') AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SPED_PLAN_TYPE_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[SPED_PLAN_TYPE_VIEW] (    
    @userID      BIGINT
  , @userGroup   INT   
  , @userRank    INT
  , @term		 VARCHAR(256)
  , @recID       BIGINT
)
 
RETURNS TABLE      
    
AS RETURN(      
    
/*-------------------------------    
 * Retrieve records   
 *------------------------------*/  
  
  select top (dbo.CONST_MAX_ROWS())
     [id]   = codeValue                   /* we want to use codeValue in our dropdowns*/
   , [name] = (convert(varchar, codeValue) + ' ' + [name])  /* dropdown text should be code + text */ 
   , codeSetName
   , codeValue
   , [definition]
   , [codeName] = [name]
  from dbo.SpEd_Plan_Type
  where (active = 1
	and ((@term is null) or ([name] like (('%' + @term + '%'))) or (codeValue like (('%' + @term + '%'))))
	and ((@recID is null) or (codeValue = @recID))
	)
  order by codeValue

)
  
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[SPED_PLAN_TYPE_VIEW] TO [webuser]
GO   


