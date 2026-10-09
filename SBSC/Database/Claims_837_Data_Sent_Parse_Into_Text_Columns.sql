USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Claims_837_Data_Sent_Parse_Into_Text_Columns') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.Claims_837_Data_Sent_Parse_Into_Text_Columns
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[Claims_837_Data_Sent_Parse_Into_Text_Columns] (
    @transmission_id bigint
  , @hdr_ftr_id      bigint
) 

RETURNS @recs TABLE (

  transmission_id bigint
, header_footer_id bigint
, generated_on    datetime
, claim_id        bigint

, file_name            varchar(255)
, submitter_name_entity_id_code nvarchar(max)
, submitter_name_entity_type_qualifier nvarchar(max) 
, submitter_name_last_or_organization_name nvarchar(max)
, submitter_name_id_code_qualifier nvarchar(max)        
, submitter_name_id_code nvarchar(max)

, submitter_edi_contact_info_contact_function_code nvarchar(max)
, submitter_edi_contact_info_contact_name  nvarchar(max)
, submitter_edi_contact_info_communication_number_qualifier_1  nvarchar(max)
, submitter_edi_contact_info_communication_number_1  nvarchar(max)

, receiver_name_entity_id_code nvarchar(max)
, receiver_name_entity_type_qualifier nvarchar(max) 
, receiver_name_last_or_organization_name nvarchar(max)
, receiver_name_id_code_qualifier nvarchar(max)        
, receiver_name_id_code nvarchar(max)

, billing_provider_specialty_info_provider_code nvarchar(max)
, billing_provider_specialty_info_reference_id_qualifier nvarchar(max)
, billing_provider_specialty_info_reference_id nvarchar(max)

, billing_provider_name_entity_identifier_code nvarchar(max)
, billing_provider_name_entity_type_qualifier nvarchar(max)
, billing_provider_name_first_or_organization_name nvarchar(max)
, billing_provider_name_id_code_qualifier nvarchar(max)
, billing_provider_name_id_code nvarchar(max)

, billing_provider_address_address_line_1 nvarchar(max)

, billing_provider_city_state_zip_city nvarchar(max)
, billing_provider_city_state_zip_state nvarchar(max)
, billing_provider_city_state_zip_zip nvarchar(max)

, billing_provider_tax_identification_reference_id_qualifier nvarchar(max)
, billing_provider_tax_identification_reference_id nvarchar(max)

, subscriber_info_payer_responsibility_sequence_number_code nvarchar(max)
, subscriber_info_individual_relationship_code nvarchar(max)
, subscriber_info_claim_file_indicator_code nvarchar(max)

, subscriber_name_entity_id_code nvarchar(max)
, subscriber_name_entity_type_qualifier nvarchar(max)
, subscriber_name_last_or_organization_name nvarchar(max)
, subscriber_name_first_name nvarchar(max)
, subscriber_name_middle_name nvarchar(max)
, subscriber_name_id_code_qualifier nvarchar(max)
, subscriber_name_id_code nvarchar(max)

, subscriber_address_address_line_1 nvarchar(max)

, subscriber_city_state_zip_city nvarchar(max)
, subscriber_city_state_zip_state nvarchar(max)
, subscriber_city_state_zip nvarchar(max)

, subscriber_demographic_info_dob_format_qualifier nvarchar(max)
, subscriber_demographic_info_dob nvarchar(max)
, subscriber_demographic_info_sex nvarchar(max)

, payer_name_entity_id_code nvarchar(max)
, payer_name_entity_type_qualifier nvarchar(max)
, payer_name_last_or_organization_name nvarchar(max)
, payer_name_id_code_qualifier nvarchar(max)
, payer_name_id_code	 nvarchar(max)

, claim_info_claim_submitter_claim_tracking_id varchar(255)
, claim_info_monetary_amount nvarchar(max)
, claim_info_health_care_service_location_info nvarchar(max)
, claim_info_provider_accepts_assignment_code nvarchar(max)
, claim_info_provider_assigned_benefits nvarchar(max)
, claim_info_provider_release_of_info_code nvarchar(max)
   
, statement_dates_date_time_qualifier nvarchar(max)
, statement_dates_date_time_period_format_qualifer nvarchar(max)
, statement_dates_date_time_period nvarchar(max)

, principal_diagnosis_health_care_code_info nvarchar(max)

, attending_provider_name_entity_id_code nvarchar(max)
, attending_provider_name_entity_type_qualifier nvarchar(max)
, attending_provider_name_last_or_organization_name nvarchar(max)
, attending_provider_name_first_name nvarchar(max)
, attending_provider_name_id_code_qualifier nvarchar(max)
, attending_provider_name_id_code nvarchar(max)

, service_line_number_assigned_number nvarchar(max)

, institutional_service_line_revenue_code nvarchar(max)
, institutional_service_line_medical_procedure_identifier nvarchar(max)
, institutional_service_line_monetary_amount nvarchar(max)
, institutional_service_line_unit_of_measure nvarchar(max)
, institutional_service_line_unit_count nvarchar(max)

, service_date_date_time_qualifier nvarchar(max)
, service_date_date_time_period_format_qualifier nvarchar(max)
, service_date_date_time_period nvarchar(max)

)

