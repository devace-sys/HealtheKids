USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CASEMIS_FLATFILE_IMPORT') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.CASEMIS_FLATFILE_IMPORT
GO


CREATE PROCEDURE dbo.CASEMIS_FLATFILE_IMPORT 
(
	@a_path varchar(max),
	@B_path varchar(max),

	@save_record bit = 1,
	
	@casemis_id bigint OUTPUT
	
)    
AS    
BEGIN    

/************************************************

CASEMIS_FLATFILE_IMPORT

After the CASEMIS A and B files have been processed by
the external parser application, the full contents of 
each file are loaded into SQL tables for later reference 
in student data matching and services research.

During the upload process, data elements are checked 
against the standard specified in the CASEMIS TAG;
however, these checks don't provide any kind of flow
control during file import - they're after-action 
review only.

***************************************************/




declare @a_errorcount bigint = 0
declare @b_errorcount bigint = 0 

/***************************************************/
/*                                                 */
/*           CASEMIS-A FILE IMPORT                 */
/*                                                 */
/***************************************************/

/* Start by initalizing tables */

/* Holds raw text data from the flatfile */
Create table #Raw_String_A
(
	line_text varchar(max)
)

/* Interim table 1: split flatfile into textual chunks of specific columns of type info*/
create table #Raw_Casemis_A
(
	line_id		bigint identity (1,1),
	REPT_DATE	varchar( 	8),
	SELPA_CODE	varchar(	4),
	SELPA_FROM	varchar(	4),
	DIST_SERV	varchar(	7),
	DIST_RESI	varchar(	7),
	SCH_CODE	varchar(	7),
	SCH_TYPE	varchar(	2),
	LAST_NAME	varchar(	15),
	FIRST_NAME	varchar(	15),
	STUDENT_ID	varchar(	16),
	SSID		varchar(	10),
	SSN			varchar(	9),
	BIRTHDATE	varchar(	8),
	GENDER		varchar(	1),
	ETHNICITY	varchar(	3),
	RACE1		varchar(	3),
	RACE2		varchar(	3),
	RACE3		varchar(	3),
	EL			varchar(	1),
	NATIV_LANG	varchar(	2),
	EARLY_INT	varchar(	1),
	IN_RFRDATE	varchar(	8),
	IN_RFRBY	varchar( 	2),
	IN_PRNTCST	varchar(	8),
	IN_INTEVAL	varchar( 	8),
	REFR_DATE	varchar(	8),
	REFR_BY		varchar(	2),
	PRNT_CSNT	varchar(	8),
	INIT_EVAL	varchar(	8),
	EVLDLAY		varchar(	2),
	TBDLAY		varchar(	2),
	PLAN_TYPE	varchar(	2),
	MIGRANT		varchar(	1),
	RESID_STAT	varchar(	2),
	ENTRY_DATE	varchar(	8),
	LAST_IEP	varchar(	8),
	LAST_EVAL	varchar(	8),
	DISABILIT1	varchar(	3),
	DISABILIT2	varchar(	3),
	SOLE_LOW	varchar(	1),
	INFANT_SET	varchar(	2),
	FEDSET_INF	varchar(	3),
	FEDSET_PRS	varchar(	3),
	FEDSET_SCH	varchar(	3),
	IN_REGCLS	varchar(	3),
	GRADE		varchar(	2),
	TRAN_REG1	varchar(	2),
	TRAN_REG2	varchar(	2),
	TRAN_REG3	varchar(	2),
	TRAN_REG4	varchar(	2),
	TRAN_REG5	varchar(	2),
	TRAN_REG6	varchar(	2),
	TRAN_REG7	varchar(	2),
	TRAN_REG8	varchar(	2),
	SPEC_TRANS	varchar(	1),
	PARINPUT	varchar(	2),
	PARTI_CAH	varchar(	2),
	PARTI_MATH	varchar(	2),
	PARTI_SCI	varchar(	2),
	PARTI_ELA	varchar(	2),
	PARTI_HIS	varchar(	2),
	PARTI_WRTG	varchar(	2),
	GRAD_PLAN	varchar(	2),
	EXIT_DATE	varchar(	8),
	EXIT_RESON	varchar(	2)
)


/* Interim table 2: Take chunked text data and convert into concrete types (like dates) */
create table #a_casemis_upload
(
	line_id		bigint,
	REPT_DATE	date,
	SELPA_CODE	varchar(	4),
	SELPA_FROM	varchar(	4),
	DIST_SERV	varchar(	7),
	DIST_RESI	varchar(	7),
	SCH_CODE	varchar(	7),
	SCH_TYPE	varchar(	2),
	LAST_NAME	varchar(	15),
	FIRST_NAME	varchar(	15),
	STUDENT_ID	varchar(	16),
	SSID		varchar(	10),
	SSN			varchar(	9),
	BIRTHDATE	date,
	GENDER		varchar(	1),
	ETHNICITY	varchar(	3),
	RACE1		varchar(	3),
	RACE2		varchar(	3),
	RACE3		varchar(	3),
	EL			varchar(	1),
	NATIV_LANG	varchar(	2),
	EARLY_INT	varchar(	1),
	IN_RFRDATE	date,
	IN_RFRBY	varchar( 	2),
	IN_PRNTCST	date,
	IN_INTEVAL	date,
	REFR_DATE	date,
	REFR_BY		varchar(	2),
	PRNT_CSNT	date,
	INIT_EVAL	date,
	EVLDLAY		varchar(	2),
	TBDLAY		varchar(	2),
	PLAN_TYPE	varchar(	2),
	MIGRANT		varchar(	1),
	RESID_STAT	varchar(	2),
	ENTRY_DATE	date,
	LAST_IEP	date,
	LAST_EVAL	date,
	DISABILIT1	varchar(	3),
	DISABILIT2	varchar(	3),
	SOLE_LOW	varchar(	1),
	INFANT_SET	varchar(	2),
	FEDSET_INF	varchar(	3),
	FEDSET_PRS	varchar(	3),
	FEDSET_SCH	varchar(	3),
	IN_REGCLS	varchar(	3),
	GRADE		varchar(	2),
	TRAN_REG1	varchar(	2),
	TRAN_REG2	varchar(	2),
	TRAN_REG3	varchar(	2),
	TRAN_REG4	varchar(	2),
	TRAN_REG5	varchar(	2),
	TRAN_REG6	varchar(	2),
	TRAN_REG7	varchar(	2),
	TRAN_REG8	varchar(	2),
	SPEC_TRANS	varchar(	1),
	PARINPUT	varchar(	2),
	PARTI_CAH	varchar(	2),
	PARTI_MATH	varchar(	2),
	PARTI_SCI	varchar(	2),
	PARTI_ELA	varchar(	2),
	PARTI_HIS	varchar(	2),
	PARTI_WRTG	varchar(	2),
	GRAD_PLAN	varchar(	2),
	EXIT_DATE	date,
	EXIT_RESON	varchar(	2)
)

