USE users
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[GENERATE_RANDOM_NUMBERS]'))
DROP VIEW [dbo].[GENERATE_RANDOM_NUMBERS]
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE VIEW [dbo].[GENERATE_RANDOM_NUMBERS] 
AS

select top 1
  [VALUE_BIGINT]   = CAST(CRYPT_GEN_RANDOM(8) AS bigint)
 ,[VALUE_INT]      = CAST(CRYPT_GEN_RANDOM(4) AS int)
, [VALUE_SMALLINT] = CAST(CRYPT_GEN_RANDOM(2) AS smallint)
, [VALUE_TINYINT]  = CAST(CRYPT_GEN_RANDOM(1) AS tinyint)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[GENERATE_RANDOM_NUMBERS] TO [webuser]
GO