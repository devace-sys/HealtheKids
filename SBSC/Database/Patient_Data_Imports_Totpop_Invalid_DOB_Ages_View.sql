USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Patient_Data_Imports_Totpop_Invalid_DOB_Ages_View') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION Patient_Data_Imports_Totpop_Invalid_DOB_Ages_View
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[Patient_Data_Imports_Totpop_Invalid_DOB_Ages_View] (
    @logEntry       BIGINT

/*
  , @fileSubClass   varchar(256)

  , @findTooYoung   BIT
  , @findTooOld     BIT

*/

)
    
RETURNS 
@retval TABLE
(
   ID bigint
  ,[log_entry] bigint

  ,[Last_Name] varchar(75)
  ,[First_Name] varchar(75)

  ,calcAge      int
  ,[Grade]      varchar(10)

  ,isTooYoung   int
  ,isTooOld     int

  ,[Student_ID] varchar(25)
  ,[CSIS_SSID]  varchar(12)

  ,[DOB]        varchar(10)
  ,[Sex]        char(1)
)
AS
BEGIN

declare @today datetime = GETDATE()

--if (@fileSubClass = dbo.CONST_PATIENT_DATA_FILE_SUB_CLASS_TOTAL_POP())
--begin

  INSERT INTO @retval

  select * from
  (
    SELECT [ID]
      ,[FROM_CLIENT_log_entry]

      ,[Last_Name]
      ,[First_Name]

      ,calcAge
      ,[Grade]

      , CASE
        WHEN ISNUMERIC( Grade ) = 1
             AND Grade > 0
             AND ( calcAge - grade ) < 4
         THEN 1 ELSE 0 END isTooYoung

      , CASE
        WHEN ISNUMERIC( Grade ) = 1
             AND Grade > 0
             AND ( calcAge - grade ) > 8
         THEN 1 ELSE 0 END isTooOld

      ,[Student_ID]
      ,[CSIS_SSID]

      ,[DOB]
      ,[Sex]

    FROM [SPEDMON].[dbo].[Import_From_A_From_Client_ToSPED_File_rows]

    CROSS APPLY (
    select CAST( datediff(month, DOB, @today) as decimal) / 12  calcAge
    ) ca

    where FROM_CLIENT_log_entry = @logEntry
      AND SpEd_Marker != 1
  ) s1

  WHERE isTooYoung = 1 OR isTooOld = 1


--end

--else if (@fileSubClass = dbo.CONST_PATIENT_DATA_FILE_SUB_CLASS_SPEC_ED_SVCS())
--begin
--end

return -- returns @retval

end
GO

GRANT SELECT ON  [dbo].[Patient_Data_Imports_Totpop_Invalid_DOB_Ages_View] TO [webuser]
GO
