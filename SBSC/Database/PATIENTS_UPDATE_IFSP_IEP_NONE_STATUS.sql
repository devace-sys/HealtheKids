USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENTS_UPDATE_IFSP_IEP_NONE_STATUS') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.PATIENTS_UPDATE_IFSP_IEP_NONE_STATUS
GO

/*-------------------------------
 * Create 
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[PATIENTS_UPDATE_IFSP_IEP_NONE_STATUS] (  
  @clientID bigint
)    
AS    
BEGIN     
    
/***************************************************************************    
 * PATIENTS_UPDATE_IFSP_IEP_NONE_STATUS */    
/**    
 ***************************************************************************/         
     
SET NOCOUNT ON    

/*============================================================
 * Init 
 *===========================================================*/  
    
declare @patsThatNeedIepStatusUpdate as table (
    patID       bigint  
  , pipID       bigint
unique clustered (patID)
)

exec dbo.PRINT_STATUS_MESSAGE 'Patients that need IEP status update - Starting'

exec dbo.PRINT_STATUS_MESSAGE 'Patients that need IEP status update - Searching for patients that need update'

insert into @patsThatNeedIepStatusUpdate (patID, pipID)
select distinct 
      pps.patID     
	, pipID = pip.id
from dbo.PATIENTS_Promised_Services as pps
join dbo.PATIENTS_Patient           as pap on pap.PATIENT_ID = pps.patID
join dbo.PATIENTS_Client            as pc  on pc.PATIENT_ID  = pap.PATIENT_ID
join dbo.PATIENTS_IEP               as pip on pip.PATIENT_ID = pap.PATIENT_ID
where (
	  (pps.active = 1) 
  and (pap.ACTIVE = N'Y')
  and (pip.IEP_IFSP_NONE = 'None')
  and ((@clientID is null) or (pc.CLIENT_ID = @clientID))
)

if exists (select top 1 * from @patsThatNeedIepStatusUpdate)
begin

  exec dbo.PRINT_STATUS_MESSAGE 'Patients that need IEP status update - Patients that need update found'

  exec dbo.PRINT_STATUS_MESSAGE 'Patients that need IEP status update - Performing updates'

  update pip
  set 
    pip.IEP_IFSP_NONE = N'IEP'
  from @patsThatNeedIepStatusUpdate as t1
  join dbo.PATIENTS_IEP             as pip on pip.id = t1.pipID
  where 
    (pip.PATIENT_ID = t1.patID)
end
else
begin
  exec dbo.PRINT_STATUS_MESSAGE 'Patients that need IEP status update - No patients that need updates found'
end

exec dbo.PRINT_STATUS_MESSAGE 'Patients that need IEP status update - Done'

END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[PATIENTS_UPDATE_IFSP_IEP_NONE_STATUS] TO [webuser]
GO
