/* CASEMIS - Spedcare Student Matching */ 

/* Include in final documentation that this sproc COPIES query elements in student-data-A routine and changes in one have to be matched in the other. */

USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CASEMIS_STUDENTDATA_MATCH') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.CASEMIS_STUDENTDATA_MATCH
GO


CREATE PROCEDURE dbo.CASEMIS_STUDENTDATA_MATCH 
(
	@CASEMIS_FILE_ID bigint,
	@istestrun bit = 1
)
AS
BEGIN

/* var and temp table initialization */
declare @current_client bigint


/* ID CASEMIS file we want to work with and what client the file is for. */

--set @CASEMIS_FILE_ID = 1
set @current_client= (select client_id from CASEMIS_FILES where ID = @CASEMIS_FILE_ID)



create table  #parsedpopfile ( 
							case_A_line_ID BIGINT,
							--file input columnss
							SSN nvarchar(9), 
							STUDLNAME nvarchar(20), 
							STUDFNAME nvarchar(15), 
							STUDMI nvarchar (1), 
							DOB date, 
							SEX nvarchar(1), 
							SCHMEDID nvarchar(9),
							CDS25 nvarchar(7), 
							CSIS nvarchar(10), 
							CDS7 nvarchar (7),
							GRADE nvarchar(2),
							SCHSTUDID nvarchar(16),
							
							
							--CDS->clientID simplifier
							
							clientid int,
							
							--CDS7->siteID simplifier
							siteid int,
							
							--Create 'count' columns
							
							CountSSN bigint,
							CountCSIS bigint,
							CountFLDOB bigint,
							CountCSIS_FLDOB bigint,
							CountSSN_FLDOB bigint,
							
							
							--create pass #1 'todo' columns
							isMatch bit,
							checkSCHSTUDID bit,
							checkInactive bit,
							
							--pass #1 done, so now we move onto the inactive checks
							--Create 'count' columns
							
							ICountSSN bigint,
							ICountCSIS bigint,
							ICountFLDOB bigint,
							ICountCSIS_FLDOB bigint,
							ICountSSN_FLDOB bigint,
							
							isInactiveMatch bit,
							checkInactiveSCHSTUDID bit,
							NotFound bit,
							
							MatchOnFLDOB bit,
							MatchCSIS_FLDOB bit,
							MatchSSN_FLDOB bit,
							
							CountActiveSCHSTUDID bigint,
							CountInactiveSCHSTUDID bigint,
							
							MatchPatientID bigint,
							CreatedPatientID Bigint,
							currentpatientsiteid bigint,
							Errorcode nvarchar(200) 
							)




/* Load up CASEMIS-A info for student data match */

insert into #parsedpopfile (case_A_line_ID, SSN, STUDLNAME, STUDFNAME, DOB, SEX, CDS25, CSIS, CDS7, GRADE, SCHSTUDID)
select cfas.Line_ID, cfas.SSN, cfas.LAST_NAME, cfas.FIRST_NAME, cfas.BIRTHDATE, cfas.GENDER, cfas.DIST_RESI, cfas.SSID, cfas.SCH_CODE, cfas.GRADE, cfas.STUDENT_ID 
from CASEMIS_FILES_A_STUDENTS cfas 
where cfas.Casemis_File_ID = @CASEMIS_FILE_ID

update #parsedpopfile 
set 
	clientid = @current_client
	,siteid = 
		(
			select 
				top 1 SITE_ID 
				
			from 
				SITES_Site 
				
			where 
				(
					SITE_CDS = CDS7 
					and SITE_CLIENT_ID = @current_client 
					and CDS7 <> ''
				) 
				OR 
				(
					CDS7 = '' 
					and SITE_CLIENT_ID = @current_client 
					and SITE_NAME like '%unknown school%'
				)
		)

/* The only blank siteIDs remaining are ones where the CDS7 field is filled with something that isn't a CDS7 value. These get filed under unknown school code. */
update #parsedpopfile set siteid = (select site_id from SITES_Site ss where ss.SITE_CLIENT_ID = @current_client and ss.SITE_NAME like '%unknown school%') where siteid is null



--start getting counts for data - remember, this is first pass - searching only within the district and for active students.


print 'Count Updates:'

print 'Active matches'
update #parsedpopfile
set CountSSN = 
	(
		select COUNT(*) 
		from PATIENTS_Patient pp  
		inner join PATIENTS_Client pc on 
			pp.PATIENT_ID = pc.PATIENT_ID 
			and pp.SSN = #parsedpopfile.SSN
			and pp.ACTIVE = 'Y'
			and pc.CLIENT_ID = clientid

		where  #parsedpopfile.SSN <> ''
	)
	
