/*###########################################################################*/
/*#         IMPORTANT NOTE REGARDING CLAIM AND SERVICE LEVEL DATA           #*/
/*#                                                                         #*/
/*# The use of the terms claim level and service level with respect to the  #*/
/*# X12 835 are not the save as SpEdCares service record and claim record   #*/
/*#                                                                         #*/
/*# - SpEdCare claim records are equivalent to 835 service level data       #*/         
/*# - SpEdCare service records are equivalent to 835 claim level data       #*/
/*###########################################################################*/

use SPEDMON 
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].CYBHI_POSTING') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
begin
  drop PROCEDURE dbo.CYBHI_POSTING
end
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE dbo.CYBHI_POSTING (
    @userID            bigint
  , @pathFileName      nvarchar(512)
  , @test              bit
  , @fileID            bigint output
)
AS
BEGIN

/***************************************************************************    
 * CYBHI_POSTING */    
/**    
 * Processes remittance advice in 835 data
 *
 * 
 ***************************************************************************/            

/* ---------- Sample use ----------

use SPEDMON
go

declare @fileID as bigint

exec dbo.CYBHI_POSTING 
      805
	, 'C:\spedmon\data\import-export\claims\835_5010_3213438_22094356_2025_06_05_T01_08_53.edi'
    , 1
	, @fileID  output

----------
*/

/*###########################################################################*/
/*#                            INIT                                         #*/
/*###########################################################################*/

set nocount on

exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Posting - Starting'

declare @tranOpen                        as bit = 0
declare @today                           as datetime = getdate()
declare @subElemSeperator                as char(1)
declare @numClaimLevelRows               as int = 0
declare @numClaimLevelRowsAreOurs        as int = 0
declare @numClaimLevelRowsAreNotOurs             as int = 0 
declare @allClaimsAreOurs                        as bit = 0
declare @msgStr                                  as varchar(512) = ''

/*---------------------------------------------------------------------------------------------------------*/

/*---------------------------------------------------------
  | Setup table vars
  ---------------------------------------------------------*/

declare @checks as table ( 
    file_id           bigint        not null
  , tx_control_number varchar(255)  not null
  , checkDate         date
  , checkNumber       varchar(50)
  , checkAmount       money       default(0)
  , clientID          bigint      default(-1)
  , totClp            money       default(0)
  , totPla            money       default(0)
  , balanced          bit         default(0)
  , npi               varchar(50) default('')
  , hasRemitAdviceForOtherSubmiters         bit default(0)
  , remitAdviceForOtherSubmitersCheckAmount money default(0)
  , postingID                               bigint  
unique clustered (file_id, tx_control_number)
)

/*---------------------------------------------------------------------------------------------------------*/

declare @claimLevel as table (
    file_id                       bigint       not null
  , tx_control_number             varchar(255) not null
  , line_number                   bigint       not null
  , ourSvcRecRefID                varchar(20)
  , ccn                           varchar(50)
  , payerStatusCode               tinyint
  , bic                           varchar(80)
  , amountSubmitted               money
  , amountPaid                    money
  , svcRecID                      bigint     
  --, numOfSl                      smallint     
  , ourTxStatusCode               smallint
  , ourSvcRecRefIDLen             int         not null default(0)
  , ourSvcRecRefIDFirst3          varchar(3)  not null default('')
  , ourSvcRecRefIDIsCorrectFormat bit         not null default(0)
  , idx                           int identity(1,1) 
unique clustered (file_id, tx_control_number, line_number)
)

/*---------------------------------------------------------------------------------------------------------*/

declare @serviceLevel as table (    
    file_id              bigint         not null
  , tx_control_number    varchar(255)   not null
  , line_number          bigint         not null
  , ourSvcRecRefID       varchar(20)
  , amountSubmitted      money
  , amountPaid           money  
  , dos                  date
  , procModComboPaid     varchar(50)
  , procCodePaid         varchar(10)
  , unitsPaid            smallint
  , line_item            tinyint
  , svcRecID             bigint
  , claimID              bigint
  , cybhiClaimTransmissionClaimID bigint
  , ourTxStatusCode               smallint    
  , idx                           int identity(1,1) 
unique clustered (file_id, tx_control_number, line_number, idx)
)

/*---------------------------------------------------------------------------------------------------------*/

declare @claimLevelAdustmentsRaw as table (
    file_id               bigint
  , tx_control_number     varchar(255)
  , line_number           bigint
  , ourSvcRecRefID        varchar(20)
  
  , adjustmentGroupCode   varchar(2)

  , adjustmentReasonCode1 varchar(5)
  , monetaryAmount1       money
  
  , adjustmentReasonCode2 varchar(5)
  , monetaryAmount2       money
  
  , adjustmentReasonCode3 varchar(5)
  , monetaryAmount3       money
  
  , adjustmentReasonCode4 varchar(5)
  , monetaryAmount4       money
  
  , adjustmentReasonCode5 varchar(5)
  , monetaryAmount5       money
  
  , adjustmentReasonCode6 varchar(5)
  , monetaryAmount6       money
)

/*---------------------------------------------------------------------------------------------------------*/

declare @serviceLevelAdustmentsRaw as table (
    file_id               bigint
  , tx_control_number     varchar(255)
  , line_number           bigint
  , ourSvcRecRefID        varchar(20)

  , adjustmentGroupCode   varchar(2)

  , adjustmentReasonCode1 varchar(5)
  , monetaryAmount1       money

  , adjustmentReasonCode2 varchar(5)
  , monetaryAmount2       money

  , adjustmentReasonCode3 varchar(5)
  , monetaryAmount3       money

  , adjustmentReasonCode4 varchar(5)
  , monetaryAmount4       money

  , adjustmentReasonCode5 varchar(5)
  , monetaryAmount5       money

  , adjustmentReasonCode6 varchar(5)
  , monetaryAmount6       money

  , line_item             tinyint
)

/*---------------------------------------------------------------------------------------------------------*/

declare @serviceLevelHealthCareRemarkCodes as table (
    file_id               bigint          not null
  , tx_control_number     varchar(255)    not null
  , line_number           bigint          not null
  , ourSvcRecRefID        varchar(20)

  , codeListQualifierCode varchar(3)
  , industryCode          varchar(30)

  , line_item             tinyint
  , svcRecID              bigint
  , claimID               bigint

  , idx                   int identity(1,1) not null

  unique clustered (file_id, tx_control_number, line_number, idx)
)

/*---------------------------------------------------------------------------------------------------------*/

declare @providerLevelAdustmentsRaw as table (

    file_id               bigint
  , tx_control_number     varchar(255)
  
  , adjustmentIdentifier1 varchar(100)
  , monetaryAmount1       money
  
  , adjustmentIdentifier2 varchar(100)
  , monetaryAmount2       money
  
  , adjustmentIdentifier3 varchar(100)
  , monetaryAmount3       money

  , adjustmentIdentifier4 varchar(100)
  , monetaryAmount4       money
  
  , adjustmentIdentifier5 varchar(100)
  , monetaryAmount5       money

  , adjustmentIdentifier6 varchar(100)
  , monetaryAmount6       money
)

/*---------------------------------------------------------------------------------------------------------*/

declare @providerLevelAdustments as table (

    file_id               bigint
  , tx_control_number     varchar(255) 
  , adjustmentReasonCode  varchar(2)
  , referenceID           varchar(50)
  , monetaryAmount        money
  , clientID              bigint
  , idx                   int identity(1,1) 

 unique clustered (file_id, tx_control_number, idx)
)

/*---------------------------------------------------------------------------------------------------------*/

declare @claimLevelAdustments as table (

    file_id               bigint        not null
  , tx_control_number     varchar(255)  not null
  , line_number           bigint        not null
  , ourSvcRecRefID        varchar(20)  
  , adjustmentGroupCode   varchar(2)
  , adjustmentReasonCode varchar(5)
  , monetaryAmount        money   
  , svcRecID              bigint
  , idx                   int identity(1,1) not null

 unique clustered (file_id, tx_control_number, idx)
)

/*---------------------------------------------------------------------------------------------------------*/

declare @serviceLevelAdustments as table (
    file_id               bigint         not null
  , tx_control_number     varchar(255)   not null
  , line_number           bigint         not null
  , ourSvcRecRefID        varchar(20)  
  , adjustmentGroupCode   varchar(2)
  , adjustmentReasonCode varchar(5)
  , monetaryAmount        money   
  , svcRecID              bigint
  , claimID               bigint
  , idx                   int identity(1,1) not null

 unique clustered (file_id, tx_control_number, idx)
)

/*---------------------------------------------------------------------------------------------------------*/

declare @cybhiClaimPostings as table (
	  claims835DataReceivedFileID  bigint       not null
    , tx_control_number            varchar(255) not null
	, id                           bigint       not null
unique clustered (claims835DataReceivedFileID, tx_control_number)
)

/*---------------------------------------------------------------------------------------------------------*/

