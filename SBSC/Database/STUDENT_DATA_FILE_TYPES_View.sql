USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('STUDENT_DATA_FILE_TYPES_View') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION STUDENT_DATA_FILE_TYPES_View
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[STUDENT_DATA_FILE_TYPES_View](     
  @recID       INT,      
  @active      BIT,
  @canEdit     BIT)    
 
RETURNS TABLE      

/***************************************************************************    
 * STUDENT_DATA_FILE_TYPES_View */    
/**    
 * Returns a table of CLIENT STUDENT DATA CONTACT RECORDS that match the given parameters.    
 * Each client has one or more student data files.      
 *    
 * @param  active          If practitioner is active
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
   select *  from dbo.STUDENT_DATA_FILE_TYPES  as sd  
  ) as sc
  
  where ((@recID  is null) or (sc.id     = @recID)) AND
        ((@active is null) or (sC.ACTIVE = @active))

  order by TYPE_NAME
)
  
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[STUDENT_DATA_FILE_TYPES_View] TO [webuser]
GO