, CountCSIS = 
	(
		select COUNT(*) 
		from PATIENTS_Patient pp  
		inner join PATIENTS_Client pc on 
			pp.PATIENT_ID = pc.PATIENT_ID 
			and pp.CSIS = #parsedpopfile.CSIS  
			and pp.ACTIVE = 'Y'
			and pc.CLIENT_ID = clientid
		where #parsedpopfile.CSIS <> ''
	)
, CountFLDOB = 
	(
		select COUNT(*) 
		from PATIENTS_Patient pp  
		inner join PATIENTS_Client pc on 
			pp.PATIENT_ID = pc.PATIENT_ID 
			and pp.DATE_OF_BIRTH = #parsedpopfile.DOB 
			and #parsedpopfile.STUDFNAME = pp.FIRST_NAME 
			and #parsedpopfile.STUDLNAME = pp.LAST_NAME
			and pp.ACTIVE = 'Y'
		and pc.CLIENT_ID = clientid
	)
	
, CountSSN_FLDOB = 
	(
		select COUNT(*) 
		from PATIENTS_Patient pp  
		inner join PATIENTS_Client pc on 
			pp.PATIENT_ID = pc.PATIENT_ID 
			and pp.SSN = #parsedpopfile.SSN
			and pp.DATE_OF_BIRTH = #parsedpopfile.DOB
			and #parsedpopfile.STUDFNAME = pp.FIRST_NAME 
			and #parsedpopfile.STUDLNAME = pp.LAST_NAME
			and pp.ACTIVE = 'Y'
		and pc.CLIENT_ID = clientid
		where #parsedpopfile.SSN <> ''
	)
, CountCSIS_FLDOB = 
	(
		select COUNT(*) 
		from PATIENTS_Patient pp  
		inner join PATIENTS_Client pc on 
			pp.PATIENT_ID = pc.PATIENT_ID 
			and pp.CSIS = #parsedpopfile.CSIS
			and pp.DATE_OF_BIRTH = #parsedpopfile.DOB
			and #parsedpopfile.STUDFNAME = pp.FIRST_NAME 
			and #parsedpopfile.STUDLNAME = pp.LAST_NAME
			and pp.ACTIVE = 'Y'
		and pc.CLIENT_ID = clientid
		where #parsedpopfile.CSIS <> ''
	)



--Update the decision flags now that we have the counts
print 'Flagging active decision markers'

--Unsure - need to check on student ID
update #parsedpopfile 
set checkSCHSTUDID = 1
where
	( 
		(
		CountFLDOB > 1
		and 
		(
			CountCSIS + CountSSN <> 0
		)
		)
	)
	and CountCSIS_FLDOB <> 1
	and CountSSN_FLDOB <> 1

--Based on counts returned, we've found a match
update #parsedpopfile 
set isMatch = 1
where
	--case 1
	CountSSN_FLDOB =1
	or 
	--case 2
	CountFLDOB =1
	or 
	--case 3
	(
		CountFLDOB =0 
		and CountCSIS =1 
		and CountCSIS_FLDOB = 1
		and CountSSN_FLDOB =0
	)
	or 
	--case 4
	(
		CountFLDOB = 0 
		and CountCSIS >1 
		and CountSSN < 2 
		and CountCSIS_FLDOB = 1 
		and CountSSN_FLDOB = 0
	)
	or 
	--case 5
	(
		(
			CountFLDOB > 1 
			and 
			(
				Not
				(
					(CountFLDOB = 0 and CountCSIS >1 and CountSSN > 1 )
					or 
					(CountFLDOB > 1 and CountCSIS = 0 and CountSSN = 0)
				)
			) 
			and CountCSIS_FLDOB = 1 
			and CountSSN_FLDOB = 0
		) 
	)
	or 
	--case 6
	( not(CountFLDOB = 0 and CountCSIS > 1 and CountSSN > 1) and CountCSIS_FLDOB = 1 and CountSSN_FLDOB >1)

--Couldn't find a match in actives - flag for inactive search
update #parsedpopfile 
set checkInactive = 1
where
	--case 1
	(CountFLDOB = 0 and CountCSIS_FLDOB = 0 and CountSSN_FLDOB = 0)
	--case 2
	or (CountFLDOB = 0 and CountCSIS > 1 and CountSSN > 1 and CountSSN_FLDOB <> 1)
	--case 3
	or (CountFLDOB = 0 and CountCSIS > 1 and CountSSN <2 and CountCSIS_FLDOB > 1 and CountSSN_FLDOB = 0)
	--case 4
	or (CountFLDOB = 0 and CountCSIS < 2 and CountSSN > 1 and CountCSIS_FLDOB=0 and CountSSN_FLDOB > 1)
	--case 5
	or (CountFLDOB > 1 and CountCSIS = 0 and CountSSN = 0 and
		((CountCSIS_FLDOB = 0 and CountSSN_FLDOB =0) or (CountCSIS_FLDOB = 1 and CountSSN_FLDOB =0)))

--Pass 1 finished.



