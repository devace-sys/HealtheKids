USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.TRAINED_STAFF_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.TRAINED_STAFF_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[TRAINED_STAFF_VIEW]    
(
 @recID        BIGINT,      
 @workTypeID   bigint,
 @staffID      bigint,
 @isTrained    bit
 )    
 
 RETURNS TABLE    
 
 /***************************************************************************    
  * TRAINED_STAFF_VIEW */    
 /**    
  * Returns a table of TRAINED_STAFF that match the given parameters    
  *    
  * @param  worktypeID      worktype ID  
  * @param  staffID         staff ID  
  * @param  recID           Client record id    
  * @return                 Table of INPUT_BATCHES data    
  ***************************************************************************/     
  
AS RETURN(   
          
/*-------------------------------    
 * Retrieve records   
 *------------------------------*/     
 
   SELECT ts.staff_id,
          u.firstname+' '+u.lastname as StaffName,
          tw.id                      as WORKTYPE_ID,
          tw.WorkType,          
          tr.RATING,
          tr.RATE                   
  FROM [SPEDMON].dbo.TYPE_OF_WORK tw   
  join [dbo].[TRAINED_STAFF] ts on tw.id = ts.WORKTYPE_ID    
  left join users.dbo.USERS_DATA_CORE(users.dbo.CONST_APP_NAME_SPEDCARE(),null,null,null,null) as u on u.ID = TS.STAFF_ID
                                                                                    and accountIsLockedOut = 0
  left join dbo.STAFF_TRAINING_RATES tr on tr.RATING_ID = TS.RATING                            
  
  where ((@workTypeId   is null) or (ts.WORKTYPE_ID  = @workTypeID))
    and ((@staffId      is null) or (ts.staff_id     = @staffID))
    and ((@isTrained    is null) or (ts.TRAINED      = @isTrained))
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[TRAINED_STAFF_VIEW ] TO [webuser]
GO