AS     
BEGIN

/*###########################################################################
  # Setup
  ###########################################################################*/    

declare @rankingWorkspace as table (
    idx      bigint
  , pos      bigint
  UNIQUE CLUSTERED (idx)
)

declare @claims as table (
  claim_id bigint

  UNIQUE CLUSTERED (claim_id)
)

declare @headerDataSegments as table (
     idx     bigint identity(1,1)
   , seg_pos bigint
   , header_segment nvarchar(max)
   UNIQUE CLUSTERED (idx)
)

declare @headerDataElements as table (
    idx           bigint identity(1,1)
  , seg_id        bigint
  , seg_pos       bigint
  , element_pos   bigint
  , header_element nvarchar(max)
    UNIQUE CLUSTERED (idx)
  , UNIQUE NONCLUSTERED (seg_pos, element_pos, idx)
)

declare @transactionData as table (
    id                    bigint 
  , header_footer_id      bigint
  , generated_on          datetime
  , prep_claim_row_id     bigint
  , claim_id              bigint
  , has_orp               bit
  , dist_id_chng          bit
  , pat_id_chng           bit
  , edi_transaction_segs  nvarchar(max)
)

declare @transactionDataHL as table (   
     id                   bigint
   , claim_id             bigint   
   , parent               bit
   , hl_segment_data      nvarchar(max)
   , hl_idx               bigint
   , h1_parent_idx        bigint
)

declare @transactionDataSegments as table (   
     idx                 bigint identity(1,1)
   , claim_id            bigint
   , seg_pos             bigint
   , transaction_segment nvarchar(max)
   UNIQUE CLUSTERED (claim_id, seg_pos, idx)
)

declare @transactionDataElements as table (
    idx           bigint identity(1,1)
  , claim_id      bigint
  , seg_id        bigint
  , seg_pos       bigint
  , element_pos   bigint
  , transaction_element nvarchar(max)
      
  UNIQUE CLUSTERED (claim_id, seg_pos, element_pos, idx)
)

declare @header_segs           as nvarchar(max)
declare @generated_on          as datetime
declare @file_name             as varchar(255)
declare @trans_prov_hier_segs  as nvarchar(max)
declare @header_footer_id      as bigint
declare @seg_term              as char(1)
declare @elem_sep              as char(1)

declare @submitter_name_entity_id_code as nvarchar(max)
declare @submitter_name_entity_type_qualifier as nvarchar(max)
declare @submitter_name_last_or_organization_name as nvarchar(max)
declare @submitter_name_id_code_qualifier as nvarchar(max)
declare @submitter_name_id_code as nvarchar(max)

declare @submitter_edi_contact_info_contact_function_code nvarchar(max)
declare @submitter_edi_contact_info_contact_name  nvarchar(max)
declare @submitter_edi_contact_info_communication_number_qualifier_1  nvarchar(max)
declare @submitter_edi_contact_info_communication_number_1  nvarchar(max)

declare @receiver_name_entity_id_code as nvarchar(max)
declare @receiver_name_entity_type_qualifier as nvarchar(max)
declare @receiver_name_last_or_organization_name as nvarchar(max)
declare @receiver_name_id_code_qualifier as nvarchar(max)
declare @receiver_name_id_code as nvarchar(max)


/*###########################################################################
  # Get header footer data and delimiters
  ###########################################################################*/    

select top 1

     @header_footer_id  = id
   , @seg_term          = edi_seg_term
   , @elem_sep          = edi_elem_sep 
   , @header_segs       = edi_header_segs 
   , @generated_on      = generated_on
   , @file_name         = file_name

from dbo.Claims_837_Data_Sent_Header_Footer as t1
where 
       (t1.transmission_id  = @transmission_id)
  and ((@hdr_ftr_id is null) or (t1.id = @hdr_ftr_id))
order by 
  t1.id desc

/*###########################################################################
  # Header segments 
  ###########################################################################*/    

/* Splitting header segments into seperate segments */

insert into @headerDataSegments
select     
    seg_pos = null
  , header_segment = t1.value
from STRING_SPLIT(@header_segs,@seg_term) as t1

/* Calculating header segment position values */

update @headerDataSegments set seg_pos = idx

/*###########################################################################
  # Header data elements 
  ###########################################################################*/    

insert into @headerDataElements
select 

    seg_id = t1.idx
  , seg_pos = t1.seg_pos
  , elem_pos = null
  , header_element = t2.value
from @headerDataSegments as t1
cross apply (
  select * from STRING_SPLIT(t1.header_segment,@elem_sep)
) as t2

delete @rankingWorkspace

insert into @rankingWorkspace
select 
  idx
, pos =  DENSE_RANK() over (partition by seg_id, seg_pos order by idx)
from @headerDataElements

update t1
  set t1.element_pos = t2.pos
from @headerDataElements as t1
join @rankingWorkspace as t2 on t2.idx = t1.idx

delete @rankingWorkspace

/*-----------------------------------------------------------------------------
 * Submitter Name
 * NM1*41*2*SCHOOL BUSINESS SERVICES OF CALI *****46*9A7
 * http://sbscitdev.help4schools.com/X12Docs/Documents/Standards/837/10200.htm
 *-----------------------------------------------------------------------------*/

