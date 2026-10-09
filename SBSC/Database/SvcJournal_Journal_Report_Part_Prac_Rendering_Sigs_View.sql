USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SvcJournal_Journal_Report_Part_Prac_Rendering_Sigs_View') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SvcJournal_Journal_Report_Part_Prac_Rendering_Sigs_View
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[SvcJournal_Journal_Report_Part_Prac_Rendering_Sigs_View] (
    @userID            BIGINT
  , @userGroup         INT  
  , @userRank          INT
  , @clientID          BIGINT
  , @journalID         BIGINT
)    

RETURNS TABLE
 
 /***************************************************************************    
  * SvcJournal_Journal_Report_Part_Prac_Rendering_Sigs_View */    
 /**    
  * Returns a list of journal entries
  *
  * @return table 
  ***************************************************************************/                         
     
AS RETURN
(

with
cte_rendering_pracs_p1
as
(  
  select 
    pracID
   , max(lastEntered) as dateTimeSigned
  from
  (
    select 
       sjee.pracID                            as pracID
      ,isnull(sjee.lastModified,sjee.created) as lastEntered
    from dbo.SvcJournals              as sj
    join dbo.SvcJournal_Event_Entries as sjee on sjee.journalID = sj.id
    where 
        (sj.clientID = @clientID)
    and (sj.id       = @journalID)   
    and (sj.active   = 1)
    and (sjee.active = 1)
  ) as je
  group by pracID
)
,
cte_rendering_pracs_p2
as
(
  select 
     p1.pracID 
    ,pp.CONCAT_NAME
    ,gg.GROUP_NAME_ABBREVIATION
    ,p1.dateTimeSigned
  from cte_rendering_pracs_p1 as p1
  join dbo.PRACTITIONER_Practitioner as pp on pp.PRACTITIONER_ID = p1.pracID
  join dbo.PRACTITIONER_GROUPS       as pg on pg.PRACTITIONER_ID = pp.PRACTITIONER_ID
  join dbo.GROUP_Group               as gg on gg.GROUP_ID        = pg.GROUP_ID
  where 
    pg.GROUP_TYPE in (1,2)
)

select  
    CONCAT_NAME                      as pracName
  , GROUP_NAME_ABBREVIATION          as pracType
  , 'Electronically Signed'          as pracSig
  , dateTimeSigned                   as dateTimeSigned
  , dbo.RPT_DATE_FMT(dateTimeSigned) as dateSignedStr
from cte_rendering_pracs_p2

)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[SvcJournal_Journal_Report_Part_Prac_Rendering_Sigs_View] TO [webuser]
GO  
