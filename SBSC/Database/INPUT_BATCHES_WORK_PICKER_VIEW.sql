USE [SPEDMON]
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.INPUT_BATCHES_WORK_PICKER_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.INPUT_BATCHES_WORK_PICKER_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[INPUT_BATCHES_WORK_PICKER_VIEW]    
(
	@userID       bigint,
	@userGroup	  bigint,
	@userRank	  bigint,
	@recID		  bigint,
	@canEdit		bit,
	@active			bit,
	@requestingUserID bigint,
	@viewOnly	  bit
)    
 
 RETURNS TABLE    
 
 /***************************************************************************    
  * INPUT_BATCHES_WORK_PICKER_VIEW */    
 /**    
  * Returns a ordered list of batches this user can work on, ordered by priority of importance.
  *    
  * @param  userID          Callers user id      
  * @return                 Table of workable batches, sorted by assignment, age, etc.    
  ***************************************************************************/     
  
AS RETURN(  
	with pickableBatches as
	(
	select * from INPUT_BATCHES
	where Current_status_Code = 50
		and clientID <> 112
	),
	assignedAnsweredBatches as
	(
	select * from INPUT_BATCHES ib
	where Current_status_Code = 255	
		and (@requestingUserID = ib.Current_status_UserID2 or @requestingUserID is null)	
	),
	assignedBatches as
	(
	select * from INPUT_BATCHES ib
	where Current_status_Code in (60,70)
		 and (@requestingUserID = ib.Current_status_UserID2 or @requestingUserID is null)
	),
	pickableBatchesByUserSkill as
	(
		 select pickableBatches.* from pickableBatches
		 inner join TRAINED_STAFF ts 
			  on pickableBatches.Type_Of_Work = ts.WORKTYPE_ID
			  and ts.RATING in (2,3,4) /* 50,75,100 */
			  and (@userID is null or @requestingUserID = ts.STAFF_ID)
	),
	TopPriorityToAssign as
	(
	select * from pickableBatchesByUserSkill --order by Oldest_DOS
	),

	finalPickerList as
	(
	select TOP (dbo.CONST_MAX_ROWS()) 1 as isAssigned, CASE WHEN Current_status_Code = 70 then 1 else 0 END as workStarted, * from assignedBatches
	UNION
	select TOP (dbo.CONST_MAX_ROWS()) 1 as isAssigned, CASE WHEN Current_status_Code = 70 then 1 else 0 END as workStarted, * from assignedAnsweredBatches
	union
	select TOP (dbo.CONST_MAX_ROWS()) 0 as isAssigned, CASE WHEN Current_status_Code = 70 then 1 else 0 END as workStarted, * from TopPriorityToAssign

	)


	select TOP (dbo.CONST_MAX_ROWS()) * from finalPickerList
	/* LEFT OUTER JOIN to SORTINGPRIORITYLIST */
	where ((isAssigned = 1 AND @viewOnly = 1) or @viewOnly = 0)
		AND NOT (ISNULL(Priority_number,0) >= 40 and isnull(priority_number,0) <=99)
	
	ORDER BY
	isAssigned desc, /* assigned work (isAssigned = 1) comes first */
	workStarted DESC, /* Work that has been started should be finished before looking at something newly-assigned */
	/* 'Flexible' priorities */
	
	/* hacked-in way to quickly 'prioritize' a set of work */
	/* WFA1 default-assigns a priority number of 0/NULL. We want to catch these and make them LESS important than a priority of 1 to make the scores more intuitive. */
	CASE WHEN ISNULL(priority_number,0) = 0 THEN (SELECT MAX(priority_number) +1 from input_batches) else priority_number END ASC,
	
	/* 'Push' clients */
	
	Oldest_DOS, /* and outside of that, we want to do the oldest work first */
	Date_Recieved /* and if they contain services of the same age, do the batch we recieved first first */
	,finalPickerList.id /* batch ID ordering last as final tiebreaker */
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[INPUT_BATCHES_WORK_PICKER_VIEW] TO [webuser]
GO
