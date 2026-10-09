USE SPEDMON
GO

if OBJECT_ID('Claims_Write_5010_837_File') is not null
        drop procedure Claims_Write_5010_837_File
go

CREATE procedure dbo.Claims_Write_5010_837_File
(
	  @generationID    bigint
	, @transmission_id bigint
	, @IncomingClaims BIGINT_TableType READONLY
	, @Path VARCHAR(255)
	, @Filename VARCHAR(100)
) as 
BEGIN

/******************************************************

NB:
the CLM segment in the 2300 loop is incomplete - we do 
not include batch number or RUNSEQ data. 

Look into filling this out after we get the file-generation stuff complete.

additionally the CLM segment has the literal-string 
***89:A:1*Y*C*Y*N*********N~
Since this doesn't seem to change from file to file, I'm leaving it as-is.
CLM05: Health Care Service Location Information
	89 is facility type code 'Special facility - other'						(1331)
	A is facility code qualifier 'Uniform Billing Claim Form Bill Type'		(1332)
	1 is Claim Frequency Code. "1": Admit thru Discharge.					(1325)
CLM06: Provider Signature on File
	Y: yes
CLM07: Medicare Assignment Code
	C: Not Assigned
CLM08: Benefit Assigned
	Y: Yes
CLM09: Release of Information Code
	N: No, Provider is Not Allowed to Release Data

********* (Elements 10-17 not used)
CLM18: Explanation of Benefits Indicator
	N: No
	
(Protip: It's also only used by EDS: Since we're not EDS, leaving the string as is shouldn't hurt anything.)



******************************************************/

--select * from @incomingClaims

