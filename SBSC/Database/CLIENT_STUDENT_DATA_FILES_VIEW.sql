USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLIENT_STUDENT_DATA_FILES_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CLIENT_STUDENT_DATA_FILES_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[CLIENT_STUDENT_DATA_FILES_VIEW](      
  @recID       INT,    
  @clientID    INT,
  @fileTypeID  INT,
  @companyID   INT,
  @frequency   char, 
  @autoReq     BIT,
  @requestedBy BIGINT,    
  @active      BIT,
  @canEdit     BIT)    
 
RETURNS TABLE      

/***************************************************************************    
 * CLIENT_STUDENT_DATA_FILES_VIEW */    
/**    
 * Returns a table of CLIENT STUDENT DATA FILES that match the given parameters.    
 * Each client has one or more student data files.      
 *    
 * @param  clientID        ID of client   
 * @param  fileTypeID      ID of file Type
 * @param  company         Company requesting the file    
 * @param  frequency       Frequency of file request    
 * @param  active          If record is active
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
          co.name         AS COMPANY,
          ft.TYPE_NAME    AS FILE_TYPE,
          [REQUEST FREQUENCY] =
          CASE sdf.FREQUENCY
                     WHEN 'q' THEN 'Quarterly'
					 WHEN 'm' THEN 'Monthly'					 
					 END, 
          u.name          AS [REQUESTED_USER],					 
	      sdf.AUTO_REQUEST,
	      sdf.ACTIVE,    
          sdf.CLIENT_ID,
          sdf.COMPANY_ID,
          sdf.FILE_TYPE_ID,
          sdf.FREQUENCY,
          sdf.REQUESTED_BY AS [REQUESTED_USERID],
          sdf.id
          
  from  dbo.CLIENT_STUDENT_DATA_FILES as sdf
  left join  dbo.CLIENTS_Client              as c  on c.CLIENT_ID = sdf.CLIENT_ID
  left join  dbo.COMPANIES                   as co on co.id       = sdf.COMPANY_ID
  left join  dbo.STUDENT_DATA_FILE_TYPES     as ft on ft.id       = sdf.FILE_TYPE_ID
  left join users.dbo.USERS_DATA_CORE(users.dbo.CONST_APP_NAME_SPEDCARE(),null,null,null,null)
                                             as u  on  u.ID       = sdf.REQUESTED_BY
  ) as sd
  where   ((@recID       is null) or (sd.id               = @recID))      and
          ((@companyID   is null) or (sd.COMPANY_ID       = @companyID))  and
          ((@clientID    is null) or (sd.CLIENT_ID        = @clientID))   and
          ((@frequency   is null) or (sd.FREQUENCY        = @frequency))  and
          ((@fileTypeID  is null) or (sd.FILE_TYPE_ID     = @fileTypeID)) and
          ((@autoReq     is null) or (sd.AUTO_REQUEST     = @autoReq))    and                
          ((@requestedBy is null) or (sd.REQUESTED_USERID = @requestedBy))and                
          ((@active      is null) or (sd.Active           = @active))                     
          
  order by CLIENT_NAME
)
  
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CLIENT_STUDENT_DATA_FILES_VIEW] TO [webuser]
GO