--Pass 2: Search inactives
print 'Inactive matches'
--Run Inactive Counts
update #parsedpopfile
set iCountSSN = 
	(
		select COUNT(*) 
		from PATIENTS_Patient pp  
		inner join PATIENTS_Client pc on 
			pp.PATIENT_ID = pc.PATIENT_ID 
			and pp.SSN = #parsedpopfile.SSN
			and pp.ACTIVE = 'N'
		and pc.CLIENT_ID = clientid
		where  #parsedpopfile.SSN <> '' and #parsedpopfile.checkInactive = 1
	)
	
, iCountCSIS = 
	(
		select COUNT(*) 
		from PATIENTS_Patient pp  
		inner join PATIENTS_Client pc on 
			pp.PATIENT_ID = pc.PATIENT_ID 
			and pp.CSIS = #parsedpopfile.CSIS  
			and pp.ACTIVE = 'N'
		and pc.CLIENT_ID = clientid
		where #parsedpopfile.CSIS <> '' and #parsedpopfile.checkInactive = 1
	)
, iCountFLDOB = 
	(
		select COUNT(*) 
		from PATIENTS_Patient pp  
		inner join PATIENTS_Client pc on 
			pp.PATIENT_ID = pc.PATIENT_ID 
			and pp.DATE_OF_BIRTH = #parsedpopfile.DOB 
			and #parsedpopfile.STUDFNAME = pp.FIRST_NAME 
			and #parsedpopfile.STUDLNAME = pp.LAST_NAME
			and pp.ACTIVE = 'N'
		and pc.CLIENT_ID = clientid
		where #parsedpopfile.checkInactive = 1
	)
	
, iCountSSN_FLDOB = 
	(
		select COUNT(*) 
		from PATIENTS_Patient pp  
		inner join PATIENTS_Client pc on 
			pp.PATIENT_ID = pc.PATIENT_ID 
			and pp.SSN = #parsedpopfile.SSN
			and pp.DATE_OF_BIRTH = #parsedpopfile.DOB
			and #parsedpopfile.STUDFNAME = pp.FIRST_NAME 
			and #parsedpopfile.STUDLNAME = pp.LAST_NAME
			and pp.ACTIVE = 'N'
		and pc.CLIENT_ID = clientid
		where #parsedpopfile.SSN <> ''and #parsedpopfile.checkInactive = 1
	)
, iCountCSIS_FLDOB = 
	(
		select COUNT(*) 
		from PATIENTS_Patient pp  
		inner join PATIENTS_Client pc on 
			pp.PATIENT_ID = pc.PATIENT_ID 
			and pp.CSIS = #parsedpopfile.CSIS
			and pp.DATE_OF_BIRTH = #parsedpopfile.DOB
			and #parsedpopfile.STUDFNAME = pp.FIRST_NAME 
			and #parsedpopfile.STUDLNAME = pp.LAST_NAME
			and pp.ACTIVE = 'N'
		and pc.CLIENT_ID = clientid
		where #parsedpopfile.CSIS <> '' and #parsedpopfile.checkInactive = 1
	)


--Update the decision flags now that we have the inactive counts
print 'Update inactive flag counts'
--Unsure - need to check on inactive student ID
update #parsedpopfile
set checkInactiveSCHSTUDID = 1
where 
	checkinactive = 1
	and
	(
		( 
			(
				iCountFLDOB > 1
				and 
				(
					iCountCSIS + iCountSSN <> 0
				)
			)
		)
		and iCountCSIS_FLDOB <> 1
		and iCountSSN_FLDOB <> 1
	)

--Based on counts returned, we've found a match	in the inactives
update #parsedpopfile
set isInactiveMatch = 1
where
	checkinactive = 1
	and
	(
	

	--case 1
	iCountSSN_FLDOB =1
	or 
	--case 2
	iCountFLDOB =1
	or 
	--case 3
	(
		iCountFLDOB =0 
		and iCountCSIS =1 
		and iCountCSIS_FLDOB = 1
		and iCountSSN_FLDOB =0
	)
	or 
	--case 4
	(
		iCountFLDOB = 0 
		and iCountCSIS >1 
		and iCountSSN < 2 
		and iCountCSIS_FLDOB = 1 
		and iCountSSN_FLDOB = 0
	)
	or 
	--case 5
	(
		(
			iCountFLDOB > 1 
			and 
			(
				Not
				(
					(iCountFLDOB = 0 and iCountCSIS >1 and iCountSSN > 1 )
					or 
					(iCountFLDOB > 1 and iCountCSIS = 0 and iCountSSN = 0)
				)
			) 
			and iCountCSIS_FLDOB = 1 
			and iCountSSN_FLDOB = 0
		) 
	)
	or 
	--case 6
	( not(iCountFLDOB = 0 and iCountCSIS > 1 and iCountSSN > 1) and iCountCSIS_FLDOB = 1 and iCountSSN_FLDOB >1)

	
	)
	
