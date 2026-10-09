USE [SPEDMON]
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.ICD_10_CM_CODES_VIEW') AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.ICD_10_CM_CODES_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[ICD_10_CM_CODES_VIEW] (    
    @userID      BIGINT
  , @userGroup   INT   
  , @userRank    INT
  , @term		 varchar(256)
  , @recID       bigint 
)
 
RETURNS TABLE      
    
AS RETURN(      
    
/*-------------------------------    
 * Retrieve records   
 *------------------------------*/  
  
select top (dbo.CONST_MAX_ROWS())
   [id]   = icd10.id
 , [name] = icd10.code + ' - ' + icd10.[name]
 , [code] = icd10.code
 , icd10.codeChapter
 , icd10.codeCategory
 , icd10.codeSubCategory

from dbo.ICD_10_CM_CODES as icd10
where ( 
      (icd10.active = 1)
  and ((@term is null)  or ((icd10.code like (@term + '%')) or (icd10.[name] like ('%' + @term + '%'))))
  and ((@recID is null) or (icd10.id = @recID))
)
order by       
	icd10.codeCategory    asc
  , icd10.codeSubCategory asc
)  
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[ICD_10_CM_CODES_VIEW] TO [webuser]
GO   


