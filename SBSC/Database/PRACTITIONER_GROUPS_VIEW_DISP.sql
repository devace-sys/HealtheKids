USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTITIONER_GROUPS_VIEW_DISP') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PRACTITIONER_GROUPS_VIEW_DISP
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[PRACTITIONER_GROUPS_VIEW_DISP]()     
RETURNS TABLE

/***************************************************************************
 * PRACTITIONER_GROUPS_VIEW_DISP */
/**
 * This is a "front end" for the PRACTITIONER_GROUPS table.  
 * It filters out all practitioner allied discipline group assignments.
 *
 * @return                 Table
 ***************************************************************************/  

AS RETURN (
  -- Report groups are groups that DO NOT have    
  -- associated procedure codes    
  select pg.*,gd.groupName
  from PRACTITIONER_GROUPS        as pg
  join GROUP_DISP_VIEW_ALL(null)  as gd on gd.groupID = pg.GROUP_ID
)  
GO