--Couldn't find a match in inactives - flag for patient creation
update #parsedpopfile
set NotFound = 1
where
	checkinactive = 1
	and
	(
	--case 1
	(iCountFLDOB = 0 and iCountCSIS_FLDOB = 0 and iCountSSN_FLDOB = 0)
	--case 2
	or (iCountFLDOB = 0 and iCountCSIS > 1 and iCountSSN > 1 and iCountSSN_FLDOB <> 1)
	--case 3
	or (iCountFLDOB = 0 and iCountCSIS > 1 and iCountSSN <2 and iCountCSIS_FLDOB > 1 and iCountSSN_FLDOB = 0)
	--case 4
	or (iCountFLDOB = 0 and iCountCSIS < 2 and iCountSSN > 1 and iCountCSIS_FLDOB=0 and iCountSSN_FLDOB > 1)
	--case 5
	or (iCountFLDOB > 1 and iCountCSIS = 0 and iCountSSN = 0 and
		((iCountCSIS_FLDOB = 0 and iCountSSN_FLDOB =0) or (iCountCSIS_FLDOB = 1 and iCountSSN_FLDOB =0)))

	)



--Next thing: check for SCHSTUDID match.
--what lead us to a SCHSTUDID match SSN OR CSIS?
--actually, we can just ignore it and go off of LFDOB and SCHSTUDID.
print 'Getting match counts based off of SCHSTUDID match'
print 'Active SCHSTUDID count:'
--counting based on match of SCHSTUDID 

--We have to do some additional handling in a subquery since a patient can have more than one schoolsite record and we want to get their current/most recent one.
--counting number of active schstudid matches
update #parsedpopfile
set CountActiveSCHSTUDID = 
(

	
		(
		select COUNT(*) 
		from PATIENTS_Patient pp  
		inner join PATIENTS_Client pc on 
			pp.PATIENT_ID = pc.PATIENT_ID 
			and pp.DATE_OF_BIRTH = #parsedpopfile.DOB 
			and #parsedpopfile.STUDFNAME = pp.FIRST_NAME 
			and #parsedpopfile.STUDLNAME = pp.LAST_NAME
			and pp.ACTIVE = 'Y'
		and pc.CLIENT_ID = clientid
		inner join PATIENTS_School ps on 
			ps.PATIENT_ID = pp.PATIENT_ID 
			and ps.SITE_ID = siteid 
			and ps.STUDENT_ID = SCHSTUDID
		where checkSCHSTUDID = 1
	)
	
	
)

--counting number of inactive schstudid matches
update #parsedpopfile
set CountInactiveSCHSTUDID = 
(
			(
		select COUNT(*) 
		from PATIENTS_Patient pp  
		inner join PATIENTS_Client pc on 
			pp.PATIENT_ID = pc.PATIENT_ID 
			and pp.DATE_OF_BIRTH = #parsedpopfile.DOB 
			and #parsedpopfile.STUDFNAME = pp.FIRST_NAME 
			and #parsedpopfile.STUDLNAME = pp.LAST_NAME
			and pp.ACTIVE = 'N'
		and pc.CLIENT_ID = clientid
		inner join PATIENTS_School ps on 
			ps.PATIENT_ID = pp.PATIENT_ID 
			and ps.SITE_ID = siteid 
			and ps.STUDENT_ID = SCHSTUDID
		where checkInactiveSCHSTUDID = 1
		)

)

print 'Adding on error notes'
update #parsedpopfile
set Errorcode = ISNULL(Errorcode,'') + ' MULT_CSIS '
where CountCSIS > 1 or iCountCSIS > 1

update #parsedpopfile
set Errorcode = ISNULL(Errorcode,'') + ' MULT_SSN '
where CountSSN > 1 or iCountSSN > 1

update #parsedpopfile
set Errorcode = ISNULL(Errorcode,'') + ' MULT_SCHSTUDID '
where CountActiveSCHSTUDID > 1 or CountInactiveSCHSTUDID > 1



--what patient ID can we pull from match data
print 'getting patient IDs for active matches'
--First, active matches
print 'Match on active FLDOB'
update #parsedpopfile
set matchpatientid = 
	(
		select pp.PATIENT_ID 
		from PATIENTS_Patient pp  
		inner join PATIENTS_Client pc on 
			pp.PATIENT_ID = pc.PATIENT_ID 
			and pp.DATE_OF_BIRTH = #parsedpopfile.DOB 
			and #parsedpopfile.STUDFNAME = pp.FIRST_NAME 
			and #parsedpopfile.STUDLNAME = pp.LAST_NAME
			and pp.ACTIVE = 'Y'
		and pc.CLIENT_ID = clientid
	)
