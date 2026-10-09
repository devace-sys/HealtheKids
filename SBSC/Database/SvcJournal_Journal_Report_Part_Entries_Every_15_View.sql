USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SvcJournal_Journal_Report_Part_Entries_Every_15_View') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SvcJournal_Journal_Report_Part_Entries_Every_15_View
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[SvcJournal_Journal_Report_Part_Entries_Every_15_View] (
    @userID            BIGINT
  , @userGroup         INT  
  , @userRank          INT
  , @clientID          BIGINT
  , @journalID         BIGINT
)    

RETURNS TABLE
 
 /***************************************************************************    
  * SvcJournal_Journal_Report_Part_Entries_Every_15_View */    
 /**    
  * Returns a list of journal entries
  *
  * @return table 
  ***************************************************************************/                         
     
AS RETURN
(

select 
  rowNum = ROW_NUMBER() over (order by eventStartTime, eventEndTime)
, dbo.RPT_TIME_FMT(eventStartTime,0)  as startTimeStr 
, dbo.RPT_TIME_FMT(eventEndTime,  0)  as endTimeStr
, eventLabel
, eventNotes
, pracName  

from dbo.SvcJournal_Journal_Service_Blocks_Every_15_View_Core (@userID,@userGroup,@userRank,@clientID,@journalID) as sb

)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[SvcJournal_Journal_Report_Part_Entries_Every_15_View] TO [webuser]
GO  
