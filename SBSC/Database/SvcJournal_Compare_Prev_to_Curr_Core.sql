USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SvcJournal_Compare_Prev_to_Curr_Core') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION SvcJournal_Compare_Prev_to_Curr_Core
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[SvcJournal_Compare_Prev_to_Curr_Core] (
    @userID            BIGINT
  , @userGroup         INT  
  , @userRank          INT
  , @clientID          BIGINT      
  , @journalID         BIGINT
  , @revisionID        BIGINT
)    

RETURNS TABLE
 
 /***************************************************************************    
  * SvcJournal_Compare_Prev_to_Curr_Core */    
 /**    
  * Returns a list of problems with the journal
  *
  * @return table 
  ***************************************************************************/                         
     
AS RETURN
(
with

/*============================================================
 * Previous Header
 *============================================================*/  

cte_prev_header
as
(
select
   id
 , dos
 , patID
 , patAbsent
 , active
 , chksum = CHECKSUM (
      id
    , patID
    , dos
    , patAbsent
    , active
  )
from dbo.SvcJournals_Revisions 
where 
      (id         = @journalID) 
  and (revisionID = @revisionID)
)
,

/*============================================================
 * Current Header
 *============================================================*/  

cte_curr_header
as
(
select
   id
  ,dos
  ,patID
  ,patAbsent
  ,active
  ,chksum = CHECKSUM (
      id
    , patID
    , dos
    , patAbsent
    , active
  )
from dbo.SvcJournals
where 
  (id = @journalID)
)
,

/*============================================================
 * Previous Time Blocks
 *============================================================*/  

cte_prev_time_blocks
as
(
select    
    journalID
  , patID
  , dos
  , patAbsent
  , contBlock
  , pracID
  , nameID
  , iep
  , procID
  , numMins
  , startTime
  , endTime
  , eventTypeID
  , entryNotes
  , orpDocID
  , chksum = CHECKSUM (
      journalID
    , patID
    , dos
    , patAbsent
    , contBlock
    , pracID
    , nameID
    , iep
    , procID
    , numMins
    , startTime
    , endTime
    , eventTypeID    
    , entryNotes
    , orpDocID
  )
from dbo.SvcJournal_Service_Records_Time_Blocks_Revisions as tbp
join dbo.SvcJournals_Revisions                            as sjp on  sjp.id         = tbp.journalID
                                                                 and sjp.revisionID = tbp.revisionID
where 
      ((tbp.journalID  = @journalID) 
  and  (tbp.revisionID = @revisionID))
)
,

/*============================================================
 * Current Time Blocks
 *============================================================*/  

cte_curr_time_blocks
as
(
select
    journalID
  , patID
  , dos
  , patAbsent
  , contBlock
  , pracID
  , nameID
  , iep
  , procID
  , numMins
  , startTime
  , endTime
  , eventTypeID
  , entryNotes
  , orpDocID
  , chksum = CHECKSUM (
      journalID
    , patID
    , dos
    , patAbsent
    , contBlock
    , pracID
    , nameID
    , iep
    , procID
    , numMins
    , startTime
    , endTime
    , eventTypeID
    , entryNotes
    , orpDocID
  )

from dbo.SvcJournal_Journal_Service_Blocks_And_Procedure_Data_View_Core(  @userID
                                                                         ,@userGroup
                                                                         ,@userRank
                                                                         ,@clientID
                                                                         ,@journalID)

)
,

/*============================================================
 * In Prev and Curr Header
 *============================================================*/  

cte_in_prev_and_curr_headers
as
(
select 
    Header = 1  
  , Block  = 0
  , Prev   = 1
  , Curr   = 1
  , p.id        as journalID
  , p.patID     as patID
  , p.dos       as dos
  , p.patAbsent as patAbsent
  , null        as contBlock
  , null        as pracID
  , null        as nameID
  , null        as iep
  , null        as procID
  , null        as numMins
  , null        as startTime
  , null        as endTime
  , null        as eventTypeID
  , null        as entryNotes
  , null        as orpDocID
  , p.chksum    as chksum
from cte_prev_header as p
join cte_curr_header as c on c.chksum = p.chksum
)
,

/*============================================================
 * In Previous and Current Time Blocks
 *============================================================*/  

cte_in_prev_and_curr_time_blocks
as
(
select 
    Header = 0  
  , Block  = 1  
  , Prev   = 1
  , Curr   = 1
  , p.* 
from cte_prev_time_blocks as p
join cte_curr_time_blocks as c on c.chksum = p.chksum
)
,

/*============================================================
 * In Previous But Not In Current Time Blocks
 *============================================================*/  

cte_in_prev_not_in_curr_time_blocks
as
(
select 
    Header = 0  
  , Block  = 1  
  , Prev   = 1
  , Curr   = 0
  , p.* 
from      cte_prev_time_blocks as p
left join cte_curr_time_blocks as c on c.chksum = p.chksum
where c.chksum is null
)
,

/*============================================================
 * In Current But Not In Previous Time Blocks
 *============================================================*/  

cte_in_curr_not_in_prev_time_blocks
as
(
select 
    Header = 0  
  , Block  = 1  
  , Prev   = 0
  , Curr   = 1
  , c.* 
from      cte_curr_time_blocks as c
left join cte_prev_time_blocks as p on p.chksum = c.chksum
where p.chksum is null
)
,

/*============================================================
 * Output
 *============================================================*/  

cte_output
as
(
          select * from cte_in_prev_and_curr_headers
union all select * from cte_in_prev_and_curr_time_blocks
union all select * from cte_in_prev_not_in_curr_time_blocks
union all select * from cte_in_curr_not_in_prev_time_blocks
)

select * from cte_output

)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[SvcJournal_Compare_Prev_to_Curr_Core] TO [webuser]
GO  
