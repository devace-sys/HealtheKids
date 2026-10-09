USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RPT_FRQ_DUR') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RPT_FRQ_DUR
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[RPT_FRQ_DUR]
  (@what   VARCHAR(50),
   @frq    INT,
   @dur    INT,
   @durIn  VARCHAR(50)
)     

RETURNS VARCHAR(255)
AS     
BEGIN    

  DECLARE @tempout as VARCHAR(255)
  declare @tempdur as varchar(100)
  declare @tempfrq as varchar(100)  
  
  set @tempout = ''
  
  if ((@frq is null) and (@dur is null))
  begin
    /*-------------------------------
     * If nothing is passed in then
     * return a blank
     *------------------------------*/  
    return @tempout
  end
  else
  begin
    
    /*-------------------------------
     * Otherwise we are going to 
     * figure out what we can return
     *------------------------------*/  

    if (@frq is null)
    
      /*-------------------------------
       * If the frequency is null then
       * we don't worry about showing it
       *------------------------------*/  
    
      set @tempfrq = ''
    
    else if (@frq = 1)
    
      /*-------------------------------
       * If the frequency is 1
       * we don't worry about showing it
       *------------------------------*/  
    
      set @tempfrq = ''
    
    else
      
      /*-------------------------------
       * If the frequency is anything
       * else we show it
       *------------------------------*/  
      
      set @tempfrq = ' (x ' + CONVERT(varchar(100),@frq) + ')'
        
    if (@dur is null)
    begin 
    
      /*-------------------------------
       * If the duration is null
       * we don't worry about showing it
       * and we can get out        
       *------------------------------*/  
      
      set @tempdur = ''
      return @tempout
    end   
    else
    begin    

      /*-------------------------------
       * Otherwise do something with it
       *------------------------------*/  

      set @tempdur = CONVERT(varchar(100),@dur) + ' ' + @durIn
    end
    
    /*-------------------------------
     * Create our output line
     *------------------------------*/  

    set @tempout = @what + ' ' + @tempdur + @tempfrq + ' ' 

  end
  
  
  RETURN @tempout
  
END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[RPT_FRQ_DUR] TO [webuser]
GO
