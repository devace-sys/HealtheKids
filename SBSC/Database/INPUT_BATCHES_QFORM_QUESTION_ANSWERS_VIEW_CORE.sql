USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.INPUT_BATCHES_QFORM_QUESTION_ANSWERS_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.INPUT_BATCHES_QFORM_QUESTION_ANSWERS_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[INPUT_BATCHES_QFORM_QUESTION_ANSWERS_VIEW_CORE]
(@userID            BIGINT,    
 @userGroup         INT,    
 @userRank          INT,
 @clientID          BIGINT,
 @pracID            BIGINT,
 @hasAnswer         BIT)
RETURNS TABLE 
AS
RETURN 
(

/***************************************************************************
 * INPUT_BATCHES_QFORM_QUESTION_ANSWERS_VIEW_CORE */
/**
 * Returns qform data
 *
 * @return Table
 ***************************************************************************/ 
 
with

/*###########################################################################
  # QForm Data with initial filtering
  ###########################################################################*/   
  
cte_pass_1
as
(
select 
    irr.id
  , tow.WorkType                   as [Type of Work]
  , irrd.Question                  as [Question]  
  , m.FirstName + ' ' + m.LastName as [From]  
  , ib.File_Name                   as [Batch File]  
  , isnull(irrd.Answer,'')         as [Answer]  
  
  , convert(varchar(100),ib.id)              as [fp1] 
  , convert(varchar(100),irr.id)             as [fp2]
  , convert(varchar(100),irrd.id)            as [fp3]
  , isnull(irrdf.file_key,'')                as [filekey]
  
from      dbo.INPUT_BATCHES                          as ib
join      dbo.TYPE_OF_WORK                           as tow   on  tow.id            = ib.Type_Of_Work
join      users.dbo.INFO_REQUEST_RESPONSE            as irr   on  irr.ReferenceID   = ib.id
                                                              and irr.ClientID      = ib.ClientID
join      users.dbo.Users                            as u     on u.userrid          = irr.From_UserID
join      users.dbo.Membership                       as m     on m.UserId           = u.UserId
join      users.dbo.INFO_REQUEST_RESPONSE_DETAILS    as irrd  on  irrd.InfoRequestResponseID = irr.id
left join users.dbo.INFO_REQUEST_RESPONSE_FILES      as irrdf on  irrdf.info_request_response_detail_ID = irrd.id
where 
      (((@clientID is null) or (ib.ClientID   = @clientID))
and   ((@pracID    is null) or (irr.To_PracID = @pracID)))
)
,

/*###########################################################################
  # Determine if qform has answer either as text, file or both
  ###########################################################################*/   

cte_pass_2
as
(
select 
  *,
  [hasAnswer] = case 
    when [Answer]  != '' then 1
    when [filekey] != '' then 1
    else 0 end,  
      
  [Answer File] = case when [filekey] != '' then 'E:\Work Flow\workflow_qform_uploads\' + [fp1] + '\' + [fp2] + '\' + [fp3] + '\' + [filekey] else '' end
    
from cte_pass_1
)
,

/*###########################################################################
  # Filter on derived columns
  ###########################################################################*/   

cte_pass_3
as
(
select 
   [Type of Work]
 , [Question]  
 , [From]  
 , [Batch File]  
 , [Answer]
 , [Answer File]

 from cte_pass_2 
 where (1=1) and ((@hasAnswer is null) or (hasAnswer = @hasAnswer))
)

/*###########################################################################
  # Output
  ###########################################################################*/   

select top (dbo.CONST_MAX_ROWS()) 
*
from cte_pass_3
order by 
    [Type of Work]
  , [Question]
  , [Batch File]

)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON [dbo].[INPUT_BATCHES_QFORM_QUESTION_ANSWERS_VIEW_CORE] TO [webuser]
GO