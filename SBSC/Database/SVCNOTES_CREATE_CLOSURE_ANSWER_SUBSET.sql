
/* Basic sproc to create new answers. Called from other stored procedures to produce cloned 'favorites' or multi=use practitioner custom answers */

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SVCNOTES_CREATE_CLOSURE_ANSWER_SUBSET') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.SVCNOTES_CREATE_CLOSURE_ANSWER_SUBSET
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE dbo.SVCNOTES_CREATE_CLOSURE_ANSWER_SUBSET 
(
	@ancestorAnswers bigint_TableType READONLY,
	@descendantAnswers bigint_TableType READONLY
)

/***************************************** 
	For two sets of answers, links each of the parent answers to each of the child answers to create followups across the two sets
******************************************/

AS
BEGIN


		declare @buffer table (row bigint identity(1,1), parent_answerid bigint, child_answerid bigint)
	
		insert into @buffer
			select * from @ancestorAnswers
			cross join @descendantAnswers
	
		declare @idx bigint = 1
	
		declare @max bigint = (select MAX(row) + 1 from @buffer)
		BEGIN TRANSACTION
			while @idx < @max
			BEGIN
				declare @p bigint= (select parent_answerid from @buffer where row = @idx)
				declare @c bigint= (select child_answerid from @buffer where row = @idx)
				
				exec SVCNOTES_CREATE_CLOSURE_CHILD_ANSWER @p,@c
			
				set @idx = @idx+1
			END
		COMMIT TRANSACTION

END
GO