select top 1 @submitter_name_entity_id_code = header_element 
from @headerDataElements
where seg_pos = 5 and element_pos = 2

select top 1 @submitter_name_entity_type_qualifier = header_element 
from @headerDataElements
where seg_pos = 5 and element_pos = 3

select top 1 @submitter_name_last_or_organization_name = header_element 
from @headerDataElements
where seg_pos = 5 and element_pos = 4

select top 1 @submitter_name_id_code_qualifier = header_element 
from @headerDataElements
where seg_pos = 5 and element_pos = 9

select top 1  @submitter_name_id_code = header_element 
from @headerDataElements
where seg_pos = 5 and element_pos = 10

/*-----------------------------------------------------------------------------
 * Submitter EDI Contact Information
 * PER*IC*JAIME VILORIA*TE*9163751707
 * http://sbscitdev.help4schools.com/X12Docs/Documents/Standards/837/10450.htm 
 *-----------------------------------------------------------------------------*/

select top 1  @submitter_edi_contact_info_contact_function_code = header_element 
from @headerDataElements
where seg_pos = 6 and element_pos = 2

select top 1  @submitter_edi_contact_info_contact_name = header_element 
from @headerDataElements
where seg_pos = 6 and element_pos = 3

select top 1  @submitter_edi_contact_info_communication_number_qualifier_1 = header_element 
from @headerDataElements
where seg_pos = 6 and element_pos = 4

select top 1  @submitter_edi_contact_info_communication_number_1  = header_element 
from @headerDataElements
where seg_pos = 6 and element_pos = 5

/*-----------------------------------------------------------------------------
 * Receiver Name
 * NM1*40*2*MEDI-CAL*****46*610442	
 * http://sbscitdev.help4schools.com/X12Docs/Documents/Standards/837/10500.htm
 *-----------------------------------------------------------------------------*/

select top 1 @receiver_name_entity_id_code = header_element 
from @headerDataElements
where seg_pos = 7 and element_pos = 2

select top 1 @receiver_name_entity_type_qualifier = header_element 
from @headerDataElements
where seg_pos = 7 and element_pos = 3

select top 1 @receiver_name_last_or_organization_name = header_element 
from @headerDataElements
where seg_pos = 7 and element_pos = 4

select top 1 @receiver_name_id_code_qualifier = header_element 
from @headerDataElements
where seg_pos = 7 and element_pos = 9

select top 1  @receiver_name_id_code = header_element 
from @headerDataElements
where seg_pos = 7 and element_pos = 10

/*###########################################################################
  # Transaction Segments Data
  ###########################################################################*/    

/* Get transaction segments */

insert into @transactionData
select 
  *
from dbo.Claims_837_Data_Sent_Transactions as t1
where (t1.header_footer_id = @header_footer_id)
order by t1.prep_claim_row_id 

/*-----------------------------------------------------------------------------
 * Segment 1 - Subscriber Hierarchival Level
 * HL*2*1070*22*0
 * http://sbscitdev.help4schools.com/X12Docs/Documents/Standards/837/40010.htm
 *-----------------------------------------------------------------------------*/

insert into @transactionDataHL
select 
    id
  , claim_id
  , parent = 1
  , hl_segment_data = left( edi_transaction_segs ,((charindex('~HL',edi_transaction_segs)))) 
  , hl_idx = null
  , h1_parent_idx = null
from @transactionData  
where (dist_id_chng = 1)

insert into @transactionDataHL
select 
   id
  ,claim_id
  ,parent = 0
  ,hl_segment_data = substring(edi_transaction_segs, charindex('~HL',edi_transaction_segs)+1, charindex('SBR',edi_transaction_segs)-charindex('~HL',edi_transaction_segs)-1)
  ,hl_idx = null 
  ,h1_parent_idx = null
from @transactionData  
where (dist_id_chng = 1)

insert into @transactionDataHL
select 
   id
  ,claim_id
  ,parent=0
  ,hl_segment_data = left( edi_transaction_segs ,((charindex('SBR',edi_transaction_segs))-1)) 
  , hl_idx = null
  , h1_parent_idx = null
from @transactionData
where (dist_id_chng is null)

update @transactionDataHL
set hl_idx = convert(bigint,substring(hl_segment_data,4,(charindex('*',hl_segment_data,4)-4)))

update @transactionDataHL
set h1_parent_idx = convert(bigint,(replace((replace(hl_segment_data,N'HL*' + convert(nvarchar,hl_idx) + N'*',N'')),N'*22*0~',N'')))
from @transactionDataHL 
where (parent = 0)

/* Removing parent hl data from segments that have it */

update t1
  set t1.edi_transaction_segs = replace (t1.edi_transaction_segs,t2.hl_segment_data,N'')
from @transactionData   as t1
join @transactionDataHL as t2 on t2.id = t1.id
where (t2.parent = 1)

/* Replacing hl data with parent data so we can easily extract provider data */


update t1
  set t1.edi_transaction_segs = replace(t1.edi_transaction_segs,t2.hl_segment_data,t3.hl_segment_data)
from @transactionData   as t1
join @transactionDataHL as t2 on t2.id = t1.id
join @transactionDataHL as t3 on t3.hl_idx = t2.h1_parent_idx and t3.parent = 1
where (t2.parent = 0)

