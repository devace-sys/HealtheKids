USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.INPUT_BATCHES_WORK_PICKER') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.INPUT_BATCHES_WORK_PICKER
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[INPUT_BATCHES_WORK_PICKER]
(@userID        bigint   = 0,
@recordID bigint OUTPUT )
     
AS    

BEGIN     
    
/***************************************************************************    
 * INPUT_BATCHES_WORK_PICKER */    
/**    
 * @param   userID          The userID of who is running this & requesting work  

 ***************************************************************************/         
     
SET NOCOUNT ON    
    
DECLARE @msg        AS VARCHAR(1000)
DECLARE @recCount   AS INT

BEGIN TRANSACTION

declare @Assigned bigint, @total bigint

declare @workingBatchID bigint

select @Assigned = SUM(isAssigned), @total = COUNT(*)
from INPUT_BATCHES_WORK_PICKER_VIEW(@userID, null,null,null,null,null, @userID,0)

/* ID the batch we're gonna be working with */
select top 1 @workingBatchID = id from INPUT_BATCHES_WORK_PICKER_VIEW(@userID, null,null,null,null,null, @userID,0)

/* Determine if next batch from assigned work or new work */
if @Assigned = 0
BEGIN
	/* Batch needs to be assigned */
	print 'assign'
END
else
BEGIN 
	/* batch is already assigned */
	print 'Assigned - update status?'
END

set @recordID = @workingBatchID

ROLLBACK TRANSACTION

END    
    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[INPUT_BATCHES_WORK_PICKER] TO [webuser]
GO
