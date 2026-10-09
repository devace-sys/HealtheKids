use SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Claims_Post_835_File') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.Claims_Post_835_File
GO


/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE PROCEDURE [dbo].[Claims_Post_835_File]
 (
	  @pathFile835File         nvarchar(512)
	, @pathFilePostingFile     VARCHAR(MAX)
	, @warrantDate		       DATE  
	, @isTestRun			   BIT = 1
	, @skipProcModComboCheck   BIT = 0
 )  
AS    
BEGIN    

/*
 * Bring in the parsed 835 file into a temporary staging table
 * for error checking and data validation. 
 */

create table #raw_parse
(
	rowtype varchar(30),	rowID bigint,	parentRowID BIGINT,	Segment varchar(max),	col5 varchar(max),	col6 varchar(max),	col7 varchar(max),	col8 varchar(max),	col9 varchar(max),	col10 varchar(max),	col11 varchar(max),	col12 varchar(max),	col13 varchar(max),	col14 varchar(max),	col15 varchar(max),	col16 varchar(max),	col17 varchar(max),	col18 varchar(max),	col19 varchar(max),	col20 varchar(max),	col21 varchar(max),	col22 varchar(max),	col23 varchar(max),	col24 varchar(max),	col25 varchar(max),	col26 varchar(max),	col27 varchar(max),	col28 varchar(max),	col29 varchar(max),	col30 varchar(max),	col31 varchar(max),	col32 varchar(max),	col33 varchar(max),	col34 varchar(max),	col35 varchar(max),	col36 varchar(max),	col37 varchar(max),	col38 varchar(max),	col39 varchar(max),	col40 varchar(max),	col41 varchar(max),	col42 varchar(max),	col43 varchar(max),	col44 varchar(max),	col45 varchar(max),	col46 varchar(max),	col47 varchar(max),	col48 varchar(max),	col49 varchar(max),	col50 varchar(max)
)


set nocount on

