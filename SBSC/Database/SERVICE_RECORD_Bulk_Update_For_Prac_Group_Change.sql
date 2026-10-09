USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_RECORD_Bulk_Update_For_Prac_Group_Change') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.SERVICE_RECORD_Bulk_Update_For_Prac_Group_Change
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[SERVICE_RECORD_Bulk_Update_For_Prac_Group_Change] (
    @userID        BIGINT
  , @clientID      bigint    
  , @pracID        bigint
  , @startDOS      datetime
  , @endDOS        datetime
  , @oldGroupID    bigint
  , @newGroupID    bigint  
)    
AS    
BEGIN     

declare @tranOpen                    as bit
declare @today                       as datetime    
declare @curIdx                      as bigintdeclare @maxIdx                      as bigintdeclare @oldNameID                   as bigintdeclare @newNameID                   as bigintdeclare @svcRecID                    as bigintdeclare @generateClaimsForThisSvcRec as bitdeclare @editDelReason               as varchar(7000)declare @auditRecID                  as bigintdeclare @rowCount                    as int declare @svcRecsToEdit as table (    idx                          bigint identity(1,1)  , svcRecID                     bigint  , oldNameID                    bigint  , newNameID                    bigint  , editDelReason                varchar(7000)  , generateClaimsForThisSvcRec  bit)

SET NOCOUNT ON    
set @tranOpen = 0
set @today    = getdate()

BEGIN TRY

exec dbo.PRINT_STATUS_MESSAGE 'Getting service records'

;withcte_p1as(  select       svcRecID   = sr.id    , oldNameID  = sr.nameID	, newNameID  = dbo.GET_SERVICE_NAME_ID_REPLACEMENT_FOR_GROUP_CHANGE ( sr.clientID, sr.planType, sr.dos, sr.svcType, sr.svcSubType1, sr.viaTelehealth, sr.groupID, sr.nameID, @newGroupID)	, sr.generateClaimsForThisSvcRec      from dbo.SERVICE_RECORDS as sr    where (          (sr.clientID = @clientID)      and (sr.pracID   = @pracID)      and (sr.dos between @startDOS and @endDOS)      and (sr.groupID = @oldGroupID)      and (sr.state in (1,10))  )),cte_p2as(  select       p1.* 	, editDelReason = 'Bulk update. Prac had incorrect groupID assignment. Changed groupID from ' + convert(varchar(50),@oldGroupID)  + ' to ' + convert(varchar(50),@newGroupID)	                + ' and changed nameID from ' + convert(varchar(50),p1.oldNameID) + ' to ' + convert(varchar(50),p1.newNameID) + '.'  from cte_p1 as p1  where     (p1.newNameID is not null))insert into @svcRecsToEdit (    svcRecID  , oldNameID  , newNameID  , editDelReason  , generateClaimsForThisSvcRec)select     p2.svcRecID  , p2.oldNameID  , p2.newNameID  , p2.editDelReason  , generateClaimsForThisSvcRec from cte_p2 as p2order by svcRecID asc
select @curIdx = min(idx), @maxIdx = max(idx) from @svcRecsToEdit

begin transaction
set @tranOpen = 1

while (@curIdx <= @maxIdx)
begin
  
  exec dbo.PRINT_STATUS_MESSAGE 'Getting service record'

  select top 1 
	  @svcRecID                    = t1.svcRecID
	, @oldNameID                   = t1.oldNameID
	, @newNameID                   = t1.newNameID
	, @editDelReason               = t1.editDelReason
    , @generateClaimsForThisSvcRec = t1.generateClaimsForThisSvcRec 
  from @svcRecsToEdit as t1 
  where (t1.idx = @curIdx)

  set @rowCount = 0

  exec dbo.PRINT_STATUS_MESSAGE 'Attempting to update'

  update sr
  set 
      sr.groupID      = @newGroupID
	, sr.nameID       = @newNameID
    , sr.lastmodified = @today
	, sr.[state]      = 10
  from dbo.SERVICE_RECORDS as sr

  /* Check for changes JUST before update to make sure we should still update this record */
  
  where (
          (sr.id       = @svcRecID)
      and (sr.clientID = @clientID)      and (sr.pracID   = @pracID)      and (sr.dos between @startDOS and @endDOS)      and (sr.groupID = @oldGroupID)      and (sr.nameID  = @oldNameID)
	  and (sr.state in (1,10))
  )
  
  /* Determine if an update actually happened */

  set @rowCount = @@ROWCOUNT
  
  /* If it did then go ahead and manage claims and create audit record */

  if (@rowCount != 0)
  begin
    exec dbo.PRINT_STATUS_MESSAGE 'Update completed'
    exec dbo.PRINT_STATUS_MESSAGE 'Managing claims'
    exec dbo.SERVICE_RECORD_MANAGE_CLAIMS_CORE @svcRecID, 2, @today, N'', N'', 10, @generateClaimsForThisSvcRec
    exec dbo.PRINT_STATUS_MESSAGE 'Creating audit record'
    exec dbo.SERVICE_RECORD_Audit @svcRecID, @today, @userID, 2, 10, @editDelReason, @auditRecID OUTPUT
  end
  else
  begin
    exec dbo.PRINT_STATUS_MESSAGE 'Update was not needed, record had changed'
  end

  /* Move on to next row */

  set @curIdx = @curIdx + 1
end

commit transaction
set @tranOpen = 0

exec dbo.PRINT_STATUS_MESSAGE 'Done'
  
RETURN(0)    

END TRY    

/*-------------------------------    
 * If we end up here something    
 * went wrong
 *------------------------------*/    

BEGIN CATCH    
  
  -- Error or raise error with severity 11 to 19 will be caught here    
    
  /*-------------------------------    
   * Cancel any pending    
   * transactions  
   *------------------------------*/    
      
  IF @tranOpen = 1 ROLLBACK TRANSACTION    
      
  /*-------------------------------    
   * Identify error
   *------------------------------*/    
  
  DECLARE @ErrorMessage  AS NVARCHAR(4000)    
  DECLARE @ErrorSeverity AS INT    
  DECLARE @ErrorState    AS INT    
      
  SELECT  @ErrorMessage  = ERROR_MESSAGE(),    
          @ErrorSeverity = ERROR_SEVERITY(),    
          @ErrorState    = ERROR_STATE()    
      
  SET @ErrorMessage = @ErrorMessage 
      
  /*-------------------------------    
   * Return the error message to
   * the caller.  
   *------------------------------*/    
 
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
    
END CATCH    

END  
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[SERVICE_RECORD_Bulk_Update_For_Prac_Group_Change] TO [webuser]
GO
