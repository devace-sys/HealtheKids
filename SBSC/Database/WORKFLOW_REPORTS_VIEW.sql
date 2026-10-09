USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('WORKFLOW_REPORTS_VIEW') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.WORKFLOW_REPORTS_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
  
CREATE PROCEDURE [dbo].[WORKFLOW_REPORTS_VIEW](@reportNum bigint) as   
BEGIN

--*************To get today
DECLARE @Today DATE
	Set @Today = GETDATE()
--*************To get A YEAR before today
DECLARE @YearAgoToday DATE
	Set @YearAgoToday = DATEADD(year,-1, GETDATE())
--*************To get "Week Start Date" (Sunday) for THIS week
DECLARE @LastSunday DATE
	Set @LastSunday = DATEADD(wk,DATEDIFF(wk,7,GETDATE()),6)
--*************To get "Week Start Date" (Sunday) for NEXT week
DECLARE @NextSunday DATE
	Set @NextSunday = DATEADD(wk,DATEDIFF(wk,0,GETDATE()),6)
--*************To get 320 days before today for thing like a list of batches for priority input
DECLARE @AgingDate DATE
	Set @AgingDate = DATEADD(day,-320, GETDATE())
--*************To get a month after today
DECLARE @YearAgoTodayPLUS1Mo DATE
	Set @YearAgoTodayPLUS1Mo = DATEADD(month,1, @YearAgoToday)
--*************To get the last day of NEXT month LAST year
DECLARE @AgeOutCheck DATE
	Set @AgeOutCheck = DATEADD(mm, DATEDIFF(mm, 0, @YearAgoTodayPLUS1Mo)+1, -1)
--*************To get the first day of THIS month LAST year
DECLARE @FirstDayThisMoLastYear DATE
	Set @FirstDayThisMoLastYear = DATEADD(month, DATEDIFF(month, 0, @YearAgoToday), 0) --AS StartOfMonth
--*************To get the most recent past January 1
DECLARE @Year VARCHAR (10)
DECLARE @LatestJanuary DATE
	SET @Year=(DATEPART (YYYY, GETDATE()))
	SET @LatestJanuary = ('01/01/'+@Year)
--*************To get the January 1 two years before the most recent past January 1
DECLARE @TriennialJanuary DATE
	Set @TriennialJanuary = DATEADD(year,-2, @LatestJanuary)
--*************To get the most recent past July 1
DECLARE @LatestJuly DATE
	Set @LatestJuly = 
			CASE 
				WHEN @Today >= ('07/01/' + @Year)
				THEN ('07/01/' + @Year)
				ELSE DATEADD (Year,-1,('07/01/' + @Year))
				END
--*************To get the January 1 two years before the most recent past July 1
DECLARE @TriennialJuly DATE
	Set @TriennialJuly = DATEADD(year,-2, @LatestJuly)


	IF @reportNum IS NULL
	BEGIN
	/* Display reports and values */
				SELECT 1 as repValue, 'All Clients' as repName
		UNION	select 2 as repValue, 'Batches (Count by Status)'
		UNION	select 3 as repValue, 'Batches (Count by Work Type)'
		UNION	select 4 as repValue, 'Batches (List in Process)'
		UNION	select 5 as repValue, 'Batches (Assigned Work NOT Done)'
		UNION	select 6 as repValue, 'Batches (HIGH PRIORITY Review)'
		UNION	select 7 as repValue, 'Batches (Aging Work)'
		UNION	select 8 as repValue, 'Workers (Training In Process)'
		UNION	select 9 as repValue, 'Batches (FIFO)'
		UNION	select 10 as repValue, 'Workers (Training & Scheduling)'
		UNION	select 11 as repValue, 'Workers (Untrained by Types)'
		UNION	select 12 as repValue, 'Batches (Historical View)'
		UNION	select 13 as repValue, 'Batches (Not Billable)'
		UNION	select 14 as repValue, 'Batches (Qforms)'
		UNION	select 15 as repValue, 'Batches (Qforms (No A))'
		UNION	select 16 as repValue, 'Batches (Received by Date)'
		UNION	select 17 as repValue, 'Batches (Lag in Receipt)'
		
		
	
	END
	
	/* All Clients */
	if @reportNum = 1
	BEGIN 
	select * from CLIENTS_Client
	END
	
	if @reportNum = 2
	BEGIN
	SELECT
	'1 - Count by Status'														as 'Section'
	,ibs.Status_Code															as 'Status Code'
	,ibs.Status																	as 'Current Status Description'
	,COUNT(ib.id)																as '# of Batches'
	,isnull(SUM(ib.Estimated_Input_Hours),0)									as 'Hours'
	,isnull(convert(varchar(10),convert(date,MIN(ib.Date_Recieved))),0)			as 'Oldest Date Received'
	,isnull(convert(varchar(10),convert(date,MIN(ib.Oldest_DOS))),0)			as 'Oldest DOS'

