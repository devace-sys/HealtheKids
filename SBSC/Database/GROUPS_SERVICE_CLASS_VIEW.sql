USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.GROUPS_SERVICE_CLASS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.GROUPS_SERVICE_CLASS_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[GROUPS_SERVICE_CLASS_VIEW] (
    @userID     bigint
  , @userGroup  int  
  , @userRank   int    
  , @source     int
  , @term       varchar(255)
)
RETURNS TABLE 
AS RETURN (    

/***************************************************************************    
 * GROUPS_SERVICE_CLASS_VIEW */    
/**    
 * Retrieve service class data from the given parameters
 *
 * @param   source    Partition id * @param   term      Search term * * @returns Table of service class data *
 ***************************************************************************/ 

select top (dbo.CONST_MAX_ROWS()) * 
from dbo.GROUPS_SERVICE_CLASS_VIEW_CORE (  @userID
                                         , @userGroup
                                         , @userRank
                                         , @source
                                         , @term )
order by Name

)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[GROUPS_SERVICE_CLASS_VIEW] TO [webuser]
GO





