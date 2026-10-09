USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.INPUT_BATCHES_QFORM_QUESTION_ANSWERS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.INPUT_BATCHES_QFORM_QUESTION_ANSWERS_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[INPUT_BATCHES_QFORM_QUESTION_ANSWERS_VIEW]
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
 * INPUT_BATCHES_QFORM_QUESTION_ANSWERS_VIEW */
/**
 * Returns qform data
 *
 * @return Table
 ***************************************************************************/ 
 
select * from dbo.INPUT_BATCHES_QFORM_QUESTION_ANSWERS_VIEW_CORE (@userID, @userGroup, @userRank, @clientID, @pracID, @hasAnswer)

)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON [dbo].[INPUT_BATCHES_QFORM_QUESTION_ANSWERS_VIEW] TO [webuser]
GO