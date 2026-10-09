use spedmon
go


/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
--DROP PROCEDURE if exists dbo.SITE_ATTEMPT_MATCHES_BY_NAME_AND_CODE
--GO

DROP FUNCTION if exists dbo.SITE_ATTEMPT_MATCHES_BY_NAME_AND_CODE
GO

CREATE FUNCTION [dbo].[SITE_ATTEMPT_MATCHES_BY_NAME_AND_CODE]  (

  @clientID          as bigint           ,
                     -- using @clientID only to call dbo.GET_SITE_INFO_UNKNOWN_SCHOOL if we need it

  @possibleSiteIdsCSV as varchar(max) ,
  @incomingSiteName   as nvarchar(100)    ,
  @incomingCDS7       as nchar(7)   

  -- NOTE:
  -- modified to support blank/null @incomingCDS7 ;
  -- the function would then fuzzy-match on SiteName for the given list of possibleSiteIds
)

RETURNS bigint
as begin
 
declare @selectedSiteID bigint

declare @possibleSiteMatches table (
  idx                    int identity(1,1)  not null  ,
  possibleMatchSiteID    int NOT NULL                 ,
  matchScore             int                          ,
  levenstein             int   
unique clustered (idx)
)

insert into @possibleSiteMatches ( possibleMatchSiteID )
select
  possibleMatchSiteID = convert(int,ss.value)
from STRING_SPLIT(@possibleSiteIdsCSV,',') as ss

declare @iter_i                 int = 1
declare @max_iter_i             int
declare @iter_possible_match_id int

SELECT 
  @max_iter_i = MAX(idx)
  FROM @possibleSiteMatches

declare @match_retval int
declare @levenstein   int

while ( @iter_i <= @max_iter_i )
begin

  select top 1
    @iter_possible_match_id = possibleMatchSiteID
  FROM   @possibleSiteMatches
  WHERE  (idx = @iter_i)

  declare @iter_matchJsonInfo varchar(max) = null

  SET 
    @iter_matchJsonInfo = [dbo].[SITE_IS_GOOD_MATCH_BY_NAME_AND_CODE]
    (
        @iter_possible_match_id  ,
        @incomingSiteName        ,
        @incomingCDS7            )

  --exec @match_retval = [dbo].[SITE_IS_GOOD_MATCH_BY_NAME_AND_CODE]
  SELECT TOP 1
    @match_retval = matchQuality,
    @levenstein   = levenstein
  FROM
  OPENJSON( @iter_matchJsonInfo, '$' )
  WITH (
    "matchQuality"  bigint ,
    "levenstein"    bigint
  )

  -- NOTE: with a UDF we can't do a RAISERROR here; if there is a problem it just does a raiserror from the calling SPROC

  IF ( @match_retval = 2 )
    RETURN  @iter_possible_match_id

    -- @match_retval = 2 means that the CDS code matches and the name string match is considered perfect;
    --                 not perfect character for character,
    --                 but rather that
    --                   upper( no_punc_or_whitespace ( incoming) ) )
    --                 is a substring of
    --                   upper( no_punc_or_whitespace ( existing ) )
    --                 or vise versa, for whichever is longer

  --else
  UPDATE  @possibleSiteMatches
     SET
        matchScore  = @match_retval,
        levenstein  = @levenstein 
     WHERE
     idx = @iter_i

  SET @iter_i += 1

end

-- if there are multiple possible matches with matchScore = 1 (not perfect, but possible)
-- then we need to find the one with the shortest levenshtein distance,
-- between @incomingSiteName_upper_nopunc_nospace and @existingSiteName_upper_nopunc_nospace


-- handle edge case where ALL matches are bad
IF (
  ( SELECT MAX(matchScore) FROM @possibleSiteMatches ) = 0
)
BEGIN
  select top 1
    @selectedSiteID  = t1.SITE_ID
  FROM dbo.GET_SITE_INFO_UNKNOWN_SCHOOL(@clientID) as t1
  RETURN  @selectedSiteID
END
-- this particular edge case hasn't been tested at the level of the calling SPROC;
-- we will have to eventually make sure that "unknown" sites here are reported-out with the other unknowns on the match report.
-- but it works here, at the utility function level

;with min_levenstein as (
  SELECT
    MIN(levenstein) dist
  FROM  @possibleSiteMatches
  WHERE matchScore = 1 -- mostly good match
)
SELECT top 1
   @selectedSiteID = possibleMatchSiteID
   FROM @possibleSiteMatches p_mat
   JOIN min_levenstein ON min_levenstein.dist = p_mat.levenstein
                      AND p_mat.matchScore    = 1

RETURN  @selectedSiteID

END    

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[SITE_ATTEMPT_MATCHES_BY_NAME_AND_CODE] TO [webuser]
GO