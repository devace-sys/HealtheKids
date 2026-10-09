USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.IS_CLIENT_PAYING_PER_BATCH_AS_OF_REF_DATE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.IS_CLIENT_PAYING_PER_BATCH_AS_OF_REF_DATE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[IS_CLIENT_PAYING_PER_BATCH_AS_OF_REF_DATE] (
  @clientID BIGINT
, @refDate datetime) 

RETURNS BIT 
WITH SCHEMABINDING
AS     
BEGIN    
  
  if (@clientID is null) return null
  if (@refDate is null) set @refDate = getdate()  
 
  if exists (
    select top 1        cc.id     from dbo.CLIENT_CONTRACTS as cc       where ( 
          (cc.CLIENT_ID                     = @clientID)
	  and (cc.BILL_FOR_SERVICE_PAPER_CLAIMS = 1)
      and (@refDate between cc.START_DATE and cc.END_DATE)
	  and (cc.ACTIVE = 1)
    )
 ) 
 return 1
 
return 0  

END  
GO
