USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RMTS_PARTICIPANTS_INCLUDED_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION RMTS_PARTICIPANTS_INCLUDED_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[RMTS_PARTICIPANTS_INCLUDED_VIEW_CORE] (
    @clientID            bigint
  , @rosterID            bigint
)    
 
RETURNS 

@recs table (    
    id                         bigint
  , [name]                     varchar(256)
  , title                      varchar(2003)
  , submitClaims               bit
  , submitClaimsStr            varchar(3)
  , clientID                   bigint
  , pracID                     bigint
  , groupID                    bigint
  , groupServiceClassNameID    bigint
  , sourceOfData               int
  , rosterID                   bigint
  , participantID              bigint 
  unique clustered (id)
)
AS
BEGIN
 
 /***************************************************************************    
  * RMTS_PARTICIPANTS_INCLUDED_VIEW_CORE */    
 /**    
  * Returns a table of participants who are or may be included
  *    
  * @return                 Table 
  ***************************************************************************/     

if (@clientID is null) return

declare @refRosterID  as bigint = null
declare @sourceOfData as int    = null

/* Particular roster being specified? */

if ((@rosterID is not null))
begin
  set @sourceOfData = 1
  set @refRosterID = @rosterID
end

/* No roster id passed, find the most recent */

else 
begin
  set @sourceOfData = 2
  select top 1 
    @refRosterID = rpr.id
  from dbo.RMTS_PARTICIPATION_ROSTER as rpr  
  where 
    (rpr.clientID = @clientID)
  order by 
    rpr.quarterID desc
end

/* Return records based on saved data */

if (@refRosterID is not null)
begin
 
  insert into @recs
  select 
    rpp.* 
  , sourceOfData   = @sourceOfData
  , rosterID       = iif((@sourceOfData = 1),rpr.id, null)
  , participantID  = iif((@sourceOfData = 1),rp.id,  null)
  
  from dbo.RMTS_PARTICIPATION_ROSTER                        as rpr
  join dbo.RMTS_PARTICIPANTS                                as rp  on rp.rosterID = rpr.id
  join dbo.RMTS_PARTICIPANTS_POSSIBLE_VIEW_CORE (@clientID) as rpp on rpp.pracID = rp.pracID
  where 
    (rpr.id = @refRosterID)

  return

end
else

/* Very first time creating any roster for this client */

begin
	set @sourceOfData = 3
    insert into @recs
    select 
        rpp.*
	  , sourceOfData  = @sourceOfData
      , rosterID      = null
      , participantID = null
   
	from dbo.RMTS_PARTICIPANTS_POSSIBLE_VIEW_CORE (@clientID) as rpp 
    where 
	  (rpp.submitClaims = 1)
    return
end

return
END
GO

GRANT SELECT ON  [dbo].[RMTS_PARTICIPANTS_INCLUDED_VIEW_CORE] TO [webuser]
GO
