USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.ONE_ON_ONE_AIDE_ASSIGNMENT_VIEW_BY_DATE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.ONE_ON_ONE_AIDE_ASSIGNMENT_VIEW_BY_DATE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[ONE_ON_ONE_AIDE_ASSIGNMENT_VIEW_BY_DATE]    
(@clientID   INT,
 @pracID     INT,
 @patID      INT,
 @refDate    DATETIME)    

RETURNS TABLE

 /***************************************************************************    
  * ONE_ON_ONE_AIDE_ASSIGNMENT_VIEW_BY_DATE */    
 /**    
  * Returns a table of patients that match the given parameters    
  *    
  * @param  clientID        Required.  ID of client    
  * @param  pracID          Required.  ID of prac
  * @param  patID           Required.  ID of prac
  * @param  refDate         Reference date
  * @return                 Table of data    
  ***************************************************************************/     
  
AS RETURN
(

with

/*============================================================
 * All dates in the month 
 *============================================================*/

cte_dates
as
(
  select * from dbo.DATE_SEQUENCE(dbo.DATE_MONTH_START_END(@refDate,0), 
                                  dbo.DATE_MONTH_START_END(@refDate,1))
) 
,

/*============================================================
 * Services 
 *============================================================*/

cte_details
as
(

  select  
    tmt.* 
  from cte_dates as dts
     
  cross apply
  (
    select
      dos,
      clientID,
      pracID,
      patID      
    from
      dbo.RECURRING_SERVICES_MIN_BASED_PROCS_EXPD_DETAIL (@clientID,
                                                          @patID,
                                                          @pracID, 
                                                          dts.date, 
                                                          dbo.CONST_SERVICES_TREATMENT(),
                                                          null,
                                                          null,
                                                          1,
                                                          1)  
  ) as tmt
)

select distinct
  clientID as [CLIENT_ID],
  pracID   as [PRACTITIONER_ID],
  patID    as [PATIENT_ID]
from 
  cte_details
  
 
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[ONE_ON_ONE_AIDE_ASSIGNMENT_VIEW_BY_DATE] TO [webuser]
GO
