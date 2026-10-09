USE SPEDMON
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/

 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLIENT_INVOICES_SAVE_CORE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.CLIENT_INVOICES_SAVE_CORE
GO
 

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE PROCEDURE [dbo].[CLIENT_INVOICES_SAVE_CORE] (
    @userID                       Bigint
  , @userGroup                    Int
  , @userRank                     Int 
  , @clientID			          bigint 

  --
  , @updateNotesOnly                  bit
  , @updatePmtInfo                    bit
  , @updateDepositDistribInfo         bit

  --
   , @updateDepositDistribDateOnly     bit
  --
    --
  , @depositDate                  date 
  , @dateCollected                date
  , @amountPaid                   money 
  , @distributionDate             date
  , @distributionNotes           varchar(max)
    --

  , @notes                        varchar(max) 

    --

  , @editDelReason                Varchar(7000)    
  , @validateRec                  Bit    
  , @saveType                     Int    
  , @recID                        Int    
  , @MsgNoRec                     Varchar(1000)    
  , @MsgNoEdit                    Varchar(1000) 
  , @MsgDupRec                    Varchar(1000)     
  , @MsgDataError                 Varchar(1000)
  , @MsgNotActive                 Varchar(1000)     
  , @spDetails                    Varchar(8000) OUTPUT   
  , @recordID                     BigInt        OUTPUT)    
AS    
BEGIN            
 
SET NOCOUNT ON    
 
-- DECLARE @TranOpen            AS BIT  


-- BEGIN TRY    
 
/*-------------------------------    
 * Init our output parameters    
 *------------------------------*/    
 
SET @spDetails  = ''    
SET @recordID = 0 

/*-------------------------------    
 * Verify all parameters that    
 * indicate what type of operation    
 * to perform have been passed in    
 * and any other parms that are    
 * neccessary for proper operation    
 *------------------------------*/    
 
IF (@userID            IS NULL)			    RAISERROR ('userID is required',      11, 1)      
IF (@userGroup         IS NULL)			    RAISERROR ('userGroup is required',   11, 1)    
IF (@userRank          IS NULL)			    RAISERROR ('userRank is required',    11, 1)    
IF (@validateRec       IS NULL)			    RAISERROR ('Validate flag required',  11, 1) 

IF (( @clientID      IS NOT NULL )
AND (not exists (select top 1 CLIENT_ID from dbo.CLIENTS_Client where CLIENT_ID = @clientID)
))
      RAISERROR ('Invalid Client ID',      11, 1) 


IF (
     ISNULL( @updateNotesOnly, 0) = 0 AND
     ISNULL( @updatePmtInfo, 0)   = 0 AND
     ISNULL( @updateDepositDistribInfo, 0) = 0  AND
	 ISNULL( @updateDepositDistribDateOnly, 0) = 0
   )
      RAISERROR ('Nothing to update.',      11, 1) 

/*-------------------------------    
 * Validation exit
 *------------------------------*/    
  
IF (@validateRec = 1) 
BEGIN    
  SET @recordID = 0
  RETURN(0)    
END        
 
/*============================================================
 * Write data
 *============================================================*/  

-- BEGIN TRANSACTION    
 
--  SET @TranOpen = 1     

  if (@saveType = dbo.CONST_SAVE_TYPE_EDIT())
  begin
  
    if ( @updateNotesOnly = 1 )
	BEGIN

  	  Update dbo.Client_Invoices 

	   Set
        [Notes]              = @notes

	  Where( (INVOICE_ID = @recID)	
	   and (CLIENT_ID  = @clientID  OR  @clientID  IS NULL) 
	  )
	END	
    ELSE  IF (@updatePmtInfo = 1)
    BEGIN

  	  Update dbo.Client_Invoices 
	   Set

		[Date_Collected]         = @dateCollected,
		[Amount_Paid]            = @amountPaid

	  Where( (INVOICE_ID = @recID)	
	    and (CLIENT_ID  = @clientID  OR  @clientID  IS NULL) 
	  )

    END
    ELSE  IF (@updateDepositDistribInfo = 1)
    BEGIN

  	  Update dbo.Client_Invoices 
	   Set

		[Deposit_Date]           = @depositDate,
        [Distributed_Date]       = @distributionDate ,
		[Distribution_Notes]     = @distributionNotes

	  Where( (INVOICE_ID = @recID)	
	    and (CLIENT_ID  = @clientID  OR  @clientID  IS NULL) 
	  )

    END
    ELSE IF (@updateDepositDistribDateOnly = 1)
	BEGIN
  	  Update dbo.Client_Invoices 
	   Set
                [Distributed_Date]       = @distributionDate 

	  Where( (INVOICE_ID = @recID)	
	   and (CLIENT_ID  = @clientID  OR  @clientID  IS NULL)
	  )
    END

    Set @recordID = @recID 

  end

/*-------------------------------    
 * If we reach this point    
 * everything is OK, commit our    
 * changes and exit    
 *------------------------------*/    
 
-- COMMIT TRANSACTION    
-- SET @TranOpen = 0   
 
RETURN(0)  

-- END TRY    
 
END    
 
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[CLIENT_INVOICES_SAVE_CORE] TO [webuser]
GO