--prep sample data
--declare @incomingclaims table(claim_id bigint)
--insert into @incomingclaims
--select top 24000  CLAIM_ID from CLAIM_Claim cc
--inner join PATIENTS_Patient pp on cc.PATIENT_ID = pp.PATIENT_ID and LEN(pp.bic) =14
----where --STATUS = 1 and 
----	--client_ID <> 112
--where CLAIM_ID in
--(select CLAIM_ID from #h837_test_table)

--end sample data prep, actual routine stuff begins below
--print CONVERT(NVARCHAR(MAX), getdate(),21) + ' ' + 'Finish loading test data'



/*
	Submitter identifiers and contact information
	
	At some point, the submitter identifier or point of contact may change for the organization. 
	To facilitate changes in the future (and limit 'magic number' syndrome, I'm pulling out some 
	of these elements into variables for later editing.
	
	For future consideration: This sproc might take a UserID input, and use information in the 
	user's record to build contact information for the 837 file.
*/

/* Get claim source */

declare @claimSource   as bigint  = 1
declare @claimFreqCode as char(1) = '1'
declare @includeCCN    as bit     = 0
declare @useLxOf1      as bit     = 0

select top 1 
    @claimSource = isnull(tg.claimSource,1)
from dbo.TRANSMISSION_GENERATIONS as tg
where (tg.id = @generationID)

/* 837 contains all new claims for current claiming window */

if (@claimSource = 1) 
begin
  set @claimFreqCode = '1'
  set @includeCCN     = 0
  set @useLxOf1       = 0
end

/* 837 contains all retroactive claims */

else if (@claimSource = 2) 
begin
  set @claimFreqCode = '1'
  set @includeCCN     = 0
  set @useLxOf1       = 0
end

/* 837 contains all voided claims */

else if (@claimSource = 3) 
begin
  set @claimFreqCode = '8' /* Void*/
  set @includeCCN     = 1
  set @useLxOf1       = 1
end

/* Default */
else
begin
  set @claimSource    = 1
  set @claimFreqCode  = '1'
  set @includeCCN     = 0
  set @useLxOf1       = 0
end

declare @cmc_submitter_ID nchar(3) = '9A7', --9A7 is the Medi-Cal submitter identifier for SBSC
		@poc_name nchar(60)  = 'VICTORIA ROHL SPITSYN',
		@poc_phone nchar(80) = '9163751707', /* the element before this one MUST be 'TE' (signifying this field is a telephone number); additionally, ACS requires no non-numeric characters for phone numbers */
		@org_name nchar(33)  = 'SCHOOL BUSINESS SERVICES OF CALI'


/********************************************************************

As of 10/1/2015, claims submitted to Medi-Cal with a DOS on or after this date MUST use an ICD-10 diagnosis code.

Claims with a DOS before the switchover still use the ICD-9.

********************************************************************/

declare @diagnosis_code_switchover_date date = '20151001'

/*
 * AS of 1/1/2019 Medi-Cal providers are supposed to use a 4 digit revenue code.
 * The guidance we have received from DHCS as of 12/18/2018 has instructed us to
 * continue to use the 3 digit revenue code 001 for all claims even on or after
 * 1/1/2019.  We have left cutover logic in place just in case DHCS changes their mind.
 */
 
declare @revCode3To4DigitCutover as datetime = convert(datetime,'1/1/2019 00:00:00')


--select COUNT (*) as '# of claims' from @incomingclaims

if OBJECT_ID('tempdb..#claim_index_table') is not null
begin 
	drop table #claim_index_table
end

Create table #claim_index_table 
	(
		row_id		bigint identity, 
		claim_id		bigint, 
		district_id	bigint, 
		patient_id	bigint, 
		dist_id_chng	bit, 
		pat_id_chng	bit, 
		has_orp        bit,
		pat_clm_num	bigint
	)

insert into #claim_index_table (claim_id,district_id,patient_id, has_orp)
select cc.CLAIM_ID, cc.CLIENT_ID,cc.PATIENT_ID, has_orp = convert(bit,case when (cc.ORP_PRACTITIONER_ID is not null) then 1 else 0 end) from @incomingclaims ic
inner join CLAIM_Claim cc on ic.id = cc.CLAIM_ID
order by cc.CLIENT_ID, cc.PATIENT_ID --Incoming claims should be sorted by client and patient for proper ordering and minimization of segment usage..

print CONVERT(NVARCHAR(MAX), getdate(),21) + ' ' + 'Mark out patient and district change points'

--BLOCK 1
--cless loop for marking when districts and patients change for loop identification.
declare @iterator bigint
declare @curr_dist_val bigint
declare @curr_pat_val bigint
declare @tbl_max bigint

set @iterator = 1
set @curr_dist_val = NULL
set @curr_pat_val = null
set @tbl_max = (select MAX(row_id) from #claim_index_table)

while @iterator <= @tbl_max
	begin
		if @curr_dist_val <> (select district_id from #claim_index_table where row_id = @iterator)
			or @curr_dist_val is null
			BEGIN
				update #claim_index_table
				set dist_id_chng = 1
				where row_id = @iterator
				set @curr_dist_val = (select district_id from #claim_index_table where row_id = @iterator)
			END
		set @iterator = @iterator + 1
	END
	
	update #claim_index_table
	set pat_clm_num = 1 where pat_id_chng =1 

--this creates a patient loop for each claimline, similar (hopefully) to how the current h837 process works
--it produces larger files, but cuts down the runtime by about 2/3rds as compared to a 'proper' ordering where multiple claims exist within a patient loop.
update #claim_index_table
set pat_id_chng = 1


print CONVERT(NVARCHAR(MAX), getdate(),21) + ' ' + 'Build initial HL segment numbers'
--header and footer go around this

if OBJECT_ID('tempdb..#HL_SEQ_TBL') is not null
begin 
	drop table #HL_SEQ_TBL
end

--create loop identifiers for district and patient HL segments (loops 2000A, 2000B)

create table #HL_SEQ_TBL (HLCOUNT bigint identity, row_id bigint, MOD_HLCOUNT bigint)

insert into #HL_SEQ_TBL (row_id)
select row_id from #claim_index_table
where dist_id_chng =1
		or (dist_id_chng is null and pat_id_chng = 1)
		
update #HL_SEQ_TBL
set MOD_HLCOUNT = HLCOUNT
		
print CONVERT(NVARCHAR(MAX), getdate(),21) + ' ' + 'Get listing of dist & patient-change claimlines'
		
--Get a temp listing of all rows where district and patient changes occur at the same time (and therefore have 2000A and B HL segments)
declare @mult_hl_tbl table(row_num bigint)

insert into @mult_hl_tbl
select row_id from #claim_index_table
where dist_id_chng = 1 and pat_id_chng = 1


--Start looping to properly increment HL after each multiple-HL line
--since every line where the dist and pat ID change has two HL segments, the starting HL for all lines -after- that line is incremented by one; this is done for every double-HL line in the file.
set @iterator = 1
--set @tbl_max = (select count (*) from @mult_hl_tbl)


while (select COUNT(*) from @mult_hl_tbl) >0
	BEGIN
	update #HL_SEQ_TBL
	set MOD_HLCOUNT = MOD_HLCOUNT+1
	where row_id > (select top 1 row_num from @mult_hl_tbl order by row_num desc)
	
	delete from @mult_hl_tbl where row_num = (select top 1 row_num from @mult_hl_tbl order by row_num desc)
	END
print CONVERT(NVARCHAR(MAX), getdate(),21) + ' ' +'finish multi-HL-line update'


--/*reporting table check (diagnostic only)*/
--select cit.row_id, cit.claim_id, dist_id_chng, *,
--	( 
--		select top 1 MOD_HLCOUNT
--		from #claim_index_table cit1 
--		inner join #HL_SEQ_TBL hst on cit1.row_id = hst.row_id 
--		where cit1.district_id = cit.district_id order by cit1.row_id 
--	) as parentHL

-- from #claim_index_table cit
--left outer join #HL_SEQ_TBL on cit.row_id = #HL_SEQ_TBL.row_id
--order by cit.row_id


if OBJECT_ID('tempdb..#Final_prep_claims') is not null
begin 
	drop table #final_prep_claims
end

create table #final_prep_claims (
    row_id bigint
  , claim_id bigint
  , dist_id_chng bit
  , pat_id_chng bit
  , has_orp bit
  , HLCOUNT bigint
  , parentHL bigint
  , printdata nvarchar (max))

insert into #final_prep_claims
select cit.row_id, cit.claim_id, dist_id_chng, pat_id_chng, cit.has_orp, mod_hlcount,
	( 
		select top 1 mod_HLCOUNT
		from #claim_index_table cit1 
		inner join #HL_SEQ_TBL hst on cit1.row_id = hst.row_id 
		where cit1.district_id = cit.district_id order by cit1.row_id 
	) as parentHL, ''

 from #claim_index_table cit
left outer join #HL_SEQ_TBL on cit.row_id = #HL_SEQ_TBL.row_id
order by cit.row_id

--Prepwork finished, now we start appending data to build the 837 file
print CONVERT(NVARCHAR(MAX), getdate(),21) + ' ' + ' Start building 837'
--Definitions as per the 837_v4010A1_data_specs_cg01.pdf in the 837 Companion Guide package
--at http://files.medi-cal.ca.gov/pubsdoco/hipaa/hipaaspecs_home.asp as of March 2010
declare @segterm char = '~'		/* Segment Terminator */
declare @el_sep char = '*'		/* Element Seperator */
declare @subel_sep char = ':'	/* Subelement Seperator */
declare @rep_sep char = '^'		/* Repetition Seperator - see ISA11 */

declare @group_ctrl_num nvarchar(9) = LEFT(convert (nvarchar(max), 1234567890),9)
declare @trans_ctrl_num nvarchar(9) = RIGHT( '0000000000' + RIGHT(convert(nvarchar(max), @transmission_id),9),9) --'SBSC01' --field must be a minimum of 4 characters
declare @interchange_ctrl_num nvarchar(9) = LEFT('2' + convert (nvarchar(max), YEAR(getdate())) + RIGHT('0000' + convert(nvarchar(max), @transmission_id), 4),9)

declare @837Header nvarchar(max) -- ISA header, 1000 A and B loops.
set @837Header = 
	'ISA' +@el_sep + '00'+ @el_sep +'          '+ @el_sep +'00'+ @el_sep +'          '+ @el_sep +'ZZ'+ @el_sep + @cmc_submitter_ID + '            '+ @el_sep +'ZZ'+ @el_sep +'610442         '+ @el_sep 
		+ RIGHT(CONVERT(nvarchar(max),YEAR(GETDATE())),2) + RIGHT('0'+ CONVERT(NVARCHAR(MAX),MONTH(GETDATE())),2) + RIGHT('0'+ CONVERT(NVARCHAR(MAX), DAY(GETDATE())),2) + @el_sep 
		+ RIGHT('0'+ CONVERT(NVARCHAR(MAX),DATEPART(hour,GETDATE())),2) + RIGHT('0'+ CONVERT(NVARCHAR(MAX),DATEPART(minute,GETDATE())),2) + @el_sep 
		+ @rep_sep + @el_sep +'00501'+ @el_sep +@interchange_ctrl_num+ @el_sep +'0'+ @el_sep +'T'+ @el_sep + @subel_sep 
		--The last significant element in this segment ('T') indicates the current file is only to be used for testing. Nobody (ACS,HP, EDS) seems to care though - they process claims as normal.
	
	+ @segterm +
	'GS'+ @el_sep +'HC'+ @el_sep + @cmc_submitter_ID + @el_sep +'610442'+ @el_sep + 
		CONVERT(nvarchar(max),YEAR(GETDATE())) + RIGHT('0'+ CONVERT(NVARCHAR(MAX),MONTH(GETDATE())),2) + RIGHT('0'+ CONVERT(NVARCHAR(MAX), DAY(GETDATE())),2)
		+ @el_sep +
		RIGHT('0'+ CONVERT(NVARCHAR(MAX),datepart(HOUR, GETDATE())),2) + RIGHT('0'+ CONVERT(NVARCHAR(MAX),datepart(MINUTE, GETDATE())),2)
		+ @el_sep + @group_ctrl_num + @el_sep +'X'+ @el_sep +'005010X223A2'
	+ @segterm +
	'ST'+ @el_sep +'837'+ @el_sep + @trans_ctrl_num+@el_sep+'005010X223A2'
	+@segterm+
	'BHT'+ @el_sep +'0019'+ @el_sep +'00'+ @el_sep + LEFT('SBSC01',30)+ @el_sep +
		CONVERT(nvarchar(max),YEAR(GETDATE())) + RIGHT('0'+ CONVERT(NVARCHAR(MAX),MONTH(GETDATE())),2) + RIGHT('0'+ CONVERT(NVARCHAR(MAX), DAY(GETDATE())),2)
		+ @el_sep +
		RIGHT('0'+ CONVERT(NVARCHAR(MAX),datepart(HOUR, GETDATE())),2) + RIGHT('0'+ CONVERT(NVARCHAR(MAX),datepart(MINUTE, GETDATE())),2)
		+ @el_sep +'CH'
	+@segterm +
	'NM1'+ @el_sep +'41'+ @el_sep +'2'+ @el_sep + @org_name + @el_sep +''+ @el_sep +''+ @el_sep +''+ @el_sep +''+ @el_sep +'46'+ @el_sep +@cmc_submitter_ID
	+@segterm+ 
	'PER'+ @el_sep +'IC'+ @el_sep + RTRIM(@poc_name) + @el_sep +'TE'+ @el_sep + RTRIM(@poc_phone)
	+ @segterm +
	'NM1'+ @el_sep +'40'+ @el_sep +'2'+ @el_sep +'MEDI-CAL'+ @el_sep +''+ @el_sep +''+ @el_sep +''+ @el_sep +''+ @el_sep +'46'+ @el_sep +'610442'
	+@segterm


--Initialize 837 2000A and 2010AA loop for each client
update #final_prep_claims
set printdata =	
	'HL' + @el_sep + CONVERT(varchar(max), HLCOUNT) + @el_sep + @el_sep + '20' + @el_sep + '1' 
		+ @segterm +
	'PRV' + @el_sep + 'BI' + @el_sep + 'PXC' + @el_sep + '261QS1000X' 
		+ @segterm +
				--261QS1000X is the taxonomy code for 'Student Health: Active', 
				--as listed in http://files.medi-cal.ca.gov/pubsdoco/npi/docs/taxonomy_61.pdf
				--Alternate source of listings in http://codelists.wpc-edi.com/nucc_frameset.htm 

	'NM1' + @el_sep + '85' + @el_sep + '2' + @el_sep +
		UPPER(LEFT((select CLIENT_NAME from CLAIM_Claim cla inner join CLIENTS_Client cli on cla.CLIENT_ID = cli.CLIENT_ID where cla.CLAIM_ID= #final_prep_claims.claim_id),33))
		+ @el_sep + @el_sep + @el_sep + @el_sep + @el_sep + 'XX' + @el_sep +
		(select NPI from CLAIM_Claim cla inner join CLIENTS_Client cli on cla.CLIENT_ID = cli.CLIENT_ID where cla.CLAIM_ID= #final_prep_claims.claim_id) 
		+ @segterm +
			
	'N3' + @el_sep + 
		UPPER(LEFT((select REPLACE(ADDRESS_1,'.','') from CLIENTS_Address cli inner join CLAIM_Claim cla on cli.CLIENT_ID = cla.CLIENT_ID and cla.CLAIM_ID = #final_prep_claims.claim_id), 26)) + 
		ISNULL( UPPER(LEFT((select @el_sep + REPLACE(ADDRESS_2,'.','') + @segterm from CLIENTS_Address cli inner join CLAIM_Claim cla on cli.CLIENT_ID = cla.CLIENT_ID and cla.CLAIM_ID = #final_prep_claims.claim_id where ADDRESS_2 <> ''), 26)), @segterm) +
				
	'N4' + @el_sep + 
		(select UPPER(LEFT(city, 18)) + @el_sep + STATE + @el_sep+ LEFT( ZIP+ isnull(ZIP_PLUS_FOUR,''),9) from CLIENTS_Address cli inner join CLAIM_Claim cla on cli.CLIENT_ID = cla.CLIENT_ID and cla.CLAIM_ID = #final_prep_claims.claim_id) 
		+ @segterm +
					
	'REF' + @el_sep + 'EI' + @el_sep +
		UPPER(LEFT((select TAX_ID from CLIENTS_Client cli inner join CLAIM_Claim cla on cli.CLIENT_ID = cla.CLIENT_ID and cla.CLAIM_ID = #final_prep_claims.claim_id), 9)) 
		+ @segterm
	--The old 837 stuff from HEBS doesn't appear to use the PER segment, so neither will we.	
where dist_id_chng = 1

			
--Setup 837 2000B and 2010BA patient loop
update #final_prep_claims
set printdata = printdata + 
	'HL' + @el_sep + CONVERT(varchar(MAX),HLCOUNT+1) + @el_sep + CONVERT(varchar(MAX), parentHL) + @el_sep + '22' + @el_sep + '0' 
		+ @segterm 
where pat_id_chng = 1 and dist_id_chng = 1

update #final_prep_claims
set printdata = printdata + 
	'HL' + @el_sep + CONVERT(varchar(MAX),HLCOUNT) + @el_sep + CONVERT(varchar(MAX), parentHL) + @el_sep + '22' + @el_sep + '0' 
		+ @segterm 
where pat_id_chng = 1 and dist_id_chng is null

update #final_prep_claims
set printdata = printdata + 
	'SBR' + @el_sep+ 'P' + @el_sep+'18'+ @el_sep+ @el_sep+ @el_sep+ @el_sep+ @el_sep+ @el_sep + @el_sep + 'MC' 
		+ @segterm +
		
	--2010BA starts
	'NM1' + @el_sep + 'IL' + @el_sep + '1'+ @el_sep +
		UPPER(LEFT((select top 1 LAST_NAME = dbo.PATIENT_5010_837_SELECT_NAME_TO_USE_FOR_CLAIM_LAST_OR_FIRST (pp.LAST_NAME, pp.FIRST_NAME, pp.DHCS_LAST_NAME, pp.DHCS_FIRST_NAME,'L') from PATIENTS_Patient pp inner join CLAIM_Claim cc on pp.PATIENT_ID = cc.PATIENT_ID and cc.CLAIM_ID = #final_prep_claims.claim_id),35))
		+ @el_sep +
		UPPER(LEFT((select top 1 FIRST_NAME = dbo.PATIENT_5010_837_SELECT_NAME_TO_USE_FOR_CLAIM_LAST_OR_FIRST (pp.LAST_NAME, pp.FIRST_NAME, pp.DHCS_LAST_NAME, pp.DHCS_FIRST_NAME,'F') from PATIENTS_Patient pp inner join CLAIM_Claim cc on pp.PATIENT_ID = cc.PATIENT_ID and cc.CLAIM_ID = #final_prep_claims.claim_id),25))	
		+ @el_sep + --the 837 spec provides field widths for first and last name that are longer than what medi-cal uses; Medi-cal looks at the first X characters in the field and simply discards the rest.
		--UPPER(LEFT((select ISNULL(MIDDLE_NAME,'') from PATIENTS_Patient pp inner join CLAIM_Claim cc on pp.PATIENT_ID = cc.PATIENT_ID and cc.CLAIM_ID = #final_prep_claims.claim_id),1))	
		--HEBS doesn't seem to use the middle name element, so we'll leave it out for now.
		+ @el_sep + @el_sep + @el_sep +'MI' + @el_sep +
		UPPER(LEFT((select BIC from PATIENTS_Patient pp inner join CLAIM_Claim cc on pp.PATIENT_ID = cc.PATIENT_ID and cc.CLAIM_ID = #final_prep_claims.claim_id),15))	
		+ @segterm +
		
	'N3' + @el_sep + 
		UPPER(LEFT((select REPLACE(ADDRESS_1,'.','') from CLIENTS_Address cli inner join CLAIM_Claim cla on cli.CLIENT_ID = cla.CLIENT_ID and cla.CLAIM_ID = #final_prep_claims.claim_id), 26)) + 
		ISNULL( UPPER(LEFT((select @el_sep + REPLACE(ADDRESS_2,'.','') + @segterm from CLIENTS_Address cli inner join CLAIM_Claim cla on cli.CLIENT_ID = cla.CLIENT_ID and cla.CLAIM_ID = #final_prep_claims.claim_id where ADDRESS_2 <> ''), 26)), @segterm) +
		
	'N4' + @el_sep + 
		(select UPPER(LEFT(city, 18)) + @el_sep + STATE + @el_sep+ LEFT( ZIP+ isnull(ZIP_PLUS_FOUR,''),9) from CLIENTS_Address cli inner join CLAIM_Claim cla on cli.CLIENT_ID = cla.CLIENT_ID and cla.CLAIM_ID = #final_prep_claims.claim_id) 
		+ @segterm +
		
	'DMG' + @el_sep + 'D8' + @el_sep + 
		LEFT((select CONVERT(nvarchar(max),YEAR(DATE_OF_BIRTH)) + RIGHT('0'+ CONVERT(NVARCHAR(MAX),MONTH(date_of_birth)),2) + RIGHT('0'+ CONVERT(NVARCHAR(MAX), DAY(date_of_birth)),2) from PATIENTS_Patient pp inner join CLAIM_Claim cc on pp.PATIENT_ID = cc.PATIENT_ID and cc.CLAIM_ID = #final_prep_claims.claim_id),8)
		+@el_sep + 
		UPPER(LEFT((select SEX from PATIENTS_Patient pp inner join CLAIM_Claim cc on pp.PATIENT_ID = cc.PATIENT_ID and cc.CLAIM_ID = #final_prep_claims.claim_id),1))	
		+ @segterm +
		
	'NM1' + @el_sep + 'PR' + @el_sep + '2' +  @el_sep +'MEDI-CAL OP' + @el_sep + 
		+ @el_sep  + @el_sep  + @el_sep  + @el_sep + 'XV' +@el_sep + '610442' 
		+ @segterm
where pat_id_chng = 1


--set up 2300+ loops for the actual claims on each line.

/* TODO: The CLM01 claim identifier element only accepts a maximum length of 20 characters (More is not against syntax, but Medi-cal or other payer has no obligation to provide the +20 chars when giving us an 835 */

/* This is a quick validation check using the changes to CLM identifer as of 20171004 */

if exists (select 1 from #final_prep_claims fpc where LEN(CONVERT(nvarchar(max),fpc.claim_id)) > 9)
begin 
	RAISERROR ('Some of the claim IDs in this transmission exceed the maximum length of 9 characters and would break existing format guidelines.',16,1)	
end
if exists (select 1 from #final_prep_claims fpc inner join Transmission_Record_Claims trc on fpc.claim_id = trc.claim_id and trc.transmission_id = @transmission_id where LEN(CONVERT(nvarchar(max),trc.trc_ID)) > 8)
begin 
	RAISERROR ('Some of the transmission-record-claim IDs in this transmission exceed the maximum length of 8 characters and would break existing format guidelines.',16,1)
end

update #final_prep_claims
	--Claim identifier; currently takes CLAIM_ID-TRC_ID to indicate that this is a spedcare claim as opposed to someone else's who hasn't updated their submitter info
set printdata = printdata + 
	'CLM' 
	+ @el_sep 
	+ LEFT(
			(
			select 
				  RIGHT('0000000000' + convert(nvarchar(max),cc.claim_id),9)
				+ '-' 
				+  RIGHT('0000000000' + convert(nvarchar(max),trc.trc_ID),8)
			from CLAIM_Claim cc 
				inner join Transmission_Record_Claims trc 
					on trc.claim_id = cc.CLAIM_ID 
					and trc.transmission_id = @transmission_id
			where 
				cc.CLAIM_ID = #final_prep_claims.claim_id
			),20)
		+@el_sep 
		+ (select LEFT(
		   convert(nvarchar(MAX),
		   (
		     select 
		       coalesce(trc.Amount_Transmitted,dbo.CLAIMS_AMOUNT_CALC(cc.CLAIM_ID)) 
	         from CLAIM_Claim cc 
		     inner join Transmission_Record_Claims trc on trc.claim_id = cc.CLAIM_ID and trc.transmission_id = @transmission_id
		     where 
		       cc.CLAIM_ID = #final_prep_claims.claim_id
		   )
		 ),9)) 
		+ @el_sep 		 
		+ @el_sep 
		+ @el_sep 
		/* CLM05.  Place of service is stored with claim procedure.  Claim frequency code varies based on claim source from generation record. */
		+ (select top 1 cp.PLACE_OF_SERVICE_CODE from CLAIM_Procedures cp inner join CLAIM_Claim cc on cp.PROCEDURE_ID = cc.PROCEDURE_ID and cc.CLAIM_ID = #final_prep_claims.claim_id) 
		+  @subel_sep 
		+ 'A' 
		+  @subel_sep 
		+ @claimFreqCode 
		+ @el_sep 
		+ 'Y' 
		+ @el_sep 
		+'C'
		+ @el_sep 
		+'Y'
		+ @el_sep 
		+'Y'
		+ @segterm 
		+ 'DTP' + @el_sep + '434' + @el_sep + 'RD8' +@el_sep + 
		/* 'FROM' date */
		LEFT((select CONVERT(nvarchar(max), YEAR(cc.SERVICE_DATE))+ RIGHT('0'+ CONVERT(nvarchar(max), month(cc.SERVICE_DATE)),2) + RIGHT('0'+ CONVERT(nvarchar(max), DAY(cc.SERVICE_DATE)),2) from CLAIM_Claim cc where cc.CLAIM_ID = #final_prep_claims.claim_id),8)
		+ '-' +
		/* 'THROUGH' date - same as FROM due to single service date */
		LEFT((select CONVERT(nvarchar(max), YEAR(cc.SERVICE_DATE))+ RIGHT('0'+ CONVERT(nvarchar(max), month(cc.SERVICE_DATE)),2) + RIGHT('0'+ CONVERT(nvarchar(max), DAY(cc.SERVICE_DATE)),2) from CLAIM_Claim cc where cc.CLAIM_ID = #final_prep_claims.claim_id),8)
		+ @segterm +		
		/* Add REF segment for CCN here if the claim source for this 837 requires it (voids or changes) */
		iif (
		   (@includeCCN = 1)
		  ,'REF' + @el_sep + 'F8' + @el_sep + (select top 1 RIGHT(N'0000000000000' + ISNULL(sac.ccn,N''),13) 
		  from dbo.CIF_REQUESTS_CLAIMS_VOID_SUBMISSIONS as sac 
		  where (sac.claimID = #final_prep_claims.claim_id) 		  
		  ) + @segterm
		  , ''
		)
		+
	/* HI Segment notes: BK refers to ICD-9. When switching to ICD-10, this becomes ABK */
	'HI' + @el_sep + 
		CASE
			WHEN (select SERVICE_DATE from CLAIM_Claim cc where cc.CLAIM_ID = #final_prep_claims.claim_id) < @diagnosis_code_switchover_date
				THEN 'BK' + @subel_sep + REPLACE((select LTRIM(RTRIM(cp.DIAGNOSIS_CODE)) from CLAIM_Procedures cp inner join CLAIM_Claim cc on cp.PROCEDURE_ID = cc.PROCEDURE_ID and cc.CLAIM_ID = #final_prep_claims.claim_id),'.','')
			WHEN (select SERVICE_DATE from CLAIM_Claim cc where cc.CLAIM_ID = #final_prep_claims.claim_id) >= @diagnosis_code_switchover_date
				THEN 'ABK' + @subel_sep + REPLACE((select LTRIM(RTRIM(cp.ICD_10_DIAGNOSIS_CODE)) from CLAIM_Procedures cp inner join CLAIM_Claim cc on cp.PROCEDURE_ID = cc.PROCEDURE_ID and cc.CLAIM_ID = #final_prep_claims.claim_id),'.','')
			ELSE 'FNORD'
		END
		+ @segterm +
	--2310A Loop
	CASE
	WHEN ((select top 1 cc.ORP_PRACTITIONER_ID from dbo.CLAIM_CLAIM as cc where ((cc.CLAIM_ID = #final_prep_claims.claim_id) and (#final_prep_claims.has_orp = 1))) IS NOT NULL)
	THEN
	  'NM1'
	  + @el_sep + '71' -- NM101 = 71 -- code for "Attending Physician" -- actually the ORP physician --required element
	  + @el_sep + '1'  -- NM102 = 1 -- code for "Person" -- required element
	  + (  select top 1          
	           @el_sep  + prp.LAST_NAME  -- 'LAST NAME' -- NM103 -- last name or organization name -- required element	   
	         + @el_sep  + prp.FIRST_NAME -- NM104 -- first name -- "Situational rule: required when the person has a first name"
              + @el_sep                   -- NM105 - middle name or initial -- "required when the middle name is needed to identify the individual" -- we are using NPI, so who cares
	         + @el_sep                   -- NM106 - name prefix - NOT USED AS PER SPEC
	         + @el_sep                   -- NM107 - name suffix - not required; we are using NPI
	         + @el_sep	+ 'XX'           -- NM108 - Identification code qualifier - says what kind of identification number we are using -- XX means NPI	
	         + @el_sep  + prp.npiNumber
	       from dbo.CLAIM_CLAIM               as cc 
	       join dbo.PRACTITIONER_Practitioner as prp on prp.PRACTITIONER_ID = cc.ORP_PRACTITIONER_ID
	     where (cc.CLAIM_ID = #final_prep_claims.claim_id)
	    )		
	  + @segterm
	ELSE '' END
	+
	/*
	'PRV'
	+ @el_sep + 'AT' -- PRV01 = AT -- "Attending"
	+ @el_sep + 'PXC' -- PRV02 -- says that we are using a Provider Taxonomy Code
	+ @el_sep + 'CODE' -- PRV03 -- the value of the taxonomy code
	+ @segterm +
	*/
	--2400 Loop
	'LX' + @el_sep + iif ( (@useLxOf1 = 0) 
	                      , (select convert(nvarchar(max),LINE_NUMBER) from CLAIM_Claim cc where cc.CLAIM_ID = #final_prep_claims.claim_id)
			              , '1')
			--this is copied data from the CLM segment above - HEBS uses an LX of 1 for all lines
		+ @segterm + 
	
	'SV2' + @el_sep 
	      + (select top 1 case when (cc.SERVICE_DATE >= @revCode3To4DigitCutover) then '0001' else '001' end
	         from dbo.CLAIM_Claim as cc where cc.CLAIM_ID = #final_prep_claims.claim_id) 
	      + @el_sep + 		

		+(select 'HC' + @subel_sep + LTRIM(RTRIM(PROCEDURE_CODE)) 
		+ isnull(@subel_sep + LTRIM(RTRIM(PROCEDURE_MODIFIER_1)),'')
		+ isnull(@subel_sep + LTRIM(RTRIM(PROCEDURE_MODIFIER_2)),'') 
		+ isnull(@subel_sep + LTRIM(RTRIM(PROCEDURE_MODIFIER_3)),'') 
		+ isnull(@subel_sep + LTRIM(RTRIM(PROCEDURE_MODIFIER_4)),'')  from dbo.CLAIM_Procedures cp inner join dbo.CLAIM_Claim cc on cp.PROCEDURE_ID = cc.PROCEDURE_ID and cc.CLAIM_ID = #final_prep_claims.claim_id)
		+ @el_sep + 		
		(SELECT LEFT(convert(nvarchar(MAX),(
		  select 
		    coalesce(trc.Amount_Transmitted,dbo.CLAIMS_AMOUNT_CALC(cc.CLAIM_ID)) 
	      from CLAIM_Claim cc 
		  inner join Transmission_Record_Claims trc on trc.claim_id = cc.CLAIM_ID and trc.transmission_id = @transmission_id
		  where 
		    cc.CLAIM_ID = #final_prep_claims.claim_id
		
		)),9))
		+ @el_sep + 'UN' + @el_sep + 
		(select convert(nvarchar(max), cc.SERVICE_UNITS) from CLAIM_Procedures cp inner join CLAIM_Claim cc on cp.PROCEDURE_ID = cc.PROCEDURE_ID and cc.CLAIM_ID = #final_prep_claims.claim_id) -- copied from CLM segment
		+ @segterm +
	'DTP' + @el_sep + '472' + @el_sep + 'D8' + @el_sep +
		LEFT((select CONVERT(nvarchar(max), YEAR(cc.SERVICE_DATE))+ RIGHT('0'+ CONVERT(nvarchar(max), month(cc.SERVICE_DATE)),2) + RIGHT('0'+ CONVERT(nvarchar(max), DAY(cc.SERVICE_DATE)),2) from CLAIM_Claim cc where cc.CLAIM_ID = #final_prep_claims.claim_id),8)
		+ @segterm
	
declare @837Footer nvarchar(max) = 
	'SE' + @el_sep + 
		--this is just the sum of the segments for the client, patient, and claim loops. 
		--It does NOT contain the segment counts for the entire file (ISA/IEA header/footer segments are not present)
		RIGHT (
			CONVERT( nvarchar(max),
				  ( select COUNT (*)*6  from #final_prep_claims)                         /* 6 segments in 2300 loop; in 5010 837, AMT segment was removed for each claim */
				+ ( select COUNT (*)*6  from #final_prep_claims where dist_id_chng = 1)  /* District change detail segments */
				+ ( select COUNT (*)*7  from #final_prep_claims where pat_id_chng  = 1)  /* patient identification detail segments, including HL marker for district */
				+ ( select COUNT (*)    from #final_prep_claims where has_orp      = 1)  /* Num of claims that have an ORP segement */
			    + ( select COUNT (*)    from #final_prep_claims where @includeCCN  = 1)  /* This 837 is a CIF void or change and has ccn segments */				
				+ 6 /* ST,SE, and segments between ST and first loop occurence (removes REF from transaction header (from 7 to 6) */
			)
		,10)
		+ @el_sep + @trans_ctrl_num 
		+ @segterm +
	'GE' + @el_sep + '1' + @el_sep + @group_ctrl_num 
		+ @segterm +
	'IEA' + @el_sep + '1' + @el_sep + @interchange_ctrl_num
		+ @segterm
		
	


/*claim segment diagnostic*/
/*select  #final_prep_claims.*,printdata, row_id as rowid 
from #final_prep_claims

*/

declare @printSegmentCount varchar(max)
set @printSegmentCount = CONVERT( nvarchar(max),
				  ( select COUNT (*)*6  from #final_prep_claims)                         /* 6 segments in 2300 loop; in 5010 837, AMT segment was removed for each claim */
				+ ( select COUNT (*)*6  from #final_prep_claims where dist_id_chng = 1)  /* District change detail segments */
				+ ( select COUNT (*)*7  from #final_prep_claims where pat_id_chng  = 1)  /* patient identification detail segments, including HL marker for district */
				+ ( select COUNT (*)    from #final_prep_claims where has_orp      = 1)  /* Num of claims that have an ORP segement */
				+ ( select COUNT (*)    from #final_prep_claims where @includeCCN  = 1)  /* This 837 is a CIF void or change and has ccn segments */				
				+ 6 /* ST,SE, and segments between ST and first loop occurence (removes REF from transaction header (from 7 to 6) */
			)

print ' SEGMENT_COUNT: ' + @printSegmentCount


declare @full837 nvarchar(max)

set @full837 = @837Header


set @full837 = @full837 + 
(
select printdata as [text()]
from #final_prep_claims
order by row_id
for XML PATH('')
)

set @full837 = @full837 + @837footer

print @full837

IF EXISTS (SELECT 1 FROM #final_prep_claims fpc where fpc.printdata IS NULL)
	BEGIN
		Select 'Error: claims in file generating NULL segments in printdata column:'
		SELECT * FROM #final_prep_claims fpc where fpc.printdata IS NULL
	END

ELSE 
	BEGIN
		print CONVERT(NVARCHAR(MAX), getdate(),21) + ' ' + ' Finish building 837'

		execute spedmon.dbo.writestringtofile @full837, @Path, @Filename
				
		print CONVERT(NVARCHAR(MAX), getdate(),21) + ' ' + ' Storing 837 data'

		declare @dataHeaderFooterID as bigint
		declare @generatedOn        as datetime = getdate()

		print CONVERT(NVARCHAR(MAX), getdate(),21) + ' ' + ' Header and Footer Segments'

		insert into dbo.Claims_837_Data_Sent_Header_Footer
		select
		    transmission_id     = @transmission_id
		  , file_name           = @fileName		  
		  , generated_on        = @generatedOn
		  , edi_seg_term        = @segterm
		  , edi_elem_sep        = @el_sep
		  , edi_sub_elem_sep    = @subel_sep
		  , edi_rep_sep         = @rep_sep
		  , edi_header_segs     = @837Header
		  , edi_footer_segs     = @837Footer
          , edi_file_text       = @full837	
		set @dataHeaderFooterID = SCOPE_IDENTITY()
			
		print CONVERT(NVARCHAR(MAX), getdate(),21) + ' ' + ' Transaction Segments'

		insert into dbo.Claims_837_Data_Sent_Transactions
		select 
		    header_footer_id      = @dataHeaderFooterID
		  , generated_on          = @generatedOn
		  , prep_claim_row_id     = t1.row_id
		  , claim_id              = t1.claim_id
		  , has_orp               = t1.has_orp
		  , dist_id_chng          = t1.dist_id_chng
		  , pat_id_chng           = t1.pat_id_chng
		  , edi_transaction_segs  = t1.printdata
		from #final_prep_claims as t1
		order by t1.row_id

		print CONVERT(NVARCHAR(MAX), getdate(),21) + ' ' + ' Parsing Segments Into Text Columns'
		
		insert into dbo.Import_From_837
        select * from dbo.Claims_837_Data_Sent_Parse_Into_Text_Columns (@transmission_id,null)
	

	END
END
GO
