USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SvcJournal_Journal_Report_Part_Prac_Supervisor_Notes_View') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SvcJournal_Journal_Report_Part_Prac_Supervisor_Notes_View
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[SvcJournal_Journal_Report_Part_Prac_Supervisor_Notes_View] (
    @userID            BIGINT
  , @userGroup         INT  
  , @userRank          INT
  , @clientID          BIGINT
  , @journalID         BIGINT
)    

RETURNS TABLE
 
 /***************************************************************************    
  * SvcJournal_Journal_Report_Part_Prac_Supervisor_Notes_View */    
 /**    
  * Returns a list of supervisor notes
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
      reviewedByName             as supervisingPrac
    , svcRecCreatedByName        as renderingPrac    
    , isnull(sra.reviewNotes,'') as reviewNotes
    
  from dbo.SvcJournal_Service_Records as sjsr 
  join dbo.SERVICE_RECORDS_APPROVAL   as sra on sra.svcRecID = sjsr.svcRecID
  where 
        (sjsr.journalID = @journalID) 
    and (sra.reviewedByNameRefID is not null)
)
,
cte_supervising_pracs_p2
as
(
  select * 
  from cte_supervising_pracs_p1 
  where (reviewNotes != '')
)

select * from cte_supervising_pracs_p2

)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[SvcJournal_Journal_Report_Part_Prac_Supervisor_Notes_View] TO [webuser]
GO  