FROM dbo.Input_Batches_Status			as ibs
	left outer join dbo.Input_Batches	as ib		on ibs.Status_Code = ib.Current_status_Code

WHERE 1=1
	and ibs.Status_Code in (10,30,50,60,70,80,90,100,110,130,85)		--Batches currently in Process
	
GROUP by ibs.Status_Code,ibs.Status --Current_status_Code, ib.Current_status_Code, ibs.Status 

order by ibs.Status_Code --convert(integer, ib.Current_status_Code), ib.Current_status_Code, ibs.Status 
	END
	
	if @reportNum = 3
	BEGIN
	SELECT
	'2 - Count by Work Type'																	as 'Section'
	,COUNT(ib.id)																as '# of Batches'
	,isnull(SUM(ib.Estimated_Input_Hours),0)									as 'Hours'
	,isnull(convert(varchar(10),convert(date,MIN(ib.Date_Recieved))),0)			as 'Oldest Date Received'
	,isnull(convert(varchar(10),convert(date,MIN(ib.Oldest_DOS))),0)			as 'Oldest DOS'
	,tw.WorkType																as 'Type of Work'
	,ISNULL(YearCount.Batches_Past_Year,0)										as 'Batches in Past Year'
	,ISNULL(YearCount.Hours_past_year,0)										as 'Hours in Past Year'

FROM	dbo.TYPE_OF_WORK					as tw
	left outer join dbo.Input_Batches		as ib		on ib.Type_Of_Work = tw.id
															and ib.Current_status_Code = 50
	left outer join (
		SELECT
		tw.WorkType
		,COUNT(ib.id)								as Batches_Past_Year
		,SUM(ib.Estimated_Input_Hours)				as Hours_past_year
	 
		FROM Input_Batches							as ib
			join TYPE_OF_WORK						as tw	on tw.id = ib.Type_Of_Work
																WHERE 1=1
																	and ib.Date_Recieved >= @YearAgoToday
																	and Partial_File <> 1
																GROUP by ib.Type_Of_Work,tw.WorkType
																	)											
																	as YearCount on tw.WorkType = YearCount.WorkType
WHERE 1=1
		and tw.WorkType not in (
		 'ADR - Audiometrist'
		,'AUD - Audiology'
		,'COTA - Certified Occupational Therapist Assistant'
		,'DR - Physician'
		,'DRPSY - Psychiatrist'
		,'DRPSY - Psychiatrist'
		,'OPT - Optometrist'
		,'SLPA - Speech Language Pathologist Assistant'
		,'TCM - Case Manager'
		,'TCM - RSP Teacher'
		,'TCM - SDC Teacher'
		,'TCM - Teacher, General Education')
	
GROUP by  tw.WorkType, YearCount.Batches_Past_Year, YearCount.Hours_past_year	

