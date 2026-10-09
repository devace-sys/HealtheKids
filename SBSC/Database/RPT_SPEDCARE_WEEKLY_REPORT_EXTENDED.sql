USE SPEDMON
GO

/*-------------------------------
* Exists/Drop
*------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RPT_SPEDCARE_WEEKLY_REPORT_EXTENDED') AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RPT_SPEDCARE_WEEKLY_REPORT_EXTENDED
GO

/***************************************************************************
 * RPT_SPEDCARE_WEEKLY_REPORT_EXTENDED */
/**
 ***************************************************************************/

CREATE FUNCTION [dbo].[RPT_SPEDCARE_WEEKLY_REPORT_EXTENDED]
(
   @today       datetime
 , @startWeek   datetime
 , @endWeek     datetime
)
RETURNS TABLE
AS RETURN
(
  select top (dbo.CONST_MAX_ROWS())
    t1.*
  from dbo.RPT_SPEDCARE_WEEKLY_REPORT_EXTENDED_CORE (@today, @startWeek, @endWeek) as t1
  order by 
    t1.CLIENT_ID
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[RPT_SPEDCARE_WEEKLY_REPORT_EXTENDED] TO [webuser]
GO
  
