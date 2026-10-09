/* Note: We need this primarily for a dropdown */

USE SPEDMON
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENTS_Promised_Services_Pcal_Compliance_Rating_For_Pat_Codes_View') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PATIENTS_Promised_Services_Pcal_Compliance_Rating_For_Pat_Codes_View
GO

CREATE FUNCTION [dbo].[PATIENTS_Promised_Services_Pcal_Compliance_Rating_For_Pat_Codes_View] (
    @userID     bigint    
  , @userGroup  int
  , @userRank   int    
) 
    
RETURNS TABLE 
AS RETURN (       

  select top (dbo.CONST_MAX_ROWS())
       id = t1.code /* We need to use code as the id */	 
     , t1.[name]
  from dbo.PATIENTS_Promised_Services_Pcal_Compliance_Rating_For_Pat_Codes as t1

  where (
        (1=1)
    and (t1.active = 1)
  )
  order by
      t1.code desc
)
GO

GRANT SELECT ON  [dbo].[PATIENTS_Promised_Services_Pcal_Compliance_Rating_For_Pat_Codes_View] TO [webuser]
GO