ORDER by [# of Batches] desc
	END
	
	if @reportNum = 4
	BEGIN
	--*************************************************************************************************************
--3 - This section LISTS all the batches CURRENTLY IN PROCESS
--*************************************************************************************************************
SELECT DISTINCT
	 ib.id
	,'3 - List in Process'															as 'Section'
	,convert(integer, ib.Current_status_Code)										as 'Current Status Code'
	,ibs.Status																		as 'Current Status Description'
	,convert(date,ib.Date_Recieved)													as 'Date Received'
	,Oldest_DOS																		as 'Oldest DOS'
	,ib.File_Name																	as 'File Name'
    ,wt.WorkType																	as 'Type of Work'
	,ib.Estimated_Input_Hours														as 'Hours'
	--,cr.first_name + ' ' + cr.last_name											as 'District Rep'
	,isnull(um.FirstName + ' ' + um.LastName, '')									as 'Last Assigned to'
  	,convert(date,ib.Current_Status_Date)	as 'Status Date' --,iba.FROM_STATUS		as 'From'

FROM dbo.INPUT_BATCHES as ib
	join dbo.Input_Batches_Status			as ibs		on ibs.Status_Code = ib.Current_status_Code
	join CLIENTS_Client						as cc		on cc.CLIENT_ID = ib.ClientID
	join dbo.TYPE_OF_WORK					as wt		on wt.id = ib.Type_Of_Work
	left outer join users.dbo.users			as uu		on uu.userrid = ib.Current_status_UserID2
	left outer join users.dbo.Membership	as um		on um.UserId = uu.userid
	join dbo.CLIENTS_Client_Reps			as cr		on cr.id = cc.ClientRepIDLEACurrent
	
WHERE 1=1
	and Current_status_Code in (10,30,50,60,70,80,85,90,100,110,130)		--Batches currently in Process
	
ORDER BY  convert(integer, ib.Current_status_Code), convert(date,ib.Date_Recieved), ib.File_Name
	END


	if @reportNum = 5
	BEGIN
	--*************************************************************************************************************
--4 - This section LISTS all the batches Assigned but NOT DoneYet
--*************************************************************************************************************
SELECT DISTINCT
	 ib.id
	,'4 - Assigned Work NOT Done'													as 'Section'
	,convert(integer, ib.Current_status_Code)										as 'Current Status Code'
	,ibs.Status																		as 'Current Status Description'
	,convert(date,ib.Date_Recieved)													as 'Date Received'
	,Oldest_DOS																		as 'Oldest DOS'
	,ib.File_Name																	as 'File Name'
    ,wt.WorkType																	as 'Type of Work'
    ,ib.Estimated_Input_Hours														as 'Hours'
	,isnull(um.FirstName + ' ' + um.LastName, '')									as 'Last Assigned to'
	--,isnull(um1.FirstName + ' ' + um1.LastName, '')									as 'Other Name'

  	,convert(date,ib.Current_Status_Date)											as 'Status Date'

FROM dbo.INPUT_BATCHES						as ib
	join dbo.Input_Batches_Status			as ibs		on ibs.Status_Code = ib.Current_status_Code
	join CLIENTS_Client						as cc		on cc.CLIENT_ID = ib.ClientID
	join dbo.TYPE_OF_WORK					as wt		on wt.id = ib.Type_Of_Work
	left outer join users.dbo.users			as uu		on uu.userrid = ib.Current_status_UserID2
	left outer join users.dbo.users			as uu1		on uu1.userrid = ib.Current_status_UserID1
	left outer join users.dbo.Membership	as um		on um.UserId = uu.userid
	left outer join users.dbo.Membership	as um1		on um1.UserId = uu1.userid
	join dbo.CLIENTS_Client_Reps			as cr		on cr.id = cc.ClientRepIDLEACurrent
	
WHERE 1=1
	and Current_status_Code in (60,70,130,80,85,100,110,130)		
	
ORDER BY [Last Assigned to], convert(date,ib.Current_Status_Date)
	END
	
	
	if @reportNum = 6
	BEGIN
	--*************************************************************************************************************
-- 4.1 - This section has the DETAILED ACTIVITY HISTORY of all files NEEDING HIGH PRIORITY REVIEW
--*************************************************************************************************************
SELECT
	  '4.1 - HIGH PRIORITY Review'						as 'Section'
      ,isnull(uum.FirstName + ' ' + uum.LastName, '')	as 'Who put this here?'
      ,ib.File_Name										as 'File Name'
      ,wt.WorkType										as 'Type of Work'
      --,convert(date,ib.Oldest_DOS)						as 'Oldest DOS'
      --,convert(date,ib.Date_Recieved)					as 'Date Received'
      ,iba.Date_Updated									as 'Activity Date'
      ,iba.FROM_STATUS									as 'From Status Code'
      ,iba.TO_STATUS									as 'To Status Code'
      ,ibss.Status										as 'To Status Name'
      ,ib.Current_status_Code							as 'Current Status Code'
      ,ibs.Status										as 'Current Status Name'
      ,ib.Notes											as 'Notes'
      ,ib.ParentBatchID									as 'Parent Batch ID'

FROM dbo.INPUT_BATCHES						as ib
	join dbo.Input_Batches_Status			as ibs		on ibs.Status_Code = ib.Current_status_Code
	join CLIENTS_Client						as cc		on cc.CLIENT_ID = ib.ClientID
	join (select Input_Batches_ID, MAX(ID) as last_recID from Input_Batches_Activity group by Input_Batches_ID) as last_entered_rec on ib.id = last_entered_rec.Input_Batches_ID
	join dbo.Input_Batches_Activity			as iba		on iba.ID = last_entered_rec.last_recID
	join dbo.TYPE_OF_WORK					as wt		on wt.id = ib.Type_Of_Work
	left outer join users.dbo.users			as uu		on uu.userrid = iba.AssignedTo
	left outer join users.dbo.Users			as uuu		on uuu.userrid = iba.UpdatedBy
	left outer join users.dbo.Membership	as uum		on uum.UserId = uuu.UserId
	left outer join users.dbo.Membership	as um		on um.UserId = uu.userid
	join dbo.CLIENTS_Client_Reps			as cr		on cr.id = cc.ClientRepIDLEACurrent
	join dbo.Input_Batches_Status			as ibss		on ibss.Status_Code = iba.TO_STATUS

WHERE 1=1
	and ib.Current_status_Code in (80, 85,110,130)	--Batches needing high priority review
	--and iba.TO_STATUS in (80, 85, 110, 130)
	
ORDER by Current_status_Code ,convert(date,ib.Date_Recieved), ib.File_Name, iba.Date_Updated
	END
	
	if @reportNum = 7
	BEGIN
	--*************************************************************************************************************
-- 5 - This section lists all the AGING BATCHES 
--*************************************************************************************************************
SELECT DISTINCT
	 ib.id
	,'5 - Aging Work'																as 'Section'
	,convert(integer, ib.Current_status_Code)										as 'Current Status Code'
	,ibs.Status																		as 'Current Status Description'
	,convert(date,ib.Date_Recieved)													as 'Date Received'
	,convert(date,Oldest_DOS)														as 'Oldest DOS'
	,ib.File_Name																	as 'File Name'
    ,wt.WorkType																	as 'Type of Work'
    ,ib.Estimated_Input_Hours														as 'Hours'    
	,cr.first_name + ' ' + cr.last_name												as 'District Rep'
	,isnull(um.FirstName + ' ' + um.LastName, '')									as 'Last Assigned to'
  	,convert(date,ib.Current_Status_Date)	as 'Status Date' --,iba.FROM_STATUS		as 'From'

FROM dbo.INPUT_BATCHES								as ib
	join				dbo.Input_Batches_Status	as ibs		on ibs.Status_Code = ib.Current_status_Code
	join				CLIENTS_Client				as cc		on cc.CLIENT_ID = ib.ClientID
	join				dbo.TYPE_OF_WORK			as wt		on wt.id = ib.Type_Of_Work
	left outer join		users.dbo.users				as uu		on uu.userrid = ib.Current_status_UserID2
	left outer join		users.dbo.Membership		as um		on um.UserId = uu.userid
	join				dbo.CLIENTS_Client_Reps		as cr		on cr.id = cc.ClientRepIDLEACurrent
	
WHERE 1=1
	and Current_status_Code < 60
	and Oldest_DOS <= @AgeOutCheck
	
ORDER BY convert(date,Oldest_DOS), convert(date,ib.Date_Recieved)
	END


	if @reportNum = 8
	BEGIN
	--*************************************************************************************************************
-- 6 - This section provides TRAINING IN PROCESS
--*************************************************************************************************************
SELECT 
	  '6 - Training In Process'							as 'Training in Process'
	  , userdata.staffname								as 'Staff Name'
	  , ISNULL(worktype, '')							as 'Currently training on'
	  , train.rate										as '% Trained'
	  , ISNULL (rating, 'No Active Training')			as 'Skill level'
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
		)												as 'Last date user started on a batch of this type'

