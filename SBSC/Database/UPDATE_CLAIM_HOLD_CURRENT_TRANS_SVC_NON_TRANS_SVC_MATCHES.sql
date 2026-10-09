USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.UPDATE_CLAIM_HOLD_CURRENT_TRANS_SVC_NON_TRANS_SVC_MATCHES') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.UPDATE_CLAIM_HOLD_CURRENT_TRANS_SVC_NON_TRANS_SVC_MATCHES
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE PROCEDURE dbo.UPDATE_CLAIM_HOLD_CURRENT_TRANS_SVC_NON_TRANS_SVC_MATCHES 
AS    
BEGIN     
    
/***************************************************************************    
 * UPDATE_CLAIM_HOLD_CURRENT_TRANS_SVC_NON_TRANS_SVC_MATCHES */    
/**    
 * 
 ***************************************************************************/         

SET NOCOUNT ON        

declare @today as datetime

BEGIN TRY


RAISERROR ('Updating current transportation matches', 0, 1) WITH NOWAIT 

/*#####################################################################################################################*/

/*============================================================
 * Set reference date to current date
 *============================================================*/  

set @today = getdate()

/*#####################################################################################################################*/

/*============================================================
 * Delete previous matches
 *============================================================*/  

RAISERROR ('Cleaning out old data', 0, 1) WITH NOWAIT 
truncate table dbo.CLAIM_HOLD_CURRENT_TRANS_SVC_NON_TRANS_SVC_MATCHES

/*#####################################################################################################################*/

/*============================================================
 * Find matches for all active LEA clients
 *============================================================*/  

RAISERROR ('Searching for current matching services', 0, 1) WITH NOWAIT 

insert into dbo.CLAIM_HOLD_CURRENT_TRANS_SVC_NON_TRANS_SVC_MATCHES

select   

    CLIENT_ID            = tms.clientID
  , SVC_REC_ID           = tms.svcRecID
  , CLAIM_ID             = tms.claimID
  , NON_TRANS_SVC_REC_ID = tms.nonTransSvcRecID 
  , LAST_UPDATED         = @today
from dbo.CLIENTS_Client_Active_LEA  as clc

cross apply (

  /*============================================================
   * IEP/IFSP Services
   *============================================================*/  

  select * from dbo.TRANSPORTATION_MGMT_MATCHING_SERVICES_VIEW_CORE (null, null, null, clc.CLIENT_ID, 1, @today) /* IEP */
  
  union

  /*============================================================
   * Non IEP/IFSP Services
   *============================================================*/  

  select * from dbo.TRANSPORTATION_MGMT_MATCHING_SERVICES_VIEW_CORE (null, null, null, clc.CLIENT_ID, 0, @today) /* Non IEP */

) as tms

/*#####################################################################################################################*/

/*============================================================
 * Done
 *============================================================*/  

 RAISERROR ('Done', 0, 1) WITH NOWAIT 

/*#####################################################################################################################*/

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

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[UPDATE_CLAIM_HOLD_CURRENT_TRANS_SVC_NON_TRANS_SVC_MATCHES] TO [webuser]
GO
