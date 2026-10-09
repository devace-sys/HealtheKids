USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.DOS_DOB_IEP_BILLING_PROGRAM_TO_PLAN_TYPE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.DOS_DOB_IEP_BILLING_PROGRAM_TO_PLAN_TYPE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[DOS_DOB_IEP_BILLING_PROGRAM_TO_PLAN_TYPE] (
    @dos              DATETIME
  , @dob              DATETIME
  , @iep              BIT
  , @billingProgramID tinyint
) RETURNS INT AS
BEGIN    
  
  if (@billingProgramID is null) set @billingProgramID = 1
 
  if (@billingProgramID = 1)
  begin
    return dbo.DOS_DOB_IEP_TO_PLAN_TYPE(@dos,@dob,@iep)
  end
 
  else if (@billingProgramID = 2)
  begin
    return dbo.CONST_PLAN_CYBHI() 
  end
  
  else if (@billingProgramID = 3)
  begin
    return dbo.CONST_PLAN_RU_HEALTH() 
  end

  else
  begin 
    return null
  end

  return null

END    
GO
