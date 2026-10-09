USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.FILE_UPLOAD_VIEW_FORM_DATA') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.FILE_UPLOAD_VIEW_FORM_DATA
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[FILE_UPLOAD_VIEW_FORM_DATA]
(@userID            BIGINT,    
 @userGroup         INT,    
 @userRank          INT,
 @uploadID          BIGINT 
)
RETURNS TABLE 
AS
RETURN 
(

/***************************************************************************
 * FILE_UPLOAD_VIEW_FORM_DATA */
/**
 * Returns file upload record status data
 *
 * @return Table
 ***************************************************************************/ 


with

/*###########################################################################
  # Files uploaded from source 1 - Public Send Us A File
  ###########################################################################*/    

cte_uploads_from_s1_p1
as
(
select 
    pcv.CountyName 
  , fur.county_code
  , pdv.DistrictName
  , fur.district_code
  , fur.last_name
  , fur.first_name
  , fur.file_class
  , fur.file_type
  , fur.work_email
  , convert(varchar,fur.ref_date) as ref_date
  , fur.request_datetime
  , fur.request_ip
  , fur.request_user_agent
  
from dbo.FILE_UPLOAD_REQUESTS                               as fur
join dbo.FILE_UPLOADS                                       as fu  on fu.id            = fur.uploadId
join dbo.CDE_SCHOOLS_PUBLIC_COUNTIES_VIEW  (null,null)      as pcv on pcv.CountyCode   = fur.county_code
join dbo.CDE_SCHOOLS_PUBLIC_DISTRICTS_VIEW (null,null,null) as pdv on pdv.DistrictCode = fur.district_code
where (fur.uploadId = @uploadID)
)
,
cte_uploads_from_s1_p2
as
(
      select 'Select County'    as [QuestionText], CountyName   as [AnswerText], county_code   as [AnswerValues] from cte_uploads_from_s1_p1
union select 'Select District'  as [QuestionText], DistrictName as [AnswerText], district_code as [AnswerValues] from cte_uploads_from_s1_p1
union select 'Enter Last Name'  as [QuestionText], last_name    as [AnswerText], ''            as [AnswerValues] from cte_uploads_from_s1_p1
union select 'Enter First Name' as [QuestionText], first_name   as [AnswerText], ''            as [AnswerValues] from cte_uploads_from_s1_p1
union select 'Enter Work Email' as [QuestionText], work_email   as [AnswerText], ''            as [AnswerValues] from cte_uploads_from_s1_p1
union select 'Oldest DOS'       as [QuestionText], ''           as [AnswerText], ref_date      as [AnswerValues] from cte_uploads_from_s1_p1  
)
,

/*###########################################################################
  # Files uploaded from source 2 - Private Send Us A File
  ###########################################################################*/    

cte_uploads_from_s2_p1
as
(
select 
  formRequestID 
from dbo.FORM_PAGES_PARTS_SUBMITTED as fpps 
join dbo.FILE_UPLOADS               as fu on fu.id = fpps.crossRefId 
where (fpps.crossRefId = @uploadID)
)
,
cte_uploads_from_s2_p2
as
(
select 
    fpp.label                     as [QuestionText]
  , isnull(fpps.selectedNames,'') as [AnswerText]
  , isnull(fpps.value,'')         as [AnswerValues]
from dbo.FORM_PAGES_PARTS_SUBMITTED  as fpps
join cte_uploads_from_s2_p1          as fu  on fu.formRequestID = fpps.formRequestID
join dbo.FORM_PAGES_PARTS            as fpp on fpp.id = fpps.formPagePartDefinitionID
)
,

/*###########################################################################
  # Files uploaded from source 3 - Service Notes
  ###########################################################################*/    

cte_uploads_from_s3_p1
as
(
select 
  snq.QuestionText                  as QuestionText
, convert(varchar,sna.AnswerValue)  as AnswerText
, convert(varchar,sna.AnswerID)     as AnswerValues 
from dbo.SvcNote_Note_Answers_Files as snaf
join dbo.FILE_UPLOADS               as fu   on fu.id      = snaf.fileUploadID
join dbo.SvcNote_Note_Answers       as sna  on sna.NoteID = snaf.noteID
join dbo.SvcNote_Questions          as snq  on snq.id     = sna.questionID
where (snaf.fileUploadID = @uploadID)
)
,

/*###########################################################################
  # Combined
  ###########################################################################*/    

cte_uploads_from_all_p1
as
(
      select * from cte_uploads_from_s1_p2
union select * from cte_uploads_from_s2_p2
union select * from cte_uploads_from_s3_p1
)
,
cte_uploads_from_all_p2
as
(
select 
    ltrim(rtrim(QuestionText)) as QuestionText
  , ltrim(rtrim(AnswerText))   as AnswerText
  , ltrim(rtrim(AnswerValues)) as AnswerValues  
from cte_uploads_from_all_p1
)
,
cte_output
as
(
select * from cte_uploads_from_all_p2
)

select * from cte_output


)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[FILE_UPLOAD_VIEW_FORM_DATA] TO [webuser]
GO