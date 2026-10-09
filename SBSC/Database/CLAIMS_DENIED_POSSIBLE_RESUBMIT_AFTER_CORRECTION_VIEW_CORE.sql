USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLAIMS_DENIED_POSSIBLE_RESUBMIT_AFTER_CORRECTION_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CLAIMS_DENIED_POSSIBLE_RESUBMIT_AFTER_CORRECTION_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION dbo.CLAIMS_DENIED_POSSIBLE_RESUBMIT_AFTER_CORRECTION_VIEW_CORE (
     @clientID          BIGINT
   , @oldestDOS         DATETIME
   , @today             DATETIME   
   , @useOrLose         BIT
)    

RETURNS TABLE
 
 /***************************************************************************    
  * CLAIMS_DENIED_POSSIBLE_RESUBMIT_AFTER_CORRECTION_VIEW_CORE */    
 /**    
  *
  * Returns claims we can possibly resubmit after data correction
  *
  * @return table 
  ***************************************************************************/                         
     
AS RETURN
(
  select 
    t1.*
  from      dbo.CLAIMS_DENIED_POSSIBLE_RESUBMIT_BASE_DATA_VIEW_CORE     (@clientID ,@oldestDOS, @today, @useOrLose) as t1
  left join dbo.CLAIMS_DENIED_POSSIBLE_RESUBMIT_AUTOMATICALLY_VIEW_CORE (@clientID, @oldestDOS, @today, @useOrLose) as t2 on t2.CLAIM_ID = t1.CLAIM_ID
  where (t2.CLAIM_ID is null)
) 

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CLAIMS_DENIED_POSSIBLE_RESUBMIT_AFTER_CORRECTION_VIEW_CORE] TO [webuser]
GO  
