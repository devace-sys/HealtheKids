USE [SPEDMON]
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLAIM_TCM_FLAG_HISTORY_VIEW') AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CLAIM_TCM_FLAG_HISTORY_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION  [dbo].[CLAIM_TCM_FLAG_HISTORY_VIEW] ( 
    @whichEntity      int
  , @entityID         bigint   
)
RETURNS 

@recs table (   
    entryStartDate     datetime
  , entryEndDate       datetime
  , claimTCM           bit
  , effectiveDate      datetime
  , idx                bigint identity(1,1)
  unique clustered (entryStartDate, entryEndDate, idx)
)

AS
begin


declare @flagHistory table (
    id                 bigint
  , loggedOn           datetime 
  , saveType           int
  , claimTCM           bit
  , effectiveDate      datetime      
)


/* Get audit data from audit log for entity. */

/* Client */

if (@whichEntity = 1) 
begin
  insert into @flagHistory
  select 
      t1.id
    , t1.loggedOn
    , t1.saveType
    , claimTCM = isnull(t1.claim_TCM,1)
    , effectiveDate  = isnull (t1.claim_TCMEffectiveDate,t1.loggedOn)
  from dbo.CLIENTS_AUDIT_LOG as t1
  where (t1.recID = @entityID)
end
 
 
/* Practitioner  */

else if (@whichEntity = 2)
begin
  insert into @flagHistory
  select 
      t1.id
    , t1.loggedOn
    , t1.saveType
    , claimTCM = isnull(t1.claim_TCM,1)
    , effectiveDate  = isnull (t1.claim_TCMEffectiveDate,t1.loggedOn)
  from dbo.PRACTITIONERS_AUDIT_LOG as t1
  where (t1.recID = @entityID)
end

/* Not supported */

else 
begin
  return
end

/* If there is no audit data for the entity creation (new record, saveType = 1)
   then the entity must predate the audit log as there would be a save type for new records
   Assume a claim TCM = 1 as this would have been the value back then */
  
if not exists (select top 1 id from @flagHistory where saveType = 1)
begin
  
  /* Client */
  
  if (@whichEntity = 1)
  begin
    insert into @flagHistory
    select 
	    id            = 0
	  , loggedOn      = isnull(t1.DATE_CREATED,dbo.CONST_MIN_DATETIME())
	  , saveType      = 1
	  , claimTCM      = 1
      , effectiveDate = isnull(t1.claim_TCMEffectiveDate,isnull(t1.DATE_CREATED,dbo.CONST_MIN_DATETIME()))
    from dbo.CLIENTS_Client as t1
    where (t1.CLIENT_ID = @entityID)   
  end

  /* Practitioner */

  else if (@whichEntity = 2)
  begin
  
    insert into @flagHistory
    select 
	    id            = 0
	  , loggedOn      = isnull(t1.DATE_CREATED,dbo.CONST_MIN_DATETIME())
	  , saveType      = 1
	  , claimTCM      = 1
      , effectiveDate = isnull(t1.claim_TCMEffectiveDate,isnull(t1.DATE_CREATED,dbo.CONST_MIN_DATETIME()))
    from dbo.PRACTITIONER_Practitioner as t1
    where (t1.PRACTITIONER_ID = @entityID)   
  end
end  

/* Generate date ranges and output data */

insert into @recs

select  
   entryStartDate = t1.loggedOn
 , entryEndDate   = isnull((LEAD(t1.loggedOn) OVER(ORDER BY t1.id)),getdate())
 , claimTCM
 , effectiveDate = convert(date,t1.effectiveDate)
from @flagHistory as t1
order by t1.id

return
end
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CLAIM_TCM_FLAG_HISTORY_VIEW] TO [webuser]
GO   


