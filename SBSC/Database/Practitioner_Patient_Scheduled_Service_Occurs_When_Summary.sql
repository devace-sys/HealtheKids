USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Practitioner_Patient_Scheduled_Service_Occurs_When_Summary') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.Practitioner_Patient_Scheduled_Service_Occurs_When_Summary
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION dbo.Practitioner_Patient_Scheduled_Service_Occurs_When_Summary ( 
    @recurring        bit  
  , @startDate        date
  , @startTime        time(0)
  , @mon              bit
  , @monStartTime     time(0)
  , @tue              bit
  , @tueStartTime     time(0)
  , @wed              bit
  , @wedStartTime     time(0)
  , @thu              bit
  , @thuStartTime     time(0)
  , @fri              bit
  , @friStartTime     time(0)
)
 
RETURNS varchar(512)
AS     
BEGIN        

declare @summary         as varchar(512) = ''
declare @startDateStr    as varchar(50)  = ''
declare @startTimeStr    as varchar(50)  = ''
declare @monStartTimeStr as varchar(50)  = ''
declare @tueStartTimeStr as varchar(50)  = ''
declare @wedStartTimeStr as varchar(50)  = ''
declare @thuStartTimeStr as varchar(50)  = ''
declare @friStartTimeStr as varchar(50)  = ''

set @summary = '' 

if (@recurring = 1)
begin    
  set @monStartTimeStr = dbo.RPT_TIME_FMT (@monStartTime,0)
  set @tueStartTimeStr = dbo.RPT_TIME_FMT (@tueStartTime,0)
  set @wedStartTimeStr = dbo.RPT_TIME_FMT (@wedStartTime,0)
  set @thuStartTimeStr = dbo.RPT_TIME_FMT (@thuStartTime,0)
  set @friStartTimeStr = dbo.RPT_TIME_FMT (@friStartTime,0)

  if (@mon = 1) set @summary = @summary + ' * Mon @' + iif((@monStartTimeStr != ''),(@monStartTimeStr),'TBD')
  if (@tue = 1) set @summary = @summary + ' * Tue @' + iif((@tueStartTimeStr != ''),(@tueStartTimeStr),'TBD')
  if (@wed = 1) set @summary = @summary + ' * Wed @' + iif((@wedStartTimeStr != ''),(@wedStartTimeStr),'TBD')
  if (@thu = 1) set @summary = @summary + ' * Thu @' + iif((@thuStartTimeStr != ''),(@thuStartTimeStr),'TBD')
  if (@fri = 1) set @summary = @summary + ' * Fri @' + iif((@friStartTimeStr != ''),(@friStartTimeStr),'TBD')

  if (@summary = '') set @summary = '** Schedule TBD **'

end
else
begin
  set @startDateStr = dbo.RPT_DATE_FMT(@startDate)
  set @startTimeStr = dbo.RPT_TIME_FMT(@startTime,0)
  set @summary = 'On ' + @startDateStr + '@' + iif((@startTimeStr !=''), @startTimeStr,'TBD')
end

return @summary

END				
				   
GO  
