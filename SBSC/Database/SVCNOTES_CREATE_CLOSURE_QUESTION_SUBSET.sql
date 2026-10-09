
/* Basic sproc to create new answers. Called from other stored procedures to produce cloned 'favorites' or multi=use practitioner custom answers */

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SVCNOTES_CREATE_CLOSURE_QUESTION_SUBSET') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.SVCNOTES_CREATE_CLOSURE_QUESTION_SUBSET
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE dbo.SVCNOTES_CREATE_CLOSURE_QUESTION_SUBSET 
(
	@ancestorAnswers bigint_TableType READONLY,
	@descendantQuestion BIGINT
)

/***************************************** 
	For a set of parent answers and a question, link the answers to the question
******************************************/

AS
BEGIN


		declare @buffer table (row bigint identity(1,1), parent_answerid bigint, child_questionid bigint)
	
		insert into @buffer
			select * from @ancestorAnswers
			cross join (select @descendantQuestion as qID) as dq
	
		declare @idx bigint = 1
	
		declare @max bigint = (select MAX(row) + 1 from @buffer)
		
			while @idx < @max
			BEGIN
				declare @p bigint= (select parent_answerid from @buffer where row = @idx)
				declare @c bigint= (select child_questionid from @buffer where row = @idx)
				
				exec SVCNOTES_CREATE_CLOSURE_CHILD_QUESTION @p,@c
			
				set @idx = @idx+1
			END

END
GO