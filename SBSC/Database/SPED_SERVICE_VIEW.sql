USE [SPEDMON]
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SPED_SERVICE_VIEW') AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SPED_SERVICE_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[SPED_SERVICE_VIEW] (    
    @userID      BIGINT
  , @userGroup   INT   
  , @userRank    INT
  , @term		 varchar(256)
  , @recID       int /* code value */
)
 
RETURNS TABLE      
    
AS RETURN(      
    
/*-------------------------------    
 * Retrieve records   
 *------------------------------*/  
  
  select top (dbo.CONST_MAX_ROWS())
     [id]   = ss.codeValue                   /* we want to use codeValue in our dropdowns*/
   , [name] = (convert(varchar, ss.codeValue) + ' ' + ss.[name])  /* dropdown text should be code + text */
   , ss.codeSetName
   , ss.codeValue
   , ss.[definition]
   , [codeName] = ss.[name]
  from dbo.SpEd_Service as ss
  where ( 
        (ss.active = 1)
	and ((@recID is null) or (ss.codeValue = @recID))
	and ((@term is null)  or (ss.[name] like (('%' + @term + '%'))) or (ss.codeValue like (('%' + @term + '%'))))
  )
  order by 
    ss.codeValue

)
  
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[SPED_SERVICE_VIEW] TO [webuser]
GO   


