USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTITIONER_GROUPS_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PRACTITIONER_GROUPS_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[PRACTITIONER_GROUPS_VIEW_CORE] 
(@groupCategory as int)     
RETURNS TABLE 

/***************************************************************************
 * PRACTITIONER_GROUPS_VIEW_CORE */
/**
 * Returns a list of groups based on category.  Category is based on
 * group type
 *
 * @param  groupCategory
 ***************************************************************************/  

AS RETURN (         
  select
    pg.PRACTITIONER_GROUP,
    pg.PRACTITIONER_ID,
    pgv.* 
  from PRACTITIONER_GROUPS                    as pg  
  join dbo.GROUPS_VIEW_CORE_2(@groupCategory) as pgv on (pgv.GROUP_ID = pg.GROUP_ID)
)  
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[PRACTITIONER_GROUPS_VIEW_CORE] TO [webuser]
GO

