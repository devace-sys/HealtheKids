USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLIENT_REPS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CLIENT_REPS_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[CLIENT_REPS_VIEW]    
(   @userID       INT
  , @userGroup    INT    
  , @userRank     INT   
  , @active       BIT
  , @recID        BIGINT )     
 
 RETURNS TABLE    
 
 /***************************************************************************    
  * CLIENT_REPS_VIEW */    
 /**    
  * Returns a table of DISTRICT REPS that match the given parameters    
  *    
  * @param  userID          Callers user id    
  * @param  userGroup       Callers user group    
  * @param  userRank        Callers user rank     
  * @param  recID           district-rep record id    
  * @return                 Table of CLIENT_REPS data    
  ***************************************************************************/     
  
AS RETURN (   
          
/*-------------------------------    
 * Retrieve records   
 *------------------------------*/     
 
   select top (dbo.CONST_MAX_ROWS()) 
     
       cr.id                             as id
     , cr.last_name+', ' + cr.first_name as name
     , cr.company_id                     as company
     , cp.name                           as companyname
 
   from dbo.CLIENTS_Client_Reps as cr 
   join dbo.Companies           as cp on cp.id = cr.company_id

   where (
         (1=1)     
     and ((@active is null)  or (cr.active = @active))
	 and ((@recID  is null)  or (cr.id     = @recID)) 
	)

	order by
	    cr.last_name
	  , cr.first_name
)    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CLIENT_REPS_VIEW] TO [webuser]
GO