/* Holds raw text data from the flatfile */
Create table #Raw_String_B
(
	line_text varchar(max)
)


/* Interim table 1: split flatfile into textual chunks of specific columns of type info*/
create table #Raw_Casemis_B
(
	line_id		bigint identity (1,1),
	REPT_DATE	varchar(8),
	SELPA_CODE	varchar(4),
	STUDENT_ID	varchar(16),
	SSID		varchar(10),
	SERVICE		varchar(3),
	PROVIDER	varchar(3),
	LOCATION	varchar(3),
	FREQUENCY	varchar(2),
	DURATION	varchar(4)
)

/* Interim table 2: Take chunked text data and convert into concrete types (like dates) */
create table #B_casemis_upload
(
	line_id		bigint,
	REPT_DATE	date,
	SELPA_CODE	varchar(4),
	STUDENT_ID	varchar(16),
	SSID		varchar(10),
	SERVICE		varchar(3),
	PROVIDER	varchar(3),
	LOCATION	varchar(3),
	FREQUENCY	varchar(2),
	DURATION	int
)


/* Pull file data into working storage */

declare @a_blk_str nvarchar(4000)

	/* Upload raw text information from a flatfile */
	set @a_blk_str = 'bulk insert #raw_String_A from ''' + @a_path + ''' WITH ( FIELDTERMINATOR ='','', ROWTERMINATOR =''\n'' )';
	print @a_blk_str
	exec (@a_blk_str)



/* Chunk raw text */

insert into #Raw_Casemis_A 
(
	REPT_DATE,
	SELPA_CODE,
	SELPA_FROM,
	DIST_SERV,
	DIST_RESI,
	SCH_CODE,
	SCH_TYPE,
	LAST_NAME,
	FIRST_NAME,
	STUDENT_ID,
	SSID,
	SSN,
	BIRTHDATE,
	GENDER,
	ETHNICITY,
	RACE1,
	RACE2,
	RACE3,
	EL,
	NATIV_LANG,
	EARLY_INT,
	IN_RFRDATE,
	IN_RFRBY,
	IN_PRNTCST,
	IN_INTEVAL,
	REFR_DATE,
	REFR_BY,
	PRNT_CSNT,
	INIT_EVAL,
	EVLDLAY,
	TBDLAY,
	PLAN_TYPE,
	MIGRANT,
	RESID_STAT,
	ENTRY_DATE,
	LAST_IEP,
	LAST_EVAL,
	DISABILIT1,
	DISABILIT2,
	SOLE_LOW,
	INFANT_SET,
	FEDSET_INF,
	FEDSET_PRS,
	FEDSET_SCH,
	IN_REGCLS,
	GRADE,
	TRAN_REG1,
	TRAN_REG2,
	TRAN_REG3,
	TRAN_REG4,
	TRAN_REG5,
	TRAN_REG6,	
	TRAN_REG7,	
	TRAN_REG8,	
	SPEC_TRANS,	
	PARINPUT,	
	PARTI_CAH,	
	PARTI_MATH,	
	PARTI_SCI,	
	PARTI_ELA,	
	PARTI_HIS,	
	PARTI_WRTG,	
	GRAD_PLAN,	
	EXIT_DATE,	
	EXIT_RESON
)	
select 
	SUBSTRING(line_text, 	1	,	8	)	,
	SUBSTRING(line_text, 	9	,	4	)	,
	SUBSTRING(line_text, 	13	,	4	)	,
	SUBSTRING(line_text, 	17	,	7	)	,
	SUBSTRING(line_text, 	24	,	7	)	,
	SUBSTRING(line_text, 	31	,	7	)	,
	SUBSTRING(line_text, 	38	,	2	)	,
	SUBSTRING(line_text, 	40	,	15	)	,
	SUBSTRING(line_text, 	55	,	15	)	,
	SUBSTRING(line_text, 	70	,	16	)	,
	SUBSTRING(line_text, 	86	,	10	)	,
	SUBSTRING(line_text, 	96	,	9	)	,
	SUBSTRING(line_text, 	105	,	8	)	,
	SUBSTRING(line_text, 	113	,	1	)	,
	SUBSTRING(line_text, 	114	,	3	)	,
	SUBSTRING(line_text, 	117	,	3	)	,
	SUBSTRING(line_text, 	120	,	3	)	,
	SUBSTRING(line_text, 	123	,	3	)	,
	SUBSTRING(line_text, 	126	,	1	)	,
	SUBSTRING(line_text, 	127	,	2	)	,
	SUBSTRING(line_text, 	129	,	1	)	,
	SUBSTRING(line_text, 	130	,	8	)	,
	SUBSTRING(line_text, 	138	,	2	)	,
	SUBSTRING(line_text, 	140	,	8	)	,
	SUBSTRING(line_text, 	148	,	8	)	,
	SUBSTRING(line_text, 	156	,	8	)	,
	SUBSTRING(line_text, 	164	,	2	)	,
	SUBSTRING(line_text, 	166	,	8	)	,
	SUBSTRING(line_text, 	174	,	8	)	,
	SUBSTRING(line_text, 	182	,	2	)	,
	SUBSTRING(line_text, 	184	,	2	)	,
	SUBSTRING(line_text, 	186	,	2	)	,
	SUBSTRING(line_text, 	188	,	1	)	,
	SUBSTRING(line_text, 	189	,	2	)	,
	SUBSTRING(line_text, 	191	,	8	)	,
	SUBSTRING(line_text, 	199	,	8	)	,
	SUBSTRING(line_text, 	207	,	8	)	,
	SUBSTRING(line_text, 	215	,	3	)	,
	SUBSTRING(line_text, 	218	,	3	)	,
	SUBSTRING(line_text, 	221	,	1	)	,
	SUBSTRING(line_text, 	222	,	2	)	,
	SUBSTRING(line_text, 	224	,	3	)	,
	SUBSTRING(line_text, 	227	,	3	)	,
	SUBSTRING(line_text, 	230	,	3	)	,
	SUBSTRING(line_text, 	233	,	3	)	,
	SUBSTRING(line_text, 	236	,	2	)	,
	SUBSTRING(line_text, 	238	,	2	)	,
	SUBSTRING(line_text, 	240	,	2	)	,
	SUBSTRING(line_text, 	242	,	2	)	,
	SUBSTRING(line_text, 	244	,	2	)	,
	SUBSTRING(line_text, 	246	,	2	)	,
	SUBSTRING(line_text, 	248	,	2	)	,
	SUBSTRING(line_text, 	250	,	2	)	,
	SUBSTRING(line_text, 	252	,	2	)	,
	SUBSTRING(line_text, 	254	,	1	)	,
	SUBSTRING(line_text, 	255	,	2	)	,
	SUBSTRING(line_text, 	257	,	2	)	,
	SUBSTRING(line_text, 	259	,	2	)	,
	SUBSTRING(line_text, 	261	,	2	)	,
	SUBSTRING(line_text, 	263	,	2	)	,
	SUBSTRING(line_text, 	265	,	2	)	,
	SUBSTRING(line_text, 	267	,	2	)	,
	SUBSTRING(line_text, 	269	,	2	)	,
	SUBSTRING(line_text, 	271	,	8	)	,
	SUBSTRING(line_text, 	279	,	2	)	
from #Raw_String_A


/* Modify date values so blank entries are not set as 19000101 dates */

update #Raw_Casemis_A
set REPT_DATE = NULL
where REPT_DATE = ''

update #Raw_Casemis_A
set BIRTHDATE = NULL
where BIRTHDATE = ''

update #Raw_Casemis_A
set IN_RFRDATE = NULL
where IN_RFRDATE = ''

update #Raw_Casemis_A
set IN_PRNTCST = NULL
where IN_PRNTCST = ''

update #Raw_Casemis_A
set IN_INTEVAL = NULL
where IN_INTEVAL = ''

update #Raw_Casemis_A
set REFR_DATE = NULL
where REFR_DATE = ''

update #Raw_Casemis_A
set PRNT_CSNT = NULL
where PRNT_CSNT = ''

update #Raw_Casemis_A
set INIT_EVAL = NULL
where INIT_EVAL = ''

update #Raw_Casemis_A
set ENTRY_DATE = NULL
where ENTRY_DATE = ''

update #Raw_Casemis_A
set LAST_IEP = NULL
where LAST_IEP = ''

update #Raw_Casemis_A
set LAST_EVAL = NULL
where LAST_EVAL = ''

update #Raw_Casemis_A
set EXIT_DATE = NULL
where EXIT_DATE = ''




 /* Some files may use non-whitespace to pad blank date values */
 
 update #Raw_Casemis_A
	set REPT_DATE = null
	where REPT_DATE = '00000000'
	
	
 update #Raw_Casemis_A
	set BIRTHDATE = null
	where BIRTHDATE = '00000000'
	
 update #Raw_Casemis_A
	set IN_RFRDATE = null
	where IN_RFRDATE = '00000000'
	
 update #Raw_Casemis_A
	set IN_PRNTCST = null
	where IN_PRNTCST = '00000000'
 
  update #Raw_Casemis_A
	set IN_INTEVAL = null
	where IN_INTEVAL = '00000000'
	
 update #Raw_Casemis_A
	set REFR_DATE = null
	where REFR_DATE = '00000000'
	
 update #Raw_Casemis_A
	set PRNT_CSNT = null
	where PRNT_CSNT = '00000000'
	
 update #Raw_Casemis_A
	set INIT_EVAL = null
	where INIT_EVAL = '00000000'
 
  update #Raw_Casemis_A
	set ENTRY_DATE = null
	where ENTRY_DATE = '00000000'

 update #Raw_Casemis_A
	set LAST_IEP = null
	where LAST_IEP = '00000000'
	
 update #Raw_Casemis_A
	set LAST_EVAL = null
	where LAST_EVAL = '00000000'	
 
  update #Raw_Casemis_A
	set EXIT_DATE = null
	where BIRTHDATE = '00000000'
 
 
 
 







select * from #Raw_Casemis_A


/* Load into final prep table before validation and commit to hard table in DB */

insert into #a_casemis_upload
(
	line_id,
	REPT_DATE,
	SELPA_CODE,
	SELPA_FROM,
	DIST_SERV,
	DIST_RESI,
	SCH_CODE,
	SCH_TYPE,
	LAST_NAME,
	FIRST_NAME,
	STUDENT_ID,
	SSID,
	SSN,
	BIRTHDATE,
	GENDER,
	ETHNICITY,
	RACE1,
	RACE2,
	RACE3,
	EL,
	NATIV_LANG,
	EARLY_INT,
	IN_RFRDATE,
	IN_RFRBY,
	IN_PRNTCST,
	IN_INTEVAL,
	REFR_DATE,
	REFR_BY,
	PRNT_CSNT,
	INIT_EVAL,
	EVLDLAY,
	TBDLAY,
	PLAN_TYPE,
	MIGRANT,
	RESID_STAT,
	ENTRY_DATE,
	LAST_IEP,
	LAST_EVAL,
	DISABILIT1,
	DISABILIT2,
	SOLE_LOW,
	INFANT_SET,
	FEDSET_INF,
	FEDSET_PRS,
	FEDSET_SCH,
	IN_REGCLS,
	GRADE,
	TRAN_REG1,
	TRAN_REG2,
	TRAN_REG3,
	TRAN_REG4,
	TRAN_REG5,
	TRAN_REG6,	
	TRAN_REG7,	
	TRAN_REG8,	
	SPEC_TRANS,	
	PARINPUT,	
	PARTI_CAH,	
	PARTI_MATH,	
	PARTI_SCI,	
	PARTI_ELA,	
	PARTI_HIS,	
	PARTI_WRTG,	
	GRAD_PLAN,	
	EXIT_DATE,	
	EXIT_RESON
)
select 
	line_id,
	LTRIM(RTRIM(REPT_DATE)),
	LTRIM(RTRIM(SELPA_CODE)),
	LTRIM(RTRIM(SELPA_FROM)),
	LTRIM(RTRIM(DIST_SERV)),
	LTRIM(RTRIM(DIST_RESI)),
	LTRIM(RTRIM(SCH_CODE)),
	LTRIM(RTRIM(SCH_TYPE)),
	LTRIM(RTRIM(LAST_NAME)),
	LTRIM(RTRIM(FIRST_NAME)),
	LTRIM(RTRIM(STUDENT_ID)),
	LTRIM(RTRIM(SSID)),
	LTRIM(RTRIM(SSN)),
	LTRIM(RTRIM(BIRTHDATE)),
	LTRIM(RTRIM(GENDER)),
	LTRIM(RTRIM(ETHNICITY)),
	LTRIM(RTRIM(RACE1)),
	LTRIM(RTRIM(RACE2)),
	LTRIM(RTRIM(RACE3)),
	LTRIM(RTRIM(EL)),
	LTRIM(RTRIM(NATIV_LANG)),
	LTRIM(RTRIM(EARLY_INT)),
	LTRIM(RTRIM(IN_RFRDATE)),
	LTRIM(RTRIM(IN_RFRBY)),
	LTRIM(RTRIM(IN_PRNTCST)),
	LTRIM(RTRIM(IN_INTEVAL)),
	LTRIM(RTRIM(REFR_DATE)),
	LTRIM(RTRIM(REFR_BY)),
	LTRIM(RTRIM(PRNT_CSNT)),
	LTRIM(RTRIM(INIT_EVAL)),
	LTRIM(RTRIM(EVLDLAY)),
	LTRIM(RTRIM(TBDLAY)),
	LTRIM(RTRIM(PLAN_TYPE)),
	LTRIM(RTRIM(MIGRANT)),
	LTRIM(RTRIM(RESID_STAT)),
	LTRIM(RTRIM(ENTRY_DATE)),
	LTRIM(RTRIM(LAST_IEP)),
	LTRIM(RTRIM(LAST_EVAL)),
	LTRIM(RTRIM(DISABILIT1)),
	LTRIM(RTRIM(DISABILIT2)),
	LTRIM(RTRIM(SOLE_LOW)),
	LTRIM(RTRIM(INFANT_SET)),
	LTRIM(RTRIM(FEDSET_INF)),
	LTRIM(RTRIM(FEDSET_PRS)),
	LTRIM(RTRIM(FEDSET_SCH)),
	LTRIM(RTRIM(IN_REGCLS)),
	LTRIM(RTRIM(GRADE)),
	LTRIM(RTRIM(TRAN_REG1)),
	LTRIM(RTRIM(TRAN_REG2)),
	LTRIM(RTRIM(TRAN_REG3)),
	LTRIM(RTRIM(TRAN_REG4)),
	LTRIM(RTRIM(TRAN_REG5)),
	LTRIM(RTRIM(TRAN_REG6)),	
	LTRIM(RTRIM(TRAN_REG7)),	
	LTRIM(RTRIM(TRAN_REG8)),	
	LTRIM(RTRIM(SPEC_TRANS)),	
	LTRIM(RTRIM(PARINPUT)),	
	LTRIM(RTRIM(PARTI_CAH)),	
	LTRIM(RTRIM(PARTI_MATH)),	
	LTRIM(RTRIM(PARTI_SCI)),	
	LTRIM(RTRIM(PARTI_ELA)),	
	LTRIM(RTRIM(PARTI_HIS)),	
	LTRIM(RTRIM(PARTI_WRTG)),	
	LTRIM(RTRIM(GRAD_PLAN)),	
	LTRIM(RTRIM(EXIT_DATE)),	
	LTRIM(RTRIM(EXIT_RESON))

 from #Raw_Casemis_A
 
 
 
 
 
 
 declare @errorstring varchar(max) = ''
 
 

/* Validation and Error Checks - CASEMIS A */

/*	V & E is divided into two phases:
	1: identify things that -must- stop the file from processing (these things can never go wrong)
	2: point out where the file deviates from spec (shouldn't be wrong, but often are)
*/

/* There should be 0 REPT_DATES that are blank in the originating CASEMIS file. */
IF	(select	COUNT(*) as NULL_REPT_DATE_CT 
	from	#Raw_Casemis_A 
	where	REPT_DATE is null) <> 0
BEGIN
	set @errorstring = 'CASEMIS-A (' + @a_path + '): REPT_DATE field contains blank values.'
	Raiserror(@errorstring, 15, 1)
	RETURN
END

/* We haven't imported SELPA data, so we don't have any good method for validating SELPA fields. */



/*	
	DIST_SERV: We use the most frequently-appearing DIST_SERV in the CDS to extract client ID. If we can't get a client ID, that's a good reason to error out.
*/

declare @casemis_client_CDS varchar(10) = (select top 1 DIST_SERV from #a_casemis_upload group by DIST_SERV order by COUNT(*) desc )

declare @casemis_client_id bigint = NULL

set @casemis_client_id = (select cc.client_id from CLIENTS_Client cc where cc.CLIENT_CDS = @casemis_client_CDS)

select @casemis_client_CDS, @casemis_client_id

IF @casemis_client_id IS NULL

BEGIN
	set @errorstring = 'CASEMIS-A (' + @a_path + '): DIST_SERV column''s primary value '+@casemis_client_CDS+' does not resolve to a valid Client ID.'
	RAISERROR(@errorstring, 15, 1)
	RETURN
END
 
 



/*************************/
/*                       */
/* CASEMIS-B FILE IMPORT */
/*                       */
/*************************/



/* Upload raw text information */
declare @b_blk_str nvarchar(4000) = 'bulk insert #raw_String_B from ''' + @B_path + ''' WITH ( FIELDTERMINATOR ='','', ROWTERMINATOR =''\n'' )';
print @B_blk_str
exec (@B_blk_str)




insert into #Raw_Casemis_B
(
	REPT_DATE,
	SELPA_CODE,
	STUDENT_ID,
	SSID,
	SERVICE,
	PROVIDER,
	LOCATION,
	FREQUENCY,
	DURATION
)
select 
	SUBSTRING(line_text, 	1	,	8	)	,
	SUBSTRING(line_text, 	9	,	4	)	,
	SUBSTRING(line_text, 	13	,	16	)	,
	SUBSTRING(line_text, 	29	,	10	)	,
	SUBSTRING(line_text, 	39	,	3	)	,
	SUBSTRING(line_text, 	42	,	3	)	,
	SUBSTRING(line_text, 	45	,	3	)	,
	SUBSTRING(line_text, 	48	,	2	)	,
	SUBSTRING(line_text, 	50	,	4	)	
from #Raw_String_B


update #Raw_Casemis_B 
set REPT_DATE = NULL 
where REPT_DATE = ''

insert into #B_casemis_upload
(
	line_id,
	REPT_DATE,
	SELPA_CODE,
	STUDENT_ID,
	SSID,
	SERVICE,
	PROVIDER,
	LOCATION,
	FREQUENCY,
	DURATION
)
select 
	line_id,
	RTRIM(ltrim(rept_date)),
	RTRIM(ltrim(SELPA_CODE)),
	RTRIM(ltrim(STUDENT_ID)),
	RTRIM(ltrim(SSID)),
	RTRIM(ltrim(SERVICE)),
	RTRIM(ltrim(PROVIDER)),
	RTRIM(ltrim(LOCATION)),
	RTRIM(ltrim(FREQUENCY)),
	RTRIM(ltrim(DURATION))
	
	
from #Raw_Casemis_B b


select * from #Raw_Casemis_B


/* Validation and Error Checks - CASEMIS B */

/*--------------------------------------------------------*/
/* Things that can stop a CASEMIS B file from processing: */
/*--------------------------------------------------------*/


/* There should be 0 REPT_DATES that are blank in the originating CASEMIS file. */
	IF	(select	COUNT(*) as NULL_REPT_DATE_CT 
		from	#Raw_Casemis_B 
		where	REPT_DATE is null) <> 0
	BEGIN
		set @errorstring = 'CASEMIS-B (' + @B_path + '): REPT_DATE field contains blank values.'
		Raiserror(@errorstring, 15, 1)
		RETURN
	END
	
/* REPT_DATE values in B-file shouldn't differ from ones in A-file. */
	IF	(select	COUNT(*) as NULL_REPT_DATE_CT 
		from	#Raw_Casemis_B b
			left outer join #Raw_Casemis_A a on a.REPT_DATE = b.REPT_DATE
		where	a.REPT_DATE is null) <> 0
	BEGIN
		set @errorstring = 'CASEMIS-B (' + @B_path + '): REPT_DATE field contains more than one date value.'
		Raiserror(@errorstring, 15, 1)
		RETURN
	END

/* Orphan records - If a B-file STUDENT_ID or SSID is not present in the A-file */
	--IF (select COUNT(*) as NUM_B_ORPHANS from #B_casemis_upload b left outer join #a_casemis_upload a on (b.SSID = a.SSID or b.STUDENT_ID = a.STUDENT_ID) where a.line_id is null) <> 0
	--BEGIN
	--	set @errorstring = 'CASEMIS-B (' + @B_path + '): Records in B-file could not be matched by SSID or STUDENT_ID to a student record in the A-file'
	--	RAISERROR(@errorstring, 10, 1) /* this is lower priority error */
	--	RETURN
	--END

/* Record inconsistency - SELPA code in B-file that isn't in A-file */

	IF (select COUNT(*) as B_SELPA_SINGLETON from #B_casemis_upload b left outer join #a_casemis_upload a on b.SELPA_CODE = a.SELPA_CODE where a.line_id is null) <> 0
	BEGIN
		set @errorstring = 'CASEMIS-B (' + @B_path + '): Records in B-file have SELPA codes not present in A-file'
		RAISERROR(@errorstring, 15, 1)
		RETURN
	END

/* Record integrity - More than one SELPA code in B-file */
	IF (select COUNT(distinct b.SELPA_CODE) as B_SELPA_COUNT from #B_casemis_upload b left outer join #a_casemis_upload a on b.SELPA_CODE = a.SELPA_CODE group by b.SELPA_CODE) <> 1
	BEGIN
		set @errorstring = 'CASEMIS-B (' + @B_path + '): More than one SELPA code present'
		RAISERROR(@errorstring, 15, 1)
		RETURN
	END



	
/****************************************************/	
/*													*/
/*				WARNING REPORTING					*/
/*	List warnings related to data in CASEMIS files 	*/
/*													*/
/*													*/
/****************************************************/
	
if @save_record = 0		
BEGIN	
	/*------------------------------------------------------*/
	/* Things that are flagged as warnings during CASEMIS-A */
	/*------------------------------------------------------*/	
	
	
	/* Validating the CDS7 for a specific schoolsite is pretty trivial; we check if it's in our database.
		
		...unless CASEMIS data specs are not followed and the SCH_CODE field is left blank by the district. Joy.
		
		If we have a non-blank value in the SCH_CODE field, we test it to see if it's in our records.

	 */

	select 'SCH_CODE CDS7 not in Spedcare database' as A_REASON,  #a_casemis_upload.* from #a_casemis_upload
		outer apply
		(
			select ss.* from CLIENTS_Client cc
			inner join SITES_Site ss on ss.SITE_CLIENT_ID = cc.CLIENT_ID and ss.SITE_CDS = SCH_CODE
			where cc.CLIENT_CDS in (DIST_RESI, DIST_SERV)
		) q
		
		where #a_casemis_upload.SCH_CODE <> '' and q.SITE_ID is null
	UNION

	/* Same deal with SCH_TYPE. Check to make sure the nonblanks match with the official format. */

	select 'SCH_TYPE does not meet format requirements' as A_REASON, * from #a_casemis_upload
	where 
		SCH_TYPE not like'[0-9][0-9]'
		and SCH_TYPE <> ''
	UNION

	/* Student IDs should be unique to a single row in the CASEMIS file. */

	select 'STUDENT_ID exists in more than one record' as A_REASON, A.* 
	from #a_casemis_upload A
		cross apply (
			select COUNT(*) as STUDID_DUPES from #a_casemis_upload A2 where A2.STUDENT_ID = A.STUDENT_ID
		) q
	where q.STUDID_DUPES > 1
	UNION

	select 'SSID exists in more than one record' as A_REASON, A.* 
	from #a_casemis_upload A
		cross apply (
			select COUNT(*) as STUDID_DUPES from #a_casemis_upload A2 where A2.SSID = A.SSID
		) q
	where q.STUDID_DUPES > 1
		and SSID <> ''
		
	UNION



	/* SSNs: Need to be blank or in [0-9], 9character. If the latter, then they need to be unique (hopefully) */

	select 'SSN out of format' as A_REASON, * from #a_casemis_upload
	where SSN not like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
			and SSN <> ''
	UNION		
	select 'SSN is duplicated by another record' as A_REASON, * from #a_casemis_upload where SSN in		
	(		
		select ssn from #a_casemis_upload where SSN  like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
		group by SSN
		having COUNT(*) >1
	)
	UNION


	/* Birthdate has to be a valid date value; since this is handled in type conversion, check for NULL which represents a blank field. */

	select 'BIRTHDATE is blank' as A_REASON, * from #a_casemis_upload where BIRTHDATE is null
	UNION
	/* Gender must be F or M */

	select 'GENDER not in (''F'',''M'')' as A_REASON, * from #a_casemis_upload where GENDER not in ('F','M')
	UNION
	/* Ethnicity must fall in specific code range. */

	select 'ETHNICITY outside specified range' as A_REASON, * from #a_casemis_upload where ETHNICITY not in ('500','501','900')
	UNION
	/* RACE 1-3: Validation would require data import into secondary table, so this is just a basic format check. */
	select 'RACE1/2/3 in nonstandard/non-numeric format' as A_REASON, * from #a_casemis_upload where
		RACE1 not like '[0-9][0-9][0-9]'
		and RACE2 not like '[0-9][0-9][0-9]'
		and RACE3 not like '[0-9][0-9][0-9]'
	UNION

	/* EL is apparently allowed to be blank, despite spec. */
	select 'EL needs to be Y or N' as A_REASON, * from #a_casemis_upload where EL not like '[YN]' and EL <> ''
	UNION

	/* NATIV_LANG requires external table */
	select 'NATIV_LANG in nonstandard/non-numeric format' as A_REASON, * from #a_casemis_upload
	where NATIV_LANG not like '[0-9][0-9]'
			and NATIV_LANG <> ''
	UNION

	/* EARLY_INT is apparently allowed to be blank, despite spec. */
	select 'EARLY_INT needs to be Y or N' as A_REASON, * from #a_casemis_upload where EARLY_INT not like '[YN]' and EARLY_INT <> ''
	UNION

	/* Can't really do any verification of the IN_RFRDATE. */

	/* IN_RFRBY requires external table */
	select 'IN_RFRBY is in nonstandard/non-numeric format' as A_REASON, * from #a_casemis_upload
	where IN_RFRBY not like '[0-9][0-9]'
			and IN_RFRBY <> ''
	UNION		

	/* IN_PRNTCSNT should throw error if it is blank. Buuuuuuut this field apparently is allowed to be null, so can't really verify this field. */


	/* INIT_EVAL is apparently 'allowed' to be blank. With other failed dependencies, the best option is to a simple comparison against birthdate */

	select 'INIT_EVAL occurs before birthdate' as A_REASON, * from #a_casemis_upload 
		where INIT_EVAL is not null
			and INIT_EVAL < BIRTHDATE
	UNION		

	/* EVLDLAY requires external table */
	select 'EVLDLAY in nonstandard/non-numeric format' as A_REASON , * from #a_casemis_upload
	where EVLDLAY not like '[0-9][0-9]'
			and EVLDLAY <> ''
	UNION

	/* TBDLAY requires external table */
	select 'TBDLAY in nonstandard/non-numeric format' as A_REASON , * from #a_casemis_upload
	where TBDLAY not like '[0-9][0-9]'
			and TBDLAY <> ''
	UNION
		
	/* PLAN_TYPE requires external table and 'shouldn't' be blank. */
	select 'PLAN_TYPE in nonstandard/non-numeric format' as A_REASON , * from #a_casemis_upload
	where PLAN_TYPE not like '[0-9][0-9]'
			and PLAN_TYPE <> ''	
	UNION

	/* MIGRANT is apparently allowed to be blank, despite spec. */

	select 'MIGRANT needs to be Y or N' as A_REASON ,* from #a_casemis_upload where MIGRANT not like '[YN]' and EL <> ''
	UNION

	/* RESID_STAT requires external table and 'shouldn't' be blank. */
	select 'RESID_STAT in nonstandard/non-numeric format' as A_REASON , * from #a_casemis_upload
	where RESID_STAT not like '[0-9][0-9]'
		and RESID_STAT <> ''	
	UNION

	/* ENTRY_DATE is apparently 'allowed' to be blank/NULL. */

	select 'ENTRY_DATE occurs before BIRTHDATE' as A_REASON, * from #a_casemis_upload 
		where 
		ENTRY_DATE is not null
			and ENTRY_DATE < BIRTHDATE
	UNION
	/* LAST_IEP is apparently 'allowed' to be blank/NULL. */

	select 'LAST_IEP occurs before BIRTHDATE' as A_REASON, * from #a_casemis_upload 
		where 
		LAST_IEP is not null
			and LAST_IEP < BIRTHDATE
	UNION
	/* LAST_EVAL is apparently 'allowed' to be blank/NULL. */

	select 'LAST_EVAL occurs before BIRTHDATE' as A_REASON, *   from #a_casemis_upload 
		where 
		LAST_EVAL is not null
			and LAST_EVAL < BIRTHDATE
	UNION

	/* DISABILIT1 requires external table and 'shouldn't' be blank. */
	select 'DISABILIT1 in nonstandard/non-numeric format' as A_REASON, * from #a_casemis_upload
	where DISABILIT1 not like '[0-9][0-9][0-9]'
		and DISABILIT1 <> ''	
	UNION

	/* DISABILIT2 requires external table and 'shouldn't' be blank. */
	select 'DISABILIT2 in nonstandard/non-numeric format' as A_REASON, *  from #a_casemis_upload
	where DISABILIT2 not like '[0-9][0-9][0-9]'
		and DISABILIT2 <> ''	
	UNION

	/* SOLE_LOW is allowed to be blank, Y, or N. */

	select 'SOLE_LOW needs to be Y or N' as A_REASON, * from #a_casemis_upload where SOLE_LOW not like '[YN]' and SOLE_LOW <> ''
	UNION

	/* INFANT_SET is allowed to be '21', '22', '23' or blank. */

	select 'INFANT_SET uses value outside available range' as A_REASON, * from #a_casemis_upload where INFANT_SET not in ('21','22','23') and INFANT_SET <> ''
	UNION
	/* FEDSET_INF requires external table and can be blank. */
	select 'FEDSET_INF in nonstandard/non-numeric format' as A_REASON, *  from #a_casemis_upload
	where FEDSET_INF not like '[0-9][0-9][0-9]'
		and FEDSET_INF <> ''	
	UNION

	/* FEDSET_PRS requires external table and can be blank. */
	select 'FEDSET_PRS in nonstandard/non-numeric format' as A_REASON, *  from #a_casemis_upload
	where FEDSET_PRS not like '[0-9][0-9][0-9]'
		and FEDSET_PRS <> ''	
	UNION
	/* FEDSET_SCH requires external table and can be blank. */
	select 'FEDSET_SCH in nonstandard/non-numeric format' as A_REASON, *  from #a_casemis_upload
	where FEDSET_SCH not like '[0-9][0-9][0-9]'
		and FEDSET_SCH <> ''	
	UNION

	/* IN_REGCLS requires external table and can't be blank. */
	select 'IN_REGCLS in nonstandard/nonstandard/non-numeric format' as A_REASON, *  from #a_casemis_upload
	where IN_REGCLS not like '[0-9][0-9][0-9]'
	UNION
	/*	While GRADE is a two-character numeric field, the coding 
		for grades is arbitrary and requires an external table to 
		parse. */
	select 'GRADE in nonstandard/non-numeric format' as A_REASON, *  from #a_casemis_upload
	where GRADE not like '[0-9][0-9]'
	UNION

	/* TRAN_REG1 'should' be blank. Client files assume otherwise, though? */

	select 'TRAN_REG1 falls outside value range' as A_REASON, * from #a_casemis_upload where TRAN_REG1 not in ('10','20','')
	UNION

	/* TRAN_REG2 through TRAN_REG7 are allowed to be blank. */

	select 'TRAN_REG2 falls outside value range' as A_REASON, *  from #a_casemis_upload where TRAN_REG2 not in ('10','20','')
	UNION
	select 'TRAN_REG3 falls outside value range' as A_REASON, *  from #a_casemis_upload where TRAN_REG3 not in ('10','20','')
	UNION
	select 'TRAN_REG4 falls outside value range' as A_REASON, *  from #a_casemis_upload where TRAN_REG4 not in ('10','20','')
	UNION
	select 'TRAN_REG5 falls outside value range' as A_REASON, *  from #a_casemis_upload where TRAN_REG5 not in ('10','20','')
	UNION
	select 'TRAN_REG6 falls outside value range' as A_REASON, *  from #a_casemis_upload where TRAN_REG6 not in ('10','20','')
	UNION
	select 'TRAN_REG7 falls outside value range' as A_REASON, *  from #a_casemis_upload where TRAN_REG7 not in ('10','20','')
	UNION

	/* TRAN_REG8 has more values than 1-7 */
	select 'TRAN_REG8 falls outside value range' as A_REASON, *  from #a_casemis_upload where TRAN_REG8 not in ('10','20', '30','')
	UNION

	/* SPEC_TRANS is allowed to be Y or N. Blanks are not allowed in spec, but exist in file. */
	select 'SPEC_TRANS needs to be Y or N' as A_REASON, * from #a_casemis_upload where SPEC_TRANS not like '[YN]' and SPEC_TRANS <> ''
	UNION

	/* PARINPUT uses specific set of values. */
	select 'PARINPUT falls outside value range' as A_REASON, *  from #a_casemis_upload where PARINPUT not in ('10','20', '30')
	UNION


	/* The PARTI_* are all two-character numeric designators who shouldn't be blank. */
	/* Emphasis on shouldn't. Actual file appears to allow such. */

	select 'PARTI_CAH falls outside value range' as A_REASON, *  from #a_casemis_upload where PARTI_CAH not like '[0-9][0-9]' and PARTI_CAH <> ''
	UNION
	select 'PARTI_MATH falls outside value range' as A_REASON, *  from #a_casemis_upload where PARTI_MATH not like '[0-9][0-9]' and PARTI_MATH <> ''
	UNION
	select 'PARTI_SCI falls outside value range' as A_REASON, *  from #a_casemis_upload where PARTI_SCI not like '[0-9][0-9]' and PARTI_SCI <> ''
	UNION
	select 'PARTI_ELA falls outside value range' as A_REASON, *  from #a_casemis_upload where PARTI_ELA not like '[0-9][0-9]' and PARTI_ELA <> ''
	UNION
	select 'PARTI_HIS falls outside value range' as A_REASON, *  from #a_casemis_upload where PARTI_HIS not like '[0-9][0-9]' and PARTI_HIS <> ''
	UNION
	select 'PARTI_WRTG falls outside value range' as A_REASON, *  from #a_casemis_upload where PARTI_WRTG not like '[0-9][0-9]' and PARTI_WRTG <> ''
	UNION

	/* GRAD_PLAN uses specific set of values. */
	select 'GRAD_PLAN falls outside value range' as A_REASON, *  from #a_casemis_upload where GRAD_PLAN not in ('10','20', '')
	UNION

	/* EXIT_DATE: A student may not have left the special ed program, so EXIT_DATE may be blank. If it does exist, it has to be after ENTRY_DATE */
	select 'EXIT_DATE occurs before ENTRY_DATE' as A_REASON, * FROM #a_casemis_upload 
	where (ENTRY_DATE is not null and EXIT_DATE is not null and EXIT_DATE < ENTRY_DATE)
	UNION

	/* EXIT_RESON is defined in external table; spec allows blanks. */
	select 'EXIT_RESON falls outside value range' as A_REASON, *  from #a_casemis_upload where EXIT_RESON not like '[0-9][0-9]' and EXIT_RESON <> ''

	order by line_id

	set @a_errorcount = @@ROWCOUNT	
		

	/*------------------------------------------------------*/
	/* Things that are flagged as warnings during CASEMIS-B */
	/*------------------------------------------------------*/

	select 'STUDENT_ID field has to have a value' as B_REASON,  #B_casemis_upload.* from #B_casemis_upload where #B_casemis_upload.STUDENT_ID = ''
	UNION
	select 'SSID field out of format bounds' as B_REASON,  #B_casemis_upload.* from #B_casemis_upload where #B_casemis_upload.SSID = '' or #B_casemis_upload.SSID like '_________'

	UNION
	select 'SERVICE code out of format bounds' as B_REASON,  #B_casemis_upload.* from #B_casemis_upload where SERVICE not like '[0-9][0-9][0-9]'

	UNION
	select 'PROVIDER code out of format bounds' as B_REASON,  #B_casemis_upload.* from #B_casemis_upload where PROVIDER not like '[0-9][0-9][0-9]'

	UNION
	select 'LOCATION code out of format bounds' as B_REASON,  #B_casemis_upload.* from #B_casemis_upload where LOCATION not like '[0-9][0-9][0-9]'

	UNION
	select 'FREQUENCY code out of format bounds' as B_REASON,  #B_casemis_upload.* from #B_casemis_upload where FREQUENCY not like '[0-9][0-9]'

	UNION
	select 'DURATION out of format bounds' as B_REASON,  #B_casemis_upload.* from #B_casemis_upload where DURATION <10
	order by line_id

	set @b_errorcount = @@ROWCOUNT




	/********************************************************/
	/*			We've set up all of our error checks.		*/
	/*			If we haven't exceptioned out, check		*/
	/*			error counts and test variable before		*/
	/*			pushing to tables in database.				*/
	/********************************************************/


	
END /* warning block */

if @save_record = 1
BEGIN
BEGIN TRANSACTION
	declare @client_id bigint = (select cc.client_id from (select top 1 DIST_SERV from #a_casemis_upload group by DIST_SERV order by COUNT(*) desc )a inner join CLIENTS_Client cc on cc.CLIENT_CDS = a.DIST_SERV)
	declare @casemis_file_id bigint
	
	
	
	
	/* Create core CASEMIS record */
	
	insert into CASEMIS_FILES
	values (@client_id, GETDATE())
	
	set @casemis_file_id = SCOPE_IDENTITY()
	
	
	/* Load in CASEMIS-A records, tied to core record */
	
	select @casemis_file_id as 'Current File #'
	
	insert into CASEMIS_FILES_A_STUDENTS
	
	(
		Casemis_File_ID ,
		Line_ID		,
		REPT_DATE	,
		SELPA_CODE	,
		SELPA_FROM	,
		DIST_SERV	,
		DIST_RESI	,
		SCH_CODE	,
		SCH_TYPE	,
		LAST_NAME	,
		FIRST_NAME	,
		STUDENT_ID	,
		SSID		,
		SSN			,
		BIRTHDATE	,
		GENDER		,
		ETHNICITY	,
		RACE1		,
		RACE2		,
		RACE3		,
		EL			,
		NATIV_LANG	,
		EARLY_INT	,
		IN_RFRDATE	,
		IN_RFRBY	,
		IN_PRNTCST	,
		IN_INTEVAL	,
		REFR_DATE	,
		REFR_BY		,
		PRNT_CSNT	,
		INIT_EVAL	,
		EVLDLAY		,
		TBDLAY		,
		PLAN_TYPE	,
		MIGRANT		,
		RESID_STAT	,
		ENTRY_DATE	,
		LAST_IEP	,
		LAST_EVAL	,
		DISABILIT1	,
		DISABILIT2	,
		SOLE_LOW	,
		INFANT_SET	,
		FEDSET_INF	,
		FEDSET_PRS	,
		FEDSET_SCH	,
		IN_REGCLS	,
		GRADE		,
		TRAN_REG1	,
		TRAN_REG2	,
		TRAN_REG3	,
		TRAN_REG4	,
		TRAN_REG5	,
		TRAN_REG6	,
		TRAN_REG7	,
		TRAN_REG8	,
		SPEC_TRANS	,
		PARINPUT	,
		PARTI_CAH	,
		PARTI_MATH	,
		PARTI_SCI	,
		PARTI_ELA	,
		PARTI_HIS	,
		PARTI_WRTG	,
		GRAD_PLAN	,
		EXIT_DATE	,
		EXIT_RESON	
	
	)
	
	select @casemis_file_id, 
		Line_ID		,
		REPT_DATE	,
		SELPA_CODE	,
		SELPA_FROM	,
		DIST_SERV	,
		DIST_RESI	,
		SCH_CODE	,
		SCH_TYPE	,
		LAST_NAME	,
		FIRST_NAME	,
		STUDENT_ID	,
		SSID		,
		SSN			,
		BIRTHDATE	,
		GENDER		,
		ETHNICITY	,
		RACE1		,
		RACE2		,
		RACE3		,
		EL			,
		NATIV_LANG	,
		EARLY_INT	,
		IN_RFRDATE	,
		IN_RFRBY	,
		IN_PRNTCST	,
		IN_INTEVAL	,
		REFR_DATE	,
		REFR_BY		,
		PRNT_CSNT	,
		INIT_EVAL	,
		EVLDLAY		,
		TBDLAY		,
		PLAN_TYPE	,
		MIGRANT		,
		RESID_STAT	,
		ENTRY_DATE	,
		LAST_IEP	,
		LAST_EVAL	,
		DISABILIT1	,
		DISABILIT2	,
		SOLE_LOW	,
		INFANT_SET	,
		FEDSET_INF	,
		FEDSET_PRS	,
		FEDSET_SCH	,
		IN_REGCLS	,
		GRADE		,
		TRAN_REG1	,
		TRAN_REG2	,
		TRAN_REG3	,
		TRAN_REG4	,
		TRAN_REG5	,
		TRAN_REG6	,
		TRAN_REG7	,
		TRAN_REG8	,
		SPEC_TRANS	,
		PARINPUT	,
		PARTI_CAH	,
		PARTI_MATH	,
		PARTI_SCI	,
		PARTI_ELA	,
		PARTI_HIS	,
		PARTI_WRTG	,
		GRAD_PLAN	,
		EXIT_DATE	,
		EXIT_RESON	
	 from #a_casemis_upload

	
	/* Load in CASEMIS-B records, linked to core and CASEMIS-A records */

	 
	 insert into CASEMIS_FILES_B_SERVICES
	 (
		Casemis_File_ID ,
		Casemis_Student_Line_ID ,
		Line_ID		,
		REPT_DATE	,
		SELPA_CODE	,
		STUDENT_ID	,
		SSID		,
		SERVICE		,
		PROVIDER	,
		LOCATION	,
		FREQUENCY	,
		DURATION	
	)
	
	select 
		@casemis_file_id ,
		cfas.Line_ID ,
		b.Line_ID		,
		b.REPT_DATE	,
		b.SELPA_CODE	,
		b.STUDENT_ID	,
		b.SSID		,
		b.SERVICE		,
		b.PROVIDER	,
		b.LOCATION	,
		b.FREQUENCY	,
		b.DURATION	
		
		from #B_casemis_upload b 
		inner join CASEMIS_FILES_A_STUDENTS cfas 
			on cfas.Casemis_File_ID = @casemis_file_id 
			and 
				(
					(cfas.SSID = b.SSID and b.SSID <> '') 
					or 
					(b.SSID = '' and b.STUDENT_ID = cfas.STUDENT_ID)
				)
		
	 
	 



COMMIT TRANSACTION
END

set @casemis_id = @casemis_file_id


/* Cleanup tables. Work done. */


drop table #Raw_String_A
drop table #raw_casemis_A
drop table #a_casemis_upload

drop table #Raw_String_B
drop table #raw_casemis_B
drop table #B_casemis_upload


END