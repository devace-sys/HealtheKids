USE [SPEDMON]
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SELPA_CODES_VIEW') AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SELPA_CODES_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[SELPA_CODES_VIEW] (    
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
     [id]   = code                  /* we want to use codeValue in our dropdowns*/
   , [name] = cast(code as varchar) + ' ' + [name]   /* dropdown text should be code + text */
   , county
   , [codeName] = [name]
   , mailingAddress
   , city
   , zip
   , phone

  from dbo.SELPAS
  where (active = 1
	and ((@term is null) or ([name] like (('%' + @term + '%'))) or (code like (('%' + @term + '%'))))
	)
  order by code

)
  
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[SELPA_CODES_VIEW] TO [webuser]
GO   

/* The following grant is essential for the user login process.  Do not move.*/
GRANT SELECT ON  [dbo].[SELPAS] TO [webuser]
GO   

