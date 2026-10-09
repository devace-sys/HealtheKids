USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CASELOAD_VIEW_BY_DATE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CASELOAD_VIEW_BY_DATE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[CASELOAD_VIEW_BY_DATE]    
(@clientID   INT,
 @pracID     INT,
 @patID      INT,
 @refDate    DATETIME)    

RETURNS TABLE

 /***************************************************************************    
  * CASELOAD_VIEW_BY_DATE */    
 /**    
  * Returns a table of patients that match the given parameters    
  *    
  * @param  clientID        Required.  ID of client    
  * @param  pracID          Practitioner ID for caseload
  * @param  refDate         Reference date
  * @return                 Table of patient data    
  ***************************************************************************/     
  
AS RETURN
(
  /*-------------------------------
   * q2 
   * with duplicate eliminiation
   *------------------------------*/
  select distinct *  
  from
  (
    /*-------------------------------
     * q1 + rows are limited to
     * start and end dates that bracket
     * @refdate
     *------------------------------*/
    select
      ID,
      CLIENT_ID,
      PRACTITIONER_ID,
      PATIENT_ID,
      CREATED_BY,
      CREATED_ON,
      LAST_MODIFIED_BY,
      LAST_MODIFIED_ON,
      ACTIVE,
      CUR_PRAC_PAT_DATES_ID,
      CUR_PRAC_PAT_SVC_SCH_ID 
    from
    (
      /*-------------------------------
       * Caseload entries for given
       * @clientID and @pracID.  
       * In the cases where start or 
       * end dates are null, the 
       * current date is returned.
       *------------------------------*/
      select 
        pp.*,
        dbo.DATE_START (START_DATE,1)  as START_DATE,
        dbo.DATE_END   (END_DATE)      as END_DATE
      from PRACTITIONER_PATIENTS_DATES as ppd
      join PRACTITIONER_PATIENTS       as pp on pp.ID = ppd.PRAC_PAT_ID 
      where 
             ((pp.CLIENT_ID = @clientID)
         and ((@pracID is null) or (pp.PRACTITIONER_ID  = @pracID))
         and ((@patID  is null) or (pp.PATIENT_ID       = @patID)))
    ) as q1
    where @refDate between START_DATE and END_DATE 
  ) as q2
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CASELOAD_VIEW_BY_DATE] TO [webuser]
GO