declare @bulkSQL varchar(max) = 'bulk insert #raw_parse from ''' + @pathFilePostingFile + ''' with (fieldterminator = ''*'')'
  
RAISERROR ('Importing parsed 835 data', 0, 1) WITH NOWAIT

EXECUTE (@bulkSQL);
 
/******************************************************************************
 * Get file names... We will save them in the CLAIM_CLAIM_Posting table 
 * later on.
 ******************************************************************************/

RAISERROR ('Getting file names', 0, 1) WITH NOWAIT 

declare @fileName835     as nvarchar(512)
declare @fileNamePosting as nvarchar(512)

set @fileName835     = dbo.GET_FILE_NAME_FROM_PATH_FILE_NAME (@pathFile835File,     '\')
set @fileNamePosting = dbo.GET_FILE_NAME_FROM_PATH_FILE_NAME (@pathFilePostingFile, '\')

print @fileName835
print @fileNamePosting

/******************************************************************************
 * Prescan 
 ******************************************************************************/
 
RAISERROR ('Prescan starting', 0, 1) WITH NOWAIT 

/************************************
 * Create starter records for groups
 * and codes we do not have in our
 * reference tables.
 ************************************/

/* Insert starting records for missing group codes */

RAISERROR ('Search for and insert misssing claim_detail_groups', 0, 1) WITH NOWAIT 

insert into dbo.CLAIM_DETAIL_GROUPS
select distinct 
    GROUP_CODE   = rp.col5
  , GROUP_DETAIL = null
from #raw_parse as rp
left join dbo.CLAIM_DETAIL_GROUPS as cdg on cdg.GROUP_CODE = rp.col5
where 
  (((rp.rowtype = 'CAS') or (rp.rowtype = 'LQ')) and (cdg.GROUP_ID is null))

/* Insert starting records for missing detail codes */

RAISERROR ('Search for and insert misssing claim_detail_codes', 0, 1) WITH NOWAIT

insert into dbo.CLAIM_DETAIL_CODES
select distinct 
   CODE_VALUE       = rp.col6
 , DETAIL_TEXT      = null
 , START_DATE       = null
 , LAST_MODIFY_DATE = null
 , END_DATE         = null
 , IS_ARC_CARC      = 1
 , IS_HCRC_RARC     = 0
from #raw_parse as rp
left join dbo.CLAIM_DETAIL_CODES as cdc on cdc.CODE_VALUE   = rp.col6 
                                        and cdc.IS_ARC_CARC = 1 
where 
  ((rp.rowtype = 'CAS') and (cdc.CODE_ID is null))

insert into dbo.CLAIM_DETAIL_CODES
select distinct   
    CODE_VALUE       = rp.col6
  , DETAIL_TEXT      = null
  , START_DATE       = null
  , LAST_MODIFY_DATE = null
  , END_DATE         = null
  , IS_ARC_CARC      = 0
  , IS_HCRC_RARC     = 1  
from #raw_parse as rp
left join dbo.CLAIM_DETAIL_CODES as cdc on  cdc.CODE_VALUE   = rp.col6 
                                        and cdc.IS_HCRC_RARC = 1 
where ((rp.rowtype = 'LQ') and (cdc.CODE_ID is null))

RAISERROR ('Prescan complete', 0, 1) WITH NOWAIT

/* Raw table output for easier review. */
--select '' as RAW_FILE_UPLOAD, * from #raw_parse
--order by rowID

/* Instatiate posting date and check to make sure the specified warrant date isn't too weird */

declare @posting_date datetime = getdate()

if @warrantDate <> '19000101' and @warrantDate is not null

BEGIN


RAISERROR ('Validating imported 835 data', 0, 1) WITH NOWAIT

/******************************************************************************/
/* Validate rows in the file to check for possible errors or reposting issues */
/******************************************************************************/

declare @rowErrorTable table (row_id bigint, error_code bigint)

/****************************************/
/*		Validate TRN/BPR segments		*/
/****************************************/

/* Check to make sure the NPI on the transaction matches to a client in our database */
	insert into @rowErrorTable
	select rp.rowID, (select top 1 Error_ID from dbo.Claim_Claim_Posting_Errorcodes where Short_Err = 'CLI_NPI') --'Client NPI not in Spedcare.' 
	from #raw_parse rp
	left outer join dbo.CLIENTS_Client cc
		on cc.NPI = col39
	where cc.CLIENT_ID is null and rowtype = 'TRN'

/* Search posting table to see if this transaction's check number has already been posted. */
	insert into @rowErrorTable
	select rp.rowID, (select top 1 Error_ID from dbo.Claim_Claim_Posting_Errorcodes where Short_Err = 'CLI_POST') --'This check number has already been posted for a non-zero amount.' 
	from #raw_parse rp
	where rowtype = 'TRN' and exists (select top 1 * from dbo.CLAIM_Claim_Posting where CHECK_NUMBER = col23 and CHECK_AMOUNT > 0 )	
	
/* Verify the manually-entered check date - if the posting table already contains an entry for a client on that date , it might be an indication that something is incorrect */
	insert into @rowErrorTable
	select distinct rp.rowID, (select top 1 Error_ID from dbo.Claim_Claim_Posting_Errorcodes where Short_Err = 'CLI_CHK_DATE') --'This client has already had a transaction posted for the check date you have chosen.'
	from #raw_parse rp
	outer apply 
	(
		select '' as Double_Check_Date, ccp.*
		from dbo.CLIENTS_Client cli 
			inner join dbo.CLAIM_Claim cc on cli.CLIENT_ID = cc.CLIENT_ID and cli.NPI = rp.col39
			inner join dbo.CLAIM_Claim_Adjudication cca on cca.CLAIM_ID = cc.CLAIM_ID
			inner join  dbo.CLAIM_Claim_Posting ccp on ccp.POSTING_ID = cca.POSTING_ID and ccp.CHECK_DATE = @warrantDate
	) check_test
	where rp.rowtype = 'TRN'
	and check_test.POSTING_ID is not null

	
/****************************************/
/*		END TRN/BPR VALIDATION			*/
/****************************************/



/****************************/
/*	Validate CLP segments	*/
/****************************/

/*	
	Sometimes a previous client will still be registered on our CMC submitter ID, even though we are no longer processing their claims.
	Since they are still registered with us. EDS will still send us posting data regarding their claim submissions; this is data to 
	filter out and ignore for a proper posting experience. Most of the claim and service verification flags are there as a check to prevent this from happening.
	
	Error conditions are also in place to make sure the document itself follows relevant format and is self-coherent,
	as well as to elucidate potential procedural issues with how we may transmit claims (and alter their data) in the future.
*/

	insert into @rowErrorTable
	select rp.rowid, (select top 1 Error_ID from dbo.Claim_Claim_Posting_Errorcodes where Short_Err = 'CLM_ID_FRMT') --'Claim identifier not in SBSC format.' 
	from #raw_parse rp
	where 
		rp.rowtype = 'CLP'
		and (
				/* exclude if not in basic HEBS or Spedcare format(s) */
				(
						col5 not like '%-%-%-%'		/* HEBS */
					and col5 not like '%-%-SPD'		/* Spedcare prior to 10/2017 */
					and col5 not like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]' /* Spedcare on/after 10/2017 (TRC addition to claim identifier) */
				)		
				or ISNUMERIC(SUBSTRING(col5,0, CHARINDEX('-',col5))) <> 1	/* Or if the first segment (pre-dash) of the identifier is not numeric */
				or SUBSTRING(col5,0, CHARINDEX('-',col5)) like '[a-z]%'		/* Or if the first segment starts with an alphabetic character */
			)
	
	
	
	/* If the format matches our basic format criteria, try and match the claim ID in the 835 file to a claim in the database */
	
	/* 
		Start by creating a correlation table between a row of the file and the claim_ID listed in that row of the file. 
		This helps reduce SUBSTRING() overhead and makes further queries on claim_ID more readable. 
		This now includes the TRC_id.
	*/
	
   declare @Row_Claim_Correlation table (row_id bigint, claim_id bigint, trans_rec_claim_id bigint)

   RAISERROR ('Row_Claim_Correlation insert', 0, 1) WITH NOWAIT 

	insert into @Row_Claim_Correlation
	select
		rp.rowID 
		,CONVERT(bigint, SUBSTRING(col5,0, CHARINDEX('-',col5)))					as clm_id
		,CASE
			when col5 like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]' /* Spedcare on/after 10/2017 (TRC addition to claim identifier) */
			then CONVERT(bigint, SUBSTRING(col5,CHARINDEX('-',col5)+1, 9999))
			else NULL
		 END as trc_id
		
	from 
		#raw_parse rp
		left outer join @rowErrorTable ret on rp.rowID = ret.row_id
	where rp.rowtype = 'CLP' and ISNUMERIC(SUBSTRING(col5,0, CHARINDEX('-',col5))) = 1 and ret.row_id is null


/* Isolate HEBS claims in a seperate reference lookup */

RAISERROR ('HEBS claims isolate' , 0, 1) WITH NOWAIT 

declare @HEBS_Claims_in_Errortable table (rowid bigint , claimID bigint)

insert into @HEBS_Claims_in_Errortable
select  ret.row_id, claimpatmatch.CLAIM_ID from @rowErrorTable ret
inner join #raw_parse rp 
	on ret.row_id = rp.rowID 
	and ret.error_code = 4 --CLM_ID_FRMT:	Claim identifier not in SBSC format.
	and col5 like '%-%-%-%'
	and col5 not like '%-%-99-%'
	and ISNUMERIC(SUBSTRING(col5,0, CHARINDEX('-',col5))) <> 1
	and SUBSTRING(col5,0, CHARINDEX('-',col5)) like '[a-z]%'
	and rp.rowtype = 'clp'
	
inner join #raw_parse rp_svc on rp.rowID = rp_svc.parentRowID and rp_svc.rowtype = 'svc'
outer apply 
(select top 1 pp.FIRST_NAME, pp.LAST_NAME, pp.BIC, cc.*, cp.PROCEDURE_CODE, cp.PROCEDURE_MODIFIER_1,cp.PROCEDURE_MODIFIER_2,cp.PROCEDURE_MODIFIER_3 from

		dbo.PATIENTS_Patient pp 

		inner join dbo.CLAIM_Claim cc on pp.PATIENT_ID = cc.PATIENT_ID
		inner join dbo.CLAIM_Procedures cp on cp.PROCEDURE_ID = cc.PROCEDURE_ID
		--inner join CLAIM_Claim_Adjudication cca on cc.CLAIM_ID = cca.CLAIM_ID
			
		where
		cc.STATUS = dbo.CONST_CLAIM_STATUS_SUB_PAID() -- HEBS adjustments should only be to paid claims
		and pp.BIC = rp.col24 
		and cc.SERVICE_DATE = rp.col30
		and SUBSTRING(rp.col5,0, CHARINDEX('-',rp.col5)) = cc.PAPER_CLAIM_NUMBER
		and cp.PROCEDURE_CODE = rp_svc.col6
		and (cp.PROCEDURE_MODIFIER_1 = rp_svc.col7 or rp_svc.col7 is null)
		and (cp.PROCEDURE_MODIFIER_2 = rp_svc.col8 or rp_svc.col8 is null)
		and (cp.PROCEDURE_MODIFIER_3 = rp_svc.col9 or rp_svc.col9 is null)
		and exists (select 1 from CLAIM_Claim_Adjudication cca where cca.CLAIM_ID = cc.CLAIM_ID)
		
		order by cc.LAST_UPDATED desc
) claimpatmatch



select '' as HEBS_Claims_in_Errortable, * from @HEBS_Claims_in_Errortable het inner join #raw_parse rp on het.rowid=rp.rowID inner join CLAIM_Claim cc on cc.CLAIM_ID = het.claimID


/* populate correlation table with the claims we just linked to */
insert into @Row_Claim_Correlation (row_id, claim_id)
select rowid,claimID from @HEBS_Claims_in_Errortable

/* And then remove those row-error entries from the error list */
delete from @rowErrorTable
where error_code = (select top 1 Error_ID from dbo.Claim_Claim_Posting_Errorcodes where Short_Err = 'CLM_ID_FRMT')
and row_id in (select rowid from @HEBS_Claims_in_Errortable)



	/*
		Once we've attempted to establish a 835 row - Spedcare claim link, we can do further analysis on the relationship between the row and the claim.
		This allows for identification of row-claim pairings that may be malicious, erroneous, or simply have data that does not fit our expectations, 
		given our understanding of the process of claim transmission and payment.
	
	*/
	
	
	
	/*
		Even though we've been able to say 'This 835 row seems to link to this claim ID', it's still important to 
		do some additional matching on the data within the claim and verify that the claim in the file is really 
		the one in our database. 
	*/
	
	insert into @rowErrorTable
	select rp.rowid, (select top 1 Error_ID from dbo.Claim_Claim_Posting_Errorcodes where Short_Err = 'CLM_ID_EXIST') --'Claim ID in file does not exist in database.' 
	from 
		 #raw_parse rp
		inner join @Row_Claim_Correlation rcc on rp.rowID = rcc.row_id
		left outer join dbo.CLAIM_Claim cc on rcc.claim_id = cc.CLAIM_ID
	where 
		rp.rowtype = 'CLP'
		and cc.claim_id is null
		
	insert into @rowErrorTable
	select rp.rowid, (select top 1 Error_ID from dbo.Claim_Claim_Posting_Errorcodes where Short_Err = 'TRC_ID_EXIST') --'The Transmission Record Claim ID (TRC_ID) does not exist in dbo.Transmission_Record_Claims.' 
	from 
		 #raw_parse rp
		inner join @Row_Claim_Correlation rcc on rp.rowID = rcc.row_id
		left outer join dbo.TRANSMISSION_RECORD_CLAIMS_ALL as trc on rcc.trans_rec_claim_id = trc.trc_ID
	where 
		rp.rowtype = 'CLP'
		and col5 like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]' /* Spedcare on/after 10/2017 (TRC addition to claim identifier) */
		and trc.trc_ID is null
		
	insert into @rowErrorTable
	select rp.rowid, (select top 1 Error_ID from dbo.Claim_Claim_Posting_Errorcodes where Short_Err = 'CLM_TRC_MATCH') --'The Transmission Record Claim ID (TRC_ID) exists, but the claim ID it is linked to in dbo.Transmission_Record_Claims is not the claim_ID in the 835 file.' 
	from 
		 #raw_parse rp
		inner join @Row_Claim_Correlation rcc on rp.rowID = rcc.row_id
		left outer join dbo.TRANSMISSION_RECORD_CLAIMS_ALL as trc_tr on rcc.trans_rec_claim_id = trc_tr.trc_ID 
		left outer join dbo.TRANSMISSION_RECORD_CLAIMS_ALL as trc_cl on trc_tr.transmission_id = trc_cl.transmission_id and trc_tr.claim_id = trc_cl.claim_id
		
	where 
		rp.rowtype = 'CLP'
		and col5 like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]' /* Spedcare on/after 10/2017 (TRC addition to claim identifier) */
		and trc_tr.trc_ID is not null
		and trc_cl.trc_ID is null
		
	
	insert into @rowErrorTable
	select rp.rowID, (select top 1 Error_ID from dbo.Claim_Claim_Posting_Errorcodes where Short_Err = 'CLM_CLI_MAT') --'The client for this claim record is not the client specified for this claim in the database.'
		from #raw_parse rp
		inner join @Row_Claim_Correlation rcc on rp.rowID = rcc.row_id
		inner join #raw_parse rp_trans 
			on rp.parentRowID = rp_trans.rowID
			and rp.rowtype = 'CLP' and rp_trans.rowtype = 'TRN'
		inner join dbo.CLAIM_Claim cc on rcc.claim_id = cc.CLAIM_ID
		left outer join dbo.CLIENTS_Client cli 
			on cc.CLIENT_ID = cli.CLIENT_ID
			and rp_trans.col39 = cli.NPI
	where
		cli.CLIENT_ID is null

	insert into @rowErrorTable
	select rp.rowid, (select top 1 Error_ID from dbo.Claim_Claim_Posting_Errorcodes where Short_Err = 'CLM_BIC_MAT') --'Patient BIC on original claim does not match BIC in 835 file.' 
		from #raw_parse rp
		inner join @Row_Claim_Correlation rcc on rp.rowID = rcc.row_id
		left outer join dbo.CLAIM_Claim cc on rcc.claim_id = cc.CLAIM_ID
		left outer join dbo.PATIENTS_Patient pp on cc.PATIENT_ID =pp.PATIENT_ID
	where 
		rp.rowtype = 'CLP'
		and col6 <> '22'	/* Leave out reversals when doing a BIC check */
		and col24 NOT IN (select pp.BIC union select pba.ARCHIVED_BIC as BIC from dbo.PATIENT_BIC_ARCHIVE as pba where pba.patient_id = pp.PATIENT_ID)
	
	
	
	
	/*
		Duplicate checking: A claim payment can only be posted once. 
			* A claim can have multiple payments (like reversal of a previous amount, repayments)
			* A duplicate payment will have the same CCN (claim control number) as an adjudication already in our database
			
		The exception to this is void/reversals, which refer to the original CCN of the claimline they reverse. If there is a CCN conflict on a 22, double-check that the CCN
	*/
	
	insert into @rowErrorTable
	select rp.rowid, (select top 1 Error_ID from dbo.Claim_Claim_Posting_Errorcodes where Short_Err = 'CLM_ADJ')  --'This claim has already been adjudicated in a previous posting.' 
		from #raw_parse rp
		inner join @Row_Claim_Correlation rcc on rp.rowID = rcc.row_id
		left outer join dbo.CLAIM_Claim cc on rcc.claim_id = cc.CLAIM_ID
		left outer join dbo.PATIENTS_Patient pp on cc.PATIENT_ID =pp.PATIENT_ID
		left outer join dbo.CLAIM_Claim_Adjudication cca on cca.CLAIM_ID = cc.CLAIM_ID and cca.CCN = rp.col11 -- they have an adjudication entry with the same claim control number (unique to each payment-posting)
		left outer join dbo.CLAIM_Claim_Adjudication cca2 on cca.CLAIM_ID = cca2.CLAIM_ID and cca2.DATE_ADJUDICATED = @warrantDate and cca.ADJUDICATION_ID <> cca2.ADJUDICATION_ID and cca.AMOUNT_PAID + cca2.AMOUNT_PAID = 0
	where 
		rp.rowtype = 'CLP'
		and

			(
				(cca.ADJUDICATION_ID is not null and rp.col6 <> '22')
				OR
				(
					cca.ADJUDICATION_ID is not null			--adjudication with that ccn
					and rp.col6 = '22'						--VOID claimline
					and cca.DATE_ADJUDICATED = @warrantDate --claimline and adjudication match on warrant/checkdate
					and cca.AMOUNT_PAID = rp.col8			--and dollar amount paid
					and cca2.ADJUDICATION_ID is not null	-- and there is another adjudication for this claim that the current VOID Claimline cancels.
				)
			)
			
	
/*
	Data Verification: Spedcare Claim
	
	Before we post adjudication to a claim, it's a good idea to do some checks on the data we already have on that claim.
	The idea is that the process we follow for transmission should follow a certain path, which is enforced by the sprocs
	we use to automate the process. If a claim's information is different from what we expect, that indicates a deviation 
	from process that should be investigated.
*/	
	
	insert into @rowErrorTable
	select distinct rp.rowid, (select top 1 Error_ID from dbo.Claim_Claim_Posting_Errorcodes where Short_Err = 'CLM_PAY_ZADJ')  --'This claim is marked as 'PAID' in Spedcare, but all adjustments for this claim are for zero dollar amounts.' 
		from #raw_parse rp
		inner join @Row_Claim_Correlation rcc on rp.rowID = rcc.row_id
		inner join dbo.CLAIM_Claim cc on cc.CLAIM_ID = rcc.claim_id and (STATUS = dbo.CONST_CLAIM_STATUS_SUB_PAID() OR STATUS = dbo.CONST_CLAIM_STATUS_RECV_PROXY_PAID())
		cross apply 
		(
			select 
				COUNT(*) as num_non_zed_adj
			from 
				dbo.CLAIM_Claim_Adjudication cca
			where
				cca.CLAIM_ID = cc.CLAIM_ID
				and cca.AMOUNT_PAID <> 0
			having COUNT(*) = 0
		) Haz_adj_all_zero
	
	
	insert into @rowErrorTable	
	select rp.rowid, (select top 1 Error_ID from dbo.Claim_Claim_Posting_Errorcodes where Short_Err = 'CLM_STAT_BND')  --'The state of this claim in Spedcare falls outside verifiable bounds (1,2,3,4,13,14).' 
		from #raw_parse rp
		inner join @Row_Claim_Correlation rcc 
			on rp.rowID = rcc.row_id	
		inner join dbo.CLAIM_Claim cc 
			on cc.CLAIM_ID = rcc.claim_id 
			and STATUS not in 
				(
					dbo.CONST_CLAIM_STATUS_SUB_PAID(), 
					dbo.CONST_CLAIM_STATUS_NOT_SUB(),
					dbo.CONST_CLAIM_STATUS_SUB_PENDING(),
					dbo.CONST_CLAIM_STATUS_SUB_REJECT(),
					
					[dbo].[CONST_CLAIM_STATUS_RECV_PROXY_PAID](),
					[dbo].[CONST_CLAIM_STATUS_RECV_PROXY_DENIED]()
				)
	
	
	insert into @rowErrorTable	
	select rp.rowid, (select top 1 Error_ID from dbo.Claim_Claim_Posting_Errorcodes where Short_Err = 'CLM_STAT_ND')  --'The Spedcare claim you are trying to post to is in state 'NEW' or 'DENIED'.' 
		from #raw_parse rp
		inner join @Row_Claim_Correlation rcc 
			on rp.rowID = rcc.row_id	
		inner join dbo.CLAIM_Claim cc 
			on cc.CLAIM_ID = rcc.claim_id 
			and cc.STATUS in 
				(
					dbo.CONST_CLAIM_STATUS_NOT_SUB(),
					dbo.CONST_CLAIM_STATUS_SUB_REJECT(),
					[dbo].[CONST_CLAIM_STATUS_RECV_PROXY_DENIED]()
				)
	
/*
	Data Verification: 835 File
	
	We want to make sure the data on our claim records is self-consistent (as per above);
	however, we also want to make sure that the data that's being transmitted to us by
	ECS/ACS is internally self-consistent, both in terms of the data for a claim within 
	the file, and how the 835 claim's payment/denial/reversal state and dollar amounts 
	compare to the current state and adjudications associated with its counterpart.
	
*/	
	



	/*
		Due to some issues with the entity-attribute-value structure of #raw_parse
		and how that structure interacts with parseable numeric criteria
		(doing a WHERE on a convert(decimal(18,2),col) generates a 'cannot convert
		varchar to numeric'), the only solution I could come up with was to create a
		table variable to hold the converted numeric values and their corresponding
		row IDs.
		
		NB: Values 1,2,3, and 22 are representational of the status values from the EDI 835 standard, NOT Spedcare status values.
	*/
	declare @payment_check_zero table (row_id bigint, amt_paid decimal(18,2))

	insert into @payment_check_zero
	select rp.rowid, CONVERT(decimal(18,2),ISNULL(REPLACE(rp.col8,'',0),0))
		from #raw_parse rp
		inner join @Row_Claim_Correlation rcc 
			on rp.rowID = rcc.row_id
			and rp.rowtype = 'CLP'
			and rp.col6 in ('1','2','3','22')
				
	
	insert into @rowErrorTable	
	select pcz.row_id, (select top 1 Error_ID from dbo.Claim_Claim_Posting_Errorcodes where Short_Err = 'CLM_PAY_ZERO')  --'This claim is listed in the 835 file as payment or reversal, but the dollar amount for this payment is zero.' 
		from @payment_check_zero pcz
		where pcz.amt_paid = 0
	
	
	
	insert into @rowErrorTable		
	select rp.rowid, (select top 1 Error_ID from dbo.Claim_Claim_Posting_Errorcodes where Short_Err = 'CLM_NODEN_PAID')  --'This claim is listed in the 835 file as a non-payment/denial; the record in Spedcare for this claim states that it has already been paid.' 
		from #raw_parse rp
		inner join @Row_Claim_Correlation rcc 
			on rp.rowID = rcc.row_id	
		inner join dbo.CLAIM_Claim cc 
			on cc.CLAIM_ID = rcc.claim_id 
			and cc.STATUS in 
				(
					dbo.CONST_CLAIM_STATUS_SUB_PAID(),
					dbo.CONST_CLAIM_STATUS_RECV_PROXY_PAID()
				)	
			and rp.col6 not in ('1','2','3','22')
	
	
	
	delete from @payment_check_zero
	
	insert into @payment_check_zero
	select rp.rowid, CONVERT(decimal(18,2),ISNULL(REPLACE(rp.col8,'',0),0))
		from #raw_parse rp
		inner join @Row_Claim_Correlation rcc 
			on rp.rowID = rcc.row_id
			and rp.rowtype = 'CLP'
			and rp.col6 not in ('1','2','3','22')
		
	insert into @rowErrorTable		
	select pcz.row_id, (select top 1 Error_ID from dbo.Claim_Claim_Posting_Errorcodes where Short_Err = 'CLM_DEN_NOZERO')  --'This claim is listed in the 835 file as a non-payment/denial and has a nonzero dollar amount.' 
		from @payment_check_zero pcz
		where pcz.amt_paid <> 0
		
	
	
	
/******************************	
/* End claim-level validation */
*******************************/

/************************************/
/*	Start service-level validation	*/
/************************************/

/* Check to see if procedure on 835 claim matches the one for the claim in our database unless user skips check  */
if (@skipProcModComboCheck = 0)
begin

insert into @rowErrorTable
select  rp.rowID, (select top 1 Error_ID from dbo.Claim_Claim_Posting_Errorcodes where Short_Err = 'CLM_PROC_MAT') --'This claim''s procedure coding does not match the original procedure recorded. See row ' + CONVERT(varchar(MAX),srp.rowID) + ' for procedure code information.'
	from #raw_parse rp
	inner join #raw_parse srp 
		on srp.rowtype = 'SVC' 
		and srp.parentRowID = rp.rowID
		and rp.rowtype = 'CLP'
	inner join @Row_Claim_Correlation rcc on rp.rowID = rcc.row_id
	left outer join dbo.CLAIM_Claim cc on rcc.claim_id = cc.CLAIM_ID
	left outer join dbo.CLAIM_Procedures cp on cp.PROCEDURE_ID = cc.PROCEDURE_ID
	outer apply 
	(
		select * from
		(
		select ROW_NUMBER() over(order by svc_proc) as svc_order_id, * from
		(
			select ISNULL(srp.col6,'') as svc_proc
			union
			select ISNULL(srp.col7,'')
			union 
			select ISNULL(srp.col8,'')
			union
			select ISNULL(srp.col9,'')
		) svcproc
		) num_svcproc
		
		left outer join 
		(
		select ROW_NUMBER() over(order by db_proc) as db_proc_order_id, * from
		(
			select ISNULL(cp.PROCEDURE_CODE,'') as db_proc, cp.PROCEDURE_ID
			union
			select ISNULL(cp.PROCEDURE_MODIFIER_1,'') , cp.PROCEDURE_ID
			union 
			select ISNULL(cp.PROCEDURE_MODIFIER_2,''), cp.PROCEDURE_ID
			union
			select ISNULL(cp.PROCEDURE_MODIFIER_3,''), cp.PROCEDURE_ID
		) dbclaimproc
		
		)num_dbclaimproc 
			on num_dbclaimproc.db_proc_order_id = num_svcproc.svc_order_id 
			and num_dbclaimproc.db_proc = num_svcproc.svc_proc
		
		
	)proc_id_check
where	proc_id_check.PROCEDURE_ID is null 
		and cc.CLAIM_ID is not null  /* This eliminates cases where a 'bad procedure' error was generated for a nonexistent claim */


order by rp.rowID

end /* Skip proc mod combo check */

/*********************************************************************************** 
	If a SVC segment has problems, the claim segment it is a child of 
	should not be uploaded until the SVC issue has been corrected.
 *********************************************************************************/
insert into @rowErrorTable
select rp.parentRowID, (select top 1 Error_ID from dbo.Claim_Claim_Posting_Errorcodes where Short_Err = 'SVC_ERR') --'Error in child SVC row ' + CONVERT(NVARCHAR(MAX),rp.rowid) +  ' makes this row invalid.' 
from #raw_parse rp
where 
	 rp.rowID in (select row_id from @rowErrorTable)
	and rp.parentRowID not in (select row_id from @rowErrorTable)
	and rp.rowtype in ('SVC')

/* End SVC validation */

/************************************/
/*	Remittance Advice Validation	*/
/************************************/

/******************************************************

FOR LQ and CAS segments: 
	col5 must match to a claim_detail_groups entry
	col6 must match to a claim_detail_codes entry, 
		and the ISCARC/ISRARC flags must match:
			CAS - CARC
			LQ  - RARC

*******************************************************/

insert into @rowErrorTable
select  SVC.parentRowID, (select top 1 Error_ID from dbo.Claim_Claim_Posting_Errorcodes where Short_Err = 'LQ_CAS_ERR') --'Error in child LQ/CAS row ' + CONVERT(NVARCHAR(MAX),CASLQ.rowid) +  ' makes this row invalid.' 
from #raw_parse CASLQ
	inner join #raw_parse SVC 
		on CASLQ.parentRowID = SVC.rowID 
		and SVC.rowtype = 'SVC'
	left outer join CLAIM_DETAIL_GROUPS CDG 
		on CASLQ.col5 = CDG.GROUP_CODE
	left outer join CLAIM_DETAIL_CODES CDC 
		on CASLQ.col6 = CDC.CODE_VALUE 
		AND ((CASLQ.rowtype = 'CAS' and CDC.IS_ARC_CARC = 1) 
			or (CASLQ.rowtype = 'LQ' and CDC.IS_HCRC_RARC = 1))
		
where CDG.GROUP_ID is null or CDC.CODE_ID is null




/********************************/
/*	General Validation Cleanup	*/
/********************************/

/* 
	Any children of a block that is error-flagged should also be flagged.
	This is repeated twice to make sure error flags inherit properly.
	(Yes, this should PROBABLY be done via a looping/recursion process, but the depth limitations on the original 835 make that excessive.)
*/

insert into @rowErrorTable
select rp.rowid, (select top 1 Error_ID from dbo.Claim_Claim_Posting_Errorcodes where Short_Err = 'PRNT_ERR') --'Error in parent row: ' + CONVERT(nvarchar(max), rp.parentRowID)
	from #raw_parse rp
	inner join (select distinct row_id from @rowErrorTable) parent_error 
		on parent_error.row_id = rp.parentRowID
	left outer join @rowErrorTable ret on rp.rowID = ret.row_id and ret.error_code = (select top 1 Error_ID from dbo.Claim_Claim_Posting_Errorcodes where Short_Err = 'PRNT_ERR')
where ret.row_id is null	

insert into @rowErrorTable
select rp.rowid, (select top 1 Error_ID from dbo.Claim_Claim_Posting_Errorcodes where Short_Err = 'PRNT_ERR') --'Error in parent row: ' + CONVERT(nvarchar(max), rp.parentRowID)
	from #raw_parse rp
	inner join (select distinct row_id from @rowErrorTable) parent_error on parent_error.row_id = rp.parentRowID
	left outer join @rowErrorTable ret on rp.rowID = ret.row_id and ret.error_code = (select top 1 Error_ID from dbo.Claim_Claim_Posting_Errorcodes where Short_Err = 'PRNT_ERR')
where ret.row_id is null	

/************************/
/* End validation block */
/************************/

/******************************
	Quick claim stats display
*******************************/

select
(
	select 
		COUNT (*) as '# of claims in file' 
	from 
		#raw_parse rp 
	where rp.rowtype = 'CLP'
) as '# of claims in file' 
,
(
	select 
		COUNT (*) as '# of error-free claims' 
	from 
		#raw_parse rp 
		inner join @Row_Claim_Correlation rcc 
			on rcc.row_id = rp.rowID 
	where 
		rp.rowID not in (select row_id from @rowErrorTable)
) as '# of error-free claims' 


/****************************************************

	'RESCUE' claimlines with a BIC mismatch

	Cases where an 835 claimline has a different
	BIC than the originating Spedcare claim are
	a little tricky; we still want to flag these 
	as errors for the report, but want to process 
	them like normal claim adjudications...
	...with the addition of a CLAIM_NOTE describing
	the unique details behind the posting.
	
	We implement this by using an 'Errored but OK-Post'
	table, which contains rowIDs that failed on one error,
	but have been judged worthy of posting.
	
	During the actual posting of claim adjudication lines,
	claimlines that are in the error table but not in the 
	'post anyways' table will not be posted.
	
*****************************************************/

declare @BIC_errored_but_post_anyways table (row_id bigint)
	
/*  Load up list of BIC-mismatch claims, where the mismatch is the ONLY error */
	
	insert into @BIC_errored_but_post_anyways (row_id)
	select row_id from 
	(
		select 
			ret.row_id 
		from 
			@rowErrorTable ret 
			cross apply 
			(
				select COUNT(*) numtimes_error
				from @rowErrorTable retct 
				where retct.row_id = ret.row_id
			) row_error_count
		where 
			numtimes_error = 1
			and ret.error_code = (select top 1 Error_ID from dbo.Claim_Claim_Posting_Errorcodes where Short_Err = 'CLM_BIC_MAT')
		
	) BIC_RESCUE_CLAIMS
	
	
	/* Create a note for each of the claims explaining the specific circumstances of the BIC issue and providing details for reference */
	
	
	insert into CLAIM_Claim_Notes (CLAIM_ID, NOTE, DATE_CREATED, DATE_MODIFIED)
	select rcc.claim_id, 'Claim was created in Spedcare but billed in HEBS. During 837 transmission, HEBS appended a different patient name and BIC than what was on the original claim; as a result, there was a BIC mismatch error during Spedcare 835 posting. '
				+ 'Reference information from the 835 follows: 835_LNAME: ' + rp.col18 + ' 835_FNAME: ' + rp.col19 + ' 835_BIC: ' + rp.col24 + ' 835_CCN: ' + rp.col11 + ' WARRANT DATE: ' + CONVERT(VARCHAR(MAX), @warrantDate)
				,GETDATE()
				,GETDATE()
	from
	@BIC_errored_but_post_anyways bic_mat
	inner join @Row_Claim_Correlation rcc on bic_mat.row_id = rcc.row_id
	inner join #raw_parse rp on rp.rowID = bic_mat.row_id
	
	

	
	
	
	
	

select '' as 'Claimlines OK to post', * from #raw_parse rp inner join @Row_Claim_Correlation rcc on rcc.row_id = rp.rowID where rp.rowID not in (select ret.row_id from @rowErrorTable ret left outer join @BIC_errored_but_post_anyways BIC on ret.row_id = BIC.row_id where BIC.row_id is null)





/***********************************/
/* Begin posting and adjudication  */
/***********************************/

BEGIN TRANSACTION

RAISERROR ('starting posting', 0, 1) WITH NOWAIT 

declare @intermedPostTransact table
		(
		file_row_id			bigint PRIMARY KEY, 
		posting_id			int, 
		posting_date		datetime, 
		check_date			datetime, 
		check_number		nvarchar(50),
		check_amt			decimal (18,2), 
		note				nvarchar(max), 
		healthy_families	bit,
		client_ID			bigint,
		EDS_PERCENT			numeric(18,8)
		)

declare @posting_corr_output table 
		(
		posting_id			int, 
		check_number		nvarchar(50)
		)		

RAISERROR ('IPT insert', 0, 1) WITH NOWAIT 

insert into @intermedPostTransact (file_row_id, posting_date, check_date, check_number, check_amt, healthy_families, client_ID)
  select rowID,	@posting_date, @warrantDate, col23, col6, (CASE when col25 = 'H' then 1 else 0 END) as hfam, clients.CLIENT_ID
  from 
	#raw_parse rp
  inner join CLIENTS_Client clients on rp.col39 = clients.NPI
  where rp.rowtype = 'TRN' and rp.rowID not in (select row_id from @rowErrorTable )
  
 
RAISERROR ('insert into posting from ipt', 0, 1) WITH NOWAIT 
 
insert into CLAIM_Claim_Posting 
	(	
		POSTING_DATE,
		CHECK_DATE, 
		CHECK_NUMBER, 
		CHECK_AMOUNT, 
		POSTING_NOTE, 
		HEALTHY_FAMILIES, 
		EDS_PERCENT,
		clientID,
		FILE_NAME_835,
		FILE_NAME_POSTING
	)
	
	output 
		inserted.POSTING_ID, 
		inserted.CHECK_NUMBER
	into @posting_corr_output
	
	select  
		posting_date, 
		check_date, 
		check_number, 
		check_amt, 
		null, 
		healthy_families, 
		-1		,				/* EDSPERCENT is set at -1 due to the fact that the column cannot hold percentages and -1 is a good inappropriate key. */
		client_ID,
		@fileName835,
		@fileNamePosting
		

	from @intermedPostTransact 

RAISERROR ('pass posting ID back to ipt', 0, 1) WITH NOWAIT 

update @intermedPostTransact
set posting_id = pco.posting_id
from 
	@intermedPostTransact ipt
	inner join @posting_corr_output pco on ipt.check_number = pco.check_number

/***************************************************************/
/* Append adjudication data for claims in posting transactions */
/***************************************************************/

RAISERROR ('Append adjudication data', 0, 1) WITH NOWAIT 

insert into CLAIM_Claim_Adjudication (CLAIM_ID, DATE_ADJUDICATED, AMOUNT_PAID, ccn, POSTING_ID, PROXY_DISBURSED, TRANSMISSION_RECORD_CLAIM_ID)

select 
	rcc.claim_id
	, ipt.check_date
	
	, clp_data.col8
	, clp_data.col11
	, ipt.posting_id
	, CASE WHEN cc.IS_PROXY = 1 then 0 else NULL END
	, rcc.trans_rec_claim_id
from 
	#raw_parse clp_data
	inner join @intermedPostTransact ipt 
		on clp_data.parentRowID = ipt.file_row_id
	inner join @Row_Claim_Correlation rcc
		on clp_data.rowID = rcc.row_id
	inner join CLAIM_Claim cc on cc.CLAIM_ID = rcc.claim_id
where 
	clp_data.rowID not in (select ret.row_id from @rowErrorTable ret left outer join @BIC_errored_but_post_anyways BIC on ret.row_id = BIC.row_id where BIC.row_id is null)
	and clp_data.rowtype = 'clp'
	
	
/*************************************/
/* Append remittance and reason data */
/*************************************/
/*****
	Claim remittance/reason/detail codings are useful 
	for determining why claims may have denied or not paid fully.
*****/

RAISERROR ('Adjudication details - remittance & reason', 0, 1) WITH NOWAIT 

insert into CLAIM_CLAIM_ADJUDICATION_DETAILS (ADJUDICATION_ID, DETAIL_GROUP_ID, DETAIL_CODE_ID)

select 
	ADJUDICATION_ID, cdg.group_id, CDC.CODE_ID
from 
	#raw_parse CASLQ
	inner join #raw_parse SVC 
		on CASLQ.parentRowID = SVC.rowID
	inner join #raw_parse CLP 
		on SVC.parentRowID = CLP.rowID
	inner join @Row_Claim_Correlation rcc 
		on clp.rowID = rcc.row_id
	inner join CLAIM_Claim_Adjudication cca 
		on rcc.claim_id = cca.CLAIM_ID
		and cca.DATE_ADJUDICATED = @warrantDate
		and cca.CCN = CLP.col11
	left outer join CLAIM_DETAIL_CODES CDC
		on (CDC.CODE_VALUE = CASLQ.col6 and CASLQ.rowtype = 'CAS' and CDC.IS_ARC_CARC = 1)
		or (CDC.CODE_VALUE = CASLQ.col6 and CASLQ.rowtype = 'LQ' and CDC.IS_HCRC_RARC = 1)
	left outer join CLAIM_DETAIL_GROUPS CDG
		on CDG.GROUP_CODE = CASLQ.col5
where 
	CASLQ.rowtype in ('LQ','CAS')
	and clp.rowID not in (select ret.row_id from @rowErrorTable ret left outer join @BIC_errored_but_post_anyways BIC on ret.row_id = BIC.row_id where BIC.row_id is null)
order by  ADJUDICATION_ID,CASLQ.parentRowID



/***********************************/
/* PLB/State Adjustment insertions */
/***********************************/

/****
	PLB adjustments are 'Provider-Level Benefits' and 
	are used to indicate adjustments to financial amounts
	that are not applicable to any single claim payment.
	
	This may include things like a check that has been lost
	in the mail and needs to be cancelled/reconciled before
	a new check can be written. The problem that has occurred
	is not due to anything being wrong with any individual
	claim or set of claims, so the claims themselves are not
	adjusted.
****/

insert into claim_claim_posting_adjustments (posting_id, IDENTIFIER, fiscal_period_date, amount)
select ipt.posting_id, plb_parse.col7, convert(date,plb_parse.col6), col8 from #raw_parse plb_parse
left outer join @intermedPostTransact ipt on ipt.file_row_id = plb_parse.parentRowID
where plb_parse.rowtype = 'PLB'



/*****************************/
/* Calculate EDS Percentages */
/*****************************/

/****
	Whenever a claim is transmitted through EDS/ACS/HP/etc., any payment on that claim has a quantity
	deducted from the amount Medi-Cal would have paid on the claim. This amount is known as the EDS Percent,
	and represents the processing company's payment for acting as an intermediary.


****/

RAISERROR ('Calculating EDS percentages', 0, 1) WITH NOWAIT 

update @intermedPostTransact 
set EDS_PERCENT =  ccp_ipt.EDS_PERCENT
from 
@intermedPostTransact ipt
inner join
(
	select 
		case TOTAL_PAID when 0 then 0 else 
			(
				ISNULL(CONVERT(DECIMAL(18,10),((CHECK_TOTAL-TOTAL_PAID_VOID)/TOTAL_PAID))/*-CONVERT(DECIMAL(18,3),(TOTAL_PAID_VOID/TOTAL_PAID))*/,0)			
			) END as EDS_PERCENT,
		ipt.posting_id
	from @intermedPostTransact ipt
		inner join #raw_parse rp 
			on ipt.file_row_id = rp.rowID
		cross apply (select CONVERT(DECIMAL(18,2),REPLACE(rp.col6,'','0')) as CHECK_TOTAL from #raw_parse rpbt where rpbt.rowID = rp.rowID) as CHECK_VALUE
		cross apply (select SUM(CONVERT(DECIMAL(18,2),REPLACE(col8,'','0'))) as TOTAL_PAID from #raw_parse RPBT where rowtype = 'CLP' and RPBT.parentRowID = rp.rowID and col6 in ('1','2','3')) paid_total
		cross apply (select ISNULL(SUM(CONVERT(DECIMAL(18,2),REPLACE(col8,'','0'))),0) as TOTAL_PAID_VOID from #raw_parse RPBT where rowtype = 'CLP' and RPBT.parentRowID = rp.rowID and col6 in ('22')) void_total
	
		
		
) ccp_ipt 
on ccp_ipt.posting_id = ipt.posting_id

select '' as TEST_EDS_PERCENT_QUICK, * from @intermedPostTransact

update CLAIM_Claim_Adjudication
set EDSPERCENT = ipt.EDS_PERCENT
from 
CLAIM_Claim_Adjudication cca
inner join @intermedPostTransact ipt on cca.POSTING_ID = ipt.posting_id


/*********************************************************/
/* Update claim LISTAT/status to indicate payment/denial */
/*********************************************************/

/******* 
	835 claim status 1,2, or 3 all translate to a 'paid' claim status; 
	835 2 and 3 refer to second and third-tier repayments - see 835 spec on CLP segment data.
*******/



RAISERROR ('Claim status update', 0, 1) WITH NOWAIT 

declare @claim_paid int = dbo.CONST_CLAIM_STATUS_SUB_PAID()
declare @claim_den int = dbo.CONST_CLAIM_STATUS_SUB_REJECT()

update dbo.CLAIM_Claim
set 
    STATUS = conv_status
  , LAST_UPDATED = GETDATE()
from
(
	select 
	rcc.claim_id  as CONV_CLAIM_ID,
	CONV_STATUS =  
		CASE 
			when	col6 = 1	then @claim_paid
			when	col6 = 2 	then @claim_paid
			when	col6 = 3	then @claim_paid
			when	col6 = 4	then @claim_den
			
			when	col6 = 22 	then @claim_paid
		END,
		*
	from 
		#raw_parse rp
		inner join @Row_Claim_Correlation rcc 
			on rp.rowID = rcc.row_id
	where 
		rowtype = 'CLP' 
		and rp.rowID not in (select ret.row_id from @rowErrorTable ret left outer join @BIC_errored_but_post_anyways BIC on ret.row_id = BIC.row_id where BIC.row_id is null)
) q

where q.CONV_CLAIM_ID = claim_claim.CLAIM_ID


/***************************************************

	Disburse payments and denials from proxy claims
	in this posting to the original claims associated
	with each proxy.

***************************************************/

exec dbo.Claims_Proxy_Disburse

/******************************************************/
/* Posting is complete - generate posting report data */
/******************************************************/

RAISERROR ('HSPOST generation:', 0, 1) WITH NOWAIT 

RAISERROR ('error listings', 0, 1) WITH NOWAIT 

select '' as TRANSACTION_ERRORS, *
from 
	@rowErrorTable ret 
	inner join dbo.Claim_Claim_Posting_Errorcodes ccpe 
		on ret.error_code = ccpe.Error_ID
	inner join #raw_parse rp 
		on ret.row_id = rp.rowID 
		and rowtype = 'TRN'
order by rp.rowID

select '' as CLAIM_ERRORS, *
from 
	@rowErrorTable ret 
	inner join dbo.Claim_Claim_Posting_Errorcodes ccpe 
		on ret.error_code = ccpe.Error_ID
	inner join #raw_parse rp 
		on ret.row_id = rp.rowID 
		and rowtype = 'CLP' 
		and Short_Err <> 'PRNT_ERR'
	left outer join @Row_Claim_Correlation rcc on rcc.row_id = rp.rowID
	left outer join dbo.CLAIM_Claim cc on rcc.claim_id = cc.CLAIM_ID
order by rp.rowID


RAISERROR ('negative AMTPAIDs', 0, 1) WITH NOWAIT 

select '' as CLAIMS_NEGATIVE_AMTPAID,  * 
from 
	@intermedPostTransact ipt
	inner join dbo.CLAIM_Claim_Adjudication cca 
		on cca.AMOUNT_PAID < 0 
		and cca.POSTING_ID = ipt.POSTING_ID
	inner join dbo.CLAIM_Claim cc 
		on cca.CLAIM_ID = cc.CLAIM_ID

/**************************************************************************
	Transaction-Level Adjustments
	
	These adjustments originate in the PLB segment of the 835 file 
	and indicate an adjustment by the 835 processor unrelated 
	to any specific claim in the transaction (e.g. if a check is lost
	in the mail and needs to be reissued).
***************************************************************************/

RAISERROR ('Transaction-level adjustments', 0, 1) WITH NOWAIT 

select '' as TRANSACTION_ADJUSTMENTS , * 
from 
	dbo.Claim_Claim_Posting_Adjustments ccpa
	inner join @intermedPostTransact ipt 
		on ipt.posting_id = ccpa.POSTING_ID



/**********************************************************************************
	Claim-Level Adjustments:
	
	The aggregate here counts the number of claims listed in this 835 file
	that have more than one adjudication record linked to them.
	
	If a claim was in this file and has more than one adjudication record, 
	that indicates that that payment record in the 835 is an adjustment 
	on a claim that has been previously handled.
***********************************************************************************/

RAISERROR ('Claim-level adjustments', 0, 1) WITH NOWAIT 

select '' as CLAIM_ADJUSTMENTS, * 
from 
	@intermedPostTransact ipt
	inner join dbo.CLAIM_Claim_Adjudication cca 
		on cca.POSTING_ID = ipt.posting_id
	cross apply 
		(
			select 
				COUNT (*) num_pymts 
			from 
				dbo.CLAIM_Claim_Adjudication adj_ct 
			where 
				adj_ct.CLAIM_ID = cca.CLAIM_ID
		) adjust_check
		
	inner join dbo.CLAIM_Claim cc 
		on cc.CLAIM_ID = cca.CLAIM_ID

where adjust_check.num_pymts > 1


/*
	Print HSPOST data:
	
	When HEBS finished posting an 835 file, it generated an HSPOST report 
	that was used to update the Newtrans financial spreadsheet.
	
	This query replicates the core functionality of that report, generating
	financial and statistical data to copy and paste elsewhere.
	
*/

	select 
				ISNULL(SUM(CONVERT(DECIMAL(18,2),REPLACE(col8,'','0'))),0) as TOTAL_PAID 
			from 
				#raw_parse RPBT 
			where 
				rowtype = 'CLP' 
				--and RPBT.parentRowID = TRN_rp.rowID 
				and col6 in ('1','2','3')
					
RAISERROR ('HSPOST Actual', 0, 1) WITH NOWAIT 

select 'HSPOST Actual'


RAISERROR ('inserting posting data into archive table', 0, 1) WITH NOWAIT 

insert into dbo.Payment_Summary_By_Client_835 (
	

		POSTING_ID,					
		CLIENT_ID,					
		CLIENT_SHORT_NAME,
		CLIENT_NAME,					
		CLIENT_CDS,					
		
		CLIENT_NPI,					
		CLIENT_TAX_ID,

		CMC_SUBMITTER_ID,
		BALFLAG,			
		PROGRAM_TYPE,				
		POSTING_TYPE,				
		
		RADATE,						
		RANUMBER,					
		
		TOTAL_CLAIMS_BILLED,			
		TOTAL_AMOUNT_BILLED,			
		
		TOTAL_CLAIMS_PAID,			
		TOTAL_AMOUNT_PAID,			
		
		TOTAL_CLAIMS_DENIED,			
		TOTAL_AMOUNT_DENIED,			
		
		TOTAL_CLAIMS_VOID,			
		TOTAL_AMOUNT_VOID,			
		
		ADJ1REASON,					
		ADJ1AMOUNT,					
		
		ADJ2REASON,					
		ADJ2AMOUNT,					
		
		ADJ3REASON,					
		ADJ3AMOUNT,					
		
		CHECK_AMOUNT,				
		CHECK_DATE,					
		
		EDS_PERCENT,					
		
		AMOUNT_WITHHELD,				
		
		PAID_835_ERROR,				
		DENIED_835_ERROR,
		
		RevenueSharingCategoryLEA,
		WhenToInvoice,
		InvoiceRate

	)


select 
	
	ipt.posting_id,
	cli.CLIENT_ID,
	cli.ShortName,
	cli.CLIENT_NAME,
	cli.CLIENT_CDS,
	cli.NPI,
	cli.tax_id,
	TRN_rp.col28, /* CMC submitter ID */
	'P',			 /* BALFLAG */
	CASE ccp.HEALTHY_FAMILIES
		when 1 then 'A'
		else 1
	END as PROGTYPE,
	'835' as POSTTYPE,
	ccp.CHECK_DATE as RADATE, 
	ccp.CHECK_NUMBER as RANUMBER, 
	
	ISNULL(BILLEDCLMS.BILLEDCLMS ,0) as BILLEDCLMS,
	ISNULL(BILLEDCLMS.BILLEDAMT,0) as BILLEDAMT,
	
	ISNULL(PAID_CLMS.PAIDCLMS,0) as PAIDCLMS,
	ISNULL(PAID_CLMS.PAIDAMT,0) as PAIDAMT,
	ISNULL(DEN_CLMS.DENCLMS,0) as DENCLMS,
	ISNULL(den_clms.DENAMT,0) as DENAMT,
	ISNULL(VOID_OUT.VOIDCLMS,0) as VOIDCLMS,
	ISNULL(VOID_OUT.VOIDAMT,0) as VOIDAMT,

	ISNULL(ADJUST_DATA.identifier,'') as ADJ1REASON,   ISNULL(ADJUST_DATA.amount,0) as ADJ1AMOUNT,
	ISNULL(ADJUST_DATA_2.identifier,'') as ADJ2REASON, ISNULL(ADJUST_DATA_2.amount,0) as ADJ2AMOUNT,
	ISNULL(ADJUST_DATA_3.identifier,'') as ADJ3REASON, ISNULL(ADJUST_DATA_3.amount,0) as ADJ3AMOUNT,

	ccp.CHECK_AMOUNT as CHECKAMT,
	ccp.CHECK_DATE as CHECKDATE,
	
	CONVERT(decimal(18,10),ISNULL((select top 1 EDSPERCENT from CLAIM_Claim_Adjudication cca where cca.POSTING_ID = ccp.posting_id),0)) as EDSPERCENT,
	
	ISNULL(BILLEDAMT,0) - ISNULL(TOTAL_PAID,0) - ISNULL(TOTAL_DENIED_BILL,0) - ISNULL(VOIDBILLAMT,0) as AMTWH,
	
	PAID835ERR,
	DEN835ERR,
	
	CASE WHEN cli.RevenueSharingCategoryLEACurrent like 'LEA-%' THEN  RTRIM(LTRIM(SUBSTRING (cli.RevenueSharingCategoryLEACurrent, 5, 2))) else '**' END,
	cli.WhenToInvoice,
	cli.InvoiceRate
	
from 
	@intermedPostTransact ipt
	inner join #raw_parse TRN_rp 
		on ipt.file_row_id =TRN_rp.rowID and TRN_rp.rowtype = 'TRN'
	inner join dbo.CLIENTS_Client cli 
		on convert(nchar(10),TRN_rp.col39) = cli.NPI
	inner join dbo.CLAIM_Claim_Posting ccp 
		on ipt.posting_id = ccp.POSTING_ID
	outer  apply
		(
			select
			rp_bill.parentRowID,
				COUNT(*) as BILLEDCLMS
				,ISNULL(SUM(convert(decimal(18,2),replace(rp_bill.col7,'',0))),0) as BILLEDAMT
			from 
				#raw_parse rp_bill
			where 
				rp_bill.parentRowID = TRN_rp.rowID and rp_bill.rowtype = 'CLP' and TRN_rp.rowtype = 'TRN' and ISNUMERIC(rp_bill.col7) = 1 
			group by parentRowID
		) BILLEDCLMS
	
	outer apply
		(
			select 
				rp_paid.parentRowID,
				COUNT(*) as PAIDCLMS 
				,ISNULL(SUM(convert(decimal(18,2),REPLACE(rp_paid.col8,'',0))),0) as PAIDAMT
			from 
				#raw_parse rp_paid

			where 
				rp_paid.parentRowID = TRN_rp.rowID 
				and rp_paid.rowtype = 'CLP' 
				and rp_paid.col6 in ('1','2','3')
				and TRN_rp.rowtype = 'TRN'
				and ISNUMERIC(rp_paid.col8) = 1 
			group by parentRowID
		) PAID_CLMS

	outer apply
		(
			select 
				rp_den.parentRowID,
				COUNT(*) as DENCLMS 
				,ISNULL(SUM(convert(decimal(18,2),REPLACE(rp_den.col7,'','0'))),0) as DENAMT
			from 
				#raw_parse rp_den

			where 
				rp_den.parentRowID = TRN_rp.rowID 
				and rp_den.rowtype = 'CLP' 
				and rp_den.col6 in ('4')
				and TRN_rp.rowtype = 'TRN'
				and ISNUMERIC(rp_den.col7) = 1 
			group by parentRowID
		) DEN_CLMS

	outer apply 
		(
			select 
				rpbt.parentRowID,
				ISNULL(SUM(CONVERT(DECIMAL(18,2),REPLACE(col8,'','0'))),0) as TOTAL_PAID 
			from 
				#raw_parse RPBT 
			where 
				rowtype = 'CLP' 
				and RPBT.parentRowID = TRN_rp.rowID 
				and col6 in ('1','2','3')
				and ISNUMERIC(rpbt.col8) = 1 
			group by parentrowid
		) paid_total
	
	outer apply 
		(
			select 
				rpbt.parentRowID,
				ISNULL(SUM(CONVERT(DECIMAL(18,2),REPLACE(col7,'','0'))),0) 
				 as TOTAL_DENIED_BILL 
			from 
				#raw_parse RPBT 
			where 
				rowtype = 'CLP' 
				and RPBT.parentRowID = TRN_rp.rowID 
				and col6 in ('4')
				and ISNUMERIC(rpbt.col7) = 1 
			group by parentrowid
		) denbill_total
	
	outer apply 
			(
				select
				rpbt.parentRowID,
				COUNT(*) as VOIDCLMS, 
				ISNULL(SUM(CONVERT(DECIMAL(18,2),REPLACE(col8,'','0'))),0) 
					as VOIDAMT, 
				ISNULL(SUM(CONVERT(DECIMAL(18,2),REPLACE(col7,'','0'))),0) 
					as VOIDBILLAMT
				
				
				from #raw_parse RPBT 
				where rowtype = 'CLP' and RPBT.parentRowID = TRN_rp.rowID and col6 in ('22')
				and ISNUMERIC(rpbt.col8) = 1 
				and ISNUMERIC(rpbt.col7) = 1 
				group by parentrowid
			) VOID_OUT
	
	
	left outer join
		(
			select 
				ROW_NUMBER() over (partition by posting_id order by AMOUNT desc) as line
				,* 
			from 
				dbo.CLAIM_Claim_Posting_Adjustments ccpa
		) ADJUST_DATA 
			on ADJUST_DATA.posting_id = ipt.posting_id 
			and ADJUST_DATA.line = 1

	left outer join
		(
			select 
				ROW_NUMBER() over (partition by posting_id order by AMOUNT desc) as line
				,* 
			from 
				dbo.CLAIM_Claim_Posting_Adjustments ccpa
		) ADJUST_DATA_2 
			on ADJUST_DATA_2.posting_id = ipt.posting_id 
			and ADJUST_DATA_2.line = 2

	left outer join
		(
			select 
				ROW_NUMBER() over (partition by posting_id order by AMOUNT desc) as line
				,* 
			from 
				dbo.CLAIM_Claim_Posting_Adjustments ccpa
		) ADJUST_DATA_3 
			on ADJUST_DATA_3.posting_id = ipt.posting_id 
			and ADJUST_DATA_3.line = 3

	left outer join
		(
			select 
				rp_trn.rowID
				,DENCLMCT = COUNT (rp_clp.rowid)  --as DENCLMCT 
				,ISNULL(SUM(convert(decimal(18,2),REPLACE(rp_clp.col7,'','0'))),0) as DENAMT		
			from 
				#raw_parse rp_clp
				inner join (select distinct row_id from  @rowErrorTable) ret 
					on	rp_clp.rowtype = 'CLP' 
					and rp_clp.rowID = ret.row_id
				inner join #raw_parse rp_trn
					on rp_clp.parentRowID = rp_trn.rowID 
					and rp_trn.rowtype = 'TRN'
			group by rp_trn.rowID
		) ERROROUT 
			on ERROROUT.rowid = ipt.file_row_id
		


		
		
	/***************************************
	
		Paid and denied 835 errors in this report
		ONLY include errored claims within a non-errored posting.
		
		If the client/posting/transaction has an inherent error (no matching NPI, etc.), 
		then they will not show up in the final HSPOST report output
	
	****************************************/
		
		
	outer apply 
		(
			select 
				ISNULL(SUM(CONVERT(decimal(18,2),ISNULL(replace(rp.col7,'',0),0))),0) as PAID835ERR
			from 
				@intermedPostTransact ipt
				inner join #raw_parse rp 
					on ipt.file_row_id = rp.parentRowID and col6 in ('1','2','3','22') and rowtype = 'CLP'
				inner join 
					(
						select distinct row_ID 
						from 
							@rowErrorTable row_error
							inner join dbo.Claim_Claim_Posting_Errorcodes ccpe 
								on ccpe.Error_ID = row_error.error_code
								--and ccpe.Short_Err in ('CLM_ID_FRMT','CLM_ID_EXIST')
					) ret
					on ret.row_id = rp.rowID
			where ipt.posting_id = ccp.POSTING_ID
		) PAIDERRLIST

	outer apply 
		(
			select ISNULL(SUM(CONVERT(decimal(18,2),ISNULL(replace(rp.col7,'',0),0))),0) as DEN835ERR
			from 
				@intermedPostTransact ipt
				inner join #raw_parse rp 
					on ipt.file_row_id = rp.parentRowID and col6 ='4' and rowtype = 'CLP'
				inner join
					(
						select distinct row_ID 
						from 
							@rowErrorTable row_error
					) ret
					on ret.row_id = rp.rowID
			where ipt.posting_id = ccp.POSTING_ID
		) DENERRLIST

order by 
	CLIENT_CDS
			
/* Update check date for client table */

RAISERROR ('Updating posting clients with LAST_CHECK details', 0, 1) WITH NOWAIT 

update dbo.CLIENTS_Client
set LAST_CHECK = @warrantDate
where CLIENT_ID in
(
	select psbc.CLIENT_ID from dbo.Payment_Summary_By_Client_835 psbc
	where POSTING_ID in
		(select ipt.posting_id from @intermedPostTransact ipt)
)
		
/* report results using archival storage */

RAISERROR ('reporting payment data results', 0, 1) WITH NOWAIT 

select 

	SUBSTRING(psbc.CLIENT_CDS,0,3) + '-' + SUBSTRING(psbc.CLIENT_CDS, 3,20)	as SCHDIST,
	'SS'+ psbc.client_CDS as SCHMEDID,
	psbc.CLIENT_NPI, 
	psbc.CLIENT_NAME, 
	psbc.CMC_SUBMITTER_ID as CMCSUBID,
	psbc.BALFLAG,
	psbc.PROGRAM_TYPE as PROGTYPE,
	psbc.POSTING_TYPE as POSTTYPE,
	psbc.RADATE, 
	psbc.RANUMBER, 
	'' as RACHKNUM,
	psbc.CLIENT_TAX_ID as TAX_ID
	,psbc.TOTAL_CLAIMS_BILLED as BILLEDCLMS
	,psbc.TOTAL_AMOUNT_BILLED as BILLEDAMT
	,psbc.TOTAL_CLAIMS_PAID as PAIDCLMS
	,psbc.TOTAL_AMOUNT_PAID as PAIDAMT
	,psbc.TOTAL_CLAIMS_DENIED as DENCLMS
	,psbc.TOTAL_AMOUNT_DENIED as DENAMT
	,psbc.TOTAL_CLAIMS_VOID as VOIDCLMS
	,psbc.TOTAL_AMOUNT_VOID as VOIDAMT

	
	
	,psbc.ADJ1REASON, psbc.ADJ1AMOUNT
	,psbc.ADJ2REASON, psbc.ADJ2AMOUNT
	,psbc.ADJ3REASON, psbc.ADJ3AMOUNT


	, psbc.CHECK_AMOUNT as CHECKAMT
	, psbc.CHECK_DATE as CHECKDATE
	/*,'EDSPERCENT' = case PAID_CLMS.PAIDAMT when 0 then 0 else convert(numeric(18,3),(select top 1 EDSPERCENT from CLAIM_Claim_Adjudication cca where cca.POSTING_ID = ccp.posting_id) q) END*/
	,psbc.EDS_PERCENT as EDSPERCENT
	

	,ISNULL(TOTAL_AMOUNT_BILLED,0) - ISNULL(TOTAL_AMOUNT_PAID,0) - ISNULL(TOTAL_AMOUNT_DENIED,0) - ISNULL(TOTAL_AMOUNT_VOID,0) as AMTWH

	,psbc.PAID_835_ERROR as PAID835ERR
	,psbc.DENIED_835_ERROR as DEN835ERR
	,psbc.PAYMENT_LINE_ID 
	,psbc.RevenueSharingCategoryLEA as 'Revenue Sharing Category-LEA'
	,psbc.WhenToInvoice as 'When to Invoice'
	,psbc.InvoiceRate as 'Invoice Rate'

from 
	dbo.Payment_Summary_By_Client_835 psbc 
	inner join @intermedPostTransact ipt 
		on ipt.posting_id = psbc.POSTING_ID		
					
/**************************************************************************************************************

	Claim denial/detail reporting:
	
	If a claim is denied or the claim amount is adjusted due to relevant circumstances,
	detail codes are attached in the CAS and/or LQ segments for that claim payment record 
	to show reasons for that adjustment.
	
	Doing analysis on the claim details for a posting is often useful for determining if 
	a claim or claims can be corrected and resubmitted.
	
	This analysis takes the form of:
	
		* Run a check to display the denial percentage for each client in the current posting, 
		  as well as each client's denial percentage for their last posting. A large increase 
		  in denial percentages may warrant further examination.
		  
		* For each client in the current posting, display an aggregate listing of the detail
		  codes for that client and the total number of claims with that detail code. 
		  This breakdown provides further detail about what kinds of issues may have resulted in denials.

***************************************************************************************************************/	
	
select client.CLIENT_NAME, CURRENT_TOTAL
		,case when CURRENT_TOTAL = 0 then 0 else CONVERT(DECIMAL(18,2),100*(CURRENT_DENIED/CONVERT(DECIMAL(18,2),CURRENT_TOTAL))) end as CURRENT_PERCENTAGE_DENIED
		,case when PREVIOUS_TOTAL = 0 then 0 else CONVERT(DECIMAL(18,2),100*(PREVIOUS_DENIED/CONVERT(DECIMAL(18,2),previous_total))) end as PREVIOUS_PERCENTAGE_DENIED
		
from 
	@intermedPostTransact ipt
	inner join dbo.CLAIM_Claim_Posting ccp on ipt.posting_id = ccp.POSTING_ID
	inner join dbo.CLIENTS_Client client on ccp.clientid = client.CLIENT_ID
	
	outer apply 
	(
		select 
			top 1 * 
		from 
			dbo.CLAIM_Claim_Posting ccp2
		where 
			ccp2.clientID = ccp.clientID
			and ccp2.POSTING_DATE <> ccp.POSTING_DATE
		order by 
			ccp2.POSTING_DATE desc
	) next_prev_ccp
	
	outer apply
	(
		select COUNT(*) as CURRENT_TOTAL 
		from 
			dbo.CLAIM_Claim_Adjudication cca
			inner join dbo.CLAIM_Claim cc 
				on cca.CLAIM_ID = cc.CLAIM_ID 
				and cca.POSTING_ID = ccp.POSTING_ID
	) curr_post_total_claims
	
	outer apply
	(
		select COUNT(*) as CURRENT_DENIED 
		from 
			dbo.CLAIM_Claim_Adjudication cca
			inner join dbo.CLAIM_Claim cc 
				on cca.CLAIM_ID = cc.CLAIM_ID 
				and cca.POSTING_ID = ccp.POSTING_ID
				and cc.STATUS <> dbo.CONST_CLAIM_STATUS_SUB_PAID() /* Claims which have denied and resubmitted no longer have DENIED statuses. Since the only two choices for an adjudicated claim are PAID and DENIED, any claim which is not PAID must therefore be DENIED. */
	) curr_post_total_denied
	
	outer apply
	(
		select COUNT(*) as PREVIOUS_TOTAL 
		from 
			dbo.CLAIM_Claim_Adjudication cca
			inner join dbo.CLAIM_Claim cc 
				on cca.CLAIM_ID = cc.CLAIM_ID 
				and cca.POSTING_ID = next_prev_ccp.POSTING_ID
	) prev_post_total_claims
	
	outer apply
	(
		select COUNT(*) as PREVIOUS_DENIED 
		from 
			dbo.CLAIM_Claim_Adjudication cca
			inner join dbo.CLAIM_Claim cc 
				on cca.CLAIM_ID = cc.CLAIM_ID 
				and cca.POSTING_ID = next_prev_ccp.POSTING_ID
				and cc.STATUS <> dbo.CONST_CLAIM_STATUS_SUB_PAID()
	) prev_post_total_denied
	
select 
	client.CLIENT_NAME, 
	cdc.CODE_VALUE as DENIAL_CODE_VALUE, 
	cdc.DETAIL_TEXT, 
	COUNT(*) as NUMBER_OF_CLAIMS
	
from 
		@intermedPostTransact ipt
		inner join dbo.CLAIM_Claim_Posting ccp 
			on ipt.posting_id = ccp.POSTING_ID
		
		inner join dbo.CLAIM_Claim_Adjudication cca 
			on cca.POSTING_ID = ccp.POSTING_ID
		
		inner join dbo.CLAIM_CLAIM_ADJUDICATION_DETAILS ccad 
			on cca.ADJUDICATION_ID = ccad.ADJUDICATION_ID
		
		inner join dbo.CLAIM_DETAIL_CODES cdc 
			on ccad.DETAIL_CODE_ID = cdc.CODE_ID
			and cdc.IS_ARC_CARC = 1			
		
		inner join dbo.CLIENTS_Client client 
			on ccp.clientid = client.CLIENT_ID
			
		inner join dbo.CLAIM_Claim cc 
			on cca.CLAIM_ID = cc.CLAIM_ID 
			and cc. STATUS = dbo.CONST_CLAIM_STATUS_SUB_REJECT()
		
group by CLIENT_NAME, CODE_VALUE, DETAIL_TEXT
order by CLIENT_NAME, DENIAL_CODE_VALUE

/***********************************************************************************
 * Reporting: Identify still-payable claims that were transmitted over 2 weeks ago *
 ***********************************************************************************/

select
	convert(date,GETDATE()) as  'CURRENT_DATE',
	convert(date,dateadd(DAY,-14,GETDATE())) as 'TRANSMISSION BEFORE DATE',
	convert(date,dateadd(year,-1, DateAdd(Day, 1, GETDATE() - Day(GETDATE()) + 1) -1)) as 'SERVICES AFTER DATE'
	
select '' as UNRETURNED_CLAIMS_AS_PER_DATES
  , cc.*
  , cli.*
  , trc.trc_ID
  , trc.transmission_id
  , trc.claim_id
  , trc.Amount_Transmitted
  , tr.* 

from dbo.CLAIM_Claim cc 
inner join dbo.CLIENTS_Client cli 
	on cli.CLIENT_ID=cc.CLIENT_ID
	and cli.LEA = 1
	and cc.STATUS = 2
	and cc.SERVICE_DATE >= convert(date,dateadd(year,-1, DateAdd(Day, 1, GETDATE() - Day(GETDATE()) + 1) -1))
inner join dbo.TRANSMISSION_RECORD_CLAIMS_ALL as trc on  trc.claim_id = cc.CLAIM_ID
inner join dbo.Transmission_Records_All as tr 
	on tr.Transmission_ID=trc.transmission_id
	and tr.Created_at < 	convert(date,dateadd(DAY,-14,GETDATE()))

/************************************************************************
 *	Posting done, report done, check to see if commit or rollback       *
 ************************************************************************/

if @isTestRun = 1
BEGIN
	print 'Test posting completed - starting rollback.'
	ROLLBACK TRANSACTION
END
else 
BEGIN
	print 'Posting completed - starting commit.'
	COMMIT TRANSACTION
END


print 'end posting'
print getdate()


END --of 'manually entered check date is okay, start doing stuff with proper posting


drop table #raw_parse

END -- of stored procedure
GO