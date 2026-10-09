USE SPEDMON
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLIENT_SCHOOL_SESSION_BREAKS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CLIENT_SCHOOL_SESSION_BREAKS_VIEW
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[CLIENT_SCHOOL_SESSION_BREAKS_VIEW] (
    @userID                bigint
  , @userGroup             bigint    
  , @userRank              int     
  , @clientID              bigint     
  , @academicYearID        bigint
  , @term                  varchar(256)
  , @active                bit
  , @recID                 bigint    
)
    
returns table     
as
 
return 
(    
  select top (dbo.CONST_MAX_ROWS()) 
      ssb.*
	, clientWideBreakStr       = dbo.RPT_BIT_TO_YN(ssb.clientWideBreak)
	, academicYearName         = ssa.[name]
	, academicYearStartDate    = ssa.startDate
	, academicYearEndDate      = ssa.endDate
	, academicYearStartDateYMD = dbo.RPT_DATE_FMT_YYYY_MM_DD(ssa.startDate)
	, academicYearEndDateYMD   = dbo.RPT_DATE_FMT_YYYY_MM_DD(ssa.endDate)
	, siteName                 = ss.SITE_NAME
	, startDateStr             = dbo.RPT_DATE_FMT(ssb.startDate)
	, endDateStr               = dbo.RPT_DATE_FMT(ssb.endDate)
	, startDateStrYMD          = dbo.RPT_DATE_FMT_YYYY_MM_DD(ssb.startDate)
	, endDateStrYMD            = dbo.RPT_DATE_FMT_YYYY_MM_DD(ssb.endDate)
  
  from      [dbo].[CLIENT_SCHOOL_SESSION_BREAKS]         as ssb
  join      [dbo].[CLIENT_SCHOOL_SESSION_ACADEMIC_YEARS] as ssa on ssa.id     = ssb.academicYearID
  left join [dbo].SITES_Site                             as ss  on ss.SITE_ID = ssb.siteID
  
  where (
         (1=1)
    and ((@recID          is null)  or ( ssb.id             = @recID))
    and ((@clientID       is null)  or ( ssb.clientID       = @clientID))
    and ((@academicYearID is null)  or ( ssb.academicYearID = @academicYearID))
	and ((@term           is null)  or ( ssb.[name] like (('%' + isnull(@term,'') + '%'))))
	and ((@active         is null)  or ( ssb.active         = @active))
  )
  order by 
      ssb.startDate
	, ssb.endDate
)
 
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CLIENT_SCHOOL_SESSION_BREAKS_VIEW] TO [webuser]
GO