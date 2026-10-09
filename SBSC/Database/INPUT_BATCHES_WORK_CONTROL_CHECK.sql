USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.INPUT_BATCHES_WORK_CONTROL_CHECK') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.INPUT_BATCHES_WORK_CONTROL_CHECK
GO
/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[INPUT_BATCHES_WORK_CONTROL_CHECK]
( @clientID        int,
  @workTypeID      int
) RETURNS VARCHAR(MAX) AS    
BEGIN  
  
  DECLARE @notes AS VARCHAR(MAX) 
  
  select @notes = Note from dbo.Input_Batches_Work_Control 
  where Client_ID  = @clientID   and 
        WorkTypeID = @workTypeID and
        Active     = 1 and
        (End_Date is null or End_Date >= getdate())
  
  if (@notes is null)
      select @notes = Note from dbo.Input_Batches_Work_Control 
       where Client_ID  = @clientID and 
             WorkTypeID is null    and
             Active     = 1 and
             (End_Date  is null or End_Date >= getdate())       
  RETURN @notes   
      
END    
    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[INPUT_BATCHES_WORK_CONTROL_CHECK] TO [webuser]
GO
