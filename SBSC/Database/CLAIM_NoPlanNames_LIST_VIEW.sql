USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLAIM_NoPlanNames_LIST_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CLAIM_NoPlanNames_LIST_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE  FUNCTION [dbo].[CLAIM_NoPlanNames_LIST_VIEW]    
(@userID       INT,    
 @userGroup    INT,    
 @userRank     INT,   
 @recID        INT,
 @name         NVARCHAR(100))    
 
 RETURNS TABLE    
 
 /***************************************************************************    
  * CLAIM_NoPlanNames_LIST_VIEW */    
 /**    
  * Returns a table of CLAIM_NoPlanNames_LIST that match the given parameters    
  *    
  * @param  userID          Callers user id    
  * @param  userGroup       Callers user group    
  * @param  userRank        Callers user rank     
  * @param  recID           record id    
  * @return                 Table of CLAIMS_NoPlanNames_LIST data    
  ***************************************************************************/     
  
AS RETURN(   
          
/*-------------------------------    
 * Retrieve records   
 *------------------------------*/     
 
   select c.NO_PLAN_NAME_ID       as id,
          c.Name                  as name
   from CLAIM_NoPlanNames as c
   where (1=1)  
   and ((@name is null)  or (c.name like dbo.CREATE_NAME_PAT(@name)))      
   and ((@recID is null)  or (c.NO_PLAN_NAME_ID    = @recID)) 
 )
 
 GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CLAIM_NoPlanNames_LIST_VIEW] TO [webuser]
GO
    