declare @svcRecsClaimRecs as table (
    referenceID            varchar(20) not null
  , svcRecID               bigint      not null
  , ourProcModComboPaid    varchar(50) not null
  , claimID                bigint      not null
  , ourProcCodePaid        varchar(10) not null
  , transmissionClaimID    bigint      not null
  , claimLineNum           tinyint     not null  
unique clustered (referenceID, svcRecID, ourProcModComboPaid, claimID)
)

/*---------------------------------------------------------------------------------------------------------*/

declare @existingSraIDs as table (
    file_id                 bigint       not null
  , tx_control_number       varchar(255) not null
  , claimLevelIdx           int  
  , svcRecID                bigint
  , prevSraID               bigint
  , prevPostingID           bigint    
)

/*---------------------------------------------------------------------------------------------------------*/

/*###########################################################################*/
/*#                        INITIAL PARSING                                  #*/
/*###########################################################################*/

exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Posting - Save, Parse, and Pivot 835 File'

set @fileID = -1
exec dbo.Claims_835_Save_And_Process_File @pathFileName,2,@fileID output

if (@fileID = -1)
begin
  return
end

/*---------------------------------------------------------------------------------------------------------*/

exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Posting - Get subelement seperator from original x12 data'

set @subElemSeperator = ''

select top 1 
  @subElemSeperator = isnull(substring(t1.edi_file_text,105,1),'')
from dbo.Claims_835_Data_Received_File_Content as t1
where 
  (t1.id = @fileID)
option(recompile)

if (@subElemSeperator = '')
begin
  return
end

/*---------------------------------------------------------------------------------------------------------*/

/*###########################################################################*/
/*#                           WARRANT DATA                                  #*/
/*###########################################################################*/

set @tranOpen = 0

begin try

exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Posting - Extract Check Record Data from Parsed 835 Data and Associate Client Records'

insert into @checks (
    file_id
  , tx_control_number
  , checkDate
  , checkNumber
  , checkAmount
  , npi
  , clientID
)

select 
    t1.[file_id]
  , t1.tx_control_number
  , checkDate   = t1.[check_issue_or_eft_effective_date_(BPR_0200_BPR16)]
  , checkNumber = t1.[check_or_eft_trace_number_(TRN_0400_TRN02)]
  , checkAmount = t1.[monetary_amount_(BPR_0200_BPR02)] 
  , npi         = t1.[client_npi_(1000B_0800_N1_N107)]
  , clientID    = isnull(clc2.clientID,-1)
from dbo.Import_From_835_DS_001_Checks as t1

outer apply (
  select top 1 
    clientID = clc1.CLIENT_ID 
  from dbo.CLIENTS_Client as clc1 
  where       
	   (clc1.cybhiNPI = convert(nchar(10),t1.[client_npi_(1000B_0800_N1_N107)]))
	or (clc1.NPI      = convert(nchar(10),t1.[client_npi_(1000B_0800_N1_N107)]))
) as clc2

/* Uses index */

where (
      (t1.file_id = @fileID)
  and (t1.tx_control_number is not null)
  and (t1.id is not null)
)
option(recompile)

/*---------------------------------------------------------------------------------------------------------*/

/*###########################################################################*/
/*#                CLAIM LEVEL DATA (SpEdCare Service Records)              #*/
/*###########################################################################*/

exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Posting - Extract Claim Level Data from Parsed 835 Data'

insert into @claimLevel (
    file_id           
  , tx_control_number 
  , line_number       
  , ourSvcRecRefID    
  , ccn               
  , payerStatusCode   
  , bic               
  , amountSubmitted   
  , amountPaid         
)
select 
      clms.file_id
    , clms.tx_control_number
	, clms.line_number
	, ourSvcRecRefID     = clms.[claim_submitter_claim_tracking_id_(2100_0100_CLP_CLP01)]
    , ccn                = clms.[claim_control_number_(2100_0100_CLP_CLP07)]
    , payerStatusCode    = try_convert(tinyint,clms.[claim_status_code_(2100_0100_CLP_CLP02)])
    , bic                = clms.[patient_bic_(2100_0300_NM1_109)]
    , amountSubmitted    = clms.[claim_amount_submitted_(2100_0100_CLP_CLP03)]
	, amountPaid         = isnull(clms.[claim_amount_paid_(2100_0100_CLP_CLP05)],0)
    
from dbo.Import_From_835_DS_002_Claim_Level_Claim_Payment_Info_Patient_Name_Claim_Dates as clms
  
/* Uses index */

where (clms.file_id = @fileID)
option(recompile)

/*---------------------------------------------------------------------------------------------------------*/

/*###########################################################################*/
/*#           CHECK CLAIM SUBMITTER TRACKING IDS FORMAT                     #*/
/*###########################################################################*/

exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Posting - Check the claim submitter claim tracking ids for our correct format'

update @claimLevel set ourSvcRecRefIDLen = 0, ourSvcRecRefIDFirst3 = '' option(recompile)
update @claimLevel set ourSvcRecRefIDLen = len(ourSvcRecRefID) option(recompile)
update @claimLevel set ourSvcRecRefIDFirst3 = upper(trim(left(ourSvcRecRefID,3))) where (ourSvcRecRefIDLen >= 3) option(recompile)
update @claimLevel set ourSvcRecRefIDIsCorrectFormat = 1 where ((ourSvcRecRefIDLen = 20) and (ourSvcRecRefIDFirst3 = '9A7')) option(recompile)

/*---------------------------------------------------------------------------------------------------------*/

/*###########################################################################*/
/*#                     GET CLAIM LEVEL ROW COUNTS                          #*/
/*###########################################################################*/

exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Posting - Get claim level row counts'

set @numClaimLevelRows           = 0
set @numClaimLevelRowsAreOurs    = 0
set @numClaimLevelRowsAreNotOurs = 0

select @numClaimLevelRows           = count(cl.[file_id]) from @claimLevel as cl option(recompile)
select @numClaimLevelRowsAreOurs    = count(cl.[file_id]) from @claimLevel as cl where (cl.ourSvcRecRefIDIsCorrectFormat = 1) option(recompile)
select @numClaimLevelRowsAreNotOurs = count(cl.[file_id]) from @claimLevel as cl where (cl.ourSvcRecRefIDIsCorrectFormat = 0) option(recompile)

/*---------------------------------------------------------------------------------------------------------*/

/*###########################################################################*/
/*#                          VERIFY ROW COUNTS                              #*/
/*###########################################################################*/

exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Posting - Verifying claim level row counts'

set @msgStr = 'CYBHI Posting - Total number of claim level rows : ' + convert(varchar(50), @numClaimLevelRows)
exec dbo.PRINT_STATUS_MESSAGE @msgStr

set @msgStr = 'CYBHI Posting - Number of claim level rows that originated from us : ' + convert(varchar(50), @numClaimLevelRowsAreOurs)
exec dbo.PRINT_STATUS_MESSAGE @msgStr

set @msgStr = 'CYBHI Posting - Number of claim level rows that did not originate from us : ' + convert(varchar(50), @numClaimLevelRowsAreNotOurs)
exec dbo.PRINT_STATUS_MESSAGE @msgStr

/*###########################################################################*/
/*#               NO CLAIM LEVEL ROWS AT ALL - GET OUT                      #*/
/*###########################################################################*/

if (@numClaimLevelRows = 0)
begin
    exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Posting - **** ISSUE **** There are no claim lines in this file at all.  Need to investigate further.'
    return 
end

/*###########################################################################*/
/*#                NO CLAIM LEVEL ROWS FOR US - GET OUT                     #*/
/*###########################################################################*/

if (@numClaimLevelRowsAreOurs = 0)
begin
  exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Posting - **** ISSUE **** Nothing to post.  We cannot process this file.  There are no claim lines in this file that originated from us.'
  select cl.* from @claimLevel as cl
  return 
end  

/*###########################################################################*/
/*#                ALL CLAIM LEVEL ROWS ARE FOR US                          #*/
/*###########################################################################*/

if (@numClaimLevelRowsAreOurs = @numClaimLevelRows)
begin
  set @allClaimsAreOurs                = 1
  exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Posting - All claim in this file appear to have originated from us.'  
end
else

/*###########################################################################*/
/*#            ONLY SOME OF THE CLAIM LEVEL ROWS ARE FOR US                  #*/
/*###########################################################################*/

begin  
  set @allClaimsAreOurs = 0

  /* ====== For each check calculate total amount that was not from us ======*/
  ;
  with
  cte_p1
  as
  (
    select 
      cl.file_id
	, cl.tx_control_number
    , totAmtPaid = sum(cl.amountPaid)
    from @claimLevel as cl 
    where 
      (cl.ourSvcRecRefIDIsCorrectFormat = 0)
    group by 
        cl.[file_id]
	  , cl.tx_control_number
  )
  
  /* ====== Update each applicable check with this amount ======*/
  
  update chks 
  set 
      chks.hasRemitAdviceForOtherSubmiters = 1
    , chks.remitAdviceForOtherSubmitersCheckAmount = p1.totAmtPaid
  from cte_p1  as p1
  join @checks as chks on chks.[file_id] = p1.[file_id] and chks.tx_control_number = p1.tx_control_number
  option(recompile)

  exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Posting - This file has some claims that originated from us and some that originated from another vendor.'  
  
