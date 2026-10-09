USE SPEDMON
GO



/*-------------------------------
 * Exists/Drop
 *------------------------------*/


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLIENT_COMPLIANCE_ITEM_SAVE_FOR_CLIENTS_ONE_OR_ALL') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.CLIENT_COMPLIANCE_ITEM_SAVE_FOR_CLIENTS_ONE_OR_ALL
GO


/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[CLIENT_COMPLIANCE_ITEM_SAVE_FOR_CLIENTS_ONE_OR_ALL] (
    @userID                BIGINT
  , @userGroup             INT  
  , @userRank              INT      
  , @taskID				   BIGINT
  , @dueDate			   DATE
  , @dateToShowOnDashboard DATE
  , @isComplete			   BIT

  , @clientID          bigint

  , @editDelReason         VARCHAR(7000)
  , @validateRec           BIT
  , @saveType              INT
  , @recID                 BIGINT
  , @MsgNoRec              VARCHAR(1000)
  , @MsgNoEdit             VARCHAR(1000)
  , @MsgDupRec             VARCHAR(1000)
  , @MsgDataError          VARCHAR(1000)
  , @MsgNotActive          VARCHAR(1000)
  , @spDetails             VARCHAR(8000) OUTPUT
  , @recordID              BIGINT        OUTPUT )
AS    
BEGIN        
   
SET NOCOUNT ON    

/*============================================================
 * Variables
 *============================================================*/

DECLARE @tranOpen           AS BIT            -- Is a transaction open

/*============================================================
 * Get all clients
 *============================================================*/
declare @allClients as table (
    idx                       bigint identity(1,1)
  , clientID				  bigint
  unique clustered (idx)
)
insert into @allClients
select cc.CLIENT_ID from dbo.CLIENTS_Client as cc
where cc.LEA = 1 -- this means they are active

BEGIN TRY


/*============================================================
 * Validation
 *============================================================*/  

IF (@validateRec = 1) 
BEGIN  
  SET @recordID = 0 
  RETURN(0)    
END        

BEGIN TRANSACTION
SET @TranOpen = 1
  
/*-------------------------------    
 * Save client complaince item
 *------------------------------*/    

exec [dbo].[CLIENT_COMPLIANCE_ITEM_SAVE_CORE] 
    @userID                
  , @userGroup             
  , @userRank              
  , @taskID				   
  , @dueDate			   
  , @dateToShowOnDashboard 
  , @editDelReason         
  , @validateRec           
  , @saveType              
  , @recID                 
  , @MsgNoRec              
  , @MsgNoEdit             
  , @MsgDupRec             
  , @MsgDataError          
  , @MsgNotActive          
  , @spDetails             OUTPUT
  , @recordID              OUTPUT 

if (isnull(@recordID, 0) = 0) RAISERROR('Something went wrong when saving record', 11, 1)

/*############################################################################
 *#  Populate records for clients for this client compliance item
 *############################################################################*/

-- if save type is new, then create fresh records for each client
if (@saveType = dbo.CONST_SAVE_TYPE_NEW())
begin

  if (@clientID IS  NOT NULL )
  BEGIN

  	  exec dbo.CLIENT_COMPLIANCE_CLIENT_ITEM_SAVE_CORE
		   @userID                 
		 , @userGroup              
		 , @userRank               
		 , @clientID		
		 , @recordID -- @clientComplianceItemID 
		 , '' -- @notes                  
		 , @isComplete	
		 , null -- @dateCompleted


         , @dueDate   
         , @dateToShowOnDashboard

         , 0 -- @editDueDateAllClients        
         , 0 -- @editDashboardDateAllClients      


         , null -- @taskName already saved
                                      

			
		 , @editDelReason          

		 , @validateRec

		 , 1        

		 , @recID                  
		 , @MsgNoRec               
		 , @MsgNoEdit              
		 , @MsgDupRec              
		 , @MsgDataError           
		 , @MsgNotActive           
		 , @spDetails              
		 , @recordID 

  END
  ELSE
  BEGIN

	  -- loop variables
	  declare @i int = 1
	  declare @numClients int
	  select  @numClients = count(*) from @allClients
	  declare @curClientID bigint                     

	  while (@i <= @numClients)                        
	  begin
	    select top 1 @curClientID = clientID
	    from @allClients where idx = @i
	    set @i = @i + 1            
      
	    exec dbo.CLIENT_COMPLIANCE_CLIENT_ITEM_SAVE_CORE
		     @userID                 
		   , @userGroup              
		   , @userRank               
		   , @curClientID				
		   , @recordID -- @clientComplianceItemID 
		   , '' -- @notes  
                
		   , @isComplete	
	  	   , null -- @dateCompleted


	       , @dueDate   
	       , @dateToShowOnDashboard
	
	       , 0 -- @editDueDateAllClients        
	       , 0 -- @editDashboardDateAllClients      
	
	
	       , null -- @taskName already saved
 

		   , @editDelReason          
		   , @validateRec  
          
		   , 1

		   , @recID                  
		   , @MsgNoRec               
		   , @MsgNoEdit              
		   , @MsgDupRec              
		   , @MsgDataError           
		   , @MsgNotActive           
		   , @spDetails              
		   , @recordID               
	  end

  END
     
end

-- if save type is edit, only update the completion status if passed
else if (@saveType = dbo.CONST_SAVE_TYPE_EDIT() and @isComplete is not null)
begin
	update dbo.CLIENT_COMPLIANCE_CLIENT_ITEMS
	set isComplete = @isComplete
	where clientComplianceItemID = @recordID

end

/*============================================================
 * All done, commit changes and get out
 *============================================================*/  
    
COMMIT TRANSACTION    
SET @TranOpen = 0    
RETURN(0)    
END TRY  

/*============================================================
 * Exception handling
 *============================================================*/      

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
   
  -- Only send really bad exceptions back with sp details

  if (@ErrorSeverity > 11)    
    SET @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ']'    
      
  -- Reraise the error so it returns back to the server    
      
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
    
END CATCH    
END    
    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[CLIENT_COMPLIANCE_ITEM_SAVE_FOR_CLIENTS_ONE_OR_ALL] TO [webuser]
GO

