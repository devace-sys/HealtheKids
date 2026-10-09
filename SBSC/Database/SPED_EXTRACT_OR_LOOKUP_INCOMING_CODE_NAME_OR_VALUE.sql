use SPEDMON
go

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SPED_EXTRACT_OR_LOOKUP_INCOMING_CODE_NAME_OR_VALUE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SPED_EXTRACT_OR_LOOKUP_INCOMING_CODE_NAME_OR_VALUE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION dbo.SPED_EXTRACT_OR_LOOKUP_INCOMING_CODE_NAME_OR_VALUE (
    @strValueIn         varchar(256)
  , @useWhichSpEdCodeSet int
)

RETURNS int

AS
BEGIN


declare @strValueOut                as varchar(256) = ''
declare @codeValueOut                as int = -1 /* -1 is not found */

declare @valueStartsWith2DigitCode   as bit = 0
declare @valueStartsWith3DigitCode   as bit = 0
declare @valueStartsWithText         as bit = 0
declare @valueIsCodeOnly             as bit = 0
declare @len                         as int = 0

set @codeValueOut = -1
set @strValueIn      = trim(isnull(@strValueIn,''))
set @len          = len(@strValueIn)

if (@len < 1)
begin
  set @codeValueOut = -1

  return @codeValueOut
end

set @valueIsCodeOnly = iif((ISNUMERIC(@strValueIn)=1),1,0)

/* @strValueIn contains just a numeric code so we can convert and exit. */

if (@valueIsCodeOnly = 1)
begin
  set @codeValueOut = convert(int,@strValueIn)

  return @codeValueOut
end

/* If we reach this point @strValueIn contains alpha numeric text
 * so we need to do some more work to determine what to do
 */

/* First test to see if @strValueIn starts with either a 2 or 3 digit number followed by a space or dash */

set @valueStartsWith3DigitCode  = iif( (PATINDEX('[0-9][0-9][0-9][ -]%', @strValueIn) = 1),1,0)
set @valueStartsWith2DigitCode  = iif((@valueStartsWith3DigitCode = 0),(iif( (PATINDEX('[0-9][0-9][ -]%', @strValueIn) = 1),1,0)),0)

/* If @strValueIn is the 2 digit variant */

if (@valueStartsWith2DigitCode = 1)
begin
  set @strValueOut = SUBSTRING(@strValueIn,1,2)                                     /* Extract the first 2 characters */
  if (ISNUMERIC(@strValueOut)=1) set @codeValueOut = convert(int,@strValueOut)  /* If what was extracted was actually a number then convert*/

  return @codeValueOut
end

/* If @strValueIn is the 3 digit variant */

if (@valueStartsWith3DigitCode = 1)
begin
  set @strValueOut = SUBSTRING(@strValueIn,1,3)                                      /* Extract the first 3 characters */
  if (ISNUMERIC(@strValueOut)=1)  set @codeValueOut = convert(int,@strValueOut)  /* If what we extacted is actually a number then convert */

  return @codeValueOut
end


/* Otherwise @value in has to be text only, so we have to lookup the code that this text coresponds to
 * based on @useWhichSpEdCodeSet is specified.
 */

/* SpEd Service */

if (@useWhichSpEdCodeSet = 1)
begin

  /* Try matching on name */
  select top 1 @codeValueOut = t1.codeValue from dbo.SpEd_Service as t1 where (t1.[name] = @strValueIn)

  if (@codeValueOut > 0)
    return @codeValueOut
  /* If that does not work then let's try something else */

  select top 1 @codeValueOut = t1.codeValue
  from dbo.SpEd_Service as t1
  CROSS APPLY (
    SELECT value commonAlias
      FROM OPENJSON(t1.additionalDataJSON, '$.commonAliases')
  ) ca1
  where (ca1.[commonAlias] = @strValueIn)

  if (@codeValueOut > 0)
    return @codeValueOut

end

/* SpEd Service Frequency */

else if (@useWhichSpEdCodeSet = 2)
begin

  /* Try matching on name first*/

  select top 1 @codeValueOut = t1.codeValue from dbo.SpEd_Service_Frequency as t1 where (t1.[name] = @strValueIn)

  if (@codeValueOut > 0)
    return @codeValueOut

  select top 1 @codeValueOut = t1.codeValue
  from dbo.SpEd_Service_Frequency as t1
  CROSS APPLY (
    SELECT value commonAlias
      FROM OPENJSON(t1.additionalDataJSON, '$.commonAliases')
  ) ca1
  where (ca1.[commonAlias] = @strValueIn)

  if (@codeValueOut > 0)
    return @codeValueOut

  /* If that does not find it then try definition */
  select top 1 @codeValueOut = t1.codeValue from dbo.SpEd_Service_Frequency as t1 where (t1.[definition] = @strValueIn)

  if (@codeValueOut > 0)
    return @codeValueOut
end

/* SpEd Service Location */

else if (@useWhichSpEdCodeSet = 3)
begin
  /* Try matching on name */
  select top 1 @codeValueOut = t1.codeValue from dbo.SpEd_Service_Location as t1 where (t1.[name] = @strValueIn)

  if (@codeValueOut > 0)
    return @codeValueOut
  /* If that does not work then let's try something else */

  select top 1 @codeValueOut = t1.codeValue
  from dbo.SpEd_Service_Location as t1
  CROSS APPLY (
    SELECT value commonAlias
      FROM OPENJSON(t1.additionalDataJSON, '$.commonAliases')
  ) ca1
  where (ca1.[commonAlias] = @strValueIn)

  if (@codeValueOut > 0)
    return @codeValueOut

  --  if non-abbreviated, look for a perfect substring match up to the first parenthesis character
  --  example: 'private residential school' should match 'Private residential school (not certified by Special Education Division) '
  select top 1 @codeValueOut = t1.codeValue
  from dbo.SpEd_Service_Location as t1
    where  LEN(@strValueIn) > 5
           AND (
             -- perfect substring match
             @strValueIn =
             IIF(
               CHARINDEX('(', t1.[name] ) > 0
               ,
               LEFT(
               t1.[name],
               CHARINDEX('(', t1.[name] ) - 1
               )
               ,
               t1.[name]
            )
          )

  if (@codeValueOut > 0)
    return @codeValueOut

