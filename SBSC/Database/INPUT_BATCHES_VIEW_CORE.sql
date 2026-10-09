USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.INPUT_BATCHES_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.INPUT_BATCHES_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[INPUT_BATCHES_VIEW_CORE]    
(
@recID        BIGINT,    
 @fileName     NVARCHAR(max),  
 @fileloc      NVARCHAR(max),  
 @STATUS       SMALLINT,
@clientID     BIGINT,
@workType     smallint,
@assignedTo   Bigint,
@active       BIT,    
 @canEdit      BIT
)    
 
 RETURNS TABLE    
 
 /***************************************************************************    
  * INPUT_BATCHES_VIEW_CORE */    
 /**    
  ***************************************************************************/     
  
AS RETURN(  
	select ib.*, cc.client_name, tw.worktype as Type_of_Work_Name, ibs.status as Status_Code_Name, ISNULL(m.firstname + ' ' + m.lastName,'') as Updating_UserName,
	isnull(m2.firstname + ' ' + m2.lastName,'') as Assigned_UserName, replace(ib.File_Name,'.pdf','') as REFERENCE
	
	 from input_batches ib
	left outer join clients_client cc
		on ib.clientID = cc.client_id
	left outer join type_of_work tw
		on ib.type_of_work = tw.id
	left outer join Input_Batches_Status ibs
		on ib.current_status_code = ibs.Status_Code
	left outer join users.dbo.users u
		on ib.Current_status_UserID1 = u.userrid
	left outer join users.dbo.membership m
		on u.userid = m.userid
		
		
	left outer join users.dbo.users u2
		on ib.Current_status_UserID2 = u2.userrid
		
	left outer join users.dbo.membership m2
		on u2.userid = m2.userid		
		
	where
	    ((@STATUS        IS NULL)  OR (ib.current_Status_code    = @STATUS))
    AND ((@clientID      IS NULL)  OR (ib.clientid               = @clientID))
    AND ((@workType      IS NULL)  OR (ib.Type_Of_Work           = @workType))
    AND ((@assignedTo    IS NULL)  OR (ib.Current_status_UserID2 = @assignedTo))
    AND ((@recID         IS NULL)  OR (ib.id                     = @recID))
    AND ((@active        IS NULL)  OR (ib.active                 = @active))
    AND ((@fileloc       IS NULL)  OR (ib.file_location          = @fileloc))
    AND ((@filename      IS NULL)  OR (ib.file_name              = @filename))
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[INPUT_BATCHES_VIEW_CORE] TO [webuser]
GO
