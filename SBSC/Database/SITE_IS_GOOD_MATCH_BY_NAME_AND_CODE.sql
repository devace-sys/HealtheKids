use spedmon
go

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 

--DROP PROCEDURE if exists dbo.SITE_IS_GOOD_MATCH_BY_NAME_AND_CODE
--GO

DROP FUNCTION if exists dbo.SITE_IS_GOOD_MATCH_BY_NAME_AND_CODE
GO

-- this could have been a function,
-- but it returns an output param (as well as a return value), so it was made a SPROC.
-- Perhaps it could/should be refactored eventually as a UDF that returns a JSON string.

CREATE FUNCTION [dbo].[SITE_IS_GOOD_MATCH_BY_NAME_AND_CODE] (
  @possibleMatchSiteID         bigint ,
  @incomingSiteName  nvarchar(100)  ,
  @incomingCDS7          nchar(7)   --,

)
returns varchar(max)

  -- example: [{"matchQuality":1,"levenstein":2}]

  -- returns matchQuality 2 if perfect string or substring match (case insensitive, ignoring whitespace)
  -- returns matchQuality 1 if a mostly good match
  -- returns matchQuality 0 if bad/no match

  -- NOTE:
  -- modified to support blank/null @incomingCDS7 ;
  -- the function would then fuzzy-match on SiteName only.

as begin

declare @results_1row table ( matchQuality int not null, levenstein int null)
declare @retJson            varchar(max)
declare @levenstein         int
declare @existingSiteCDS    nchar(7)
declare @existingSiteName   nvarchar(100)

select 
  @existingSiteCDS   = [SITE_CDS]  ,
  @existingSiteName  = [SITE_NAME]

FROM  [dbo].[SITES_Site]
WHERE SITE_ID = @possibleMatchSiteID

-- GETOUT immediately when CDS7 codes mismatch
if ( TRIM( ISNULL(@incomingCDS7, '')) != '' )
  if (  UPPER( @existingSiteCDS )  !=  UPPER( @incomingCDS7 ) )
  BEGIN
    INSERT INTO
    @results_1row (matchQuality)
    select  0

    SET @retJson = 
      CAST( 
        ( select matchQuality FROM @results_1row FOR JSON auto )
          as varchar(max))

    RETURN @retJson

  END

declare  @incomingSiteName_upper_nopunc_nospace  nvarchar(100) ,
         @existingSiteName_upper_nopunc_nospace  nvarchar(100)

declare  @longer_str_upper_nopunc_nospace  nvarchar(100) ,
         @shorter_str_upper_nopunc_nospace  nvarchar(100)

SET @incomingSiteName_upper_nopunc_nospace  =  UPPER(
     [dbo].[FMT_STRING_STRIP_PUNCTUATION_ALPHANUMERIC_ONLY](
     @incomingSiteName , 0)
   )

SET @existingSiteName_upper_nopunc_nospace  =  UPPER(
     [dbo].[FMT_STRING_STRIP_PUNCTUATION_ALPHANUMERIC_ONLY](
     @existingSiteName , 0)
   )

IF ( LEN(@incomingSiteName_upper_nopunc_nospace) > LEN(@existingSiteName_upper_nopunc_nospace) )
BEGIN
   SET  @longer_str_upper_nopunc_nospace   = @incomingSiteName_upper_nopunc_nospace ;
   SET  @shorter_str_upper_nopunc_nospace  = @existingSiteName_upper_nopunc_nospace
END
ELSE
BEGIN
   SET  @shorter_str_upper_nopunc_nospace   = @incomingSiteName_upper_nopunc_nospace ;
   SET  @longer_str_upper_nopunc_nospace    = @existingSiteName_upper_nopunc_nospace
END

IF (
  CHARINDEX( @shorter_str_upper_nopunc_nospace , @longer_str_upper_nopunc_nospace)
  > 0 )
  BEGIN
    INSERT INTO
    @results_1row (matchQuality)
    select  2 

    SET @retJson = 
      CAST( 
        ( select matchQuality FROM @results_1row FOR JSON auto )
          as varchar(max))

    RETURN @retJson

  END


--declare @levenstein int

SELECT

  @levenstein  =  [dbo].[Levenshtein](
                    @incomingSiteName_upper_nopunc_nospace
                  , @existingSiteName_upper_nopunc_nospace
                  , 1000
                  )

IF ( @levenstein <
     ( LEN( @longer_str_upper_nopunc_nospace ) - LEN( @shorter_str_upper_nopunc_nospace ) + 3
     )
   )
  BEGIN
    INSERT INTO
    @results_1row 
    select  1, @levenstein

    SET @retJson = 
      CAST( 
        ( select matchQuality, levenstein FROM @results_1row FOR JSON auto )
          as varchar(max))

    RETURN @retJson

  END

--else

INSERT INTO
@results_1row (matchQuality)
select  0

SET @retJson = 
  CAST( 
    ( select matchQuality FROM @results_1row FOR JSON auto )
      as varchar(max))

RETURN @retJson

END    

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[SITE_IS_GOOD_MATCH_BY_NAME_AND_CODE] TO [webuser]
GO