USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTICE_OFFICE_VISITS_WAITING_ROOM_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PRACTICE_OFFICE_VISITS_WAITING_ROOM_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[PRACTICE_OFFICE_VISITS_WAITING_ROOM_VIEW]    
(   @userID              bigint
  , @userGroup           int  
  , @userRank            int   
  , @clientID            bigint
  , @groupSvcClassNameID bigint
  , @siteID              bigint
  , @patID               bigint
  , @pracID              bigint  
  , @completed           bit
  , @active              bit
  , @recID               bigint
)     
 
RETURNS TABLE    
 
 /***************************************************************************    
  * PRACTICE_OFFICE_VISITS_WAITING_ROOM_VIEW */    
 /**    
  * Returns a table of practice office visits that match the given parameters    
  *    
  *
  * IMPORTANT NOTE: This has to have the same signature (same parameters) as 
  * PRACTICE_OFFICE_VISITS_VIEW.
  *
  * @return  Table of practice office visits data    
  ***************************************************************************/     
  
AS RETURN (   
          
/*-------------------------------    
 * Retrieve records   
 *------------------------------*/     
 
select top (dbo.CONST_MAX_ROWS()) 
     povc.*  
from dbo.PRACTICE_OFFICE_VISITS_VIEW_CORE ( 
    @userID
  , @userGroup
  , @userRank 
  , @clientID 
  , @groupSvcClassNameID 
  , @siteID  
  , null /* @patID */
  , null /* @pracID*/
  , 0    /*@completed*/
  , 1    /*@active*/ 
  , null /*@recID*/ ) as povc

where (
       (povc.waiting = 1)
   and (povc.completed = 0)   
)

order by 
    povc.visiting asc  /* Visting last */
  , povc.id       asc /* Earliest first */
  

	
)    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PRACTICE_OFFICE_VISITS_WAITING_ROOM_VIEW] TO [webuser]
GO
