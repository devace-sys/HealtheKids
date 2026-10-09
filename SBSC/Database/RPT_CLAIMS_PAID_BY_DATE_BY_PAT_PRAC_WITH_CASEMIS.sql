USE [SPEDMON]
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RPT_CLAIMS_PAID_BY_DATE_BY_PAT_PRAC_WITH_CASEMIS') AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[RPT_CLAIMS_PAID_BY_DATE_BY_PAT_PRAC_WITH_CASEMIS]
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[RPT_CLAIMS_PAID_BY_DATE_BY_PAT_PRAC_WITH_CASEMIS]    
(@clientID     INT,
 @startDateDOS DATETIME,    
 @endDateDOS   DATETIME,
 @startDateDOW DATETIME,
 @endDateDOW   DATETIME)
 RETURNS TABLE
 
 /***************************************************************************    
  * RPT_CLAIMS_PAID_BY_DATE_BY_PAT_PRAC_WITH_CASEMIS */    
 /**    
  * Generates data for:
  * 
  * - claims paid by patient
  * - services promised to a patient (CASEMIS)
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
     * Claims paid + services promised
     *------------------------------*/
    
    select 
      [PATIENT_ID],    
      [PRACTITIONER_ID],
      sum([Assessments])               as [Assessments],
      sum([Services & Transportation]) as [Services & Transportation],
      sum([TCM])                       as [TCM],
      sum([Total])                     as [Total] 
         
    from
    (

      /*-------------------------------
       * Claims paid
       *------------------------------*/

      select 
        [PATIENT_ID],    
        [PRACTITIONER_ID],
        [Assessments],
        [Services & Transportation],
        [TCM],
        [Total]    

        from RPT_CLAIMS_PAID_BY_DATE_BY_PAT_PRAC_CORE(@clientID, 
                                                      @startDateDOS, 
                                                      @endDateDOS, 
                                                      @startDateDOW, 
                                                      @endDateDOW)
       union
     
      /*-------------------------------
       * Services promised
       *------------------------------*/

       select distinct
         [PATIENT_ID],    
         [PRACTITIONER_ID],
         [Assessments]               = 0,
         [Services & Transportation] = 0,
         [TCM]                       = 0,
         [Total]                     = 0  
      from PRACTITIONER_PATIENTS as pp
      where pp.CLIENT_ID = @clientID
    
    ) as q1
    group by [PATIENT_ID], [PRACTITIONER_ID]
)

GO    

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[RPT_CLAIMS_PAID_BY_DATE_BY_PAT_PRAC_WITH_CASEMIS] TO [webuser]
GO   