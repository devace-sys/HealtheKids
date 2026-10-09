USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_RECORD_VIEW_REDUNDANT_ENTRIES_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SERVICE_RECORD_VIEW_REDUNDANT_ENTRIES_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[SERVICE_RECORD_VIEW_REDUNDANT_ENTRIES_CORE] (
    @clientID       int
  , @patID          int
  , @svcClassNameID bigint
  , @svcTypeID      int
  , @nameID         int
  , @altNameID      int
  , @dos            datetime
  , @startTime      time(0)
  , @svcRecID       bigint
)
returns 
@recs table (
     id                    bigint 
   , pracID                int
   , pracName              varchar(256)
   , pracTitle             varchar(256)
   , groupID               int
   , nameID                int
   , numMins               int
   , startTime             time(0)
   , created               datetime
)
as
begin
    
declare @dfltTime as time(0) = convert(time(0),'00:00:00')
set @startTime = isnull(@startTime,convert(time(0),'00:00:00'))

--CLIENT_PAT_GRP_FAM_SVCTYPE_IDX_W_ADD_COLS

insert into @recs (
    id
  , pracID
  , pracName
  , pracTitle
  , groupID
  , nameID
  , numMins
  , startTime
  , created
)

select 
       sr.id
	 , sr.pracID
	 , pracName  = prp.CONCAT_NAME
	 , pracTitle = gg.GROUP_NAME
	 , sr.groupID
	 , sr.nameID
	 , sr.numMins
	 , sr.startTime
	 , sr.created
from dbo.SERVICE_RECORDS           as sr
join dbo.PRACTITIONER_Practitioner as prp on prp.PRACTITIONER_ID = sr.pracID
join dbo.GROUP_Group               as gg  on gg.GROUP_ID         = sr.groupID
where (
     ((sr.clientID            = @clientID)
  and (sr.patID               = @patID)
  and (sr.pracGrpSvcClsNameID = @svcClassNameID)
  and (sr.svcType             = @svcTypeID)
  and (sr.dos                 = @dos)
  and ((@svcRecID is null) or (sr.id != isnull(@svcRecID,0))))
  and ((sr.nameID = @nameID) or (sr.nameID = @altNameID))
  and (sr.state not in (99,199))  
  and (isnull(sr.startTime,@dfltTime) = @startTime)   
)

return

end
GO