FROM
	(select u.userrid, m.LastName + ', ' + m.FirstName as staffname , u.UserName FROM Users.dbo.Users u
	inner join Users.dbo.Membership m on m.UserId = u.UserId and SBSC_Employee = 1
	inner join Users.dbo.UsersInRoles uir on m.UserId = uir.UserId
	inner join Users.dbo.Roles r on uir.RoleId = r.RoleId and  (r.RoleName like '%input%' or r.RoleName like '%Leade%')
		WHERE 1=1
			and UserName not like '%quit%'
			and m.IsLockedOut = 0
	) as userdata
	outer apply (
		select TYPE_OF_WORK.WorkType, strat.RATING, strat.RATE, TYPE_OF_WORK.id as workTypeID
		FROM TRAINED_STAFF as ts
			inner join TYPE_OF_WORK on ts.WORKTYPE_ID = TYPE_OF_WORK.id
			inner join STAFF_TRAINING_RATES strat on ts.RATING = strat.RATING_ID
		WHERE
			ts.STAFF_ID = userdata.userrid
			and ts.WORKTYPE_ID = TYPE_OF_WORK.id
			and strat.RATE not in (1,0)
	) as train
		WHERE train.RATE is not null
ORDER by staffname, RATE desc, WorkType
	END
	
	
	if @reportNum = 9
	BEGIN
	--*************************************************************************************************************