end

/*---------------------------------------------------------------------------------------------------------*/

/*###########################################################################*/
/*#                  CHECK FOR NON MATCHING CLIENTS                         #*/
/*###########################################################################*/

exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Posting - Check for non matching clients'

if exists (
  select top 1 
    chks.clientID 
  from @checks as chks
  where 
    (chks.clientID = -1)  
)
begin
  
  exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Posting - **** ISSUE **** Could not match up one or more NPIs in 835 to CYBHI Client NPI'
  
  select 
    chks.* 
  from @checks as chks 
  where (chks.clientID = -1)
  option(recompile)

  return
end

/*---------------------------------------------------------------------------------------------------------*/

/*###########################################################################*/
/*#                  CHECK FOR REDUDANT POSTINGS                            #*/
/*###########################################################################*/

exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Posting - Check for redundant postings'

if exists (
  select 
    ccp.id
  from @checks as chks
  join dbo.CYBHI_CLAIM_POSTINGS as ccp on  ccp.checkDate   = chks.checkDate
                                       and ccp.checkNumber = chks.checkNumber
                                       and ccp.checkAmount = chks.checkAmount									   
)
begin
  exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Posting - **** ISSUE **** Posting Data Has Already Been Saved For 1 or More of the Warrants In This File'
  return
end

/*---------------------------------------------------------------------------------------------------------*/

/*###########################################################################*/
/*#                SERVICE LEVEL DATA (SpEdCare Claim Records)              #*/
/*###########################################################################*/

exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Posting - Extract Service Level Data from Parsed 835 Data'

insert into @serviceLevel (
    file_id              
  , tx_control_number    
  , line_number
  , ourSvcRecRefID          
  , procModComboPaid
  , dos    
  , amountSubmitted     
  , amountPaid          
  , unitsPaid
  , line_item 
)
select 
    svcs.file_id
  , svcs.tx_control_number
  , svcs.line_number
  , svcs.[claim_submitter_claim_tracking_id_(2100_0100_CLP_CLP01)]
  , procModComboPaid = replace(trim(substring(svcs.[proc_mod_combo_paid_(2110_0700_SVC_SVC01)],(charindex(@subElemSeperator,svcs.[proc_mod_combo_paid_(2110_0700_SVC_SVC01)],0)+1),255)),@subElemSeperator,' ')
  , dos              = svcs.[service_date_(2110_0800_DTM_DTM02)]
  , amountSubmitted  = svcs.[amount_submitted_(2110_0700_SVC_SVC02)]
  , amountPaid       = svcs.[amount_paid_(2110_0700_SVC_SVC03)]	
  , unitsPaid        = svcs.[units_paid_(2110_0700_SVC_SVC05)]
  , line_item        = isnull(try_convert(tinyint,svcs.[line_item_control_number_(2110_1000)]),1)

from dbo.Import_From_835_DS_004_Service_Level_Payment_Info_Service_Dates as svcs
  
/* Uses index */

where 
  (svcs.file_id = @fileID)        

option(recompile)

/*---------------------------------------------------------------------------------------------------------*/
  				   
exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Posting - Extract procedure codes from parsed 835 data'

update @serviceLevel
  set procCodePaid = trim(left(procModComboPaid,(charindex(' ',procModComboPaid,0)))) /* Should be first */
option(recompile)

/*---------------------------------------------------------------------------------------------------------*/

/*###########################################################################*/
/*#                   PROVIDER (Client) LEVEL ADJUSTMENT DATA               #*/
/*###########################################################################*/

exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Posting - Extract Provider Level Adjustment Data from Parsed 835 Data'

insert into @providerLevelAdustmentsRaw (
    file_id
  , tx_control_number
  
  , adjustmentIdentifier1 
  , monetaryAmount1       
  
  , adjustmentIdentifier2 
  , monetaryAmount2       
  
  , adjustmentIdentifier3 
  , monetaryAmount3       

  , adjustmentIdentifier4 
  , monetaryAmount4       
  
  , adjustmentIdentifier5 
  , monetaryAmount5       

  , adjustmentIdentifier6 
  , monetaryAmount6   
)
select 
    pla.file_id
  , pla.tx_control_number
  
  , pla.[adjustment_identifier_1_(PLB_SUM_0100_PLB01)]
  , pla.[monetary_amount_1_(PLB_SUM_0100_PLB01)]
  
  , pla.[adjustment_identifier_2_(PLB_SUM_0100_PLB01)]
  , pla.[monetary_amount_2_(PLB_SUM_0100_PLB01)]
  
  , pla.[adjustment_identifier_3_(PLB_SUM_0100_PLB01)]
  , pla.[monetary_amount_3_(PLB_SUM_0100_PLB01)]
  
  , pla.[adjustment_identifier_4_(PLB_SUM_0100_PLB01)]
  , pla.[monetary_amount_4_(PLB_SUM_0100_PLB01)]
  
  , pla.[adjustment_identifier_5_(PLB_SUM_0100_PLB01)]
  , pla.[monetary_amount_5_(PLB_SUM_0100_PLB01)]
  
  , pla.[adjustment_identifier_6_(PLB_SUM_0100_PLB01)]
  , pla.[monetary_amount_6_(PLB_SUM_0100_PLB01)]
   
from dbo.Import_From_835_DS_007_Provider_Level_Adjustments as pla
where 
  (file_id = @fileID)
option(recompile)


/*---------------------------------------------------------------------------------------------------------*/

exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Posting - Split Out Provider Level Adjustment Data'

insert into @providerLevelAdustments (
    file_id
  , tx_control_number
  , adjustmentReasonCode
  , referenceID
  , monetaryAmount
)
select
    q1.file_id
  , q1.tx_control_number
  , q1.adjustmentReasonCode
  , q1.referenceID
  , q1.monetaryAmount
from
(

/* Adj 1 */

select 
    pla.file_id
  , pla.tx_control_number 

  , adjustmentReasonCode = substring ( pla.adjustmentIdentifier1
                                      , 0
									  , charindex ( @subElemSeperator
									               , pla.adjustmentIdentifier1
											   	   , 0))
  
  , referenceID = substring ( pla.adjustmentIdentifier1
                             , charindex ( @subElemSeperator
									       , pla.adjustmentIdentifier1
										   , 0) + 1, 255)

  , monetaryAmount = pla.monetaryAmount1
  
from @providerLevelAdustmentsRaw as pla

/* Adj 2 */

union all

select 
    pla.file_id
  , pla.tx_control_number 

  , adjustmentReasonCode = substring ( pla.adjustmentIdentifier2
                                      , 0
									  , charindex ( @subElemSeperator
									               , pla.adjustmentIdentifier2
											   	   , 0))
  
  , referenceID = substring ( pla.adjustmentIdentifier2
                             , charindex ( @subElemSeperator
									       , pla.adjustmentIdentifier2
										   , 0) + 1, 255)

  , monetaryAmount = pla.monetaryAmount2
  
from @providerLevelAdustmentsRaw as pla

/* Adj 3 */

union all

select 
    pla.file_id
  , pla.tx_control_number 

  , adjustmentReasonCode = substring ( pla.adjustmentIdentifier3
                                      , 0
									  , charindex ( @subElemSeperator
									               , pla.adjustmentIdentifier3
											   	   , 0))
  
  , referenceID = substring ( pla.adjustmentIdentifier3
                             , charindex ( @subElemSeperator
									       , pla.adjustmentIdentifier3
										   , 0) + 1, 255)

  , monetaryAmount = pla.monetaryAmount3
  
from @providerLevelAdustmentsRaw as pla

/* Adj 4 */

union all

select 
    pla.file_id
  , pla.tx_control_number 

  , adjustmentReasonCode = substring ( pla.adjustmentIdentifier4
                                      , 0
									  , charindex ( @subElemSeperator
									               , pla.adjustmentIdentifier4
											   	   , 0))
  
  , referenceID = substring ( pla.adjustmentIdentifier4
                             , charindex ( @subElemSeperator
									       , pla.adjustmentIdentifier4
										   , 0) + 1, 255)

  , monetaryAmount = pla.monetaryAmount4
  
from @providerLevelAdustmentsRaw as pla

/* Adj 5 */

union all

select 
    pla.file_id
  , pla.tx_control_number 

  , adjustmentReasonCode = substring ( pla.adjustmentIdentifier5
                                      , 0
									  , charindex ( @subElemSeperator
									               , pla.adjustmentIdentifier5
											   	   , 0))
  
  , referenceID = substring ( pla.adjustmentIdentifier5
                             , charindex ( @subElemSeperator
									       , pla.adjustmentIdentifier5
										   , 0) + 1, 255)

  , monetaryAmount = pla.monetaryAmount5
  
from @providerLevelAdustmentsRaw as pla

/* Adj 6 */

union all

select 
    pla.file_id
  , pla.tx_control_number 

  , adjustmentReasonCode = substring ( pla.adjustmentIdentifier6
                                      , 0
									  , charindex ( @subElemSeperator
									               , pla.adjustmentIdentifier6
											   	   , 0))
  
  , referenceID = substring ( pla.adjustmentIdentifier6
                             , charindex ( @subElemSeperator
									       , pla.adjustmentIdentifier6
										   , 0) + 1, 255)

  , monetaryAmount = pla.monetaryAmount6
  
from @providerLevelAdustmentsRaw as pla
) as q1
where 
  (q1.adjustmentReasonCode is not null)
