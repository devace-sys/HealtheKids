USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.FORM_FORM_CANCEL') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.FORM_FORM_CANCEL
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[FORM_FORM_CANCEL]     
 (@userID        BIGINT,    
  @userGroup     INT,    
  @userRank      INT,    
  @editDelReason VARCHAR(7000),    
  @validateRec   BIT,
  @formRequestID varchar(1000),    
  @recID         INT,
  @MsgNoRec      VARCHAR(1000),     
  @MsgNoEdit     VARCHAR(1000),
  @spDetails     VARCHAR(8000) OUTPUT,    
  @recordID      BIGINT        OUTPUT)    
AS    
BEGIN     
    
/***************************************************************************    
 * FORM_FORM_CANCEL */    
/**    
 *
 * Cancels a data driven form entry
 ***************************************************************************/         
     
/*###########################################################################
  # Init 
  ###########################################################################*/  
  
declare @today  as datetime = getdate()
set @recordID = null
set @spDetails  = ''

/*###########################################################################
  # Deactivate
  ###########################################################################*/  

select @recordID = id from FORM_FORM_SUBMITTED where (formRequestID = @formRequestID)    
update FORM_FORM_SUBMITTED set active = 0, lastUpdatedOn = @today where formRequestID = @formRequestID
if (@recordID is null) set @recordID = 0
return (0)

END
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[FORM_FORM_CANCEL] TO [webuser]
GO
