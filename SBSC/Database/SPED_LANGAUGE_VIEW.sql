USE [SPEDMON]
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SPED_LANGUAGE_VIEW') AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SPED_LANGUAGE_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[SPED_LANGUAGE_VIEW] (    
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
     sl.id                     
   , [name] = sl.codeValue + ' ' + sl.[name]  /* dropdown text should be code + text */ 
   , sl.codeSetName
   , sl.codeValue
   , sl.[definition]
   , [codeName] = sl.[name]
  from dbo.SPED_LANGUAGE as sl
  where (
        (sl.active = 1)
	and ((@term is null) or (sl.[name] like (('%' + @term + '%'))) or (sl.codeValue like (('%' + @term + '%'))))
	)
  order by codeValue

)
  
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[SPED_LANGUAGE_VIEW] TO [webuser]
GO   