option(recompile)

/*---------------------------------------------------------------------------------------------------------*/

/*###########################################################################*/
/*#              835 Internal Balance Check (Transaction Level)             #*/
/*###########################################################################*/

exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Posting - Perform 835 Balance Check'

/*    Sum of All Claim Payments (Sum of all CLP04) 
 *  - Sum of All Provider Adjustments (SUM of PLB04, 06, 08, 10, 12, and 14)s 
 *  = Total Payment Amount (BPR-02).
 */

;with
cte_p1
as
(
select 
    chks.file_id
  , chks.tx_control_number 
  , totClp = isnull(cl2.totClp,0)
  , totPla = isnull(pla2.totPla,0)
  , chks.checkAmount  
from @checks as chks

outer apply (
  select 
    totClp = sum(isnull(cl1.amountPaid,0))
  from @claimLevel as cl1
  where 
        ((cl1.file_id = chks.file_id)
    and (cl1.tx_control_number = chks.tx_control_number)
    and (cl1.line_number is not null))
  group by
    cl1.file_id
  , cl1.tx_control_number
) as cl2

outer apply (
  select 
    totPla = sum(isnull(pla1.monetaryAmount,0))
  from @providerLevelAdustments as pla1
  where 
        ((pla1.file_id = chks.file_id)
    and (pla1.tx_control_number = chks.tx_control_number)
    and (pla1.idx is not null))
  group by
    pla1.file_id
  , pla1.tx_control_number
) as pla2
)

update chks
set 
    chks.totClp = p1.totClp
  , chks.totPla = p1.totPla
from cte_p1  as p1
join @checks as chks on chks.file_id = p1.file_id and chks.tx_control_number = p1.tx_control_number
option(recompile)

update @checks set balanced = convert(bit,(iif(((totClp - totPla) = checkAmount),1,0)))
option(recompile)

if exists (select * from @checks where balanced = 0)
begin
  select * from @checks option(recompile)
  exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Posting - **** ISSUE **** 835 Balance Check Failed'
  return
end
else
begin
  exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Posting - 835 Balance Check Passed'
end

/*---------------------------------------------------------------------------------------------------------*/

/*###########################################################################*/
/*#       Claim Level Adjustment Data (Service Record) Pass 1 of 2          #*/
/*###########################################################################*/

exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Posting - Extract Claim Level Adjustment Data from Parsed 835 Data'

insert into @claimLevelAdustmentsRaw (
    file_id 
  , tx_control_number
  , line_number      
  , ourSvcRecRefID  
  , adjustmentGroupCode

  , adjustmentReasonCode1 
  , monetaryAmount1  
  
  , adjustmentReasonCode2
  , monetaryAmount2      
  
  , adjustmentReasonCode3
  , monetaryAmount3      
  
  , adjustmentReasonCode4
  , monetaryAmount4      
  
  , adjustmentReasonCode5 
  , monetaryAmount5  
  
  , adjustmentReasonCode6
  , monetaryAmount6      
)

select 
  
    cla.file_id              
  , cla.tx_control_number    
  , cla.line_number
  , ourSvcRecRefID      = cla.[claim_submitter_claim_tracking_id_(2100_0100_CLP_CLP01)]
  , adjustmentGroupCode = cla.[claim_adjustment_group_code_(2100_0200_CAS_CAS01)]
  
  , cla.[claim_adjustment_reason_code_1_(2100_0200_CAS_CAS02)]
  , cla.[monetary_amount_1_(2100_0200_CAS_CAS03)]

  , cla.[claim_adjustment_reason_code_2_(2100_0200_CAS_CAS05)]
  , cla.[monetary_amount_2_(2100_0200_CAS_CAS06)]

  , cla.[claim_adjustment_reason_code_3_(2100_0200_CAS_CAS08)]
  , cla.[monetary_amount_3_(2100_0200_CAS_CAS09)]

  , cla.[claim_adjustment_reason_code_4_(2100_0200_CAS_CAS11)]
  , cla.[monetary_amount_4_(2100_0200_CAS_CAS12)]

  , cla.[claim_adjustment_reason_code_5_(2100_0200_CAS_CAS14)]
  , cla.[monetary_amount_5_(2100_0200_CAS_CAS15)]

  , cla.[claim_adjustment_reason_code_6_(2100_0200_CAS_CAS17)]
  , cla.[monetary_amount_6_(2100_0200_CAS_CAS18)]

from dbo.Import_From_835_DS_003_Claim_Level_Adjustments as cla
where 
  (cla.file_id = @fileID)
option(recompile)

/*---------------------------------------------------------------------------------------------------------*/

/*###########################################################################*/
/*#         Service Level Adjustment Data (Claim Record) Pass 1 of 2        #*/
/*###########################################################################*/

exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Posting - Extract Service Level Adjustment Data from Parsed 835 Data'

insert into @serviceLevelAdustmentsRaw (
    file_id 
  , tx_control_number
  , line_number      
  , ourSvcRecRefID  
  , adjustmentGroupCode

  , adjustmentReasonCode1 
  , monetaryAmount1  
  
  , adjustmentReasonCode2
  , monetaryAmount2      
  
  , adjustmentReasonCode3
  , monetaryAmount3      
  
  , adjustmentReasonCode4
  , monetaryAmount4      
  
  , adjustmentReasonCode5 
  , monetaryAmount5  
  
  , adjustmentReasonCode6
  , monetaryAmount6      
  
  , line_item
)
select 
    sla.file_id              
  , sla.tx_control_number    
  , sla.line_number
  , sla.[claim_submitter_claim_tracking_id_(2100_0100_CLP_CLP01)]

  , sla.[claim_adjustment_group_code_(2110_0900_CAS_CAS01)]

  , sla.[claim_adjustment_reason_code_1_(2110_0900_CAS_CAS02)]
  , sla.[monetary_amount_1_(2110_0900_CAS_CAS03)]

  , sla.[claim_adjustment_reason_code_2_(2110_0900_CAS_CAS05)]
  , sla.[monetary_amount_2_(2110_0900_CAS_CAS06)]

  , sla.[claim_adjustment_reason_code_3_(2110_0900_CAS_CAS08)]
  , sla.[monetary_amount_3_(2110_0900_CAS_CAS09)]

  , sla.[claim_adjustment_reason_code_4_(2110_0900_CAS_CAS11)]
  , sla.[monetary_amount_4_(2110_0900_CAS_CAS12)]

  , sla.[claim_adjustment_reason_code_5_(2110_0900_CAS_CAS14)]
  , sla.[monetary_amount_5_(2110_0900_CAS_CAS15)]

  , sla.[claim_adjustment_reason_code_6_(2110_0900_CAS_CAS17)]
  , sla.[monetary_amount_6_(2110_0900_CAS_CAS18)]

  , line_item  = isnull(try_convert(tinyint,sla.[line_item_control_number_(2110_1000)]),1)

from dbo.Import_From_835_DS_005_Service_Level_Adjustments as sla
where 
  (sla.file_id = @fileID)
option(recompile)

/*---------------------------------------------------------------------------------------------------------*/

/*###########################################################################*/
/*#              Service Level Health Care Remark Codes                     #*/
/*###########################################################################*/

exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Posting - Extract Service Level Health Care Remark Data from Parsed 835 Data'

insert into @serviceLevelHealthCareRemarkCodes (
    file_id 
  , tx_control_number
  , line_number   
  , ourSvcRecRefID 
  , codeListQualifierCode
  , industryCode  
  , line_item  
)
select 
   slhcrc.file_id
 , slhcrc.tx_control_number
 , slhcrc.line_number
 , slhcrc.[claim_submitter_claim_tracking_id_(2100_0100_CLP_CLP01)]
 , slhcrc.[code_list_qualifier_code_(2110_1300_LQ_LQ01)]
 , slhcrc.[remark_code_(2110_1300_LQ_LQ02)] 
 , line_item  = isnull(try_convert(tinyint,slhcrc.[line_item_control_number_(2110_1000)]),1)
