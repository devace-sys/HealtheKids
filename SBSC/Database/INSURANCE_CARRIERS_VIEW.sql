USE SPEDMON
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.INSURANCE_CARRIERS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.INSURANCE_CARRIERS_VIEW
GO

CREATE FUNCTION [dbo].[INSURANCE_CARRIERS_VIEW] (
    @userID     bigint    
  , @userGroup  int
  , @userRank   int    
  , @term       varchar(255)
  , @active     bit    /* For future use */
  , @recID      bigint
) 
    
RETURNS TABLE 
AS RETURN (       

  select top (dbo.CONST_MAX_ROWS())
       ic.id 
     , [name] = ic.[name] 
	 , ic.carrierCode
	 , carrierName = ic.[name]
	 , ic.ohcCode
	 , ic.planTypeCode
	 , ic.planSupportedByCYBHI
	 , ic.usState
	 , ic.active
  from dbo.INSURANCE_CARRIERS as ic

  WHERE (
        (1=1)
	and ((@recID is null) or (ic.id = @recID))
	and ((@active is null) or (ic.active = @active)) 
	and ((@term  is null) or (ic.[name] like ( @term + '%' ))) 
  )
  order by
      ic.[name]
	, ic.[carrierCode]
	, ic.id
)
GO

GRANT SELECT ON  [dbo].[INSURANCE_CARRIERS_VIEW] TO [webuser]
GO