where isMatch = 1 and CountFLDOB = 1 and Not (CountCSIS_FLDOB =1) and not (CountSSN_FLDOB = 1) --match on FLDOB
and MatchPatientID is null

print 'match on active fldob & CSIS'
update #parsedpopfile
set MatchPatientID = 
(
	select pp.PATIENT_ID
		from PATIENTS_Patient pp  
		inner join PATIENTS_Client pc on 
			pp.PATIENT_ID = pc.PATIENT_ID 
			and pp.CSIS = #parsedpopfile.CSIS
			and pp.DATE_OF_BIRTH = #parsedpopfile.DOB
			and #parsedpopfile.STUDFNAME = pp.FIRST_NAME 
			and #parsedpopfile.STUDLNAME = pp.LAST_NAME
			and pp.ACTIVE = 'Y'
		and pc.CLIENT_ID = clientid
		where #parsedpopfile.CSIS <> ''
		)
where isMatch = 1 and (CountCSIS_FLDOB =1) and not (CountSSN_FLDOB = 1) --match on FLDOB & CSIS
and MatchPatientID is null

print 'match on active FLDOB & SSN'
update #parsedpopfile 
set MatchPatientID = 
(
		select pp.PATIENT_ID
		from PATIENTS_Patient pp  
		inner join PATIENTS_Client pc on 
			pp.PATIENT_ID = pc.PATIENT_ID 
			and pp.SSN = #parsedpopfile.SSN
			and pp.DATE_OF_BIRTH = #parsedpopfile.DOB
			and #parsedpopfile.STUDFNAME = pp.FIRST_NAME 
			and #parsedpopfile.STUDLNAME = pp.LAST_NAME
			and pp.ACTIVE = 'Y'
		and pc.CLIENT_ID = clientid
		where #parsedpopfile.SSN <> ''
)
where isMatch = 1 and  (CountSSN_FLDOB = 1) --match on FLDOB & SSN
and MatchPatientID is null


--next, inactive matches
print 'getting patient IDs for inactive matches'
print 'Inactive FLDOB match'
update #parsedpopfile
set matchpatientid = 
	(
		select pp.PATIENT_ID 
		from PATIENTS_Patient pp  
		inner join PATIENTS_Client pc on 
			pp.PATIENT_ID = pc.PATIENT_ID 
			and pp.DATE_OF_BIRTH = #parsedpopfile.DOB 
			and #parsedpopfile.STUDFNAME = pp.FIRST_NAME 
			and #parsedpopfile.STUDLNAME = pp.LAST_NAME
			and pp.ACTIVE = 'N'
		and pc.CLIENT_ID = clientid
	)
where isInactiveMatch = 1 and iCountFLDOB = 1 and Not (iCountCSIS_FLDOB =1) and not (iCountSSN_FLDOB = 1) --match on FLDOB
and MatchPatientID is null

print 'Match on FLDOB & CSIS'
update #parsedpopfile
set MatchPatientID = 
(
	select pp.PATIENT_ID
		from PATIENTS_Patient pp  
		inner join PATIENTS_Client pc on 
			pp.PATIENT_ID = pc.PATIENT_ID 
			and pp.CSIS = #parsedpopfile.CSIS
			and pp.DATE_OF_BIRTH = #parsedpopfile.DOB
			and #parsedpopfile.STUDFNAME = pp.FIRST_NAME 
			and #parsedpopfile.STUDLNAME = pp.LAST_NAME
			and pp.ACTIVE = 'N'
		and pc.CLIENT_ID = clientid
		where #parsedpopfile.CSIS <> ''
		)
where isInactiveMatch = 1 and (iCountCSIS_FLDOB =1) and not (iCountSSN_FLDOB = 1) --match on FLDOB & CSIS
and MatchPatientID is null

print 'Match on FLDOB & SSN'
update #parsedpopfile 
set MatchPatientID = 
(
		select pp.PATIENT_ID 
		from PATIENTS_Patient pp  
		inner join PATIENTS_Client pc on 
			pp.PATIENT_ID = pc.PATIENT_ID 
			and pp.SSN = #parsedpopfile.SSN
			and pp.DATE_OF_BIRTH = #parsedpopfile.DOB
			and #parsedpopfile.STUDFNAME = pp.FIRST_NAME 
			and #parsedpopfile.STUDLNAME = pp.LAST_NAME
			and pp.ACTIVE = 'N'
		and pc.CLIENT_ID = clientid
		where #parsedpopfile.SSN <> ''
)
where isinactiveMatch = 1 and  (iCountSSN_FLDOB = 1) --match on FLDOB & SSN
and MatchPatientID is null


