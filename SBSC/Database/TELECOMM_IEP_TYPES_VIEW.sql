USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.TELECOMM_IEP_TYPES_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION TELECOMM_IEP_TYPES_VIEW
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[TELECOMM_IEP_TYPES_VIEW] (
 @userID              BIGINT,    
 @userGroup           BIGINT,    
 @userRank            INT, 
 @term                varchar(256),
 @recID               BIGINT,
 @canEdit             BIT,
 @active              BIT
 )    
 
RETURNS TABLE
 
 /***************************************************************************    
  * TELECOMM_IEP_TYPES_VIEW */    
 /**    
  * Returns a table of IEP types
  *    
  * @param   userID         The userid of who is requesting the operation
  * @param   userGroup      Users group    
  * @param   userRank       User rank      
  * @param   term           name of iep type
  * @param   recID          Entity record id
  * @param   canEdit        
  * @param   active         Active 0 = No 1 = Yes
  * @return                 Table of IEP Types    
  ***************************************************************************/     
 
AS RETURN
(
 
select top (dbo.CONST_MAX_ROWS())

    id  
  , [name]
  , formName = [name]
  , formsHTML
  , formsJSON
  , active   

from dbo.TELECOMM_IEP_TYPES  as t1
where (
      (1=1)
  and ((@term is null) or ([name] like (isnull(@term,'') + '%')))  
  and ((@active    is null)  or (t1.active  = @active))
  and ((@recID     is null)  or (t1.id      = @recID))
)

)

GO

GRANT SELECT ON  [dbo].[TELECOMM_IEP_TYPES_VIEW] TO [webuser]
GO
