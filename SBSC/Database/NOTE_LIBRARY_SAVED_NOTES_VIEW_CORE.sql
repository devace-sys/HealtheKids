USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.NOTE_LIBRARY_SAVED_NOTES_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.NOTE_LIBRARY_SAVED_NOTES_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[NOTE_LIBRARY_SAVED_NOTES_VIEW_CORE] (

    @userID        as bigint    
  , @userGroup     as int  
  , @userRank      as int
  , @noteOwner     as bigint
  , @noteNamespace as varchar(500)
  , @noteSource    as varchar(500)
  , @clientID      as bigint
  , @pracID        as bigint
  , @patID         as bigint
  , @term          as varchar(50)
  , @active        as bit
  , @recID         as bigint
)    

RETURNS TABLE
 
 /***************************************************************************    
  * NOTE_LIBRARY_SAVED_NOTES_VIEW_CORE */    
 /**    
  * Returns 
  *
  * @return table 
  ***************************************************************************/                         
     
AS RETURN
(
with
cte_p1
as
(
select 
  *
  , [noteTitle] = left(noteText,100) + '...' 
  , [canDelete] = case noteOwner when @userID then 1 else 0 end
from dbo.NOTE_LIBRARY_SAVED_NOTES as sn
where
       (sn.noteNamespace = @noteNamespace)
   and (sn.noteSource    = @noteSource)
   and (sn.clientID      = @clientID)
   and ((@pracID  is null) or (sn.pracID = @pracID))
   and ((@patID  is null) or (sn.patID  = @patID))  
   and ((@active is null) or (sn.active = @active))
)
,
cte_p2
as
(
select 
  sn.*
  , [name]     = noteTitle
  , [notes]    = noteText
  , [context1] = 'Note for ' + pap.CONCAT_NAME  
from cte_p1                as sn
join dbo.PATIENTS_Patient  as pap on pap.PATIENT_ID = sn.patID
where 
   (1=1)
   and ((@term is null) or (sn.noteText like ((@term + '%'))))
)
select * from cte_p2

)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[NOTE_LIBRARY_SAVED_NOTES_VIEW_CORE] TO [webuser]
GO  