from dbo.Import_From_835_DS_006_Service_Level_Health_Care_Remark_Codes as slhcrc
where 
  (slhcrc.file_id = @fileID)
option(recompile)

/*---------------------------------------------------------------------------------------------------------*/

/*###########################################################################*/
/*#       Claim Level Adjustment Data (Service Record) Pass 2 of 2          #*/
/*###########################################################################*/

exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Posting - Split Out Claim Level Adjustment Data'

insert into @claimLevelAdustments (
    file_id
  , tx_control_number
  , line_number  
  , ourSvcRecRefID        
  , adjustmentGroupCode
  , adjustmentReasonCode
  , monetaryAmount
)
select
    q1.file_id
  , q1.tx_control_number
  , q1.line_number  
  , q1.ourSvcRecRefID
  , q1.adjustmentGroupCode
  , q1.adjustmentReasonCode
  , q1.monetaryAmount
from
(

/* Adj 1 */

select 
    cla.file_id
  , cla.tx_control_number 
  , cla.line_number  
  , cla.ourSvcRecRefID
  , cla.adjustmentGroupCode
  , adjustmentReasonCode = cla.adjustmentReasonCode1                               
  , monetaryAmount       = cla.monetaryAmount1
  
from @claimLevelAdustmentsRaw as cla

/* Adj 2 */

union all

select 
    cla.file_id
  , cla.tx_control_number 
  , cla.line_number  
  , cla.ourSvcRecRefID
  , cla.adjustmentGroupCode
  , adjustmentReasonCode = cla.adjustmentReasonCode2                               
  , monetaryAmount       = cla.monetaryAmount2
  
from @claimLevelAdustmentsRaw as cla

/* Adj 3 */

union all

select 
    cla.file_id
  , cla.tx_control_number 
  , cla.line_number  
  , cla.ourSvcRecRefID
  , cla.adjustmentGroupCode
  , adjustmentReasonCode = cla.adjustmentReasonCode3                              
  , monetaryAmount       = cla.monetaryAmount3
  
from @claimLevelAdustmentsRaw as cla

/* Adj 4 */

union all

select 
    cla.file_id
  , cla.tx_control_number 
  , cla.line_number  
  , cla.ourSvcRecRefID
  , cla.adjustmentGroupCode
  , adjustmentReasonCode = cla.adjustmentReasonCode4                               
  , monetaryAmount       = cla.monetaryAmount4
  
from @claimLevelAdustmentsRaw as cla

/* Adj 5 */

union all

select 
    cla.file_id
  , cla.tx_control_number 
  , cla.line_number  
  , cla.ourSvcRecRefID
  , cla.adjustmentGroupCode
  , adjustmentReasonCode = cla.adjustmentReasonCode5                               
  , monetaryAmount       = cla.monetaryAmount5
  
from @claimLevelAdustmentsRaw as cla

/* Adj 6 */

union all

select 
    cla.file_id
  , cla.tx_control_number 
  , cla.line_number  
  , cla.ourSvcRecRefID
  , cla.adjustmentGroupCode
  , adjustmentReasonCode = cla.adjustmentReasonCode6                               
  , monetaryAmount       = cla.monetaryAmount6
  
from @claimLevelAdustmentsRaw as cla

) as q1
where 
  (q1.adjustmentReasonCode is not null)
option(recompile)

/*---------------------------------------------------------------------------------------------------------*/

/*###########################################################################*/
/*#         Service Level Adjustment Data (Claim Record) Pass 2 of 2        #*/
/*###########################################################################*/

exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Posting - Split Out Service Level Adjustment Data'

insert into @serviceLevelAdustments (
    file_id
  , tx_control_number
  , line_number  
  , ourSvcRecRefID        
  , adjustmentGroupCode
  , adjustmentReasonCode
  , monetaryAmount
)
select
    q1.file_id
  , q1.tx_control_number
  , q1.line_number  
  , q1.ourSvcRecRefID
  , q1.adjustmentGroupCode
  , q1.adjustmentReasonCode
  , q1.monetaryAmount
from
(

/* Adj 1 */

select 
    cla.file_id
  , cla.tx_control_number 
  , cla.line_number  
  , cla.ourSvcRecRefID
  , cla.adjustmentGroupCode
  , adjustmentReasonCode = cla.adjustmentReasonCode1                               
  , monetaryAmount       = cla.monetaryAmount1
  
from @serviceLevelAdustmentsRaw as cla

/* Adj 2 */

union all

select 
    cla.file_id
  , cla.tx_control_number 
  , cla.line_number  
  , cla.ourSvcRecRefID
  , cla.adjustmentGroupCode
  , adjustmentReasonCode = cla.adjustmentReasonCode2                               
  , monetaryAmount       = cla.monetaryAmount2
  
from @serviceLevelAdustmentsRaw as cla

/* Adj 3 */

union all

select 
    cla.file_id
  , cla.tx_control_number 
  , cla.line_number  
  , cla.ourSvcRecRefID
  , cla.adjustmentGroupCode
  , adjustmentReasonCode = cla.adjustmentReasonCode3                              
  , monetaryAmount       = cla.monetaryAmount3
  
from @serviceLevelAdustmentsRaw as cla

/* Adj 4 */

union all

select 
    cla.file_id
  , cla.tx_control_number 
  , cla.line_number  
  , cla.ourSvcRecRefID
  , cla.adjustmentGroupCode
  , adjustmentReasonCode = cla.adjustmentReasonCode4                               
  , monetaryAmount       = cla.monetaryAmount4
  
from @serviceLevelAdustmentsRaw as cla

/* Adj 5 */

union all

select 
    cla.file_id
  , cla.tx_control_number 
  , cla.line_number  
  , cla.ourSvcRecRefID
  , cla.adjustmentGroupCode
  , adjustmentReasonCode = cla.adjustmentReasonCode5                               
  , monetaryAmount       = cla.monetaryAmount5
  
from @serviceLevelAdustmentsRaw as cla

/* Adj 6 */

union all

select 
    cla.file_id
  , cla.tx_control_number 
  , cla.line_number  
  , cla.ourSvcRecRefID
  , cla.adjustmentGroupCode
  , adjustmentReasonCode = cla.adjustmentReasonCode6                               
  , monetaryAmount       = cla.monetaryAmount6
  
from @serviceLevelAdustmentsRaw as cla

) as q1
where 
  (q1.adjustmentReasonCode is not null)
option(recompile)

/*###########################################################################*/
/*#      If only some of the claim lines originated from us                 #*/ 
/*#  Then we need to preset the svcRec ids and claimIds to a -1             #*/ 
/*###########################################################################*/

if (@allClaimsAreOurs = 0)
begin

  exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Posting - Setting dummy service record and claim ids for claim and service lines that did not originate from us'

  update cl
  set 
    cl.svcRecID = -1
  from @claimLevel as cl 
  where 
    (cl.ourSvcRecRefIDIsCorrectFormat = 0)
  option(recompile)

  update sl
  set 
      sl.svcRecID                      = -1
    , sl.claimID                       = -1
	, sl.cybhiClaimTransmissionClaimID = -1
  from @claimLevel    as cl 
  join @serviceLevel  as sl on sl.tx_control_number = cl.tx_control_number and sl.line_number = cl.line_number
  where 
    (cl.ourSvcRecRefIDIsCorrectFormat = 0)
  option(recompile)
end

/*---------------------------------------------------------------------------------------------------------*/

/*###########################################################################*/
/*#      Get SpEdCare svcRec, claimRec, and txClaimRecIDs                   #*/ 
/*#  Also get proc mod combo (we use this in lieu of a reliable line num)   #*/ 
/*###########################################################################*/

exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Posting - Finding SpEdCare TransmissionClaim Service and Claim Records By SvcRecRefID'

insert into @svcRecsClaimRecs (
    referenceID            
  , svcRecID               
  , ourProcModComboPaid                        
  , claimID 
  , ourProcCodePaid
  , transmissionClaimID               
  , claimLineNum  
)
select 
    ccth.referenceID
  , ccth.svcRecID
  , ourProcModComboPaid =  convert(varchar,(trim(trim(isnull(cp.PROCEDURE_CODE,N''))
						   + N' ' + trim(isnull(cp.PROCEDURE_MODIFIER_1, N''))
						   + N' ' + trim(isnull(cp.PROCEDURE_MODIFIER_2, N''))						   
						   + N' ' + trim(isnull(cp.PROCEDURE_MODIFIER_3, N''))						   
						   + N' ' + trim(isnull(cp.PROCEDURE_MODIFIER_4, N'')))),50)
  , ccth.claimID
  , ourProcCodePaid     = convert(varchar(10),trim(isnull(cp.PROCEDURE_CODE,N'')))
  , transmissionClaimID = ccth.id
  , clms.claimLineNum
  
