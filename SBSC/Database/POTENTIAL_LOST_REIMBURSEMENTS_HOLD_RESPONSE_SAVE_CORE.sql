USE SPEDMON
GO



/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.POTENTIAL_LOST_REIMBURSEMENTS_HOLD_RESPONSE_SAVE_CORE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.POTENTIAL_LOST_REIMBURSEMENTS_HOLD_RESPONSE_SAVE_CORE
GO

/*-------------------------------
 * Create 
 *------------------------------*/

    
CREATE PROCEDURE [dbo].[POTENTIAL_LOST_REIMBURSEMENTS_HOLD_RESPONSE_SAVE_CORE] (
    @userID              BIGINT
  , @userGroup           INT  
  , @userRank            INT      
  , @plrIDString         varchar(256)
  , @defer               bit  
  , @notes               varchar(max)
  , @updateNotes         bit = 0
  , @editDelReason       VARCHAR(7000)
  , @validateRec         BIT
  , @saveType            INT
  , @recID               BIGINT  -- not used; can be removed up the stack
  , @MsgNoRec            VARCHAR(1000)
  , @MsgNoEdit           VARCHAR(1000)
  , @MsgDupRec           VARCHAR(1000)
  , @MsgDataError        VARCHAR(1000)
  , @MsgNotActive        VARCHAR(1000)
  , @spDetails           VARCHAR(8000) OUTPUT
  , @recordID            BIGINT        OUTPUT )    
AS    
BEGIN     
    
/***************************************************************************    
 * POTENTIAL_LOST_REIMBURSEMENTS_HOLD_RESPONSE_SAVE_CORE */    
/**    
 * Saves a response to a PLR category
 * 
 ***************************************************************************/         
     
SET NOCOUNT ON    

/*============================================================
 * Variables
 *============================================================*/

DECLARE @today                AS DATETIME       -- Current date/time stamp    
DECLARE @tranOpen             AS BIT            -- Is a transaction open
DECLARE @isEdit               As Bit            -- Determines whether we are editing or adding a new record
declare @existingNotes        as varchar(max) = null

SET @recordID  = 0    
SET @spDetails = ''    
SET @today     = GETDATE()    

set @isEdit   = 0
set @recordID = 0

select top 1 
    @recordID      = isnull(chcr.id,0)
  , @existingNotes = chcr.NOTES
from dbo.CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_ACTIONABLE_REPORT_DATA_RESPONSES as chcr
where 
  (chcr.PLR_ID_STRING = @plrIDString)

if (@recordID != 0)
begin
  set @isEdit = 1 
end
else 
begin
  set @isEdit = 0
end


if (@isEdit = 1)
begin

  if (@updateNotes = 0) 
  begin
    set @notes = @existingNotes
  end

  update dbo.CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_ACTIONABLE_REPORT_DATA_RESPONSES
  set      
      DEFER           = @defer
    , NOTES			  = @notes
    , [lastModfied]   = @today       
	, [lastModifedBy] = @userID
  where ( 	    
    (id = @recordID)
  )	
end
else
begin					
	insert into dbo.CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_ACTIONABLE_REPORT_DATA_RESPONSES (
        [PLR_ID_STRING]     
	  , [DEFER]               
	  , [NOTES]				
	  , [created]             
	  , [createdBy]                            
	)
	values (
        @plrIDString	 
	  , @defer
	  , @notes
	  , @today
	  , @userID
	)
	
	set @recordID = SCOPE_IDENTITY()   

	end

	return(0)
	
END    
    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[POTENTIAL_LOST_REIMBURSEMENTS_HOLD_RESPONSE_SAVE_CORE] TO [webuser]
GO
