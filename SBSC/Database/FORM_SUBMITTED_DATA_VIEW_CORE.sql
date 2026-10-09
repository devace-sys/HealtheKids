USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.FORM_SUBMITTED_DATA_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.FORM_SUBMITTED_DATA_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[FORM_SUBMITTED_DATA_VIEW_CORE] (
    @formDefinitionID   bigint
  , @formRequestID      varchar(255)  
  , @formSubmittedID    bigint
  , @completed          bit
  , @active             bit
)    

RETURNS TABLE
 
 /***************************************************************************    
  * FORM_SUBMITTED_DATA_VIEW_CORE */    
 /**    
  * Returns submitted data
  *
  * @return table 
  ***************************************************************************/                         
     
AS 
RETURN
(
with

/*###########################################################################
  # Collect form data submitted
  ###########################################################################*/  
  
cte_p1
as
(
  select 
      formRequestID            =  ffs.formRequestID
    , formSubmittedID          =  ffs.id    
    , formPagePartSubmittedID  =  fpps.id    
    , formDefinitionID         =  f.id
    , formPageDefinitionID     =  fpp.formPageID
    , formPagePartDefinitionID =  fpp.id
    , fpp.formPagePartType
    , createdByUserID          =  ffs.userID
    , createdByUserName        =  u.UserName
    , createdOn                =  ffs.createdOn
    , lastUpdatedOn            =  ffs.lastUpdatedOn
    , active                   =  ffs.active
    , completed                =  ffs.complete
    , completedOn              =  ffs.completedOn     
    , formTitle                =  f.formTitle
    , pageTitle                =  fp.pageTitle 
    , question                 =  fpp.label
    , answer = case (fpp.formPagePartType)
        when 11 then fpps.selectedNames
        when 12 then fpps.selectedNames
        when 13 then case(fpps.value) when 1 then 'Yes' when 2 then 'No' when 3 then 'Does Not Apply' end
        else fpps.value
      end 
  from dbo.FORM_PAGES_PARTS_SUBMITTED as fpps
  join dbo.FORM_FORM_SUBMITTED        as ffs  on ffs.formRequestID  = fpps.formRequestID
  join dbo.FORM_PAGES_PARTS           as fpp  on fpp.id             = fpps.formPagePartDefinitionID 
  join dbo.FORM_PAGES                 as fp   on fp.id              = fpp.formPageID
  join dbo.FORM_FORM                  as f    on f.id               = ffs.formDefinitionID
  left join users.dbo.Users           as u    on u.userrid          = ffs.userID
  where 
      ((1=1)
  and ((@formRequestID    is null) or (fpps.formRequestID = @formRequestID))
  and ((@formSubmittedID  is null) or (ffs.id             = @formSubmittedID))  
  and ((@formDefinitionID is null) or (fpp.formID         = @formDefinitionID))  
  and ((@completed        is null) or (ffs.complete       = @completed))
  and ((@active           is null) or (ffs.active         = @active)))
)
,

/*###########################################################################
  # Data from part types that are 11, 12
  ###########################################################################*/  

cte_p2
as
(
  select 
      p2_1.formSubmittedID
    , p2_1.formRequestID
    , p2_1.formPagePartSubmittedID
    , p2_1.formDefinitionID
    , p2_1.formPageDefinitionID
    , p2_1.formPagePartDefinitionID 
    , p2_1.createdByUserID
    , p2_1.createdByUserName
    , p2_1.createdOn
    , p2_1.lastUpdatedOn
    , p2_1.completed
    , p2_1.completedOn
    , p2_1.active
    , p2_1.formTitle
    , p2_1.pageTitle
    , p2_1.question
    , p2_2.answerNum
    , p2_2.answer 
  from cte_p1 as p2_1 
  cross apply (
    select id as AnswerNum, part as Answer from dbo.STRING_SPLIT (p2_1.Answer,'|',1)     
  ) as p2_2
  where p2_1.formPagePartType in (11,12)
)
,

/*###########################################################################
  # Data from part types that are not parts 11, 12
  ###########################################################################*/  

cte_p3
as
(
  select  
      formSubmittedID
    , formRequestID
    , formPagePartSubmittedID
    , formDefinitionID
    , formPageDefinitionID
    , formPagePartDefinitionID 
    , createdByUserID
    , createdByUserName
    , createdOn
    , lastUpdatedOn
    , completed
    , completedOn
    , active
    , formTitle
    , pageTitle
    , question
    , answerNumber = 1
    , answer
  from cte_p1 where formPagePartType not in (11,12)
)
,

/*###########################################################################
  # Combine
  ###########################################################################*/  

cte_p4
as
(
  select * from cte_p2 
  union 
  select * from cte_p3
)
,

/*###########################################################################
  # Provide row ordering
  ###########################################################################*/  

cte_p5
as
(
select 
    recNumber  = DENSE_RANK () over (order by 
                                         formSubmittedID
                                       , formRequestID)
  , recLine    = ROW_NUMBER () over (partition by 
                                         formSubmittedID
                                       , formRequestID 
                                     order by 
                                         formPagePartSubmittedID)
  , questionNum = ROW_NUMBER () over (partition by 
                                           formSubmittedID
                                         , formRequestID
                                         , formPageDefinitionID                                                                       
                                       order by 
                                          formPagePartSubmittedID)

  
  ,*

  from cte_p4
)

/*###########################################################################
  # Output
  ###########################################################################*/  

select 
top (dbo.CONST_MAX_ROWS()) 
* 
, rptFormTitle = case when (recLine     = 1) then formTitle else '' end
, rptPageTitle = case when (questionNum = 1) then pageTitle else '' end
, rptQuestion  = case when (answerNum   = 1) then question  else '' end
, rptAnswer    = answer
from cte_p5 
order by 
    recNumber
  , recLine
  , questionNum
  , answerNum

)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[FORM_SUBMITTED_DATA_VIEW_CORE] TO [webuser]
GO  

