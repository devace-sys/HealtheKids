USE SPEDMON
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLIENT_SCHOOL_SESSION_ACADEMIC_YEARS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CLIENT_SCHOOL_SESSION_ACADEMIC_YEARS_VIEW
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[CLIENT_SCHOOL_SESSION_ACADEMIC_YEARS_VIEW] (
    @userID                bigint
  , @userGroup             bigint    
  , @userRank              int     
  , @clientID              bigint     
  , @term                  varchar(256)
  , @active                bit
  , @recID                 bigint    
)
    
returns table     
as
 
return 
(    
  select top (dbo.CONST_MAX_ROWS()) 
  
      ssa.*
	, companyFiscalYearName = cfy.FY_DEFINITION
	, startDateStr          = dbo.RPT_DATE_FMT(ssa.startDate)
	, endDateStr            = dbo.RPT_DATE_FMT(ssa.endDate)
	, startDateStrYMD       = dbo.RPT_DATE_FMT_YYYY_MM_DD(ssa.startDate)
	, endDateStrYMD         = dbo.RPT_DATE_FMT_YYYY_MM_DD(ssa.endDate)
  
  from [dbo].[CLIENT_SCHOOL_SESSION_ACADEMIC_YEARS] as ssa
  join [dbo].[COMPANY_FISCAL_YEARS]                 as cfy on cfy.ID = ssa.companyFiscalYearID
  
  where (
         (1=1)
    and ((@recID    is null)  or ( ssa.id       = @recID))
    and ((@clientID is null)  or ( ssa.clientID = @clientID))
    and ((@term     is null)  or (ssa.[name] like (('%' + isnull(@term,'') + '%'))))
	and ((@active   is null)  or ( ssa.active   = @active))
  )
  order by 
      ssa.startDate
	, ssa.endDate
)
 
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CLIENT_SCHOOL_SESSION_ACADEMIC_YEARS_VIEW] TO [webuser]
GO