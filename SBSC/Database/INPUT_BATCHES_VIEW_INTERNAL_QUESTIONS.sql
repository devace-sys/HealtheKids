USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.INPUT_BATCHES_VIEW_INTERNAL_QUESTIONS') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.INPUT_BATCHES_VIEW_INTERNAL_QUESTIONS
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[INPUT_BATCHES_VIEW_INTERNAL_QUESTIONS]    
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

with userdata as
(
	select u.userrid, m.* from users.dbo.users u
	inner join users.dbo.membership m
		on u.userid = m.userid

)
	select ibvc.REFERENCE, CONVERT(date,OLDEST_DOS) as [Oldest DOS], QuestionAsked.*, AnswerProvided.*, ibvc.id as [id] from input_batches_view_core(null,null,null,null,null,null,null,null,null) ibvc
cross apply (select iba.Note as QuestionText, userdata.FirstName + ' ' + userdata.LastName as AskedBy, iba.Date_Updated as AskedOn, iba.id as questionActivityID
			from Input_Batches_Activity iba inner join userdata on iba.AssignedTo = userdata.userrid where iba.Input_Batches_ID = ibvc.id and TO_STATUS = 250) as QuestionAsked

outer apply (select top 1 iba.Note as AnswerText, userdata.FirstName + ' ' + userdata.LastName as AnsweredBy, iba.Date_Updated as AnsweredOn 
			from Input_Batches_Activity iba inner join userdata on iba.AssignedTo = userdata.userrid where iba.Input_Batches_ID = ibvc.id and TO_STATUS = 255 and Date_Updated > QuestionAsked.AskedOn) as AnswerProvided

where ibvc.Current_status_Code in (250) /* question-status set */
	and Answerprovided.AnsweredOn is null /* answer status not set */
	
	AND ((@clientID      IS NULL)  OR (ibvc.clientid               = @clientID))
    AND ((@workType      IS NULL)  OR (ibvc.Type_Of_Work           = @workType))
    AND ((@assignedTo    IS NULL)  OR (ibvc.Current_status_UserID2 = @assignedTo))
    AND ((@recID         IS NULL)  OR (ibvc.id                     = @recID))
    AND ((@active        IS NULL)  OR (ibvc.active                 = @active))
    AND ((@fileloc       IS NULL)  OR (ibvc.file_location          = @fileloc))
    AND ((@filename      IS NULL)  OR (ibvc.file_name              = @filename))
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[INPUT_BATCHES_VIEW_INTERNAL_QUESTIONS] TO [webuser]
GO
