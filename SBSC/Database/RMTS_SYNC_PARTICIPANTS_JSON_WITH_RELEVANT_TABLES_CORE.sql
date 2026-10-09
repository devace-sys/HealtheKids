USE SPEDMON
GO

/*-------------------------------
 * Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RMTS_SYNC_PARTICIPANTS_JSON_WITH_RELEVANT_TABLES_CORE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.RMTS_SYNC_PARTICIPANTS_JSON_WITH_RELEVANT_TABLES_CORE
GO


/*-------------------------------
 * Create 
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[RMTS_SYNC_PARTICIPANTS_JSON_WITH_RELEVANT_TABLES_CORE] (
      @clientID bigint
    , @rosterID bigint
)
AS    
BEGIN     
    
/***************************************************************************    
 * RMTS_SYNC_PARTICIPANTS_JSON_WITH_RELEVANT_TABLES_CORE */    
/**    
 * HAS TO BE CALLED WITHIN A TRANSACTION
 *
 * Synchoronize the columns @participantRosterJSON and @participantRosterChangesJSON
 * from dbo.RMTS_PARTICIPATION_ROSTER table and the dbo.RMTS_PARTICIPANTS_CHANGES table
 * with entries in dbo.RMTS_PARTICIPANTS
 *    
 ***************************************************************************/         
     
SET NOCOUNT ON    

/*============================================================
 * Variables
 *============================================================*/  
DECLARE @rosterJSON			varchar(max)
DECLARE @rosterChangesJSON	varchar(max)

declare @participantChanges as table (
    [pracID]			  bigint
  , [action]			  varchar(10)
  , [effectiveDate]		  date
  , [participationStatus] varchar(20)
  , [participating]		  varchar(5)
  , [participantObj]      varchar(max)
  , [recordedOn]		  datetime
  , [recordedBy]		  bigint
)


declare @participants as table (
    pracID			      bigint
  , pracName			  varchar(256)
  , pracTitle			  varchar(256)
  , startDate 			  date
  , endDate				  date
  , submitClaimsStr       varchar(10)
  , created				  datetime
  , createdBy			  bigint
  , lastModified		  datetime
  , lastModifiedBy		  bigint
)

declare @roster as table (
    id               bigint
  , quarterStartDate date
  , quarterEndDate   date
)

BEGIN TRY

/*============================================================
 * Verify incoming parameters that are essential for proper op
 *============================================================*/  
    
IF (@rosterID      IS NULL) RAISERROR ('roster ID not passed', 11, 1)

/*============================================================
 * Cache roster data
 *============================================================*/ 

insert into @roster 
(
	  id              
	, quarterStartDate
	, quarterEndDate  
)
select top 1
	  id              
	, quarterStartDate
	, quarterEndDate  
from dbo.RMTS_PARTICIPATION_ROSTER_VIEW(null,null,null,@clientID, 1, @rosterID)

/*============================================================
 * Cache participants data
 *============================================================*/ 

Insert into @participants
(
	  pracID			
	, pracName		
	, pracTitle		
	, startDate 		
	, endDate			
	, submitClaimsStr 
	, created			
	, createdBy		
	, lastModified	
	, lastModifiedBy	
) 
select 
	  pracID			
	, pracName		
	, pracTitle		
	, startDate 		
	, endDate			
	, submitClaimsStr 
	, created			
	, createdBy		
	, lastModified	
	, lastModifiedBy	
from dbo.RMTS_PARTICIPANTS_VIEW_CORE(@clientID, @rosterID, 1, null)


/*============================================================
 * Handle changes for start date
 * Logic: if start date is after quarter start, mark as "added"
 *============================================================*/  
Insert into @participantChanges 
	(
		  [pracID]              
		, [action]              
		, [effectiveDate]       
		, [participationStatus] 
		, [participating]		
		, [recordedOn]	 
		, [recordedBy]	 
	)
	select
		  [pracID]              = rp.pracID 
		, [action]              = 'added'			  
		, [effectiveDate]       = rp.startDate	  
		, [participationStatus] = 'Participating'
		, [participating]		= '1'  		
		, [recordedOn]	   = isnull(rp.lastModified, rp.created)
		, [recordedBy]	   = isnull(rp.lastModifiedBy, rp.createdBy)
	from @participants as rp
	cross apply @roster as rpr

	where rp.startDate > rpr.quarterStartDate

