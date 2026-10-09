USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.MULTI_DATE_PARSE') AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.MULTI_DATE_PARSE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[MULTI_DATE_PARSE](@datesIn varchar(8000),
                                         @delimiter char(1)  )
                                         
returns @temptable TABLE (id int identity(1,1) PRIMARY KEY,    
                          date datetime)          
   
/***************************************************************************    
 * MultiDateParse */    
/**    
 * Splits string of dates delimited by delimiter into a table of datetime values 
 * ordered by id    
 *    
 * @param  datesIn         String to split    
 * @param  delimiter       dates are delimited by this character    
 * @return                 Table of parts    
 ***************************************************************************/            
     
AS          
begin    
   
  declare @cnt   int                    
  
  /*-------------------------------    
   * If the string is null or    
   * zero length get out    
   *------------------------------*/    
     
  IF (@datesIn   IS NULL) RETURN 
  IF (@delimiter IS NULL) SET @delimiter  = ','      
 
  INSERT INTO @temptable
  SELECT convert(datetime,part) FROM dbo.STRING_SPLIT(@datesIn,@delimiter,NULL)
   
RETURN  
END
          
GO