/* Creating placeholder segments for those transactions that dont have an ORP */

update @transactionData
  set edi_transaction_segs = replace(edi_transaction_segs,'~LX','~NM1*********~LX')
where (has_orp = 0)

/*###########################################################################
  # Transaction Segments
  ###########################################################################*/    

/* Getting claim ids from transaction segments */

insert into @claims
select 
    t1.claim_id
from @transactionData as t1

/* Getting transaction segments and splitting them into seperate segments */

insert into @transactionDataSegments
select 
    t1.claim_id
  , seg_pos = null
  , transaction_segment = t2.value
from @transactionData as t1

cross apply (
  select * from STRING_SPLIT(t1.edi_transaction_segs,@seg_term)
) as t2

/* Calculating transaction segment position values */

delete @rankingWorkspace

insert into @rankingWorkspace
select 
  idx
, pos =  DENSE_RANK() over (partition by claim_id order by idx)
from @transactionDataSegments

update t1
  set t1.seg_pos = t2.pos
from @transactionDataSegments as t1
join @rankingWorkspace as t2 on t2.idx = t1.idx

delete @rankingWorkspace

/*###########################################################################
  # Transaction Elements
  ###########################################################################*/    

/* Getting transaction elements from split segments and spliting elements into separate elements */

insert into @transactionDataElements
select 
    t1.claim_id
  , seg_id = t1.idx
  , seg_pos = t1.seg_pos
  , elem_pos = null
  , transaction_element = t2.value
from @transactionDataSegments as t1
cross apply (
  select * from STRING_SPLIT(t1.transaction_segment,@elem_sep)
) as t2

delete @rankingWorkspace

insert into @rankingWorkspace
select 
  idx
, pos =  DENSE_RANK() over (partition by claim_id, seg_id, seg_pos order by idx)
from @transactionDataElements

update t1
  set t1.element_pos = t2.pos
from @transactionDataElements as t1
join @rankingWorkspace as t2 on t2.idx = t1.idx

delete @rankingWorkspace

/*###########################################################################
  # Extracting column data from elements and generating rows
  ###########################################################################*/    

insert into @recs
select 
      transmission_id  = @transmission_id
    , header_footer_id = @header_footer_id
	, generated_on     = @generated_on 	
	
	, cc.claim_id 
    , file_name                                = @file_name
	, submitter_name_entity_id_code            = @submitter_name_entity_id_code
    , submitter_name_entity_type_qualifier     = @submitter_name_entity_type_qualifier   
    , submitter_name_last_or_organization_name = @submitter_name_last_or_organization_name
    , submitter_name_id_code_qualifier         = @submitter_name_id_code_qualifier 
    , submitter_name_id_code                   = @submitter_name_id_code
    
	, submitter_edi_contact_info_contact_function_code            = @submitter_edi_contact_info_contact_function_code 
    , submitter_edi_contact_info_contact_name                     = @submitter_edi_contact_info_contact_name
    , submitter_edi_contact_info_communication_number_qualifier_1 = @submitter_edi_contact_info_communication_number_qualifier_1
    , submitter_edi_contact_info_communication_number_1           = @submitter_edi_contact_info_communication_number_1

    , receiver_name_entity_id_code            = @receiver_name_entity_id_code
    , receiver_name_entity_type_qualifier     = @receiver_name_entity_type_qualifier   
    , receiver_name_last_or_organization_name = @receiver_name_last_or_organization_name
    , receiver_name_id_code_qualifier         = @receiver_name_id_code_qualifier 
    , receiver_name_id_code                   = @receiver_name_id_code
    
	, t2_1.billing_provider_specialty_info_provider_code
    , t2_2.billing_provider_specialty_info_reference_id_qualifier
	, t2_3.billing_provider_specialty_info_reference_id

	, t3_2.billing_provider_name_entity_identifier_code
    , t3_3.billing_provider_name_entity_type_qualifier
    , t3_4.billing_provider_name_first_or_organization_name
    , t3_9.billing_provider_name_id_code_qualifier
    , t3_10.billing_provider_name_id_code
   
    , t4_2.billing_provider_address_address_line_1
   
    , t5_2.billing_provider_city_state_zip_city
    , t5_3.billing_provider_city_state_zip_state
    , t5_4.billing_provider_city_state_zip_zip

    , t6_2.billing_provider_tax_identification_reference_id_qualifier
    , t6_3.billing_provider_tax_identification_reference_id

   , t7_2.subscriber_info_payer_responsibility_sequence_number_code
   , t7_3.subscriber_info_individual_relationship_code
   , t7_10.subscriber_info_claim_file_indicator_code
        
   , t8_2.subscriber_name_entity_id_code
   , t8_3.subscriber_name_entity_type_qualifier
   , t8_4.subscriber_name_last_or_organization_name
   , t8_5.subscriber_name_first_name
   , t8_6.subscriber_name_middle_name
   , t8_9.subscriber_name_id_code_qualifier
   , t8_10.subscriber_name_id_code

   , t9_2.subscriber_address_address_line_1
   
   , t10_2.subscriber_city_state_zip_city
   , t10_3.subscriber_city_state_zip_state
   , t10_4.subscriber_city_state_zip_zip
   
   , t11_2.subscriber_demographic_info_dob_format_qualifier
   , t11_3.subscriber_demographic_info_dob
   , t11_4.subscriber_demographic_info_sex
   
   , t12_2.payer_name_entity_id_code
   , t12_3.payer_name_entity_type_qualifier
   , t12_4.payer_name_last_or_organization_name
   
   , t12_9.payer_name_id_code_qualifier
   , t12_10.payer_name_id_code
   
   , t13_2.claim_info_claim_submitter_claim_tracking_id
   , t13_3.claim_info_monetary_amount
   , t13_6.claim_info_health_care_service_location_info
   , t13_8.claim_info_provider_accepts_assignment_code
   , t13_9.claim_info_provider_assigned_benefits
   , t13_10.claim_info_provider_release_of_info_code  
   
   , t14_2.statement_dates_date_time_qualifier
   , t14_3.statement_dates_date_time_period_format_qualifer
   , t14_4.statement_dates_date_time_period
   
   
   , t15_2.principal_diagnosis_health_care_code_info
   
   , t16_2.attending_provider_name_entity_id_code
   , t16_3.attending_provider_name_entity_type_qualifier
   , t16_4.attending_provider_name_last_or_organization_name
   , t16_5.attending_provider_name_first_name
   , t16_9.attending_provider_name_id_code_qualifier
   , t16_10.attending_provider_name_id_code

   , t17_2.service_line_number_assigned_number
   
   , t18_2.institutional_service_line_revenue_code
   , t18_3.institutional_service_line_medical_procedure_identifier
   , t18_4.institutional_service_line_monetary_amount
   , t18_5.institutional_service_line_unit_of_measure
   , t18_6.institutional_service_line_unit_count   

   , t19_2.service_date_date_time_qualifier
   , t19_3.service_date_date_time_period_format_qualifier
   , t19_4.service_date_date_time_period