from @checks                             as cks
join @claimLevel                         as cl   on cl.tx_control_number = cks.tx_control_number
join dbo.CYBHI_CLAIM_TRANSMISSION_CLAIMS as ccth on ccth.referenceID     = cl.ourSvcRecRefID
join dbo.CYBHI_CLAIMS                    as clms on clms.id              = ccth.claimID
join dbo.CLAIM_PROCEDURES                as cp   on cp.PROCEDURE_ID      = clms.procedureID
option(recompile)

/*###########################################################################*/
/*#      Associate SpEdCare service records with claim level data           #*/ 
/*###########################################################################*/

exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Posting - Finding SpEdCare Service Records and Associate With Claim and Service Level Data '

update cl
  set cl.svcRecID = srcr.svcRecID
from @checks                             as cks
join @claimLevel                         as cl   on cl.tx_control_number = cks.tx_control_number
join @svcRecsClaimRecs                   as srcr on srcr.referenceID     = cl.ourSvcRecRefID
option(recompile)

update sl
  set sl.svcRecID = cl.svcRecID
from @checks                             as cks
join @claimLevel                         as cl on cl.tx_control_number = cks.tx_control_number
join @serviceLevel                       as sl on sl.tx_control_number = cl.tx_control_number
                                               and sl.line_number = cl.line_number
option(recompile)

exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Posting - Checking SpEdCare Service Record Associations With Claim and Service Level Data '

if exists (select top 1 cl.* from @claimLevel as cl where (cl.svcRecID is null))
begin
  exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Posting - **** ISSUE **** SpEdCare Service Record Reassociation Failed'
  select What = '835 Claim Level', t1.* from @claimLevel       as t1 option(recompile)
  select What = 'SvcRecClaimRecs', t1.* from @svcRecsClaimRecs as t1 option(recompile)
  return
end
else
begin
  exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Posting - SpEdCare Service Record Reassociation Was Successful'
end

/*---------------------------------------------------------------------------------------------------------*/

/*###########################################################################*/
/*#      Associate SpEdCare claim records with service level data           #*/ 
/*###########################################################################*/

exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Posting - Finding SpEdCare Claim Records and Associate With Service Level Data'  

update sl
set
    sl.claimID                       = srcr.claimID
  , sl.cybhiClaimTransmissionClaimID = srcr.transmissionClaimID
from @serviceLevel     as sl
join @svcRecsClaimRecs as srcr on    ((srcr.referenceID = sl.ourSvcRecRefID)
                                 and (srcr.svcRecID     = sl.svcRecID)
                                 and (
								          (srcr.ourProcModComboPaid = sl.procModComboPaid)
								       or (srcr.ourProcCodePaid     = sl.procCodePaid)   /* In case full pmc is not returned.  CYBHI fee schedule currently has distinct procedure codes for each claim line.*/
								     )
								 and (srcr.claimID > 0))
option(recompile)

exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Posting - Checking SpEdCare Claim Record Associations With Service Level Data'  

if exists (select top 1 sl.* from @serviceLevel as sl where ((sl.svcRecId is null) or (sl.claimID is null)))
begin
  exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Posting - **** ISSUE **** SpEdCare Claim Record Reassociation Failed'
  select What = '835 Claim Level',   t1.* from @claimLevel       as t1 option(recompile)
  select What = '835 Service Level', t1.* from @serviceLevel     as t1 option(recompile)
  select What = 'SvcRecClaimRecs',   t1.* from @svcRecsClaimRecs as t1 option(recompile)

  return
end
else
begin
  exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Posting - SpEdCare Claim Record Reassociation Successful'
end

/*---------------------------------------------------------------------------------------------------------*/

/*###########################################################################*/
/*#      Associate claim level adjustments with SpEdCare service records    #*/ 
/*###########################################################################*/

exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Posting - Associate Claim Level Adjustments with SpEdCare Service Records'  

update cla
set 
  cla.svcRecID = cl.svcRecID
from @claimLevel              as cl
join @claimLevelAdustments    as  cla on  cla.file_id           = cl.file_id
                                      and cla.tx_control_number = cl.tx_control_number
                                      and cla.line_number       = cl.line_number
option (recompile)

/*---------------------------------------------------------------------------------------------------------*/

/*###########################################################################*/
/*#      Associate service level adjustments with SpEdCare claim records    #*/ 
/*###########################################################################*/

exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Posting - Associate Service Level Adjustments with SpEdCare Claim Records'  

update sla

set 
    sla.svcRecID = sl.svcRecID
  , sla.claimID  = sl.claimID

from @claimLevel as cl

join @serviceLevel as sl on  sl.file_id           = cl.file_id
                         and sl.tx_control_number = cl.tx_control_number
						 and sl.line_number       = cl.line_number

join @serviceLevelAdustments as sla on  sla.file_id           = sl.file_id
                                    and sla.tx_control_number = sl.tx_control_number
                                    and sla.line_number       = sl.line_number
option(recompile)							

/*---------------------------------------------------------------------------------------------------------*/

/*###########################################################################*/
/*# Associate service level health care remarks with SpEdCare claim records #*/ 
/*###########################################################################*/

exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Posting - Associate Service Level Health Care Remarks with SpEdCare Claim Records'  

update slhcrc

set 
    slhcrc.svcRecID = sl.svcRecID
  , slhcrc.claimID  = sl.claimID

from @claimLevel as cl

join @serviceLevel as sl on  sl.file_id           = cl.file_id
                         and sl.tx_control_number = cl.tx_control_number
				   	     and sl.line_number       = cl.line_number

join @serviceLevelHealthCareRemarkCodes as slhcrc on  slhcrc.file_id           = sl.file_id
                                                  and slhcrc.tx_control_number = sl.tx_control_number
                                                  and slhcrc.line_number       = sl.line_number
								                  and slhcrc.line_item         = sl.line_item
option(recompile)


/*---------------------------------------------------------------------------------------------------------*/

/*###########################################################################*/
/*#            Associate provider level adjustments with clients            #*/ 
/*###########################################################################*/

exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Posting - Associate Provider Level Adjustments with Clients'  

update pla
set
  pla.clientID = chks.clientID
from @checks                     as chks 
join @providerLevelAdustments    as pla on  pla.file_id           = chks.file_id
                                        and pla.tx_control_number = chks.tx_control_number
option(recompile)

/*---------------------------------------------------------------------------------------------------------*/

/*###########################################################################*/
/*#           Determine OUR txStatus code for SpEdCare claims               #*/ 
/*###########################################################################*/

exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Posting - Determine our txStatus Code'  

update @claimLevel
  set ourTxStatusCode = 3
where payerStatusCode in (1,2,3,19,20,21,22,23,25)
option(recompile)

update @claimLevel
  set ourTxStatusCode = 4
where payerStatusCode in (4)
option(recompile)

update sl
set 
  sl.ourTxStatusCode = cl.ourTxStatusCode
from @claimLevel   as cl
join @serviceLevel as  sl on sl.file_id     = cl.file_id
                   and sl.tx_control_number = cl.tx_control_number
				   and sl.svcRecID          = cl.svcRecID
option(recompile)

/*---------------------------------------------------------------------------------------------------------*/

/*###########################################################################*/
/*#              835 Internal Balance Check (Service Level)                 #*/
/*###########################################################################*/

exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Posting - Peforming service level balance check'  

/* Submitted Charges (SVC02) – Sum Of Adjustments (CAS-03, CAS-06, CAS-09, CAS-12, CAS-15, CAS-18) = Service Amount Paid (SVC03) */

declare @numSLNotBalanced as int = 0

;with
cte_p1
as
(
  select 
    sl.file_id
  , sl.tx_control_number 
  , sl.line_number
  , totAmtSub  = sum(sl.amountSubmitted)
  , totAmtPaid = sum(sl.amountPaid)
  from @serviceLevel as sl
group by 
    sl.file_id
  , sl.tx_control_number 
  , sl.line_number
)
,
cte_p2
as
(
  select 
      p1.file_id
	, p1.tx_control_number
	, p1.line_number
	, p1.totAmtSub
    , totAmtAdjust = isnull(sla2.totAmtAdjust,0)
	, p1.totAmtPaid
  from cte_p1 as p1
  outer apply (
    select 
      totAmtAdjust = sum(sla1.monetaryAmount)
    from @serviceLevelAdustments as sla1
    where 
            sla1.file_id           = p1.file_id
        and sla1.tx_control_number = p1.tx_control_number
  	    and sla1.line_number       = p1.line_number
  ) as sla2
)
,
cte_p3
as
(
  select 
      p2.*
    , balanced = iif (((p2.totAmtSub - p2.totAmtAdjust) = p2.totAmtPaid),1,0)
  from cte_p2 as p2
)
select 
  @numSLNotBalanced = count(p3.line_number)
from cte_p3 as p3
where 
  (p3.balanced = 0)
option(recompile)

