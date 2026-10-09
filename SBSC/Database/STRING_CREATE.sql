USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.STRING_CREATE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.STRING_CREATE
GO
/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION STRING_CREATE  (@pattern varchar(8000),     
                                @parts   varchar(8000),    
                                @delimiter char(1),     
                                @trimSlices bit)           
returns                         varchar(8000)    
    
/***************************************************************************    
 * STRING_CREATE */    
/**    
 * Creates a string by replacing placeholders {n} in pattern with coresponding    
 * substrings stored as a delimited string in parts where {n} is the ordinal    
 * position of the part.  Placeholders start at {1}.    
 *    
 * @param  pattern         Pattern to use    
 * @param  parts           Delimited string of parts used to replace placeholders    
 *                         {n} in pattern    
 * @param  delimiter       Character that parts uses for its delimiter    
 * @param  trimSlices      true  = Remove leading and trailing whitespace from each    
 *                                 part    
 *                         false = Preserve leading and trailing whitspace in parts    
 * @return                 New string or null if there was a problem    
 ***************************************************************************/            
     
as           
begin    
    
/*-------------------------------    
 * If the pattern is null get out    
 *------------------------------*/    
    
if @pattern is null return null    
    
declare @tblParms        table(id int, part varchar(255))    
declare @outputString as varchar(8000)    
declare @part         as varchar(255)    
declare @partid       as int    
declare @numParts     as int    
declare @partCount    as int    
declare @placehold    as varchar(50)    
    
declare @temp  as varchar(8000)    
declare @ltemp as varchar(8000)    
declare @rtemp as varchar(8000)    
declare @startIdx as int    
declare @endIdx as int    
declare @safetyCtr as int    
    
/*-------------------------------    
 * Copy the pattern    
 *------------------------------*/    
     
set @outputString = @pattern    
    
/*-------------------------------    
 * Split the parts    
 *
 * TODO: Delimeter and trim flag
 * are NOT being passed, fix this.
 *------------------------------*/    

set @numParts = 0
    
insert into @tblParms    
select * from dbo.STRING_SPLIT(@parts,@delimiter,@trimSlices)    
select @numParts = count(*) from @tblParms as t1
    
/*-------------------------------    
 * If we have parts    
 *------------------------------*/    
     
if (@numParts > 0)    
begin    
      
  set @partCount = 1    
        
  while (@partCount <= @numParts)    
  begin    
        
    /*-------------------------------    
     * For each part n, replace the    
     * corepsonding place holder    
     * {n} in our output string    
     *------------------------------*/    
    
    select top 1     
      @partid = id,     
      @part   = part     
    from @tblParms where id = @partCount    
            
    /*-------------------------------    
     * If the part contains placeholder    
     * characters, this is a syntax error    
     * return null    
     *------------------------------*/    
    
    if (charindex('{',@part,0) > 0) set @outputString = null    
    if (charindex('}',@part,0) > 0) set @outputString = null    
    if @outputString = null return null    
        
    /*-------------------------------    
     * If we are out of parts, exit    
     *------------------------------*/    
         
    if @partid is null break    
        
    set @placehold = '{' + convert(varchar(10),@partid) + '}'    
    set @outputString = replace(@outputString,@placehold,@part)    
    set @partCount = @partCount + 1    
  end    
end    
    
/*-------------------------------    
 * Remove any remaining    
 * placeholders    
 *------------------------------*/    
    
set @safetyCtr = 0    
    
while (@safetyCtr < 100)    
begin    
  set @safetyCtr = @safetyCtr + 1    
  if (@safetyCtr >= 100) break    
  set @startIdx = charindex('{',@outputString,0)    
  if (@startIdx = 0) break;    
  set @startIdx = @startIdx -1      
  set @endIdx   = charindex('}',@outputString,0)    
  if (@endIdx = 0) break    
  set @endIdx   = len(@outputString) - @endIdx    
  set @ltemp = rtrim(left(@outputString,@startIdx))    
  set @rtemp = ltrim(right(@outputString,@endIdx))    
  set @temp  =  @ltemp + ' ' + @rtemp    
  set @outputString  = @temp    
end    
    
/*-------------------------------    
 * If there were any incomplete    
 * placeholders (syntax error)    
 * return null    
 *------------------------------*/    
    
if (charindex('{',@outputString,0) > 0) set @outputString = null    
if (charindex('}',@outputString,0) > 0) set @outputString = null    
    
return @outputString    
          
end    
    
GO
