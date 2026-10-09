USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.GENERAL_DATA_UPDATES') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.GENERAL_DATA_UPDATES
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[GENERAL_DATA_UPDATES]
AS
BEGIN   

  set nocount on

  /*------------------------------------------------------------------------------------------------------------*/

  exec dbo.CLEAN_PATIENT_DATA

  /*------------------------------------------------------------------------------------------------------------*/
  
  /* TODO: Remove the commented code out when we have verified that it is no longer needed.
     Effective 2026-2027 Q1 can no longer be a clone of the previous Q4. 
   */

  /*declare @refDate as datetime
  set @refDate = null
  exec dbo.RMTS_PARTICIPATION_ROSTER_AUTO_GENERATE_Q1 @refDate
  */

  /*------------------------------------------------------------------------------------------------------------*/

  -- transaction block inside

  exec  [dbo].[PATIENTS_STUDENTS_NO_LONGER_IN_ACTIVE_USE_DEACTIVATE]

     null ,
     15  -- @numOfMonthsOfInactivity as int

  /*------------------------------------------------------------------------------------------------------------*/
  
  exec dbo.CYBHI_TPA_UPDATE_PAT_ENROLLMENT_STATUS null

  /*------------------------------------------------------------------------------------------------------------*/
  
  exec dbo.PATIENTS_UPDATE_IFSP_IEP_NONE_STATUS null
 
  /*------------------------------------------------------------------------------------------------------------*/
  
  exec dbo.PRACTITIONERS_UPDATE_SITES null,0,1

  /*------------------------------------------------------------------------------------------------------------*/

  /* TODO: Add any additional general data update calls to the end of this file */

  /*------------------------------------------------------------------------------------------------------------*/
  
  RETURN(0)
END 
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[GENERAL_DATA_UPDATES] TO [webuser]
GO