if (@numSLNotBalanced > 0)
begin
  exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Posting - **** ISSUE **** Service level balance check failed'
  return 
end
else
begin
  exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Posting - Service level balance check passed'
end

/*###########################################################################*/
/*#                  Existing adjudication data check                       #*/ 
/*###########################################################################*/

/*---------------------------------------------------------------------------------------------------------*/

exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Posting - Check for existing adjudication records with same ccn, amount, and status code'

/* Note previously adjudicated warrant check (check date, number, amount) is peformed earlier in this routine */

insert into @existingSraIDs (
    file_id
  , tx_control_number
  , claimLevelIdx
  , svcRecID
  , prevSraID
  , prevPostingID
)
select 
      cl.file_id
	, cl.tx_control_number
	, claimLevelIdx = cl.idx
	, cl.svcRecID        
	, prevSraID      = ccpsra2.id
    , prevPostingID  = ccpsra2.postingID    
from @claimLevel as cl
cross apply (
  select 
      ccpsra.id
    , ccpsra.postingID    
  from dbo.CYBHI_CLAIM_POSTING_SERVICE_RECORD_ADJUDICATION as ccpsra
  where 
        ((ccpsra.ccn            = cl.ccn)) /* index */ 
    and (ccpsra.svcRecID        = cl.svcRecID)
	and (ccpsra.referenceID     = cl.ourSvcRecRefID)
	and (ccpsra.amountPaid      = cl.amountPaid)
    and (ccpsra.payerStatusCode = cl.payerStatusCode)
) as ccpsra2
option(recompile)

/*---------------------------------------------------------------------------------------------------------*/

/*###########################################################################*/
/*#                  Existing adjudication data warning                     #*/ 
/*###########################################################################*/

if exists (select top 1 file_id from @existingSraIDs)
begin
  exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Posting - **** WARNING **** There are existing adjudication records with same key data'
end

/*---------------------------------------------------------------------------------------------------------*/

/*###########################################################################*/
/*#            TEST MODE ONLY -  Output Data and Exit                       #*/
/*#   Note: This block of code should always be before we commit data       #*/
/*###########################################################################*/

if (@test = 1)
begin

  exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Posting - Output data'  

  select 
      what = 'WARNING - Previously adjudicated in a previous check'
	, chks.clientID
	, clientName = clc.CLIENT_NAME
	, clc.cybhiClientName
	, clc.cybhiNPI
	, thisCheckDate   = chks.checkDate
	, thisCheckNumber = chks.checkNumber
	, thisCheckAmount = chks.checkAmount
	, cl.ccn
    , cl.svcRecID
	, cl.ourSvcRecRefID
	, cl.amountPaid
	, cl.payerStatusCode
	, previouslyAdjudicatedInCheckNumber = t4.checkNumber
	, previouslyAdjudicatedInCheckDate   = t4.checkDate
	, previouslyAdjudicatedInCheckAmount = t4.checkAmount
	, previouslyAdjudicatedOn            = t4.created
    , previousPostingID                  = t3.postingID
	, previousCCN                        = t3.ccn
	, previousSvcRecID                   = t3.svcRecID
	, previousOurReferenceID             = t3.referenceID
	, previousAmountPaid                 = t3.amountPaid
	, previousPayerStatusCode            = t3.payerStatusCode
	, previousOurTxStatusCode            = t3.ourTxStatusCode
     
  from @claimLevel        as cl
  join @checks            as chks  on chks.file_id            = cl.file_id
                                   and chks.tx_control_number = cl.tx_control_number
  join dbo.CLIENTS_Client as clc   on clc.CLIENT_ID = chks.clientID
  
  join @existingSraIDs                                     as t2 on t2.claimLevelIdx = cl.idx
  join dbo.CYBHI_CLAIM_POSTING_SERVICE_RECORD_ADJUDICATION as t3 on t3.id            = t2.prevSraID
  join dbo.CYBHI_CLAIM_POSTINGS                            as t4 on t4.id            = t3.postingID
  option(recompile)
  
  select What = 'Svc Rec Claim Rec Assoc'   , t1.* from @svcRecsClaimRecs     as t1 

  select What = 'Checks'                    , t1.* from @checks               as t1
  select What = 'Claim Level'               , t2.* from @claimLevel           as t2
  select What = 'Claim Level Adjust'        , t3.* from @claimLevelAdustments as t3

  select What = 'Service Level'             , t4.* from @serviceLevel           as t4
  select What = 'Service Level Adjust'      , t5.* from @serviceLevelAdustments as t5

  select What = 'Service Level Remark Codes', t6.* from @serviceLevelHealthCareRemarkCodes as t6
  select What = 'Provider Level Adjust'     , t7.* from @providerLevelAdustments           as t7

  select 
      What              = 'Compare'     
    , theirDOS          = sl.dos
    , theirLineItem     = sl.line_item
    , theirProcModCombo = sl.procModComboPaid
    , theirAmountPaid   = sl.amountPaid
	, theirStatus       = cl.payerStatusCode
	
    , ourDOS            = cc.dos
    , ourLineItem       = cc.claimLineNum
    , ourProcModCombo   = dbo.RPT_PROC_MOD_COMBO (cp.PROCEDURE_CODE, cp.PROCEDURE_MODIFIER_1 , cp.PROCEDURE_MODIFIER_2, cp.PROCEDURE_MODIFIER_3, cp.PROCEDURE_MODIFIER_4)   
    , ourAmountClamed   = cc.amountClaimed
	, ourStatus         = cc.txStatusCode

  from @claimLevel          as cl 
  join @serviceLevel        as sl on sl.svcRecID     = cl.svcRecID
  join dbo.CYBHI_CLAIMS     as cc on cc.id           = sl.claimID
  join dbo.CLAIM_Procedures as cp on cp.PROCEDURE_ID = cc.procedureID
  option(recompile)
 
  exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Posting - In test mode exiting'  

  return
end


/*###########################################################################*/
/*#                      LIVE MODE ONLY                                     #*/
/*###########################################################################*/

/*---------------------------------------------------------------------------------------------------------*/

set @today = getdate()

begin transaction
set @tranOpen = 1

/*---------------------------------------------------------------------------------------------------------*/

/*###########################################################################*/
/*#                      Create Posting Records                             #*/
/*###########################################################################*/

exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Posting - Create Posting Records and Capture Posting IDs'

insert into dbo.CYBHI_CLAIM_POSTINGS (                                 
      clientID                     
	, claims835DataReceivedFileID
    , tx_control_number          
    , checkDate                  
    , checkNumber   
    , checkAmount   
	, created       
	, createdBy  
	, hasRemitAdviceForOtherSubmiters
	, remitAdviceForOtherSubmitersCheckAmount   
)

output 
  INSERTED.claims835DataReceivedFileID
, INSERTED.tx_control_number
, INSERTED.id

into @cybhiClaimPostings

select 
    chks.clientID               
  , claims835DataReceivedFileID = chks.file_id
  , chks.tx_control_number
  , chks.checkDate
  , chks.checkNumber
  , chks.checkAmount
  , created   = @today
  , createdBy = @userID
  , chks.hasRemitAdviceForOtherSubmiters
  , chks.remitAdviceForOtherSubmitersCheckAmount
from @checks as chks

/*---------------------------------------------------------------------------------------------------------*/

exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Posting - Update Check Data with Posting IDs'

update t2
set 
  t2.postingID = t1.id
from @cybhiClaimPostings as t1
join @checks             as t2 on t2.file_id = t1.claims835DataReceivedFileID
                               and t2.tx_control_number = t1.tx_control_number
option(recompile)

/*---------------------------------------------------------------------------------------------------------*/

/*###########################################################################*/
/*#       Create Previous Adjudication Exception Tracking Records           #*/
/*###########################################################################*/

exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Posting - Create Previous Adjudication Exception Tracking Records'

insert into dbo.CYBHI_CLAIM_POSTING_SERVICE_RECORD_PREVIOUS_ADJUDICATION_EXCEPTIONS (
    postingID
  , svcRecID
  , prevPostingID
  , prevSraID
  , exceptionCode
  , created
  , createdBy
  , active
)
select 
    postingID         = chks.postingID
  , svcRecID          = esra.svcRecID
  , esra.prevPostingID
  , esra.prevSraID          
  , exceptionCode = 1
  , created   = @today
  , createdBy = @userID
  , active    = 1
from @checks         as chks
join @existingSraIDs as esra on esra.file_id = chks.file_id and esra.tx_control_number = chks.tx_control_number
option(recompile)

/*---------------------------------------------------------------------------------------------------------*/

/*###########################################################################*/
/*#          Create Posting Service Record Adjudication Records             #*/
/*#                 (Related to Spedcare Service Records)                   #*/
/*###########################################################################*/

exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Posting - Create CYBHI Posting Service Record Adjudication Records'