-- 7 - This section lists the NEXT BATCHES TO ASSIGN in Date Received sequence
--*************************************************************************************************************
SELECT DISTINCT
	 ib.id
	,'7 - FIFO'																		as 'Section'
	,convert(integer, ib.Current_status_Code)										as 'Current Status Code'
	,ibs.Status																		as 'Current Status Description'
	,convert(date,ib.Date_Recieved)													as 'Date Received'
	,convert(date,Oldest_DOS)														as 'Oldest DOS'
	,ib.File_Name																	as 'File Name'
    ,wt.WorkType																	as 'Type of Work'
    ,ib.Estimated_Input_Hours														as 'Hours'    
	,cr.first_name + ' ' + cr.last_name												as 'District Rep'
	,isnull(um.FirstName + ' ' + um.LastName, '')									as 'Last Assigned to'
  	,convert(date,ib.Current_Status_Date)	as 'Status Date' --,iba.FROM_STATUS		as 'From'

FROM dbo.INPUT_BATCHES						as ib
	join dbo.Input_Batches_Status			as ibs		on ibs.Status_Code = ib.Current_status_Code
	join CLIENTS_Client						as cc		on cc.CLIENT_ID = ib.ClientID
	join dbo.TYPE_OF_WORK					as wt		on wt.id = ib.Type_Of_Work
	left outer join users.dbo.users			as uu		on uu.userrid = ib.Current_status_UserID2
	left outer join users.dbo.Membership	as um		on um.UserId = uu.userid
	join dbo.CLIENTS_Client_Reps			as cr		on cr.id = cc.ClientRepIDLEACurrent
	
WHERE 1=1
	and Current_status_Code < 60
	and  NOT (Oldest_DOS <= @AgeOutCheck)
	
ORDER BY convert(date,ib.Date_Recieved)
	
	END

if @reportNum = 10
	BEGIN
	--*************************************************************************************************************
-- 8 - This section provides STAFF INFORMATION
--*************************************************************************************************************
SELECT
	 '8 - Staff'																		as 'Section'
	,userdata.staffname																as 'Input Staff Name'
	,TYPE_OF_WORK.WorkType															as 'Work Type'
	,isnull(str.RATE, 0) 															as '% Trained'
	,isnull(str.RATING, 'No training in this type yet' )							as 'Training Comment'
	,isnull((select SUM(dbo.STAFF_PROMISED_HOURS.TOTAL_HOURS)
			FROM dbo.STAFF_PROMISED_HOURS 
			WHERE dbo.STAFF_PROMISED_HOURS.STAFF_ID = userdata.userrid 
				and dbo.STAFF_PROMISED_HOURS.WEEKSTART_DATE = @NextSunday),0)		as 'NEXT Week Hours'
	,isnull((select SUM(dbo.STAFF_PROMISED_HOURS.TOTAL_HOURS)
			FROM dbo.STAFF_PROMISED_HOURS 
			WHERE dbo.STAFF_PROMISED_HOURS.STAFF_ID = userdata.userrid 
				and dbo.STAFF_PROMISED_HOURS.WEEKSTART_DATE = @LastSunday),0)		as 'THIS Week Hours'

FROM	(select u.userrid, m.LastName + ', ' + m.FirstName		as staffname , u.UserName from Users.dbo.Users u
		inner join Users.dbo.Membership m on m.UserId = u.UserId and SBSC_Employee = 1
		inner join Users.dbo.UsersInRoles uir on m.UserId = uir.UserId
		inner join Users.dbo.Roles r on uir.RoleId = r.RoleId and  (r.RoleName like '%input%' or r.RoleName like '%Leade%')
			WHERE 1=1
				and UserName not like '%quit%'
				and m.IsLockedOut = 0
		) as userdata
	full join TYPE_OF_WORK  on 1=1
	left outer join TRAINED_STAFF ts on ts.STAFF_ID = userdata.userrid and ts.WORKTYPE_ID = TYPE_OF_WORK.id
	left outer join dbo.STAFF_TRAINING_RATES as str on str.RATING_ID = ts.RATING

