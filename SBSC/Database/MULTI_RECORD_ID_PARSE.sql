USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.MULTI_RECORD_ID_PARSE') AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.MULTI_RECORD_ID_PARSE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[MULTI_RECORD_ID_PARSE](@RecordIDsIn varchar(8000), @delimiter char(1))
                                         
returns @temptable TABLE (id    int identity(1,1) PRIMARY KEY,    
                          recid bigint )          
   
/***************************************************************************    
 * MultiRecordIDParse */    
/**    
 * Splits string of record ids delimited by delimiter into a table of record
 * ids ordered by id    
 *    
 * @param  RecordIDsIn     String to split    
 * @param  delimiter       dates are delimited by this character    
 * @return                 Table of parts    
 ***************************************************************************/            
     
AS          
begin    
   
  declare @cnt as int                    
  
  /*-------------------------------    
   * If the string is null or    
   * zero length get out    
   *------------------------------*/    
     
  IF (@RecordIDsIn  IS NULL) RETURN 
  IF (@delimiter    IS NULL) SET @delimiter  = ','      
 
  INSERT INTO @temptable
  SELECT convert(bigint,part) FROM dbo.STRING_SPLIT(@RecordIDsIn, @delimiter, NULL)
   
RETURN  
END
          
GO
