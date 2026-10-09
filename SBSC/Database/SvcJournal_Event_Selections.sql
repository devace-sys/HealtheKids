USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SvcJournal_Event_Selections') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SvcJournal_Event_Selections
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[SvcJournal_Event_Selections] (
    @userID        bigint    
  , @userGroup     int  
  , @userRank      int
  , @noteNamespace varchar(500)
  , @noteSource    varchar(500)
  , @isDefault     bit
  , @journalID     bigint
  , @pracID        bigint
  , @term          varchar(255)
  , @recID         int
)    

RETURNS TABLE
 
 /***************************************************************************    
  * SvcJournal_Event_Selections */    
 /**    
  * Returns a list of event selections
  *
  * @return table 
  ***************************************************************************/                         
     
AS RETURN
(

select * 
from dbo.SvcJournal_Event_Selections_Core (  @userID
                                           , @userGroup
                                           , @userRank
                                           , @noteNamespace
                                           , @noteSource
                                           , @isDefault
                                           , @journalID
                                           , @pracID
                                           , @term
                                           , @recID)

)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[SvcJournal_Event_Selections] TO [webuser]
GO  