WHERE 1=1
	and TYPE_OF_WORK.WorkType not in (
		 'ADR - Audiometrist'
		,'AUD - Audiology'
		,'COTA - Certified Occupational Therapist Assistant'
		,'DR - Physician'
		,'DRPSY - Psychiatrist'
		,'DRPSY - Psychiatrist'
		,'OPT - Optometrist'
		,'SLPA - Speech Language Pathologist Assistant'
		,'TCM - Case Manager'
		,'TCM - RSP Teacher'
		,'TCM - SDC Teacher'
		,'TCM - Teacher, General Education')

GROUP BY ts.STAFF_ID ,userdata.staffname ,TYPE_OF_WORK.WorkType ,str.RATE, str.RATING ,userdata.UserName,userdata.userrid
	
ORDER BY [UserName] , [Worktype]
	END


	if @reportNum = 11
	BEGIN
	--*************************************************************************************************************
-- 9 - This section provides TRAINING NOT YET STARTED
--*************************************************************************************************************
SELECT
	 '9 - Training NOT Started'														as 'Section'
	,userdata.staffname																as 'Input Staff Name'
	,TYPE_OF_WORK.WorkType															as 'Work Type'

FROM	(select u.userrid, m.LastName + ', ' + m.FirstName		as staffname , u.UserName from Users.dbo.Users u
		inner join Users.dbo.Membership m on m.UserId = u.UserId and SBSC_Employee = 1
		inner join Users.dbo.UsersInRoles uir on m.UserId = uir.UserId
		inner join Users.dbo.Roles r on uir.RoleId = r.RoleId and  (r.RoleName like '%input%' or r.RoleName like '%Leade%')
			WHERE 1=1
				and UserName not like '%quit%'
				and m.IsLockedOut = 0
		) as userdata
	full join TYPE_OF_WORK  on 1=1
	left outer join TRAINED_STAFF ts on ts.STAFF_ID = userdata.userrid and ts.WORKTYPE_ID = TYPE_OF_WORK.id
	left outer join dbo.STAFF_TRAINING_RATES as str on str.RATING_ID = ts.RATING

WHERE 1=1
	and ts.ID is null
	and TYPE_OF_WORK.WorkType not in (
		 'ADR - Audiometrist'
		,'AUD - Audiology'
		,'COTA - Certified Occupational Therapist Assistant'
		,'DR - Physician'
		,'DRPSY - Psychiatrist'
		,'DRPSY - Psychiatrist'
		,'OPT - Optometrist'
		,'SLPA - Speech Language Pathologist Assistant'
		,'TCM - Case Manager'
		,'TCM - RSP Teacher'
		,'TCM - SDC Teacher'
		,'TCM - Teacher, General Education')

GROUP BY ts.STAFF_ID ,userdata.staffname ,TYPE_OF_WORK.WorkType ,str.RATE, str.RATING ,userdata.UserName,userdata.userrid
	
ORDER BY [staffname] , [Worktype]
	END
	
	
	if @reportNum = 12
	BEGIN
	--*************************************************************************************************************
-- 10 - This section has the DETAILED ACTIVITY HISTORY of all files CURRENTLY IN PROCESS
--*************************************************************************************************************
SELECT
	  '10 - History'									as 'Section'
	  ,ib.id											as 'Batch ID'
	  ,cr.first_name + ' ' + cr.last_name				as 'District Rep'
      ,cc.CLIENT_NAME									as 'Client Name'
      ,ib.File_Name										as 'File Name'
      ,wt.WorkType										as 'Type of Work'
      ,convert(date,ib.Oldest_DOS)						as 'Oldest DOS'
      ,convert(date,ib.Date_Recieved)					as 'Date Received'
      ,iba.Date_Updated									as 'Activity Date'
      ,iba.FROM_STATUS									as 'From Status Code'
      ,iba.TO_STATUS									as 'To Status Code'
      ,ibss.Status										as 'To Status Name'
      ,ib.Current_status_Code							as 'Current Status Code'
      ,ibs.Status										as 'Current Status Name'
      ,isnull(uum.FirstName + ' ' + uum.LastName, '')	as 'Who TOOK this action?'
      ,isnull(um.FirstName + ' ' + um.LastName, '')		as 'Who is this assigned to AFTER this action?'
      ,ib.File_Location									as 'Current File Location'
      ,convert(date,ib.Date_Sent)						as 'Date Sent'
      ,ib.Estimated_Input_Hours							as 'Hours'
      ,ib.Notes											as 'Notes'
      ,ib.ParentBatchID									as 'Parent Batch ID'
      ,convert(date,SUBSTRING(ib.File_Name,1,8))		as 'Date in File Name'

