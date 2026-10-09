USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Patient_Data_Imports_Parse_SpEd_Data_File_Row_Determine_Can_Use') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.Patient_Data_Imports_Parse_SpEd_Data_File_Row_Determine_Can_Use
GO


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION dbo.Patient_Data_Imports_Parse_SpEd_Data_File_Row_Determine_Can_Use (
      @includeServiceAmmended     bit
	, @includeServiceDiscontinued bit 
    , @includeDoNotReport         bit
	, @svcAmended                 bit
	, @svcDiscontinued            bit
	, @doNotReport                bit
	
) 
RETURNS BIT 
WITH SCHEMABINDING
AS     
BEGIN 

declare @c1 as bit = 1
declare @c2 as bit = 1
declare @c3 as bit = 1

/*###########################################################################*/
/*# Include rows where service is flagged as ammended?                      #*/
/*#                                                                         #*/
/*###########################################################################*/

if ((@includeServiceAmmended = 0) and (@svcAmended = 0)) set @c1 = 1
if ((@includeServiceAmmended = 1) and (@svcAmended = 0)) set @c1 = 1
if ((@includeServiceAmmended = 0) and (@svcAmended = 1)) set @c1 = 0
if ((@includeServiceAmmended = 1) and (@svcAmended = 1)) set @c1 = 1

/*###########################################################################*/
/*# Include rows where service is flagged as discontinued?                  #*/
/*#                                                                         #*/
/*###########################################################################*/

if ((@includeServiceDiscontinued = 0) and (@svcDiscontinued = 0)) set @c2 = 1
if ((@includeServiceDiscontinued = 1) and (@svcDiscontinued = 0)) set @c2 = 1
if ((@includeServiceDiscontinued = 0) and (@svcDiscontinued = 1)) set @c2 = 0
if ((@includeServiceDiscontinued = 1) and (@svcDiscontinued = 1)) set @c2 = 1

/*###########################################################################*/
/*# Include rows where service is flagged as do not report?                 #*/
/*#                                                                         #*/
/*###########################################################################*/

if ((@doNotReport    = 0) and (@includeDoNotReport = 0)) set @c3 = 1
if ((@doNotReport    = 1) and (@includeDoNotReport = 0)) set @c3 = 0
if ((@doNotReport    = 0) and (@includeDoNotReport = 1)) set @c3 = 1
if ((@doNotReport    = 1) and (@includeDoNotReport = 1)) set @c3 = 1

/*###########################################################################*/
/*# If any of the previous checks did not result in including the row       #*/
/*# exit with a no.  Note: We need to perform this evaluation HERE to       #*/
/*# properly handle client specific svcCode rules so DO NOT MOVE THIS.      #*/
/*###########################################################################*/

if ((@c1 = 0 ) or (@c2 = 0) or (@c3 = 0)) return 0

/*###########################################################################*/
/*# Otherwise include the row                                               #*/
/*###########################################################################*/

return 1

END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[Patient_Data_Imports_Parse_SpEd_Data_File_Row_Determine_Can_Use] TO [webuser]
GO