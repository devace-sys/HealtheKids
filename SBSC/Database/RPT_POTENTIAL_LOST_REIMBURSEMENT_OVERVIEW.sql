USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RPT_POTENTIAL_LOST_REIMBURSEMENT_OVERVIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RPT_POTENTIAL_LOST_REIMBURSEMENT_OVERVIEW
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[RPT_POTENTIAL_LOST_REIMBURSEMENT_OVERVIEW] (  
    @clientID       bigint
  , @repID          bigint
)
 
RETURNS TABLE
 
 /***************************************************************************    
  * RPT_POTENTIAL_LOST_REIMBURSEMENT_OVERVIEW */    
 /**    
  * Returns a table 
  *    
  * @param   userID         The userid of who is requesting the report
  * @param   userGroup      Users group    
  * @param   userRank       User rank
  * @param   clientID       Record ID of client to run report for
  * @param   startDate      Starting DOS
  * @param   endDate        Ending DOS      
  * @return                 Table of report rows
  ***************************************************************************/     
 
AS RETURN (

  select top (dbo.CONST_MAX_ROWS())
      repName
    , repEmail
    , clientName
    , estReimb
    , numSvcs
    , holdReason

  from
  (
    select 
        repName
      , repEmail
      , clientName
      , holdReason    
      , count(svcRecID)         as numSvcs    
      , sum(REIMBURSE_ESTIMATE) as estReimb
    from dbo.WAITING_SERVICES_DATA_TEMP_ACTIONABLE
    where (
           (1=1)
      and  ((@clientID  is null) or (clientID = @clientID))
      and  ((@repID     is null) or (REP_ID   = @repID))
    )
    group by 
      repName
    , repEmail
    , clientName
    , holdReason  
  ) as q1

  order by
      repName    asc
    , repEmail   asc
    , clientName asc 
    , estReimb   desc

) 
 
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[RPT_POTENTIAL_LOST_REIMBURSEMENT_OVERVIEW] TO [webuser]
GO