FROM dbo.INPUT_BATCHES						as ib
	join dbo.Input_Batches_Status			as ibs		on ibs.Status_Code = ib.Current_status_Code
	join CLIENTS_Client						as cc		on cc.CLIENT_ID = ib.ClientID
	join dbo.Input_Batches_Activity			as iba		on iba.Input_Batches_ID = ib.id
	join dbo.TYPE_OF_WORK					as wt		on wt.id = ib.Type_Of_Work
	left outer join users.dbo.users			as uu		on uu.userrid = iba.AssignedTo
	left outer join users.dbo.Users			as uuu		on uuu.userrid = iba.UpdatedBy
	left outer join users.dbo.Membership	as uum		on uum.UserId = uuu.UserId
	left outer join users.dbo.Membership	as um		on um.UserId = uu.userid
	join dbo.CLIENTS_Client_Reps			as cr		on cr.id = cc.ClientRepIDLEACurrent
	join dbo.Input_Batches_Status			as ibss		on ibss.Status_Code = iba.TO_STATUS

WHERE 1=1
	and ib.Current_status_Code in (10,30,50,60,70,80, 85,90,100,110,130)	--Batches CURRENTLY IN PROCESS
	
ORDER by convert(date,ib.Date_Recieved), ib.File_Name, iba.Date_Updated
	END
	
	if @reportNum = 13
	BEGIN
	----*************************************************************************************************************
---- 11 - This section has NOT BILLABLE for batches received IN THE PAST YEAR
----*************************************************************************************************************
SELECT 
	'11 - Not Billable'								as 'Section'
	,cr.first_name + ' ' + cr.last_name				as 'District Rep'
    ,cc.CLIENT_NAME									as 'Client Name'
	,cc.OwnedByCompanyID_LEA						as 'Company'
    ,ib.File_Name									as 'File Name'
    ,wt.WorkType									as 'Type of Work'
    ,convert(date,ib.Current_Status_Date)			as 'Date Returned'

FROM dbo.INPUT_BATCHES								as ib
	join dbo.Input_Batches_Status					as ibs		on ibs.Status_Code = ib.Current_status_Code
	join CLIENTS_Client								as cc		on cc.CLIENT_ID = ib.ClientID
	join dbo.TYPE_OF_WORK							as wt		on wt.id = ib.Type_Of_Work
	left outer join users.dbo.users					as uu		on uu.userrid = ib.Current_status_UserID2
	left outer join users.dbo.Membership			as um		on um.UserId = uu.userid
	join dbo.CLIENTS_Client_Reps					as cr		on cr.id = cc.ClientRepIDLEACurrent 


WHERE 1=1
	and convert(date,ib.Current_Status_Date) > @YearAgoToday
	and ib.Current_status_Code = 310		--Not Billable
	and cc.LEA = 1
	
ORDER by ib.Date_Recieved, cc.CLIENT_NAME, ib.File_Name, convert(date,ib.Current_Status_Date)
	END


	if @reportNum = 14
	BEGIN
	--*************************************************************************************************************
-- 12 - This section has FILES RETURNED with QUESTION FORMS for batches received AFTER the @YearAgoToday
--*************************************************************************************************************
SELECT 
	'12 - QForms'									as 'Section'
	,cr.first_name + ' ' + cr.last_name				as 'District Rep'
    ,cc.CLIENT_NAME									as 'Client Name'
	,cc.OwnedByCompanyID_LEA						as 'Company'
    ,ib.File_Name									as 'File Name'
    ,wt.WorkType									as 'Type of Work'
    ,convert(date,ib.Current_Status_Date)			as 'Date Returned'
    --,ib.Current_status_Code						as 'CurrentStatus (290 & 300 = No Answer Yet'
    ,CASE 
		WHEN ib.Current_status_Code IN (290,300) 
		THEN 'No Answer yet'				
		ELSE ''
		END											as 'Answered?'

FROM dbo.INPUT_BATCHES								as ib
	join dbo.Input_Batches_Status					as ibs		on ibs.Status_Code = ib.Current_status_Code
	join CLIENTS_Client								as cc		on cc.CLIENT_ID = ib.ClientID
	join dbo.TYPE_OF_WORK							as wt		on wt.id = ib.Type_Of_Work
	left outer join users.dbo.users					as uu		on uu.userrid = ib.Current_status_UserID2
	left outer join users.dbo.Membership			as um		on um.UserId = uu.userid
	join dbo.CLIENTS_Client_Reps					as cr		on cr.id = cc.ClientRepIDLEACurrent  

