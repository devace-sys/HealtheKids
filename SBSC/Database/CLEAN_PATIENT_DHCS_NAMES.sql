USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLEAN_PATIENT_DHCS_NAMES') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.CLEAN_PATIENT_DHCS_NAMES
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[CLEAN_PATIENT_DHCS_NAMES]
AS
BEGIN   

set nocount on

begin try

RAISERROR ('Cleaning patient data - DHCS Names', 0, 1) WITH NOWAIT

declare @today    as datetime = getdate()
declare @recCount as int = 0
declare @txOpen   as bit = 0

declare @pdc as table (
    CLIENT_ID             bigint
  , PATIENT_ID            bigint
  , DHCS_LAST_NAME_OLD    nvarchar(50)
  , DHCS_FIRST_NAME_OLD   nvarchar(50)
  , DHCS_MIDDLE_NAME_OLD  nvarchar(50)
  , DHCS_LAST_NAME_NEW    nvarchar(50)
  , DHCS_FIRST_NAME_NEW   nvarchar(50)
  , DHCS_MIDDLE_NAME_NEW  nvarchar(50)
)

/*-------------------------------    
 * Find pending updates   
 *------------------------------*/  

RAISERROR ('Cleaning patient data - DHCS Names - Comparing 835 import data and our data to find patient name updates', 0, 1) WITH NOWAIT

insert into @pdc
select 
    CLIENT_ID 
  , PATIENT_ID
  , DHCS_LAST_NAME_OLD
  , DHCS_FIRST_NAME_OLD
  , DHCS_MIDDLE_NAME_OLD
  , DHCS_LAST_NAME_NEW
  , DHCS_FIRST_NAME_NEW
  , DHCS_MIDDLE_NAME_NEW
from dbo.IMPORT_FROM_835_LATEST_PATIENT_DATA_CHANGES 

select @recCount = count(PATIENT_ID) from @pdc

/*-------------------------------    
 * If none get out
 *------------------------------*/  

if (@recCount = 0)
begin
  RAISERROR ('Cleaning patient data - DHCS Names - No updates found', 0, 1) WITH NOWAIT
  RETURN(0)
end

/*-------------------------------    
 * Otherwise update patient data
 *------------------------------*/  

RAISERROR ('Cleaning patient data - DHCS Names - Updating patient data.', 0, 1) WITH NOWAIT

begin transaction
  
  set @txOpen = 1
  
  /* Update patients table with new dhcs name */

  update pap
  set 
      pap.DHCS_LAST_NAME    = pdc.DHCS_LAST_NAME_NEW
    , pap.DHCS_FIRST_NAME   = pdc.DHCS_FIRST_NAME_NEW
    , pap.DHCS_MIDDLE_NAME  = pdc.DHCS_MIDDLE_NAME_NEW
    , pap.LAST_UPDATED      = @today

  from dbo.PATIENTS_Patient as pap
  join @pdc                 as pdc on pdc.PATIENT_ID = pap.PATIENT_ID
  where (pap.PATIENT_ID = pdc.PATIENT_ID)

  /* Create audit records */

  insert into dbo.PATIENTS_AUDIT_LOG (patRecID, loggedOn, userID, saveType, reason)
  select 
      PATIENT_ID
    , @today
    , 0
    , dbo.CONST_REC_STATE_MOD()
    ,   'Corrected DHCS Name from 835 data '
      + ' [Old DHCS Last, First] : '	
	  + t1.DHCS_LAST_NAME_OLD
	  + ', ' 
	  + t1.DHCS_FIRST_NAME_OLD
	  + ' [New DHCS Last, First] : '
	  + t1.DHCS_LAST_NAME_NEW
	  + ', ' 
	  + t1.DHCS_FIRST_NAME_NEW		
  from @pdc as t1

commit transaction
set @txOpen = 0
RAISERROR ('Cleaning patient data - DHCS Names - Done', 0, 1) WITH NOWAIT
RETURN(0)

end try
   
begin catch

   /*-------------------------------    
     * If we end up here something    
     * went wrong.  Cancel any pending    
     * transactions and return any    
     * error any error messages to    
     * the caller    
     *------------------------------*/    
       
  -- Error or raise error with severity 11 to 19 will be caught here    

  if (@txOpen = 1) rollback transaction

  DECLARE @ErrorMessage  AS NVARCHAR(4000)    
  DECLARE @ErrorSeverity AS INT    
  DECLARE @ErrorState    AS INT    
      
  SELECT  @ErrorMessage  = ERROR_MESSAGE(),    
          @ErrorSeverity = ERROR_SEVERITY(),    
          @ErrorState    = ERROR_STATE()    
      
  SET @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ']'
      
  -- Reraise the error so it returns back to the server    
      
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    

end catch


END 
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[CLEAN_PATIENT_DHCS_NAMES] TO [webuser]
GO
