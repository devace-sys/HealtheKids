USE SPEDMON
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Practitioner_Patient_Scheduled_Services_Data_Core') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.Practitioner_Patient_Scheduled_Services_Data_Core
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[Practitioner_Patient_Scheduled_Services_Data_Core] (
    @clientID               bigint     
  , @pracID                 bigint
  , @patID                  bigint 
  , @practitionerPatientCaseloadExpectedServiceID  bigint	
  , @active                                        bit
  , @recID                                         bigint  
  , @pracPatGroupID								   bigint
)
    
returns table     
as
 
return 
(    

/***************************************************************************
 * Practitioner_Patient_Scheduled_Services_Data_Core */
/**
 ***************************************************************************/

/* Show non recurring regardless of caseload row relation */

select
  ppssNonRecurring.*
from dbo.Practitioner_Patient_Scheduled_Services as ppssNonRecurring
where (
          ((ppssNonRecurring.clientID = @clientID)
      and (ppssNonRecurring.pracID    = @pracID))
	  and ((@patID is null)                                        or (ppssNonRecurring.patID  = @patID))
	  and ((@recID   is null)                                      or (ppssNonRecurring.id     = @recID))
	  and ((@active  is null)                                      or (ppssNonRecurring.active = @active))
	  and ((@pracPatGroupID is null)							   or (ppssNonRecurring.caseloadGrpID = @pracPatGroupID))
      and (ppssNonRecurring.recurring = 0)
)

union

/* Show recurring with optional caseload row relation filter */

select
  ppssRecurring.*
from dbo.Practitioner_Patient_Scheduled_Services as ppssRecurring
where (
          ((ppssRecurring.clientID = @clientID)
      and (ppssRecurring.pracID    = @pracID))
	  and ((@patID is null)                                        or (ppssRecurring.patID  = @patID))
	  and ((@practitionerPatientCaseloadExpectedServiceID is null) or (ppssRecurring.practitionerPatientCaseloadExpectedServiceID = @practitionerPatientCaseloadExpectedServiceID))
	  and ((@recID   is null)                                      or (ppssRecurring.id     = @recID))
	  and ((@active  is null)                                      or (ppssRecurring.active = @active))
	  and ((@pracPatGroupID is null)							   or (ppssRecurring.caseloadGrpID = @pracPatGroupID))
      and (ppssRecurring.recurring = 1)
)

) 
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[Practitioner_Patient_Scheduled_Services_Data_Core] TO [webuser]
GO