WHERE 1=1
	and ib.Date_Recieved > @YearAgoToday
	and ib.File_Name like '%QForm%'
	and ib.File_Name NOT like '%-NB%'
	and ib.Current_status_Code <> 340
	and cc.LEA = 1
	
ORDER by ib.Date_Recieved, cc.CLIENT_NAME, ib.File_Name, convert(date,ib.Current_Status_Date)
	END
	
	
	if @reportNum = 15
	BEGIN
	--*************************************************************************************************************
-- 13 - This section is a lIST of Questions Not yet Answered
--*************************************************************************************************************
select 
	'13 - Q no A'							as 'Section'
	,rep.first_name +' ' +rep.last_name	as 'District Rep' 
	,cc.CLIENT_NAME						as 'Client Name'
	,ib.File_Name						as 'File name'
	,tow.WorkType						as 'Type of Work'
	,convert(date,ib.Oldest_DOS)		as 'Oldest DOS'
	,convert(date,ur.CreatedOn)			as 'Date Returned'
	,ur.Email_To						as 'Sent to'
	,isnull(ur.Email_CC,'')				as 'CC email to'
	,udr.Question						as 'Question Asked'
	
from users.dbo.INFO_REQUEST_RESPONSE_DETAILS		as udr
join users.dbo.INFO_REQUEST_RESPONSE				as ur		on ur.id = udr.InfoRequestResponseID
left outer join SPEDMON.dbo.INPUT_BATCHES			as ib		on ur.ReferenceID = ib.id
join SPEDMON.dbo.TYPE_OF_WORK						as tow		on tow.id = ib.Type_Of_Work
join SPEDMON.dbo.CLIENTS_Client						as cc		on cc.CLIENT_ID = ur.ClientID
join SPEDMON.dbo.CLIENTS_Client_Reps				as rep		on rep.id = cc.ClientRepIDLEACurrent

where 1=1
	and udr.Answer is null
	and ur.CreatedOn >= @YearAgoToday
	--and ib.id is null
	and ib.Current_status_Code in (290, 300)
	
order by [District Rep], [Client Name], [Date Returned], [File name]
	END
	
	if @reportNum = 16
	BEGIN
	--*************************************************************************************************************
-- 14 - This section shows HOW MANY BATCHES were RECEIVED each DAY for the past year
--*************************************************************************************************************
SELECT
	 '14 - Batches Received by Date'		as 'Section'
	,DATENAME (month, Date_Recieved)		as 'Month'
	,DATENAME (year, Date_Recieved)			as 'Year'
	,DATENAME ( weekday , Date_Recieved)	as 'Day'
	,convert(date,Date_Recieved)			as 'Date Received'
	,Count(id)								as '# of Batches'

FROM dbo.INPUT_BATCHES

WHERE 1=1
	and convert(date,Date_Recieved) >= @FirstDayThisMoLastYear
	and Partial_File <> 1

GROUP BY convert(date,Date_Recieved), DATENAME ( weekday , Date_Recieved), DATENAME (month, Date_Recieved), DATENAME (year, Date_Recieved)

ORDER BY convert(date,Date_Recieved)
	END
	
	if @reportNum = 17
	BEGIN
	--*************************************************************************************************************
-- 15 - This section shows the LAG TIME between the Oldest DOS in the batch and the date it was received into the Work Flow
--*************************************************************************************************************
SELECT
	 '15 - Lag in Receipt'					as 'Section'
	,cc.CLIENT_NAME							as 'Client Name'
	,ib.File_Name							as 'File Name'
	,convert(date,ib.Oldest_DOS)			as 'Oldest DOS'
	,convert(date,ib.Date_Recieved)			as 'Date Received'
	
	
FROM dbo.INPUT_BATCHES as ib
join dbo.CLIENTS_Client as cc on cc.CLIENT_ID = ib.ClientID

WHERE 1=1
	and Date_Recieved >= @FirstDayThisMoLastYear

ORDER BY
	cc.CLIENT_NAME
	,convert(date,ib.Date_Recieved)
	,convert(date,ib.Oldest_DOS)
	END

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[WORKFLOW_REPORTS_VIEW] TO [webuser]
GO