from @claims as cc

/*-----------------------------------------------------------------------------
 * Segment 2 - Billing Provider Speciality Info (Client)
 * PRV*BI*PXC*261QS1000X
 * http://sbscitdev.help4schools.com/X12Docs/Documents/Standards/837/20030.htm
 *-----------------------------------------------------------------------------*/

cross apply (
  select top 1 billing_provider_specialty_info_provider_code = transaction_element 
  from @transactionDataElements 
  where claim_id = cc.claim_id and seg_pos = 2 and element_pos = 2
) as t2_1

cross apply (
  select top 1 billing_provider_specialty_info_reference_id_qualifier = transaction_element 
  from @transactionDataElements 
  where claim_id = cc.claim_id and seg_pos = 2 and element_pos = 3
) as t2_2

cross apply (
  select top 1 billing_provider_specialty_info_reference_id = transaction_element 
  from @transactionDataElements 
  where claim_id = cc.claim_id and seg_pos = 2 and element_pos = 4
) as t2_3

/*-----------------------------------------------------------------------------
 * Segment 3 - Billing Provider Name (Client)
 * NM1*85*2*ELK GROVE USD*****XX*1740338011
 * http://sbscitdev.help4schools.com/X12Docs/Documents/Standards/837/20150.htm
 *-----------------------------------------------------------------------------*/

cross apply (
  select top 1 billing_provider_name_entity_identifier_code = transaction_element 
  from @transactionDataElements 
  where claim_id = cc.claim_id and seg_pos = 3 and element_pos = 2
) as t3_2

cross apply (
  select top 1 billing_provider_name_entity_type_qualifier = transaction_element 
  from @transactionDataElements 
  where claim_id = cc.claim_id and seg_pos = 3 and element_pos = 3
) as t3_3

cross apply (
  select top 1 billing_provider_name_first_or_organization_name = transaction_element 
  from @transactionDataElements 
  where claim_id = cc.claim_id and seg_pos = 3 and element_pos = 4
) as t3_4

cross apply (
  select top 1 billing_provider_name_id_code_qualifier = transaction_element 
  from @transactionDataElements
  where claim_id = cc.claim_id and seg_pos = 3 and element_pos = 9
) as t3_9

cross apply (
  select top 1 billing_provider_name_id_code = transaction_element 
  from @transactionDataElements
  where claim_id = cc.claim_id and seg_pos = 3 and element_pos = 10
) as t3_10


/*-----------------------------------------------------------------------------
 * Segment 4 - Billing Provider Address (Client)
 * N3*9510 ELK GROVE-FLORIN ROAD
 * http://sbscitdev.help4schools.com/X12Docs/Documents/Standards/837/20250.htm 
 *-----------------------------------------------------------------------------*/

cross apply (
  select top 1 billing_provider_address_address_line_1 = transaction_element 
  from @transactionDataElements 
  where claim_id = cc.claim_id and seg_pos = 4 and element_pos = 2
) as t4_2

/*-----------------------------------------------------------------------------
 * Segment 5 - Billing Provider City, State, Zip (Client)
 * N4*ELK GROVE*CA*956241801
 * http://sbscitdev.help4schools.com/X12Docs/Documents/Standards/837/20300.htm
 *-----------------------------------------------------------------------------*/