print 'SCHSTUDID MATCHES'
print 'ACTIVE MATCHES'
update #parsedpopfile
set MatchPatientID = 
	(
		select pp.PATIENT_ID 
		from PATIENTS_Patient pp  
		inner join PATIENTS_Client pc on 
			pp.PATIENT_ID = pc.PATIENT_ID 
			and pp.DATE_OF_BIRTH = #parsedpopfile.DOB 
			and #parsedpopfile.STUDFNAME = pp.FIRST_NAME 
			and #parsedpopfile.STUDLNAME = pp.LAST_NAME
			and pp.ACTIVE = 'Y'
		and pc.CLIENT_ID = clientid
		inner join PATIENTS_School ps on 
			ps.PATIENT_ID = pp.PATIENT_ID 
			and ps.SITE_ID = siteid 
			and ps.STUDENT_ID = SCHSTUDID
		where checkSCHSTUDID = 1
	)
where CountActiveSCHSTUDID = 1

print 'INACTIVE MATCHES'
update #parsedpopfile
set MatchPatientID = 
	(
		select pp.PATIENT_ID 
		from PATIENTS_Patient pp  
		inner join PATIENTS_Client pc on 
			pp.PATIENT_ID = pc.PATIENT_ID 
			and pp.DATE_OF_BIRTH = #parsedpopfile.DOB 
			and #parsedpopfile.STUDFNAME = pp.FIRST_NAME 
			and #parsedpopfile.STUDLNAME = pp.LAST_NAME
			and pp.ACTIVE = 'N'
		and pc.CLIENT_ID = clientid
		inner join PATIENTS_School ps on 
			ps.PATIENT_ID = pp.PATIENT_ID 
			and ps.SITE_ID = siteid 
			and ps.STUDENT_ID = SCHSTUDID
		where checkInactiveSCHSTUDID = 1
	)
where CountinActiveSCHSTUDID = 1


/* Do patient inserts and updates */



BEGIN TRANSACTION

/*
Okay, this is a little tetchy. In order to match up a kid with their patient record, 
we have to link the file identity ROW_NUM to the identity patient_id. 

Since the OUTPUT on an INSERT INTO only lets us talk about the values in columns that we've just inserted
(the FROM block in output only works for update/delete?)

So, we take the ROW_NUM from the file and insert it into the SSN field when we create a new patient.
That way we can run the OUTPUT for the PATIENT_ID and the 'SSN' for that patient (containing the ROW_NUM)
and derive the relationship between the newly inserted patient records and the file rows they came from.

Once we have this relationship, we can export it to another table and fill in the SSN field with a proper UPDATE statement.
*/
declare @tempfilepatcorr table (patient_id bigint, file_row_num bigint)

