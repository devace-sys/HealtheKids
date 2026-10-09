USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.STRING_WRAP') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.STRING_WRAP
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE  FUNCTION [dbo].STRING_WRAP (

    @TxtN2Wrap nvarchar(4000) -- Input text to be wrapped
  , @nMaxLineLen int -- # Characters allowed on a line.
  , @Separators nvarchar(255) = ' ' -- List of characters 
                                    -- that separate words @TxtN2Wrap.  Space is 
                                    -- assumed to be a separator, even if it's not
                                    -- included in this parameter.
  , @LineTerminator nvarchar(255) -- Char used to start a
                                  -- new line.  If NULL, NCHAR(10) is used.
)
     
RETURNS nvarchar(4000) -- The result string wrapped.

/*
****************************************************************/

AS 
BEGIN

  /***************************************************************************    
   * STRING_WRAP */    
  /**    
   * This is a renamed version of Andrew Novick's udf_TxtN_Wrap
   *
   * Courtesy of: 
   *
   * http://searchwindevelopment.techtarget.com/tip/Word-wrapping-with-T-SQL
   *   
   * Original comments slightly modified below:
   *
   * This function word wraps a nvarchar string at a given length. There can
   * be several word separating characters. Space is always added as a separator.
   *
   * Attribution: Loosely based on a wrapping function in VBScript from ASP101.com
   *
   * Common Usage:
   *
   * select dbo.STRING_WRAP (REPLICATE ('12345 ', 200) , 58, N' ', NULL) as [Wrapped Text]
   * select dbo.STRING_WRAP ('123457890', 4, N' ', NULL) as [Wrapped at 4 with Word longer than line]
   *
   * © Copyright 2002 Andrew Novick http://www.NovickSoftware.com
   * You may use this function in any of your SQL Server databases
   * including databases that you sell, so long as they contain 
   * other unrelated database objects. You may not publish this 
   * UDF either in print or electronically.
   *
   * @param  TxtN2Wrap       String to wrap
   * @param  nMaxLineLen     # Characters allowed on a line.
   * @param  Separators      List of characters that separate words in @TxtN2Wrap.
   *                         Space is assumed to be a separator, even if it's not
   *                         included in this parameter.
   * @param  LineTerminator  Char used to start a new line.  If NULL, NCHAR(10) is used.
   * 
   * @return                 nvarchar
   ***************************************************************************/  

     DECLARE @sOutput             nvarchar(4000) -- working var for the result
     DECLARE @nInputLen           int            -- Length of input
     DECLARE @nCurPos             int            -- Current Position
     DECLARE @nCurLineStart       int            -- current line starts
     DECLARE @nPosOfLastSeparator int            -- Last Separator seen

     -- Save the length of the input

     SET @nInputLen = Len(@TxtN2Wrap)

     -- Start both character pointers at the beginning
     
     SELECT @nCurPos             = 1
          , @nCurLineStart       = 1
          , @nPosOfLastSeparator = 0  

     SELECT @sOutput             = '' -- empty string, not null

     -- Check the parameters form some of our requirements
     
     IF @LineTerminator is NULL SET @LineTerminator = NCHAR(10)
     
     -- Cannot use this expression as a Default

     IF CHARINDEX (N' ', @Separators) = 0  -- Space is 
         SET @Separators = N' ' + @Separators -- Required

     -- Loop through all characters of the input
     
     WHILE @nCurPos < @nInputLen BEGIN
 
       -- Make note of the last separator for use later.
     
        If CHARINDEX(SUBSTRING(@TxtN2Wrap, @nCurPos, 1)
                                , @Separators, 1) > 0 BEGIN
             SET @nPosOfLastSeparator = @nCurPos
        End -- If

        -- Once we have enough for a line, go back to
        -- the last separator we saw and end the line there.
        
        IF @nCurPos >= @nCurLineStart + @nMaxLineLen - 1 BEGIN

            if @nPosOfLastSeparator = 0 BEGIN
            
               -- Cases where a word is longer than the line length

               -- Append the new to the result
            
               Set @sOutput = @sOutput 
                        + SUBSTRING(@TxtN2Wrap, @nCurLineStart, @nMaxLineLen)
                        + @LineTerminator
                SET @nCurLineStart = @nCurLineStart + @nMaxLineLen
                
               END
            
            ELSE BEGIN
            
                -- Append this new line to the result
            
                SET @sOutput = @sOutput 
                        + RTRIM(LTRIM(
                               SUBSTRING(@TxtN2Wrap
                                     , @nCurLineStart
                                     , @nPosOfLastSeparator 
                                       - @nCurLineStart + 1)
                           ))
                        + @LineTerminator

                -- Reset the next line's starting point to the
                -- point used for the last one's end + 1.
                
                SELECT @nCurLineStart = @nPosOfLastSeparator + 1
                     , @nPosOfLastSeparator = 0 -- Don't have one now.
                
            END 
            
            -- Remove any leading separators from the new line.
            
            While CHARINDEX(SUBSTRING(@TxtN2Wrap
                                       , @nCurLineStart, 1)
                             , @Separators, 1) > 0 BEGIN 
               SELECT @nCurLineStart = @nCurLineStart + 1
                    , @nCurPos = @nCurLineStart + 1 
            END -- While
        END -- IF

        -- Increment our current position.
        
        SET @nCurPos = @nCurPos + 1
     END -- While

     -- If the loop ends before we add all the text, add it now.
     
     SET @sOutput = @sOutput + RTRIM(LTrim(SUBSTRING(@TxtN2Wrap
                                            , @nCurLineStart
                                            , @nInputLen 
                                             - @nCurLineStart+1)
                                      ))

     RETURN @sOutput
END
GO