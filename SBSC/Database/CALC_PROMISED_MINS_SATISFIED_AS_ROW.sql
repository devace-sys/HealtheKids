USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

 IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CALC_PROMISED_MINS_SATISFIED_AS_ROW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CALC_PROMISED_MINS_SATISFIED_AS_ROW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[CALC_PROMISED_MINS_SATISFIED_AS_ROW] (
    @numMins                       int = 0
  , @patAbsent                     bit = 0
  , @pracAbsent                    bit = 0
  , @makeupSession                 bit = 0
  , @patAbsentMinsAreSatisfiedMins bit =  1
  , @attendanceSelectionID         int = -1
) 
RETURNS table
WITH SCHEMABINDING
AS
return
(     
  select top 1 
  
  numMinsSatisfied = case 

    /* Normal session.  Minutes are satisifed. */  
	
	when ((@patAbsent = 0) and (@pracAbsent = 0) and (@makeupSession = 0)) then @numMins 
    
	/* Patient is absent */

	when (@patAbsent = 1) then 
		
	  /* and we are in a mode where we count patient absenses as 
	   * satisfied minutues then minute are satisfied.  
	   * The practitioner was present and the patient was not
	   * service would have been given if patient was present.
	   * This is our interpretation of how absenses should be
	   * treated in determining satisfied minutes. */
	   
	  iif ((@patAbsentMinsAreSatisfiedMins = 1)
	      , @numMins
	
	      /* Otherwise if we are in a mode where a patient absence 
		   * excused or not is NOT counted as minutes satisfied except for
		   * a few cases.  This is CDEs current interpretation. */

		  , iif ((@attendanceSelectionID in (
		             11 /* Student Non Participatory (Field Trip, Assembly, etc.) */
		           , 13 /* Student Participating In Required State Testing */
				  ))
		         , @numMins /* This is one of CDEs exceptions*/
				 , 0        /* Otherwise not */)
    )
	
	/* Makeup session.  Minutes are satisfied.*/    
	
	when (@makeupSession = 1) then @numMins  
    
	/* Practitioner is absent.  Minutes are not satisfied. */
	
	when (@pracAbsent = 1) then 0         
    
	/* Any other case is invalid so we return 0 */
	else  0      
  end /* Case */
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CALC_PROMISED_MINS_SATISFIED_AS_ROW] TO [webuser]
GO