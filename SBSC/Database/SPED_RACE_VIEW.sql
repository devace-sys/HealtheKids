USE [SPEDMON]
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SPED_RACE_VIEW') AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SPED_RACE_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[SPED_RACE_VIEW] (    
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
     [id]  =  sr.codeValue
   , [name] = convert(varchar(50),sr.codeValue) + ' ' + sr.[name]  /* dropdown text should be code + text */ 
   , sr.codeSetName
   , sr.codeValue
   , sr.[definition]
   , [codeName] = sr.[name]
  from dbo.SPED_RACE as sr
  where (
        (sr.active = 1)
	and ((@term is null) or (sr.[name] like (('%' + @term + '%'))) or (sr.codeValue like (('%' + @term + '%'))))
	)
  order by codeValue

)
  
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[SPED_RACE_VIEW] TO [webuser]
GO   


