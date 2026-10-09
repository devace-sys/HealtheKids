USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RPT_PATIENT_FIND_REDUNDANT_RECORDS') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RPT_PATIENT_FIND_REDUNDANT_RECORDS
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[RPT_PATIENT_FIND_REDUNDANT_RECORDS] ( @clientID BIGINT)    

RETURNS 
TABLE
AS 
RETURN
(

select top (dbo.CONST_MAX_ROWS())
    [Client] = clc.CLIENT_NAME
  , pfrrc2.*
  , [SpEdCare Client ID] = clc.CLIENT_ID
from dbo.CLIENTS_Client as clc
cross apply (
  select top (dbo.CONST_MAX_ROWS())
      [Record Set] = pfrrc1.RECORD_SET
	, [Redudancy Found Using] = case 
	  when pfrrc1.FOUND_IN_PASS = 1 then '1 - CSIS/SSID'
	  when pfrrc1.FOUND_IN_PASS = 2 then '2 - BIC'
	  when pfrrc1.FOUND_IN_PASS = 3 then '3 - Student ID'
	  when pfrrc1.FOUND_IN_PASS = 4 then '4 - Name + DOB + Sex'
	  else ''
	end
	, [CSIS / SSID]  = pfrrc1.CSIS
	, [BIC]        = pfrrc1.BIC
	, [Student ID]  = pfrrc1.STUDENT_ID
	, [Last]       = pfrrc1.LAST_NAME
	, [First]      = pfrrc1.FIRST_NAME
	, [DOB]        = dbo.RPT_DATE_FMT(pfrrc1.DATE_OF_BIRTH)
    , [Sex]        = pfrrc1.SEX
	, [Active]     = upper(pfrrc1.ACTIVE)
	, [SpEdCare Patient ID]  = pfrrc1.PATIENT_ID
  from dbo.PATIENT_FIND_REDUNDANT_RECORDS_CORE (clc.CLIENT_ID) as pfrrc1
  order by 
      pfrrc1.RECORD_SET
    , pfrrc1.PATIENT_ID 
) as pfrrc2    
where (
      (1=1)
  and ((clc.LEA = 1) or (clc.MAA = 1))
  and ((@clientID is null) or (clc.CLIENT_ID = @clientID))

)
order by 
  clc.CLIENT_NAME
  
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].RPT_PATIENT_FIND_REDUNDANT_RECORDS TO [webuser]
GO   

