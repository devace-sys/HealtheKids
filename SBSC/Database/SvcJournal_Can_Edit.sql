USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SvcJournal_Can_Edit') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION SvcJournal_Can_Edit
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[SvcJournal_Can_Edit] (
    @userID            BIGINT
  , @userGroup         INT  
  , @userRank          INT
  , @clientID          BIGINT      
  , @journalID         BIGINT
)    

RETURNS BIT
 
 /***************************************************************************    
  * SvcJournal_Can_Edit */    
 /**    
  * Can a journal still be edited or deleted
  *
  * @return bit
  ***************************************************************************/                         
     
BEGIN

  
  declare @canEdit as bit = null
 
  /*============================================================
   * If active journal exists
   *============================================================*/  

  if (
    exists(
      select top 1 
        convert(bit,1) 
      from dbo.SvcJournals as sj 
      where 
            sj.clientID = @clientID  
        and sj.id       = @journalID 
        and sj.active   = 1
    )
  )
 
  begin

    /*============================================================
     * Get count of number of service records associated with
     * the journal that can NO LONGER be edited
     *============================================================*/  

    declare @numSentSvcs as int = null

    select 
      @numSentSvcs = count (svcRecID)     
    from dbo.SvcJournal_Related_Svc_Records_Data_Core ( @userID, @userGroup, @userRank, @clientID, @journalID, null , null )    
    where (
          (canStillEditSvc = 0) 
      and (state != dbo.CONST_SVC_REC_STATE_DEL()) 
      and (state != dbo.CONST_SVC_REC_STATE_CIF())
    )

    /*============================================================
     * If one or more associated service records can no longer be
     * edited then the journal can no longer be edited
     *============================================================*/  

    if (@numSentSvcs > 0)
    begin
      set @canEdit = 0
    end
    
    /*============================================================
     * If there are no services found that can no longer be edited
     * then the journal can be reopened and edited or deleted
     *============================================================*/  

    else
    begin
      set @canEdit = 1
    end
    
  end
  
  /*============================================================
   * No active journal found.  Nothing to edit.
   *============================================================*/  

  else  
  begin
    set @canEdit = 0
  end
  
  
  return @canEdit

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXEC ON  [dbo].[SvcJournal_Can_Edit] TO [webuser]
GO  
