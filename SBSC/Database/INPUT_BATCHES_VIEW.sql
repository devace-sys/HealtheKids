USE SPEDMON
GO

/*-------------------------------
* Exists/Drop
*------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.INPUT_BATCHES_VIEW') AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.INPUT_BATCHES_VIEW
GO

/*-------------------------------
* Object Definition
*------------------------------*/

CREATE FUNCTION [dbo].[INPUT_BATCHES_VIEW]    
(@recID        BIGINT,    
 @fileName     NVARCHAR(max),  
 @fileloc      NVARCHAR(max),  
 @STATUS       SMALLINT,
 @clientID     BIGINT,
 @workType     smallint,
 @assignedTo   Bigint,
 @active       BIT,    
 @canEdit      BIT)    
 
RETURNS TABLE  
 
 /***************************************************************************    
  * INPUT_BATCHES_VIEW */    
 /**    
  * Returns a table of INPUT_BATCHES that match the given parameters    
  *    
  * @param  filename        All or part of file name    
  * @param  active          If client is active
  * @param  recID           Client record id    
  * @return                 Table of INPUT_BATCHES data    
  ***************************************************************************/    
 
AS
RETURN          

/*-------------------------------    
 * Retrieve records  
 *------------------------------*/  

  ( 
  
  with UserCoreNameExtract(id, FirstName, LastName)
  AS
  (
      select id, firstName, lastName from
	  users.dbo.USERS_DATA_CORE( users.dbo.CONST_APP_NAME_SPEDCARE(),null,null,null,null)
      where (userGroupID = 2) /* SBSC Usergroup */
  )
  
    SELECT top (dbo.CONST_MAX_ROWS())
          ib.Priority_number            AS Priority,
          ib.File_Name                  AS FileName,        
		  st.STATUS,        
          [SoftwareOnlyBatch] = 
		    case when (ib.Date_Recieved is not null) then 
		      case when (dbo.IS_CLIENT_PAYING_PER_BATCH_AS_OF_REF_DATE (ib.ClientID, ib.Date_Recieved) = 1) 
			  then 
			    'Yes - NO WORK UNLESS AUTHORIZED' 
			  else 'No' end 
	        else 'No' end,
          t.WorkType,
          u1.firstname+' '+u1.lastname  AS AssignedTo,
          ib.Oldest_DOS                 AS OldestDateOfService,
          ib.Estimated_Input_Hours      AS EstimatedHours,
          ib.Degree_Of_Difficulty       AS Difficulty,
          cc.CLIENT_NAME                AS Client,
          ib.Date_Recieved              AS DateRecieved,
          ib.Date_Sent                  AS DateOnFile,
          ib.Current_Status_Date        AS FileRecordLastModified,                    
          ib.Current_status_Code        AS StatusCode,
          ib.Current_status_UserID1     AS User1,
          ib.Current_status_UserID2     AS User2,
          ib.Clientid,
          ib.Type_Of_Work               AS WorkTypeID,
          ib.id,
          ib.Partial_File               AS PartialFile,
          ib.ParentBatchID ,
          ib.active,
          u2.firstname+' '+u2.lastname  AS PreScreenedBy,
          ib.Notes,
          u3.firstname+' '+u3.lastname  AS LastUpdatedBy,  
          ib.File_Location              AS FileLocation,
          cc.CLIENT_CDS

   FROM dbo.INPUT_BATCHES                   as ib
   LEFT JOIN dbo.CLIENTS_client             as cc  on cc.Client_ID   = ib.ClientID
   LEFT JOIN dbo.Input_Batches_Status       as st  on st.Status_Code = ib.Current_status_Code                                      
   LEFT JOIN (SELECT top 1 Input_Batches_ID,Date_Updated,updatedBy FROM dbo.Input_Batches_Activity ORDER BY date_Updated DESC)
                                        AS iba ON iba.Input_Batches_ID = ib.id
   LEFT JOIN dbo.Type_of_work           AS t   ON t.id  = ib.type_of_work
   LEFT JOIN UserCoreNameExtract
                                        AS u1  ON u1.ID = ib.Current_status_UserID2
   LEFT JOIN UserCoreNameExtract
                                        AS u2  ON u2.ID = ib.Current_status_UserID1
   LEFT JOIN UserCoreNameExtract
                                        AS u3  ON u3.ID = iba.updatedBy
   WHERE (
          (ib.current_Status_code NOT IN (320,330,340)) /* We exclude tolarge, corrupted, deleted */    
      AND ((@STATUS        IS NULL)  OR (ib.current_Status_code    = @STATUS))            
      AND ((@clientID      IS NULL)  OR (ib.clientid               = @clientID))
      AND ((@workType      IS NULL)  OR (ib.Type_Of_Work           = @workType))
      AND ((@assignedTo    IS NULL)  OR (ib.Current_status_UserID2 = @assignedTo))
      AND ((@recID         IS NULL)  OR (ib.id                     = @recID))
      AND ((@active        IS NULL)  OR (ib.active                 = @active))
    --AND ((@fileloc       IS NULL)  OR (ib.file_location          = @fileloc))
      AND ((@filename      IS NULL)  OR (ib.file_name              = @filename))
    )
    ORDER BY filename
    --OldestDOS ,Priority,Client
)
         
GO

/*-------------------------------
* User Permissions
*------------------------------*/

GRANT SELECT ON  [dbo].[INPUT_BATCHES_VIEW] TO [webuser]
GO
