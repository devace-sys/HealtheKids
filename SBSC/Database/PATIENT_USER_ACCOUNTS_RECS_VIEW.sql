USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_USER_ACCOUNTS_RECS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PATIENT_USER_ACCOUNTS_RECS_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[PATIENT_USER_ACCOUNTS_RECS_VIEW] ( 
  @userIDIntAssociation BIGINT
)    
RETURNS TABLE 
AS RETURN (     
  select 
    t1.* 
  from dbo.PATIENT_USER_ACCOUNTS_VIEW_CORE (
    null
  , null
  , null
  , null
  , null
  , 1
  , null
  , @userIDIntAssociation) as t1

)   
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[PATIENT_USER_ACCOUNTS_RECS_VIEW] TO [webuser]
GO
