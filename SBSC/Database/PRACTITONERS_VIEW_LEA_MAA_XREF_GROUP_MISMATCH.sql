USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTITONERS_VIEW_LEA_MAA_XREF_GROUP_MISMATCH') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PRACTITONERS_VIEW_LEA_MAA_XREF_GROUP_MISMATCH
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[PRACTITONERS_VIEW_LEA_MAA_XREF_GROUP_MISMATCH](@clientID INT)    
 
RETURNS TABLE      

/***************************************************************************    
 * PRACTITIONERS_VIEW_LEA_MAA_XREF_GROUP_MISMATCH */    
/**    
 * Returns a table of practitioners that currently:
 *
 * - are common between LEA and MAA
 * - are active in both programs
 * - are coded as "not MAA" in LEA
 *    
 * @param  clientID        ID of client 
 * @return                 Table of practitioner data    
 ***************************************************************************/     

AS RETURN(      
    
/*-------------------------------    
 * Retrieve records   
 *------------------------------*/  

select top (dbo.CONST_MAX_ROWS()) q2.*
from
(
  select 
    
    q1.*
     
    from
    (
      select       
        pl.[LEA Client],
        pl.[LEA Practitioner],
        pl.[LEA Practitioner Group Name],
        pl.[MAA Client],
        pl.[MAA Participant],                 
        pl.[LEA Client ID],
        pl.[LEA Practitioner ID],   
        pl.[LEA Practitioner Group ID],
        pl.[MAA Client ID],
        pl.[MAA Participant ID]
        
      from dbo.PRACTITONERS_VIEW_LEA_MAA_XREF_CORE(@clientID,1,null) as pl

     /*-------------------------------    
      * Practitioners/participants that
      * are considered issues are:
      *
      * - Active LEA
      * - Active MAA
      *------------------------------*/  

    where
    
     (([MAA Active] = 1) and ([LEA Active] = 1))
        
    ) as q1
  ) as q2
  order by [LEA Client] desc
)

GO

/*-------------------------------
 * User Permissions
 *
 * Note: This script also 
 * requires the permissions
 * that are setup in:
 *
 * spedmon\batch\restore\
 * restore-partner-databases.sql
 *------------------------------*/
 
GRANT SELECT ON [dbo].[PRACTITONERS_VIEW_LEA_MAA_XREF_GROUP_MISMATCH] TO [webuser]
GO



