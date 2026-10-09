USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_RECORD_ATTENDANCE_FLAGS_TO_SELECTION_ID_AND_NAME') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SERVICE_RECORD_ATTENDANCE_FLAGS_TO_SELECTION_ID_AND_NAME
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

 CREATE FUNCTION [dbo].[SERVICE_RECORD_ATTENDANCE_FLAGS_TO_SELECTION_ID_AND_NAME] (  
    @patAbsent     BIT
  , @pracAbsent    BIT
  , @makeupSession  BIT
) 
RETURNS table
AS    
return
(
  
  select top 1 
      srafs.id 
	, srafs.name
  from dbo.SERVICE_RECORD_ATTENDANCE_FLAGS_SELECTIONS as srafs
  where ( 
        (srafs.patAbsent     = isnull(@patAbsent,     0))
    and (srafs.pracAbsent    = isnull(@pracAbsent,    0))
    and (srafs.makeupSession = isnull(@makeupSession, 0))
  )
  
)
GO