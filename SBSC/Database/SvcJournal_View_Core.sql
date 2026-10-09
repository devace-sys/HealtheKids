USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SvcJournal_View_Core') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SvcJournal_View_Core
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[SvcJournal_View_Core] (
    @userID            BIGINT
  , @userGroup         INT  
  , @userRank          INT      
  , @clientID          BIGINT
  , @patID             BIGINT
  , @startDate         DATETIME
  , @endDate           DATETIME
  , @completed         BIGINT
  , @journalID         BIGINT)    

RETURNS TABLE
 
 /***************************************************************************    
  * SvcJournal_View_Core */    
 /**    
  * Returns a list of journal entry data
  *
  * @return table 
  ***************************************************************************/                         
     
AS 
RETURN
(
with
cte_journal_journals
as
(
  select 
      id as [journalID]
    , clientName
    , clientID
    , patName
    , patID
    , patName + ' - ' + dos as [journalName]
    , dos
    , dosVal
    , patientAbsent
    , completed

  from dbo.SvcJournal_Journals_View_Core(@userID,@userGroup,@userRank,@clientID,@patID,null,@completed,@journalID)
  where dos between @startDate and @endDate
)
,
cte_journal_journals_and_journal_entries
as
(
  select 
      jj.*
    , je.* 
  from cte_journal_journals as jj
  cross apply (
    select 
        id        as [entryID]
      , name      as [entryName] 
      , startTime
      , startTimeVal
      , endTime
      , endTimeVal      
      , eventID 
      , eventLabel
      , notes
    from dbo.SvcJournal_Journal_Entries_View_Core (@userID,@userGroup,@userRank,@clientID, null, jj.journalID, null)    
  ) as je
)
,
cte_output 
as
(
  select 

      recNumber = DENSE_RANK() over (order by 
                                       clientName
                                     , clientID
                                     , patName
                                     
                                     
                                     
                                     , patID
                                     , dosVal
                                     , journalID
                                     )

    , recLine = ROW_NUMBER () over (partition by
                                       journalID                                      
                                    order by 
                                      clientName
                                    , clientID
                                    , patName
                                    , patID
                                    , dosVal
                                    , journalID
                                    , startTimeVal
                                    , endTimeVal
                                    )                                                                  
    , detailLine = ROW_NUMBER () over (partition by
                                         journalID
                                       , entryID                                      
                                    order by 
                                      clientName
                                    , clientID
                                    , patName
                                    , patID
                                    , dosVal
                                    , journalID
                                    , startTimeVal
                                    , endTimeVal
                                    )                                                                  

    , * 
  from cte_journal_journals_and_journal_entries
)
select top (dbo.CONST_MAX_ROWS()) 
    recNumber
  , recLine
  , detailLine
  , [Service]       = case (recLine)    when 1 then journalName    else '' end  
  , [Event]         = case (detailLine) when 1 then entryName      else '' end  
  , [Notes]         = case (detailLine) when 1 then notes          else '' end
from cte_output 
order by recNumber, recLine, detailLine
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[SvcJournal_View_Core] TO [webuser]
GO  

