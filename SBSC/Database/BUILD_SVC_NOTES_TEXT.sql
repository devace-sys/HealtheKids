USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.BUILD_SVC_NOTES_TEXT') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.BUILD_SVC_NOTES_TEXT
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[BUILD_SVC_NOTES_TEXT]
(
    @patientGoalProgressText varchar(max)
  , @svcNotesFormBuilderText varchar(max)
  , @notes                   varchar(max)
) 
RETURNS varchar(max)
AS     
BEGIN    

declare @notesText as varchar(max) = ''

declare @hasPatientGoalProgressText as bit = 0
declare @hasSvcNotesFormBuilderText as bit = 0
declare @hasNotes                   as bit = 0

set @patientGoalProgressText  = trim(isnull(@patientGoalProgressText,''))
set @svcNotesFormBuilderText  = trim(isnull(@svcNotesFormBuilderText,''))
set @notes                    = trim(isnull(@notes                  ,''))

set @hasPatientGoalProgressText  = iif((len(@patientGoalProgressText) = 0),0,1)
set @hasSvcNotesFormBuilderText  = iif((len(@svcNotesFormBuilderText) = 0),0,1)
set @hasNotes                    = iif((len(@notes)                   = 0),0,1)

set @notesText = ''

if (@hasPatientGoalProgressText = 1)
begin
  set @notesText = @patientGoalProgressText
end

if (@hasSvcNotesFormBuilderText = 1)
begin

  if (@hasPatientGoalProgressText = 1)
  begin
    set @notesText = @notesText + char(13)
  end

  set @notesText = @notesText + @svcNotesFormBuilderText
end

if (@hasNotes = 1)
begin

  if ((@hasSvcNotesFormBuilderText = 1) or (@hasPatientGoalProgressText = 1))
  begin
    set @notesText = @notesText + char(13) + '* Additional Notes : ' 
  end

  set @notesText = @notesText + @notes
end

return @notesText  
END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[BUILD_SVC_NOTES_TEXT] TO [webuser]
GO