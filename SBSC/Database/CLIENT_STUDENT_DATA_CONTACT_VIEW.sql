USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLIENT_STUDENT_DATA_CONTACT_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CLIENT_STUDENT_DATA_CONTACT_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[CLIENT_STUDENT_DATA_CONTACT_VIEW](    
 
  @recID       INT,    
  @clientID    INT,
  @fileTypeID  INT,
  @canEdit     BIT)    
 
RETURNS TABLE      

/***************************************************************************    
 * CLIENT_STUDENT_DATA_CONTACT_VIEW */    
/**    
 * Returns a table of CLIENT STUDENT DATA CONTACT RECORDS that match the given parameters.    
 * Each client has one or more student data files.      
 *    
 * @param  clientID        ID of client    
 * @param  fileTypeID      ID of file Type
 * @param  canEdit         If practitioner can be edited by userID  
 * @param  recID           Student data file ID    
 * @return                 Table of Client student data files    
 ***************************************************************************/     
AS RETURN(      
    
/*-------------------------------    
 * Retrieve records   
 *------------------------------*/  
  
  select top (dbo.CONST_MAX_ROWS()) *
  from
  (
   select c.CLIENT_NAME,          
          ft.TYPE_NAME as FILE_TYPE,          
          sdc.CONTACT_LAST_NAME+', '+sdc.CONTACT_FIRST_NAME as CONTACT_NAME,
          sdc.EMAIL AS CONTACT_EMAIL,
          sdc.SECONDARY_CONTACT_EMAIL, 
          sdc.DATE_CREATED,
          sdc.CREATED_BY,
          sdc.id,
          sdc.CONTACT_FIRST_NAME,
          sdc.CONTACT_LAST_NAME,
          sdc.CLIENT_ID,
          sdc.FILE_TYPE_ID,
          sdc.NOTES
  from  dbo.CLIENT_STUDENT_DATA_CONTACT as sdc
  left join  dbo.CLIENTS_Client          as c  on c.CLIENT_ID = sdc.CLIENT_ID
  left join  dbo.STUDENT_DATA_FILE_TYPES as ft on ft.id       = sdc.FILE_TYPE_ID

  ) as sc
  where   ((@recID      is null) or (sc.id           = @recID))     and
          ((@clientID   is null) or (sc.CLIENT_ID    = @clientID))  and
          ((@fileTypeID is null) or (sc.FILE_TYPE_ID = @fileTypeID))

  order by CLIENT_NAME
)
  
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CLIENT_STUDENT_DATA_CONTACT_VIEW] TO [webuser]
GO