cross apply (
  select top 1 billing_provider_city_state_zip_city = transaction_element 
  from @transactionDataElements 
  where claim_id = cc.claim_id and seg_pos = 5 and element_pos = 2
) as t5_2

cross apply (
  select top 1 billing_provider_city_state_zip_state = transaction_element 
  from @transactionDataElements 
  where claim_id = cc.claim_id and seg_pos = 5 and element_pos = 3
) as t5_3

cross apply (
  select top 1 billing_provider_city_state_zip_zip = transaction_element 
  from @transactionDataElements 
  where claim_id = cc.claim_id and seg_pos = 5 and element_pos = 4
) as t5_4

/*-----------------------------------------------------------------------------
 * Segment 6 - Billing Provider Tax Identification (Client)
 * REF*EI*946002501
 * http://sbscitdev.help4schools.com/X12Docs/Documents/Standards/837/20350.htm
 *-----------------------------------------------------------------------------*/

 cross apply (
  select top 1 billing_provider_tax_identification_reference_id_qualifier = transaction_element 
  from @transactionDataElements 
  where claim_id = cc.claim_id and seg_pos = 6 and element_pos = 2
) as t6_2

 cross apply (
  select top 1 billing_provider_tax_identification_reference_id = transaction_element 
  from @transactionDataElements 
  where claim_id = cc.claim_id and seg_pos = 6 and element_pos = 3
) as t6_3


/*-----------------------------------------------------------------------------
 * Segment 7 - Subscriber Information (Patient)
 * SBR*P*18*******MC
 * http://sbscitdev.help4schools.com/X12Docs/Documents/Standards/837/40050.htm
 *-----------------------------------------------------------------------------*/

cross apply (
  select top 1 subscriber_info_payer_responsibility_sequence_number_code = transaction_element 
  from @transactionDataElements 
  where claim_id = cc.claim_id and seg_pos = 7 and element_pos = 2
) as t7_2

cross apply (
  select top 1 subscriber_info_individual_relationship_code = transaction_element 
  from @transactionDataElements 
  where claim_id = cc.claim_id and seg_pos = 7 and element_pos = 3
) as t7_3

cross apply (
  select top 1 subscriber_info_claim_file_indicator_code = transaction_element 
  from @transactionDataElements 
  where claim_id = cc.claim_id and seg_pos = 7 and element_pos = 10
) as t7_10

/*-----------------------------------------------------------------------------
 * Segment 8 - Subscriber Name  (Patient)
 * NM1*IL*1*POTTER*ALLISON****MI*93018867D45335
 * http://sbscitdev.help4schools.com/X12Docs/Documents/Standards/837/40150.htm
 *-----------------------------------------------------------------------------*/

cross apply (
  select top 1 subscriber_name_entity_id_code = transaction_element 
  from @transactionDataElements 
  where claim_id = cc.claim_id and seg_pos = 8 and element_pos = 2
) as t8_2

cross apply (
  select top 1 subscriber_name_entity_type_qualifier = transaction_element 
  from @transactionDataElements 
  where claim_id = cc.claim_id and seg_pos = 8 and element_pos = 3
) as t8_3

cross apply (
  select top 1 subscriber_name_last_or_organization_name = transaction_element 
  from @transactionDataElements 
  where claim_id = cc.claim_id and seg_pos = 8 and element_pos = 4
) as t8_4

cross apply (
  select top 1 subscriber_name_first_name = transaction_element 
  from @transactionDataElements 
  where claim_id = cc.claim_id and seg_pos = 8 and element_pos = 5
) as t8_5

cross apply (
  select top 1 subscriber_name_middle_name = transaction_element 
  from @transactionDataElements 
  where claim_id = cc.claim_id and seg_pos = 8 and element_pos = 6
) as t8_6

cross apply (
  select top 1 subscriber_name_id_code_qualifier = transaction_element 
  from @transactionDataElements 
  where claim_id = cc.claim_id and seg_pos = 8 and element_pos = 9
) as t8_9

cross apply (
  select top 1 subscriber_name_id_code = transaction_element 
  from @transactionDataElements 
  where claim_id = cc.claim_id and seg_pos = 8 and element_pos = 10
) as t8_10

/*-----------------------------------------------------------------------------
 * Segment 9 - Subscriber Address (Client Address Actually)
 * N3*9510 ELK GROVE-FLORIN ROAD
 * http://sbscitdev.help4schools.com/X12Docs/Documents/Standards/837/40250.htm
 *-----------------------------------------------------------------------------*/

cross apply (
  select top 1 subscriber_address_address_line_1 = transaction_element 
  from @transactionDataElements 
  where claim_id = cc.claim_id and seg_pos = 9 and element_pos = 2
) as t9_2

/*-----------------------------------------------------------------------------
 * Segment 10 - Subscriber City, State, Zip (Client City,State,Zip Actually)
 * N4*ELK GROVE*CA*956241801
 * http://sbscitdev.help4schools.com/X12Docs/Documents/Standards/837/40300.htm
 *-----------------------------------------------------------------------------*/

cross apply (
  select top 1 subscriber_city_state_zip_city = transaction_element 
  from @transactionDataElements 
  where claim_id = cc.claim_id and seg_pos = 10 and element_pos = 2
) as t10_2

