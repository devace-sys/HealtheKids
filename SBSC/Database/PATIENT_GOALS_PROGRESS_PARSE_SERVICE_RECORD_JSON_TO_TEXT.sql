USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_GOALS_PROGRESS_PARSE_SERVICE_RECORD_JSON_TO_TEXT') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PATIENT_GOALS_PROGRESS_PARSE_SERVICE_RECORD_JSON_TO_TEXT
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[PATIENT_GOALS_PROGRESS_PARSE_SERVICE_RECORD_JSON_TO_TEXT] (
  @patientGoalProgressJSON varchar(max)
) 
RETURNS varchar(max) 
begin     

declare @progressJSON             as varchar(max) = '[]'
declare @textOut                  as varchar(max) = ''
declare @goalMeasureUsing1Text    as varchar(max) = ''
declare @goalMeasureUsing2Text    as varchar(max) = ''
declare @hasGoalMeasureUsing1Text as bit = 0
declare @hasGoalMeasureUsing2Text as bit = 0
declare @includeCRLFBetween       as bit = 0

set @progressJSON             = '[]'
set @textOut                  = ''
set @goalMeasureUsing1Text    = ''
set @goalMeasureUsing2Text    = ''
set @hasGoalMeasureUsing1Text = 0
set @hasGoalMeasureUsing2Text = 0
set @includeCRLFBetween       = 0

set @progressJSON = trim(isnull(@patientGoalProgressJSON,''))
if (@progressJSON = '') set @progressJSON = '[]'
if (@progressJSON = '[]') return @textOut

  /* progressTrackingForWhat = 1 Goal
                            = 10 Objective 1
							= 20 Objective 2
							= 30 Objective 3
 */

select @goalMeasureUsing1Text =  
  STRING_AGG(
      '* [Goal] : '               + t1.goalName 
    + char(13)
	+ ' ' 
	+ case 
	     when t1.progressTrackingForWhat = 1  then ''
	     when t1.progressTrackingForWhat = 10 then '[Objective 1] : ' + t1.objective1Text + char(13) + ' ' 
	     when t1.progressTrackingForWhat = 20 then '[Objective 2] : ' + t1.objective2Text + char(13) + ' ' 
	     when t1.progressTrackingForWhat = 30 then '[Objective 3] : ' + t1.objective3Text + char(13) + ' ' 
	     else ''
	  end
	+ ' [Score] : '               + convert(varchar(255),convert(bigint,t1.score))
    + ' [Successful Attempts] : ' + convert(varchar(255),t1.successfulAttempts)
    + ' [Total Attempts] : '      + convert(varchar(255),t1.totalAttempts)
	, char(13)
)
from dbo.PATIENT_GOALS_PROGRESS_PARSE_SERVICE_RECORD_JSON ( null,null, @progressJSON ) as t1
where 
  (t1.inputGoalProgressUsingWhat = 1)



select @goalMeasureUsing2Text =  
  STRING_AGG(
      '* [Goal] : ' + t1.goalName     
	+ char(13)
	+ ' ' 
	+ case 
	     when t1.progressTrackingForWhat = 1  then ''
	     when t1.progressTrackingForWhat = 10 then '[Objective 1] : ' + t1.objective1Text + char(13) + ' ' 
	     when t1.progressTrackingForWhat = 20 then '[Objective 2] : ' + t1.objective2Text + char(13) + ' ' 
	     when t1.progressTrackingForWhat = 30 then '[Objective 3] : ' + t1.objective3Text + char(13) + ' ' 
	     else ''
	  end
	+ ' [Practitioner Session Rating] : ' + convert(varchar(255),t1.practitionerSessionRating)
    + ' [Patient Session Rating] : ' + convert(varchar(255),t1.patientSessionRating) 

	, char(13)
)
  
from dbo.PATIENT_GOALS_PROGRESS_PARSE_SERVICE_RECORD_JSON ( null,null, @progressJSON ) as t1
where 
  (t1.inputGoalProgressUsingWhat = 2)

if (@goalMeasureUsing1Text is not null) set @hasGoalMeasureUsing1Text = 1
if (@goalMeasureUsing2Text is not null) set @hasGoalMeasureUsing2Text = 1

set @includeCRLFBetween = 0
if ((@hasGoalMeasureUsing1Text = 1) and (@hasGoalMeasureUsing2Text = 1)) set @includeCRLFBetween = 1

set @textOut = ''
             + iif((@hasGoalMeasureUsing1Text = 1),@goalMeasureUsing1Text,'')
             + iif((@includeCRLFBetween = 1), char(13),'')
			 + iif((@hasGoalMeasureUsing2Text = 1),@goalMeasureUsing2Text,'')
			 
return @textOut

end 
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[PATIENT_GOALS_PROGRESS_PARSE_SERVICE_RECORD_JSON_TO_TEXT] TO [webuser]
GO