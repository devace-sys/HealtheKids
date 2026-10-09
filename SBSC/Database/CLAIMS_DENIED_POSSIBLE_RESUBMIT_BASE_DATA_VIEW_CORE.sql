USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLAIMS_DENIED_POSSIBLE_RESUBMIT_BASE_DATA_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CLAIMS_DENIED_POSSIBLE_RESUBMIT_BASE_DATA_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[CLAIMS_DENIED_POSSIBLE_RESUBMIT_BASE_DATA_VIEW_CORE] (
     @clientID          BIGINT
   , @oldestDOS         DATETIME
   , @today             DATETIME   
   , @useOrLose         BIT
)    

RETURNS TABLE
 
 /***************************************************************************    
  * CLAIMS_DENIED_POSSIBLE_RESUBMIT_BASE_DATA_VIEW_CORE */    
 /**    
  *
  * Returns all denied claims except for those that we unconditionally
  * do not consider for resubmission.  This is the starting point for
  * futher categorization of what to resubmit.
  *
  * @return table 
  ***************************************************************************/                         
     
AS RETURN
(
 
 select 
   * 
 from dbo.CLAIMS_DENIED_VIEW_CORE (@clientID,@oldestDOS,@today,1,null) 
 where (
       (ADJUDICATION_RANK = 1)                       /* Latest reasons */
   and (CLASS_PREV_PAID   = 0)                       /* Not previously paid */
   and (CLASS_NO_PLAN_LIMITS_REACHED = 0)            /* Not a non IEP unit cap */
   and (CLASS_IEP_IFSP_NON_ASSMT_LIMITS_REACHED = 0) /* Not a IEP non assessement limit cap */
   --and (PAT_BIC_LEN_OK = 1)                          /* BIC length is OK */
   and (CLASS_NON_PROXY_HELD = 0)                    /* Not a stand alone claim that is currently held for some reason */
   and (CLASS_SVC_IS_SUB_STATE = 1)                  /* Svc rec state is not in a state we dont expect */

   and ((@useOrLose is null) or (USE_OR_LOSE = @useOrLose))
 )
 
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CLAIMS_DENIED_POSSIBLE_RESUBMIT_BASE_DATA_VIEW_CORE] TO [webuser]
GO  
