USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTITIONER_VIEW_GROUP_HISTORY') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PRACTITIONER_VIEW_GROUP_HISTORY
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[PRACTITIONER_VIEW_GROUP_HISTORY] (@pracID int)           
returns TABLE

/***************************************************************************    
 * PRACTITIONER_VIEW_GROUP_HISTORY */    
/**    
 * Returns a table of group ids that the given practitioner has used
 *    
 * @param  pracID          Practitioner id
 * @return                 Table of groups
 ***************************************************************************/            

as           
return
(      
  select * from dbo.PRACTITIONER_VIEW_GROUP_HISTORY_CORE(@pracID)  
)        
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PRACTITIONER_VIEW_GROUP_HISTORY] TO [webuser]
GO
    
