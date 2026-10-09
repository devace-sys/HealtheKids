USE [SPEDMON]
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SPED_GENDER_VIEW') AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SPED_GENDER_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[SPED_GENDER_VIEW] (    
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
     [id]                     
   , [name] = codeValue + ' ' + [name]  /* dropdown text should be code + text */ 
   , codeSetName
   , codeValue
   , [definition]
   , [codeName] = [name]
  from dbo.SPED_GENDER
  where (active = 1
	and ((@term is null) or ([name] like (('%' + @term + '%'))) or (codeValue like (('%' + @term + '%'))))
	)
  order by codeValue

)
  
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[SPED_GENDER_VIEW] TO [webuser]
GO   


