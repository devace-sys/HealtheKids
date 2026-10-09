USE SPEDMON
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLIENT_SCHOOL_SESSION_SITE_SPECIFIC_CALC_DATES_NOT_IN_SESSION') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CLIENT_SCHOOL_SESSION_SITE_SPECIFIC_CALC_DATES_NOT_IN_SESSION
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[CLIENT_SCHOOL_SESSION_SITE_SPECIFIC_CALC_DATES_NOT_IN_SESSION] (
    @clientID    bigint
  , @siteID      bigint
  , @startDate   datetime
  , @endDate     datetime
)   

returns 
table 
as
return
(

/*============================================================
 * Site specific breaks
 *===========================================================*/  

  select 
      breakName = csa.[name] + ' - ' + csb.[name]
    , startDate = csb.startDate
    , endDate   = csb.endDate
  from dbo.[CLIENT_SCHOOL_SESSION_BREAKS]         as csb
  join dbo.[CLIENT_SCHOOL_SESSION_ACADEMIC_YEARS] as csa on csa.id = csb.academicYearID
  where ( 
        (csb.clientID = @clientID)
    and (csb.siteID = @siteID)
    and (csb.clientWideBreak = 0)
    and ((@startDate is null) or (csb.startDate >= @startDate))
	and ((@endDate   is null) or (csb.endDate <= @endDate))
    and (csb.active = 1)
  )
) 
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CLIENT_SCHOOL_SESSION_SITE_SPECIFIC_CALC_DATES_NOT_IN_SESSION] TO [webuser]
GO