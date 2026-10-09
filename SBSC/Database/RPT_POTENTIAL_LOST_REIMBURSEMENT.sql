USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RPT_POTENTIAL_LOST_REIMBURSEMENT') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RPT_POTENTIAL_LOST_REIMBURSEMENT
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[RPT_POTENTIAL_LOST_REIMBURSEMENT] (  
    @clientID       bigint
  , @repID          bigint
)
 
RETURNS TABLE
 
 /***************************************************************************    
  * RPT_POTENTIAL_LOST_REIMBURSEMENT */    
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
    , dbo.RPT_DATE_FMT(dosMonthYear)               as dosMonthYear
    , dbo.RPT_BIT_TO_YN(dosUseOrLose)              as dosUseOrLose
    , patName
    , patBIC
    , groupName
    , pracName
    , svcName
    , dbo.RPT_DATE_FMT(LAST_TRANSMISSION_DATETIME) as lastTransmissionAttemptOn
    , holdReason
    , numMins         = SUM(numMins)
    , numTrips        = SUM(numTrips)
    , numMiles        = SUM(numMiles)
    , numSvcs         = COUNT(svcRecID) 
    , totReimburseEst = SUM(REIMBURSE_ESTIMATE)
  
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
    , dosMonthYear
    , dosUseOrLose
    , patName
    , patBIC
    , groupName
    , pracName
    , svcName
    , LAST_TRANSMISSION_DATETIME
    , holdReason
  
   order by
       repName      asc
     , clientName   asc
     , dosMonthYear desc
     , dosUseOrLose desc

) 
 
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[RPT_POTENTIAL_LOST_REIMBURSEMENT] TO [webuser]
GO