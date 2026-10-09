USE USERS
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.QFORMS_FOLLOWUP_LIST') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.QFORMS_FOLLOWUP_LIST
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[QFORMS_FOLLOWUP_LIST]()    
 
RETURNS TABLE      


/***************************************************************************    
 * QFORMS_FOLLOWUP_LIST */    
/**    
 * Returns a table of un-answered Info Request Response records that needs to be followed up
 *
 *     
 * @param  date            date requesting  
 * 
 * @return                 Table of IRR records that are not answered  
 ***************************************************************************/     
 
AS RETURN(      
    
/*-------------------------------    
 * Retrieve records   
 *------------------------------*/  
  
  select top (dbo.CONST_MAX_ROWS()) *
  from
  (
  select irr.*,
         ib.File_Name,
         ib.File_Location         
    from dbo.INFO_REQUEST_RESPONSE irr
    join SPEDMON.dbo.INPUT_BATCHES ib on ib.id = irr.ReferenceID and ib.Current_status_Code = 290
   where DATEADD(dd,14,SentOn) <= GETDATE() and 
         (FollowedUpOn is null or DATEADD(dd,7,FollowedUpOn) <= GETDATE()) and
         (Status = 10 or Status = 20 or Status = 30)
  ) as sd 
)
  
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[QFORMS_FOLLOWUP_LIST] TO [webuser]
GO