/*============================================================
 * Handle changes for end date
 * Logic: if end date is before quarter end, mark as "removed"
 *============================================================*/  
Insert into @participantChanges 
	(
		  [pracID]             
		, [action]             
		, [effectiveDate]      
		, [participationStatus]
		, [participating]		
		, [recordedOn]	   
		, [recordedBy]	   
	)
	select
          [pracID]              = rp.pracID  
		, [action]              = 'removed'			  
		, [effectiveDate]       = rp.endDate	  
		, [participationStatus] = 'Not Participating'
		, [participating]		= '0'  
		, [recordedOn]	   = isnull(rp.lastModified, rp.created)
		, [recordedBy]	   = isnull(rp.lastModifiedBy, rp.createdBy)
	from @participants as rp
	cross apply @roster as rpr
	where rp.endDate < rpr.quarterEndDate

/*============================================================
 * Create JSON fields
 *============================================================*/ 
SET @rosterJSON = (
	select 
		  id     = rpv.pracID
		, [name] = rpv.pracName
		, title  = rpv.pracTitle
		, submitClaimsStr = rpv.submitClaimsStr
	from @participants as rpv
	FOR JSON PATH
)

SET @rosterChangesJSON = (
	select 
		  [action]             
		, [effectiveDate]      
		, [participationStatus]
		, participating          = iif([participating] = 1, '1', '0')		
		, 'participantObj.id'    = rpvc2.pracID
		, 'participantObj.name'  = rpvc2.pracName
		, 'participantObj.title' = rpvc2.pracTitle
		, 'participantObj.submitClaimsStr' = rpvc2.submitClaimsStr

	from @participantChanges as pc
	cross apply (select top 1
					  rpvc1.pracID
					, rpvc1.pracName
					, rpvc1.pracTitle
					, rpvc1.submitClaimsStr
				 from @participants as rpvc1
				 where ((1=1) and (rpvc1.pracID =pc.pracID )) 
				 ) as rpvc2
	FOR JSON PATH
)

/*============================================================
 * Sync roster with one update
 *============================================================*/  
UPDATE dbo.RMTS_PARTICIPATION_ROSTER
set participantRosterJSON = @rosterJSON
  , participantRosterChangesJSON = @rosterChangesJSON
where id = @rosterID and clientID = @clientID

/*============================================================
 * Sync roster changes
 *============================================================*/ 
delete from dbo.RMTS_PARTICIPANTS_CHANGES where (rosterID = @rosterID)

insert into dbo.RMTS_PARTICIPANTS_CHANGES
select rosterID      = @rosterID
     , pracID        = pc.pracID
	 , participating = pc.participating
	 , effectiveDate = pc.effectiveDate
	 , recordedOn    = pc.recordedOn
	 , recordedBy    = pc.recordedBy
from @participantChanges as pc

RETURN(0)    
END TRY  

/*============================================================
 * Exception handling
 *============================================================*/      

BEGIN CATCH    
    
  /*-------------------------------    
   * If we end up here something    
   * went wrong.  Cancel any pending    
   * transactions and return any    
   * error any error messages to    
   * the caller    
   *------------------------------*/    
       
  -- Error or raise error with severity 11 to 19 will be caught here    
            
  DECLARE @ErrorMessage  AS NVARCHAR(4000)    
  DECLARE @ErrorSeverity AS INT    
  DECLARE @ErrorState    AS INT    
      
  SELECT  @ErrorMessage  = ERROR_MESSAGE(),    
          @ErrorSeverity = ERROR_SEVERITY(),    
          @ErrorState    = ERROR_STATE()    
   
  -- Only send really bad exceptions back with sp details

  if (@ErrorSeverity > 11)    
    SET @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ']'    
      
  -- Reraise the error so it returns back to the server    
      
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
    
END CATCH    
END    
    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[RMTS_SYNC_PARTICIPANTS_JSON_WITH_RELEVANT_TABLES_CORE] TO [webuser]
GO
