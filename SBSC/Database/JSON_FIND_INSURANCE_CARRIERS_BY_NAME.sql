USE spedmon
GO

DROP FUNCTION if exists dbo.JSON_FIND_INSURANCE_CARRIERS_BY_NAME
GO


/***************************************************************************    
 * JSON_FIND_INSURANCE_CARRIERS_BY_NAME */    
/**    
 * Finds all relevant insurer carriers for a given input string, using
 * whitespace-stripped concat-substrings and space-separated multi-substrings
 * logic
 
 * @param   incomingInsurerNameOrCode   String; name or code of insurer to find
 * @param   active                      Bit flag; filter carriers by active flag
 *                                      or NULL for all active and inactive
 * @param   carrierStateUS              String; two-letter code for US state,
                                        or NULL
 * @returns varchar(max)                JSON blob
 ***************************************************************************/  

CREATE FUNCTION dbo.JSON_FIND_INSURANCE_CARRIERS_BY_NAME  (
  @incomingInsurerNameOrCode     as varchar(100) ,
  @active                  bit ,  -- active flag filter for insurance carriers
  @carrierStateUS          char(3)
)
RETURNS varchar(max)
AS begin

  declare @doneSearching    bit     = 0

  -- will rename this local var
  declare @retvals          varchar(100)  = null

  declare @carrierIDs  table ( valu bigint )

  declare @retJSON  varchar(max)

  -- pass 0: find by carrierCode

  SELECT  top 1
    @retvals = id
      -- implicit conversion works, yo.

  FROM INSURANCE_CARRIERS  ins
  WHERE
    [carrierCode] = @incomingInsurerNameOrCode
    AND
    ( @active  IS NULL  OR  ins.active = @active )
    AND
    ( ISNULL( @carrierStateUS, '') = ''  OR  @carrierStateUS = ins.usState )

  IF ( @retvals IS NOT NULL )
  BEGIN
   SET @doneSearching = 1
  END

  ELSE
  BEGIN

    -- pass 1: attempt match by, basically, substring at position 1, with no whitespace
  
    declare @incomingInsurerNameAlphaStr as varchar(100) ,
            @incomingInsurerNameAlphaStrLen as int ;

    SELECT @incomingInsurerNameAlphaStr = 
      dbo.FMT_STRING_STRIP_PUNCTUATION_ALPHANUMERIC_ONLY( @incomingInsurerNameOrCode, 1)

    SELECT @incomingInsurerNameAlphaStrLen = LEN ( @incomingInsurerNameAlphaStr )

    -- find a simple string match against the table; no dup checking

    SELECT  top 1  @retvals = id
    FROM INSURANCE_CARRIERS  ins
    WHERE
      [alphaNameString] = @incomingInsurerNameAlphaStr
      AND
      ( @active  IS NULL  OR  ins.active = @active )
      AND
      ( ISNULL( @carrierStateUS, '') = ''  OR  @carrierStateUS = ins.usState )

      IF ( @retvals IS NOT NULL )
      BEGIN
        -- perfect match; no need to continue to look for weaker matches
        SET @doneSearching = 1
      END

    declare @numFoundThisSubstring int = 0
    -- find substring match at position 1; with dup checking

    ;with alphaNameSubstringsPerIns as (
      SELECT
        id,
        SUBSTRING( [alphaNameString], 1, @incomingInsurerNameAlphaStrLen ) substr
      FROM INSURANCE_CARRIERS  ins
    WHERE
      ( @active  IS NULL  OR  ins.active = @active )
      AND
      ( ISNULL( @carrierStateUS, '') = ''  OR  @carrierStateUS = ins.usState )
    ) ,
    groupd_and_counted as (
      SELECT
        COUNT(*) [count],
        substr 
      FROM alphaNameSubstringsPerIns

      WHERE substr = @incomingInsurerNameAlphaStr

      GROUP BY substr
      -- HAVING COUNT(*) = 1
    )

    select @numFoundThisSubstring = [count]
    FROM  groupd_and_counted

    IF ( @numFoundThisSubstring > 0 )
    BEGIN
 
      SELECT @retvals = 
        STRING_AGG( CAST( id AS VARCHAR(max) ) , ',' )

      FROM INSURANCE_CARRIERS  ins
      WHERE

        SUBSTRING( [alphaNameString], 1, @incomingInsurerNameAlphaStrLen )
           = @incomingInsurerNameAlphaStr

        AND
        ( @active  IS NULL  OR  ins.active = @active )
        AND
        ( ISNULL( @carrierStateUS, '') = ''  OR  @carrierStateUS = ins.usState )

      IF ( @numFoundThisSubstring = 1 )
        SET @doneSearching = 1
        -- only 1 perfect substring match; no need to continue searching for weaker matches
    END

    IF ( @doneSearching = 0 )
    BEGIN

      -- pass 2: attempt match by substring tokens

      -- There may or may not already be IDs in the @retvals string.
      -- Populate the table var, and empty the string.

      --if ( ISNUMERIC( @retvals ) = 1)
      --  INSERT INTO @carrierIDs select @retvals
      --else -- comma-delimited

      IF ( LEN( @retvals ) > 0 )
      BEGIN
        INSERT INTO @carrierIDs SELECT value from STRING_SPLIT( @retvals, ',' )
      END

      SET @retvals = null

      declare @strTokens table ( idx int identity (1,1), incomingToken varchar(20) );

      declare @allItemsFoundByAllTokens table (
        --idxIncoming int,
        weightIndicated int,  -- a simple weighting, using string LEN().
                              -- we care more about matching proper nouns and adjectives rather than simple
                              -- grammatical markers like a, of, the, at, in, and
        foundCarrierID bigint
      );

      declare @weightSumsPerFound table (
        --idxIncoming int,
        weightIndicatedSum int,
        foundCarrierID bigint
      );

      declare @highest_matchscore int = null

      INSERT INTO @strTokens
      SELECT * FROM STRING_SPLIT( @incomingInsurerNameOrCode, ' ' )

      INSERT INTO @allItemsFoundByAllTokens

      SELECT
        --in_1.idx , -- we don't actually using this in the final result, but its a unique identifier, usable for debugging
        LEN( ex_.tokenStr ) ,
        ex_.carrierID
      FROM  
        @strTokens  in_1

        JOIN
        dbo.INSURANCE_CARRIER_NAME_TOKENS ex_
        ON in_1.incomingToken  = ex_.tokenStr

        LEFT JOIN
          dbo.INSURANCE_CARRIERS  ins
        ON ( @active IS NOT NULL
             AND
             ins.id = ex_.carrierID
           )
        WHERE
        ( @active IS NULL OR @active = ins.active )
        AND
        ( ISNULL( @carrierStateUS, '') = ''  OR  @carrierStateUS = ins.usState )

  
      -- FAILURE CONDITION: none found, return null

      -- if ( ( select count(*) from @allItemsFoundByAllTokens ) = 0 )
      --  return NULL

      -- find the heighest weighted result

      INSERT INTO @weightSumsPerFound
      SELECT
          SUM( weightIndicated ),
          foundCarrierID
        FROM  @allItemsFoundByAllTokens
        GROUP BY foundCarrierID

      -- determine what the max score is, and retrieve the value

  
      SELECT
          @highest_matchscore = MAX( weightIndicatedSum )
        FROM  @weightSumsPerFound


     -- IF (
     --  ( select COUNT(*) FROM @weightSumsPerFound WHERE weightIndicatedSum = @highest_matchscore )
     --   != 1 )
     --   return null
  
      SELECT -- top 1
        @retvals = STRING_AGG( foundCarrierID, ',' )
      FROM @weightSumsPerFound
      WHERE weightIndicatedSum = @highest_matchscore

    END
  END

  -- There may or may not already be IDs in the @retvals string.
  -- Populate the table var, and empty the string.'
  -- TODO: this is copy-paste from above.  Will de-spaghettify, later

  IF ( LEN( @retvals ) > 0 )
  BEGIN
    INSERT INTO @carrierIDs SELECT value from STRING_SPLIT( @retvals, ',' )
  END

  ; with distinct_matchd as (
    SELECT DISTINCT *
    FROM @carrierIDs
  ) ,
  q_ins as (
  SELECT
    ins.*
  FROM
  dbo.INSURANCE_CARRIERS ins
  JOIN  distinct_matchd dmat
    ON ins.id = dmat.valu
  )
  SELECT @retJSON=allresults FROM (

  SELECT * FROM q_ins

  FOR JSON auto) s1 (allresults)  


  return  @retJSON

END

GO