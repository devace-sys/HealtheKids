USE [TimeKeeper]
GO


DROP PROCEDURE IF EXISTS [dbo].[MoveToFavoriteTasks]
GO


CREATE PROCEDURE [dbo].[MoveToFavoriteTasks]
(
  @EmployeeID        BIGINT,
  @taskID            BIGINT,
  @recordID          BIGINT OUTPUT
)    
AS    
BEGIN

declare @TranOpen      as bit = 0

  SET @recordID = 0

BEGIN TRY  
BEGIN TRANSACTION    
    
  SET @TranOpen = 1    

                     insert into TimeKeeper.dbo.Employee_TimeEntry_Tasks_Favorites
                     (
                         EmployeeID
                         ,taskID
                     )
                     values
                     ( 
                         @EmployeeID
                         ,@taskID
                     );

  --SET @recordID = SCOPE_IDENTITY()
  --if (@recordID IS NULL)
  --  RAISERROR('is null!!!', 11, 1);
  SET @recordID = SCOPE_IDENTITY();

COMMIT TRANSACTION    
SET @TranOpen = 0    
RETURN(0)
 
END TRY    
BEGIN CATCH    
    
  /*-------------------------------    
   * If we end up here something    
   * went wrong.  Cancel any pending    
   * transactions and return any    
   * error any error messages to    
   * the caller    
   *------------------------------*/    
       
  -- Error or raise error with severity 11 to 19 will be caught here    
      
  IF @tranOpen = 1 ROLLBACK TRANSACTION    
      
  DECLARE @ErrorMessage  AS NVARCHAR(4000)    
  DECLARE @ErrorSeverity AS INT    
  DECLARE @ErrorState    AS INT    
      
  SELECT  @ErrorMessage  = ERROR_MESSAGE(),    
          @ErrorSeverity = ERROR_SEVERITY(),    
          @ErrorState    = ERROR_STATE()    
      
  SET @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ']'    
      
  -- Reraise the error so it returns back to the server    
      
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
    
END CATCH   

END

GO


GRANT EXECUTE ON [dbo].[MoveToFavoriteTasks]  TO [webuser]
GO