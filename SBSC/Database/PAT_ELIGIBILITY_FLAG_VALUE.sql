USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PAT_ELIGIBILITY_FLAG_VALUE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PAT_ELIGIBILITY_FLAG_VALUE
GO
/*-------------------------------
 * Object Definition
 *------------------------------*/
CREATE FUNCTION [dbo].[PAT_ELIGIBILITY_FLAG_VALUE]    
(@flagIn NVARCHAR(1)     
)RETURNS CHAR(2) AS     
BEGIN        
  IF (@flagIn IS NULL)  RETURN dbo.CONST_PAT_ELIGIBILITY_FLAG_VALUE_UNK()    
  IF (@flagIn = '')     RETURN dbo.CONST_PAT_ELIGIBILITY_FLAG_VALUE_UNK()    
  IF (LEN(@flagIn) = 0) RETURN dbo.CONST_PAT_ELIGIBILITY_FLAG_VALUE_UNK()    
      
  SET @flagIn = RTRIM(LTRIM(UPPER(@flagIn)))    
      
  IF (@flagIn = 'Y')    RETURN dbo.CONST_PAT_ELIGIBILITY_FLAG_VALUE_YES()    
  IF (@flagIn = 'N')    RETURN dbo.CONST_PAT_ELIGIBILITY_FLAG_VALUE_NO()    
      
  RETURN dbo.CONST_PAT_ELIGIBILITY_FLAG_VALUE_UNK()    
END    
GO
