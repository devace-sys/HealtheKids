USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_RECORD_ATTENDANCE_SELECTION_ID_TO_FLAGS') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SERVICE_RECORD_ATTENDANCE_SELECTION_ID_TO_FLAGS
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION dbo.SERVICE_RECORD_ATTENDANCE_SELECTION_ID_TO_FLAGS (
    @selectionID  int
) 
RETURNS TABLE
AS    
RETURN
(   
   select top 1 
      flagsFound = 1
    , sras.patAbsent
	, sras.pracAbsent
	, sras.makeupSession
  from dbo.SERVICE_RECORD_ATTENDANCE_SELECTIONS as sras
  where ( sras.id = @selectionID ) 
)
GO