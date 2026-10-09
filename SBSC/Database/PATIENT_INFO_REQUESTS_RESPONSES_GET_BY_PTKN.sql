USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (
    SELECT * 
    FROM sys.objects 
    WHERE object_id = OBJECT_ID('dbo.PATIENT_INFO_REQUESTS_RESPONSES_GET_BY_PTKN') 
      AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT')
)
begin 
  DROP FUNCTION dbo.PATIENT_INFO_REQUESTS_RESPONSES_GET_BY_PTKN;
end
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[PATIENT_INFO_REQUESTS_RESPONSES_GET_BY_PTKN] (
  @ptkn VARCHAR(512)
) 
RETURNS TABLE
AS RETURN (
with
cte_p1
as
(
  select top 1 
    
	   requestID = pirr.id     
	 , pirr.clientID
     , studentIDLast2Chars = right(trim(isnull(psvc2.STUDENT_ID,N'')),2)
     , clientName          = clc.CLIENT_NAME
     , clientLogoFileData  = clc.clientlogofiledata
     , requestSentToJSON   = pirr.requestSentToJSON

     , requestFromSource = case 
        when (pirr.individualRequest = 0) and (pirr.requestFromAuthor = 0) then 1
	    when (pirr.individualRequest = 0) and (pirr.requestFromAuthor = 1) then 2
	    when (pirr.individualRequest = 1) and (pirr.requestFromAuthor = 0) then 3
	    when (pirr.individualRequest = 1) and (pirr.requestFromAuthor = 1) then 4
	  end
    
	, pirr.createdBy

	, pirr.requestingSaveType
    , pirr.requestingWhatInfo

	, patName = isnull(pap2.patName,N'')
	, dobStr  = isnull(pap2.dobStr,'')
	

  from dbo.Patient_Info_Requests_Responses as pirr
  join dbo.CLIENTS_Client                  as clc  on  clc.CLIENT_ID  = pirr.clientID
  
  outer apply (
    select top 1
      psvc1.STUDENT_ID 
    from dbo.PATIENTS_SITES_VIEW_CURRENT(pirr.clientID) as psvc1
    where 
      (psvc1.PATIENT_ID = pirr.patID)
  ) as psvc2

  outer apply (
    select top 1 
        patName = pap1.CONCAT_NAME
	  , dobStr  = dbo.RPT_DATE_FMT(pap1.DATE_OF_BIRTH)
    from dbo.PATIENTS_Patient as pap1
    where 
      (pap1.PATIENT_ID = pirr.patID)
  ) as pap2
  
  where (
        (pirr.publicToken      = @ptkn)
    and (pirr.responseReceived = 0)
    and (pirr.completed        = 0)
    and (pirr.active           = 1)
  )
)
select 
    p1.*
  , requesterName = case 
                       when p1.requestFromSource = 1 then fromS1.requesterName
					   when p1.requestFromSource = 4 then fromS4.requesterName
					 end
  , requesterTitle = case 
                       when p1.requestFromSource = 1 then fromS1.requesterTitle
					   when p1.requestFromSource = 4 then fromS4.requesterTitle
					 end

  , requesterEmail = case 
                       when p1.requestFromSource = 1 then fromS1.requesterEmail
					   when p1.requestFromSource = 4 then fromS4.requesterEmail
					 end
   
  , requesterPhone = case 
                       when p1.requestFromSource = 1 then fromS1.requesterPhone
					   when p1.requestFromSource = 4 then fromS4.requesterPhone
					 end
    
from cte_p1 as p1

outer apply (
  select top 1 
      pirrmu.requesterName
    , requesterTitle = ''
	, pirrmu.requesterEmail
    , pirrmu.requesterPhone
  from dbo.PATIENT_INFO_REQUESTS_RESPONSES_MASS_UPDATE_ROWS as pirrmur
  join dbo.PATIENT_INFO_REQUESTS_RESPONSES_MASS_UPDATES     as pirrmu on pirrmu.id = pirrmur.pirrMassUpdateID
  where (
    (pirrmur.pirrID = p1.requestID)
  )
) as fromS1

outer apply (
  select top 1  
      requesterName  = ua1.[name]
    , requesterTitle = ua1.pracDispGroupName    
    , requesterEmail = ua1.email
    , requesterPhone = ua1.phone
  from users.dbo.USERS_ALL as ua1 
  where 
    (ua1.id = p1.createdBy)
) as fromS4

)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON [dbo].[PATIENT_INFO_REQUESTS_RESPONSES_GET_BY_PTKN] TO [webuser];
GO
