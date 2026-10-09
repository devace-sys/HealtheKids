USE [SPEDMON]
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RPT_CLAIMS_PAID_BY_DATE_BY_PAT_PRAC_CORE') AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[RPT_CLAIMS_PAID_BY_DATE_BY_PAT_PRAC_CORE]
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[RPT_CLAIMS_PAID_BY_DATE_BY_PAT_PRAC_CORE]    
(@clientID     INT,
 @startDateDOS DATETIME,    
 @endDateDOS   DATETIME,
 @startDateDOW DATETIME,
 @endDateDOW   DATETIME)
 RETURNS TABLE
 
 /***************************************************************************    
  * RPT_CLAIMS_PAID_BY_DATE_BY_PAT_PRAC_CORE */    
 /**    
  * Generates data for:
  * 
  * - claims paid by patient
  * - broken down by practitioner
  *
  * for a given:
  *
  * - client
  * - date of service (DOS) range
  * - date of warrant (Check) range
  *   
  * @param  clientID      Client id
  * @param  startDateDOS  Starting DOS
  * @param  endDateDOS    Ending DOS  
  * @param  startDateDOW  Starting DOW
  * @param  endDateDOW    Ending DOW  
  * @return               Table
  ***************************************************************************/
AS
RETURN(
   
  /*-------------------------------
   * All patients with amounts 
   * paid
   *------------------------------*/
        
  SELECT 
    [PATIENT_ID],    
    [PRACTITIONER_ID],
    [Assessments],
    [Services & Transportation],
    [TCM],
    [Total]    
  FROM
  (
    /*-------------------------------
     * Round to nearest even dollar
     * q2
     *------------------------------*/

    SELECT    
      [PATIENT_ID],
      [PRACTITIONER_ID],
      dbo.BANKERS_ROUND([Assessments T],0)               AS [Assessments],
      dbo.BANKERS_ROUND([Services & Transportation T],0) AS [Services & Transportation],
      dbo.BANKERS_ROUND([TCM T],0)                       AS [TCM],
      dbo.BANKERS_ROUND([Amount T],0)                    AS [Total]
       
    FROM
    (    
      /*-------------------------------
       * Aggregate totals
       * q1
       *------------------------------*/
       
      SELECT
        [PATIENT_ID],
        [PRACTITIONER_ID],
        count(PATIENT_ID)                    AS [Number Of Claims],
        sum([ASSESSMENTS])                   AS [Assessments T],
        sum([SERVICES_AND_TRANSPORTATION])   AS [Services & Transportation T],
        SUM([TCM])                           AS [TCM T],
        sum([AMOUNT_DISBURSED])              AS [Amount T]
      
      FROM RPT_CLAIMS_PAID_BY_DATE_CORE (@clientID,
                                         @startDateDOS,
                                         @endDateDOS,
                                         @startDateDOW,
                                         @endDateDOW) AS c
      GROUP BY 
      
        [PATIENT_ID],
        [PRACTITIONER_ID]
        
      ) AS q1 /* Sums */
    ) AS q2 /* Rounds */
)

GO    

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[RPT_CLAIMS_PAID_BY_DATE_BY_PAT_PRAC_CORE] TO [webuser]
GO   