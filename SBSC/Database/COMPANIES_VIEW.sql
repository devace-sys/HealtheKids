USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.COMPANIES_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.COMPANIES_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[COMPANIES_VIEW]    
(@userID       INT,    
 @userGroup    INT,    
 @userRank     INT,   
 @recID        INT)    
 
 RETURNS TABLE    
 
 /***************************************************************************    
  * COMPANIES_VIEW */    
 /**    
  * Returns a table of COMPANIES that match the given parameters    
  *    
  * @param  userID          Callers user id    
  * @param  userGroup       Callers user group    
  * @param  userRank        Callers user rank     
  * @param  recID           COMPANY record id    
  * @return                 Table of COMPANIES data    
  ***************************************************************************/     
  
AS RETURN(   
          
/*-------------------------------    
 * Retrieve records   
 *------------------------------*/     
 
   select c.id           as id,
          c.name         as name,
          c.company_TYPE as company_type
   from COMPANIES as c
   where (1=1)     
   and ((@recID is null)  or (c.id     = @recID)) 
 )    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[COMPANIES_VIEW] TO [webuser]
GO
