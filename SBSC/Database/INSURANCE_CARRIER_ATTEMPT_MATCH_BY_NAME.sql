USE SPEDMON
GO

/* TESTING NOTES:
   Works with the following strings (use @usState = NULL, as Braven is not based in CA)

  'BRAVEN CHOICE'
  'BRAVEN MEDICARE CHOICE'
  'BRAVENMEDICARECHOICE'
  'BRAVENMEDICARECHOI'
  'B102'

  NOTE: For Rialto, this UDF fails to find a perfect match for "Kaiser"
        because Kaiser has multiple entries in our Carriers table; the string
        "Kaiser" isn't specific enough.

        Fails to match to "Inland Empire", as they are not present in our table.
        Where/how did we populate that table from?  I don't remember.

        Matches perfectly, given the input string "Molina Healthcare of California"
        and @usState = 'CA'.

        Matches perfectly, given the input string "HealthNet" and @usState = 'CA'.
*/


DROP FUNCTION if exists dbo.INSURANCE_CARRIER_ATTEMPT_MATCH_BY_NAME
GO



/***************************************************************************    
 * INSURANCE_CARRIER_ATTEMPT_MATCH_BY_NAME */    
/**    
 * Returns the numeric ID of an Insurance Carrier, if exactly one viable match
 * is found; returns -1 if ambiguous, NULL if none found
 
 * @param   incomingInsurerNameOrCode   String; name or code of insurer to find
 * @param   active                      Bit flag; filter carriers by active flag
 *                                      or NULL for all active and inactive
 * @param   carrierStateUS              String; two-letter code for US state,
                                        or NULL
 * @returns bigint                      numeric ID of an Insurance Carrier, if
 *                                      exactly one viable match is found; returns -1
 *                                      if ambiguous, NULL if none found
 ***************************************************************************/  



CREATE FUNCTION dbo.INSURANCE_CARRIER_ATTEMPT_MATCH_BY_NAME  (
  @incomingInsurerNameOrCode     as varchar(100) ,
  @active                  bit ,  -- active flag filter for insurance carriers
  @carrierStateUS          char(3)
)
RETURNS bigint
AS begin

  if (  ISNULL( @incomingInsurerNameOrCode, '') = '' )
    RETURN NULL

  if ( @incomingInsurerNameOrCode = 'N/A'
        OR
       @incomingInsurerNameOrCode = 'NONE'
        OR
       @incomingInsurerNameOrCode = 'OTHER'
  )
    RETURN NULL

  declare @fetchedJSON varchar(max);
  declare @fetchedCount int;

  declare @fetchedID    bigint;

  SELECT @fetchedJSON =
    dbo.JSON_FIND_INSURANCE_CARRIERS_BY_NAME  (
    @incomingInsurerNameOrCode      ,
    @active                         , 
    @carrierStateUS          
  )

  SELECT @fetchedCount = COUNT(*) FROM OPENJSON (@fetchedJSON)

  IF ( @fetchedCount = 0 )
    RETURN NULL

  IF ( @fetchedCount > 1 )
    RETURN -1

  select top 1 @fetchedID=id from  OPENJSON (@fetchedJSON) WITH ( [id] bigint )

  return @fetchedID


END

GO