cross apply (
  select top 1 subscriber_city_state_zip_state = transaction_element 
  from @transactionDataElements 
  where claim_id = cc.claim_id and seg_pos = 10 and element_pos = 3
) as t10_3

cross apply (
  select top 1 subscriber_city_state_zip_zip = transaction_element 
  from @transactionDataElements 
  where claim_id = cc.claim_id and seg_pos = 10 and element_pos = 4
) as t10_4

/*-----------------------------------------------------------------------------
 * Segment 11 - Subscriber Demographic Info (Patient)
 * DMG*D8*20010508*F
 * http://sbscitdev.help4schools.com/X12Docs/Documents/Standards/837/40320.htm
 *-----------------------------------------------------------------------------*/

cross apply (
  select top 1 subscriber_demographic_info_dob_format_qualifier = transaction_element 
  from @transactionDataElements 
  where claim_id = cc.claim_id and seg_pos = 11 and element_pos = 2
) as t11_2

cross apply (
  select top 1 subscriber_demographic_info_dob = transaction_element 
  from @transactionDataElements 
  where claim_id = cc.claim_id and seg_pos = 11 and element_pos = 3
) as t11_3

cross apply (
  select top 1 subscriber_demographic_info_sex = transaction_element 
  from @transactionDataElements 
  where claim_id = cc.claim_id and seg_pos = 11 and element_pos = 4
) as t11_4

	
/*-----------------------------------------------------------------------------
 * Segment 12 - Payer Name (Medi-cal)
 * NM1*PR*2*MEDI-CAL OP*****XV*610442
 * http://sbscitdev.help4schools.com/X12Docs/Documents/Standards/837/60150.htm
 *-----------------------------------------------------------------------------*/

cross apply (
  select top 1 payer_name_entity_id_code = transaction_element 
  from @transactionDataElements 
  where claim_id = cc.claim_id and seg_pos = 12 and element_pos = 2
) as t12_2

cross apply (
  select top 1 payer_name_entity_type_qualifier = transaction_element 
  from @transactionDataElements 
  where claim_id = cc.claim_id and seg_pos = 12 and element_pos = 3
) as t12_3

cross apply (
  select top 1 payer_name_last_or_organization_name = transaction_element 
  from @transactionDataElements
  where claim_id = cc.claim_id and seg_pos = 12 and element_pos = 4
) as t12_4


cross apply (
  select top 1 payer_name_id_code_qualifier = transaction_element 
  from @transactionDataElements 
  where claim_id = cc.claim_id and seg_pos = 12 and element_pos = 9
) as t12_9

cross apply (
  select top 1 payer_name_id_code = transaction_element 
  from @transactionDataElements 
  where claim_id = cc.claim_id and seg_pos = 12 and element_pos = 10
) as t12_10

/*-----------------------------------------------------------------------------
 * Segment 13 - Claim Information (Claim)
 * CLM*032309599-09452671*37.08***89:A:1*Y*C*Y*Y
 * http://sbscitdev.help4schools.com/X12Docs/Documents/Standards/837/C1300.htm
 *-----------------------------------------------------------------------------*/

cross apply (
  select top 1 claim_info_claim_submitter_claim_tracking_id = convert(varchar(255),transaction_element)
  from @transactionDataElements 
  where claim_id = cc.claim_id and seg_pos = 13 and element_pos = 2
) as t13_2

cross apply (
  select top 1 claim_info_monetary_amount = transaction_element 
  from @transactionDataElements 
  where claim_id = cc.claim_id and seg_pos = 13 and element_pos = 3
) as t13_3

cross apply (
  select top 1 claim_info_health_care_service_location_info = transaction_element 
  from @transactionDataElements 
  where claim_id = cc.claim_id and seg_pos = 13 and element_pos = 6
) as t13_6

cross apply (
  select top 1 claim_info_provider_accepts_assignment_code = transaction_element 
  from @transactionDataElements 
  where claim_id = cc.claim_id and seg_pos = 13 and element_pos = 8
) as t13_8

cross apply (
  select top 1 claim_info_provider_assigned_benefits = transaction_element 
  from @transactionDataElements 
  where claim_id = cc.claim_id and seg_pos = 13 and element_pos = 9
) as t13_9

cross apply (
  select top 1 claim_info_provider_release_of_info_code = transaction_element 
  from @transactionDataElements 
  where claim_id = cc.claim_id and seg_pos = 13 and element_pos = 10
) as t13_10

/*-----------------------------------------------------------------------------
 * Segment 14 - Statement Dates (Claim)
 * DTP*434*RD8*20180817-20180817
 * http://sbscitdev.help4schools.com/X12Docs/Documents/Standards/837/C1360.htm
 *-----------------------------------------------------------------------------*/

cross apply (
  select top 1 statement_dates_date_time_qualifier = transaction_element 
  from @transactionDataElements 
  where claim_id = cc.claim_id and seg_pos = 14 and element_pos = 2
) as t14_2

cross apply (
  select top 1 statement_dates_date_time_period_format_qualifer = transaction_element 
  from @transactionDataElements 
  where claim_id = cc.claim_id and seg_pos = 14 and element_pos = 3
) as t14_3

