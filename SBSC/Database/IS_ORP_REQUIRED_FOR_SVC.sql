USE SPEDMON
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.IS_ORP_REQUIRED_FOR_SVC') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION IS_ORP_REQUIRED_FOR_SVC
GO    

CREATE FUNCTION [dbo].[IS_ORP_REQUIRED_FOR_SVC] (
    @svcIsNeverBillable        bit
  , @svcType                   bigint
  , @dos                       date
  , @procedureBillingProgramID tinyint 
)
RETURNS BIT
AS
BEGIN
   declare @retVal as bit = 0   
   
   /* Skip if billing program is exempt*/

   if (@procedureBillingProgramID in (2,3)) return @retVal

   if (@svcIsNeverBillable = 0)
   begin
     if ((@svcType = dbo.CONST_SERVICES_TREATMENT()))
     begin   
       if (@dos >= dbo.CONST_ORP_DOCUMENTATION_FOR_TREATMENT_REQUIRED_START_DATE())
       begin
         set @retVal = 1
       end
     end
   end
   return @retVal   
END
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[IS_ORP_REQUIRED_FOR_SVC] TO [webuser]
GO
