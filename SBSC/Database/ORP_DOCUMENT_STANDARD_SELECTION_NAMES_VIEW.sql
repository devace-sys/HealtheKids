USE SPEDMON
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.ORP_DOCUMENT_STANDARD_SELECTION_NAMES_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.ORP_DOCUMENT_STANDARD_SELECTION_NAMES_VIEW
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[ORP_DOCUMENT_STANDARD_SELECTION_NAMES_VIEW] (
   @userID                    BIGINT
 , @userGroup                 INT  
 , @userRank                  INT 
 , @clientID                  BIGINT
 , @rdrGroupSvcClassNameID    BIGINT
 , @rdrGroupID                BIGINT
 , @rdrPracID                 BIGINT
 , @term                      VARCHAR(255)
 , @active                    BIT
 , @recID                     BIGINT)    
 
RETURNS TABLE
 
 /***************************************************************************    
  * ORP_DOCUMENT_STANDARD_SELECTION_NAMES_VIEW */    
 /**    
  * Returns a table of entities
  *    
  * @param   userID         The userid of who is requesting the operation
  * @param   userGroup      Users group    
  * @param   userRank       User rank      
  * @param   active         Active 0 = No 1 = Yes
  * @param   recID          Entity record id
  * @return                 Table of patient data    
  ***************************************************************************/     
 
AS RETURN
( 
  select top (dbo.CONST_MAX_ROWS())
    ssn.*         
  from dbo.ORP_DOCUMENT_STANDARD_SELECTION_NAMES_VIEW_CORE (
       @userID
     , @userGroup
     , @userRank
	 , @clientID
     , dbo.GET_ORP_SVC_CLASS_NAME_ID_FROM_MULTI (@rdrGroupSvcClassNameID, @rdrGroupID, @rdrPracID)
     , @active
     , @recID ) as ssn
  
  where ( 
       ssn.display = 1
    and ((@term is null) or (    (ssn.name  like '%' + @term + '%')
                              or (ssn.notes like '%' + @term + '%') /* Key words search */
                            ))
   
  )
  order by 
    ssn.name
)
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[ORP_DOCUMENT_STANDARD_SELECTION_NAMES_VIEW] TO [webuser]
GO