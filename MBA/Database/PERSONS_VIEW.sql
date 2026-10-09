USE users
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PERSONS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PERSONS_VIEW
GO
/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[PERSONS_VIEW]
(@userID      BIGINT,    
 @userGroup   INT,    
 @userRank    INT,
 @recID       INT,
 @email       nvarchar(256),
 @source      INT,
 @active      BIT,
 @canEdit     BIT)
RETURNS TABLE 
AS
RETURN 
(

/***************************************************************************
 * PERSONS_VIEW */
/**
 * Temporary way to display persons data.
 *
 * TODO: Refactor when persons table structure is complete
 *
 * Please note that the id column is derived and it does not corespond
 * to an actual record id.  sourceID coresponds to a record id.
 *
 * @param  email           user's email or null 
 * @param  source          1 = LEA database, 2 = Users database, 3 = reserved, 4 = reserved
 * @param  active          If user is active
 * @param  canEdit         If user can be edited by userID 
 * @return                 Table of user data
 ***************************************************************************/ 
    
select 
  dbo.BIG_INT_CONCAT(q1.source,q1.sourceID) as id, 
  q1.*
from
(
  select 
    name,
    lastName,
    firstName,
    email,
    phone,
    fax,
    clientID,
    clientName,
    active, 
    notes,
    startDate,
    endDate,
    dbo.CONST_PERSONS_SOURCE_SPEDMON() as [source],
    id as [sourceID]
  from 
  -- TODO: we're gonna need to eventually fix every instance of this practi- toners typo
  SPEDMON.dbo.PRACTITONERS_VIEW_CORE(null,null,null,null,null,null,null,null,null,null,null)
  union
  select 
    name,
    lastName,
    firstName,
    email,
    phone,
    '' as fax,
    clientID,
    clientName,
    active,
    '' as notes,
    null as startDate,
    null as endDate,
    dbo.CONST_PERSONS_SOURCE_USERS() as [source],
    id as [sourceID]
  from Users.dbo.USERS_DATA_CORE(null,null,null,null,null)
  
) as q1
where (1=1) 
and ((@email is null)  or (q1.email  = @email))
and ((@source is null) or (q1.source = @source))
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[PERSONS_VIEW] TO [webuser]
GO
