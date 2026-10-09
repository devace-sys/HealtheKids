USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTITONERS_VIEW_USERS') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PRACTITONERS_VIEW_USERS
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[PRACTITONERS_VIEW_USERS]()
     
RETURNS TABLE

/***************************************************************************    
 * PRACTITIONERS_VIEW_USERS */    
/**    
 * Returns a table of practitioners who appear to have user accounts assigned
 *
 * @return                 Table of practitioner data    
 ***************************************************************************/     

AS RETURN(
  select PRACTITIONER_ID, 
         LAST_NAME,
         FIRST_NAME,
         PRAC_ASP_ID,
         UserID 
  from dbo.PRACTITIONER_Practitioner
  WHERE (PRAC_ASP_ID is not null)
 ) 
     
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[PRACTITONERS_VIEW_USERS] TO [webuser]
GO