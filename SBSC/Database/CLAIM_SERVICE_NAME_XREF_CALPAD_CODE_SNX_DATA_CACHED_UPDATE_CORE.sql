USE SPEDMON
GO
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('CLAIM_SERVICE_NAME_XREF_CALPAD_CODE_SNX_DATA_CACHED_UPDATE_CORE') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.CLAIM_SERVICE_NAME_XREF_CALPAD_CODE_SNX_DATA_CACHED_UPDATE_CORE
GO

CREATE PROCEDURE dbo.CLAIM_SERVICE_NAME_XREF_CALPAD_CODE_SNX_DATA_CACHED_UPDATE_CORE    
AS    
BEGIN    

set nocount on

declare @today as datetime = getdate()

declare @standardSnx as table (
    planTypeID       bigint not null
  , groupID          bigint not null
  , nameID           bigint not null
  , spEdSvcCodeValue int    not null
  , unique clustered (planTypeID, groupID, nameID, spEdSvcCodeValue)
)

declare @clientSpecificSnx as table (
    clientID         bigint not null
  , planTypeID       bigint not null
  , groupID          bigint not null
  , nameID           bigint not null
  , spEdSvcCodeValue int    not null
  , unique clustered (clientID, planTypeID, groupID, nameID, spEdSvcCodeValue)
)

declare @cachedSnx as table (
    clientID          bigint   not null
  , spEdSvcCodeValue  int      not null
  , planTypeID        bigint   not null
  , groupID           bigint   not null
  , nameID            bigint   not null
  , standardSelection bit      not null
  , generatedOn       datetime not null
  unique clustered (clientID, spEdSvcCodeValue, planTypeID, groupID, nameID )
)

/*#####################################################################################################################*/
/* Get existing standard snx */
/*#####################################################################################################################*/
 
insert into @standardSnx (
    planTypeID
  , groupID 
  , nameID
  , spEdSvcCodeValue
)
select distinct
    snx.planTypeID
  , snx.groupID
  , snx.nameID
  , snx.spEdSvcCodeValue
from   dbo.CLAIM_SERVICE_NAME_XREF_AND_FORM_DATA  as snx 
join   dbo.SpEd_Service                           as ss on ((ss.codeValue = snx.spEdSvcCodeValue and ss.active = 1))
where  (
          (snx.spEdSvcCodeValue != -1)
      and (snx.isStandard = 1)
      and (snx.active     = 1)
	  and (snx.id is not null)
)
option (recompile)

/*#####################################################################################################################*/
/* Get client specific snx */
/*#####################################################################################################################*/

insert into @clientSpecificSnx (
    clientID
  , planTypeID
  , groupID 
  , nameID
  , spEdSvcCodeValue
)
select distinct 
    snx.clientID
  , snx.planTypeID
  , snx.groupID
  , snx.nameID
  , snx.spEdSvcCodeValue	  
from   dbo.CLAIM_SERVICE_NAME_XREF_AND_FORM_DATA  as snx 
join   dbo.SpEd_Service                           as ss on ((ss.codeValue = snx.spEdSvcCodeValue) and (ss.active = 1))
where  (
      (snx.spEdSvcCodeValue != -1)
  and (snx.isStandard = 0)
  and (snx.active     = 1)
  and (snx.id is not null)
)
option (recompile)

/*#####################################################################################################################*/
/* Rebuild cached data */
/*#####################################################################################################################*/

/*
 * Each active client gets their own set of standard selections.
 * We are doing this so we can override selections if needed later
 */

insert into @cachedSnx (
    clientID
  , spEdSvcCodeValue
  , planTypeID
  , groupID 
  , nameID
  , standardSelection
  , generatedOn
)
select 
    clientID = clc.CLIENT_ID
  , snx2.spEdSvcCodeValue
  , snx2.planTypeID
  , snx2.groupID
  , snx2.nameID
  , standardSelection = 1
  , generatedOn = @today
from dbo.CLIENTS_Client as clc
cross apply (
  select snx1.* from @standardSnx as snx1
) as snx2
where 
  (clc.LEA = 1)
option (recompile)

/*
 * If a client has their own calpads code that the standard selections 
 * do not, include it JUST FOR THAT CLIENT.  See clientID 39 for examples.
 */

insert into @cachedSnx (
    clientID
  , spEdSvcCodeValue
  , planTypeID
  , groupID 
  , nameID
  , standardSelection
  , generatedOn
)

select distinct
    t1.clientID 
  , t1.spEdSvcCodeValue
  , t1.planTypeID
  , t1.groupID
  , t1.nameID
  , standardSelection = 0
  , generatedOn = @today
from      @clientSpecificSnx  as  t1
left join @standardSnx        as  t2 on  ((t2.planTypeID = t1.planTypeID) and (t2.groupID = t1.groupID) and (t2.nameID = t1.nameID))
where (t2.planTypeID is null)
option (recompile)

/*#####################################################################################################################*/
/* Replace cached data */
/*#####################################################################################################################*/


delete dbo.CLAIM_SERVICE_NAME_XREF_CALPAD_CODE_SNX_DATA_CACHED option (recompile)

insert into dbo.CLAIM_SERVICE_NAME_XREF_CALPAD_CODE_SNX_DATA_CACHED (
    clientID 
  , spEdSvcCodeValue
  , planTypeID
  , groupID
  , nameID
  , standardSelection
  , generatedOn
)
select 
    t1.clientID 
  , t1.spEdSvcCodeValue
  , t1.planTypeID
  , t1.groupID
  , t1.nameID
  , t1.standardSelection
  , t1.generatedOn
from @cachedSnx as t1 
order by 
    t1.clientID
  , t1.spEdSvcCodeValue
  , t1.planTypeID
  , t1.groupID
  , t1.nameID
option (recompile)     
    
END      
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  dbo.CLAIM_SERVICE_NAME_XREF_CALPAD_CODE_SNX_DATA_CACHED_UPDATE_CORE TO webuser
GO