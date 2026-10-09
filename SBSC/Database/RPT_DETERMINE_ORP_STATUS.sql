USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RPT_DETERMINE_ORP_STATUS') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RPT_DETERMINE_ORP_STATUS
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[RPT_DETERMINE_ORP_STATUS](
  @orpRequired         bit
, @orpDocID            bigint
, @orpPracID           bigint
, @orpPracNPI          varchar(50)
, @orpPracValidMcalOrp bit
) 
RETURNS VARCHAR(255) 
WITH SCHEMABINDING
AS     
BEGIN    

  declare @orpStatus as varchar(255) = null  
  
  set @orpPracNPI = ltrim(rtrim(isnull(@orpPracID,'')))
  
  set @orpStatus = case when @orpRequired = 1 
      then
      case when  @orpDocID   is null                 then 'Missing Order or Prescription in SpEdCare for Date of Service'
           when  @orpPracID  is null                 then 'No ORP Professional (physician/mental health valid ORP)'
           when  @orpPracNPI = ''                    then 'NPI or ORP Validation'
           when isnull (@orpPracValidMcalOrp, 0) = 0 then 'NPI or ORP Validation' 
           else 'ORP Compliant'
      end
      else
        'ORP Compliant'
      end   
     return @orpStatus
END  
GO


/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[RPT_DETERMINE_ORP_STATUS] TO [webuser]
GO
