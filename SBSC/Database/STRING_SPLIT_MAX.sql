USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.STRING_SPLIT_MAX') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.STRING_SPLIT_MAX
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[STRING_SPLIT_MAX] (
    @string    varchar(max)
  , @delimiter char(1)  
)
returns 
table
as           
return
(

/* Code based on post from Aaron Bertrand here : https://stackoverflow.com/a/70862904 */
/* Also see his article here : https://sqlperformance.com/2021/09/t-sql-queries/split-strings */

SELECT 
    part     = Item 
  , position = ROW_NUMBER() OVER (ORDER BY Number)
FROM (
  SELECT 
      Number
    , Item = SUBSTRING(@string, Number, CHARINDEX(@delimiter, @string + @delimiter, Number) - Number)
    FROM (
	  /* Generate numbers table */
      select 
	    gnt.num 
	  from dbo.GENERATE_NUMBERS_TABLE(len(@string)) as gnt
	 ) AS n (Number)
     WHERE 
		(Number <= CONVERT(INT, LEN(@string)))
      AND (SUBSTRING(@delimiter + @string, Number, LEN(@delimiter)) = @delimiter)
) AS y
)
        
GO
