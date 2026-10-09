USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.GENERATE_PRODUCT_KEY') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.GENERATE_PRODUCT_KEY
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

  /***************************************************************************    
   * GENERATE_PRODUCT_KEY */    
  /**    
   * Generates key value that a user can enter to provide validity of an action
   *      
   ***************************************************************************/  

CREATE FUNCTION [dbo].[GENERATE_PRODUCT_KEY] (
  @nextSequenceNumber           bigint
, @nameSpace                    varchar(50)
, @numSegs                      tinyint
, @numCharsPerAlphaNumericSeg   tinyint
, @segNumThatGetsSequenceNumber tinyint
, @randomAlphaOnly              bit
)
RETURNS varchar(256)
AS    
BEGIN
  declare @productKey as varchar(256)
  declare @segments as table (
     IDX         tinyint
    ,SEGMENT     varchar(256)
  )
  set @randomAlphaOnly = isnull(@randomAlphaOnly,0)
  set @nameSpace = trim(upper(isnull(@nameSpace,'')))
  set @nameSpace = replace(@nameSpace,'-','')
  set @nameSpace = replace(@nameSpace,' ','')  
  set @nextSequenceNumber   = isnull(@nextSequenceNumber,0)
  if @nextSequenceNumber <= 0 return null  
  set @numSegs = isnull(@numSegs,5)
  if ((@numSegs <= 0) or (@numSegs > 5)) set @numSegs = 5
  
  set @segNumThatGetsSequenceNumber = isnull(@segNumThatGetsSequenceNumber,0)
  
  if ((@segNumThatGetsSequenceNumber <= 0) or (@segNumThatGetsSequenceNumber > @numSegs)) 
  begin
    declare @rnd as tinyint
    select @rnd = (VALUE_TINYINT % @numSegs) from dbo.GENERATE_RANDOM_NUMBERS
    set @segNumThatGetsSequenceNumber = @rnd + 1  	
  end

  set @numCharsPerAlphaNumericSeg = isnull(@numCharsPerAlphaNumericSeg,0)
  if ((@numCharsPerAlphaNumericSeg <=0) or (@numCharsPerAlphaNumericSeg > 5)) set @numCharsPerAlphaNumericSeg = 5

  declare @curSeg as tinyint = 1

  while (@curSeg <= @numSegs)
  begin 
    insert into @segments (IDX,SEGMENT) values (@curSeg,UPPER(dbo.GENERATE_RANDOM_ALPHA_NUMERIC_STRING(@numCharsPerAlphaNumericSeg,@randomAlphaOnly)))
    set @curSeg = @curSeg + 1
  end

  update @segments set SEGMENT = convert(varchar(206),@nextSequenceNumber) where IDX = @segNumThatGetsSequenceNumber

  set @curSeg = 1
  set @productKey = @nameSpace
  declare @segment as varchar(256) = ''
  
  while (@curSeg <= @numSegs)
  begin     
	select top 1 @segment = SEGMENT from @segments where IDX = @curSeg
	set @productKey = @productKey + ' ' + @segment
	set @curSeg = @curSeg + 1
  end
  set @productKey = trim(@productKey)
  set @productKey = REPLACE(@productKey,' ','-')
  
  return @productKey    
END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[GENERATE_PRODUCT_KEY] TO [webuser]
GO
