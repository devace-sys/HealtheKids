USE SPEDMON
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLIENT_SCHOOL_SESSION_CALC_DATES_NOT_IN_SESSION') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CLIENT_SCHOOL_SESSION_CALC_DATES_NOT_IN_SESSION
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[CLIENT_SCHOOL_SESSION_CALC_DATES_NOT_IN_SESSION] (
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
select t1.* from dbo.[CLIENT_SCHOOL_SESSION_CLIENT_WIDE_CALC_DATES_NOT_IN_SESSION]   (@clientID, @startDate, @endDate) as t1
union all
select t2.* from dbo.[CLIENT_SCHOOL_SESSION_SITE_SPECIFIC_CALC_DATES_NOT_IN_SESSION] (@clientID, @siteID, @startDate, @endDate) as t2
) 
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].CLIENT_SCHOOL_SESSION_CALC_DATES_NOT_IN_SESSION TO [webuser]
GO