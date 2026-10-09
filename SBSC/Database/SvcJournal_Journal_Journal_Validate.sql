USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SvcJournal_Journal_Journal_Validate') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION SvcJournal_Journal_Journal_Validate
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[SvcJournal_Journal_Journal_Validate] (
    @userID            BIGINT
  , @userGroup         INT  
  , @userRank          INT
  , @clientID          BIGINT      
  , @journalID         BIGINT
)    

RETURNS TABLE
 
 /***************************************************************************    
  * SvcJournal_Journal_Journal_Validate */    
 /**    
  * Returns a list of problems with the journal
  *
  * @return table 
  ***************************************************************************/                         
     
AS RETURN
(
with

/*##########################################################################
  # Get journal
  ###########################################################################*/
  
cte_journal
as
(
  select top 1 * 
  from dbo.SvcJournals as sj 
  where (
          (sj.id      = @journalID) 
    and (sj.completed = 0) 
    and (sj.active    = 1) 
  )
)
,

/*##########################################################################
  # Get journal entries
  ###########################################################################*/

cte_journal_entries
as
(
select 
  sjee.* 
from cte_journal                   as sj
join dbo.SvcJournal_Event_Entries  as sjee on sjee.journalID = sj.id
where 
  (sjee.active = 1)
)
,

/*##########################################################################
  # Generate stats
  ###########################################################################*/

cte_stats
as
(
  select 
      numOf     = cne.numOf
    , patAbsent = cj.patAbsent
  from cte_journal as cj
  cross apply (
    select count(id) as numOf from cte_journal_entries where journalID = cj.id
  ) as cne
)
,

/*##########################################################################
  # Is the patient marked as absent
  # This might be normal, but warn user
  ###########################################################################*/

cte_absent
as
(
select 
    [retState] = dbo.CONST_RET_WARN()
  , [problem]  = case when (patAbsent = 1) then 'Patient was marked as absent' else null end 
from cte_stats
)
,

/*##########################################################################
  # Are there no entries 
  # This is not OK
  ###########################################################################*/

cte_no_entries
as
(
select 
    [retState] = dbo.CONST_RET_ERR()
  , [problem] = case when (numOf = 0) then 'There are no journal entries recorded' else null end
from cte_stats
)
,

/*##########################################################################
  # Combine results
  ###########################################################################*/

cte_combine
as
(
select 
    [journalID] = @journalID
  , [pracID]    = 0
  , [pracName]  = ''
  , * 
from
(
  select * from cte_absent
  union all  
  select * from cte_no_entries
  
) as p1
where (p1.problem is not null)

)

select 
  journalID
, pracID
, pracName
, retState 
, [retStatus] = case 
    when retState = dbo.CONST_RET_WARN() then  'Warning'
    when retState = dbo.CONST_RET_ERR()  then  'Problem'
    else '' 
  end
, problem
from cte_combine

)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[SvcJournal_Journal_Journal_Validate] TO [webuser]
GO  
