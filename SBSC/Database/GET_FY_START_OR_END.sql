USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.GET_FY_START_OR_END') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.GET_FY_START_OR_END
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[GET_FY_START_OR_END](
    @refDate  DATETIME
  , @whatDate SMALLINT) 
RETURNS DATETIME 
AS

/***************************************************************************    
 * GET_FY_START_OR_END */    
/**    
 * Determines fiscal year start or end with respect to refDate.
 * The traditional start year fy on 7/1 is assumed
 * 
 * @param   refDate  Reference date, usually today
 * @param   whatDate 1= start, 2= end
 * @return  datetime  
 ***************************************************************************/   
     
BEGIN
  declare @rd as date     = convert(date,isnull(@refDate,getdate()))
  declare @wd as smallint = isnull(@whatDate,1)
  declare @dr as datetime = null
  if (@wd not in (1,2)) return @dr
  select top 1 
    @dr = convert(datetime,(iif((@wd = 1),t1.FY_START, t1.FY_END)))
  from dbo.COMPANY_FISCAL_YEARS as t1
  where (@rd between t1.FY_START and t1.FY_END)
  return @dr
END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON [dbo].[GET_FY_START_OR_END] TO [webuser]
GO