cross apply (
  select top 1 statement_dates_date_time_period = transaction_element 
  from @transactionDataElements
  where claim_id = cc.claim_id and seg_pos = 14 and element_pos = 4
) as t14_4

/*-----------------------------------------------------------------------------
 * Segment 15 - Principle Diagnosis (Claim)
 * HI*ABK:G839
 * http://sbscitdev.help4schools.com/X12Docs/Documents/Standards/837/C2310.htm
 *-----------------------------------------------------------------------------*/

cross apply (
  select top 1 principal_diagnosis_health_care_code_info = transaction_element 
  from @transactionDataElements 
  where claim_id = cc.claim_id and seg_pos = 15 and element_pos = 2
) as t15_2

/*-----------------------------------------------------------------------------
 * Segment 16 - Attending Provider Name (ORP)
 * NM1*71*1*TARAS*HOWARD****XX*1366491474
 * http://sbscitdev.help4schools.com/X12Docs/Documents/Standards/837/C2500.htm
 *-----------------------------------------------------------------------------*/

cross apply (
  select top 1 attending_provider_name_entity_id_code = transaction_element 
  from @transactionDataElements 
  where claim_id = cc.claim_id and seg_pos = 16 and element_pos = 2
) as t16_2

cross apply (
  select top 1 attending_provider_name_entity_type_qualifier = transaction_element 
  from @transactionDataElements 
  where claim_id = cc.claim_id and seg_pos = 16 and element_pos = 3
) as t16_3

cross apply (
  select top 1 attending_provider_name_last_or_organization_name = transaction_element 
  from @transactionDataElements 
  where claim_id = cc.claim_id and seg_pos = 16 and element_pos = 4
) as t16_4

cross apply (
  select top 1 attending_provider_name_first_name = transaction_element 
  from @transactionDataElements 
  where claim_id = cc.claim_id and seg_pos = 16 and element_pos = 5
) as t16_5

cross apply (
  select top 1 attending_provider_name_id_code_qualifier = transaction_element 
  from @transactionDataElements 
  where claim_id = cc.claim_id and seg_pos = 16 and element_pos = 9
) as t16_9

cross apply (
  select top 1 attending_provider_name_id_code = transaction_element 
  from @transactionDataElements 
  where claim_id = cc.claim_id and seg_pos = 16 and element_pos = 10
) as t16_10

/*-----------------------------------------------------------------------------
 * Segment 17 - Service Line Number (Claim)
 * LX*1
 * http://sbscitdev.help4schools.com/X12Docs/Documents/Standards/837/P3650.htm
 *-----------------------------------------------------------------------------*/

cross apply (
  select top 1 service_line_number_assigned_number = transaction_element 
  from @transactionDataElements 
  where claim_id = cc.claim_id and seg_pos = 17 and element_pos = 2
) as t17_2


/*-----------------------------------------------------------------------------
 * Segment 18 - Institutional Service Line (Claim)
 * SV2*001*HC:T2003:TM*37.08*UN*2
 * http://sbscitdev.help4schools.com/X12Docs/Documents/Standards/837/P3750.htm
 *-----------------------------------------------------------------------------*/

cross apply (
  select top 1 institutional_service_line_revenue_code = transaction_element 
  from @transactionDataElements 
  where claim_id = cc.claim_id and seg_pos = 18 and element_pos = 2
) as t18_2

cross apply (
  select top 1 institutional_service_line_medical_procedure_identifier = transaction_element 
  from @transactionDataElements
  where claim_id = cc.claim_id and seg_pos = 18 and element_pos = 3
) as t18_3

cross apply (
  select top 1 institutional_service_line_monetary_amount = transaction_element 
  from @transactionDataElements
  where claim_id = cc.claim_id and seg_pos = 18 and element_pos = 4
) as t18_4

cross apply (
  select top 1 institutional_service_line_unit_of_measure = transaction_element 
  from @transactionDataElements
  where claim_id = cc.claim_id and seg_pos = 18 and element_pos = 5
) as t18_5

cross apply (
  select top 1 institutional_service_line_unit_count = transaction_element 
  from @transactionDataElements 
  where claim_id = cc.claim_id and seg_pos = 18 and element_pos = 6
) as t18_6

/*-----------------------------------------------------------------------------
 * Segment 19 - Service Date (Claim)
 * DTP*472*D8*20180817
 * http://sbscitdev.help4schools.com/X12Docs/Documents/Standards/837/P4550.htm
 *-----------------------------------------------------------------------------*/

cross apply (
  select top 1 service_date_date_time_qualifier = transaction_element 
  from @transactionDataElements 
  where claim_id = cc.claim_id and seg_pos = 19 and element_pos = 2
) as t19_2

cross apply (
  select top 1 service_date_date_time_period_format_qualifier = transaction_element 
  from @transactionDataElements 
  where claim_id = cc.claim_id and seg_pos = 19 and element_pos = 3
) as t19_3

cross apply (
  select top 1 service_date_date_time_period = transaction_element 
  from @transactionDataElements 
  where claim_id = cc.claim_id and seg_pos = 19 and element_pos = 4
) as t19_4





return
END
GO


/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[Claims_837_Data_Sent_Parse_Into_Text_Columns] TO [webuser]
GO