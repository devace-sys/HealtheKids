USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CALC_HUMAN_BYTE_SIZE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CALC_HUMAN_BYTE_SIZE
GO
/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CALC_HUMAN_BYTE_SIZE] (
    @sizeInBytes bigint
  , @siUnits     bit
) 

RETURNS VARCHAR (100)
WITH SCHEMABINDING
AS     
BEGIN    
    
declare @sizeInBytesF  as float        /* Size in bytes in as a float*/
declare @kbF           as float        /* Number of bytes in a kilobyte as a float*/
declare @unitScale     as varchar(8)   /* Lookup string for unit scale */
declare @unit          as varchar(1)   /* Unit from unit scale */
declare @bUnit         as varchar(2)   /* Either iB or B */
declare @e             as int          /* Calc scale index, (1-8 or higher) */
declare @sizeApprox    as float        /* Calc Approximate size with respect to scale */
declare @humanSize     as varchar (10) /* Calc Human friendly size */

/* Nothing passed in, get out */

if (@sizeInBytes is null) return null

/* Default if siUnits not specified */

if (@siUnits is null)  set @siUnits = 1

/* Using SI Units */

if (@siUnits = 1) 
begin
  set @kbF   = 1000
  set @bUnit = 'B'
end

/* Using IEC Units */

else
begin
  set @kbF   = 1024
  set @bUnit = 'iB'
end


set @sizeInBytesF = convert (float, @sizeInBytes)              /* Get approx size in bytes */
set @e            = floor ( log (@sizeInBytesF) / log (@kbF) ) /* Determine index of unit scale */

/* If index is larger than function can handle, get out */

if (@e > 8) return null

/* Setup unit scale lookup string */

set @unitScale = 'KMGTPEZY'

set @unit         = substring ( @unitScale, @e, 1)               /* Lookup unit scale */
set @sizeApprox   = round (@sizeInBytesF / power (@kbF ,@e), 1)  /* Compute approx size in terms of units scale */
set @humanSize  = convert(varchar(10), ceiling(@sizeApprox))               /* Convert approx size to string */

/* Return string */

return @humanSize + ' ' + @unit + @bUnit
   
    
END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[CALC_HUMAN_BYTE_SIZE] TO [webuser]
GO