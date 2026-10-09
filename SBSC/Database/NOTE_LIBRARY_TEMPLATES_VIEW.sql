USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.NOTE_LIBRARY_TEMPLATES_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.NOTE_LIBRARY_TEMPLATES_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[NOTE_LIBRARY_TEMPLATES_VIEW] (
    @userID        as bigint    
  , @userGroup     as int  
  , @userRank      as int
  , @noteOwner     as bigint  
  , @noteNamespace as varchar(500)
  , @noteSource    as varchar(500)
  , @clientID      as bigint
  , @pracID        as bigint
  , @patID         as bigint
  , @referenceDate as date
  , @term          as varchar(50)
  , @active        as bit
  , @recID         as bigint
)    

RETURNS TABLE
 
 /***************************************************************************    
  * NOTE_LIBRARY_TEMPLATES_VIEW */    
 /**    
  * Returns 
  *
  * @return table 
  ***************************************************************************/                         
     
AS RETURN
(

select 
  nt.*
from dbo.NOTE_LIBRARY_TEMPLATES_VIEW_CORE( @userID
                                           ,@userGroup
                                           ,@userRank
                                           ,@noteOwner
                                           ,@noteNamespace
                                           ,@noteSource
                                           ,@clientID
                                           ,@pracID
                                           ,@patID
                                           ,@referenceDate
                                           ,@term 
                                           ,@active
                                           ,@recID) as nt
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[NOTE_LIBRARY_TEMPLATES_VIEW] TO [webuser]
GO  