insert into dbo.CYBHI_CLAIM_POSTING_SERVICE_RECORD_ADJUDICATION (      
      postingID
    , transaction_line_number
	, svcRecID      
    , referenceID   
	, ccn    
	, amountPaid 
    , payerStatusCode
	, ourTxStatusCode
	, created   
	, createdBy 
)
select 
    postingID               = chks.postingID
  , transaction_line_number = cl.line_number
  , cl.svcRecID
  , referenceID = cl.ourSvcRecRefID
  , cl.ccn
  , cl.amountPaid
  , cl.payerStatusCode
  , cl.ourTxStatusCode
  , created   = @today
  , createdBy = @userID

from @checks       as chks

join @claimLevel   as  cl on cl.file_id     = chks.file_id
                   and cl.tx_control_number = chks.tx_control_number
option(recompile)

/*---------------------------------------------------------------------------------------------------------*/

/*###########################################################################*/
/*#          Create Posting Claim Record Adjudication Records               #*/
/*#                 (Related to Spedcare Claim Records)                     #*/
/*###########################################################################*/

exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Posting - Create CYBHI Posting Claim Record Adjudication Records'

insert into dbo.CYBHI_CLAIM_POSTING_CLAIM_RECORD_ADJUDICATION (
      postingID                     
    , transaction_line_number
	, cybhiClaimTransmissionClaimID 
	, svcRecID 
	, claimID  
	, amountPaid  
	, ourTxStatusCode 
	, created      
	, createdBy    
)
select 
    postingID                     = chks.postingID
  , transaction_line_number       = cl.line_number
  , cybhiClaimTransmissionClaimID = sl.cybhiClaimTransmissionClaimID 
  , sl.svcRecID
  , sl.claimID
  , sl.amountPaid
  , cl.ourTxStatusCode
  , created   = @today
  , createdBy = @userID

from @checks       as chks

join @claimLevel   as  cl on cl.file_id     = chks.file_id
                   and cl.tx_control_number = chks.tx_control_number

join @serviceLevel as sl on  sl.file_id           = cl.file_id
                         and sl.tx_control_number = cl.tx_control_number
						 and sl.svcRecID          = cl.svcRecID


order by 
  chks.tx_control_number
, cl.line_number
option(recompile)

/*---------------------------------------------------------------------------------------------------------*/

/*###########################################################################*/
/*#          Create Posting Provider Level Adjustment Records               #*/
/*###########################################################################*/

exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Posting - Create Provider Level Adjustment Records'

insert into dbo.CYBHI_CLAIM_POSTING_PROVIDER_LEVEL_ADJUSTMENTS (      
      postingID   
	, adjustmentReasonCode 
    , referenceID 
    , monetaryAmount 
	, created 
	, createdBy  
)
select 
    chks.postingID
  , pla.adjustmentReasonCode 
  , pla.referenceID 
  , pla.monetaryAmount 
  , created   = @today
  , createdBy = @userID

from @checks                  as chks
join @providerLevelAdustments as pla on  pla.file_id           = chks.file_id
                                     and pla.tx_control_number = chks.tx_control_number
option(recompile)

/*---------------------------------------------------------------------------------------------------------*/

/*###########################################################################*/
/*#          Create Posting Service Record Adjustment Records               #*/
/*#                 (Related to Spedcare Service Records)                   #*/
/*###########################################################################*/

exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Posting - Create Service Record Adjustment Records'

insert into dbo.CYBHI_CLAIM_POSTING_SERVICE_RECORD_ADJUDICATION_ADJUSTMENTS (      
    postingID 
  , transaction_line_number
  , svcRecID 
  , adjustmentGroupCode
  , adjustmentReasonCode
  , monetaryAmount 
  , created
  , createdBy
)
select 
    postingID               = chks.postingID
  , transaction_line_number = cl.line_number
  , cl.svcRecID
  , cla.adjustmentGroupCode
  , cla.adjustmentReasonCode
  , cla.monetaryAmount 
  , created   = @today
  , createdBy = @userID

from @checks       as chks

join @claimLevel   as  cl on cl.file_id     = chks.file_id
                   and cl.tx_control_number = chks.tx_control_number

join @claimLevelAdustments as  cla on  cla.file_id           = cl.file_id
                                   and cla.tx_control_number = cl.tx_control_number
						           and cla.svcRecID          = cl.svcRecID
option(recompile)

/*---------------------------------------------------------------------------------------------------------*/

/*###########################################################################*/
/*#          Create Posting Claim Record Adjustment Records                 #*/
/*#                 (Related to Spedcare Claim Records)                     #*/
/*###########################################################################*/

exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Posting - Create Claim Record Adjustment Records'

insert into dbo.CYBHI_CLAIM_POSTING_CLAIM_RECORD_ADJUDICATION_ADJUSTMENTS (
      postingID 
    , transaction_line_number
	, cybhiClaimTransmissionClaimID 
	, svcRecID  
	, claimID   
	, adjustmentGroupCode 
    , adjustmentReasonCode
    , monetaryAmount  
	, created  
	, createdBy
)
select 
    postingID               = chks.postingID
  , transaction_line_number = cl.line_number
  , sl.cybhiClaimTransmissionClaimID 
  , sl.svcRecID
  , sl.claimID
  , sla.adjustmentGroupCode
  , sla.adjustmentReasonCode
  , sla.monetaryAmount 
  , created   = @today
  , createdBy = @userID

from @checks       as chks

join @claimLevel   as  cl on cl.file_id     = chks.file_id
                   and cl.tx_control_number = chks.tx_control_number

join @serviceLevel as sl on  sl.file_id           = cl.file_id
                         and sl.tx_control_number = cl.tx_control_number
                         and sl.line_number       = cl.line_number
				         and sl.svcRecID          = cl.svcRecID

join @serviceLevelAdustments as sla on  sla.file_id           = sl.file_id
                                    and sla.tx_control_number = sl.tx_control_number
						            and sla.svcRecID          = sl.svcRecID
								    and sla.claimID           = sl.claimID
option(recompile)

/*---------------------------------------------------------------------------------------------------------*/

/*###########################################################################*/
/*#       Create Posting Claim Record Health Care Remark Code Records       #*/
/*#                 (Related to Spedcare Claim Records)                     #*/
/*###########################################################################*/

exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Posting - Create Claim Record Health Care Remark Codes'

insert into dbo.CYBHI_CLAIM_POSTING_CLAIM_RECORD_HEALTH_CARE_REMARK_CODES (      
      postingID                     
    , transaction_line_number       
	, cybhiClaimTransmissionClaimID 
	, svcRecID                      
	, claimID                       
	, codeListQualifierCode  
    , industryCode       
	, created  
	, createdBy
)
select 
    postingID               = chks.postingID
  , transaction_line_number = cl.line_number
  , sl.cybhiClaimTransmissionClaimID 
  , sl.svcRecID
  , sl.claimID
  , slrc.codeListQualifierCode  
  , slrc.industryCode       
  , created   = @today
  , createdBy = @userID

from @checks       as chks

join @claimLevel   as  cl on cl.file_id     = chks.file_id
                   and cl.tx_control_number = chks.tx_control_number

join @serviceLevel as sl on  sl.file_id           = cl.file_id
                         and sl.tx_control_number = cl.tx_control_number
                         and sl.line_number       = cl.line_number
				         and sl.svcRecID          = cl.svcRecID

join @serviceLevelHealthCareRemarkCodes as slrc on slrc.file_id            = sl.file_id
                                                and slrc.tx_control_number = sl.tx_control_number
						                        and slrc.svcRecID          = sl.svcRecID
								                and slrc.claimID           = sl.claimID
option(recompile)

/*---------------------------------------------------------------------------------------------------------*/

/*###########################################################################*/
/*#               Update CYBHI Claim Record Status Codes                    #*/
/*###########################################################################*/

exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Posting - Update CYBHI Claims Status Codes'

update clms
set
    clms.txStatusCode   = sl.ourTxStatusCode
  , clms.lastModified   = @today
  , clms.lastModifiedBy = @userID
from @serviceLevel    as sl
join dbo.CYBHI_CLAIMS as clms on clms.id = sl.claimID

/*---------------------------------------------------------------------------------------------------------*/

/*###########################################################################*/
/*#                             Success                                     #*/
/*###########################################################################*/

commit transaction
set @tranOpen = 0
exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Posting - Data committed'

/*---------------------------------------------------------------------------------------------------------*/

/*###########################################################################*/
/*#                         Exception Thrown                                #*/
/*###########################################################################*/

end try
begin catch
  if (@tranOpen = 1) 
  begin
    print ERROR_MESSAGE ( )
    exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Posting - **** ISSUE **** Rolling back due to error'  
    rollback transaction
  end
end catch

/*---------------------------------------------------------------------------------------------------------*/

/*###########################################################################*/
/*#                             Done                                        #*/
/*###########################################################################*/

exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Posting - Done'
return

/*---------------------------------------------------------------------------------------------------------*/

END
GO
