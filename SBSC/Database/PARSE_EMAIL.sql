USE [SPEDMON]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PARSE_EMAIL]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[PARSE_EMAIL]
GO

 
/*-------------------------------
 * Calculates status flags that a human developer or analyst would be instantly aware of, without calculation.
 * For example - an email hosted at egusd.net is a client provided email.  An email at gmail.com is from
 * a public email service; an email hosted at @wholechildtherapy.net is issued by a health-care provider
  * organization.  Etc.
*/

CREATE  FUNCTION  [dbo].[PARSE_EMAIL]
(
  @email           varchar(256),
  @clientID            bigint
)
RETURNS @results TABLE (
  isLEAClientEmail         bit,
  isViaPublicEmailWebhost  bit,
  isISP                    bit,
  isHealthCareProviderOrg  bit,
  isUnknownInstitutional   bit,

  isDotGov            bit,
  isDotOrg            bit,
  isDotEdu            bit,
  otherTLD            bit,

  isEmpty             bit,
  isInvalid           bit,

  domain              varchar(256)
)
  /***************************************************************************
 * PARSE_EMAIL */
/**
 * Returns a table of 1 row.  (UDFs do not support returning a stuct or tuple.)

 * @return                         Table of report rows
 ***************************************************************************/

 
AS BEGIN

   IF ( LEN( @email ) = 0 OR @email  IS NULL)
   BEGIN

     INSERT INTO @results (
     isEmpty
     )
	 SELECT 1;
     return;

   END

   IF ( NOT( CHARINDEX('@', @email, 1) > 1 ))
   BEGIN

     INSERT INTO @results (
     isInvalid
     )
	 SELECT 1;
     return;

   END

   declare @domain varchar(256) = 
      SUBSTRING( @email  , CHARINDEX('@', @email  , 1) + 1, 999 )

   IF ( NOT( CHARINDEX('.', @domain, 1) > 1 ))
   BEGIN

     INSERT INTO @results (
     isInvalid
     )
	 SELECT 1;
     return;

   END

   declare @domainWoSuffx varchar(256) =
    SUBSTRING(
	  @domain ,
	  1 ,
      CHARINDEX('.', @domain, 1) - 1
    )

   declare @publicEmailProviders table (
     name varchar(256)
   )

   declare @publicIspProviders table (
     name varchar(256)
   )

   INSERT INTO @publicEmailProviders ([name])
   VALUES
     ('gmail'),
	 ('yahoo'),
     ('msn'),
     ('aol'),
	 ('live'),
	 ('outlook') 
     -- add more if necessary

   INSERT INTO @publicIspProviders ([name])
   VALUES 
     ('earthlink'),
	 ('comcast'),
     ('surewest'),
	 ('charter'),
	 ('spectrum'),
	 ('att') 
     -- add more if necessary


   declare   @isDotGov      bit  = 0,
             @isDotOrg      bit  = 0,
             @isDotEdu      bit  = 0,
			 @otherTLD      bit  = 0

   declare   @isLEAClientEmail         bit  = 0,
             @isViaPublicEmailWebhost  bit  = 0,
             @isISP                    bit  = 0,
             @isHealthCareProviderOrg  bit  = 0,
             @isUnknownInstitutional   bit  = 0

   declare @substringTLD varchar(15) =
     SUBSTRING( @email , CHARINDEX('.', @email , 1), 999)

   if      ( @substringTLD = '.gov' )
      SET @isDotGov = 1
   else if ( @substringTLD = '.org' )
      SET @isDotOrg = 1 
   else if ( @substringTLD = '.edu' )
      SET @isDotEdu = 1
   else
      SET @otherTLD = 1

   INSERT INTO @results (
     isEmpty      ,
	 isInvalid    ,

     isDotGov     ,
     isDotOrg     ,
     isDotEdu     ,
     otherTLD      
   )
   SELECT
     0,
	 0,
     @isDotGov     ,
     @isDotOrg     ,
     @isDotEdu     ,
     @otherTLD      

   IF EXISTS (
     SELECT top 1 * FROM [dbo].[CLIENTS_DOMAINS]
	  WHERE CLIENT_ID = @clientID AND ACTIVE = 1
	  AND [DOMAIN] = @domain
   )
	   SET @isLEAClientEmail = 1

   ELSE IF EXISTS (

         SELECT top 1 * FROM @publicEmailProviders
		 WHERE [name] = @domainWoSuffx

   )
	   SET @isViaPublicEmailWebhost = 1

   ELSE IF EXISTS (

       SELECT top 1 * FROM @publicIspProviders
	   WHERE  [name] = @domainWoSuffx

   )
	   SET @isISP = 1

   ELSE IF (@domainWoSuffx LIKE '%health%'
    OR @domainWoSuffx LIKE '%therap%' OR @domainWoSuffx LIKE '%care%' )  -- consider adding more?
	   SET @isHealthCareProviderOrg = 1

   ELSE
       SET @isUnknownInstitutional = 1


   UPDATE @results
	   SET
	         isLEAClientEmail           =  @isLEAClientEmail          ,
             isViaPublicEmailWebhost    =  @isViaPublicEmailWebhost   ,
             isISP                      =  @isISP                     ,
             isHealthCareProviderOrg    =  @isHealthCareProviderOrg   ,
             isUnknownInstitutional     =  @isUnknownInstitutional    ,

			 domain                     =  @domain


RETURN 
END
 
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PARSE_EMAIL] TO [webuser]     
GO











