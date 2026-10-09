USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLAIMS_PROCESSING_EXCEPTION_LIST_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CLAIMS_PROCESSING_EXCEPTION_LIST_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[CLAIMS_PROCESSING_EXCEPTION_LIST_VIEW]    
(@userID       INT,    
 @userGroup    INT,    
 @userRank     INT,   
 @recID        INT)    
 
 RETURNS TABLE    
 
 /***************************************************************************    
  * CLAIMS_PROCESSING_EXCEPTION_LIST_VIEW */    
 /**    
  * Returns a table of CLAIMS_PROCESSING_EXCEPTION_LIST that match the given parameters    
  *    
  * @param  userID          Callers user id    
  * @param  userGroup       Callers user group    
  * @param  userRank        Callers user rank     
  * @param  recID           Client record id    
  * @return                 Table of CLAIMS_PROCESSING_EXCEPTION_LIST data    
  ***************************************************************************/     
  
AS RETURN(   
          
/*-------------------------------    
 * Retrieve records   
 *------------------------------*/     
 
   select c.id           as id,
          c.Name         as name,
          c.Description as description
   from CLAIMS_PROCESSING_EXCEPTION_LIST as c
   where (1=1)     
   and ((@recID is null)  or (c.id     = @recID)) 
 )    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CLAIMS_PROCESSING_EXCEPTION_LIST_VIEW] TO [webuser]
GO