end

/* SpEd Service Provider */

else if (@useWhichSpEdCodeSet = 4)
begin
  /* Try matching on name */
  select top 1 @codeValueOut = t1.codeValue from dbo.SpEd_Service_Provider as t1 where (t1.[name] = @strValueIn)

  if (@codeValueOut > 0)
    return @codeValueOut

  select top 1 @codeValueOut = t1.codeValue
  from dbo.SpEd_Service_Provider as t1
  CROSS APPLY (
    SELECT value commonAlias
      FROM OPENJSON(t1.additionalDataJSON, '$.commonAliases')
  ) ca1
  where (ca1.[commonAlias] = @strValueIn)

  if (@codeValueOut > 0)
    return @codeValueOut
  /* If that does not work then let's try something else */

  -- search for the parenthetic substrings in the "name" field of dbo.SpEd_Service_Provider.
  -- example: California Department of Social Services (DSS)
  select top 1 @codeValueOut = t1.codeValue
  from dbo.SpEd_Service_Provider as t1
    where  CHARINDEX(
             '(' + @strValueIn + ')'
             ,
             t1.[name]
           ) > 0

  if (@codeValueOut > 0)
    return @codeValueOut

  --  if non-abbreviated, look for a perfect substring match up to the first parenthesis character
  --  example: 'Nonpublic agency' should match 'Nonpublic agency (NPA) under contract with SELPA or district'
  select top 1 @codeValueOut = t1.codeValue
  from dbo.SpEd_Service_Provider as t1
    where  LEN(@strValueIn) > 5
           AND (
             -- perfect substring match
             @strValueIn =
             IIF(
               CHARINDEX('(', t1.[name] ) > 0
               ,
               LEFT(
                 t1.[name],
                 CHARINDEX('(', t1.[name] ) - 1
               )
               ,
               t1.[name]
            )
          )

  if (@codeValueOut > 0)
    return @codeValueOut

end

/* SpEd Disability Codes */

else if (@useWhichSpEdCodeSet = 5)
begin
  /* Try matching on name */
  select top 1 @codeValueOut = t1.codeValue from dbo.SpEd_Disability_Codes as t1 where (t1.[name] = @strValueIn)

  if (@codeValueOut > 0)
    return @codeValueOut

  /* If that does not work then let's try something else */

  select top 1 @codeValueOut = t1.codeValue
  from dbo.SpEd_Disability_Codes as t1
  CROSS APPLY (
    SELECT value commonAlias
      FROM OPENJSON(t1.additionalDataJSON, '$.commonAliases')
  ) ca1
  where (ca1.[commonAlias] = @strValueIn)

  if (@codeValueOut > 0)
    return @codeValueOut

  -- search for the parenthetic substrings in the "name" field of SpEd_Disability_Codes.
  -- example: Deafness (DEAF)/Hearing impairment (HI)
  select top 1 @codeValueOut = t1.codeValue
  from dbo.SpEd_Disability_Codes as t1
    where  CHARINDEX(
             '(' + @strValueIn + ')'
             ,
             t1.[name]
           ) > 0

  if (@codeValueOut > 0)
    return @codeValueOut
/*
  -- if non-abbreviated, look for a perfect substring match
  -- example: 'brain injury' should match 'Traumatic brain injury (TBI)'
  select top 1 @codeValueOut = t1.codeValue
  from dbo.SpEd_Disability_Codes as t1
    where  LEN(@strValueIn) > 5
           AND
           CHARINDEX(
             @strValueIn
             ,
             t1.[name]
           ) > 0

  if (@codeValueOut > 0)
    return @codeValueOut
*/

  --  if non-abbreviated, look for a perfect substring match up to the first parenthesis character
  --  example: 'multiple disabilities' should match 'Multiple disabilities (MD)'
  --      ex2: 'deafness' should match 'Deafness (DEAF)/Hearing impairment (HI)'
  select top 1 @codeValueOut = t1.codeValue
  from dbo.SpEd_Disability_Codes as t1
    where  LEN(@strValueIn) > 5
           AND (
             -- perfect substring match
             @strValueIn =
             IIF(
               CHARINDEX('(', t1.[name] ) > 0
               ,
               LEFT(
                 t1.[name],
                 CHARINDEX('(', t1.[name] ) - 1
               )
               ,
               t1.[name]
             )
          )

  if (@codeValueOut > 0)
    return @codeValueOut

end

/* Note: Add additional code set logic here as needed*/

/* Code set not supported */
else
begin
  set @codeValueOut = -1
end

/* If we reach this point we searched through the various code sets (or not if not supported) and either found a code value
 * or not.  Return the code value we found (-1 means we did not find it)
 */

return @codeValueOut

END
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[SPED_EXTRACT_OR_LOOKUP_INCOMING_CODE_NAME_OR_VALUE] TO [webuser]
GO

   -- ??
GRANT EXECUTE ON  [dbo].[Patient_Data_Imports_Match_Generate_Stats_And_Exceptions_Rpt_Html] TO [webuser]
GO

  -- I don't know why this is here
