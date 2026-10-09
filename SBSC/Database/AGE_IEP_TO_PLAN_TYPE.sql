USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.AGE_IEP_TO_PLAN_TYPE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.AGE_IEP_TO_PLAN_TYPE
GO
/*-------------------------------
 * Object Definition
 *------------------------------*/
CREATE FUNCTION [dbo].[AGE_IEP_TO_PLAN_TYPE](@age INT, @iep BIT) RETURNS INT AS     
BEGIN    
  /******************************************    
   * The plan type is derived from the    
   * patient's age on the day the service    
   * was provided and if the service was    
   * part of an IEP.    
   * Criteria                 Plan    
   * ---------------------    ----    
   * < 3 years old and IEP    IFSP    
   * >= 3 years old and IEP   IEP    
   * any age and no IEP       No Plan    
   *******************************************/    
  DECLARE @planType AS INT    
  SELECT @planType =      
    CASE WHEN @iep = 1 AND @age <  3 THEN dbo.CONST_PLAN_IFSP()    
         WHEN @iep = 1 AND @age >= 3 THEN dbo.CONST_PLAN_IEP()    
         WHEN @iep = 0               THEN dbo.CONST_PLAN_NONE()    
    END    
  RETURN @planType     
END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[AGE_IEP_TO_PLAN_TYPE] TO [webuser]
GO