print 'create base patient record'
insert into PATIENTS_Patient (SSN,LAST_NAME,FIRST_NAME,MIDDLE_NAME,DATE_OF_BIRTH, SEX, CSIS, DATE_CREATED, LAST_UPDATED, LASTPOP, ACTIVE, CONCAT_NAME)
output inserted.PATIENT_ID, inserted.SSN as FILE_ROW_NUM into @tempfilepatcorr
select case_A_line_ID, STUDLNAME, STUDFNAME, STUDMI, DOB, SEX, CSIS, GETDATE(), GETDATE(), GETDATE(), 'Y', STUDLNAME  + ', ' + STUDFNAME from #parsedpopfile
where (matchpatientid is null
and #parsedpopfile.Errorcode not like '%SCHSTUDID%')  --multiple schstudid matches means Jaime needs to take a look.
or NotFound = 1

print 'associate patient in file with patient record'
update #parsedpopfile
set CreatedPatientID = tfpc.patient_id
from @tempfilepatcorr tfpc
where tfpc.file_row_num = #parsedpopfile.case_A_line_ID


update PATIENTS_Patient
set SSN = #parsedpopfile.SSN
from #parsedpopfile
where PATIENTS_Patient.PATIENT_ID = CreatedPatientID

--and then create client and site data
print 'create client link data for new patient records'

insert into PATIENTS_Client (CLIENT_ID, PATIENT_ID, START_DATE, END_DATE)
--output inserted.PATIENT_ID as newclients
select clientid, CreatedPatientID, GETDATE(), DATEADD(year, 5, getdate())
from #parsedpopfile
where #parsedpopfile.CreatedPatientID is not null

print 'create site link data for new patient records'
insert into patients_school (SITE_ID, PATIENT_ID, GRADE, STUDENT_ID, START_DATE, END_DATE)
--output inserted.PATIENT_SCHOOL_ID, inserted.PATIENT_ID as newsites, inserted.SITE_ID
select siteid, CreatedPatientID, grade, schstudid, GETDATE(), DATEADD(year, 5, getdate())
from #parsedpopfile
where #parsedpopfile.CreatedPatientID is not null


/* Create IEP records. All Casemis patients have an IEP, but we don't want to create duplicate IEP records. */

print 'create IEP/IFSP link data for new patient records'
insert into PATIENTS_IEP (PATIENT_ID, IEP_IFSP_NONE)
--output inserted.PATIENT_ID as  NEW_IEPs
select CreatedPatientID, 
	CASE 
		when DATEADD(year, 3, dob) < getdate() then 'IEP'  
		when DATEADD(year, 3, dob) > getdate() then 'IFSP'
	END
		from #parsedpopfile pp
left outer join PATIENTS_IEP piep on pp.CreatedPatientID = piep.PATIENT_ID
where pp.CreatedPatientID is not null and piep.PATIENT_ID is null




--new patients have been created. Next, update already-existing patients:

update PATIENTS_Patient --part 1; need special checking for when we handle SSN and CSIS data - don't want to overwrite what we've got there. 
set LAST_NAME = STUDLNAME, 
	FIRST_NAME = STUDFNAME, 
	MIDDLE_NAME = STUDMI, 
	DATE_OF_BIRTH = dob,
	SEX = [#parsedpopfile].SEX, 
	CONCAT_NAME = STUDLNAME  + ', ' + STUDFNAME, 
	LAST_UPDATED= GETDATE(), 
	LASTPOP = GETDATE(),
	ACTIVE = 'Y'
--output inserted.PATIENT_ID as updated1
from #parsedpopfile
where #parsedpopfile.MatchPatientID = PATIENTS_Patient.PATIENT_ID

update PATIENTS_Patient
set SSN = #parsedpopfile.SSN
--output inserted.PATIENT_ID as updated1_SSN
from #parsedpopfile
where 
	(
		rtrim(ltrim(#parsedpopfile.ssn)) <> '' 
		or 
		PATIENTS_Patient.ssn = ''
	)  
	and len(rtrim(ltrim(#parsedpopfile.ssn))) = 9 
	and ltrim(rtrim(patients_patient.SSN)) <> ltrim(rtrim(#parsedpopfile.ssn))
	and  #parsedpopfile.MatchPatientID = PATIENTS_Patient.PATIENT_ID

update PATIENTS_Patient
set csis = #parsedpopfile.CSIS
--output inserted.PATIENT_ID as updated1_CSIS
from #parsedpopfile
where 
	(
		rtrim(ltrim(#parsedpopfile.csis)) <> '' 
		or 
		PATIENTS_Patient.CSIS = ''
	)  
	and len(rtrim(ltrim(#parsedpopfile.CSIS))) = 10 
	and ltrim(rtrim(patients_patient.CSIS)) <> ltrim(rtrim(#parsedpopfile.CSIS))
	and #parsedpopfile.MatchPatientID = PATIENTS_Patient.PATIENT_ID




--update IEP/IFSP/NONE data

/* All Casemis patients have an IEP */

update PATIENTS_IEP
set IEP_IFSP_NONE = 
	CASE 
		when DATEADD(year, 3, dob) < getdate() then 'IEP'  
		when DATEADD(year, 3, dob) > getdate() then 'IFSP'
	END
	
from #parsedpopfile
where #parsedpopfile.MatchPatientID = PATIENTS_IEP.PATIENT_ID


--No need to update a patient's client record

--Update site - find their current site and close it out if it's different from what's in file. Create a new site record.

--locate current site entry for current client and link it in temp table
print 'linking site entry to file patient'
update #parsedpopfile
	set currentpatientsiteid = schoolstuff.PATIENT_SCHOOL_ID
	from
	(
		select ps.PATIENT_SCHOOL_ID, ps.PATIENT_ID from PATIENTS_School ps
		inner join #parsedpopfile on #parsedpopfile.MatchPatientID = ps.PATIENT_ID
		inner join SITES_Site ss on ps.SITE_ID = ss.SITE_ID and ss.SITE_CLIENT_ID = #parsedpopfile.clientid
	) as schoolstuff
where #parsedpopfile.MatchPatientID = schoolstuff.PATIENT_ID

		
		
	print 'Updating site entry in client for patient'
	--if site record exists for that patient in that client, lolo the file data into the school-patient relationship entry.
	update PATIENTS_School
	set SITE_ID = ppf.siteid,
		GRADE = ppf.GRADE,
		STUDENT_ID = ppf.SCHSTUDID,
		start_date = getdate(),
		END_DATE = DATEADD(year, 5, getdate())
	--output inserted.PATIENT_SCHOOL_ID, inserted.PATIENT_ID as updatepatientsite, inserted.SITE_ID
	from #parsedpopfile ppf inner join SITES_Site on siteid = SITE_ID
	where PATIENTS_School.PATIENT_SCHOOL_ID = 
		(select top 1 PATIENT_SCHOOL_ID 
		from PATIENTS_School 
		where	PATIENTS_School.PATIENT_ID = ppf.MatchPatientID 
				and PATIENTS_School.PATIENT_SCHOOL_ID = currentpatientsiteid 
		order by END_DATE desc)


--and flag any that come up with that issue
update #parsedpopfile
set Errorcode = ISNULL(Errorcode,'') + ' NO_SITE_FOUND '
where currentpatientsiteid is null and CreatedPatientID is null and MatchPatientID is not null

select '' AS FULL_ERROR_RPT,  #parsedpopfile.*, pp.*, pc.*, ps.*, piep.* from #parsedpopfile 
left outer join PATIENTS_Patient pp on pp.PATIENT_ID = #parsedpopfile.CreatedPatientID or pp.PATIENT_ID = #parsedpopfile.MatchPatientID  --and pp.LAST_NAME = #parsedpopfile.STUDLNAME
left outer join PATIENTS_Client pc on pc.PATIENT_ID = pp.PATIENT_ID and pc.CLIENT_ID = #parsedpopfile.clientid
left outer join PATIENTS_School ps on ps.PATIENT_ID = pp.PATIENT_ID and ps.SITE_ID = #parsedpopfile.siteid
left outer join patients_iep piep on piep.PATIENT_ID = pp.PATIENT_ID
where Errorcode is not null or createdpatientid is not null

select count (*) as FoundMatchCount from #parsedpopfile --where siteid is null --where checkSCHSTUDID is not null or checkInactiveSCHSTUDID is not null
left outer join PATIENTS_Patient pp on pp.PATIENT_ID = #parsedpopfile.CreatedPatientID or pp.PATIENT_ID = #parsedpopfile.MatchPatientID  --and pp.LAST_NAME = #parsedpopfile.STUDLNAME
left outer join PATIENTS_Client pc on pc.PATIENT_ID = pp.PATIENT_ID and pc.CLIENT_ID = #parsedpopfile.clientid
left outer join patients_iep piep on piep.PATIENT_ID = pp.PATIENT_ID
where MatchPatientID is not null

select count (*) as NotFoundMatchCount from #parsedpopfile --where siteid is null --where checkSCHSTUDID is not null or checkInactiveSCHSTUDID is not null
left outer join PATIENTS_Patient pp on pp.PATIENT_ID = #parsedpopfile.CreatedPatientID or pp.PATIENT_ID = #parsedpopfile.MatchPatientID  --and pp.LAST_NAME = #parsedpopfile.STUDLNAME
left outer join PATIENTS_Client pc on pc.PATIENT_ID = pp.PATIENT_ID and pc.CLIENT_ID = #parsedpopfile.clientid
left outer join patients_iep piep on piep.PATIENT_ID = pp.PATIENT_ID
where MatchPatientID is null
			
select count (*)  as CreatedPatientCount from #parsedpopfile --where siteid is null --where checkSCHSTUDID is not null or checkInactiveSCHSTUDID is not null
left outer join PATIENTS_Patient pp on pp.PATIENT_ID = #parsedpopfile.CreatedPatientID or pp.PATIENT_ID = #parsedpopfile.MatchPatientID  --and pp.LAST_NAME = #parsedpopfile.STUDLNAME
left outer join PATIENTS_Client pc on pc.PATIENT_ID = pp.PATIENT_ID and pc.CLIENT_ID = #parsedpopfile.clientid
left outer join patients_iep piep on piep.PATIENT_ID = pp.PATIENT_ID
where CreatedPatientID is not null

/* Link the CASEMIS-A file records to the patient records we've updated/created */

update CASEMIS_FILES_A_STUDENTS 
set patient_id = COALESCE(MatchPatientID, createdpatientid) 
from #parsedpopfile 
where #parsedpopfile.case_A_line_ID = Line_ID and Casemis_File_ID = @CASEMIS_FILE_ID


/* Create population file records for this CASEMIS file */

insert into population_files (file_name, client_ID, upload_date, is_full_file, CASEMIS_FILE_ID)
select 
	'FCASEMIS-' + (select cc.ShortName from CLIENTS_Client cc where cc.CLIENT_ID = @current_client),
	(select top 1 clientid from #parsedpopfile),
	GETDATE(),
	1,
	@CASEMIS_FILE_ID

declare @file_ID bigint = scope_identity()

insert into population_file_patients (file_id, patient_id)
select
	@file_ID,
	CreatedPatientID
from #parsedpopfile
where CreatedPatientID is not null

insert into population_file_patients (file_id, patient_id)
select
	@file_ID,
	MatchPatientID
from #parsedpopfile 
where MatchPatientID is not null




/* ID any casemis patients from the file who were not matched. */
select '' as TOTAL_MATCH_FAIL, * from CASEMIS_FILES_A_STUDENTS where Casemis_File_ID = @CASEMIS_FILE_ID and patient_id is null


--if this wasn't a proper run
if @istestrun = 1
	BEGIN
	print 'Test run - undoing inserts & updates'
	ROLLBACK TRANSACTION
	END
else
	BEGIN
	print 'Not a test run - committing changes to database.'
	commit transaction
	END



DROP TABLE #parsedpopfile

END