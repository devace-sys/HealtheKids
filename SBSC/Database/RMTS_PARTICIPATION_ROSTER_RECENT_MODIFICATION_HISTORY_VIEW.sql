USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RMTS_PARTICIPATION_ROSTER_RECENT_MODIFICATION_HISTORY_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION RMTS_PARTICIPATION_ROSTER_RECENT_MODIFICATION_HISTORY_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[RMTS_PARTICIPATION_ROSTER_RECENT_MODIFICATION_HISTORY_VIEW] (
    @userID         BIGINT    
  , @userGroup      BIGINT    
  , @userRank       INT
  , @clientID       bigint
  , @rosterID       bigint
)    
RETURNS 
TABLE
AS
RETURN
(
  select top 5 
	    ua2.[name] as 'name'
	  , CASE
		  WHEN rprr.participantRosterChangesJSON is null THEN 'Created'
		  ELSE 'Modified'
	    END as 'action'
	  , convert(varchar(30), rprr.recordedOn) as 'date'

  from dbo.RMTS_PARTICIPATION_ROSTER           as rpr
  join dbo.RMTS_PARTICIPATION_ROSTER_REVISIONS as rprr on rprr.rosterID = rpr.id
  
  cross apply ( 
  
    select top 1 * from [users].[dbo].USERS_ALL as ua1
	where ua1.id = rprr.recordedBy
  ) as ua2

  where ( 
        (rpr.id = @rosterID)
    and (rpr.clientID = @clientID)
  )

  order by 
    rprr.recordedOn desc
)
GO

GRANT SELECT ON  [dbo].[RMTS_PARTICIPATION_ROSTER_RECENT_MODIFICATION_HISTORY_VIEW] TO [webuser]
GO
