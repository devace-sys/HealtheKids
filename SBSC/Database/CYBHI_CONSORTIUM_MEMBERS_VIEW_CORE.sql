USE SPEDMON
GO

-- Drop if exists

IF EXISTS (
  SELECT * FROM sys.objects 
  WHERE object_id = OBJECT_ID('dbo.CYBHI_CONSORTIUM_MEMBERS_VIEW_CORE') 
    AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT')
)
DROP FUNCTION dbo.CYBHI_CONSORTIUM_MEMBERS_VIEW_CORE
GO

-- Create function

CREATE FUNCTION dbo.CYBHI_CONSORTIUM_MEMBERS_VIEW_CORE (
      @userID                   bigint
    , @userGroup                int
    , @userRank                 int
    , @consortiumLeadClientID   bigint
)
RETURNS TABLE
AS
RETURN (
with

/* Lead client */

cte_p1
as
(
  select top 1 
      clc.CLIENT_ID
    , clc.CLIENT_NAME
    , leadClient = 1
  from dbo.CLIENTS_Client as clc

  /* Keep lead client identification logic in synch with C:\MBA\Common\Database\USERS_ALL.sql */

  where (
        (clc.CLIENT_ID              = @consortiumLeadClientID)
    and (clc.cybhiConsortiumBilling = 1)
    and (isnull(clc.cybhiConsortiumLeadClientID,0) = 0)
  )
)
,

/* All clients assigned to lead client */

cte_p2
as
(
  select 
      clc.CLIENT_ID
    , clc.CLIENT_NAME
    , leadClient = 0
  from dbo.CLIENTS_Client as clc
  where (
        (clc.cybhiConsortiumBilling      = 1)
    and (clc.cybhiConsortiumLeadClientID = @consortiumLeadClientID)
  )
)
,

/* Combine */

cte_p3
as
(
  select p1.* from cte_p1 as p1
  union
  select p2.* from cte_p2 as p2
)

/* Output */

select 
    id         = p3.CLIENT_ID
  , [name]     = p3.CLIENT_NAME
  , leadClient = convert(bit,p3.leadClient)
  , idStr      = convert(varchar(256),p3.CLIENT_ID)
from cte_p3 as p3
)

GO

-- Grant permission

GRANT SELECT ON dbo.CYBHI_CONSORTIUM_MEMBERS_VIEW_CORE TO [webuser]
GO
