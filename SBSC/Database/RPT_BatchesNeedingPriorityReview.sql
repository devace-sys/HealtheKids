USE [SPEDMON]
GO
/****** Object:  UserDefinedFunction [dbo].[RPT_BatchesNeedingPriorityReview]    Script Date: 09/05/2018 13:42:01 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RPT_BatchesNeedingPriorityReview]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[RPT_BatchesNeedingPriorityReview]
GO

 
/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE  FUNCTION  [dbo].[RPT_BatchesNeedingPriorityReview]
(
)

   /* NO Report specific parameters here
   */

RETURNS TABLE
  /***************************************************************************
 * RPT_BatchesNeedingPriorityReview */
/**
 * Returns a table of report rows

 * @return                         Table of report rows
 ***************************************************************************/

 
 AS RETURN

 
 
 SELECT TOP (dbo.CONST_MAX_ROWS())
	  --'4.1 - HIGH PRIORITY Review'						as 'Section'
      isnull(uum.FirstName + ' ' + uum.LastName, '')	as 'Who put this here?'
      ,convert(date,iba.Date_Updated)					as 'When?'
      ,ib.File_Name										as 'File Name'
      ,wt.WorkType										as 'Type of Work'
      ,convert(date,ib.Oldest_DOS)						as 'Oldest DOS'
      ,convert(date,ib.Date_Recieved)					as 'Date Received'
      ,iba.FROM_STATUS									as 'From Status Code'
      ,iba.TO_STATUS									as 'To Status Code'
      ,ibss.Status										as 'To Status Name'
      ,ib.Current_status_Code							as 'Current Status Code'
      ,ibs.Status										as 'Current Status Name'
      ,ib.Notes											as 'Notes'
      ,ib.ParentBatchID									as 'Parent Batch ID'
	  ,cr.first_name + ' ' + cr.last_name				as 'Practi-Cal Consultant'
	
FROM dbo.INPUT_BATCHES						as ib
	join dbo.Input_Batches_Status			as ibs		on ibs.Status_Code = ib.Current_status_Code
	join CLIENTS_Client						as cc		on cc.CLIENT_ID = ib.ClientID
	join (select Input_Batches_ID, MAX(ID)  as last_recID from Input_Batches_Activity group by Input_Batches_ID) as last_entered_rec on ib.id = last_entered_rec.Input_Batches_ID
	join dbo.Input_Batches_Activity			as iba		on iba.ID = last_entered_rec.last_recID
	join dbo.TYPE_OF_WORK					as wt		on wt.id = ib.Type_Of_Work
	left outer join users.dbo.users			as uu		on uu.userrid = iba.AssignedTo
	left outer join users.dbo.Users			as uuu		on uuu.userrid = iba.UpdatedBy
	left outer join users.dbo.Membership	as uum		on uum.UserId = uuu.UserId
	left outer join users.dbo.Membership	as um		on um.UserId = uu.userid
	join dbo.CLIENTS_Client_Reps			as cr		on cr.id = cc.ClientRepIDLEACurrent
	join dbo.Input_Batches_Status			as ibss		on ibss.Status_Code = iba.TO_STATUS

WHERE 1=1
	AND ib.Current_status_Code in (80, 85,110,130)	--Batches needing high priority review
	--and iba.TO_STATUS in (80, 85, 110, 130)
	
    --AND ((@repID    IS NULL) OR (cc.ClientRepIDLEACurrent  = @repID)) 
    --AND ((@workType IS NULL) OR (wt.id = @workType))
	
ORDER by convert(date,iba.Date_Updated), Current_status_Code ,convert(date,ib.Date_Recieved), ib.File_Name, iba.Date_Updated

 
 
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[RPT_BatchesNeedingPriorityReview] TO [webuser]     
GO

--SELECT * FROM dbo.CLIENTS_Client cc where cc.ClientRepIDLEACurrent



--SELECT * FROM [dbo].[RPT_BatchesNeedingPriorityReview]()










