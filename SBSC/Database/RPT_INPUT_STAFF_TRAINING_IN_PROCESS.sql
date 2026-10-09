USE [SPEDMON]
GO
/****** Object:  UserDefinedFunction [dbo].[RPT_INPUT_STAFF_TRAINING_IN_PROCESS]    Script Date: 09/05/2018 13:42:01 ******/

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RPT_INPUT_STAFF_TRAINING_IN_PROCESS]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[RPT_INPUT_STAFF_TRAINING_IN_PROCESS]
GO

 
/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE  FUNCTION  [dbo].[RPT_INPUT_STAFF_TRAINING_IN_PROCESS]
(
@staffID bigint
)
 /* Report specific parameters here seperated by commas 
   */

RETURNS TABLE
  /***************************************************************************
  * RPT_INPUT_STAFF_TRAINING_IN_PROCESS */
 /**
 * Returns a table of report rows
 *
 * @param   staffID          filter by Input Staff ID.
 * @return                   Table of report rows
 ***************************************************************************/

 
 AS RETURN
 --THIS IS AN INLINE TVF/UDF BECAUSE THE SYNTAX USED IS "AS RETURN".  WE CANNOT "DECLARE" ANY VARIABLES.


 SELECT  TOP (dbo.CONST_MAX_ROWS())
	  --'6 - Training In Process'						as 'Training in Process'
	   userdata.staffname								as 'Staff_Name'
	  , ISNULL(worktype, '')							as 'Currently_training_on'
	  , train.rate										as '%_Trained'
	  , ISNULL (rating, 'No Active Training')			as 'Skill_level'
	  ,(
		select 
			ISNULL(CONVERT(varchar(max),MAX(CONVERT(date,iba.Date_Updated))),'')
		from
			Input_Batches_Activity						as iba
			inner join INPUT_BATCHES					as ib 
				on iba.Input_Batches_ID = ib.id

		where 
			iba.UpdatedBy = userdata.userrid
			and ib.Type_Of_Work = train.workTypeID
			and iba.TO_STATUS = 70 /* Input Started */
		)												as 'Last_date_user_started_on_a_batch_of_this_type'

FROM
	(select u.userrid, m.LastName + ', ' + m.FirstName as staffname , u.UserName FROM Users.dbo.Users u
	inner join Users.dbo.Membership m on m.UserId = u.UserId and SBSC_Employee = 1
	inner join Users.dbo.UsersInRoles uir on m.UserId = uir.UserId
	inner join Users.dbo.Roles r on uir.RoleId = r.RoleId and  (r.RoleName like '%input%' or r.RoleName like '%Leade%')
		WHERE 1=1
			and UserName not like '%quit%'
			and m.IsLockedOut = 0
			and m.FirstName + ' ' + m.LastName NOT like '%Spitsyn%'
			and m.FirstName + ' ' + m.LastName NOT like '%COTA%'
			and m.FirstName + ' ' + m.LastName NOT like '%SLPA%'
			and m.FirstName + ' ' + m.LastName NOT like '%FreeCare%'
			and m.FirstName + ' ' + m.LastName NOT like '%PersonalCare%'
			
	) as userdata
	outer apply (
		select TYPE_OF_WORK.WorkType, strat.RATING, strat.RATE, TYPE_OF_WORK.id as workTypeID
		FROM TRAINED_STAFF as ts
			inner join TYPE_OF_WORK on ts.WORKTYPE_ID = TYPE_OF_WORK.id
			inner join STAFF_TRAINING_RATES strat on ts.RATING = strat.RATING_ID
		WHERE
			ts.STAFF_ID = userdata.userrid
			and ts.WORKTYPE_ID = TYPE_OF_WORK.id
			AND ((@staffID IS NULL) OR (ts.STAFF_ID= @staffID))
			and strat.RATE not in (1,0)
	) as train
		WHERE train.RATE is not null
ORDER by staffname, RATE desc, WorkType
 GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[RPT_INPUT_STAFF_TRAINING_IN_PROCESS] TO [webuser]     
GO




--SELECT * FROM [dbo].[RPT_INPUT_STAFF_TRAINING_IN_PROCESS](null)










