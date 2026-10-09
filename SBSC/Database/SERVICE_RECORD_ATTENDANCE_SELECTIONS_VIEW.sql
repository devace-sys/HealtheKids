USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_RECORD_ATTENDANCE_SELECTIONS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SERVICE_RECORD_ATTENDANCE_SELECTIONS_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/    
    
CREATE FUNCTION [dbo].[SERVICE_RECORD_ATTENDANCE_SELECTIONS_VIEW] (     
    @userID      BIGINT
  , @userGroup   INT    
  , @userRank    INT
  , @term        varchar(256)
) 
RETURNS TABLE 

/***************************************************************************    
 * SERVICE_RECORD_ATTENDANCE_SELECTIONS_VIEW */    
/**    
 * Returns a table of attendance options
 ***************************************************************************/     

AS RETURN(      
  
  select top (dbo.CONST_MAX_ROWS()) 
      sras.id
    , sras.[name]
    , sras.active 
  from SERVICE_RECORD_ATTENDANCE_SELECTIONS as sras
  where 
         (sras.active = 1)
    and ((@term is null) or (sras.[name] like ('%' + @term + '%'))) 
  order by 
    sras.id   
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[SERVICE_RECORD_ATTENDANCE_SELECTIONS_VIEW] TO [webuser]
GO