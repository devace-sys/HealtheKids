USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.STUDENT_DATA_FILES_TO_REQUEST') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.STUDENT_DATA_FILES_TO_REQUEST
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[STUDENT_DATA_FILES_TO_REQUEST](      
  @date      datetime,
  @quarter1  datetime,
  @quarter2  datetime,
  @quarter3  datetime,
  @quarter4  datetime,
  @frequency char)    
 
RETURNS TABLE      


/***************************************************************************    
 * STUDENT_DATA_FILES_TO_REQUEST */    
/**    
 * Returns a table of student data files and client contact info.      
 *    
 * @param  date            date requesting  
 * @return                 Table of Client student data files    
 ***************************************************************************/     
AS RETURN(      
    
/*-------------------------------    
 * Retrieve records   
 *------------------------------*/  
  
  select top (dbo.CONST_MAX_ROWS()) *
  from
  (
   select 
      cc.CONTACT_FIRST_NAME,
      cc.CONTACT_LAST_NAME,
      cc.EMAIL                   AS CONTACT_EMAIL,
      cc.SECONDARY_CONTACT_EMAIL,
      u.username                 AS CLIENT_REP_EMAIL,
      c.CLIENT_ID,
      c.CLIENT_NAME,
      sdf.FILE_TYPE_ID,
      sdf.AUTO_REQUEST,
      [QUARTER] =
      CASE 
         WHEN @date >= @quarter1 and @date < @quarter2 THEN 1
		 WHEN @date >= @quarter2 and @date < @quarter3 THEN 2
		 WHEN @date >= @quarter3 and @date < @quarter4 THEN 3
		 WHEN @date >= @quarter4 and @date < dateadd(mm,3,@quarter4) THEN 4					 
	  END          
	  from dbo.CLIENT_STUDENT_DATA_FILES   as sdf  
	  join dbo.CLIENT_STUDENT_DATA_CONTACT as cc on cc.CLIENT_ID    = sdf.CLIENT_ID and 
	                                                cc.FILE_TYPE_ID = sdf.FILE_TYPE_ID
	  join dbo.CLIENTS_Client              as c  on c.CLIENT_ID     = sdf.CLIENT_ID
	  left join dbo.CLIENTS_Client_Reps    as cr on cr.id           = c.ClientRepIDLEACurrent
	  left join users.dbo.USERS_DATA_CORE(users.dbo.CONST_APP_NAME_SPEDCARE(),null,null,null,null)	  
                                           as u  on  u.ID           = cr.user_id
	  where (((@frequency is null) or (sdf.FREQUENCY = @frequency)) and sdf.ACTIVE = 1)
  ) as sd 
)
  
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[STUDENT_DATA_FILES_TO_REQUEST] TO [webuser]
GO
