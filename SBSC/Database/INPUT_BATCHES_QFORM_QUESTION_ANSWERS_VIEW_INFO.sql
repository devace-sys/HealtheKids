USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.INPUT_BATCHES_QFORM_QUESTION_ANSWERS_VIEW_INFO') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.INPUT_BATCHES_QFORM_QUESTION_ANSWERS_VIEW_INFO
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[INPUT_BATCHES_QFORM_QUESTION_ANSWERS_VIEW_INFO]
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
 * INPUT_BATCHES_QFORM_QUESTION_ANSWERS_VIEW_INFO */
/**
 * Returns qform data
 *
 * @return Table
 ***************************************************************************/ 
 
select 

    [Question]
  , [From]  
  , [Batch File]  
  , [Answer]
  , [Answer File]

from dbo.INPUT_BATCHES_QFORM_QUESTION_ANSWERS_VIEW_CORE (@userID, @userGroup, @userRank, @clientID, @pracID, @hasAnswer) as qf

)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON [dbo].[INPUT_BATCHES_QFORM_QUESTION_ANSWERS_VIEW_INFO] TO [webuser]
GO