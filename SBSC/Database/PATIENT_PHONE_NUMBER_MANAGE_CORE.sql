USE SPEDMON
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_PHONE_NUMBER_MANAGE_CORE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.PATIENT_PHONE_NUMBER_MANAGE_CORE
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE PROCEDURE [dbo].[PATIENT_PHONE_NUMBER_MANAGE_CORE] (
    @userID             BIGINT
  , @today              DATETIME
  , @patientID          BIGINT
  , @phone              NVARCHAR(14)
)    
AS    
BEGIN     
 
/***************************************************************************    
 * PATIENT_PHONE_NUMBER_MANAGE_CORE */    
/**    
 * Manages phone numbers for a given patient
 * Note: Do not run this by itself.  Run within a transaction.
 ***************************************************************************/         
 
SET NOCOUNT ON    

declare @recID  as bigint
declare @active as bit

if (@patientID is null) return(0)

set @phone = ltrim(rtrim(isnull(@phone,N'')))
if (@phone = '') return(0)

select top 1 
  @recID  = t1.ID 
, @active = t1.ACTIVE
from dbo.PATIENTS_Phone as t1
where (
      (t1.PATIENT_ID = @patientID)
  and (t1.Phone = @phone)
)

/* If this phone number already exists */

if (@recID is not null)
begin

  /* And it is active */

  if (@active = 1) 
  begin
    /* Do nothing */
    return(0)
  end

  /* And it is NOT active*/

  else
  begin

    /* Deactivate all existing*/

	update dbo.PATIENTS_Phone 
	 set 
	    ACTIVE = 0
	  , LAST_MODIFIED_BY = @userID
	  , LAST_MODIFIED_ON = @today
	where PATIENT_ID = @patientID

	/* Reactivate this one */
	
	update dbo.PATIENTS_Phone
	  set ACTIVE = 1
	where ID = @recID
	
  end
end
else

/* This phone number does not exist */

begin

    /* Deactivate all existing*/

	update dbo.PATIENTS_Phone 
	  set 
	    ACTIVE           = 0
	  , LAST_MODIFIED_BY = @userID
	  , LAST_MODIFIED_ON = @today

	where (PATIENT_ID = @patientID)
 
    /* Add this one */

	insert into dbo.PATIENTS_Phone (
	     [PATIENT_ID]
	   , [Phone] 
	   , [CREATED_BY]
	   , [CREATED_ON]
	   , [ACTIVE] )
	values (@patientID,@phone,@userID,@today,1)
    
end

return (0)

END    
 
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[PATIENT_PHONE_NUMBER_MANAGE_CORE] TO [webuser]
GO