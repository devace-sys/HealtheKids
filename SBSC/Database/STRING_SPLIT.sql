USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.STRING_SPLIT') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.STRING_SPLIT
GO
/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[STRING_SPLIT] (@string varchar(8000),     
                             @delimiter char(1),     
                             @trimSlices bit)           
returns                      @temptable     
                               TABLE (id int identity(1,1) primary key,     
                               part varchar(255))           
/***************************************************************************    
 * STRING_SPLIT */    
/**    
 * Splits string delimited by delimiter into a table of parts ordered by id    
 *    
 * This function was based on another string split function courtesy of     
 * http://stackoverflow.com/questions/2786377/how-to-split-a-string-in-tsql/2786388#2786388           
 *    
 * @param  string          String to split    
 * @param  delimiter       Parts are delimited by this character    
 * @return                 Table of parts    
 ***************************************************************************/            

with schemabinding      
as           
begin    
    
  declare @idx   int                    -- Position of delimiter    
  declare @slice varchar(255)           -- String part    
      
  /*-------------------------------    
   * If the string is null or    
   * zero length get out    
   *------------------------------*/    
      
  if (@string is null) return           
  set @string = ltrim(rtrim(@string))    
  if (len(@string) < 1) return    
      
  /*-------------------------------    
   * Set our defaults    
   *------------------------------*/    
      
  if (@delimiter  is null) set @delimiter  = '|'     
  if (@trimSlices is null) set @trimSlices = 1    
        
  /*-------------------------------    
   * Split the string    
   *------------------------------*/    
    
  set @idx = 1            
  while (@idx!= 0)           
  begin           
        
    /*-------------------------------    
     * Find position of first/next    
     * delimeter    
     *------------------------------*/    
      
    set @idx = charindex(@delimiter,@string)           
        
    /*-------------------------------    
     * If the position is found     
     * grab the text to the left of    
     * the delimiter otherwise    
     * if no position is found there    
     * is no delimter so we grab    
     * the remaining text    
     *------------------------------*/    
         
    if @idx != 0           
      set @slice = left(@string,@idx - 1)           
    else           
      set @slice = @string           
        
    /*-------------------------------    
     * Remove white space from slice    
     *------------------------------*/        
         
    if (@trimSlices = 1)    
      set @slice = ltrim(rtrim(@slice))    
        
    /*-------------------------------    
     * Save the text slice we grabbed    
     * Note: This will include any    
     * empty slices.  Empty slices    
     * can occur if we have an input    
     * string like the following:    
     * 'hello|world||how|are|you    
     *              ^ Empty slice    
     *------------------------------*/    
         
    insert into @temptable(part) values(@slice)           
        
    /*-------------------------------    
     * If we are out of delimiters    
     * exit    
     *------------------------------*/    
    
    if @idx = 0 break    
        
    /*-------------------------------    
     * Otherwise remove text we grabbed    
     * from the original string along    
     * with the last delimiter    
     *------------------------------*/    
    
    set @string = right(@string, len(@string) - @idx)           
        
  end       
return          
end    
    
GO
