USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.BUILD_NOTE_TEMPLATE_TEXT') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.BUILD_NOTE_TEMPLATE_TEXT
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[BUILD_NOTE_TEMPLATE_TEXT]
(
    @svcName                   varchar(1000)
  , @effectiveDate             date
  , @endDate                   date
  , @noteCrit1                 varchar(8000)
  , @noteCrit2                 varchar(8000)
  , @noteCrit3                 varchar(8000)
  , @noteCrit4                 varchar(8000)
) 
RETURNS varchar(max)
AS     
BEGIN    
   return              
      + 'Service : '+ @svcName + CHAR(13)      
--      + 'Effective Date : ' + dbo.RPT_DATE_FMT(@effectiveDate) + CHAR(13)      
--      + case when @endDate is null then '' else 'End Date : ' + dbo.RPT_DATE_FMT(@endDate) + CHAR(13) end
--      + CHAR(13)
      + case when @noteCrit1 is null then '' else + @noteCrit1 + ' : ' + CHAR(13) end
      + case when @noteCrit2 is null then '' else + @noteCrit2 + ' : ' + CHAR(13) end
      + case when @noteCrit3 is null then '' else + @noteCrit3 + ' : ' + CHAR(13) end
      + case when @noteCrit4 is null then '' else + @noteCrit4 + ' : ' + CHAR(13) end
      + 'Comments/Observations : ' + CHAR(13) 
END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[BUILD_NOTE_TEMPLATE_TEXT] TO [webuser]
GO