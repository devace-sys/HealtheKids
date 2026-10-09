USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.ProcedureType') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.ProcedureType
GO
/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE function [dbo].[ProcedureType]    
(@page nchar(10))    
returns int  
WITH SCHEMABINDING    
as    
begin    
    
/* For each record in the claims_procedures table a reference is provided     
   to a page.section in the LEA Billing Codes and Reimbursement Rates document.    
   This reference is stored in the PAGE column.  We identify the procedure type    
   based on this page.section number recorded */    
    
declare @vPage as decimal(18,3)    
set @vpage = convert(decimal(18,3),@page)    
    
if (@vPage >= 1)   AND (@vPage < 7)     return 1 -- IFSP/IEP Assessment    
if (@vPage >= 7)   AND (@vPage < 11)    return 2 -- Non Plan Assessement    
if (@vPage >= 11)  AND (@vPage <= 15.3) return 3 -- Treatment (all)    
if (@vPage >=15.4) AND (@vPage <= 15.5) return 4 -- Transportation (all)    
if (@vPage >= 16)                       return 5 -- Targeted Case Management    
return 0                                         -- Unknown    
    
end    
     
GO
/*-------------------------------
 * User Permissions
 *------------------------------*/
GRANT EXECUTE ON  [dbo].[ProcedureType] TO [webuser]
GO
