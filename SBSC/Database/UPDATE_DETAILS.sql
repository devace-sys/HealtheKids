USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.UPDATE_DETAILS') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.UPDATE_DETAILS
GO
/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[UPDATE_DETAILS](@spdetails VARCHAR(8000), @detail VARCHAR(1000), @state INT) RETURNS VARCHAR(8000) AS     
BEGIN    
  
  /******************************************    
   * Updates pipe delimited list of details    
   *******************************************/    

  declare @howMuchRoomLeft                 as int           = 0
  declare @howBigIsDetailWithStateAndDelim as int           = 0
  declare @tempDetails                     as varchar(8000) = ''    
  declare @tempDetail                      as varchar(1004) = ''
    
  set @spDetails  = trim(isnull(@spDetails,''))
  set @detail     = trim(isnull(@detail,'')) 
  set @tempDetail = '[' + CONVERT(VARCHAR(2),@state) + ']' + @detail    
    
  /* We do not have existing details */
  
  IF (@spdetails = '')
  begin
    /* Go ahead and add the detail*/
    set @tempDetails = @tempDetail + '|'
  end
  
  /* We have existing details*/
  else
  begin    
    
	/* Determine how much room is left and how big the detail is*/

	set @howMuchRoomLeft                  = (8000 - len(@spdetails))
    set @howBigIsDetailWithStateAndDelim  = (len(@detail) + 5)
  
    /* If there is enough room to add the detail do it*/

	if (@howBigIsDetailWithStateAndDelim <= @howMuchRoomLeft)
    begin
	  set @tempDetails = @spdetails + @tempDetail + '|'    
    end
	
	/* Otherwise just return what we have */
	
	else
	begin
	  set @tempDetails = @spdetails
	end

  end

  return @tempDetails   

END    
GO
