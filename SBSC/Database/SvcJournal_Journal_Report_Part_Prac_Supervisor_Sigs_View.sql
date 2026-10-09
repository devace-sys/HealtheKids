USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SvcJournal_Journal_Report_Part_Prac_Supervisor_Sigs_View') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SvcJournal_Journal_Report_Part_Prac_Supervisor_Sigs_View
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[SvcJournal_Journal_Report_Part_Prac_Supervisor_Sigs_View] (
    @userID            BIGINT
  , @userGroup         INT  
  , @userRank          INT
  , @clientID          BIGINT
  , @journalID         BIGINT
)    

RETURNS TABLE
 
 /***************************************************************************    
  * SvcJournal_Journal_Report_Part_Prac_Supervisor_Sigs_View */    
 /**    
  * Returns a list of journal entries
  *
  * @return table 
  ***************************************************************************/                         
     
AS RETURN
(
with
cte_supervising_pracs_p1
as
(  
select 
*
from
(
  select 
      approved
    , reviewedByNameRefID as pracID
    , max(reviewedOn)     as dateTimeSigned
  from dbo.SvcJournal_Service_Records as sjsr 
  join dbo.SERVICE_RECORDS_APPROVAL   as sra on sra.svcRecID = sjsr.svcRecID
  where 
    (sjsr.journalID = @journalID)
  group by 
      approved
    , reviewedByNameRefID
) as q1
where 
  (pracID is not null)

)
,
cte_supervising_pracs_p2
as
(
  select 
     p1.approved
    ,p1.pracID 
    ,pp.CONCAT_NAME
    ,gg.GROUP_NAME_ABBREVIATION
    ,p1.dateTimeSigned
  from cte_supervising_pracs_p1 as p1
  join dbo.PRACTITIONER_Practitioner as pp on pp.PRACTITIONER_ID = p1.pracID
  join dbo.PRACTITIONER_GROUPS       as pg on pg.PRACTITIONER_ID = pp.PRACTITIONER_ID
  join dbo.GROUP_Group               as gg on gg.GROUP_ID        = pg.GROUP_ID
  where 
    pg.GROUP_TYPE in (1,2)
)

select  
    CONCAT_NAME                      as pracName
  , GROUP_NAME_ABBREVIATION          as pracType
  , approved                         as approved
  , dbo.RPT_BIT_TO_YN(approved)      as approvedStr  
  , 'Electronically Signed'          as pracSig
  , dbo.RPT_DATE_FMT(dateTimeSigned) as dateSignedStr
  , dateTimeSigned                   as dateTimeSigned
from cte_supervising_pracs_p2

)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[SvcJournal_Journal_Report_Part_Prac_Supervisor_Sigs_View] TO [webuser]
GO  
