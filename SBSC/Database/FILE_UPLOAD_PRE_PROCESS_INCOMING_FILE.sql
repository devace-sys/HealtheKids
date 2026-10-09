USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.FILE_UPLOAD_PRE_PROCESS_INCOMING_FILE') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.FILE_UPLOAD_PRE_PROCESS_INCOMING_FILE
GO


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE dbo.FILE_UPLOAD_PRE_PROCESS_INCOMING_FILE ( 
    @userID                   bigint
  , @userGroup                int
  , @userRank                 int
  , @environmentID            bigint  
  , @uploadID                 bigint
)
AS
BEGIN

declare @fileAsName as varchar(8000)
declare @today      as datetime
declare @statusID   as bigint 

set @today = GETDATE()

/*###########################################################################
  # Indicate pre processing occurred
  ###########################################################################*/       

exec dbo.FILE_UPLOAD_SET_STATUS @uploadID, @today, @userID, 290, null, null, null, @statusID output


return (0)  

END
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
                         
GRANT EXECUTE ON  [dbo].[FILE_UPLOAD_PRE_PROCESS_INCOMING_FILE] TO [webuser]
GO