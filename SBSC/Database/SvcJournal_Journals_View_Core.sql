USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SvcJournal_Journals_View_Core') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SvcJournal_Journals_View_Core
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[SvcJournal_Journals_View_Core] (
    @userID            BIGINT
  , @userGroup         INT  
  , @userRank          INT      
  , @clientID          BIGINT
  , @patID             BIGINT 
  , @dos               DATETIME
  , @completed         BIT
  , @recID             BIGINT
)    

RETURNS TABLE
 
 /***************************************************************************    
  * SvcJournal_Journals_View_Core */    
 /**    
  * Returns a list of journals
  *
  * @return table 
  ***************************************************************************/                         
     
AS RETURN
(
with cte_pass_1
as
(
  select 
      id                             = sj.id
   
    , clientID                       = sj.clientID
    , clientName                     = cc.CLIENT_NAME
    , patID                          = sj.patID
    , patName                        = pap.CONCAT_NAME
    , dos                            = dbo.RPT_DATE_FMT(sj.dos)
    , dosVal                         = sj.dos
    , patientAbsent                  = sj.patAbsent
    , completed                      = sj.completed
    , currentRevisionID              = sj.currentRevision
    , hasRevisionID                  = convert(bit,(case when (sj.currentRevision is null) then 0 else 1 end))
    , canEdit                        = dbo.SvcJournal_Can_Edit( @userID
                                                               ,@userGroup
                                                               ,@userRank
                                                               ,sj.clientID
                                                               ,sj.id)
    
    , patAbsentOrPresentStr = case when (sj.patAbsent) = 1  then 'Absent' else 'Present' end
    , closedOrOpenStr       = case when (sj.completed  = 1) then 'Closed' else 'Open'    end
	, sj.openingPracId
     
  from dbo.SvcJournals        as sj
  join dbo.CLIENTS_Client     as cc  on cc.CLIENT_ID        = sj.clientID
  join dbo.PATIENTS_Patient   as pap on pap.PATIENT_ID      = sj.patID
  
  where
        ((sj.active = 1)
    and ((@clientID  is null) or (sj.clientID  = @clientID))
    and ((@patID     is null) or (sj.patID     = @patID))
    and ((@dos       is null) or (sj.dos       = @dos))
    and ((@completed is null) or (sj.completed = @completed))
    and ((@recID     is null) or (sj.id        = @recID)))  
)
,
cte_pass_2
as
(
  select 
    *
  , name       = p1.dos + ' - (' + p1.patAbsentOrPresentStr + ') - ' + p1.patName
  , isReopened = convert(bit,
                   (case 
                     when (completed = 0) and (hasRevisionID = 0) then 0
                     when (completed = 0) and (hasRevisionID = 1) then 1
                     when (completed = 1) and (hasRevisionID = 0) then 0
                     when (completed = 1) and (hasRevisionID = 1) then 0
                     else 0 
                   end)  
                 )
  , canEditStr = dbo.RPT_BIT_TO_YN(canEdit)

  
  from cte_pass_1 as p1
)

select * from cte_pass_2


)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[SvcJournal_Journals_View_Core] TO [webuser]
GO  
