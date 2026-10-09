USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTITIONER_GROUPS_VIEW_REPT') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PRACTITIONER_GROUPS_VIEW_REPT
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[PRACTITIONER_GROUPS_VIEW_REPT]()     
RETURNS TABLE 

/***************************************************************************
 * PRACTITIONER_GROUPS_VIEW_REPT */
/**
 * This is a "front end" for the PRACTITIONER_GROUPS table.  
 * It filters out all practitioner reporting group assignments.
 *
 * @return                 Table
 ***************************************************************************/  

AS RETURN (
  select pg.*,gr.groupName
  from PRACTITIONER_GROUPS    as pg
  join GROUP_REPT_VIEW_ALL(null,null)  as gr on gr.groupID = pg.GROUP_ID
)  
GO
