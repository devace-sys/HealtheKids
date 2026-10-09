;var MBA = (MBA || {});

/*#############################################################################################################################################################*/

/**
 * @namespace    MBA.PX12Common
 * @memberof     MBA
 * @summary      Static methods used on a screen 
 * @description  Static methods used on a screen
 */

MBA.X12Common = (function ()
{

'use strict';

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

const _fnConvertCCYYMMDDToDate = function (value) {	
	const _yearPart  = value.substring(0, 4);
	const _monthPart = value.substring(4, 6);
	const _dayPart   = value.substring(6, 8);
	const _yyyy_mm_dd = `${_yearPart}-${_monthPart}-${_dayPart}`;
	return new Date(_yyyy_mm_dd);
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

const _fnGenerateCodeSetMap_CodeSource507 = function () {

	let _codeSet = new Map();
	_codeSet.set('X0', 'Supplemental Messages');
	_codeSet.set('A0', 'Acknowledgement/Forwarded-The claim/encounter has been forwarded to another entity.');
	_codeSet.set('A1', 'Acknowledgement/Receipt-The claim/encounter has been received. This does not mean that the claim has been accepted for adjudication.');
	_codeSet.set('A2', 'Acknowledgement/Acceptance into adjudication system-The claim/encounter has been accepted into the adjudication system.');
	_codeSet.set('A3', 'Acknowledgement/Returned as unprocessable claim-The claim/encounter has been rejected and has not been entered into the adjudication system.');
	_codeSet.set('A4', 'Acknowledgement/Not Found-The claim/encounter can not be found in the adjudication system.');
	_codeSet.set('A5', 'Acknowledgement/Split Claim-The claim/encounter has been split upon acceptance into the adjudication system.');
	_codeSet.set('A6', 'Acknowledgement/Rejected for Missing Information - The claim/encounter is missing the information specified in the Status details and has been rejected.');
	_codeSet.set('A7', 'Acknowledgement/Rejected for Invalid Information - The claim/encounter has invalid information as specified in the Status details and has been rejected.');
	_codeSet.set('A8', 'Acknowledgement/Rejected for relational field in error.');
	_codeSet.set('DR01', 'Acknowledgement/Receipt - The claim/encounter has been received. This does not mean the claim has been accepted into the data reporting/processing system. Usage: Can only be used in the Data Reporting Acknowledgement Transaction.');
	_codeSet.set('DR02', 'Acknowledgement/Acceptance into the data reporting/processing system - The claim/encounter has been accepted into the data reporting/processing system. Usage: Can only be used in the Data Reporting Acknowledgment Transaction.');
	_codeSet.set('DR03', 'Acknowledgement/Returned as unprocessable claim - The claim/encounter has been rejected and has not been entered into the data reporting/processing system. Usage: Can only be used in the Data Reporting Acknowledgment Transaction.');
	_codeSet.set('DR04', 'Acknowledgement/Not Found - The claim/encounter can not be found in the data reporting/processing system. Usage: Can only be used in the Data Reporting Acknowledgment Transaction.');
	_codeSet.set('DR05', 'Acknowledgement/Rejected for Missing Information - The claim/encounter is missing the information specified in the Status details and has been rejected. Usage: Can only be used in the Data Reporting Acknowledgment Transaction.');
	_codeSet.set('DR06', 'Acknowledgment/Rejected for invalid information - The claim/encounter has invalid information as specified in the Status details and has been rejected. Usage: Can only be used in the Data Reporting Acknowledgment Transaction.');
	_codeSet.set('DR07', 'Acknowledgement/Rejected for relational field in error. Usage: Can only be used in the Data Reporting Acknowledgment Transaction.');
	_codeSet.set('DR08', 'Acknowledgement/Warning - The claim/encounter has been accepted into the data reporting/processing system but has received a warning as specified in the Status details. Usage: Can only be used in the Data Reporting Acknowledgment Transaction.');
	_codeSet.set('P0', 'Pending:  Adjudication/Details-This is a generic message about a pended claim. A pended claim is one for which no remittance advice has been issued, or only part of the claim has been paid.');
	_codeSet.set('P1', 'Pending/In Process-The claim or encounter is in the adjudication system.');
	_codeSet.set('P2', 'Pending/Payer Review-The claim/encounter is suspended and is pending review (e.g. medical review, repricing, Third Party Administrator processing).');
	_codeSet.set('P3', 'Pending/Provider Requested Information - The claim or encounter is waiting for information that has already been requested from the provider. (Usage: A Claim Status Code identifying the type of information requested, must be reported)');
	_codeSet.set('P4', 'Pending/Patient Requested Information - The claim or encounter is waiting for information that has already been requested from the patient. (Usage: A status code identifying the type of information requested must be sent)');
	_codeSet.set('P5', 'Pending/Payer Administrative/System hold');
	_codeSet.set('F0', 'Finalized-The claim/encounter has completed the adjudication cycle and no more action will be taken.');
	_codeSet.set('F1', 'Finalized/Payment-The claim/line has been paid.');
	_codeSet.set('F2', 'Finalized/Denial-The claim/line has been denied.');
	_codeSet.set('F3', 'Finalized/Revised - Adjudication information has been changed');
	_codeSet.set('F3F', 'Finalized/Forwarded-The claim/encounter processing has been completed. Any applicable payment has been made and the claim/encounter has been forwarded to a subsequent entity as identified on the original claim or in this payers records.');
    _codeSet.set('F3N', 'Finalized/Not Forwarded-The claim/encounter processing has been completed. Any applicable payment has been made. The claim/encounter has NOT been forwarded to any subsequent entity identified on the original claim.');
	_codeSet.set('F4', 'Finalized/Adjudication Complete - No payment forthcoming-The claim/encounter has been adjudicated and no further payment is forthcoming.');
	_codeSet.set('F5', 'Finalized/Cannot Process');
	_codeSet.set('R0', 'Requests for additional Information/General Requests-Requests that dont fall into other R-type categories.');
    _codeSet.set('R1', 'Requests for additional Information/Entity Requests-Requests for information about specific entities (subscribers, patients, various providers).');
	_codeSet.set('R3', 'Requests for additional Information/Claim/Line-Requests for information that could normally be submitted on a claim.');
	_codeSet.set('R4', 'Requests for additional Information/Documentation-Requests for additional supporting documentation. Examples: certification, x-ray, notes.');
	_codeSet.set('R5', 'Request for additional information/more specific detail-Additional information as a follow up to a previous request is needed. The original information was received but is inadequate. More specific/detailed information is requested.');
	_codeSet.set('R6', 'Requests for additional information – Regulatory requirements');
	_codeSet.set('R7', 'Requests for additional information – Confirm care is consistent with Health Plan policy coverage');
	_codeSet.set('R8', 'Requests for additional information – Confirm care is consistent with health plan coverage exceptions');
	_codeSet.set('R9', 'Requests for additional information – Determination of medical necessity');
	_codeSet.set('R10', 'Requests for additional information – Support a filed grievance or appeal');
	_codeSet.set('R11', 'Requests for additional information – Pre-payment review of claims');
	_codeSet.set('R12', 'Requests for additional information – Clarification or justification of use for specified procedure code');
	_codeSet.set('R13', 'Requests for additional information – Original documents submitted are not readable.  Used only for subsequent request(s).');
	_codeSet.set('R14', 'Requests for additional information – Original documents received are not what was requested.  Used only for subsequent request(s).');
	_codeSet.set('R15', 'Requests for additional information – Workers Compensation coverage determination.');
	_codeSet.set('R16', 'Requests for additional information – Eligibility determination');
	_codeSet.set('R17', 'Replacement of a Prior Request. Used to indicate that the current attachment request replaces a prior attachment request.');
	_codeSet.set('RQ', 'General Questions (Yes/No Responses)-Questions that may be answered by a simple yes or no.');
	_codeSet.set('E0', 'Response not possible - error on submitted request data');
	_codeSet.set('E1', 'Response not possible - System Status');
	_codeSet.set('E2', 'Information Holder is not responding; resubmit at a later time.');
	_codeSet.set('E3', 'Correction required - relational fields in error.');
	_codeSet.set('E4', 'Trading partner agreement specific requirement not met: Data correction required. (Usage: A status code identifying the type of information requested must be sent)');
	_codeSet.set('D0', 'Data Search Unsuccessful - The payer is unable to return status on the requested claim(s) based on the submitted search criteria.');
	return _codeSet;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

const _fnGenerateCodeSetMap_CodeSource508 = function () {
	let _codeSet = new Map();
	_codeSet.set('0', 'Cannot provide further status electronically.');
	_codeSet.set('1', 'For more detailed information, see remittance advice.');
	_codeSet.set('2', 'More detailed information in letter.');
	_codeSet.set('3', 'Claim has been adjudicated and is awaiting payment cycle.');
	_codeSet.set('4', 'This is a subsequent request for information from the original request.');
	_codeSet.set('5', 'This is a final request for information.');
	_codeSet.set('6', 'Balance due from the subscriber.');
	_codeSet.set('7', 'Claim may be reconsidered at a future date.');
	_codeSet.set('8', 'No payment due to contract/plan provisions.');
	_codeSet.set('9', 'No payment will be made for this claim.');
	_codeSet.set('10', 'All originally submitted procedure codes have been combined.');
	_codeSet.set('11', 'Some originally submitted procedure codes have been combined.');
	_codeSet.set('12', 'One or more originally submitted procedure codes have been combined.');
	_codeSet.set('13', 'All originally submitted procedure codes have been modified.');
	_codeSet.set('14', 'Some all originally submitted procedure codes have been modified.');
	_codeSet.set('15', 'One or more originally submitted procedure code have been modified.');
	_codeSet.set('16', 'Claim/encounter has been forwarded to entity. Usage: This code requires use of an Entity Code.');
	_codeSet.set('17', 'Claim/encounter has been forwarded by third party entity to entity. Usage: This code requires use of an Entity Code.');
	_codeSet.set('18', 'Entity received claim/encounter, but returned invalid status. Usage: This code requires use of an Entity Code.');
	_codeSet.set('19', 'Entity acknowledges receipt of claim/encounter. Usage: This code requires use of an Entity Code.');
	_codeSet.set('20', 'Accepted for processing.');
	_codeSet.set('21', 'Missing or invalid information. Usage: At least one other status code is required to identify the missing or invalid information.');
	_codeSet.set('22', '... before entering the adjudication system.');
	_codeSet.set('23', 'Returned to Entity. Usage: This code requires use of an Entity Code.');
	_codeSet.set('24', 'Entity not approved as an electronic submitter. Usage: This code requires use of an Entity Code.');
	_codeSet.set('25', 'Entity not approved. Usage: This code requires use of an Entity Code.');
	_codeSet.set('26', 'Entity not found. Usage: This code requires use of an Entity Code.');
	_codeSet.set('27', 'Policy canceled.');
	_codeSet.set('28', 'Claim submitted to wrong payer.');
	_codeSet.set('29', 'Subscriber and policy number/contract number mismatched.');
	_codeSet.set('30', 'Subscriber and subscriber id mismatched.');
	_codeSet.set('31', 'Subscriber and policyholder name mismatched.');
	_codeSet.set('32', 'Subscriber and policy number/contract number not found.');
	_codeSet.set('33', 'Subscriber and subscriber id not found.');
	_codeSet.set('34', 'Subscriber and policyholder name not found.');
	_codeSet.set('35', 'Claim/encounter not found.');
	_codeSet.set('37', 'Predetermination is on file, awaiting completion of services.');
	_codeSet.set('38', 'Awaiting next periodic adjudication cycle.');
	_codeSet.set('39', 'Charges for pregnancy deferred until delivery.');
	_codeSet.set('40', 'Waiting for final approval.');
	_codeSet.set('41', 'Special handling required at payer site.');
	_codeSet.set('42', 'Awaiting related charges.');
	_codeSet.set('44', 'Charges pending provider audit.');
	_codeSet.set('45', 'Awaiting benefit determination.');
	_codeSet.set('46', 'Internal review/audit.');
	_codeSet.set('47', 'Internal review/audit - partial payment made.');
	_codeSet.set('48', 'Referral/authorization.');
	_codeSet.set('49', 'Pending provider accreditation review.');
	_codeSet.set('50', 'Claim waiting for internal provider verification.');
	_codeSet.set('51', 'Investigating occupational illness/accident.');
	_codeSet.set('52', 'Investigating existence of other insurance coverage.');
	_codeSet.set('53', 'Claim being researched for Insured ID/Group Policy Number error.');
	_codeSet.set('54', 'Duplicate of a previously processed claim/line.');
	_codeSet.set('55', 'Claim assigned to an approver/analyst.');
	_codeSet.set('56', 'Awaiting eligibility determination.');
	_codeSet.set('57', 'Pending COBRA information requested.');
	_codeSet.set('59', 'Information was requested by a non-electronic method. Usage: At least one other status code is required to identify the requested information.');
	_codeSet.set('60', 'Information was requested by an electronic method. Usage: At least one other status code is required to identify the requested information.');
	_codeSet.set('61', 'Eligibility for extended benefits.');
	_codeSet.set('64', 'Re-pricing information.');
	_codeSet.set('65', 'Claim/line has been paid.');
	_codeSet.set('66', 'Payment reflects usual and customary charges.');
	_codeSet.set('67', 'Payment made in full.');
	_codeSet.set('68', 'Partial payment made for this claim.');
	_codeSet.set('69', 'Payment reflects plan provisions.');
	_codeSet.set('70', 'Payment reflects contract provisions.');
	_codeSet.set('71', 'Periodic installment released.');
	_codeSet.set('72', 'Claim contains split payment.');
	_codeSet.set('73', 'Payment made to entity, assignment of benefits not on file. Usage: This code requires use of an Entity Code.');
	_codeSet.set('78', 'Duplicate of an existing claim/line, awaiting processing.');
	_codeSet.set('81', 'Contract/plan does not cover pre-existing conditions.');
	_codeSet.set('83', 'No coverage for newborns.');
	_codeSet.set('84', 'Service not authorized.');
	_codeSet.set('85', 'Entity not primary. Usage: This code requires use of an Entity Code.');
	_codeSet.set('86', 'Diagnosis and patient gender mismatch.');
	_codeSet.set('87', 'Denied: Entity not found. (Use code 26 with appropriate Claim Status category Code)');
	_codeSet.set('88', 'Entity not eligible for benefits for submitted dates of service. Usage: This code requires use of an Entity Code.');
	_codeSet.set('89', 'Entity not eligible for dental benefits for submitted dates of service. Usage: This code requires use of an Entity Code.');
	_codeSet.set('90', 'Entity not eligible for medical benefits for submitted dates of service. Usage: This code requires use of an Entity Code.');
	_codeSet.set('91', 'Entity not eligible/not approved for dates of service. Usage: This code requires use of an Entity Code.');
	_codeSet.set('92', 'Entity does not meet dependent or student qualification. Usage: This code requires use of an Entity Code.');
	_codeSet.set('93', 'Entity is not selected primary care provider. Usage: This code requires use of an Entity Code.');
	_codeSet.set('94', 'Entity not referred by selected primary care provider. Usage: This code requires use of an Entity Code.');
	_codeSet.set('95', 'Requested additional information not received. Usage: At least one other status code is required to identify the requested information.');
	_codeSet.set('96', 'No agreement with entity. Usage: This code requires use of an Entity Code.');
	_codeSet.set('97', 'Patient eligibility not found with entity. Usage: This code requires use of an Entity Code.');
	_codeSet.set('98', 'Charges applied to deductible.');
	_codeSet.set('99', 'Pre-treatment review.');
	_codeSet.set('100', 'Pre-certification penalty taken.');
	_codeSet.set('101', 'Claim was processed as adjustment to previous claim.');
	_codeSet.set('102', 'Newborns charges processed on mothers claim.');
	_codeSet.set('103', 'Claim combined with other claim(s).');
	_codeSet.set('104', 'Processed according to plan provisions (Plan refers to provisions that exist between the Health Plan and the Consumer or Patient)');
	_codeSet.set('105', 'Claim/line is capitated.');
	_codeSet.set('106', 'This amount is not entitys responsibility. Usage: This code requires use of an Entity Code.');
	_codeSet.set('107', 'Processed according to contract provisions (Contract refers to provisions that exist between the Health Plan and a Provider of Health Care Services)');
	_codeSet.set('108', 'Coverage has been canceled for this entity. (Use code 27)');
	_codeSet.set('109', 'Entity not eligible. Usage: This code requires use of an Entity Code.');
	_codeSet.set('110', 'Claim requires pricing information.');
	_codeSet.set('111', 'At the policyholders request these claims cannot be submitted electronically.');
	_codeSet.set('112', 'Policyholder processes their own claims.');
	_codeSet.set('113', 'Cannot process individual insurance policy claims.');
	_codeSet.set('114', 'Claim/service should be processed by entity. Usage: This code requires use of an Entity Code.');
	_codeSet.set('115', 'Cannot process HMO claims');
	_codeSet.set('116', 'Claim submitted to incorrect payer.');
	_codeSet.set('117', 'Claim requires signature-on-file indicator.');
	_codeSet.set('118', 'TPO rejected claim/line because payer name is missing. (Use status code 21 and status code 125 with entity code IN)');
	_codeSet.set('119', 'TPO rejected claim/line because certification information is missing. (Use status code 21 and status code 252)');
	_codeSet.set('120', 'TPO rejected claim/line because claim does not contain enough information. (Use status code 21)');
	_codeSet.set('121', 'Service line number greater than maximum allowable for payer.');
	_codeSet.set('122', 'Missing/invalid data prevents payer from processing claim. (Use CSC Code 21)');
	_codeSet.set('123', 'Additional information requested from entity. Usage: This code requires use of an Entity Code.');
	_codeSet.set('124', 'Entitys name, address, phone and id number. Usage: This code requires use of an Entity Code.');
	_codeSet.set('125', 'Entitys name. Usage: This code requires use of an Entity Code.');
	_codeSet.set('126', 'Entitys address. Usage: This code requires use of an Entity Code.');
	_codeSet.set('127', 'Entitys Communication Number. Usage: This code requires use of an Entity Code.');
	_codeSet.set('128', 'Entitys tax id. Usage: This code requires use of an Entity Code.');
	_codeSet.set('129', 'Entitys Blue Cross provider id. Usage: This code requires use of an Entity Code.');
	_codeSet.set('130', 'Entitys Blue Shield provider id. Usage: This code requires use of an Entity Code.');
	_codeSet.set('131', 'Entitys Medicare provider id. Usage: This code requires use of an Entity Code.');
	_codeSet.set('132', 'Entitys Medicaid provider id. Usage: This code requires use of an Entity Code.');
	_codeSet.set('133', 'Entitys UPIN. Usage: This code requires use of an Entity Code.');
	_codeSet.set('134', 'Entitys TRICARE provider id. Usage: This code requires use of an Entity Code.');
	_codeSet.set('135', 'Entitys commercial provider id. Usage: This code requires use of an Entity Code.');
	_codeSet.set('136', 'Entitys health industry id number. Usage: This code requires use of an Entity Code.');
	_codeSet.set('137', 'Entitys plan network id. Usage: This code requires use of an Entity Code.');
	_codeSet.set('138', 'Entitys site id. Usage: This code requires use of an Entity Code.');
	_codeSet.set('139', 'Entitys health maintenance provider id (HMO). Usage: This code requires use of an Entity Code.');
	_codeSet.set('140', 'Entitys preferred provider organization id (PPO). Usage: This code requires use of an Entity Code.');
	_codeSet.set('141', 'Entitys administrative services organization id (ASO). Usage: This code requires use of an Entity Code.');
	_codeSet.set('142', 'Entitys license/certification number. Usage: This code requires use of an Entity Code.');
	_codeSet.set('143', 'Entitys state license number. Usage: This code requires use of an Entity Code.');
	_codeSet.set('144', 'Entitys specialty license number. Usage: This code requires use of an Entity Code.');
	_codeSet.set('145', 'Entitys specialty/taxonomy code. Usage: This code requires use of an Entity Code.');
	_codeSet.set('146', 'Entitys anesthesia license number. Usage: This code requires use of an Entity Code.');
	_codeSet.set('147', 'Entitys qualification degree/designation (e.g. RN,PhD,MD). Usage: This code requires use of an Entity Code.');
	_codeSet.set('148', 'Entitys social security number. Usage: This code requires use of an Entity Code.');
	_codeSet.set('149', 'Entitys employer id. Usage: This code requires use of an Entity Code.');
	_codeSet.set('150', 'Entitys drug enforcement agency (DEA) number. Usage: This code requires use of an Entity Code.');
	_codeSet.set('152', 'Processor Control Number');
	_codeSet.set('153', 'Entitys id number. Usage: This code requires use of an Entity Code.');
	_codeSet.set('154', 'Relationship of surgeon & assistant surgeon.');
	_codeSet.set('155', 'Entitys relationship to patient. Usage: This code requires use of an Entity Code.');
	_codeSet.set('156', 'Patient relationship to subscriber');
	_codeSet.set('157', 'Entitys Gender. Usage: This code requires use of an Entity Code.');
	_codeSet.set('158', 'Entitys date of birth. Usage: This code requires use of an Entity Code.');
	_codeSet.set('159', 'Entitys date of death. Usage: This code requires use of an Entity Code.');
	_codeSet.set('160', 'Entitys marital status. Usage: This code requires use of an Entity Code.');
	_codeSet.set('161', 'Entitys employment status. Usage: This code requires use of an Entity Code.');
	_codeSet.set('162', 'Entitys health insurance claim number (HICN). Usage: This code requires use of an Entity Code.');
	_codeSet.set('163', 'Entitys policy/group number. Usage: This code requires use of an Entity Code.');
	_codeSet.set('164', 'Entitys contract/member number. Usage: This code requires use of an Entity Code.');
	_codeSet.set('165', 'Entitys employer name, address and phone. Usage: This code requires use of an Entity Code.');
	_codeSet.set('166', 'Entitys employer name. Usage: This code requires use of an Entity Code.');
	_codeSet.set('167', 'Entitys employer address. Usage: This code requires use of an Entity Code.');
	_codeSet.set('168', 'Entitys employer phone number. Usage: This code requires use of an Entity Code.');
	_codeSet.set('169', 'Entitys employer id.');
	_codeSet.set('170', 'Entitys employee id. Usage: This code requires use of an Entity Code.');
	_codeSet.set('171', 'Other insurance coverage information (health, liability, auto, etc.).');
	_codeSet.set('172', 'Other employer name, address and telephone number.');
	_codeSet.set('173', 'Entitys name, address, phone, gender, DOB, marital status, employment status and relation to subscriber. Usage: This code requires use of an Entity Code.');
	_codeSet.set('174', 'Entitys student status. Usage: This code requires use of an Entity Code.');
	_codeSet.set('175', 'Entitys school name. Usage: This code requires use of an Entity Code.');
	_codeSet.set('176', 'Entitys school address. Usage: This code requires use of an Entity Code.');
	_codeSet.set('177', 'Transplant recipients name, date of birth, gender, relationship to insured.');
	_codeSet.set('178', 'Total Claim Charge Amount');
	_codeSet.set('179', 'Outside lab charges.');
	_codeSet.set('180', 'Hospitals semi-private room rate.');
	_codeSet.set('181', 'Hospitals room rate.');
	_codeSet.set('182', 'Allowable/paid from other entities coverage Usage: This code requires the use of an entity code.');
	_codeSet.set('183', 'Amount entity has paid. Usage: This code requires use of an Entity Code.');
	_codeSet.set('184', 'Purchase price for the rented durable medical equipment.');
	_codeSet.set('185', 'Rental price for durable medical equipment.');
	_codeSet.set('186', 'Purchase and rental price of durable medical equipment.');
	_codeSet.set('187', 'Date(s) of service.');
	_codeSet.set('188', 'Statement from-through dates.');
	_codeSet.set('189', 'Facility admission date');
	_codeSet.set('190', 'Facility discharge date');
	_codeSet.set('191', 'Date of Last Menstrual Period (LMP)');
	_codeSet.set('192', 'Date of first service for current series/symptom/illness.');
	_codeSet.set('193', 'First consultation/evaluation date.');
	_codeSet.set('194', 'Confinement dates.');
	_codeSet.set('195', 'Unable to work dates/Disability Dates.');
	_codeSet.set('196', 'Return to work dates.');
	_codeSet.set('197', 'Effective coverage date(s).');
	_codeSet.set('198', 'Medicare effective date.');
	_codeSet.set('199', 'Date of conception and expected date of delivery.');
	_codeSet.set('200', 'Date of equipment return.');
	_codeSet.set('201', 'Date of dental appliance prior placement.');
	_codeSet.set('202', 'Date of dental prior replacement/reason for replacement.');
	_codeSet.set('203', 'Date of dental appliance placed.');
	_codeSet.set('204', 'Date dental canal(s) opened and date service completed.');
	_codeSet.set('205', 'Date(s) dental root canal therapy previously performed.');
	_codeSet.set('206', 'Most recent date of curettage, root planing, or periodontal surgery.');
	_codeSet.set('207', 'Dental impression and seating date.');
	_codeSet.set('208', 'Most recent date pacemaker was implanted.');
	_codeSet.set('209', 'Most recent pacemaker battery change date.');
	_codeSet.set('210', 'Date of the last x-ray.');
	_codeSet.set('211', 'Date(s) of dialysis training provided to patient.');
	_codeSet.set('212', 'Date of last routine dialysis.');
	_codeSet.set('213', 'Date of first routine dialysis.');
	_codeSet.set('214', 'Original date of prescription/orders/referral.');
	_codeSet.set('215', 'Date of tooth extraction/evolution.');
	_codeSet.set('216', 'Drug information.');
	_codeSet.set('217', 'Drug name, strength and dosage form.');
	_codeSet.set('218', 'NDC number.');
	_codeSet.set('219', 'Prescription number.');
	_codeSet.set('220', 'Drug product id number. (Use code 218)');
	_codeSet.set('221', 'Drug days supply and dosage.');
	_codeSet.set('222', 'Drug dispensing units and average wholesale price (AWP).');
	_codeSet.set('223', 'Route of drug/myelogram administration.');
	_codeSet.set('224', 'Anatomical location for joint injection.');
	_codeSet.set('225', 'Anatomical location.');
	_codeSet.set('226', 'Joint injection site.');
	_codeSet.set('227', 'Hospital information.');
	_codeSet.set('228', 'Type of bill for UB claim');
	_codeSet.set('229', 'Hospital admission source.');
	_codeSet.set('230', 'Hospital admission hour.');
	_codeSet.set('231', 'Hospital admission type.');
	_codeSet.set('232', 'Admitting diagnosis.');
	_codeSet.set('233', 'Hospital discharge hour.');
	_codeSet.set('234', 'Patient discharge status.');
	_codeSet.set('235', 'Units of blood furnished.');
	_codeSet.set('236', 'Units of blood replaced.');
	_codeSet.set('237', 'Units of deductible blood.');
	_codeSet.set('238', 'Separate claim for mother/baby charges.');
	_codeSet.set('239', 'Dental information.');
	_codeSet.set('240', 'Tooth surface(s) involved.');
	_codeSet.set('241', 'List of all missing teeth (upper and lower).');
	_codeSet.set('242', 'Tooth numbers, surfaces, and/or quadrants involved.');
	_codeSet.set('243', 'Months of dental treatment remaining.');
	_codeSet.set('244', 'Tooth number or letter.');
	_codeSet.set('245', 'Dental quadrant/arch.');
	_codeSet.set('246', 'Total orthodontic service fee, initial appliance fee, monthly fee, length of service.');
	_codeSet.set('247', 'Line information.');
	_codeSet.set('248', 'Accident date, state, description and cause.');
	_codeSet.set('249', 'Place of service.');
	_codeSet.set('250', 'Type of service.');
	_codeSet.set('251', 'Total anesthesia minutes.');
	_codeSet.set('252', 'Entitys prior authorization/certification number. Usage: This code requires the use of an Entity Code.');
	_codeSet.set('253', 'Procedure/revenue code for service(s) rendered. Use codes 454 or 455.');
	_codeSet.set('254', 'Principal diagnosis code.');
	_codeSet.set('255', 'Diagnosis code.');
	_codeSet.set('256', 'DRG code(s).');
	_codeSet.set('257', 'ADSM-III-R code for services rendered.');
	_codeSet.set('258', 'Days/units for procedure/revenue code.');
	_codeSet.set('259', 'Frequency of service.');
	_codeSet.set('260', 'Length of medical necessity, including begin date.');
	_codeSet.set('261', 'Obesity measurements.');
	_codeSet.set('262', 'Type of surgery/service for which anesthesia was administered.');
	_codeSet.set('263', 'Length of time for services rendered.');
	_codeSet.set('264', 'Number of liters/minute & total hours/day for respiratory support.');
	_codeSet.set('265', 'Number of lesions excised.');
	_codeSet.set('266', 'Facility point of origin and destination - ambulance.');
	_codeSet.set('267', 'Number of miles patient was transported.');
	_codeSet.set('268', 'Location of durable medical equipment use.');
	_codeSet.set('269', 'Length/size of laceration/tumor.');
	_codeSet.set('270', 'Subluxation location.');
	_codeSet.set('271', 'Number of spine segments.');
	_codeSet.set('272', 'Oxygen contents for oxygen system rental.');
	_codeSet.set('273', 'Weight.');
	_codeSet.set('274', 'Height.');
	_codeSet.set('275', 'Claim.');
	_codeSet.set('276', 'UB04/HCFA-1450/1500 claim form');
	_codeSet.set('277', 'Paper claim.');
	_codeSet.set('278', 'Signed claim form.');
	_codeSet.set('279', 'Claim/service must be itemized');
	_codeSet.set('280', 'Itemized claim by provider.');
	_codeSet.set('281', 'Related confinement claim.');
	_codeSet.set('282', 'Copy of prescription.');
	_codeSet.set('283', 'Medicare entitlement information is required to determine primary coverage');
	_codeSet.set('284', 'Copy of Medicare ID card.');
	_codeSet.set('285', 'Vouchers/explanation of benefits (EOB).');
	_codeSet.set('286', 'Other payers Explanation of Benefits/payment information.');
	_codeSet.set('287', 'Medical necessity for service.');
	_codeSet.set('288', 'Hospital late charges');
	_codeSet.set('289', 'Reason for late discharge.');
	_codeSet.set('290', 'Pre-existing information.');
	_codeSet.set('291', 'Reason for termination of pregnancy.');
	_codeSet.set('292', 'Purpose of family conference/therapy.');
	_codeSet.set('293', 'Reason for physical therapy.');
	_codeSet.set('294', 'Supporting documentation. Usage: At least one other status code is required to identify the supporting documentation.');
	_codeSet.set('295', 'Attending physician report.');
	_codeSet.set('296', 'Nurses notes.');
	_codeSet.set('297', 'Medical notes/report.');
	_codeSet.set('298', 'Operative report.');
	_codeSet.set('299', 'Emergency room notes/report.');
	_codeSet.set('300', 'Lab/test report/notes/results.');
	_codeSet.set('301', 'MRI report.');
	_codeSet.set('302', 'Refer to codes 300 for lab notes and 311 for pathology notes');
	_codeSet.set('303', 'Physical therapy notes. Use code 297:6O (6 OH - not zero)');
	_codeSet.set('304', 'Reports for service.');
	_codeSet.set('305', 'Radiology/x-ray reports and/or interpretation');
	_codeSet.set('306', 'Detailed description of service.');
	_codeSet.set('307', 'Narrative with pocket depth chart.');
	_codeSet.set('308', 'Discharge summary.');
	_codeSet.set('309', 'Code was duplicate of code 299');
	_codeSet.set('310', 'Progress notes for the six months prior to statement date.');
	_codeSet.set('311', 'Pathology notes/report.');
	_codeSet.set('312', 'Dental charting.');
	_codeSet.set('313', 'Bridgework information.');
	_codeSet.set('314', 'Dental records for this service.');
	_codeSet.set('315', 'Past perio treatment history.');
	_codeSet.set('316', 'Complete medical history.');
	_codeSet.set('317', 'Patients medical records.');
	_codeSet.set('318', 'X-rays/radiology films');
	_codeSet.set('319', 'Pre/post-operative x-rays/photographs.');
	_codeSet.set('320', 'Study models.');
	_codeSet.set('321', 'Radiographs or models. (Use codes 318 and/or 320)');
	_codeSet.set('322', 'Recent Full Mouth X-rays');
	_codeSet.set('323', 'Study models, x-rays, and/or narrative.');
	_codeSet.set('324', 'Recent x-ray of treatment area and/or narrative.');
	_codeSet.set('325', 'Recent fm x-rays and/or narrative.');
	_codeSet.set('326', 'Copy of transplant acquisition invoice.');
	_codeSet.set('327', 'Periodontal case type diagnosis and recent pocket depth chart with narrative.');
	_codeSet.set('328', 'Speech therapy notes. Use code 297:6R');
	_codeSet.set('329', 'Exercise notes.');
	_codeSet.set('330', 'Occupational notes.');
	_codeSet.set('331', 'History and physical.');
	_codeSet.set('332', 'Authorization/certification (include period covered). (Use code 252)');
	_codeSet.set('333', 'Patient release of information authorization.');
	_codeSet.set('334', 'Oxygen certification.');
	_codeSet.set('335', 'Durable medical equipment certification.');
	_codeSet.set('336', 'Chiropractic certification.');
	_codeSet.set('337', 'Ambulance certification/documentation.');
	_codeSet.set('338', 'Home health certification. Use code 332:4Y');
	_codeSet.set('339', 'Enteral/parenteral certification.');
	_codeSet.set('340', 'Pacemaker certification.');
	_codeSet.set('341', 'Private duty nursing certification.');
	_codeSet.set('342', 'Podiatric certification.');
	_codeSet.set('343', 'Documentation that facility is state licensed and Medicare approved as a surgical facility.');
	_codeSet.set('344', 'Documentation that provider of physical therapy is Medicare Part B approved.');
	_codeSet.set('345', 'Treatment plan for service/diagnosis');
	_codeSet.set('346', 'Proposed treatment plan for next 6 months.');
	_codeSet.set('347', 'Refer to code 345 for treatment plan and code 282 for prescription');
	_codeSet.set('348', 'Chiropractic treatment plan. (Use 345:QL)');
	_codeSet.set('349', 'Psychiatric treatment plan. Use codes 345:5I, 5J, 5K, 5L, 5M, 5N, 5O (5 OH - not zero), 5P');
	_codeSet.set('350', 'Speech pathology treatment plan. Use code 345:6R');
	_codeSet.set('351', 'Physical/occupational therapy treatment plan. Use codes 345:6O (6 OH - not zero), 6N');
	_codeSet.set('352', 'Duration of treatment plan.');
	_codeSet.set('353', 'Orthodontics treatment plan.');
	_codeSet.set('354', 'Treatment plan for replacement of remaining missing teeth.');
	_codeSet.set('355', 'Has claim been paid?');
	_codeSet.set('356', 'Was blood furnished?');
	_codeSet.set('357', 'Has or will blood be replaced?');
	_codeSet.set('358', 'Does provider accept assignment of benefits? (Use code 589)');
	_codeSet.set('359', 'Is there a release of information signature on file? (Use code 333)');
	_codeSet.set('360', 'Benefits Assignment Certification Indicator');
	_codeSet.set('361', 'Is there other insurance?');
	_codeSet.set('362', 'Is the dental patient covered by medical insurance?');
	_codeSet.set('363', 'Possible Workers Compensation');
	_codeSet.set('364', 'Is accident/illness/condition employment related?');
	_codeSet.set('365', 'Is service the result of an accident?');
	_codeSet.set('366', 'Is injury due to auto accident?');
	_codeSet.set('367', 'Is service performed for a recurring condition or new condition?');
	_codeSet.set('368', 'Is medical doctor (MD) or doctor of osteopath (DO) on staff of this facility?');
	_codeSet.set('369', 'Does patient condition preclude use of ordinary bed?');
	_codeSet.set('370', 'Can patient operate controls of bed?');
	_codeSet.set('371', 'Is patient confined to room?');
	_codeSet.set('372', 'Is patient confined to bed?');
	_codeSet.set('373', 'Is patient an insulin diabetic?');
	_codeSet.set('374', 'Is prescribed lenses a result of cataract surgery?');
	_codeSet.set('375', 'Was refraction performed?');
	_codeSet.set('376', 'Was charge for ambulance for a round-trip?');
	_codeSet.set('377', 'Was durable medical equipment purchased new or used?');
	_codeSet.set('378', 'Is pacemaker temporary or permanent?');
	_codeSet.set('379', 'Were services performed supervised by a physician?');
	_codeSet.set('380', 'CRNA supervision/medical direction.');
	_codeSet.set('381', 'Is drug generic?');
	_codeSet.set('382', 'Did provider authorize generic or brand name dispensing?');
	_codeSet.set('383', 'Nerve block use (surgery vs. pain management)');
	_codeSet.set('384', 'Is prosthesis/crown/inlay placement an initial placement or a replacement?');
	_codeSet.set('385', 'Is appliance upper or lower arch & is appliance fixed or removable?');
	_codeSet.set('386', 'Orthodontic Treatment/Purpose Indicator');
	_codeSet.set('387', 'Date patient last examined by entity. Usage: This code requires use of an Entity Code.');
	_codeSet.set('388', 'Date post-operative care assumed');
	_codeSet.set('389', 'Date post-operative care relinquished');
	_codeSet.set('390', 'Date of most recent medical event necessitating service(s)');
	_codeSet.set('391', 'Date(s) dialysis conducted');
	_codeSet.set('392', 'Date(s) of blood transfusion(s)');
	_codeSet.set('393', 'Date of previous pacemaker check');
	_codeSet.set('394', 'Date(s) of most recent hospitalization related to service');
	_codeSet.set('395', 'Date entity signed certification/recertification Usage: This code requires use of an Entity Code.');
	_codeSet.set('396', 'Date home dialysis began');
	_codeSet.set('397', 'Date of onset/exacerbation of illness/condition');
	_codeSet.set('398', 'Visual field test results');
	_codeSet.set('399', 'Report of prior testing related to this service, including dates');
	_codeSet.set('400', 'Claim is out of balance');
	_codeSet.set('401', 'Source of payment is not valid');
	_codeSet.set('402', 'Amount must be greater than zero. Usage: At least one other status code is required to identify which amount element is in error.');
	_codeSet.set('403', 'Entity referral notes/orders/prescription. Usage: this code requires use of an entity code.');
	_codeSet.set('404', 'Specific findings, complaints, or symptoms necessitating service');
	_codeSet.set('405', 'Summary of services');
	_codeSet.set('406', 'Brief medical history as related to service(s)');
	_codeSet.set('407', 'Complications/mitigating circumstances');
	_codeSet.set('408', 'Initial certification');
	_codeSet.set('409', 'Medication logs/records (including medication therapy)');
	_codeSet.set('410', 'Explain differences between treatment plan and patients condition');
	_codeSet.set('411', 'Medical necessity for non-routine service(s)');
	_codeSet.set('412', 'Medical records to substantiate decision of non-coverage');
	_codeSet.set('413', 'Explain/justify differences between treatment plan and services rendered.');
	_codeSet.set('414', 'Necessity for concurrent care (more than one physician treating the patient)');
	_codeSet.set('415', 'Justify services outside composite rate');
	_codeSet.set('416', 'Verification of patients ability to retain and use information');
	_codeSet.set('417', 'Prior testing, including result(s) and date(s) as related to service(s)');
	_codeSet.set('418', 'Indicating why medications cannot be taken orally');
	_codeSet.set('419', 'Individual test(s) comprising the panel and the charges for each test');
	_codeSet.set('420', 'Name, dosage and medical justification of contrast material used for radiology procedure');
	_codeSet.set('421', 'Medical review attachment/information for service(s)');
	_codeSet.set('422', 'Homebound status');
	_codeSet.set('423', 'Prognosis');
	_codeSet.set('424', 'Statement of non-coverage including itemized bill');
	_codeSet.set('425', 'Itemize non-covered services');
	_codeSet.set('426', 'All current diagnoses');
	_codeSet.set('427', 'Emergency care provided during transport');
	_codeSet.set('428', 'Reason for transport by ambulance');
	_codeSet.set('429', 'Loaded miles and charges for transport to nearest facility with appropriate services');
	_codeSet.set('430', 'Nearest appropriate facility');
	_codeSet.set('431', 'Patients condition/functional status at time of service.');
	_codeSet.set('432', 'Date benefits exhausted');
	_codeSet.set('433', 'Copy of patient revocation of hospice benefits');
	_codeSet.set('434', 'Reasons for more than one transfer per entitlement period');
	_codeSet.set('435', 'Notice of Admission');
	_codeSet.set('436', 'Short term goals');
	_codeSet.set('437', 'Long term goals');
	_codeSet.set('438', 'Number of patients attending session');
	_codeSet.set('439', 'Size, depth, amount, and type of drainage wounds');
	_codeSet.set('440', 'why non-skilled caregiver has not been taught procedure');
	_codeSet.set('441', 'Entity professional qualification for service(s). Usage: This code requires the use of an Entity Code.”');
	_codeSet.set('442', 'Modalities of service');
	_codeSet.set('443', 'Initial evaluation report');
	_codeSet.set('444', 'Method used to obtain test sample');
	_codeSet.set('445', 'Explain why hearing loss not correctable by hearing aid');
	_codeSet.set('446', 'Documentation from prior claim(s) related to service(s)');
	_codeSet.set('447', 'Plan of teaching');
	_codeSet.set('448', 'Invalid billing combination. See STC12 for details. This code should only be used to indicate an inconsistency between two or more data elements on the claim. A detailed explanation is required in STC12 when this code is used.');
	_codeSet.set('449', 'Projected date to discontinue service(s)');
	_codeSet.set('450', 'Awaiting spend down determination');
	_codeSet.set('451', 'Preoperative and post-operative diagnosis');
	_codeSet.set('452', 'Total visits in total number of hours/day and total number of hours/week');
	_codeSet.set('453', 'Procedure Code Modifier(s) for Service(s) Rendered');
	_codeSet.set('454', 'Procedure code for services rendered.');
	_codeSet.set('455', 'Revenue code for services rendered.');
	_codeSet.set('456', 'Covered Day(s)');
	_codeSet.set('457', 'Non-Covered Day(s)');
	_codeSet.set('458', 'Coinsurance Day(s)');
	_codeSet.set('459', 'Lifetime Reserve Day(s)');
	_codeSet.set('460', 'NUBC Condition Code(s)');
	_codeSet.set('461', 'NUBC Occurrence Code(s) and Date(s)');
	_codeSet.set('462', 'NUBC Occurrence Span Code(s) and Date(s)');
	_codeSet.set('463', 'NUBC Value Code(s) and/or Amount(s)');
	_codeSet.set('464', 'Payer Assigned Claim Control Number');
	_codeSet.set('465', 'Principal Procedure Code for Service(s) Rendered');
	_codeSet.set('466', 'Entitys Original Signature. Usage: This code requires use of an Entity Code.');
	_codeSet.set('467', 'Entity Signature Date. Usage: This code requires use of an Entity Code.');
	_codeSet.set('468', 'Patient Signature Source');
	_codeSet.set('469', 'Purchase Service Charge');
	_codeSet.set('470', 'Was service purchased from another entity? Usage: This code requires use of an Entity Code.');
	_codeSet.set('471', 'Were services related to an emergency?');
	_codeSet.set('472', 'Ambulance Run Sheet');
	_codeSet.set('473', 'Missing or invalid lab indicator');
	_codeSet.set('474', 'Procedure code and patient gender mismatch');
	_codeSet.set('475', 'Procedure code not valid for patient age');
	_codeSet.set('476', 'Missing or invalid units of service');
	_codeSet.set('477', 'Diagnosis code pointer is missing or invalid');
	_codeSet.set('478', 'Claim submitters identifier');
	_codeSet.set('479', 'Other Carrier payer ID is missing or invalid');
	_codeSet.set('480', 'Entitys claim filing indicator. Usage: This code requires use of an Entity Code.');
	_codeSet.set('481', 'Claim/submission format is invalid.');
	_codeSet.set('482', 'Date Error, Century Missing');
	_codeSet.set('483', 'Maximum coverage amount met or exceeded for benefit period.');
	_codeSet.set('484', 'Business Application Currently Not Available');
	_codeSet.set('485', 'More information available than can be returned in real-time mode. Narrow your current search criteria.');
	_codeSet.set('486', 'Principal Procedure Date');
	_codeSet.set('487', 'Claim not found, claim should have been submitted to/through entity. Usage: This code requires use of an Entity Code.');
	_codeSet.set('488', 'Diagnosis code(s) for the services rendered.');
	_codeSet.set('489', 'Attachment Control Number');
	_codeSet.set('490', 'Other Procedure Code for Service(s) Rendered');
	_codeSet.set('491', 'Entity not eligible for encounter submission. Usage: This code requires use of an Entity Code.');
	_codeSet.set('492', 'Other Procedure Date');
	_codeSet.set('493', 'Version/Release/Industry ID code not currently supported by information holder');
	_codeSet.set('494', 'Real-time requests not supported by the information holder, resubmit as batch request.');
	_codeSet.set('495', 'Requests for re-adjudication must reference the newly assigned payer claim control number for this previously adjusted claim. Correct the payer claim control number and re-submit.');
	_codeSet.set('496', 'Submitter not approved for electronic claim submissions on behalf of this entity. Usage: This code requires use of an Entity Code.');
	_codeSet.set('497', 'Sales tax not paid');
	_codeSet.set('498', 'Maximum leave days exhausted');
	_codeSet.set('499', 'No rate on file with the payer for this service for this entity Usage: This code requires use of an Entity Code.');
	_codeSet.set('500', 'Entitys Postal/Zip Code. Usage: This code requires use of an Entity Code.');
	_codeSet.set('501', 'Entitys State/Province. Usage: This code requires use of an Entity Code.');
	_codeSet.set('502', 'Entitys City. Usage: This code requires use of an Entity Code.');
	_codeSet.set('503', 'Entitys Street Address. Usage: This code requires use of an Entity Code.');
	_codeSet.set('504', 'Entitys Last Name. Usage: This code requires use of an Entity Code.');
	_codeSet.set('505', 'Entitys First Name. Usage: This code requires use of an Entity Code.');
	_codeSet.set('506', 'Entity is changing processor/clearinghouse. This claim must be submitted to the new processor/clearinghouse. Usage: This code requires use of an Entity Code.');
	_codeSet.set('507', 'HCPCS');
	_codeSet.set('508', 'ICD9 Usage: At least one other status code is required to identify the related procedure code or diagnosis code.');
	_codeSet.set('509', 'External Cause of Injury Code.');
	_codeSet.set('510', 'Future date. Usage: At least one other status code is required to identify the data element in error.');
	_codeSet.set('511', 'Invalid character. Usage: At least one other status code is required to identify the data element in error.');
	_codeSet.set('512', 'Length invalid for receivers application system. Usage: At least one other status code is required to identify the data element in error.');
	_codeSet.set('513', 'HIPPS Rate Code for services rendered');
	_codeSet.set('514', 'Entitys Middle Name Usage: This code requires use of an Entity Code.');
	_codeSet.set('515', 'Managed Care review');
	_codeSet.set('516', 'Other Entitys Adjudication or Payment/Remittance Date. Usage: An Entity code is required to identify the Other Payer Entity, i.e. primary, secondary.');
	_codeSet.set('517', 'Adjusted Repriced Claim Reference Number');
	_codeSet.set('518', 'Adjusted Repriced Line item Reference Number');
	_codeSet.set('519', 'Adjustment Amount');
	_codeSet.set('520', 'Adjustment Quantity');
	_codeSet.set('521', 'Adjustment Reason Code');
	_codeSet.set('522', 'Anesthesia Modifying Units');
	_codeSet.set('523', 'Anesthesia Unit Count');
	_codeSet.set('524', 'Arterial Blood Gas Quantity');
	_codeSet.set('525', 'Begin Therapy Date');
	_codeSet.set('526', 'Bundled or Unbundled Line Number');
	_codeSet.set('527', 'Certification Condition Indicator');
	_codeSet.set('528', 'Certification Period Projected Visit Count');
	_codeSet.set('529', 'Certification Revision Date');
	_codeSet.set('530', 'Claim Adjustment Indicator');
	_codeSet.set('531', 'Claim Disproportinate Share Amount');
	_codeSet.set('532', 'Claim DRG Amount');
	_codeSet.set('533', 'Claim DRG Outlier Amount');
	_codeSet.set('534', 'Claim ESRD Payment Amount');
	_codeSet.set('535', 'Claim Frequency Code');
	_codeSet.set('536', 'Claim Indirect Teaching Amount');
	_codeSet.set('537', 'Claim MSP Pass-through Amount');
	_codeSet.set('538', 'Claim or Encounter Identifier');
	_codeSet.set('539', 'Claim PPS Capital Amount');
	_codeSet.set('540', 'Claim PPS Capital Outlier Amount');
	_codeSet.set('541', 'Claim Submission Reason Code');
	_codeSet.set('542', 'Claim Total Denied Charge Amount');
	_codeSet.set('543', 'Clearinghouse or Value Added Network Trace');
	_codeSet.set('544', 'Clinical Laboratory Improvement Amendment (CLIA) Number');
	_codeSet.set('545', 'Contract Amount');
	_codeSet.set('546', 'Contract Code');
	_codeSet.set('547', 'Contract Percentage');
	_codeSet.set('548', 'Contract Type Code');
	_codeSet.set('549', 'Contract Version Identifier');
	_codeSet.set('550', 'Coordination of Benefits Code');
	_codeSet.set('551', 'Coordination of Benefits Total Submitted Charge');
	_codeSet.set('552', 'Cost Report Day Count');
	_codeSet.set('553', 'Covered Amount');
	_codeSet.set('554', 'Date Claim Paid');
	_codeSet.set('555', 'Delay Reason Code');
	_codeSet.set('556', 'Demonstration Project Identifier');
	_codeSet.set('557', 'Diagnosis Date');
	_codeSet.set('558', 'Discount Amount');
	_codeSet.set('559', 'Document Control Identifier');
	_codeSet.set('560', 'Entitys Additional/Secondary Identifier. Usage: This code requires use of an Entity Code.');
	_codeSet.set('561', 'Entitys Contact Name. Usage: This code requires use of an Entity Code.');
	_codeSet.set('562', 'Entitys National Provider Identifier (NPI). Usage: This code requires use of an Entity Code.');
	_codeSet.set('563', 'Entitys Tax Amount. Usage: This code requires use of an Entity Code.');
	_codeSet.set('564', 'EPSDT Indicator');
	_codeSet.set('565', 'Estimated Claim Due Amount');
	_codeSet.set('566', 'Exception Code');
	_codeSet.set('567', 'Facility Code Qualifier');
	_codeSet.set('568', 'Family Planning Indicator');
	_codeSet.set('569', 'Fixed Format Information');
	_codeSet.set('570', 'Free Form Message Text');
	_codeSet.set('571', 'Frequency Count');
	_codeSet.set('572', 'Frequency Period');
	_codeSet.set('573', 'Functional Limitation Code');
	_codeSet.set('574', 'HCPCS Payable Amount Home Health');
	_codeSet.set('575', 'Homebound Indicator');
	_codeSet.set('576', 'Immunization Batch Number');
	_codeSet.set('577', 'Industry Code');
	_codeSet.set('578', 'Insurance Type Code');
	_codeSet.set('579', 'Investigational Device Exemption Identifier');
	_codeSet.set('580', 'Last Certification Date');
	_codeSet.set('581', 'Last Worked Date');
	_codeSet.set('582', 'Lifetime Psychiatric Days Count');
	_codeSet.set('583', 'Line Item Charge Amount');
	_codeSet.set('584', 'Line Item Control Number');
	_codeSet.set('585', 'Denied Charge or Non-covered Charge');
	_codeSet.set('586', 'Line Note Text');
	_codeSet.set('587', 'Measurement Reference Identification Code');
	_codeSet.set('588', 'Medical Record Number');
	_codeSet.set('589', 'Provider Accept Assignment Code');
	_codeSet.set('590', 'Medicare Coverage Indicator');
	_codeSet.set('591', 'Medicare Paid at 100% Amount');
	_codeSet.set('592', 'Medicare Paid at 80% Amount');
	_codeSet.set('593', 'Medicare Section 4081 Indicator');
	_codeSet.set('594', 'Mental Status Code');
	_codeSet.set('595', 'Monthly Treatment Count');
	_codeSet.set('596', 'Non-covered Charge Amount');
	_codeSet.set('597', 'Non-payable Professional Component Amount');
	_codeSet.set('598', 'Non-payable Professional Component Billed Amount');
	_codeSet.set('599', 'Note Reference Code');
	_codeSet.set('600', 'Oxygen Saturation Qty');
	_codeSet.set('601', 'Oxygen Test Condition Code');
	_codeSet.set('602', 'Oxygen Test Date');
	_codeSet.set('603', 'Old Capital Amount');
	_codeSet.set('604', 'Originator Application Transaction Identifier');
	_codeSet.set('605', 'Orthodontic Treatment Months Count');
	_codeSet.set('606', 'Paid From Part A Medicare Trust Fund Amount');
	_codeSet.set('607', 'Paid From Part B Medicare Trust Fund Amount');
	_codeSet.set('608', 'Paid Service Unit Count');
	_codeSet.set('609', 'Participation Agreement');
	_codeSet.set('610', 'Patient Discharge Facility Type Code');
	_codeSet.set('611', 'Peer Review Authorization Number');
	_codeSet.set('612', 'Per Day Limit Amount');
	_codeSet.set('613', 'Physician Contact Date');
	_codeSet.set('614', 'Physician Order Date');
	_codeSet.set('615', 'Policy Compliance Code');
	_codeSet.set('616', 'Policy Name');
	_codeSet.set('617', 'Postage Claimed Amount');
	_codeSet.set('618', 'PPS-Capital DSH DRG Amount');
	_codeSet.set('619', 'PPS-Capital Exception Amount');
	_codeSet.set('620', 'PPS-Capital FSP DRG Amount');
	_codeSet.set('621', 'PPS-Capital HSP DRG Amount');
	_codeSet.set('622', 'PPS-Capital IME Amount');
	_codeSet.set('623', 'PPS-Operating Federal Specific DRG Amount');
	_codeSet.set('624', 'PPS-Operating Hospital Specific DRG Amount');
	_codeSet.set('625', 'Predetermination of Benefits Identifier');
	_codeSet.set('626', 'Pregnancy Indicator');
	_codeSet.set('627', 'Pre-Tax Claim Amount');
	_codeSet.set('628', 'Pricing Methodology');
	_codeSet.set('629', 'Property Casualty Claim Number');
	_codeSet.set('630', 'Referring CLIA Number');
	_codeSet.set('631', 'Reimbursement Rate');
	_codeSet.set('632', 'Reject Reason Code');
	_codeSet.set('633', 'Related Causes Code (Accident, auto accident, employment)');
	_codeSet.set('634', 'Remark Code');
	_codeSet.set('635', 'Repriced Ambulatory Patient Group Code');
	_codeSet.set('636', 'Repriced Line Item Reference Number');
	_codeSet.set('637', 'Repriced Saving Amount');
	_codeSet.set('638', 'Repricing Per Diem or Flat Rate Amount');
	_codeSet.set('639', 'Responsibility Amount');
	_codeSet.set('640', 'Sales Tax Amount');
	_codeSet.set('641', 'Service Adjudication or Payment Date. Note: Use code 516.');
	_codeSet.set('642', 'Service Authorization Exception Code');
	_codeSet.set('643', 'Service Line Paid Amount');
	_codeSet.set('644', 'Service Line Rate');
	_codeSet.set('645', 'Service Tax Amount');
	_codeSet.set('646', 'Ship, Delivery or Calendar Pattern Code');
	_codeSet.set('647', 'Shipped Date');
	_codeSet.set('648', 'Similar Illness or Symptom Date');
	_codeSet.set('649', 'Skilled Nursing Facility Indicator');
	_codeSet.set('650', 'Special Program Indicator');
	_codeSet.set('651', 'State Industrial Accident Provider Number');
	_codeSet.set('652', 'Terms Discount Percentage');
	_codeSet.set('653', 'Test Performed Date');
	_codeSet.set('654', 'Total Denied Charge Amount');
	_codeSet.set('655', 'Total Medicare Paid Amount');
	_codeSet.set('656', 'Total Visits Projected This Certification Count');
	_codeSet.set('657', 'Total Visits Rendered Count');
	_codeSet.set('658', 'Treatment Code');
	_codeSet.set('659', 'Unit or Basis for Measurement Code');
	_codeSet.set('660', 'Universal Product Number');
	_codeSet.set('661', 'Visits Prior to Recertification Date Count CR702');
	_codeSet.set('662', 'X-ray Availability Indicator');
	_codeSet.set('663', 'Entitys Group Name. Usage: This code requires use of an Entity Code.');
	_codeSet.set('664', 'Orthodontic Banding Date');
	_codeSet.set('665', 'Surgery Date');
	_codeSet.set('666', 'Surgical Procedure Code');
	_codeSet.set('667', 'Real-time requests not supported by the information holder, do not resubmit.');
	_codeSet.set('668', 'Missing Endodontics treatment history and prognosis');
	_codeSet.set('669', 'Dental service narrative needed.');
	_codeSet.set('670', 'Funds applied from a consumer spending account such as consumer directed/driven health plan (CDHP), Health savings account (H S A) and or other similar accounts');
	_codeSet.set('671', 'Funds may be available from a consumer spending account such as consumer directed/driven health plan (CDHP), Health savings account (H S A) and or other similar accounts');
	_codeSet.set('672', 'Other Payers payment information is out of balance');
	_codeSet.set('673', 'Patient Reason for Visit');
	_codeSet.set('674', 'Authorization exceeded');
	_codeSet.set('675', 'Facility admission through discharge dates');
	_codeSet.set('676', 'Entity possibly compensated by facility. Usage: This code requires use of an Entity Code.');
	_codeSet.set('677', 'Entity not affiliated. Usage: This code requires use of an Entity Code.');
	_codeSet.set('678', 'Revenue code and patient gender mismatch');
	_codeSet.set('679', 'Submit newborn services on mothers claim');
	_codeSet.set('680', 'Entitys Country. Usage: This code requires use of an Entity Code.');
	_codeSet.set('681', 'Claim currency not supported');
	_codeSet.set('682', 'Cosmetic procedure');
	_codeSet.set('683', 'Awaiting Associated Hospital Claims');
	_codeSet.set('684', 'Rejected. Syntax error noted for this claim/service/inquiry. See Functional or Implementation Acknowledgement for details. Usage: Only for use to reject claims or status requests in transactions that were accepted with errors on a 997 or 999 Acknowledgement.');
	_codeSet.set('685', 'Claim could not complete adjudication in real-time. Claim will continue processing in a batch mode. Do not resubmit.');
	_codeSet.set('686', 'The claim/ encounter has completed the adjudication cycle and the entire claim has been voided');
	_codeSet.set('687', 'Claim predetermination/estimation could not be completed in real-time. Do not resubmit.');
	_codeSet.set('688', 'Present on Admission Indicator for reported diagnosis code(s).');
	_codeSet.set('689', 'Entity was unable to respond within the expected time frame. Usage: This code requires use of an Entity Code.');
	_codeSet.set('690', 'Multiple claims or estimate requests cannot be processed in real-time.');
	_codeSet.set('691', 'Multiple claim status requests cannot be processed in real-time.');
	_codeSet.set('692', 'Contracted funding agreement, subscriber is employed by the provider of services.');
	_codeSet.set('693', 'Amount must be greater than or equal to zero. Usage: At least one other status code is required to identify which amount element is in error.');
	_codeSet.set('694', 'Amount must not be equal to zero. Usage: At least one other status code is required to identify which amount element is in error.');
	_codeSet.set('695', 'Entitys Country Subdivision Code. Usage: This code requires use of an Entity Code.');
	_codeSet.set('696', 'Claim Adjustment Group Code.');
	_codeSet.set('697', 'Invalid Decimal Precision. Usage: At least one other status code is required to identify the data element in error.');
	_codeSet.set('698', 'Form Type Identification');
	_codeSet.set('699', 'Question/Response from Supporting Documentation Form');
	_codeSet.set('700', 'ICD10. Usage: At least one other status code is required to identify the related procedure code or diagnosis code.');
	_codeSet.set('701', 'Initial Treatment Date');
	_codeSet.set('702', 'Repriced Claim Reference Number');
	_codeSet.set('703', 'Advanced Billing Concepts (ABC) code');
	_codeSet.set('704', 'Claim Note Text');
	_codeSet.set('705', 'Repriced Allowed Amount');
	_codeSet.set('706', 'Repriced Approved Amount');
	_codeSet.set('707', 'Repriced Approved Ambulatory Patient Group Amount');
	_codeSet.set('708', 'Repriced Approved Revenue Code');
	_codeSet.set('709', 'Repriced Approved Service Unit Count');
	_codeSet.set('710', 'Line Adjudication Information. Usage: At least one other status code is required to identify the data element in error.');
	_codeSet.set('711', 'Stretcher purpose');
	_codeSet.set('712', 'Obstetric Additional Units');
	_codeSet.set('713', 'Patient Condition Description');
	_codeSet.set('714', 'Care Plan Oversight Number');
	_codeSet.set('715', 'Acute Manifestation Date');
	_codeSet.set('716', 'Repriced Approved DRG Code');
	_codeSet.set('717', 'This claim has been split for processing.');
	_codeSet.set('718', 'Claim/service not submitted within the required timeframe (timely filing).');
	_codeSet.set('719', 'NUBC Occurrence Code(s)');
	_codeSet.set('720', 'NUBC Occurrence Code Date(s)');
	_codeSet.set('721', 'NUBC Occurrence Span Code(s)');
	_codeSet.set('722', 'NUBC Occurrence Span Code Date(s)');
	_codeSet.set('723', 'Drug days supply');
	_codeSet.set('724', 'Drug Quantity');
	_codeSet.set('725', 'NUBC Value Code(s)');
	_codeSet.set('726', 'NUBC Value Code Amount(s)');
	_codeSet.set('727', 'Accident date');
	_codeSet.set('728', 'Accident state');
	_codeSet.set('729', 'Accident description');
	_codeSet.set('730', 'Accident cause');
	_codeSet.set('731', 'Measurement value/test result');
	_codeSet.set('732', 'Information submitted inconsistent with billing guidelines. Usage: At least one other status code is required to identify the inconsistent information.');
	_codeSet.set('733', 'Prefix for entitys contract/member number. Usage: This code requires the use of an Entity Code.');
	_codeSet.set('734', 'Verifying premium payment');
	_codeSet.set('735', 'This service/claim is included in the allowance for another service or claim.');
	_codeSet.set('736', 'A related or qualifying service/claim has not been received/adjudicated.');
	_codeSet.set('737', 'Current Dental Terminology (CDT) Code');
	_codeSet.set('738', 'Home Infusion EDI Coalition (HEIC) Product/Service Code');
	_codeSet.set('739', 'Jurisdiction Specific Procedure or Supply Code');
	_codeSet.set('740', 'Drop-Off Location');
	_codeSet.set('741', 'Entity must be a person. Usage: This code requires use of an Entity Code.');
	_codeSet.set('742', 'Payer Responsibility Sequence Number Code');
	_codeSet.set('743', 'Entitys credential/enrollment information. Usage: This code requires use of an Entity Code.');
	_codeSet.set('744', 'Services/charges related to the treatment of a hospital-acquired condition or preventable medical error.');
	_codeSet.set('745', 'Identifier Qualifier Usage: At least one other status code is required to identify the specific identifier qualifier in error.');
	_codeSet.set('746', 'Duplicate Submission Usage: use only at the information receiver level in the Health Care Claim Acknowledgement transaction.');
	_codeSet.set('747', 'Hospice Employee Indicator');
	_codeSet.set('748', 'Corrected Data Usage: Requires a second status code to identify the corrected data.');
	_codeSet.set('749', 'Date of Injury/Illness');
	_codeSet.set('750', 'Auto Accident State or Province Code');
	_codeSet.set('751', 'Ambulance Pick-up State or Province Code');
	_codeSet.set('752', 'Ambulance Drop-off State or Province Code');
	_codeSet.set('753', 'Co-pay status code.');
	_codeSet.set('754', 'Entity Name Suffix. Usage: This code requires the use of an Entity Code.');
	_codeSet.set('755', 'Entitys primary identifier. Usage: This code requires the use of an Entity Code.');
	_codeSet.set('756', 'Entitys Received Date. Usage: This code requires the use of an Entity Code.');
	_codeSet.set('757', 'Last seen date.');
	_codeSet.set('758', 'Repriced approved HCPCS code.');
	_codeSet.set('759', 'Round trip purpose description.');
	_codeSet.set('760', 'Tooth status code.');
	_codeSet.set('761', 'Entitys referral number. Usage: This code requires the use of an Entity Code.');
	_codeSet.set('762', 'Locum Tenens Provider Identifier. Code must be used with Entity Code 82 - Rendering Provider');
	_codeSet.set('763', 'Ambulance Pickup ZipCode');
	_codeSet.set('764', 'Professional charges are non covered.');
	_codeSet.set('765', 'Institutional charges are non covered.');
	_codeSet.set('766', 'Services were performed during a Health Insurance Exchange (HIX) premium payment grace period.');
	_codeSet.set('767', 'Qualifications for emergent/urgent care');
	_codeSet.set('768', 'Service date outside the accidental injury coverage period.');
	_codeSet.set('769', 'DME Repair or Maintenance');
	_codeSet.set('770', 'Duplicate of a claim processed or in process as a crossover/coordination of benefits claim.');
	_codeSet.set('771', 'Claim submitted prematurely. Please resubmit after crossover/payer to payer COB allotted waiting period.');
	_codeSet.set('772', 'The greatest level of diagnosis code specificity is required.');
	_codeSet.set('773', 'One calendar year per claim.');
	_codeSet.set('774', 'Experimental/Investigational');
	_codeSet.set('775', 'Entity Type Qualifier (Person/Non-Person Entity). Usage: this code requires use of an entity code.');
	_codeSet.set('776', 'Pre/Post-operative care');
	_codeSet.set('777', 'Processed based on multiple or concurrent procedure rules.');
	_codeSet.set('778', 'Non-Compensable incident/event. Usage: To be used for Property and Casualty only.');
	_codeSet.set('779', 'Service submitted for the same/similar service within a set timeframe.');
	_codeSet.set('780', 'Lifetime benefit maximum');
	_codeSet.set('781', 'Claim has been identified as a readmission');
	_codeSet.set('782', 'Second surgical opinion');
	_codeSet.set('783', 'Federal sequestration adjustment');
	_codeSet.set('784', 'Electronic Visit Verification criteria do not match.');
	_codeSet.set('785', 'Missing/Invalid Sterilization/Abortion/Hospital Consent Form.');
	_codeSet.set('786', 'Submit claim to the third party property and casualty automobile insurer.');
	_codeSet.set('787', 'Resubmit a new claim, not a replacement claim.');
	_codeSet.set('788', 'Submit these services to the Pharmacy plan/processor for further consideration/adjudication.');
	_codeSet.set('789', 'Submit these services to the patients Medical Plan for further consideration.');
	_codeSet.set('790', 'Submit these services to the patients Dental Plan for further consideration.');
	_codeSet.set('791', 'Submit these services to the patients Vision Plan for further consideration.');
	_codeSet.set('792', 'Submit these services to the patients Behavioral Health Plan for further consideration.');
	_codeSet.set('793', 'Submit these services to the patients Property and Casualty Plan for further consideration.');
	_codeSet.set('794', 'Claim could not complete adjudication in real time. Resubmit as a batch request.');
	_codeSet.set('795', 'Claim submitted prematurely. Please provide the prior payers final adjudication.');
	_codeSet.set('796', 'Procedure code not valid for date of service.');
	_codeSet.set('797', 'Entitys TRICARE provider id. Usage: This code requires use of an Entity Code.');
	_codeSet.set('798', 'Claim predetermination/estimation could not be completed in real time. Claim requires manual review upon submission. Do not resubmit.');
	_codeSet.set('799', 'Resubmit a replacement claim, not a new claim.');
	_codeSet.set('800', 'Entitys required reporting has been forwarded to the jurisdiction. Usage: This code requires use of an Entity Code. To be used for Property and Casualty only.');
	_codeSet.set('801', 'Entitys required reporting was accepted by the jurisdiction. Usage: This code requires use of an Entity Code. To be used for Property and Casualty only.');
	_codeSet.set('802', 'Entitys required reporting was rejected by the jurisdiction. Usage: This code requires use of an Entity Code. To be used for Property and Casualty only.');
	_codeSet.set('803', 'Provider reporting has been rejected due to non-compliance with the jurisdictions mandated registration. To be used for Property and Casualty only.');
	_codeSet.set('804', 'Exceeds inquiry limit for batch.');
	_codeSet.set('805', 'Mammography Certification Number');
	_codeSet.set('806', 'Residential county does not match the county of the service location.');
	_codeSet.set('807', 'Health Risk Assessment');
	_codeSet.set('808', 'Manifestation diagnosis code cannot be billed as a Principal Diagnosis.');
	return _codeSet;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

const _fnGenerateCodeSetMap_DataElement98 = function () {
	let _codeSet = new Map();
	_codeSet.set('03', 'Dependent');
	_codeSet.set('1P', 'Provider');
	_codeSet.set('1Z', 'Home Health Care');
	_codeSet.set('40', 'Receiver');
	_codeSet.set('41', 'Submitter');
	_codeSet.set('71', 'Attending Physician');
	_codeSet.set('72', 'Operating Physician');
	_codeSet.set('73', 'Other Physician');
	_codeSet.set('77', 'Service Location');
	_codeSet.set('82', 'Rendering Provider');
	_codeSet.set('85', 'Billing Provider');
	_codeSet.set('87', 'Pay-to Provider');
	_codeSet.set('DK', 'Ordering Physician');
	_codeSet.set('DN', 'Referring Provider');
	_codeSet.set('DQ', 'Supervising Physician');
	_codeSet.set('FA', 'Facility');
	_codeSet.set('GB', 'Other Insured');
	_codeSet.set('HK', 'Subscriber');
	_codeSet.set('IL', 'Insured or Subscriber');
	_codeSet.set('LI', 'Independent Lab');
	_codeSet.set('MSC', 'Mammography Screening Center');
	_codeSet.set('PR', 'Payer');
	_codeSet.set('PRP', 'Primary Payer');
	_codeSet.set('QB', 'Purchase Service Provider');
	_codeSet.set('QC', 'Patient');
	_codeSet.set('QD', 'Responsible Party');
	_codeSet.set('SEP', 'Secondary Payer');
	_codeSet.set('TL', 'Testing Laboratory');
	_codeSet.set('TTP', 'Tertiary Payer');
	_codeSet.set('TU', 'Third Party Repricing Organization (TPO)');
	return _codeSet;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

const _fnGenerateCodeSetMap_DataElement1029 = function () {
  let _codeSet = new Map();
  _codeSet.set('1', 'Processed as Primary');
  _codeSet.set('2', 'Processed as Secondary');
  _codeSet.set('3',' Processed as Tertiary'); 
  _codeSet.set('4', 'Denied'); 
  _codeSet.set('19', 'Processed as Primary, Forwarded to Additional Payer(s)'); 
  _codeSet.set('20', 'Processed as Secondary, Forwarded to Additional Payer(s)'); 
  _codeSet.set('21', 'Processed as Tertiary, Forwarded to Additional Payer(s)'); 
  _codeSet.set('22', 'Reversal of Previous Payment');  
  _codeSet.set('23', 'Not Our Claim, Forwarded to Additional Payer(s)');
  return _codeSet;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

const _fnGenerateCodeSetMap_CodeSource139Carc = function () {
	let _codeSet = new Map();
	_codeSet.set('1', 'Deductible Amount');
	_codeSet.set('2', 'Coinsurance Amount');
	_codeSet.set('3', 'Co-payment Amount');
	_codeSet.set('4', 'The procedure code is inconsistent with the modifier used. Usage: Refer to the 835 Healthcare Policy Identification Segment (loop 2110 Service Payment Information REF), if present.');
	_codeSet.set('5', 'The procedure code/type of bill is inconsistent with the place of service. Usage: Refer to the 835 Healthcare Policy Identification Segment (loop 2110 Service Payment Information REF), if present.');
	_codeSet.set('6', 'The procedure/revenue code is inconsistent with the patients age. Usage: Refer to the 835 Healthcare Policy Identification Segment (loop 2110 Service Payment Information REF), if present.');
	_codeSet.set('7', 'The procedure/revenue code is inconsistent with the patients gender. Usage: Refer to the 835 Healthcare Policy Identification Segment (loop 2110 Service Payment Information REF), if present.');
	_codeSet.set('8', 'The procedure code is inconsistent with the provider type/specialty (taxonomy). Usage: Refer to the 835 Healthcare Policy Identification Segment (loop 2110 Service Payment Information REF), if present.');
	_codeSet.set('9', 'The diagnosis is inconsistent with the patients age. Usage: Refer to the 835 Healthcare Policy Identification Segment (loop 2110 Service Payment Information REF), if present.');
	_codeSet.set('10', 'The diagnosis is inconsistent with the patients gender. Usage: Refer to the 835 Healthcare Policy Identification Segment (loop 2110 Service Payment Information REF), if present.');
	_codeSet.set('11', 'The diagnosis is inconsistent with the procedure. Usage: Refer to the 835 Healthcare Policy Identification Segment (loop 2110 Service Payment Information REF), if present.');
	_codeSet.set('12', 'The diagnosis is inconsistent with the provider type. Usage: Refer to the 835 Healthcare Policy Identification Segment (loop 2110 Service Payment Information REF), if present.');
	_codeSet.set('13', 'The date of death precedes the date of service.');
	_codeSet.set('14', 'The date of birth follows the date of service.');
	_codeSet.set('15', 'The authorization number is missing, invalid, or does not apply to the billed services or provider.');
	_codeSet.set('16', 'Claim/service lacks information or has submission/billing error(s). Usage: Do not use this code for claims attachment(s)/other documentation. At least one Remark Code must be provided (may be comprised of either the NCPDP Reject Reason Code, or Remittance Advice Remark Code that is not an ALERT.) Refer to the 835 Healthcare Policy Identification Segment (loop 2110 Service Payment Information REF), if present.');
	_codeSet.set('17', 'Requested information was not provided or was insufficient/incomplete. At least one Remark Code must be provided (may be comprised of either the Remittance Advice Remark Code or NCPDP Reject Reason Code.)');
	_codeSet.set('18', 'Exact duplicate claim/service (Use only with Group Code OA except where state workers compensation regulations requires CO)');
	_codeSet.set('19', 'This is a work-related injury/illness and thus the liability of the Workers Compensation Carrier.');
	_codeSet.set('20', 'This injury/illness is covered by the liability carrier.');
	_codeSet.set('21', 'This injury/illness is the liability of the no-fault carrier.');
	_codeSet.set('22', 'This care may be covered by another payer per coordination of benefits.');
	_codeSet.set('23', 'The impact of prior payer(s) adjudication including payments and/or adjustments. (Use only with Group Code OA)');
	_codeSet.set('24', 'Charges are covered under a capitation agreement/managed care plan.');
	_codeSet.set('25', 'Payment denied. Your Stop loss deductible has not been met.');
	_codeSet.set('26', 'Expenses incurred prior to coverage.');
	_codeSet.set('27', 'Expenses incurred after coverage terminated.');
	_codeSet.set('28', 'Coverage not in effect at the time the service was provided.');
	_codeSet.set('29', 'The time limit for filing has expired.');
	_codeSet.set('30', 'Payment adjusted because the patient has not met the required eligibility, spend down, waiting, or residency requirements.');
	_codeSet.set('31', 'Patient cannot be identified as our insured.');
	_codeSet.set('32', 'Our records indicate the patient is not an eligible dependent.');
	_codeSet.set('33', 'Insured has no dependent coverage.');
	_codeSet.set('34', 'Insured has no coverage for newborns.');
	_codeSet.set('35', 'Lifetime benefit maximum has been reached.');
	_codeSet.set('36', 'Balance does not exceed co-payment amount.');
	_codeSet.set('37', 'Balance does not exceed deductible.');
	_codeSet.set('38', 'Services not provided or authorized by designated (network/primary care) providers.');
	_codeSet.set('39', 'Services denied at the time authorization/pre-certification was requested.');
	_codeSet.set('40', 'Charges do not meet qualifications for emergent/urgent care. Usage: Refer to the 835 Healthcare Policy Identification Segment (loop 2110 Service Payment Information REF), if present.');
	_codeSet.set('41', 'Discount agreed to in Preferred Provider contract.');
	_codeSet.set('42', 'Charges exceed our fee schedule or maximum allowable amount. (Use CARC 45)');
	_codeSet.set('43', 'Gramm-Rudman reduction.');
	_codeSet.set('44', 'Prompt-pay discount.');
	_codeSet.set('45', 'Charge exceeds fee schedule/maximum allowable or contracted/legislated fee arrangement. Usage: This adjustment amount cannot equal the total service or claim charge amount; and must not duplicate provider adjustment amounts (payments and contractual reductions) that have resulted from prior payer(s) adjudication. (Use only with Group Codes PR or CO depending upon liability)');
	_codeSet.set('46', 'This (these) service(s) is (are) not covered.');
	_codeSet.set('47', 'This (these) diagnosis(es) is (are) not covered, missing, or are invalid.');
	_codeSet.set('48', 'This (these) procedure(s) is (are) not covered.');
	_codeSet.set('49', 'This is a non-covered service because it is a routine/preventive exam or a diagnostic/screening procedure done in conjunction with a routine/preventive exam. Usage: Refer to the 835 Healthcare Policy Identification Segment (loop 2110 Service Payment Information REF), if present.');
	_codeSet.set('50', 'These are non-covered services because this is not deemed a medical necessity by the payer. Usage: Refer to the 835 Healthcare Policy Identification Segment (loop 2110 Service Payment Information REF), if present.');
	_codeSet.set('51', 'These are non-covered services because this is a pre-existing condition. Usage: Refer to the 835 Healthcare Policy Identification Segment (loop 2110 Service Payment Information REF), if present.');
	_codeSet.set('52', 'The referring/prescribing/rendering provider is not eligible to refer/prescribe/order/perform the service billed.');
	_codeSet.set('53', 'Services by an immediate relative or a member of the same household are not covered.');
	_codeSet.set('54', 'Multiple physicians/assistants are not covered in this case. Usage: Refer to the 835 Healthcare Policy Identification Segment (loop 2110 Service Payment Information REF), if present.');
	_codeSet.set('55', 'Procedure/treatment/drug is deemed experimental/investigational by the payer. Usage: Refer to the 835 Healthcare Policy Identification Segment (loop 2110 Service Payment Information REF), if present.');
	_codeSet.set('56', 'Procedure/treatment has not been deemed proven to be effective by the payer. Usage: Refer to the 835 Healthcare Policy Identification Segment (loop 2110 Service Payment Information REF), if present.');
	_codeSet.set('57', 'Payment denied/reduced because the payer deems the information submitted does not support this level of service, this many services, this length of service, this dosage, or this days supply.');
	_codeSet.set('58', 'Treatment was deemed by the payer to have been rendered in an inappropriate or invalid place of service. Usage: Refer to the 835 Healthcare Policy Identification Segment (loop 2110 Service Payment Information REF), if present.');
	_codeSet.set('59', 'Processed based on multiple or concurrent procedure rules. (For example multiple surgery or diagnostic imaging, concurrent anesthesia.) Usage: Refer to the 835 Healthcare Policy Identification Segment (loop 2110 Service Payment Information REF), if present.');
	_codeSet.set('60', 'Charges for outpatient services are not covered when performed within a period of time prior to or after inpatient services.');
	_codeSet.set('61', 'Adjusted for failure to obtain second surgical opinion');
	_codeSet.set('62', 'Payment denied/reduced for absence of, or exceeded, pre-certification/authorization.');
	_codeSet.set('63', 'Correction to a prior claim.');
	_codeSet.set('64', 'Denial reversed per Medical Review.');
	_codeSet.set('65', 'Procedure code was incorrect. This payment reflects the correct code.');
	_codeSet.set('66', 'Blood Deductible.');
	_codeSet.set('67', 'Lifetime reserve days. (Handled in QTY, QTY01=LA)');
	_codeSet.set('68', 'DRG weight. (Handled in CLP12)');
	_codeSet.set('69', 'Day outlier amount.');
	_codeSet.set('70', 'Cost outlier - Adjustment to compensate for additional costs.');
	_codeSet.set('71', 'Primary Payer amount.');
	_codeSet.set('72', 'Coinsurance day. (Handled in QTY, QTY01=CD)');
	_codeSet.set('73', 'Administrative days.');
	_codeSet.set('74', 'Indirect Medical Education Adjustment.');
	_codeSet.set('75', 'Direct Medical Education Adjustment.');
	_codeSet.set('76', 'Disproportionate Share Adjustment.');
	_codeSet.set('77', 'Covered days. (Handled in QTY, QTY01=CA)');
	_codeSet.set('78', 'Non-Covered days/Room charge adjustment.');
	_codeSet.set('79', 'Cost Report days. (Handled in MIA15)');
	_codeSet.set('80', 'Outlier days. (Handled in QTY, QTY01=OU)');
	_codeSet.set('81', 'Discharges.');
	_codeSet.set('82', 'PIP days.');
	_codeSet.set('83', 'Total visits.');
	_codeSet.set('84', 'Capital Adjustment. (Handled in MIA)');
	_codeSet.set('85', 'Patient Interest Adjustment (Use Only Group code PR)');
	_codeSet.set('86', 'Statutory Adjustment.');
	_codeSet.set('87', 'Transfer amount.');
	_codeSet.set('88', 'Adjustment amount represents collection against receivable created in prior overpayment.');
	_codeSet.set('89', 'Professional fees removed from charges.');
	_codeSet.set('90', 'Ingredient cost adjustment. Usage: To be used for pharmaceuticals only.');
	_codeSet.set('91', 'Dispensing fee adjustment.');
	_codeSet.set('92', 'Claim Paid in full.');
	_codeSet.set('93', 'No Claim level Adjustments.');
	_codeSet.set('94', 'Processed in Excess of charges.');
	_codeSet.set('95', 'Plan procedures not followed.');
	_codeSet.set('96', 'Non-covered charge(s). At least one Remark Code must be provided (may be comprised of either the NCPDP Reject Reason Code, or Remittance Advice Remark Code that is not an ALERT.) Usage: Refer to the 835 Healthcare Policy Identification Segment (loop 2110 Service Payment Information REF), if present.');
	_codeSet.set('97', 'The benefit for this service is included in the payment/allowance for another service/procedure that has already been adjudicated. Usage: Refer to the 835 Healthcare Policy Identification Segment (loop 2110 Service Payment Information REF), if present.');
	_codeSet.set('98', 'The hospital must file the Medicare claim for this inpatient non-physician service.');
	_codeSet.set('99', 'Medicare Secondary Payer Adjustment Amount.');
	_codeSet.set('100', 'Payment made to patient/insured/responsible party.');
	_codeSet.set('101', 'Predetermination: anticipated payment upon completion of services or claim adjudication.');
	_codeSet.set('102', 'Major Medical Adjustment.');
	_codeSet.set('103', 'Provider promotional discount (e.g., Senior citizen discount).');
	_codeSet.set('104', 'Managed care withholding.');
	_codeSet.set('105', 'Tax withholding.');
	_codeSet.set('106', 'Patient payment option/election not in effect.');
	_codeSet.set('107', 'The related or qualifying claim/service was not identified on this claim. Usage: Refer to the 835 Healthcare Policy Identification Segment (loop 2110 Service Payment Information REF), if present.');
	_codeSet.set('108', 'Rent/purchase guidelines were not met. Usage: Refer to the 835 Healthcare Policy Identification Segment (loop 2110 Service Payment Information REF), if present.');
	_codeSet.set('109', 'Claim/service not covered by this payer/contractor. You must send the claim/service to the correct payer/contractor.');
	_codeSet.set('110', 'Billing date predates service date.');
	_codeSet.set('111', 'Not covered unless the provider accepts assignment.');
	_codeSet.set('112', 'Service not furnished directly to the patient and/or not documented.');
	_codeSet.set('113', 'Payment denied because service/procedure was provided outside the United States or as a result of war.');
	_codeSet.set('114', 'Procedure/product not approved by the Food and Drug Administration.');
	_codeSet.set('115', 'Procedure postponed, canceled, or delayed.');
	_codeSet.set('116', 'The advance indemnification notice signed by the patient did not comply with requirements.');
	_codeSet.set('117', 'Transportation is only covered to the closest facility that can provide the necessary care.');
	_codeSet.set('118', 'ESRD network support adjustment.');
	_codeSet.set('119', 'Benefit maximum for this time period or occurrence has been reached.');
	_codeSet.set('120', 'Patient is covered by a managed care plan.');
	_codeSet.set('121', 'Indemnification adjustment - compensation for outstanding member responsibility.');
	_codeSet.set('122', 'Psychiatric reduction.');
	_codeSet.set('123', 'Payer refund due to overpayment.');
	_codeSet.set('124', 'Payer refund amount - not our patient.');
	_codeSet.set('125', 'Submission/billing error(s). At least one Remark Code must be provided (may be comprised of either the NCPDP Reject Reason Code, or Remittance Advice Remark Code that is not an ALERT.)');
	_codeSet.set('126', 'Deductible -- Major Medical');
	_codeSet.set('127', 'Coinsurance -- Major Medical');
	_codeSet.set('128', 'Newborns services are covered in the mothers Allowance.');
	_codeSet.set('129', 'Prior processing information appears incorrect. At least one Remark Code must be provided (may be comprised of either the NCPDP Reject Reason Code, or Remittance Advice Remark Code that is not an ALERT.)');
	_codeSet.set('130', 'Claim submission fee.');
	_codeSet.set('131', 'Claim specific negotiated discount.');
	_codeSet.set('132', 'Prearranged demonstration project adjustment.');
	_codeSet.set('133', 'The disposition of this service line is pending further review. (Use only with Group Code OA). Usage: Use of this code requires a reversal and correction when the service line is finalized (use only in Loop 2110 CAS segment of the 835 or Loop 2430 of the 837).');
	_codeSet.set('134', 'Technical fees removed from charges.');
	_codeSet.set('135', 'Interim bills cannot be processed.');
	_codeSet.set('136', 'Failure to follow prior payers coverage rules. (Use only with Group Code OA)');
	_codeSet.set('137', 'Regulatory Surcharges, Assessments, Allowances or Health Related Taxes.');
	_codeSet.set('138', 'Appeal procedures not followed or time limits not met.');
	_codeSet.set('139', 'Contracted funding agreement - Subscriber is employed by the provider of services. Use only with Group Code CO.');
	_codeSet.set('140', 'Patient/Insured health identification number and name do not match.');
	_codeSet.set('141', 'Claim spans eligible and ineligible periods of coverage.');
	_codeSet.set('142', 'Monthly Medicaid patient liability amount.');
	_codeSet.set('143', 'Portion of payment deferred.');
	_codeSet.set('144', 'Incentive adjustment, e.g. preferred product/service.');
	_codeSet.set('145', 'Premium payment withholding');
	_codeSet.set('146', 'Diagnosis was invalid for the date(s) of service reported.');
	_codeSet.set('147', 'Provider contracted/negotiated rate expired or not on file.');
	_codeSet.set('148', 'Information from another provider was not provided or was insufficient/incomplete. At least one Remark Code must be provided (may be comprised of either the NCPDP Reject Reason Code, or Remittance Advice Remark Code that is not an ALERT.)');
	_codeSet.set('149', 'Lifetime benefit maximum has been reached for this service/benefit category.');
	_codeSet.set('150', 'Payer deems the information submitted does not support this level of service.');
	_codeSet.set('151', 'Payment adjusted because the payer deems the information submitted does not support this many/frequency of services.');
	_codeSet.set('152', 'Payer deems the information submitted does not support this length of service. Usage: Refer to the 835 Healthcare Policy Identification Segment (loop 2110 Service Payment Information REF), if present.');
	_codeSet.set('153', 'Payer deems the information submitted does not support this dosage.');
	_codeSet.set('154', 'Payer deems the information submitted does not support this days supply.');
	_codeSet.set('155', 'Patient refused the service/procedure.');
	_codeSet.set('156', 'Flexible spending account payments. Note: Use code 187.');
	_codeSet.set('157', 'Service/procedure was provided as a result of an act of war.');
	_codeSet.set('158', 'Service/procedure was provided outside of the United States.');
	_codeSet.set('159', 'Service/procedure was provided as a result of terrorism.');
	_codeSet.set('160', 'Injury/illness was the result of an activity that is a benefit exclusion.');
	_codeSet.set('161', 'Provider performance bonus');
	_codeSet.set('162', 'State-mandated Requirement for Property and Casualty, see Claim Payment Remarks Code for specific explanation.');
	_codeSet.set('163', 'Attachment/other documentation referenced on the claim was not received.');
	_codeSet.set('164', 'Attachment/other documentation referenced on the claim was not received in a timely fashion.');
	_codeSet.set('165', 'Referral absent or exceeded.');
	_codeSet.set('166', 'These services were submitted after this payers responsibility for processing claims under this plan ended.');
	_codeSet.set('167', 'This (these) diagnosis(es) is (are) not covered. Usage: Refer to the 835 Healthcare Policy Identification Segment (loop 2110 Service Payment Information REF), if present.');
	_codeSet.set('168', 'Service(s) have been considered under the patients medical plan. Benefits are not available under this dental plan.');
	_codeSet.set('169', 'Alternate benefit has been provided.');
	_codeSet.set('170', 'Payment is denied when performed/billed by this type of provider. Usage: Refer to the 835 Healthcare Policy Identification Segment (loop 2110 Service Payment Information REF), if present.');
	_codeSet.set('171', 'Payment is denied when performed/billed by this type of provider in this type of facility. Usage: Refer to the 835 Healthcare Policy Identification Segment (loop 2110 Service Payment Information REF), if present.');
	_codeSet.set('172', 'Payment is adjusted when performed/billed by a provider of this specialty. Usage: Refer to the 835 Healthcare Policy Identification Segment (loop 2110 Service Payment Information REF), if present.');
	_codeSet.set('173', 'Service/equipment was not prescribed by a physician.');
	_codeSet.set('174', 'Service was not prescribed prior to delivery.');
	_codeSet.set('175', 'Prescription is incomplete.');
	_codeSet.set('176', 'Prescription is not current.');
	_codeSet.set('177', 'Patient has not met the required eligibility requirements.');
	_codeSet.set('178', 'Patient has not met the required spend down requirements.');
	_codeSet.set('179', 'Patient has not met the required waiting requirements. Usage: Refer to the 835 Healthcare Policy Identification Segment (loop 2110 Service Payment Information REF), if present.');
	_codeSet.set('180', 'Patient has not met the required residency requirements.');
	_codeSet.set('181', 'Procedure code was invalid on the date of service.');
	_codeSet.set('182', 'Procedure modifier was invalid on the date of service.');
	_codeSet.set('183', 'The referring provider is not eligible to refer the service billed. Usage: Refer to the 835 Healthcare Policy Identification Segment (loop 2110 Service Payment Information REF), if present.');
	_codeSet.set('184', 'The prescribing/ordering provider is not eligible to prescribe/order the service billed. Usage: Refer to the 835 Healthcare Policy Identification Segment (loop 2110 Service Payment Information REF), if present.');
	_codeSet.set('185', 'The rendering provider is not eligible to perform the service billed. Usage: Refer to the 835 Healthcare Policy Identification Segment (loop 2110 Service Payment Information REF), if present.');
	_codeSet.set('186', 'Level of care change adjustment.');
	_codeSet.set('187', 'Consumer Spending Account payments (includes but is not limited to Flexible Spending Account, Health Savings Account, Health Reimbursement Account, etc.)');
	_codeSet.set('188', 'This product/procedure is only covered when used according to FDA recommendations.');
	_codeSet.set('189', 'Not otherwise classified or unlisted procedure code (CPT/HCPCS) was billed when there is a specific procedure code for this procedure/service');
	_codeSet.set('190', 'Payment is included in the allowance for a Skilled Nursing Facility (SNF) qualified stay.');
	_codeSet.set('191', 'Not a work related injury/illness and thus not the liability of the workers compensation carrier Note: If adjustment is at the Claim Level, the payer must send and the provider should refer to the 835 Insurance Policy Number Segment (Loop 2100 Other Claim Related Information REF qualifier IG) for the jurisdictional regulation. If adjustment is at the Line Level, the payer must send and the provider should refer to the 835 Healthcare Policy Identification Segment (loop 2110 Service Payment information REF)');
	_codeSet.set('192', 'Non standard adjustment code from paper remittance. Usage: This code is to be used by providers/payers providing Coordination of Benefits information to another payer in the 837 transaction only. This code is only used when the non-standard code cannot be reasonably mapped to an existing Claims Adjustment Reason Code, specifically Deductible, Coinsurance and Co-payment.');
	_codeSet.set('193', 'Original payment decision is being maintained. Upon review, it was determined that this claim was processed properly.');
	_codeSet.set('194', 'Anesthesia performed by the operating physician, the assistant surgeon or the attending physician.');
	_codeSet.set('195', 'Refund issued to an erroneous priority payer for this claim/service.');
	_codeSet.set('196', 'Claim/service denied based on prior payers coverage determination.');
	_codeSet.set('197', 'Precertification/authorization/notification/pre-treatment absent.');
	_codeSet.set('198', 'Precertification/notification/authorization/pre-treatment exceeded.');
	_codeSet.set('199', 'Revenue code and Procedure code do not match.');
	_codeSet.set('200', 'Expenses incurred during lapse in coverage');
	_codeSet.set('201', 'Patient is responsible for amount of this claim/service through set aside arrangement or other agreement. (Use only with Group Code PR)  At least one Remark Code must be provided (may be comprised of either the NCPDP Reject Reason Code, or Remittance Advice Remark Code that is not an ALERT.)');
	_codeSet.set('202', 'Non-covered personal comfort or convenience services.');
	_codeSet.set('203', 'Discontinued or reduced service.');
	_codeSet.set('204', 'This service/equipment/drug is not covered under the patients current benefit plan');
	_codeSet.set('205', 'Pharmacy discount card processing fee');
	_codeSet.set('206', 'National Provider Identifier - missing.');
	_codeSet.set('207', 'National Provider identifier - Invalid format');
	_codeSet.set('208', 'National Provider Identifier - Not matched.');
	_codeSet.set('209', 'Per regulatory or other agreement. The provider cannot collect this amount from the patient. However, this amount may be billed to subsequent payer. Refund to patient if collected. (Use only with Group code OA)');
	_codeSet.set('210', 'Payment adjusted because pre-certification/authorization not received in a timely fashion');
	_codeSet.set('211', 'National Drug Codes (NDC) not eligible for rebate, are not covered.');
	_codeSet.set('212', 'Administrative surcharges are not covered');
	_codeSet.set('213', 'Non-compliance with the physician self referral prohibition legislation or payer policy.');
	_codeSet.set('214', 'Workers Compensation claim adjudicated as non-compensable. This Payer not liable for claim or service/treatment. Note: If adjustment is at the Claim Level, the payer must send and the provider should refer to the 835 Insurance Policy Number Segment (Loop 2100 Other Claim Related Information REF qualifier IG) for the jurisdictional regulation. If adjustment is at the Line Level, the payer must send and the provider should refer to the 835 Healthcare Policy Identification Segment (loop 2110 Service Payment information REF). To be used for Workers Compensation only');
	_codeSet.set('215', 'Based on subrogation of a third party settlement');
	_codeSet.set('216', 'Based on the findings of a review organization or the payers findings.');
	_codeSet.set('217', 'Based on payer reasonable and customary fees. No maximum allowable defined by legislated fee arrangement. (Note: To be used for Property and Casualty only)');
	_codeSet.set('218', 'Based on entitlement to benefits. Note: If adjustment is at the Claim Level, the payer must send and the provider should refer to the 835 Insurance Policy Number Segment (Loop 2100 Other Claim Related Information REF qualifier IG) for the jurisdictional regulation. If adjustment is at the Line Level, the payer must send and the provider should refer to the 835 Healthcare Policy Identification Segment (loop 2110 Service Payment information REF). To be used for Workers Compensation only');
	_codeSet.set('219', 'Based on extent of injury. Usage: If adjustment is at the Claim Level, the payer must send and the provider should refer to the 835 Insurance Policy Number Segment (Loop 2100 Other Claim Related Information REF qualifier IG) for the jurisdictional regulation. If adjustment is at the Line Level, the payer must send and the provider should refer to the 835 Healthcare Policy Identification Segment (loop 2110 Service Payment information REF).');
	_codeSet.set('220', 'The applicable fee schedule/fee database does not contain the billed code. Please resubmit a bill with the appropriate fee schedule/fee database code(s) that best describe the service(s) provided and supporting documentation if required. (Note: To be used for Property and Casualty only)');
	_codeSet.set('221', 'Claim is under investigation. Note: If adjustment is at the Claim Level, the payer must send and the provider should refer to the 835 Insurance Policy Number Segment (Loop 2100 Other Claim Related Information REF qualifier IG) for the jurisdictional regulation. If adjustment is at the Line Level, the payer must send and the provider should refer to the 835 Healthcare Policy Identification Segment (loop 2110 Service Payment information REF). (Note: To be used by Property & Casualty only)');
	_codeSet.set('222', 'Exceeds the contracted maximum number of hours/days/units by this provider for this period. This is not patient specific. Usage: Refer to the 835 Healthcare Policy Identification Segment (loop 2110 Service Payment Information REF), if present.');
	_codeSet.set('223', 'Adjustment code for mandated federal, state or local law/regulation that is not already covered by another code and is mandated before a new code can be created.');
	_codeSet.set('224', 'Patient identification compromised by identity theft. Identity verification required for processing this and future claims.');
	_codeSet.set('225', 'Penalty or Interest Payment by Payer (Only used for plan to plan encounter reporting within the 837)');
	_codeSet.set('226', 'Information requested from the Billing/Rendering Provider was not provided or not provided timely or was insufficient/incomplete. At least one Remark Code must be provided (may be comprised of either the NCPDP Reject Reason Code, or Remittance Advice Remark Code that is not an ALERT.)');
	_codeSet.set('227', 'Information requested from the patient/insured/responsible party was not provided or was insufficient/incomplete. At least one Remark Code must be provided (may be comprised of either the NCPDP Reject Reason Code, or Remittance Advice Remark Code that is not an ALERT.)');
	_codeSet.set('228', 'Denied for failure of this provider, another provider or the subscriber to supply requested information to a previous payer for their adjudication');
	_codeSet.set('229', 'Partial charge amount not considered by Medicare due to the initial claim Type of Bill being 12X. Usage: This code can only be used in the 837 transaction to convey Coordination of Benefits information when the secondary payers cost avoidance policy allows providers to bypass claim submission to a prior payer. (Use only with Group Code PR)');
	_codeSet.set('230', 'No available or correlating CPT/HCPCS code to describe this service. Note: Used only by Property and Casualty.');
	_codeSet.set('231', 'Mutually exclusive procedures cannot be done in the same day/setting. Usage: Refer to the 835 Healthcare Policy Identification Segment (loop 2110 Service Payment Information REF), if present.');
	_codeSet.set('232', 'Institutional Transfer Amount. Usage: Applies to institutional claims only and explains the DRG amount difference when the patient care crosses multiple institutions.');
	_codeSet.set('233', 'Services/charges related to the treatment of a hospital-acquired condition or preventable medical error.');
	_codeSet.set('234', 'This procedure is not paid separately. At least one Remark Code must be provided (may be comprised of either the NCPDP Reject Reason Code, or Remittance Advice Remark Code that is not an ALERT.)');
	_codeSet.set('235', 'Sales Tax');
	_codeSet.set('236', 'This procedure or procedure/modifier combination is not compatible with another procedure or procedure/modifier combination provided on the same day according to the National Correct Coding Initiative or workers compensation state regulations/ fee schedule requirements.');
	_codeSet.set('237', 'Legislated/Regulatory Penalty. At least one Remark Code must be provided (may be comprised of either the NCPDP Reject Reason Code, or Remittance Advice Remark Code that is not an ALERT.)');
	_codeSet.set('238', 'Claim spans eligible and ineligible periods of coverage, this is the reduction for the ineligible period. (Use only with Group Code PR)');
	_codeSet.set('239', 'Claim spans eligible and ineligible periods of coverage. Rebill separate claims.');
	_codeSet.set('240', 'The diagnosis is inconsistent with the patients birth weight. Usage: Refer to the 835 Healthcare Policy Identification Segment (loop 2110 Service Payment Information REF), if present.');
	_codeSet.set('241', 'Low Income Subsidy (LIS) Co-payment Amount');
	_codeSet.set('242', 'Services not provided by network/primary care providers.');
	_codeSet.set('243', 'Services not authorized by network/primary care providers.');
	_codeSet.set('244', 'Payment reduced to zero due to litigation. Additional information will be sent following the conclusion of litigation. To be used for Property & Casualty only.');
	_codeSet.set('245', 'Provider performance program withhold.');
	_codeSet.set('246', 'This non-payable code is for required reporting only.');
	_codeSet.set('247', 'Deductible for Professional service rendered in an Institutional setting and billed on an Institutional claim.');
	_codeSet.set('248', 'Coinsurance for Professional service rendered in an Institutional setting and billed on an Institutional claim.');
	_codeSet.set('249', 'This claim has been identified as a readmission. (Use only with Group Code CO)');
	_codeSet.set('250', 'The attachment/other documentation that was received was the incorrect attachment/document. The expected attachment/document is still missing. At least one Remark Code must be provided (may be comprised of either the NCPDP Reject Reason Code, or Remittance Advice Remark Code that is not an ALERT).');
	_codeSet.set('251', 'The attachment/other documentation that was received was incomplete or deficient. The necessary information is still needed to process the claim. At least one Remark Code must be provided (may be comprised of either the NCPDP Reject Reason Code, or Remittance Advice Remark Code that is not an ALERT).');
	_codeSet.set('252', 'An attachment/other documentation is required to adjudicate this claim/service. At least one Remark Code must be provided (may be comprised of either the NCPDP Reject Reason Code, or Remittance Advice Remark Code that is not an ALERT).');
	_codeSet.set('253', 'Sequestration - reduction in federal payment');
	_codeSet.set('254', 'Claim received by the dental plan, but benefits not available under this plan.  Submit these services to the patients medical plan for further consideration.');
	_codeSet.set('255', 'The disposition of the related Property & Casualty claim (injury or illness) is pending due to litigation. (Use only with Group Code OA)');
	_codeSet.set('256', 'Service not payable per managed care contract.');
	_codeSet.set('257', 'The disposition of the claim/service is undetermined during the premium payment grace period, per Health Insurance Exchange requirements. This claim/service will be reversed and corrected when the grace period ends (due to premium payment or lack of premium payment). (Use only with Group Code OA)');
	_codeSet.set('258', 'Claim/service not covered when patient is in custody/incarcerated. Applicable federal, state or local authority may cover the claim/service.');
	_codeSet.set('259', 'Additional payment for Dental/Vision service utilization.');
	_codeSet.set('260', 'Processed under Medicaid ACA Enhanced Fee Schedule');
	_codeSet.set('261', 'The procedure or service is inconsistent with the patients history.');
	_codeSet.set('262', 'Adjustment for delivery cost. Usage: To be used for pharmaceuticals only.');
	_codeSet.set('263', 'Adjustment for shipping cost. Usage: To be used for pharmaceuticals only.');
	_codeSet.set('264', 'Adjustment for postage cost. Usage: To be used for pharmaceuticals only.');
	_codeSet.set('265', 'Adjustment for administrative cost. Usage: To be used for pharmaceuticals only.');
	_codeSet.set('266', 'Adjustment for compound preparation cost. Usage: To be used for pharmaceuticals only.');
	_codeSet.set('267', 'Claim/service spans multiple months. At least one Remark Code must be provided (may be comprised of either the NCPDP Reject Reason Code, or Remittance Advice Remark Code that is not an ALERT.)');
	_codeSet.set('268', 'The Claim spans two calendar years. Please resubmit one claim per calendar year.');
	_codeSet.set('269', 'Anesthesia not covered for this service/procedure. Usage: Refer to the 835 Healthcare Policy Identification Segment (loop 2110 Service Payment Information REF), if present.');
	_codeSet.set('270', 'Claim received by the medical plan, but benefits not available under this plan. Submit these services to the patients dental plan for further consideration.');
	_codeSet.set('271', 'Prior contractual reductions related to a current periodic payment as part of a contractual payment schedule when deferred amounts have been previously reported. (Use only with Group Code OA)');
	_codeSet.set('272', 'Coverage/program guidelines were not met.');
	_codeSet.set('273', 'Coverage/program guidelines were exceeded.');
	_codeSet.set('274', 'Fee/Service not payable per patient Care Coordination arrangement.');
	_codeSet.set('275', 'Prior payers (or payers) patient responsibility (deductible, coinsurance, co-payment) not covered. (Use only with Group Code PR)');
	_codeSet.set('276', 'Services denied by the prior payer(s) are not covered by this payer.');
	_codeSet.set('277', 'The disposition of the claim/service is undetermined during the premium payment grace period, per Health Insurance SHOP Exchange requirements. This claim/service will be reversed and corrected when the grace period ends (due to premium payment or lack of premium payment). (Use only with Group Code OA)');
	_codeSet.set('278', 'Performance program proficiency requirements not met. (Use only with Group Codes CO or PI) Usage: Refer to the 835 Healthcare Policy Identification Segment (loop 2110 Service Payment Information REF), if present.');
	_codeSet.set('279', 'Services not provided by Preferred network providers. Usage: Use this code when there are member network limitations. For example, using contracted providers not in the members narrow network.');
	_codeSet.set('280', 'Claim received by the medical plan, but benefits not available under this plan. Submit these services to the patients Pharmacy plan for further consideration.');
	_codeSet.set('281', 'Deductible waived per contractual agreement. Use only with Group Code CO.');
	_codeSet.set('282', 'The procedure/revenue code is inconsistent with the type of bill. Usage: Refer to the 835 Healthcare Policy Identification Segment (loop 2110 Service Payment Information REF), if present.');
	_codeSet.set('283', 'Attending provider is not eligible to provide direction of care.');
	_codeSet.set('284', 'Precertification/authorization/notification/pre-treatment number may be valid but does not apply to the billed services.');
	_codeSet.set('285', 'Appeal procedures not followed');
	_codeSet.set('286', 'Appeal time limits not met');
	_codeSet.set('287', 'Referral exceeded');
	_codeSet.set('288', 'Referral absent');
	_codeSet.set('289', 'Services considered under the dental and medical plans, benefits not available.');
	_codeSet.set('290', 'Claim received by the dental plan, but benefits not available under this plan. Claim has been forwarded to the patients medical plan for further consideration.');
	_codeSet.set('291', 'Claim received by the medical plan, but benefits not available under this plan. Claim has been forwarded to the patients dental plan for further consideration.');
	_codeSet.set('292', 'Claim received by the medical plan, but benefits not available under this plan. Claim has been forwarded to the patients pharmacy plan for further consideration.');
	_codeSet.set('293', 'Payment made to employer.');
	_codeSet.set('294', 'Payment made to attorney.');
	_codeSet.set('295', 'Pharmacy Direct/Indirect Remuneration (DIR)');
	_codeSet.set('296', 'Precertification/authorization/notification/pre-treatment number may be valid but does not apply to the provider.');
	_codeSet.set('297', 'Claim received by the medical plan, but benefits not available under this plan. Submit these services to the patients vision plan for further consideration.');
	_codeSet.set('298', 'Claim received by the medical plan, but benefits not available under this plan. Claim has been forwarded to the patients vision plan for further consideration.');
	_codeSet.set('299', 'The billing provider is not eligible to receive payment for the service billed.');
	_codeSet.set('300', 'Claim received by the Medical Plan, but benefits not available under this plan. Claim has been forwarded to the patients Behavioral Health Plan for further consideration.');
	_codeSet.set('301', 'Claim received by the Medical Plan, but benefits not available under this plan. Submit these services to the patients Behavioral Health Plan for further consideration.');
	_codeSet.set('302', 'Precertification/notification/authorization/pre-treatment time limit has expired.');
	_codeSet.set('303', 'Prior payers (or payers) patient responsibility (deductible, coinsurance, co-payment) not covered for Qualified Medicare and Medicaid Beneficiaries. (Use only with Group Code CO)');
	_codeSet.set('304', 'Claim received by the medical plan, but benefits not available under this plan. Submit these services to the patients hearing plan for further consideration.');
	_codeSet.set('305', 'Claim received by the medical plan, but benefits not available under this plan. Claim has been forwarded to the patients hearing plan for further consideration.');
	_codeSet.set('306', 'Type of bill is inconsistent with the patient status. Usage: Refer to the 835 Healthcare Policy Identification Segment (loop 2110 Service Payment Information REF), if present.');
	_codeSet.set('307', 'Medicare Maximum Fair Price Standard Default Refund Amount Adjustment. At least one Remark Code must be provided (may be comprised of either the NCPDP Reject Reason Code, or Remittance Advice Remark Code that is not an ALERT.) Usage: To be used only for the Medicare Drug Price Negotiation Program.');
	_codeSet.set('308', 'Payment is adjusted due to contracted funding agreement between the payer and provider.');
	_codeSet.set('A0', 'Patient refund amount.');
	_codeSet.set('A1', 'Claim/Service denied. At least one Remark Code must be provided (may be comprised of either the NCPDP Reject Reason Code, or Remittance Advice Remark Code that is not an ALERT.)  Usage: Use this code only when a more specific Claim Adjustment Reason Code is not available.');
	_codeSet.set('A2', 'Contractual adjustment.');
	_codeSet.set('A3', 'Medicare Secondary Payer liability met.');
	_codeSet.set('A4', 'Medicare Claim PPS Capital Day Outlier Amount.');
	_codeSet.set('A5', 'Medicare Claim PPS Capital Cost Outlier Amount.');
	_codeSet.set('A6', 'Prior hospitalization or 30 day transfer requirement not met.');
	_codeSet.set('A7', 'Presumptive Payment Adjustment');
	_codeSet.set('A8', 'Ungroupable DRG.');
	_codeSet.set('B1', 'Non-covered visits.');
	_codeSet.set('B2', 'Covered visits.');
	_codeSet.set('B3', 'Covered charges.');
	_codeSet.set('B4', 'Late filing penalty.');
	_codeSet.set('B5', 'Coverage/program guidelines were not met or were exceeded.');
	_codeSet.set('B6', 'This payment is adjusted when performed/billed by this type of provider, by this type of provider in this type of facility, or by a provider of this specialty.');
	_codeSet.set('B7', 'This provider was not certified/eligible to be paid for this procedure/service on this date of service. Usage: Refer to the 835 Healthcare Policy Identification Segment (loop 2110 Service Payment Information REF), if present.');
	_codeSet.set('B8', 'Alternative services were available, and should have been utilized. Usage: Refer to the 835 Healthcare Policy Identification Segment (loop 2110 Service Payment Information REF), if present.');
	_codeSet.set('B9', 'Patient is enrolled in a Hospice.');
	_codeSet.set('B10', 'Allowed amount has been reduced because a component of the basic procedure/test was paid. The beneficiary is not liable for more than the charge limit for the basic procedure/test.');
	_codeSet.set('B11', 'The claim/service has been transferred to the proper payer/processor for processing. Claim/service not covered by this payer/processor.');
	_codeSet.set('B12', 'Services not documented in patients medical records.');
	_codeSet.set('B13', 'Previously paid. Payment for this claim/service may have been provided in a previous payment.');
	_codeSet.set('B14', 'Only one visit or consultation per physician per day is covered.');
	_codeSet.set('B15', 'This service/procedure requires that a qualifying service/procedure be received and covered. The qualifying other service/procedure has not been received/adjudicated. Usage: Refer to the 835 Healthcare Policy Identification Segment (loop 2110 Service Payment Information REF), if present.');
	_codeSet.set('B16', 'New Patient qualifications were not met.');
	_codeSet.set('B17', 'Payment adjusted because this service was not prescribed by a physician, not prescribed prior to delivery, the prescription is incomplete, or the prescription is not current.');
	_codeSet.set('B18', 'This procedure code and modifier were invalid on the date of service.');
	_codeSet.set('B19', 'Claim/service adjusted because of the finding of a Review Organization.');
	_codeSet.set('B20', 'Procedure/service was partially or fully furnished by another provider.');
	_codeSet.set('B21', 'The charges were reduced because the service/care was partially furnished by another physician.');
	_codeSet.set('B22', 'This payment is adjusted based on the diagnosis.');
	_codeSet.set('B23', 'Procedure billed is not authorized per your Clinical Laboratory Improvement Amendment (CLIA) proficiency test.');
	_codeSet.set('D1', 'Claim/service denied. Level of subluxation is missing or inadequate.');
	_codeSet.set('D2', 'Claim lacks the name, strength, or dosage of the drug furnished.');
	_codeSet.set('D3', 'Claim/service denied because information to indicate if the patient owns the equipment that requires the part or supply was missing.');
	_codeSet.set('D4', 'Claim/service does not indicate the period of time for which this will be needed.');
	_codeSet.set('D5', 'Claim/service denied. Claim lacks individual lab codes included in the test.');
	_codeSet.set('D6', 'Claim/service denied. Claim did not include patients medical record for the service.');
	_codeSet.set('D7', 'Claim/service denied. Claim lacks date of patients most recent physician visit.');
	_codeSet.set('D8', 'Claim/service denied. Claim lacks indicator that x-ray is available for review.');
	_codeSet.set('D9', 'Claim/service denied. Claim lacks invoice or statement certifying the actual cost of the lens, less discounts or the type of intraocular lens used.');
	_codeSet.set('D10', 'Claim/service denied. Completed physician financial relationship form not on file.');
	_codeSet.set('D11', 'Claim lacks completed pacemaker registration form.');
	_codeSet.set('D12', 'Claim/service denied. Claim does not identify who performed the purchased diagnostic test or the amount you were charged for the test.');
	_codeSet.set('D13', 'Claim/service denied. Performed by a facility/supplier in which the ordering/referring physician has a financial interest.');
	_codeSet.set('D14', 'Claim lacks indication that plan of treatment is on file.');
	_codeSet.set('D15', 'Claim lacks indication that service was supervised or evaluated by a physician.');
	_codeSet.set('D16', 'Claim lacks prior payer payment information.');
	_codeSet.set('D17', 'Claim/Service has invalid non-covered days.');
	_codeSet.set('D18', 'Claim/Service has missing diagnosis information.');
	_codeSet.set('D19', 'Claim/Service lacks Physician/Operative or other supporting documentation');
	_codeSet.set('D20', 'Claim/Service missing service/product information.');
	_codeSet.set('D21', 'This (these) diagnosis(es) is (are) missing or are invalid');
	_codeSet.set('D22', 'Reimbursement was adjusted for the reasons to be provided in separate correspondence. (Note: To be used for Workers Compensation only) - Temporary code to be added for timeframe only until 01/01/2009. Another code to be established and/or for 06/2008 meeting for a revised code to replace or strategy to use another existing code');
	_codeSet.set('D23', 'This dual eligible patient is covered by Medicare Part D per Medicare Retro-Eligibility.  At least one Remark Code must be provided (may be comprised of either the NCPDP Reject Reason Code, or Remittance Advice Remark Code that is not an ALERT.)');
	_codeSet.set('P1', 'State-mandated Requirement for Property and Casualty, see Claim Payment Remarks Code for specific explanation. To be used for Property and Casualty only.');
	_codeSet.set('P2', 'Not a work related injury/illness and thus not the liability of the workers compensation carrier Usage: If adjustment is at the Claim Level, the payer must send and the provider should refer to the 835 Insurance Policy Number Segment (Loop 2100 Other Claim Related Information REF qualifier IG) for the jurisdictional regulation. If adjustment is at the Line Level, the payer must send and the provider should refer to the 835 Healthcare Policy Identification Segment (loop 2110 Service Payment information REF). To be used for Workers Compensation only.');
	_codeSet.set('P3', 'Workers Compensation case settled. Patient is responsible for amount of this claim/service through WC Medicare set aside arrangement or other agreement. To be used for Workers Compensation only. (Use only with Group Code PR)');
	_codeSet.set('P4', 'Workers Compensation claim adjudicated as non-compensable. This Payer not liable for claim or service/treatment. Usage: If adjustment is at the Claim Level, the payer must send and the provider should refer to the 835 Insurance Policy Number Segment (Loop 2100 Other Claim Related Information REF qualifier IG) for the jurisdictional regulation. If adjustment is at the Line Level, the payer must send and the provider should refer to the 835 Healthcare Policy Identification Segment (loop 2110 Service Payment information REF). To be used for Workers Compensation only');
	_codeSet.set('P5', 'Based on payer reasonable and customary fees. No maximum allowable defined by legislated fee arrangement. To be used for Property and Casualty only.');
	_codeSet.set('P6', 'Based on entitlement to benefits. Usage: If adjustment is at the Claim Level, the payer must send and the provider should refer to the 835 Insurance Policy Number Segment (Loop 2100 Other Claim Related Information REF qualifier IG) for the jurisdictional regulation. If adjustment is at the Line Level, the payer must send and the provider should refer to the 835 Healthcare Policy Identification Segment (loop 2110 Service Payment information REF). To be used for Property and Casualty only.');
	_codeSet.set('P7', 'The applicable fee schedule/fee database does not contain the billed code. Please resubmit a bill with the appropriate fee schedule/fee database code(s) that best describe the service(s) provided and supporting documentation if required. To be used for Property and Casualty only.');
	_codeSet.set('P8', 'Claim is under investigation. Usage: If adjustment is at the Claim Level, the payer must send and the provider should refer to the 835 Insurance Policy Number Segment (Loop 2100 Other Claim Related Information REF qualifier IG) for the jurisdictional regulation. If adjustment is at the Line Level, the payer must send and the provider should refer to the 835 Healthcare Policy Identification Segment (loop 2110 Service Payment information REF). To be used for Property and Casualty only.');
	_codeSet.set('P9', 'No available or correlating CPT/HCPCS code to describe this service. To be used for Property and Casualty only.');
	_codeSet.set('P10', 'Payment reduced to zero due to litigation. Additional information will be sent following the conclusion of litigation. To be used for Property and Casualty only.');
	_codeSet.set('P11', 'The disposition of the related Property & Casualty claim (injury or illness) is pending due to litigation. To be used for Property and Casualty only. (Use only with Group Code OA)');
	_codeSet.set('P12', 'Workers compensation jurisdictional fee schedule adjustment. Usage: If adjustment is at the Claim Level, the payer must send and the provider should refer to the 835 Class of Contract Code Identification Segment (Loop 2100 Other Claim Related Information REF). If adjustment is at the Line Level, the payer must send and the provider should refer to the 835 Healthcare Policy Identification Segment (loop 2110 Service Payment information REF) if the regulations apply. To be used for Workers Compensation only.');
	_codeSet.set('P13', 'Payment reduced or denied based on workers compensation jurisdictional regulations or payment policies, use only if no other code is applicable. Usage: If adjustment is at the Claim Level, the payer must send and the provider should refer to the 835 Insurance Policy Number Segment (Loop 2100 Other Claim Related Information REF qualifier IG) if the jurisdictional regulation applies. If adjustment is at the Line Level, the payer must send and the provider should refer to the 835 Healthcare Policy Identification Segment (loop 2110 Service Payment information REF) if the regulations apply. To be used for Workers Compensation only.');
	_codeSet.set('P14', 'The Benefit for this Service is included in the payment/allowance for another service/procedure that has been performed on the same day. Usage: Refer to the 835 Healthcare Policy Identification Segment (loop 2110 Service Payment Information REF), if present. To be used for Property and Casualty only.');
	_codeSet.set('P15', 'Workers Compensation Medical Treatment Guideline Adjustment. To be used for Workers Compensation only.');
	_codeSet.set('P16', 'Medical provider not authorized/certified to provide treatment to injured workers in this jurisdiction. To be used for Workers Compensation only. (Use with Group Code CO or OA)');
	_codeSet.set('P17', 'Referral not authorized by attending physician per regulatory requirement. To be used for Property and Casualty only.');
	_codeSet.set('P18', 'Procedure is not listed in the jurisdiction fee schedule.  An allowance has been made for a comparable service. To be used for Property and Casualty only.');
	_codeSet.set('P19', 'Procedure has a relative value of zero in the jurisdiction fee schedule, therefore no payment is due. To be used for Property and Casualty only.');
	_codeSet.set('P20', 'Service not paid under jurisdiction allowed outpatient facility fee schedule. To be used for Property and Casualty only.');
	_codeSet.set('P21', 'Payment denied based on the Medical Payments Coverage (MPC) and/or Personal Injury Protection (PIP) Benefits jurisdictional regulations, or payment policies. Usage: If adjustment is at the Claim Level, the payer must send and the provider should refer to the 835 Insurance Policy Number Segment (Loop 2100 Other Claim Related Information REF qualifier IG) if the jurisdictional regulation applies. If adjustment is at the Line Level, the payer must send and the provider should refer to the 835 Healthcare Policy Identification Segment (loop 2110 Service Payment information REF) if the regulations apply. To be used for Property and Casualty Auto only.');
	_codeSet.set('P22', 'Payment adjusted based on the Medical Payments Coverage (MPC) and/or Personal Injury Protection (PIP) Benefits jurisdictional regulations, or payment policies. Usage: If adjustment is at the Claim Level, the payer must send and the provider should refer to the 835 Insurance Policy Number Segment (Loop 2100 Other Claim Related Information REF qualifier IG) if the jurisdictional regulation applies. If adjustment is at the Line Level, the payer must send and the provider should refer to the 835 Healthcare Policy Identification Segment (loop 2110 Service Payment information REF) if the regulations apply. To be used for Property and Casualty Auto only.');
	_codeSet.set('P23', 'Medical Payments Coverage (MPC) or Personal Injury Protection (PIP) Benefits jurisdictional fee schedule adjustment. Usage: If adjustment is at the Claim Level, the payer must send and the provider should refer to the 835 Class of Contract Code Identification Segment (Loop 2100 Other Claim Related Information REF). If adjustment is at the Line Level, the payer must send and the provider should refer to the 835 Healthcare Policy Identification Segment (loop 2110 Service Payment information REF) if the regulations apply. To be used for Property and Casualty Auto only.');
	_codeSet.set('P24', 'Payment adjusted based on Preferred Provider Organization (PPO).  Usage: If adjustment is at the Claim Level, the payer must send and the provider should refer to the 835 Class of Contract Code Identification Segment (Loop 2100 Other Claim Related Information REF). If adjustment is at the Line Level, the payer must send and the provider should refer to the 835 Healthcare Policy Identification Segment (loop 2110 Service Payment information REF) if the regulations apply. To be used for Property and Casualty only. Use only with Group Code CO.');
	_codeSet.set('P25', 'Payment adjusted based on Medical Provider Network (MPN).  Usage: If adjustment is at the Claim Level, the payer must send and the provider should refer to the 835 Class of Contract Code Identification Segment (Loop 2100 Other Claim Related Information REF). If adjustment is at the Line Level, the payer must send and the provider should refer to the 835 Healthcare Policy Identification Segment (loop 2110 Service Payment information REF) if the regulations apply. To be used for Property and Casualty only. (Use only with Group Code CO).');
	_codeSet.set('P26', 'Payment adjusted based on Voluntary Provider network (VPN).  Usage: If adjustment is at the Claim Level, the payer must send and the provider should refer to the 835 Class of Contract Code Identification Segment (Loop 2100 Other Claim Related Information REF). If adjustment is at the Line Level, the payer must send and the provider should refer to the 835 Healthcare Policy Identification Segment (loop 2110 Service Payment information REF) if the regulations apply. To be used for Property and Casualty only. (Use only with Group Code CO).');
	_codeSet.set('P27', 'Payment denied based on the Liability Coverage Benefits jurisdictional regulations and/or payment policies. Usage: If adjustment is at the Claim Level, the payer must send and the provider should refer to the 835 Insurance Policy Number Segment (Loop 2100 Other Claim Related Information REF qualifier IG) if the jurisdictional regulation applies. If adjustment is at the Line Level, the payer must send and the provider should refer to the 835 Healthcare Policy Identification Segment (loop 2110 Service Payment information REF) if the regulations apply. To be used for Property and Casualty Auto only.');
	_codeSet.set('P28', 'Payment adjusted based on the Liability Coverage Benefits jurisdictional regulations and/or payment policies. Usage: If adjustment is at the Claim Level, the payer must send and the provider should refer to the 835 Insurance Policy Number Segment (Loop 2100 Other Claim Related Information REF qualifier IG) if the jurisdictional regulation applies. If adjustment is at the Line Level, the payer must send and the provider should refer to the 835 Healthcare Policy Identification Segment (loop 2110 Service Payment information REF) if the regulations apply. To be used for Property and Casualty Auto only.');
	_codeSet.set('P29', 'Liability Benefits jurisdictional fee schedule adjustment. Usage: If adjustment is at the Claim Level, the payer must send and the provider should refer to the 835 Class of Contract Code Identification Segment (Loop 2100 Other Claim Related Information REF). If adjustment is at the Line Level, the payer must send and the provider should refer to the 835 Healthcare Policy Identification Segment (loop 2110 Service Payment information REF) if the regulations apply. To be used for Property and Casualty Auto only.');
	_codeSet.set('P30', 'Payment denied for exacerbation when supporting documentation was not complete. To be used for Property and Casualty only.');
	_codeSet.set('P31', 'Payment denied for exacerbation when treatment exceeds time allowed. To be used for Property and Casualty only.');
	_codeSet.set('P32', 'Payment adjusted due to Apportionment.');
	_codeSet.set('W1', 'Workers compensation jurisdictional fee schedule adjustment.  Note: If adjustment is at the Claim Level, the payer must send and the provider should refer to the 835 Class of Contract Code Identification Segment (Loop 2100 Other Claim Related Information REF). If adjustment is at the Line Level, the payer must send and the provider should refer to the 835 Healthcare Policy Identification Segment (loop 2110 Service Payment information REF) if the regulations apply.');
	_codeSet.set('W2', 'Payment reduced or denied based on workers compensation jurisdictional regulations or payment policies, use only if no other code is applicable. Note: If adjustment is at the Claim Level, the payer must send and the provider should refer to the 835 Insurance Policy Number Segment (Loop 2100 Other Claim Related Information REF qualifier IG) if the jurisdictional regulation applies. If adjustment is at the Line Level, the payer must send and the provider should refer to the 835 Healthcare Policy Identification Segment (loop 2110 Service Payment information REF) if the regulations apply. To be used for Workers Compensation only.');
	_codeSet.set('W3', 'The Benefit for this Service is included in the payment/allowance for another service/procedure that has been performed on the same day. Note: Refer to the 835 Healthcare Policy Identification Segment (loop 2110 Service Payment Information REF), if present. For use by Property and Casualty only.');
	_codeSet.set('W4', 'Workers Compensation Medical Treatment Guideline Adjustment.');
	_codeSet.set('W5', 'Medical provider not authorized/certified to provide treatment to injured workers in this jurisdiction. (Use with Group Code CO or OA)');
	_codeSet.set('W6', 'Referral not authorized by attending physician per regulatory requirement.');
	_codeSet.set('W7', 'Procedure is not listed in the jurisdiction fee schedule.  An allowance has been made for a comparable service.');
	_codeSet.set('W8', 'Procedure has a relative value of zero in the jurisdiction fee schedule, therefore no payment is due.');
	_codeSet.set('W9', 'Service not paid under jurisdiction allowed outpatient facility fee schedule.');
	_codeSet.set('Y1', 'Payment denied based on Medical Payments Coverage (MPC) or Personal Injury Protection (PIP) Benefits jurisdictional regulations or payment policies, use only if no other code is applicable. Note: If adjustment is at the Claim Level, the payer must send and the provider should refer to the 835 Insurance Policy Number Segment (Loop 2100 Other Claim Related Information REF qualifier IG) if the jurisdictional regulation applies. If adjustment is at the Line Level, the payer must send and the provider should refer to the 835 Healthcare Policy Identification Segment (loop 2110 Service Payment information REF) if the regulations apply. To be used for P&C Auto only.');
	_codeSet.set('Y2', 'Payment adjusted based on Medical Payments Coverage (MPC) or Personal Injury Protection (PIP) Benefits jurisdictional regulations or payment policies, use only if no other code is applicable. Note: If adjustment is at the Claim Level, the payer must send and the provider should refer to the 835 Insurance Policy Number Segment (Loop 2100 Other Claim Related Information REF qualifier IG) if the jurisdictional regulation applies. If adjustment is at the Line Level, the payer must send and the provider should refer to the 835 Healthcare Policy Identification Segment (loop 2110 Service Payment information REF) if the regulations apply. To be used for P&C Auto only.');
	_codeSet.set('Y3', 'Medical Payments Coverage (MPC) or Personal Injury Protection (PIP) Benefits jurisdictional fee schedule adjustment. Note: If adjustment is at the Claim Level, the payer must send and the provider should refer to the 835 Class of Contract Code Identification Segment (Loop 2100 Other Claim Related Information REF). If adjustment is at the Line Level, the payer must send and the provider should refer to the 835 Healthcare Policy Identification Segment (loop 2110 Service Payment information REF) if the regulations apply. To be used for P&C Auto only.');
	return _codeSet;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

const _fnGenerateCodeSetMap_CodeSource411Rarc = function () {
	let _codeSet = new Map();
	_codeSet.set('M1', 'X-ray not taken within the past 12 months or near enough to the start of treatment.');
	_codeSet.set('M2', 'Not paid separately when the patient is an inpatient.');
	_codeSet.set('M3', 'Equipment is the same or similar to equipment already being used.');
	_codeSet.set('M4', 'This is the last monthly installment payment for this durable medical equipment.');
	_codeSet.set('M5', 'Monthly rental payments can continue until the earlier of the 15th month from the first rental month, or the month when the equipment is no longer needed.');
	_codeSet.set('M6', 'You must furnish and service this item for any period of medical need for the remainder of the reasonable useful lifetime of the equipment.');
	_codeSet.set('M7', 'No rental payments after the item is purchased, returned or after the total of issued rental payments equals the purchase price.');
	_codeSet.set('M8', 'We do not accept blood gas tests results when the test was conducted by a medical supplier or taken while the patient is on oxygen.');
	_codeSet.set('M9', 'This is the tenth rental month. You must offer the patient the choice of changing the rental to a purchase agreement.');
	_codeSet.set('M10', 'Equipment purchases are limited to the first or the tenth month of medical necessity.');
	_codeSet.set('M11', 'DME, orthotics and prosthetics must be billed to the DME carrier who services the patients zip code.');
	_codeSet.set('M12', 'Diagnostic tests performed by a physician must indicate whether purchased services are included on the claim.');
	_codeSet.set('M13', 'Only one initial visit is covered per specialty per medical group.');
	_codeSet.set('M14', 'No separate payment for an injection administered during an office visit, and no payment for a full office visit if the patient only received an injection.');
	_codeSet.set('M15', 'Separately billed services/tests have been bundled as they are considered components of the same procedure. Separate payment is not allowed.');
	_codeSet.set('M16', 'Please see our web site, mailings, or bulletins for more details concerning this policy/procedure/decision.');
	_codeSet.set('M17', 'Payment approved as you did not know, and could not reasonably have been expected to know, that this would not normally have been covered for this patient.  In the future, you will be liable for charges for the same service(s) under the same or similar conditions.');
	_codeSet.set('M18', 'Certain services may be approved for home use.  Neither a hospital nor a Skilled Nursing Facility (SNF) is considered to be a patients home.');
	_codeSet.set('M19', 'Missing oxygen certification/re-certification.');
	_codeSet.set('M20', 'Missing/incomplete/invalid HCPCS.');
	_codeSet.set('M21', 'Missing/incomplete/invalid place of residence for this service/item provided in a home.');
	_codeSet.set('M22', 'Missing/incomplete/invalid number of miles traveled.');
	_codeSet.set('M23', 'Missing invoice.');
	_codeSet.set('M24', 'Missing/incomplete/invalid number of doses per vial.');
	_codeSet.set('M25', 'The information furnished does not substantiate the need for this level of service. If you believe the service should have been fully covered as billed, or if you did not know and could not reasonably have been expected to know that we would not pay for this level of service, or if you notified the patient in writing in advance that we would not pay for this level of service and he/she agreed in writing to pay, ask us to review your claim within 120 days of the date of this notice.  If you do not request an appeal, we will, upon application from the patient, reimburse him/her for the amount you have collected from him/her in excess of any deductible and coinsurance amounts. We will recover the reimbursement from you as an overpayment.');
	_codeSet.set('M26', 'The information furnished does not substantiate the need for this level of service. If you have collected any amount from the patient for this level of service/any amount that exceeds the limiting charge for the less extensive service, the law requires you to refund that amount to the patient within 30 days of receiving this notice. The requirements for refund are in 1824(I) of the Social Security Act and 42CFR411.408. The section specifies that physicians who knowingly and willfully fail to make appropriate refunds may be subject to civil monetary penalties and/or exclusion from the program. If you have any questions about this notice, please contact this office.');
	_codeSet.set('M27', 'The patient has been relieved of liability of payment of these items and services under the limitation of liability provision of the law. The provider is ultimately liable for the patients waived charges, including any charges for coinsurance, since the items or services were not reasonable and necessary or constituted custodial care, and you knew or could reasonably have been expected to know, that they were not covered. You may appeal this determination. You may ask for an appeal regarding both the coverage determination and the issue of whether you exercised due care. The appeal request must be filed within 120 days of the date you receive this notice. You must make the request through this office.');
	_codeSet.set('M28', 'This does not qualify for payment under Part B when Part A coverage is exhausted or not otherwise available.');
	_codeSet.set('M29', 'Missing operative note/report.');
	_codeSet.set('M30', 'Missing pathology report.');
	_codeSet.set('M31', 'Missing radiology report.');
	_codeSet.set('M32', 'This is a conditional payment made pending a decision on this service by the patients primary payer. This payment may be subject to refund upon your receipt of any additional payment for this service from another payer. You must contact this office immediately upon receipt of an additional payment for this service.');
	_codeSet.set('M33', 'Missing/incomplete/invalid UPIN for the ordering/referring/performing provider.');
	_codeSet.set('M34', 'Claim lacks the CLIA certification number.');
	_codeSet.set('M35', 'Missing/incomplete/invalid pre-operative photos or visual field results.');
	_codeSet.set('M36', 'This is the 11th rental month.  We cannot pay for this until you indicate that the patient has been given the option of changing the rental to a purchase.');
	_codeSet.set('M37', 'Not covered when the patient is under age 35.');
	_codeSet.set('M38', 'The patient is liable for the charges for this service as they were informed in writing before the service was furnished that we would not pay for it and the patient agreed to be responsible for the charges.');
	_codeSet.set('M39', 'The patient is not liable for payment of this service as the advance notice of non-coverage you provided the patient did not comply with program requirements.');
	_codeSet.set('M40', 'Claim must be assigned and must be filed by the practitioners employer.');
	_codeSet.set('M41', 'We do not pay for this as the patient has no legal obligation to pay for this.');
	_codeSet.set('M42', 'The medical necessity form must be personally signed by the attending physician.');
	_codeSet.set('M43', 'Payment for this service previously issued to you or another provider by another carrier/intermediary.');
	_codeSet.set('M44', 'Missing/incomplete/invalid condition code.');
	_codeSet.set('M45', 'Missing/incomplete/invalid occurrence code(s).');
	_codeSet.set('M46', 'Missing/incomplete/invalid occurrence span code(s).');
	_codeSet.set('M47', 'Missing/incomplete/invalid Payer Claim Control Number. Other terms exist for this element including, but not limited to, Internal Control Number (ICN), Claim Control Number (CCN), Document Control Number (DCN).');
	_codeSet.set('M48', 'Payment for services furnished to hospital inpatients (other than professional services of physicians) can only be made to the hospital.  You must request payment from the hospital rather than the patient for this service.');
	_codeSet.set('M49', 'Missing/incomplete/invalid value code(s) or amount(s).');
	_codeSet.set('M50', 'Missing/incomplete/invalid revenue code(s).');
	_codeSet.set('M51', 'Missing/incomplete/invalid procedure code(s).');
	_codeSet.set('M52', 'Missing/incomplete/invalid from date(s) of service.');
	_codeSet.set('M53', 'Missing/incomplete/invalid days or units of service.');
	_codeSet.set('M54', 'Missing/incomplete/invalid total charges.');
	_codeSet.set('M55', 'We do not pay for self-administered anti-emetic drugs that are not administered with a covered oral anti-cancer drug.');
	_codeSet.set('M56', 'Missing/incomplete/invalid payer identifier.');
	_codeSet.set('M57', 'Missing/incomplete/invalid provider identifier.');
	_codeSet.set('M58', 'Missing/incomplete/invalid claim information.  Resubmit claim after corrections.');
	_codeSet.set('M59', 'Missing/incomplete/invalid to date(s) of service.');
	_codeSet.set('M60', 'Missing Certificate of Medical Necessity.');
	_codeSet.set('M61', 'We cannot pay for this as the approval period for the FDA clinical trial has expired.');
	_codeSet.set('M62', 'Missing/incomplete/invalid treatment authorization code.');
	_codeSet.set('M63', 'We do not pay for more than one of these on the same day.');
	_codeSet.set('M64', 'Missing/incomplete/invalid other diagnosis.');
	_codeSet.set('M65', 'One interpreting physician charge can be submitted per claim when a purchased diagnostic test is indicated. Please submit a separate claim for each interpreting physician.');
	_codeSet.set('M66', 'Our records indicate that you billed diagnostic tests subject to price limitations and the procedure code submitted includes a professional component. Only the technical component is subject to price limitations.  Please submit the technical and professional components of this service as separate line items.');
	_codeSet.set('M67', 'Missing/incomplete/invalid other procedure code(s).');
	_codeSet.set('M68', 'Missing/incomplete/invalid attending, ordering, rendering, supervising or referring physician identification.');
	_codeSet.set('M69', 'Paid at the regular rate as you did not submit documentation to justify the modified procedure code.');
	_codeSet.set('M70', 'The NDC code submitted for this service was translated to a HCPCS code for processing, but please continue to submit the NDC on future claims for this item.');
	_codeSet.set('M71', 'Total payment reduced due to overlap of tests billed.');
	_codeSet.set('M72', 'Did not enter full 8-digit date (MM/DD/CCYY).');
	_codeSet.set('M73', 'The HPSA/Physician Scarcity bonus can only be paid on the professional component of this service. Rebill as separate professional and technical components.');
	_codeSet.set('M74', 'This service does not qualify for a HPSA/Physician Scarcity bonus payment.');
	_codeSet.set('M75', 'Multiple automated multichannel tests performed on the same day combined for payment.');
	_codeSet.set('M76', 'Missing/incomplete/invalid diagnosis or condition.');
	_codeSet.set('M77', 'Missing/incomplete/invalid/inappropriate place of service.');
	_codeSet.set('M78', 'Missing/incomplete/invalid HCPCS modifier.');
	_codeSet.set('M79', 'Missing/incomplete/invalid charge.');
	_codeSet.set('M80', 'Not covered when performed during the same session/date as a previously processed service for the patient.');
	_codeSet.set('M81', 'You are required to code to the highest level of specificity.');
	_codeSet.set('M82', 'Service is not covered when patient is under age 50.');
	_codeSet.set('M83', 'Service is not covered unless the patient is classified as at high risk.');
	_codeSet.set('M84', 'Medical code sets used must be the codes in effect at the time of service.');
	_codeSet.set('M85', 'Subjected to review of physician evaluation and management services.');
	_codeSet.set('M86', 'Service denied because payment already made for same/similar procedure within set time frame.');
	_codeSet.set('M87', 'Claim/service(s) subjected to CFO-CAP prepayment review.');
	_codeSet.set('M88', 'We cannot pay for laboratory tests unless billed by the laboratory that did the work.');
	_codeSet.set('M89', 'Not covered more than once under age 40.');
	_codeSet.set('M90', 'Not covered more than once in a 12 month period.');
	_codeSet.set('M91', 'Lab procedures with different CLIA certification numbers must be billed on separate claims.');
	_codeSet.set('M92', 'Services subjected to review under the Home Health Medical Review Initiative.');
	_codeSet.set('M93', 'Information supplied supports a break in therapy.  A new capped rental period began with delivery of this equipment.');
	_codeSet.set('M94', 'Information supplied does not support a break in therapy.  A new capped rental period will not begin.');
	_codeSet.set('M95', 'Services subjected to Home Health Initiative medical review/cost report audit.');
	_codeSet.set('M96', 'The technical component of a service furnished to an inpatient may only be billed by that inpatient facility. You must contact the inpatient facility for technical component reimbursement.  If not already billed, you should bill us for the professional component only.');
	_codeSet.set('M97', 'Not paid to practitioner when provided to patient in this place of service.  Payment included in the reimbursement issued the facility.');
	_codeSet.set('M98', 'Begin to report the Universal Product Number on claims for items of this type. We will soon begin to deny payment for items of this type if billed without the correct UPN.');
	_codeSet.set('M99', 'Missing/incomplete/invalid Universal Product Number/Serial Number.');
	_codeSet.set('M100', 'We do not pay for an oral anti-emetic drug that is not administered for use immediately before, at, or within 48 hours of administration of a covered chemotherapy drug.');
	_codeSet.set('M101', 'Begin to report a G1-G5 modifier with this HCPCS.  We will soon begin to deny payment for this service if billed without a G1-G5 modifier.');
	_codeSet.set('M102', 'Service not performed on equipment approved by the FDA for this purpose.');
	_codeSet.set('M103', 'Information supplied supports a break in therapy.  However, the medical information we have for this patient does not support the need for this item as billed.  We have approved payment for this item at a reduced level, and a new capped rental period will begin with the delivery of this equipment.');
	_codeSet.set('M104', 'Information supplied supports a break in therapy.  A new capped rental period will begin with delivery of the equipment.  This is the maximum approved under the fee schedule for this item or service.');
	_codeSet.set('M105', 'Information supplied does not support a break in therapy.  The medical information we have for this patient does not support the need for this item as billed. We have approved payment for this item at a reduced level, and a new capped rental period will not begin.');
	_codeSet.set('M106', 'Information supplied does not support a break in therapy.  A new capped rental period will not begin. This is the maximum approved under the fee schedule for this item or service.');
	_codeSet.set('M107', 'Payment reduced as 90-day rolling average hematocrit for ESRD patient exceeded 36.5%.');
	_codeSet.set('M108', 'Missing/incomplete/invalid provider identifier for the provider who interpreted the diagnostic test.');
	_codeSet.set('M109', 'We have provided you with a bundled payment for a teleconsultation. You must send 25 percent of the teleconsultation payment to the referring practitioner.');
	_codeSet.set('M110', 'Missing/incomplete/invalid provider identifier for the provider from whom you purchased interpretation services.');
	_codeSet.set('M111', 'We do not pay for chiropractic manipulative treatment when the patient refuses to have an x-ray taken.');
	_codeSet.set('M112', 'Reimbursement for this item is based on the single payment amount required under the DMEPOS Competitive Bidding Program for the area where the patient resides.');
	_codeSet.set('M113', 'Our records indicate that this patient began using this item/service prior to the current contract period for the DMEPOS Competitive Bidding Program.');
	_codeSet.set('M114', 'This service was processed in accordance with rules and guidelines under the DMEPOS Competitive Bidding Program or a Demonstration Project.  For more information regarding these projects, contact your local contractor.');
	_codeSet.set('M115', 'This item is denied when provided to this patient by a non-contract or non-demonstration supplier.');
	_codeSet.set('M116', 'Processed under a demonstration project or program. Project or program is ending and additional services may not be paid under this project or program.');
	_codeSet.set('M117', 'Not covered unless submitted via electronic claim.');
	_codeSet.set('M118', 'Letter to follow containing further information.');
	_codeSet.set('M119', 'Missing/incomplete/invalid/ deactivated/withdrawn National Drug Code (NDC).');
	_codeSet.set('M120', 'Missing/incomplete/invalid provider identifier for the substituting physician who furnished the service(s) under a reciprocal billing or locum tenens arrangement.');
	_codeSet.set('M121', 'We pay for this service only when performed with a covered cryosurgical ablation.');
	_codeSet.set('M122', 'Missing/incomplete/invalid level of subluxation.');
	_codeSet.set('M123', 'Missing/incomplete/invalid name, strength, or dosage of the drug furnished.');
	_codeSet.set('M124', 'Missing indication of whether the patient owns the equipment that requires the part or supply.');
	_codeSet.set('M125', 'Missing/incomplete/invalid information on the period of time for which the service/supply/equipment will be needed.');
	_codeSet.set('M126', 'Missing/incomplete/invalid individual lab codes included in the test.');
	_codeSet.set('M127', 'Missing patient medical record for this service.');
	_codeSet.set('M128', 'Missing/incomplete/invalid date of the patients last physician visit.');
	_codeSet.set('M129', 'Missing/incomplete/invalid indicator of x-ray availability for review.');
	_codeSet.set('M130', 'Missing invoice or statement certifying the actual cost of the lens, less discounts, and/or the type of intraocular lens used.');
	_codeSet.set('M131', 'Missing physician financial relationship form.');
	_codeSet.set('M132', 'Missing pacemaker registration form.');
	_codeSet.set('M133', 'Claim did not identify who performed the purchased diagnostic test or the amount you were charged for the test.');
	_codeSet.set('M134', 'Performed by a facility/supplier in which the provider has a financial interest.');
	_codeSet.set('M135', 'Missing/incomplete/invalid plan of treatment.');
	_codeSet.set('M136', 'Missing/incomplete/invalid indication that the service was supervised or evaluated by a physician.');
	_codeSet.set('M137', 'Part B coinsurance under a demonstration project or pilot program.');
	_codeSet.set('M138', 'Patient identified as a demonstration participant but the patient was not enrolled in the demonstration at the time services were rendered.  Coverage is limited to demonstration participants.');
	_codeSet.set('M139', 'Denied services exceed the coverage limit for the demonstration.');
	_codeSet.set('M140', 'Service not covered until after the patients 50th birthday, i.e., no coverage prior to the day after the 50th birthday');
	_codeSet.set('M141', 'Missing physician certified plan of care.');
	_codeSet.set('M142', 'Missing American Diabetes Association Certificate of Recognition.');
	_codeSet.set('M143', 'The provider must update license information with the payer.');
	_codeSet.set('M144', 'Pre-/post-operative care payment is included in the allowance for the surgery/procedure.');
	_codeSet.set('MA01', 'If you do not agree with what we approved for these services, you may appeal our decision.  To make sure that we are fair to you, we require another individual that did not process your initial claim to conduct the appeal.  However, in order to be eligible for an appeal, you must write to us within 120 days of the date you received this notice, unless you have a good reason for being late.');
	_codeSet.set('MA02', 'If you do not agree with this determination, you have the right to appeal. You must file a written request for an appeal within 180 days of the date you receive this notice.');
	_codeSet.set('MA03', 'If you do not agree with the approved amounts and $100 or more is in dispute (less deductible and coinsurance), you may ask for a hearing within six months of the date of this notice. To meet the $100, you may combine amounts on other claims that have been denied, including reopened appeals if you received a revised decision. You must appeal each claim on time.');
	_codeSet.set('MA04', 'Secondary payment cannot be considered without the identity of or payment information from the primary payer.  The information was either not reported or was illegible.');
	_codeSet.set('MA05', 'Incorrect admission date patient status or type of bill entry on claim.');
	_codeSet.set('MA06', 'Missing/incomplete/invalid beginning and/or ending date(s).');
	_codeSet.set('MA07', 'The claim information has also been forwarded to Medicaid for review.');
	_codeSet.set('MA08', 'Claim information was not forwarded because the supplemental coverage is not with a Medigap plan, or you do not participate in Medicare.');
	_codeSet.set('MA09', 'Claim submitted as unassigned but processed as assigned in accordance with our current assignment/participation agreement.');
	_codeSet.set('MA10', 'The patients payment was in excess of the amount owed.  You must refund the overpayment to the patient.');
	_codeSet.set('MA11', 'Payment is being issued on a conditional basis.  If no-fault insurance, liability insurance, Workers Compensation, Department of Veterans Affairs, or a group health plan for employees and dependents also covers this claim, a refund may be due us.  Please contact us if the patient is covered by any of these sources.');
	_codeSet.set('MA12', 'You have not established that you have the right under the law to bill for services furnished by the person(s) that furnished this (these) service(s).');
	_codeSet.set('MA13', 'You may be subject to penalties if you bill the patient for amounts not reported with the PR (patient responsibility) group code.');
	_codeSet.set('MA14', 'The patient is a member of an employer-sponsored prepaid health plan. Services from outside that health plan are not covered.  However, as you were not previously notified of this, we are paying this time.  In the future, we will not pay you for non-plan services.');
	_codeSet.set('MA15', 'Your claim has been separated to expedite handling. You will receive a separate notice for the other services reported.');
	_codeSet.set('MA16', 'The patient is covered by the Black Lung Program.  Send this claim to the Department of Labor, Federal Black Lung Program, P.O. Box 828, Lanham-Seabrook MD 20703.');
	_codeSet.set('MA17', 'We are the primary payer and have paid at the primary rate.  You must contact the patients other insurer to refund any excess it may have paid due to its erroneous primary payment.');
	_codeSet.set('MA18', 'The claim information is also being forwarded to the patients supplemental insurer. Send any questions regarding supplemental benefits to them.');
	_codeSet.set('MA19', ' Information was not sent to the Medigap insurer due to incorrect/invalid information you submitted concerning that insurer. Please verify your information and submit your secondary claim directly to that insurer.');
	_codeSet.set('MA20', 'Skilled Nursing Facility (SNF) stay not covered when care is primarily related to the use of an urethral catheter for convenience or the control of incontinence.');
	_codeSet.set('MA21', 'SSA records indicate mismatch with name and sex.');
	_codeSet.set('MA22', 'Payment of less than $1.00 suppressed.');
	_codeSet.set('MA23', 'Demand bill approved as result of medical review.');
	_codeSet.set('MA24', 'Christian Science Sanitarium/ Skilled Nursing Facility (SNF) bill in the same benefit period.');
	_codeSet.set('MA25', 'A patient may not elect to change a hospice provider more than once in a benefit period.');
	_codeSet.set('MA26', 'Our records indicate that you were previously informed of this rule.');
	_codeSet.set('MA27', 'Missing/incomplete/invalid entitlement number or name shown on the claim.');
	_codeSet.set('MA28', 'Receipt of this notice by a physician or supplier who did not accept assignment is for information only and does not make the physician or supplier a party to the determination.  No additional rights to appeal this decision, above those rights already provided for by regulation/instruction, are conferred by receipt of this notice.');
	_codeSet.set('MA29', 'Missing/incomplete/invalid provider name, city, state, or zip code.');
	_codeSet.set('MA30', 'Missing/incomplete/invalid type of bill.');
	_codeSet.set('MA31', 'Missing/incomplete/invalid beginning and ending dates of the period billed.');
	_codeSet.set('MA32', 'Missing/incomplete/invalid number of covered days during the billing period.');
	_codeSet.set('MA33', 'Missing/incomplete/invalid non-covered days during the billing period.');
	_codeSet.set('MA34', 'Missing/incomplete/invalid number of coinsurance days during the billing period.');
	_codeSet.set('MA35', 'Missing/incomplete/invalid number of lifetime reserve days.');
	_codeSet.set('MA36', 'Missing/incomplete/invalid patient name.');
	_codeSet.set('MA37', 'Missing/incomplete/invalid patients address.');
	_codeSet.set('MA38', 'Missing/incomplete/invalid birth date.');
	_codeSet.set('MA39', 'Missing/incomplete/invalid gender.');
	_codeSet.set('MA40', 'Missing/incomplete/invalid admission date.');
	_codeSet.set('MA41', 'Missing/incomplete/invalid admission type.');
	_codeSet.set('MA42', 'Missing/incomplete/invalid admission source.');
	_codeSet.set('MA43', 'Missing/incomplete/invalid patient status.');
	_codeSet.set('MA44', 'No appeal rights. Adjudicative decision based on law.');
	_codeSet.set('MA45', 'As previously advised, a portion or all of your payment is being held in a special account.');
	_codeSet.set('MA46', 'The new information was considered but additional payment will not be issued.');
	_codeSet.set('MA47', 'Our records show you have opted out of Medicare, agreeing with the patient not to bill Medicare for services/tests/supplies furnished.  As result, we cannot pay this claim. The patient is responsible for payment.');
	_codeSet.set('MA48', 'Missing/incomplete/invalid name or address of responsible party or primary payer.');
	_codeSet.set('MA49', 'Missing/incomplete/invalid six-digit provider identifier for home health agency or hospice for physician(s) performing care plan oversight services.');
	_codeSet.set('MA50', 'Missing/incomplete/invalid Investigational Device Exemption number or Clinical Trial number.');
	_codeSet.set('MA51', 'Missing/incomplete/invalid CLIA certification number for laboratory services billed by physician office laboratory.');
	_codeSet.set('MA52', 'Missing/incomplete/invalid date.');
	_codeSet.set('MA53', 'Missing/incomplete/invalid Competitive Bidding Demonstration Project identification.');
	_codeSet.set('MA54', 'Physician certification or election consent for hospice care not received timely.');
	_codeSet.set('MA55', 'Not covered as patient received medical health care services, automatically revoking his/her election to receive religious non-medical health care services.');
	_codeSet.set('MA56', 'Our records show you have opted out of Medicare, agreeing with the patient not to bill Medicare for services/tests/supplies furnished.  As result, we cannot pay this claim. The patient is responsible for payment, but under Federal law, you cannot charge the patient more than the limiting charge amount.');
	_codeSet.set('MA57', 'Patient submitted written request to revoke his/her election for religious non-medical health care services.');
	_codeSet.set('MA58', 'Missing/incomplete/invalid release of information indicator.');
	_codeSet.set('MA59', 'The patient overpaid you for these services. You must issue the patient a refund within 30 days for the difference between his/her payment and the total amount shown as patient responsibility on this notice.');
	_codeSet.set('MA60', 'Missing/incomplete/invalid patient relationship to insured.');
	_codeSet.set('MA61', 'Missing/incomplete/invalid social security number.');
	_codeSet.set('MA62', 'This is a telephone review decision.');
	_codeSet.set('MA63', 'Missing/incomplete/invalid principal diagnosis.');
	_codeSet.set('MA64', 'Our records indicate that we should be the third payer for this claim.  We cannot process this claim until we have received payment information from the primary and secondary payers.');
	_codeSet.set('MA65', 'Missing/incomplete/invalid admitting diagnosis.');
	_codeSet.set('MA66', 'Missing/incomplete/invalid principal procedure code.');
	_codeSet.set('MA67', 'Correction to a prior claim.');
	_codeSet.set('MA68', 'We did not crossover this claim because the secondary insurance information on the claim was incomplete. Please supply complete information or use the PLANID of the insurer to assure correct and timely routing of the claim.');
	_codeSet.set('MA69', 'Missing/incomplete/invalid remarks.');
	_codeSet.set('MA70', 'Missing/incomplete/invalid provider representative signature.');
	_codeSet.set('MA71', 'Missing/incomplete/invalid provider representative signature date.');
	_codeSet.set('MA72', 'The patient overpaid you for these assigned services.  You must issue the patient a refund within 30 days for the difference between his/her payment to you and the total of the amount shown as patient responsibility and as paid to the patient on this notice.');
	_codeSet.set('MA73', 'Informational remittance associated with a Medicare demonstration.  No payment issued under fee-for-service Medicare as patient has elected managed care.');
	_codeSet.set('MA74', 'This payment replaces an earlier payment for this claim that was either lost, damaged or returned.');
	_codeSet.set('MA75', 'Missing/incomplete/invalid patient or authorized representative signature.');
	_codeSet.set('MA76', 'Missing/incomplete/invalid provider identifier for home health agency or hospice when physician is performing care plan oversight services.');
	_codeSet.set('MA77', 'The patient overpaid you. You must issue the patient a refund within 30 days for the difference between the patients payment less the total of our and other payer payments and the amount shown as patient responsibility on this notice.');
	_codeSet.set('MA78', 'The patient overpaid you.  You must issue the patient a refund within 30 days for the difference between our allowed amount total and the amount paid by the patient.');
	_codeSet.set('MA79', 'Billed in excess of interim rate.');
	_codeSet.set('MA80', 'Informational notice. No payment issued for this claim with this notice. Payment issued to the hospital by its intermediary for all services for this encounter under a demonstration project.');
	_codeSet.set('MA81', 'Missing/incomplete/invalid provider/supplier signature.');
	_codeSet.set('MA82', 'Missing/incomplete/invalid provider/supplier billing number/identifier or billing name, address, city, state, zip code, or phone number.');
	_codeSet.set('MA83', 'Did not indicate whether we are the primary or secondary payer.');
	_codeSet.set('MA84', 'Patient identified as participating in the National Emphysema Treatment Trial but our records indicate that this patient is either not a participant, or has not yet been approved for this phase of the study.  Contact Johns Hopkins University, the study coordinator, to resolve if there was a discrepancy.');
	_codeSet.set('MA85', 'Our records indicate that a primary payer exists (other than ourselves); however, you did not complete or enter accurately the insurance plan/group/program name or identification number.  Enter the PlanID when effective.');
	_codeSet.set('MA86', 'Missing/incomplete/invalid group or policy number of the insured for the primary coverage.');
	_codeSet.set('MA87', 'Missing/incomplete/invalid insureds name for the primary payer.');
	_codeSet.set('MA88', 'Missing/incomplete/invalid insureds address and/or telephone number for the primary payer.');
	_codeSet.set('MA89', 'Missing/incomplete/invalid patients relationship to the insured for the primary payer.');
	_codeSet.set('MA90', 'Missing/incomplete/invalid employment status code for the primary insured.');
	_codeSet.set('MA91', 'This determination is the result of the appeal you filed.');
	_codeSet.set('MA92', 'Missing plan information for other insurance.');
	_codeSet.set('MA93', 'Non-PIP (Periodic Interim Payment) claim.');
	_codeSet.set('MA94', 'Did not enter the statement Attending physician not hospice employee on the claim form to certify that the rendering physician is not an employee of the hospice.');
	_codeSet.set('MA95', 'A not otherwise classified or unlisted procedure code(s) was billed but a narrative description of the procedure was not entered on the claim.  Refer to item 19 on the HCFA-1500.');
	_codeSet.set('MA96', 'Claim rejected. Coded as a Medicare Managed Care Demonstration but patient is not enrolled in a Medicare managed care plan.');
	_codeSet.set('MA97', 'Missing/incomplete/invalid Medicare Managed Care Demonstration contract number or clinical trial registry number.');
	_codeSet.set('MA98', 'Claim Rejected. Does not contain the correct Medicare Managed Care Demonstration contract number for this beneficiary.');
	_codeSet.set('MA99', 'Missing/incomplete/invalid Medigap information.');
	_codeSet.set('MA100', 'Missing/incomplete/invalid date of current illness or symptoms.');
	_codeSet.set('MA101', 'A Skilled Nursing Facility (SNF) is responsible for payment of outside providers who furnish these services/supplies to residents.');
	_codeSet.set('MA102', 'Missing/incomplete/invalid name or provider identifier for the rendering/referring/ ordering/ supervising provider.');
	_codeSet.set('MA103', 'Hemophilia Add On.');
	_codeSet.set('MA104', 'Missing/incomplete/invalid date the patient was last seen or the provider identifier of the attending physician.');
	_codeSet.set('MA105', 'Missing/incomplete/invalid provider number for this place of service.');
	_codeSet.set('MA106', 'PIP (Periodic Interim Payment) claim.');
	_codeSet.set('MA107', 'Paper claim contains more than three separate data items in field 19.');
	_codeSet.set('MA108', 'Paper claim contains more than one data item in field 23.');
	_codeSet.set('MA109', 'Claim processed in accordance with ambulatory surgical guidelines.');
	_codeSet.set('MA110', 'Missing/incomplete/invalid information on whether the diagnostic test(s) were performed by an outside entity or if no purchased tests are included on the claim.');
	_codeSet.set('MA111', 'Missing/incomplete/invalid purchase price of the test(s) and/or the performing laboratorys name and address.');
	_codeSet.set('MA112', 'Missing/incomplete/invalid group practice information.');
	_codeSet.set('MA113', 'Incomplete/invalid taxpayer identification number (TIN) submitted by you per the Internal Revenue Service. Your claims cannot be processed without your correct TIN, and you may not bill the patient pending correction of your TIN.  There are no appeal rights for unprocessable claims, but you may resubmit this claim after you have notified this office of your correct TIN.');
	_codeSet.set('MA114', 'Missing/incomplete/invalid information on where the services were furnished.');
	_codeSet.set('MA115', 'Missing/incomplete/invalid physical location (name and address, or PIN) where the service(s) were rendered in a Health Professional Shortage Area (HPSA).');
	_codeSet.set('MA116', 'Did not complete the statement Homebound on the claim to validate whether laboratory services were performed at home or in an institution.');
	_codeSet.set('MA117', 'This claim has been assessed a $1.00 user fee.');
	_codeSet.set('MA118', 'No Medicare payment issued for this claim for services or supplies furnished to a Medicare-eligible veteran through a facility of the Department of Veterans Affairs. Coinsurance and/or deductible are applicable.');
	_codeSet.set('MA119', 'Provider level adjustment for late claim filing applies to this claim.');
	_codeSet.set('MA120', 'Missing/incomplete/invalid CLIA certification number.');
	_codeSet.set('MA121', 'Missing/incomplete/invalid x-ray date.');
	_codeSet.set('MA122', 'Missing/incomplete/invalid initial treatment date.');
	_codeSet.set('MA123', 'Your center was not selected to participate in this study, therefore, we cannot pay for these services.');
	_codeSet.set('MA124', 'Processed for IME only.');
	_codeSet.set('MA125', 'Per legislation governing this program, payment constitutes payment in full.');
	_codeSet.set('MA126', 'Pancreas transplant not covered unless kidney transplant performed.');
	_codeSet.set('MA127', 'Reserved for future use.');
	_codeSet.set('MA128', 'Missing/incomplete/invalid FDA approval number.');
	_codeSet.set('MA129', 'This provider was not certified for this procedure on this date of service.');
	_codeSet.set('MA130', 'Your claim contains incomplete and/or invalid information, and no appeal rights are afforded because the claim is unprocessable.  Please submit a new claim with the complete/correct information.');
	_codeSet.set('MA131', 'Physician already paid for services in conjunction with this demonstration claim.  You must have the physician withdraw that claim and refund the payment before we can process your claim.');
	_codeSet.set('MA132', 'Adjustment to the pre-demonstration rate.');
	_codeSet.set('MA133', 'Claim overlaps inpatient stay. Rebill only those services rendered outside the inpatient stay.');
	_codeSet.set('MA134', 'Missing/incomplete/invalid provider number of the facility where the patient resides.');
	_codeSet.set('N1', 'You may appeal this decision in writing within the required time limits following receipt of this notice by following the instructions included in your contract, plan benefit documents or jurisdiction statutes. Refer to the URL provided in the ERA for the payer website to access the appeals process guidelines.');
	_codeSet.set('N2', 'This allowance has been made in accordance with the most appropriate course of treatment provision of the plan.');
	_codeSet.set('N3', 'Missing consent form.');
	_codeSet.set('N4', 'Missing/Incomplete/Invalid prior Insurance Carrier(s) EOB.');
	_codeSet.set('N5', 'EOB received from previous payer.  Claim not on file.');
	_codeSet.set('N6', 'Under FEHB law (U.S.C. 8904(b)), we cannot pay more for covered care than the amount Medicare would have allowed if the patient were enrolled in Medicare Part A and/or Medicare Part B.');
	_codeSet.set('N7', 'Processing of this claim/service has included consideration under Major Medical provisions.');
	_codeSet.set('N8', 'Crossover claim denied by previous payer and complete claim data not forwarded. Resubmit this claim to this payer to provide adequate data for adjudication.');
	_codeSet.set('N9', 'Adjustment represents the estimated amount a previous payer may pay.');
	_codeSet.set('N10', 'Adjustment based on the findings of a review organization/professional consult/manual adjudication/medical advisor/dental advisor/peer review.');
	_codeSet.set('N11', 'Denial reversed because of medical review.');
	_codeSet.set('N12', 'Policy provides coverage supplemental to Medicare. As the member does not appear to be enrolled in the applicable part of Medicare, the member is responsible for payment of the portion of the charge that would have been covered by Medicare.');
	_codeSet.set('N13', 'Payment based on professional/technical component modifier(s).');
	_codeSet.set('N14', 'Payment based on a contractual amount or agreement, fee schedule, or maximum allowable amount.');
	_codeSet.set('N15', 'Services for a newborn must be billed separately.');
	_codeSet.set('N16', 'Family/member Out-of-Pocket maximum has been met. Payment based on a higher percentage.');
	_codeSet.set('N17', 'Per admission deductible.');
	_codeSet.set('N18', 'Payment based on the Medicare allowed amount.');
	_codeSet.set('N19', 'Procedure code incidental to primary procedure.');
	_codeSet.set('N20', 'Service not payable with other service rendered on the same date.');
	_codeSet.set('N21', 'Your line item has been separated into multiple lines to expedite handling.');
	_codeSet.set('N22', 'This procedure code was added/changed because it more accurately describes the services rendered.');
	_codeSet.set('N23', 'Patient liability may be affected due to coordination of benefits with other carriers and/or maximum benefit provisions.');
	_codeSet.set('N24', 'Missing/incomplete/invalid Electronic Funds Transfer (EFT) banking information.');
	_codeSet.set('N25', 'This company has been contracted by your benefit plan to provide administrative claims payment services only.  This company does not assume financial risk or obligation with respect to claims processed on behalf of your benefit plan.');
	_codeSet.set('N26', 'Missing itemized bill/statement.');
	_codeSet.set('N27', 'Missing/incomplete/invalid treatment number.');
	_codeSet.set('N28', 'Consent form requirements not fulfilled.');
	_codeSet.set('N29', 'Missing documentation/orders/notes/summary/report/chart.');
	_codeSet.set('N30', 'Patient ineligible for this service.');
	_codeSet.set('N31', 'Missing/incomplete/invalid prescribing provider identifier.');
	_codeSet.set('N32', 'Claim must be submitted by the provider who rendered the service.');
	_codeSet.set('N33', 'No record of health check prior to initiation of treatment.');
	_codeSet.set('N34', 'Incorrect claim form/format for this service.');
	_codeSet.set('N35', 'Program integrity/utilization review decision.');
	_codeSet.set('N36', 'Claim must meet primary payers processing requirements before we can consider payment.');
	_codeSet.set('N37', 'Missing/incomplete/invalid tooth number/letter.');
	_codeSet.set('N38', 'Missing/incomplete/invalid place of service.');
	_codeSet.set('N39', 'Procedure code is not compatible with tooth number/letter.');
	_codeSet.set('N40', 'Missing radiology film(s)/image(s).');
	_codeSet.set('N41', 'Authorization request denied.');
	_codeSet.set('N42', 'Missing mental health assessment.');
	_codeSet.set('N43', 'Bed hold or leave days exceeded.');
	_codeSet.set('N44', 'Payers share of regulatory surcharges, assessments, allowances or health care-related taxes paid directly to the regulatory authority.');
	_codeSet.set('N45', 'Payment based on authorized amount.');
	_codeSet.set('N46', 'Missing/incomplete/invalid admission hour.');
	_codeSet.set('N47', 'Claim conflicts with another inpatient stay.');
	_codeSet.set('N48', 'Claim information does not agree with information received from other insurance carrier.');
	_codeSet.set('N49', 'Court ordered coverage information needs validation.');
	_codeSet.set('N50', 'Missing/incomplete/invalid discharge information.');
	_codeSet.set('N51', 'Electronic interchange agreement not on file for provider/submitter.');
	_codeSet.set('N52', 'Patient not enrolled in the billing providers managed care plan on the date of service.');
	_codeSet.set('N53', 'Missing/incomplete/invalid point of pick-up address.');
	_codeSet.set('N54', 'Claim information is inconsistent with pre-certified/authorized services.');
	_codeSet.set('N55', 'Procedures for billing with group/referring/performing providers were not followed.');
	_codeSet.set('N56', 'Procedure code billed is not correct/valid for the services billed or the date of service billed.');
	_codeSet.set('N57', 'Missing/incomplete/invalid prescribing date.');
	_codeSet.set('N58', 'Missing/incomplete/invalid patient liability amount.');
	_codeSet.set('N59', 'Please refer to your provider manual for additional program and provider information.');
	_codeSet.set('N60', 'A valid NDC is required for payment of drug claims effective October 02.');
	_codeSet.set('N61', 'Rebill services on separate claims.');
	_codeSet.set('N62', 'Dates of service span multiple rate periods. Resubmit separate claims.');
	_codeSet.set('N63', 'Rebill services on separate claim lines.');
	_codeSet.set('N64', 'The from and to dates must be different.');
	_codeSet.set('N65', 'Procedure code or procedure rate count cannot be determined, or was not on file, for the date of service/provider.');
	_codeSet.set('N66', 'Missing/incomplete/invalid documentation.');
	_codeSet.set('N67', 'Professional provider services not paid separately.  Included in facility payment under a demonstration project.  Apply to that facility for payment, or resubmit your claim if: the facility notifies you the patient was excluded from this demonstration; or if you furnished these services in another location on the date of the patients admission or discharge from a demonstration hospital. If services were furnished in a facility not involved in the demonstration on the same date the patient was discharged from or admitted to a demonstration facility, you must report the provider ID number for the non-demonstration facility on the new claim.');
	_codeSet.set('N68', 'Prior payment being cancelled as we were subsequently notified this patient was covered by a demonstration project in this site of service.  Professional services were included in the payment made to the facility. You must contact the facility for your payment.  Prior payment made to you by the patient or another insurer for this claim must be refunded to the payer within 30 days.');
	_codeSet.set('N69', 'PPS (Prospective Payment System) code changed by claims processing system.');
	_codeSet.set('N70', 'Consolidated billing and payment applies.');
	_codeSet.set('N71', 'Your unassigned claim for a drug or biological, clinical diagnostic laboratory services or ambulance service was processed as an assigned claim. You are required by law to accept assignment for these types of claims.');
	_codeSet.set('N72', 'PPS (Prospective Payment System)  code changed by medical reviewers.  Not supported by clinical records.');
	_codeSet.set('N73', 'A Skilled Nursing Facility is responsible for payment of outside providers who furnish these services/supplies under arrangement to its residents.');
	_codeSet.set('N74', 'Resubmit with multiple claims, each claim covering services provided in only one calendar month.');
	_codeSet.set('N75', 'Missing/incomplete/invalid tooth surface information.');
	_codeSet.set('N76', 'Missing/incomplete/invalid number of riders.');
	_codeSet.set('N77', 'Missing/incomplete/invalid designated provider number.');
	_codeSet.set('N78', 'The necessary components of the child and teen checkup (EPSDT) were not completed.');
	_codeSet.set('N79', 'Service billed is not compatible with patient location information.');
	_codeSet.set('N80', 'Missing/incomplete/invalid prenatal screening information.');
	_codeSet.set('N81', 'Procedure billed is not compatible with tooth surface code.');
	_codeSet.set('N82', 'Provider must accept insurance payment as payment in full when a third party payer contract specifies full reimbursement.');
	_codeSet.set('N83', 'No appeal rights. Adjudicative decision based on the provisions of a demonstration project.');
	_codeSet.set('N84', 'Further installment payments are forthcoming.');
	_codeSet.set('N85', 'This is the final installment payment.');
	_codeSet.set('N86', 'A failed trial of pelvic muscle exercise training is required in order for biofeedback training for the treatment of urinary incontinence to be covered.');
	_codeSet.set('N87', 'Home use of biofeedback therapy is not covered.');
	_codeSet.set('N88', 'This payment is being made conditionally.  An HHA episode of care notice has been filed for this patient. When a patient is treated under a HHA episode of care, consolidated billing requires that certain therapy services and supplies, such as this, be included in the HHAs payment.  This payment will need to be recouped from you if we establish that the patient is concurrently receiving treatment under a HHA episode of care.');
	_codeSet.set('N89', 'Payment information for this claim has been forwarded to more than one other payer, but format limitations permit only one of the secondary payers to be identified in this remittance advice.');
	_codeSet.set('N90', 'Covered only when performed by the attending physician.');
	_codeSet.set('N91', 'Services not included in the appeal review.');
	_codeSet.set('N92', 'This facility is not certified for digital mammography.');
	_codeSet.set('N93', 'A separate claim must be submitted for each place of service. Services furnished at multiple sites may not be billed in the same claim.');
	_codeSet.set('N94', 'Claim/Service denied because a more specific taxonomy code is required for adjudication.');
	_codeSet.set('N95', 'This provider type/provider specialty may not bill this service.');
	_codeSet.set('N96', 'Patient must be refractory to conventional therapy (documented behavioral, pharmacologic and/or surgical corrective therapy) and be an appropriate surgical candidate such that implantation with anesthesia can occur.');
	_codeSet.set('N97', 'Patients with stress incontinence, urinary obstruction, and specific neurologic diseases (e.g., diabetes with peripheral nerve involvement) which are associated with secondary manifestations of the above three indications are excluded.');
	_codeSet.set('N98', 'Patient must have had a successful test stimulation in order to support subsequent implantation. Before a patient is eligible for permanent implantation, he/she must demonstrate a 50 percent or greater improvement through test stimulation. Improvement is measured through voiding diaries.');
	_codeSet.set('N99', 'Patient must be able to demonstrate adequate ability to record voiding diary data such that clinical results of the implant procedure can be properly evaluated.');
	_codeSet.set('N100', 'PPS (Prospect Payment System) code corrected during adjudication.');
	_codeSet.set('N101', 'Additional information is needed in order to process this claim. Please resubmit the claim with the identification number of the provider where this service took place. The Medicare number of the site of service provider should be preceded with the letters HSP and entered into item #32 on the claim form. You may bill only one site of service provider number per claim.');
	_codeSet.set('N102', 'This claim has been denied without reviewing the medical/dental record because the requested records were not received or were not received timely.');
	_codeSet.set('N103', 'Records indicate this patient was a prisoner or in custody of a Federal, State, or local authority when the service was rendered. This  payer does not cover items and services furnished to an individual while he or she is in custody under a penal statute or rule, unless under State or local law, the individual is personally liable for the cost of his or her health care while in custody and the State or local government pursues the collection of such debt in the same way and with the same vigor as the collection of its other debts. The provider can collect from the Federal/State/ Local Authority as appropriate.');
	_codeSet.set('N104', 'This claim/service is not payable under our claims jurisdiction area. You can identify the correct Medicare contractor to process this claim/service through the CMS website at www.cms.gov.');
	_codeSet.set('N105', 'This is a misdirected claim/service for an RRB beneficiary. Submit paper claims to the RRB carrier: Palmetto GBA, P.O. Box 10066, Augusta, GA 30999. Call 888-355-9165 for RRB EDI information for electronic claims processing.');
	_codeSet.set('N106', 'Payment for services furnished to Skilled Nursing Facility (SNF) inpatients (except for excluded services) can only be made to the SNF. You must request payment from the SNF rather than the patient for this service.');
	_codeSet.set('N107', 'Services furnished to Skilled Nursing Facility (SNF) inpatients must be billed on the inpatient claim. They cannot be billed separately as outpatient services.');
	_codeSet.set('N108', 'Missing/incomplete/invalid upgrade information.');
	_codeSet.set('N109', 'This claim/service was chosen for complex review.');
	_codeSet.set('N110', 'This facility is not certified for film mammography.');
	_codeSet.set('N111', 'No appeal right except duplicate claim/service issue. This service was included in a claim that has been previously billed and adjudicated.');
	_codeSet.set('N112', 'This claim is excluded from your electronic remittance advice.');
	_codeSet.set('N113', 'Only one initial visit is covered per physician, group practice or provider.');
	_codeSet.set('N114', 'During the transition to the Ambulance Fee Schedule, payment is based on the lesser of a blended amount calculated using a percentage of the reasonable charge/cost and fee schedule amounts, or the submitted charge for the service.  You will be notified yearly what the percentages for the blended payment calculation will be.');
	_codeSet.set('N115', 'This decision was based on a Local Coverage Determination (LCD).  An LCD provides a guide to assist in determining whether a particular item or service is covered. A copy of this policy is available at www.cms.gov/mcd, or if you do not have web access, you may contact the contractor to request a copy of the LCD.');
	_codeSet.set('N116', 'This payment is being made conditionally because the service was provided in the home, and it is possible that the patient is under a home health episode of care. When a patient is treated under a home health episode of care, consolidated billing requires that certain therapy services and supplies, such as this, be included in the home health agencys (HHAs) payment. This payment will need to be recouped from you if we establish that the patient is concurrently receiving treatment under an HHA episode of care.');
	_codeSet.set('N117', 'This service is paid only once in a patients lifetime.');
	_codeSet.set('N118', 'This service is not paid if billed more than once every 28 days.');
	_codeSet.set('N119', 'This service is not paid if billed once every 28 days, and the patient has spent 5 or more consecutive days in any inpatient or Skilled /nursing Facility (SNF) within those 28 days.');
	_codeSet.set('N120', 'Payment is subject to home health prospective payment system partial episode payment adjustment. Patient was transferred/discharged/readmitted during payment episode.');
	_codeSet.set('N121', 'Medicare Part B does not pay for items or services provided by this type of practitioner for beneficiaries in a Medicare Part A covered Skilled Nursing Facility (SNF) stay.');
	_codeSet.set('N122', 'Add-on code cannot be billed by itself.');
	_codeSet.set('N123', 'This is a split service and represents a portion of the units from the originally submitted service.');
	_codeSet.set('N124', 'Payment has been denied for the/made only for a less extensive service/item because the information furnished does not substantiate the need for the (more extensive) service/item. The patient is liable for the charges for this service/item as you informed the patient in writing before the service/item was furnished that we would not pay for it, and the patient agreed to pay.');
	_codeSet.set('N125', 'Payment has been (denied for the/made only for a less extensive) service/item because the information furnished does not substantiate the need for the (more extensive) service/item. If you have collected any amount from the patient, you must refund that amount to the patient within 30 days of receiving this notice.The requirements for a refund are in §1834(a)(18) of the Social Security Act (and in §§1834(j)(4) and 1879(h) by cross-reference to §1834(a)(18)). Section 1834(a)(18)(B) specifies that suppliers which knowingly and willfully fail to make appropriate refunds may be subject to civil money penalties and/or exclusion from the Medicare program. If you have any questions about this notice, please contact this office.');
	_codeSet.set('N126', 'Social Security Records indicate that this individual has been deported. This payer does not cover items and services furnished to individuals who have been deported.');
	_codeSet.set('N127', 'This is a misdirected claim/service for a United Mine Workers of America (UMWA) beneficiary. Please submit claims to them.');
	_codeSet.set('N128', 'This amount represents the prior to coverage portion of the allowance.');
	_codeSet.set('N129', 'Not eligible due to the patients age.');
	_codeSet.set('N130', 'Consult plan benefit documents/guidelines for information about restrictions for this service.');
	_codeSet.set('N131', 'Total payments under multiple contracts cannot exceed the allowance for this service.');
	_codeSet.set('N132', 'Payments will cease for services rendered by this US Government debarred or excluded provider after the 30 day grace period as previously notified.');
	_codeSet.set('N133', 'Services for predetermination and services requesting payment are being processed separately.');
	_codeSet.set('N134', 'This represents your scheduled payment for this service. If treatment has been discontinued, please contact Customer Service.');
	_codeSet.set('N135', 'Record fees are the patients responsibility and limited to the specified co-payment.');
	_codeSet.set('N136', 'To obtain information on the process to file an appeal in Arizona, call the Departments Consumer Assistance Office at (602) 912-8444 or (800) 325-2548.');
	_codeSet.set('N137', 'The provider acting on the Members behalf, may file an appeal with the Payer. The provider, acting on the Members behalf, may file a complaint with the State Insurance Regulatory Authority without first filing an appeal, if the coverage decision involves an urgent condition for which care has not been rendered. The address may be obtained from the State Insurance Regulatory Authority.');
	_codeSet.set('N138', 'In the event you disagree with the Dental Advisors opinion and have additional information relative to the case, you may submit radiographs to the Dental Advisor Unit at the subscribers dental insurance carrier for a second Independent Dental Advisor Review.');
	_codeSet.set('N139', 'Under 32 CFR 199.13, a non-participating provider is not an appropriate appealing party. Therefore, if you disagree with the Dental Advisors opinion, you may appeal the determination if appointed in writing, by the beneficiary, to act as his/her representative. Should you be appointed as a representative, submit a copy of this letter, a signed statement explaining the matter in which you disagree, and any radiographs and relevant information to the subscribers Dental insurance carrier within 90 days from the date of this letter.');
	_codeSet.set('N140', 'You have not been designated as an authorized OCONUS provider therefore are not considered an appropriate appealing party. If the beneficiary has appointed you, in writing, to act as his/her representative and you disagree with the Dental Advisors opinion, you may appeal by submitting a copy of this letter, a signed statement explaining the matter in which you disagree, and any relevant information to the subscribers Dental insurance carrier within 90 days from the date of this letter.');
	_codeSet.set('N141', 'The patient was not residing in a long-term care facility during all or part of the service dates billed.');
	_codeSet.set('N142', 'The original claim was denied.  Resubmit a new claim, not a replacement claim.');
	_codeSet.set('N143', 'The patient was not in a hospice program during all or part of the service dates billed.');
	_codeSet.set('N144', 'The rate changed during the dates of service billed.');
	_codeSet.set('N145', 'Missing/incomplete/invalid provider identifier for this place of service.');
	_codeSet.set('N146', 'Missing screening document.');
	_codeSet.set('N147', 'Long term care case mix or per diem rate cannot be determined because the patient ID number is missing, incomplete, or invalid on the assignment request.');
	_codeSet.set('N148', 'Missing/incomplete/invalid date of last menstrual period.');
	_codeSet.set('N149', 'Rebill all applicable services on a single claim.');
	_codeSet.set('N150', 'Missing/incomplete/invalid model number.');
	_codeSet.set('N151', 'Telephone contact services will not be paid until the face-to-face contact requirement has been met.');
	_codeSet.set('N152', 'Missing/incomplete/invalid replacement claim information.');
	_codeSet.set('N153', 'Missing/incomplete/invalid room and board rate.');
	_codeSet.set('N154', 'This payment was delayed for correction of providers mailing address.');
	_codeSet.set('N155', 'Our records do not indicate that other insurance is on file.  Please submit other insurance information for our records.');
	_codeSet.set('N156', 'The patient is responsible for the difference between the approved treatment and the elective treatment.');
	_codeSet.set('N157', 'Transportation to/from this destination is not covered.');
	_codeSet.set('N158', 'Transportation in a vehicle other than an ambulance is not covered.');
	_codeSet.set('N159', 'Payment denied/reduced because mileage is not covered when the patient is not in the ambulance.');
	_codeSet.set('N160', 'The patient must choose an option before a payment can be made for this procedure/ equipment/ supply/ service.');
	_codeSet.set('N161', 'This drug/service/supply is covered only when the associated service is covered.');
	_codeSet.set('N162', 'Although your claim was paid, you have billed for a test/specialty not included in your Laboratory Certification.  Your failure to correct the laboratory certification information will result in a denial of payment in the near future.');
	_codeSet.set('N163', 'Medical record does not support code billed per the code definition.');
	_codeSet.set('N164', 'Transportation to/from this destination is not covered.');
	_codeSet.set('N165', 'Transportation in a vehicle other than an ambulance is not covered.');
	_codeSet.set('N166', 'Payment denied/reduced because mileage is not covered when the patient is not in the ambulance.');
	_codeSet.set('N167', 'Charges exceed the post-transplant coverage limit.');
	_codeSet.set('N168', 'The patient must choose an option before a payment can be made for this procedure/ equipment/ supply/ service.');
	_codeSet.set('N169', 'This drug/service/supply is covered only when the associated service is covered.');
	_codeSet.set('N170', 'A new/revised/renewed certificate of medical necessity is needed.');
	_codeSet.set('N171', 'Payment for repair or replacement is not covered or has exceeded the purchase price.');
	_codeSet.set('N172', 'The patient is not liable for the denied/adjusted charge(s) for receiving any updated service/item.');
	_codeSet.set('N173', 'No qualifying hospital stay dates were provided for this episode of care.');
	_codeSet.set('N174', 'This is not a covered service/procedure/ equipment/bed, however patient liability is limited to amounts shown in the adjustments under group PR.');
	_codeSet.set('N175', 'Missing review organization approval.');
	_codeSet.set('N176', 'Services provided aboard a ship are covered only when the ship is of United States registry and is in United States waters. In addition, a doctor licensed to practice in the United States must provide the service.');
	_codeSet.set('N177', 'We did not send this claim to patients other insurer. They have indicated no additional payment can be made.');
	_codeSet.set('N178', 'Missing pre-operative images/visual field results.');
	_codeSet.set('N179', 'Additional information has been requested from the member.  The charges will be reconsidered upon receipt of that information.');
	_codeSet.set('N180', 'This item or service does not meet the criteria for the category under which it was billed.');
	_codeSet.set('N181', 'Additional information is required from another provider involved in this service.');
	_codeSet.set('N182', 'This claim/service must be billed according to the schedule for this plan.');
	_codeSet.set('N183', 'This is a predetermination advisory message, when this service is submitted for payment additional documentation as specified in plan documents will be required to process benefits.');
	_codeSet.set('N184', 'Rebill technical and professional components separately.');
	_codeSet.set('N185', 'Do not resubmit this claim/service.');
	_codeSet.set('N186', 'Non-Availability Statement (NAS) required for this service. Contact the nearest Military Treatment Facility (MTF) for assistance.');
	_codeSet.set('N187', 'You may request a review in writing within the required time limits following receipt of this notice by following the instructions included in your contract or plan benefit documents.');
	_codeSet.set('N188', 'The approved level of care does not match the procedure code submitted.');
	_codeSet.set('N189', 'This service has been paid as a one-time exception to the plans benefit restrictions.');
	_codeSet.set('N190', 'Missing contract indicator.');
	_codeSet.set('N191', 'The provider must update insurance information directly with payer.');
	_codeSet.set('N192', 'Patient is a Medicaid/Qualified Medicare Beneficiary.');
	_codeSet.set('N193', 'Specific federal/state/local program may cover this service through another payer.');
	_codeSet.set('N194', 'Technical component not paid if provider does not own the equipment used.');
	_codeSet.set('N195', 'The technical component must be billed separately.');
	_codeSet.set('N196', 'Patient eligible to apply for other coverage which may be primary.');
	_codeSet.set('N197', 'The subscriber must update insurance information directly with payer.');
	_codeSet.set('N198', 'Rendering provider must be affiliated with the pay-to provider.');
	_codeSet.set('N199', 'Additional payment/recoupment approved based on payer-initiated review/audit.');
	_codeSet.set('N200', 'The professional component must be billed separately.');
	_codeSet.set('N201', 'A mental health facility is responsible for payment of outside providers who furnish these services/supplies to residents.');
	_codeSet.set('N202', 'Additional information/explanation will be sent separately.');
	_codeSet.set('N203', 'Missing/incomplete/invalid anesthesia time/units.');
	_codeSet.set('N204', 'Services under review for possible pre-existing condition. Send medical records for prior 12 months');
	_codeSet.set('N205', 'Information provided was illegible.');
	_codeSet.set('N206', 'The supporting documentation does not match the information sent on the claim.');
	_codeSet.set('N207', 'Missing/incomplete/invalid weight.');
	_codeSet.set('N208', 'Missing/incomplete/invalid DRG code.');
	_codeSet.set('N209', 'Missing/incomplete/invalid taxpayer identification number (TIN).');
	_codeSet.set('N210', 'You may appeal this decision.');
	_codeSet.set('N211', 'You may not appeal this decision.');
	_codeSet.set('N212', 'Charges processed under a Point of Service benefit.');
	_codeSet.set('N213', 'Missing/incomplete/invalid facility/discrete unit DRG/DRG exempt status information.');
	_codeSet.set('N214', 'Missing/incomplete/invalid history of the related initial surgical procedure(s).');
	_codeSet.set('N215', 'A payer providing supplemental or secondary coverage shall not require a claims determination for this service from a primary payer as a condition of making its own claims determination.');
	_codeSet.set('N216', 'We do not offer coverage for this type of service or the patient is not enrolled in this portion of our benefit package.');
	_codeSet.set('N217', 'We pay only one site of service per provider per claim.');
	_codeSet.set('N218', 'You must furnish and service this item for as long as the patient continues to need it.  We can pay for maintenance and/or servicing for the time period specified in the contract or coverage manual.');
	_codeSet.set('N219', 'Payment based on previous payers allowed amount.');
	_codeSet.set('N220', 'See the payers web site or contact the payers Customer Service department to obtain forms and instructions for filing a provider dispute.');
	_codeSet.set('N221', 'Missing Admitting History and Physical report.');
	_codeSet.set('N222', 'Incomplete/invalid Admitting History and Physical report.');
	_codeSet.set('N223', 'Missing documentation of benefit to the patient during initial treatment period.');
	_codeSet.set('N224', 'Incomplete/invalid documentation of benefit to the patient during initial treatment period.');
	_codeSet.set('N225', 'Incomplete/invalid documentation/orders/notes/summary/report/chart.');
	_codeSet.set('N226', 'Incomplete/invalid American Diabetes Association Certificate of Recognition.');
	_codeSet.set('N227', 'Incomplete/invalid Certificate of Medical Necessity.');
	_codeSet.set('N228', 'Incomplete/invalid consent form.');
	_codeSet.set('N229', 'Incomplete/invalid contract indicator.');
	_codeSet.set('N230', 'Incomplete/invalid indication of whether the patient owns the equipment that requires the part or supply.');
	_codeSet.set('N231', 'Incomplete/invalid invoice or statement certifying the actual cost of the lens, less discounts, and/or the type of intraocular lens used.');
	_codeSet.set('N232', 'Incomplete/invalid itemized bill/statement.');
	_codeSet.set('N233', 'Incomplete/invalid operative note/report.');
	_codeSet.set('N234', 'Incomplete/invalid oxygen certification/re-certification.');
	_codeSet.set('N235', 'Incomplete/invalid pacemaker registration form.');
	_codeSet.set('N236', 'Incomplete/invalid pathology report.');
	_codeSet.set('N237', 'Incomplete/invalid patient medical record for this service.');
	_codeSet.set('N238', 'Incomplete/invalid physician certified plan of care.');
	_codeSet.set('N239', 'Incomplete/invalid physician financial relationship form.');
	_codeSet.set('N240', 'Incomplete/invalid radiology report.');
	_codeSet.set('N241', 'Incomplete/invalid review organization approval.');
	_codeSet.set('N242', 'Incomplete/invalid radiology film(s)/image(s).');
	_codeSet.set('N243', 'Incomplete/invalid/not approved screening document.');
	_codeSet.set('N244', 'Incomplete/Invalid pre-operative  images/visual field results.');
	_codeSet.set('N245', 'Incomplete/invalid plan information for other insurance.');
	_codeSet.set('N246', 'State regulated patient payment limitations apply to this service.');
	_codeSet.set('N247', 'Missing/incomplete/invalid assistant surgeon taxonomy.');
	_codeSet.set('N248', 'Missing/incomplete/invalid assistant surgeon name.');
	_codeSet.set('N249', 'Missing/incomplete/invalid assistant surgeon primary identifier.');
	_codeSet.set('N250', 'Missing/incomplete/invalid assistant surgeon secondary identifier.');
	_codeSet.set('N251', 'Missing/incomplete/invalid attending provider taxonomy.');
	_codeSet.set('N252', 'Missing/incomplete/invalid attending provider name.');
	_codeSet.set('N253', 'Missing/incomplete/invalid attending provider primary identifier.');
	_codeSet.set('N254', 'Missing/incomplete/invalid attending provider secondary identifier.');
	_codeSet.set('N255', 'Missing/incomplete/invalid billing provider taxonomy.');
	_codeSet.set('N256', 'Missing/incomplete/invalid billing provider/supplier name.');
	_codeSet.set('N257', 'Missing/incomplete/invalid billing provider/supplier primary identifier.');
	_codeSet.set('N258', 'Missing/incomplete/invalid billing provider/supplier address.');
	_codeSet.set('N259', 'Missing/incomplete/invalid billing provider/supplier secondary identifier.');
	_codeSet.set('N260', 'Missing/incomplete/invalid billing provider/supplier contact information.');
	_codeSet.set('N261', 'Missing/incomplete/invalid operating provider name.');
	_codeSet.set('N262', 'Missing/incomplete/invalid operating provider primary identifier.');
	_codeSet.set('N263', 'Missing/incomplete/invalid operating provider secondary identifier.');
	_codeSet.set('N264', 'Missing/incomplete/invalid ordering provider name.');
	_codeSet.set('N265', 'Missing/incomplete/invalid ordering provider primary identifier.');
	_codeSet.set('N266', 'Missing/incomplete/invalid ordering provider address.');
	_codeSet.set('N267', 'Missing/incomplete/invalid ordering provider secondary identifier.');
	_codeSet.set('N268', 'Missing/incomplete/invalid ordering provider contact information.');
	_codeSet.set('N269', 'Missing/incomplete/invalid other provider name.');
	_codeSet.set('N270', 'Missing/incomplete/invalid other provider primary identifier.');
	_codeSet.set('N271', 'Missing/incomplete/invalid other provider secondary identifier.');
	_codeSet.set('N272', 'Missing/incomplete/invalid other payer attending provider identifier.');
	_codeSet.set('N273', 'Missing/incomplete/invalid other payer operating provider identifier.');
	_codeSet.set('N274', 'Missing/incomplete/invalid other payer other provider identifier.');
	_codeSet.set('N275', 'Missing/incomplete/invalid other payer purchased service provider identifier.');
	_codeSet.set('N276', 'Missing/incomplete/invalid other payer referring provider identifier.');
	_codeSet.set('N277', 'Missing/incomplete/invalid other payer rendering provider identifier.');
	_codeSet.set('N278', 'Missing/incomplete/invalid other payer service facility provider identifier.');
	_codeSet.set('N279', 'Missing/incomplete/invalid pay-to provider name.');
	_codeSet.set('N280', 'Missing/incomplete/invalid pay-to provider primary identifier.');
	_codeSet.set('N281', 'Missing/incomplete/invalid pay-to provider address.');
	_codeSet.set('N282', 'Missing/incomplete/invalid pay-to provider secondary identifier.');
	_codeSet.set('N283', 'Missing/incomplete/invalid purchased service provider identifier.');
	_codeSet.set('N284', 'Missing/incomplete/invalid referring provider taxonomy.');
	_codeSet.set('N285', 'Missing/incomplete/invalid referring provider name.');
	_codeSet.set('N286', 'Missing/incomplete/invalid referring provider primary identifier.');
	_codeSet.set('N287', 'Missing/incomplete/invalid referring provider secondary identifier.');
	_codeSet.set('N288', 'Missing/incomplete/invalid rendering provider taxonomy.');
	_codeSet.set('N289', 'Missing/incomplete/invalid rendering provider name.');
	_codeSet.set('N290', 'Missing/incomplete/invalid rendering provider primary identifier.');
	_codeSet.set('N291', 'Missing/incomplete/invalid rendering provider secondary identifier.');
	_codeSet.set('N292', 'Missing/incomplete/invalid service facility name.');
	_codeSet.set('N293', 'Missing/incomplete/invalid service facility primary identifier.');
	_codeSet.set('N294', 'Missing/incomplete/invalid service facility primary address.');
	_codeSet.set('N295', 'Missing/incomplete/invalid service facility secondary identifier.');
	_codeSet.set('N296', 'Missing/incomplete/invalid supervising provider name.');
	_codeSet.set('N297', 'Missing/incomplete/invalid supervising provider primary identifier.');
	_codeSet.set('N298', 'Missing/incomplete/invalid supervising provider secondary identifier.');
	_codeSet.set('N299', 'Missing/incomplete/invalid occurrence date(s).');
	_codeSet.set('N300', 'Missing/incomplete/invalid occurrence span date(s).');
	_codeSet.set('N301', 'Missing/incomplete/invalid procedure date(s).');
	_codeSet.set('N302', 'Missing/incomplete/invalid other procedure date(s).');
	_codeSet.set('N303', 'Missing/incomplete/invalid principal procedure date.');
	_codeSet.set('N304', 'Missing/incomplete/invalid dispensed date.');
	_codeSet.set('N305', 'Missing/incomplete/invalid injury/accident date.');
	_codeSet.set('N306', 'Missing/incomplete/invalid acute manifestation date.');
	_codeSet.set('N307', 'Missing/incomplete/invalid adjudication or payment date.');
	_codeSet.set('N308', 'Missing/incomplete/invalid appliance placement date.');
	_codeSet.set('N309', 'Missing/incomplete/invalid assessment date.');
	_codeSet.set('N310', 'Missing/incomplete/invalid assumed or relinquished care date.');
	_codeSet.set('N311', 'Missing/incomplete/invalid authorized to return to work date.');
	_codeSet.set('N312', 'Missing/incomplete/invalid begin therapy date.');
	_codeSet.set('N313', 'Missing/incomplete/invalid certification revision date.');
	_codeSet.set('N314', 'Missing/incomplete/invalid diagnosis date.');
	_codeSet.set('N315', 'Missing/incomplete/invalid disability from date.');
	_codeSet.set('N316', 'Missing/incomplete/invalid disability to date.');
	_codeSet.set('N317', 'Missing/incomplete/invalid discharge hour.');
	_codeSet.set('N318', 'Missing/incomplete/invalid discharge or end of care date.');
	_codeSet.set('N319', 'Missing/incomplete/invalid hearing or vision prescription date.');
	_codeSet.set('N320', 'Missing/incomplete/invalid Home Health Certification Period.');
	_codeSet.set('N321', 'Missing/incomplete/invalid last admission period.');
	_codeSet.set('N322', 'Missing/incomplete/invalid last certification date.');
	_codeSet.set('N323', 'Missing/incomplete/invalid last contact date.');
	_codeSet.set('N324', 'Missing/incomplete/invalid last seen/visit date.');
	_codeSet.set('N325', 'Missing/incomplete/invalid last worked date.');
	_codeSet.set('N326', 'Missing/incomplete/invalid last x-ray date.');
	_codeSet.set('N327', 'Missing/incomplete/invalid other insured birth date.');
	_codeSet.set('N328', 'Missing/incomplete/invalid Oxygen Saturation Test date.');
	_codeSet.set('N329', 'Missing/incomplete/invalid patient birth date.');
	_codeSet.set('N330', 'Missing/incomplete/invalid patient death date.');
	_codeSet.set('N331', 'Missing/incomplete/invalid physician order date.');
	_codeSet.set('N332', 'Missing/incomplete/invalid prior hospital discharge date.');
	_codeSet.set('N333', 'Missing/incomplete/invalid prior placement date.');
	_codeSet.set('N334', 'Missing/incomplete/invalid re-evaluation date.');
	_codeSet.set('N335', 'Missing/incomplete/invalid referral date.');
	_codeSet.set('N336', 'Missing/incomplete/invalid replacement date.');
	_codeSet.set('N337', 'Missing/incomplete/invalid secondary diagnosis date.');
	_codeSet.set('N338', 'Missing/incomplete/invalid shipped date.');
	_codeSet.set('N339', 'Missing/incomplete/invalid similar illness or symptom date.');
	_codeSet.set('N340', 'Missing/incomplete/invalid subscriber birth date.');
	_codeSet.set('N341', 'Missing/incomplete/invalid surgery date.');
	_codeSet.set('N342', 'Missing/incomplete/invalid test performed date.');
	_codeSet.set('N343', 'Missing/incomplete/invalid Transcutaneous Electrical Nerve Stimulator (TENS) trial start date.');
	_codeSet.set('N344', 'Missing/incomplete/invalid Transcutaneous Electrical Nerve Stimulator (TENS) trial end date.');
	_codeSet.set('N345', 'Date range not valid with units submitted.');
	_codeSet.set('N346', 'Missing/incomplete/invalid oral cavity designation code.');
	_codeSet.set('N347', 'Your claim for a referred or purchased service cannot be paid because payment has already been made for this same service to another provider by a payment contractor representing the payer.');
	_codeSet.set('N348', 'You chose that this service/supply/drug would be rendered/supplied and billed by a different practitioner/supplier.');
	_codeSet.set('N349', 'The administration method and drug must be reported to adjudicate this service.');
	_codeSet.set('N350', 'Missing/incomplete/invalid description of service for a Not Otherwise Classified (NOC) code or for an Unlisted/By Report procedure.');
	_codeSet.set('N351', 'Service date outside of the approved treatment plan service dates.');
	_codeSet.set('N352', 'There are no scheduled payments for this service. Submit a claim for each patient visit.');
	_codeSet.set('N353', 'Benefits have been estimated, when the actual services have been rendered, additional payment will be considered based on the submitted claim.');
	_codeSet.set('N354', 'Incomplete/invalid invoice.');
	_codeSet.set('N355', 'The law permits exceptions to the refund requirement in two cases: - If you did not know, and could not have reasonably been expected to know, that we would not pay for this service; or - If you notified the patient in writing before providing the service that you believed that we were likely to deny the service, and the patient signed a statement agreeing to pay for the service.If you come within either exception, or if you believe the carrier was wrong in its determination that we do not pay for this service, you should request appeal of this determination within 30 days of the date of this notice. Your request for review should include any additional information necessary to support your position.If you request an appeal within 30 days of receiving this notice, you may delay refunding the amount to the patient until you receive the results of the review. If the review decision is favorable to you, you do not need to make any refund. If, however, the review is unfavorable, the law specifies that you must make the refund within 15 days of receiving the unfavorable review decision.The law also permits you to request an appeal at any time within 120 days of the date you receive this notice. However, an appeal request that is received more than 30 days after the date of this notice, does not permit you to delay making the refund. Regardless of when a review is requested, the patient will be notified that you have requested one, and will receive a copy of the determination.The patient has received a separate notice of this denial decision. The notice advises that he/she may be entitled to a refund of any amounts paid, if you should have known that we would not pay and did not tell him/her. It also instructs the patient to contact our office if he/she does not hear anything about a refund within 30 days');
	_codeSet.set('N356', 'Not covered when performed with, or subsequent to, a non-covered service.');
	_codeSet.set('N357', 'Time frame requirements between this service/procedure/supply and a related service/procedure/supply have not been met.');
	_codeSet.set('N358', 'This decision may be reviewed if additional documentation as described in the contract or plan benefit documents is submitted.');
	_codeSet.set('N359', 'Missing/incomplete/invalid height.');
	_codeSet.set('N360', 'Coordination of benefits has not been calculated when estimating benefits for this pre-determination. Submit payment information from the primary payer with the secondary claim.');
	_codeSet.set('N361', 'Payment adjusted based on multiple diagnostic imaging procedure rules');
	_codeSet.set('N362', 'The number of Days or Units of Service exceeds our acceptable maximum.');
	_codeSet.set('N363', 'in the near future we are implementing new policies/procedures that would affect this determination.');
	_codeSet.set('N364', 'According to our agreement, you must waive the deductible and/or coinsurance amounts.');
	_codeSet.set('N365', 'This procedure code is not payable. It is for reporting/information purposes only.');
	_codeSet.set('N366', 'Requested information not provided. The claim will be reopened if the information previously requested is submitted within one year after the date of this denial notice.');
	_codeSet.set('N367', 'The claim information has been forwarded to a Consumer Spending Account processor for review; for example, flexible spending account or health savings account.');
	_codeSet.set('N368', 'You must appeal the determination of the previously adjudicated claim.');
	_codeSet.set('N369', 'Although this claim has been processed, it is deficient according to state legislation/regulation.');
	_codeSet.set('N370', 'Billing exceeds the rental months covered/approved by the payer.');
	_codeSet.set('N371', 'title of this equipment must be transferred to the patient.');
	_codeSet.set('N372', 'Only reasonable and necessary maintenance/service charges are covered.');
	_codeSet.set('N373', 'It has been determined that another payer paid the services as primary when they were not the primary payer. Therefore, we are refunding to the payer that paid as primary on your behalf.');
	_codeSet.set('N374', 'Primary Medicare Part A insurance has been exhausted and a Part B Remittance Advice is required.');
	_codeSet.set('N375', 'Missing/incomplete/invalid questionnaire/information required to determine dependent eligibility.');
	_codeSet.set('N376', 'Subscriber/patient is assigned to active military duty, therefore primary coverage may be TRICARE.');
	_codeSet.set('N377', 'Payment based on a processed replacement claim.');
	_codeSet.set('N378', 'Missing/incomplete/invalid prescription quantity.');
	_codeSet.set('N379', 'Claim level information does not match line level information.');
	_codeSet.set('N380', 'The original claim  has been processed, submit a corrected claim.');
	_codeSet.set('N381', 'Consult our contractual agreement for restrictions/billing/payment information related to these charges.');
	_codeSet.set('N382', 'Missing/incomplete/invalid patient identifier.');
	_codeSet.set('N383', 'Not covered when deemed cosmetic.');
	_codeSet.set('N384', 'Records indicate that the referenced body part/tooth has been removed in a previous procedure.');
	_codeSet.set('N385', 'Notification of admission was not timely according to published plan procedures.');
	_codeSet.set('N386', 'This decision was based on a National Coverage Determination (NCD). An NCD provides a coverage determination as to whether a particular item or service is covered. A copy of this policy is available at www.cms.gov/mcd/search.asp. If you do not have web access, you may contact the contractor to request a copy of the NCD.');
	_codeSet.set('N387', 'Submit this claim to the patients other insurer for potential payment of supplemental benefits. We did not forward the claim information.');
	_codeSet.set('N388', 'Missing/incomplete/invalid prescription number.');
	_codeSet.set('N389', 'Duplicate prescription number submitted.');
	_codeSet.set('N390', 'This service/report cannot be billed separately.');
	_codeSet.set('N391', 'Missing emergency department records.');
	_codeSet.set('N392', 'Incomplete/invalid emergency department records.');
	_codeSet.set('N393', 'Missing progress notes/report.');
	_codeSet.set('N394', 'Incomplete/invalid progress notes/report.');
	_codeSet.set('N395', 'Missing laboratory report.');
	_codeSet.set('N396', 'Incomplete/invalid laboratory report.');
	_codeSet.set('N397', 'Benefits are not available for incomplete service(s)/undelivered item(s).');
	_codeSet.set('N398', 'Missing elective consent form.');
	_codeSet.set('N399', 'Incomplete/invalid elective consent form.');
	_codeSet.set('N400', 'Electronically enabled providers should submit claims electronically.');
	_codeSet.set('N401', 'Missing periodontal charting.');
	_codeSet.set('N402', 'Incomplete/invalid periodontal charting.');
	_codeSet.set('N403', 'Missing facility certification.');
	_codeSet.set('N404', 'Incomplete/invalid facility certification.');
	_codeSet.set('N405', 'This service is only covered when the donors insurer(s) do not provide coverage for the service.');
	_codeSet.set('N406', 'This service is only covered when the recipients insurer(s) do not provide coverage for the service.');
	_codeSet.set('N407', 'You are not an approved submitter for this transmission format.');
	_codeSet.set('N408', 'This payer does not cover deductibles assessed by a previous payer.');
	_codeSet.set('N409', 'This service is related to an accidental injury and is not covered unless provided within a specific time frame from the date of the accident.');
	_codeSet.set('N410', 'Not covered unless the prescription changes.');
	_codeSet.set('N411', 'This service is allowed one time in a 6-month period.');
	_codeSet.set('N412', 'This service is allowed 2 times in a 12-month period.');
	_codeSet.set('N413', 'This service is allowed 2 times in a benefit year.');
	_codeSet.set('N414', 'This service is allowed 4 times in a 12-month period.');
	_codeSet.set('N415', 'This service is allowed 1 time in an 18-month period.');
	_codeSet.set('N416', 'This service is allowed 1 time in a 3-year period.');
	_codeSet.set('N417', 'This service is allowed 1 time in a 5-year period.');
	_codeSet.set('N418', 'Misrouted claim.  See the payers claim submission instructions.');
	_codeSet.set('N419', 'Claim payment was the result of a payers retroactive adjustment due to a retroactive rate change.');
	_codeSet.set('N420', 'Claim payment was the result of a payers retroactive adjustment due to a Coordination of Benefits or Third Party Liability Recovery.');
	_codeSet.set('N421', 'Claim payment was the result of a payers retroactive adjustment due to a review organization decision.');
	_codeSet.set('N422', 'Claim payment was the result of a payers retroactive adjustment due to a payers contract incentive program.');
	_codeSet.set('N423', 'Claim payment was the result of a payers retroactive adjustment due to a non standard program.');
	_codeSet.set('N424', 'Patient does not reside in the geographic area required for this type of payment.');
	_codeSet.set('N425', 'Statutorily excluded service(s).');
	_codeSet.set('N426', 'No coverage when self-administered.');
	_codeSet.set('N427', 'Payment for eyeglasses or contact lenses can be made only after cataract surgery.');
	_codeSet.set('N428', 'Not covered when performed in this place of service.');
	_codeSet.set('N429', 'Not covered when considered routine.');
	_codeSet.set('N430', 'Procedure code is inconsistent with the units billed.');
	_codeSet.set('N431', 'Not covered with this procedure.');
	_codeSet.set('N432', 'Adjustment based on a Recovery Audit.');
	_codeSet.set('N433', 'Resubmit this claim using only your National Provider Identifier (NPI).');
	_codeSet.set('N434', 'Missing/Incomplete/Invalid Present on Admission indicator.');
	_codeSet.set('N435', 'Exceeds number/frequency approved /allowed within time period without support documentation.');
	_codeSet.set('N436', 'The injury claim has not been accepted and a mandatory medical reimbursement has been made.');
	_codeSet.set('N437', 'If the injury claim is accepted, these charges will be reconsidered.');
	_codeSet.set('N438', 'This jurisdiction only accepts paper claims.');
	_codeSet.set('N439', 'Missing anesthesia physical status report/indicators.');
	_codeSet.set('N440', 'Incomplete/invalid anesthesia physical status report/indicators.');
	_codeSet.set('N441', 'This missed/cancelled appointment is not covered.');
	_codeSet.set('N442', 'Payment based on an alternate fee schedule.');
	_codeSet.set('N443', 'Missing/incomplete/invalid total time or begin/end time.');
	_codeSet.set('N444', 'This facility has not filed the Election for High Cost Outlier form with the Division of Workers Compensation.');
	_codeSet.set('N445', 'Missing document for actual cost or paid amount.');
	_codeSet.set('N446', 'Incomplete/invalid document for actual cost or paid amount.');
	_codeSet.set('N447', 'Payment is based on a generic equivalent as required documentation was not provided.');
	_codeSet.set('N448', 'This drug/service/supply is not included in the fee schedule or contracted/legislated fee arrangement.');
	_codeSet.set('N449', 'Payment based on a comparable drug/service/supply.');
	_codeSet.set('N450', 'Covered only when performed by the primary treating physician or the designee.');
	_codeSet.set('N451', 'Missing Admission Summary Report.');
	_codeSet.set('N452', 'Incomplete/invalid Admission Summary Report.');
	_codeSet.set('N453', 'Missing Consultation Report.');
	_codeSet.set('N454', 'Incomplete/invalid Consultation Report.');
	_codeSet.set('N455', 'Missing Physician Order.');
	_codeSet.set('N456', 'Incomplete/invalid Physician Order.');
	_codeSet.set('N457', 'Missing Diagnostic Report.');
	_codeSet.set('N458', 'Incomplete/invalid Diagnostic Report.');
	_codeSet.set('N459', 'Missing Discharge Summary.');
	_codeSet.set('N460', 'Incomplete/invalid Discharge Summary.');
	_codeSet.set('N461', 'Missing Nursing Notes.');
	_codeSet.set('N462', 'Incomplete/invalid Nursing Notes.');
	_codeSet.set('N463', 'Missing support data for claim.');
	_codeSet.set('N464', 'Incomplete/invalid support data for claim.');
	_codeSet.set('N465', 'Missing Physical Therapy Notes/Report.');
	_codeSet.set('N466', 'Incomplete/invalid Physical Therapy Notes/Report.');
	_codeSet.set('N467', 'Missing Tests and Analysis Report.');
	_codeSet.set('N468', 'Incomplete/invalid Report of Tests and Analysis Report.');
	_codeSet.set('N469', 'Claim/Service(s) subject to appeal process, see section 935 of Medicare Prescription Drug, Improvement, and Modernization Act of 2003 (MMA).');
	_codeSet.set('N470', 'This payment will complete the mandatory medical reimbursement limit.');
	_codeSet.set('N471', 'Missing/incomplete/invalid HIPPS Rate Code.');
	_codeSet.set('N472', 'Payment for this service has been issued to another provider.');
	_codeSet.set('N473', 'Missing certification.');
	_codeSet.set('N474', 'Incomplete/invalid certification.');
	_codeSet.set('N475', 'Missing completed referral form.');
	_codeSet.set('N476', 'Incomplete/invalid completed referral form.');
	_codeSet.set('N477', 'Missing Dental Models.');
	_codeSet.set('N478', 'Incomplete/invalid Dental Models.');
	_codeSet.set('N479', 'Missing Explanation of Benefits (Coordination of Benefits or Medicare Secondary Payer).');
	_codeSet.set('N480', 'Incomplete/invalid Explanation of Benefits (Coordination of Benefits or Medicare Secondary Payer).');
	_codeSet.set('N481', 'Missing Models.');
	_codeSet.set('N482', 'Incomplete/invalid Models.');
	_codeSet.set('N483', 'Missing Periodontal Charts.');
	_codeSet.set('N484', 'Incomplete/invalid Periodontal Charts.');
	_codeSet.set('N485', 'Missing Physical Therapy Certification.');
	_codeSet.set('N486', 'Incomplete/invalid Physical Therapy Certification.');
	_codeSet.set('N487', 'Missing Prosthetics or Orthotics Certification.');
	_codeSet.set('N488', 'Incomplete/invalid Prosthetics or Orthotics Certification.');
	_codeSet.set('N489', 'Missing referral form.');
	_codeSet.set('N490', 'Incomplete/invalid referral form.');
	_codeSet.set('N491', 'Missing/Incomplete/Invalid Exclusionary Rider Condition.');
	_codeSet.set('N492', 'A network provider may bill the member for this service if the member requested the service and agreed in writing, prior to receiving the service, to be financially responsible for the billed charge.');
	_codeSet.set('N493', 'Missing Doctor First Report of Injury.');
	_codeSet.set('N494', 'Incomplete/invalid Doctor First Report of Injury.');
	_codeSet.set('N495', 'Missing Supplemental Medical Report.');
	_codeSet.set('N496', 'Incomplete/invalid Supplemental Medical Report.');
	_codeSet.set('N497', 'Missing Medical Permanent Impairment or Disability Report.');
	_codeSet.set('N498', 'Incomplete/invalid Medical Permanent Impairment or Disability Report.');
	_codeSet.set('N499', 'Missing Medical Legal Report.');
	_codeSet.set('N500', 'Incomplete/invalid Medical Legal Report.');
	_codeSet.set('N501', 'Missing Vocational Report.');
	_codeSet.set('N502', 'Incomplete/invalid Vocational Report.');
	_codeSet.set('N503', 'Missing Work Status Report.');
	_codeSet.set('N504', 'Incomplete/invalid Work Status Report.');
	_codeSet.set('N505', 'This response includes only services that could be estimated in real-time. No estimate will be provided for the services that could not be estimated in real-time.');
	_codeSet.set('N506', 'This is an estimate of the members liability based on the information available at the time the estimate was processed. Actual coverage and member liability amounts will be determined when the claim is processed. This is not a pre-authorization or a guarantee of payment.');
	_codeSet.set('N507', 'Plan distance requirements have not been met.');
	_codeSet.set('N508', 'This real-time claim adjudication response represents the member responsibility to the provider for services reported. The member will receive an Explanation of Benefits electronically or in the mail. Contact the insurer if there are any questions.');
	_codeSet.set('N509', 'A current inquiry shows the members Consumer Spending Account contains sufficient funds to cover the member liability for this claim/service.  Actual payment from the Consumer Spending Account will depend on the availability of funds and determination of eligible services at the time of payment processing.');
	_codeSet.set('N510', 'A current inquiry shows the members Consumer Spending Account does not contain sufficient funds to cover the members liability for this claim/service. Actual payment from the Consumer Spending Account will depend on the availability of funds and determination of eligible services at the time of payment processing.');
	_codeSet.set('N511', 'Information on the availability of Consumer Spending Account funds to cover the member liability on this claim/service is not available at this time.');
	_codeSet.set('N512', 'This is the initial remit of a non-NCPDP claim originally submitted real-time without change to the adjudication.');
	_codeSet.set('N513', 'This is the initial remit of a non-NCPDP claim originally submitted real-time with a change to the adjudication.');
	_codeSet.set('N514', 'Consult plan benefit documents/guidelines for information about restrictions for this service.');
	_codeSet.set('N515', 'Submit this claim to the patients other insurer for potential payment of supplemental benefits. We did not forward the claim information. (use N387 instead)');
	_codeSet.set('N516', 'Records indicate a mismatch between the submitted NPI and EIN.');
	_codeSet.set('N517', 'Resubmit a new claim with the requested information.');
	_codeSet.set('N518', 'No separate payment for accessories when furnished for use with oxygen equipment.');
	_codeSet.set('N519', 'Invalid combination of HCPCS modifiers.');
	_codeSet.set('N520', 'Payment made from a Consumer Spending Account.');
	_codeSet.set('N521', 'Mismatch between the submitted provider information and the provider information stored in our system.');
	_codeSet.set('N522', 'Duplicate of a claim processed, or to be processed, as a crossover claim.');
	_codeSet.set('N523', 'The limitation on outlier payments defined by this payer for this service period has been met. The outlier payment otherwise applicable to this claim has not been paid.');
	_codeSet.set('N524', 'Based on policy this payment constitutes payment in full.');
	_codeSet.set('N525', 'These services are not covered when performed within the global period of another service.');
	_codeSet.set('N526', 'Not qualified for recovery based on employer size.');
	_codeSet.set('N527', 'We processed this claim as the primary payer prior to receiving the recovery demand.');
	_codeSet.set('N528', 'Patient is entitled to benefits for Institutional Services only.');
	_codeSet.set('N529', 'Patient is entitled to benefits for Professional Services only.');
	_codeSet.set('N530', 'Not Qualified for Recovery based on enrollment information.');
	_codeSet.set('N531', 'Not qualified for recovery based on direct payment of premium.');
	_codeSet.set('N532', 'Not qualified for recovery based on disability and working status.');
	_codeSet.set('N533', 'Services performed in an Indian Health Services facility under a self-insured tribal Group Health Plan.');
	_codeSet.set('N534', 'This is an individual policy, the employer does not participate in plan sponsorship.');
	_codeSet.set('N535', 'Payment is adjusted when procedure is performed in this place of service based on the submitted procedure code and place of service.');
	_codeSet.set('N536', 'We are not changing the prior payers determination of patient responsibility, which you may collect, as this service is not covered by us.');
	_codeSet.set('N537', 'We have examined claims history and no records of the services have been found.');
	_codeSet.set('N538', 'A facility is responsible for payment to outside providers who furnish these services/supplies/drugs to its patients/residents.');
	_codeSet.set('N539', 'We processed appeals/waiver requests on your behalf and that request has been denied.');
	_codeSet.set('N540', 'Payment adjusted based on the interrupted stay policy.');
	_codeSet.set('N541', 'Mismatch between the submitted insurance type code and the information stored in our system.');
	_codeSet.set('N542', 'Missing income verification.');
	_codeSet.set('N543', 'Incomplete/invalid income verification.');
	_codeSet.set('N544', 'Although this was paid, you have billed with a referring/ordering provider that does not match our system record. Unless corrected this will not be paid in the future.');
	_codeSet.set('N545', 'Payment reduced based on status as an unsuccessful eprescriber per the Electronic Prescribing (eRx) Incentive Program.');
	_codeSet.set('N546', 'Payment represents a previous reduction based on the Electronic Prescribing (eRx) Incentive Program.');
	_codeSet.set('N547', 'A refund request (Frequency Type Code 8) was processed previously.');
	_codeSet.set('N548', 'Patients calendar year deductible has been met.');
	_codeSet.set('N549', 'Patients calendar year out-of-pocket maximum has been met.');
	_codeSet.set('N550', 'You have not responded to requests to revalidate your provider/supplier enrollment information. Your failure to revalidate your enrollment information will result in a payment hold in the near future.');
	_codeSet.set('N551', 'Payment adjusted based on the Ambulatory Surgical Center (ASC) Quality Reporting Program.');
	_codeSet.set('N552', 'Payment adjusted to reverse a previous withhold/bonus amount.');
	_codeSet.set('N553', 'Payment adjusted based on a Low Income Subsidy (LIS) retroactive coverage or status change.');
	_codeSet.set('N554', 'Missing/Incomplete/Invalid Family Planning Indicator.');
	_codeSet.set('N555', 'Missing medication list.');
	_codeSet.set('N556', 'Incomplete/invalid medication list.');
	_codeSet.set('N557', 'This claim/service is not payable under our service area. The claim must be filed to the Payer/Plan in whose service area the specimen was collected.');
	_codeSet.set('N558', 'This claim/service is not payable under our service area. The claim must be filed to the Payer/Plan in whose service area the equipment was received.');
	_codeSet.set('N559', 'This claim/service is not payable under our service area. The claim must be filed to the Payer/Plan in whose service area the Ordering Physician is located.');
	_codeSet.set('N560', 'The pilot program requires an interim or final claim within 60 days of the Notice of  Admission. A claim was not received.');
	_codeSet.set('N561', 'The bundled claim originally submitted for this episode of care includes related readmissions. You may resubmit the original claim to receive a corrected payment based on this readmission.');
	_codeSet.set('N562', 'The provider number of your incoming claim does not match the provider number on the processed Notice of Admission (NOA) for this bundled payment.');
	_codeSet.set('N563', 'Missing required provider/supplier issuance of advance patient notice of non-coverage. The patient is not liable for payment for this service.');
	_codeSet.set('N564', 'Patient did not meet the inclusion criteria for the demonstration project or pilot program.');
	_codeSet.set('N565', 'This non-payable reporting code requires a modifier. Future claims containing this non-payable reporting code must include an appropriate modifier for the claim to be processed.');
	_codeSet.set('N566', 'This procedure code requires functional reporting. Future claims containing this procedure code must include an applicable non-payable code and appropriate modifiers for the claim to be processed.');
	_codeSet.set('N567', 'Not covered when considered preventative.');
	_codeSet.set('N568', 'Initial payment based on the Notice of Admission (NOA) under the Bundled Payment Model IV initiative.');
	_codeSet.set('N569', 'Not covered when performed for the reported diagnosis.');
	_codeSet.set('N570', 'Missing/incomplete/invalid credentialing data.');
	_codeSet.set('N571', 'Payment will be issued quarterly by another payer/contractor.');
	_codeSet.set('N572', 'This procedure is not payable unless appropriate non-payable reporting codes and associated modifiers are submitted.');
	_codeSet.set('N573', 'You have been overpaid and must refund the overpayment. The refund will be requested separately by another payer/contractor.');
	_codeSet.set('N574', 'Our records indicate the ordering/referring provider is of a type/specialty that cannot order or refer. Please verify that the claim ordering/referring provider information is accurate or contact the ordering/referring provider.');
	_codeSet.set('N575', 'Mismatch between the submitted ordering/referring provider name and the ordering/referring provider name stored in our records.');
	_codeSet.set('N576', 'Services not related to the specific incident/claim/accident/loss being reported.');
	_codeSet.set('N577', 'Personal Injury Protection (PIP) Coverage.');
	_codeSet.set('N578', 'Coverages do not apply to this loss.');
	_codeSet.set('N579', 'Medical Payments Coverage (MPC).');
	_codeSet.set('N580', 'Determination based on the provisions of the insurance policy.');
	_codeSet.set('N581', 'Investigation of coverage eligibility is pending.');
	_codeSet.set('N582', 'Benefits suspended pending the patients cooperation.');
	_codeSet.set('N583', 'Patient was not an occupant of our insured vehicle and therefore, is not an eligible injured person.');
	_codeSet.set('N584', 'Not covered based on the insureds noncompliance with policy or statutory conditions.');
	_codeSet.set('N585', 'Benefits are no longer available based on a final injury settlement.');
	_codeSet.set('N586', 'The injured party does not qualify for benefits.');
	_codeSet.set('N587', 'Policy benefits have been exhausted.');
	_codeSet.set('N588', 'The patient has instructed that medical claims/bills are not to be paid.');
	_codeSet.set('N589', 'Coverage is excluded to any person injured as a result of operating a motor vehicle while in an intoxicated condition or while the ability to operate such a vehicle is impaired by the use of a drug.');
	_codeSet.set('N590', 'Missing independent medical exam detailing the cause of injuries sustained and medical necessity of services rendered.');
	_codeSet.set('N591', 'Payment based on an Independent Medical Examination (IME) or Utilization Review (UR).');
	_codeSet.set('N592', 'Adjusted because this is not the initial prescription or exceeds the amount allowed for the initial prescription.');
	_codeSet.set('N593', 'Not covered based on failure to attend  a scheduled Independent Medical Exam (IME).');
	_codeSet.set('N594', 'Records reflect the injured party did not complete an Application for Benefits for this loss.');
	_codeSet.set('N595', 'Records reflect the injured party did not complete an Assignment of Benefits for this loss.');
	_codeSet.set('N596', 'Records reflect the injured party did not complete a Medical Authorization for this loss.');
	_codeSet.set('N597', 'Adjusted based on a medical/dental providers apportionment of care between related injuries and other unrelated medical/dental conditions/injuries.');
	_codeSet.set('N598', 'Health care policy coverage is primary.');
	_codeSet.set('N599', 'Our payment for this service is based upon a reasonable amount pursuant to both the terms and conditions of the policy of insurance under which the subject claim is being made as well as the Florida No-Fault Statute, which permits, when determining a reasonable charge for a service, an insurer to consider usual and customary charges and payments accepted by the provider, reimbursement levels in the community and various federal and state fee schedules applicable to automobile and other insurance coverages, and other information relevant to the reasonableness of the reimbursement for the service. The payment for this service is based upon 200% of the Participating Level of Medicare Part B fee schedule for the locale in which the services were rendered.');
	_codeSet.set('N600', 'Adjusted based on the applicable fee schedule for the region in which the service was rendered.');
	_codeSet.set('N601', 'In accordance with Hawaii Administrative Rules, Title 16, Chapter 23 Motor Vehicle Insurance Law payment is recommended based on Medicare Resource Based Relative Value Scale System applicable to Hawaii.');
	_codeSet.set('N602', 'Adjusted based on the Redbook maximum allowance.');
	_codeSet.set('N603', 'This fee is calculated according to the New Jersey medical fee schedules for Automobile Personal Injury Protection and Motor Bus Medical Expense Insurance Coverage.');
	_codeSet.set('N604', 'In accordance with New York No-Fault Law, Regulation 68, this base fee was calculated according to the New York Workers Compensation Board Schedule of Medical Fees, pursuant to Regulation 83 and / or Appendix 17-C of 11 NYCRR.');
	_codeSet.set('N605', 'This fee was calculated based upon New York All Patients Refined Diagnosis Related Groups (APR-DRG), pursuant to Regulation 68.');
	_codeSet.set('N606', 'The Oregon allowed amount for this procedure is based upon the Workers Compensation Fee Schedule (OAR 436-009).  The allowed amount has been calculated in accordance with Section 4 of ORS 742.524.');
	_codeSet.set('N607', 'Service provided for non-compensable condition(s).');
	_codeSet.set('N608', 'The fee schedule amount allowed is calculated at 110% of the Medicare Fee Schedule for this region, specialty and type of service.  This fee is calculated in compliance with Act 6.');
	_codeSet.set('N609', '80% of the providers billed amount is being recommended for payment according to Act 6.');
	_codeSet.set('N610', 'Payment based on an appropriate level of care.');
	_codeSet.set('N611', 'Claim in litigation.  Contact insurer for more information.');
	_codeSet.set('N612', 'Medical provider not authorized/certified to provide treatment to  injured workers in this jurisdiction.');
	_codeSet.set('N613', 'Although this was paid, you have billed with an ordering provider that needs to update their enrollment record. Please verify that the ordering provider information you submitted on the claim is accurate and if it is, contact the ordering provider instructing them to update their enrollment record. Unless corrected, a claim with this ordering provider will not be paid in the future.');
	_codeSet.set('N614', 'Additional information is included in the 835 Healthcare Policy Identification Segment (loop 2110 Service Payment Information).');
	_codeSet.set('N615', 'This enrollee receiving advance payments of the premium tax credit is in the grace period of three consecutive months for non-payment of premium. Under 45 CFR 156.270, a Qualified Health Plan issuer must pay all appropriate claims for services rendered to the enrollee during the first month of the grace period and may pend claims for services rendered to the enrollee in the second and third months of the grace period.');
	_codeSet.set('N616', 'This enrollee is in the first month of the advance premium tax credit grace period.');
	_codeSet.set('N617', 'This enrollee is in the second or third month of the advance premium tax credit grace period.');
	_codeSet.set('N618', 'This claim will automatically be reprocessed if the enrollee pays their premiums.');
	_codeSet.set('N619', 'Coverage terminated for non-payment of premium.');
	_codeSet.set('N620', 'This procedure code is for quality reporting/informational purposes only.');
	_codeSet.set('N621', 'Charges for Jurisdiction required forms, reports, or chart notes are not payable.');
	_codeSet.set('N622', 'Not covered based on the date of injury/accident.');
	_codeSet.set('N623', 'Not covered when deemed unscientific/unproven/outmoded/experimental/excessive/inappropriate.');
	_codeSet.set('N624', 'The associated Workers Compensation claim has been withdrawn.');
	_codeSet.set('N625', 'Missing/Incomplete/Invalid Workers Compensation Claim Number.');
	_codeSet.set('N626', 'New or established patient E/M codes are not payable with chiropractic care codes.');
	_codeSet.set('N627', 'Service not payable per managed care contract.');
	_codeSet.set('N628', 'Out-patient follow up visits on the same date of service as a scheduled test or treatment is disallowed.');
	_codeSet.set('N629', 'Reviews/documentation/notes/summaries/reports/charts not requested.');
	_codeSet.set('N630', 'Referral not authorized by attending physician.');
	_codeSet.set('N631', 'Medical Fee Schedule does not list this code. An allowance was made for a comparable service.');
	_codeSet.set('N632', 'According to the Official Medical Fee Schedule this service has a relative value of zero and therefore no payment is due.');
	_codeSet.set('N633', 'Additional anesthesia time units are not allowed.');
	_codeSet.set('N634', 'The allowance is calculated based on anesthesia time units.');
	_codeSet.set('N635', 'The Allowance is calculated based on the anesthesia base units plus time.');
	_codeSet.set('N636', 'Adjusted because this is reimbursable only once per injury.');
	_codeSet.set('N637', 'Consultations are not allowed once treatment has been rendered by the same provider.');
	_codeSet.set('N638', 'Reimbursement has been made according to the home health fee schedule.');
	_codeSet.set('N639', 'Reimbursement has been made according to the inpatient rehabilitation facilities fee schedule.');
	_codeSet.set('N640', 'Exceeds number/frequency approved/allowed within time period.');
	_codeSet.set('N641', 'Reimbursement has been based on the number of body areas rated.');
	_codeSet.set('N642', 'Adjusted when billed as individual tests instead of as a panel.');
	_codeSet.set('N643', 'The services billed are considered Not Covered or Non-Covered (NC) in the applicable state fee schedule.');
	_codeSet.set('N644', 'Reimbursement has been made according to the bilateral procedure rule.');
	_codeSet.set('N645', 'Mark-up allowance.');
	_codeSet.set('N646', 'Reimbursement has been adjusted based on the guidelines for an assistant.');
	_codeSet.set('N647', 'Adjusted based on diagnosis-related group (DRG).');
	_codeSet.set('N648', 'Adjusted based on Stop Loss.');
	_codeSet.set('N649', 'Payment based on invoice.');
	_codeSet.set('N650', 'This policy was not in effect for this date of loss. No coverage is available.');
	_codeSet.set('N651', 'No Personal Injury Protection/Medical Payments Coverage on the policy at the time of the loss.');
	_codeSet.set('N652', 'The date of service is before the date of loss.');
	_codeSet.set('N653', 'The date of injury does not match the reported date of loss.');
	_codeSet.set('N654', 'Adjusted based on achievement of maximum medical improvement (MMI).');
	_codeSet.set('N655', 'Payment based on providers geographic region.');
	_codeSet.set('N656', 'An interest payment is being made because benefits are being paid outside the statutory requirement.');
	_codeSet.set('N657', 'This should be billed with the appropriate code for these services.');
	_codeSet.set('N658', 'The billed service(s) are not considered medical expenses.');
	_codeSet.set('N659', 'This item is exempt from sales tax.');
	_codeSet.set('N660', 'Sales tax has been included in the reimbursement.');
	_codeSet.set('N661', 'Documentation does not support that the services rendered were medically necessary.');
	_codeSet.set('N662', 'Consideration of payment will be made upon receipt of a final bill.');
	_codeSet.set('N663', 'Adjusted based on an agreed amount.');
	_codeSet.set('N664', 'Adjusted based on a legal settlement.');
	_codeSet.set('N665', 'Services by an unlicensed provider are not reimbursable.');
	_codeSet.set('N666', 'Only one evaluation and management code at this service level is covered during the course of care.');
	_codeSet.set('N667', 'Missing prescription.');
	_codeSet.set('N668', 'Incomplete/invalid prescription.');
	_codeSet.set('N669', 'Adjusted based on the Medicare fee schedule.');
	_codeSet.set('N670', 'This service code has been identified as the primary procedure code subject to the Medicare Multiple Procedure Payment Reduction (MPPR) rule.');
	_codeSet.set('N671', 'Payment based on a jurisdiction cost-charge ratio.');
	_codeSet.set('N672', 'Amount applied to Health Insurance Offset.');
	_codeSet.set('N673', 'Reimbursement has been calculated based on an outpatient per diem or an outpatient factor and/or fee schedule amount.');
	_codeSet.set('N674', 'Not covered unless a pre-requisite procedure/service has been provided.');
	_codeSet.set('N675', 'Additional information is required from the injured party.');
	_codeSet.set('N676', 'Service does not qualify for payment under the Outpatient Facility Fee Schedule.');
	_codeSet.set('N677', 'Films/Images will not be returned.');
	_codeSet.set('N678', 'Missing post-operative images/visual field results.');
	_codeSet.set('N679', 'Incomplete/Invalid post-operative images/visual field results.');
	_codeSet.set('N680', 'Missing/Incomplete/Invalid date of previous dental extractions.');
	_codeSet.set('N681', 'Missing/Incomplete/Invalid full arch series.');
	_codeSet.set('N682', 'Missing/Incomplete/Invalid history of prior periodontal therapy/maintenance.');
	_codeSet.set('N683', 'Missing/Incomplete/Invalid prior treatment documentation.');
	_codeSet.set('N684', 'Payment denied as this is a specialty claim submitted as a general claim.');
	_codeSet.set('N685', 'Missing/Incomplete/Invalid Prosthesis, Crown or Inlay Code.');
	_codeSet.set('N686', 'Missing/incomplete/Invalid questionnaire needed to complete payment determination.');
	_codeSet.set('N687', 'This reversal is due to a retroactive disenrollment.');
	_codeSet.set('N688', 'This reversal is due to a medical or utilization review decision.');
	_codeSet.set('N689', 'This reversal is due to a retroactive rate change.');
	_codeSet.set('N690', 'This reversal is due to a provider submitted appeal.');
	_codeSet.set('N691', 'This reversal is due to a patient submitted appeal.');
	_codeSet.set('N692', 'This reversal is due to an incorrect rate on the initial adjudication.');
	_codeSet.set('N693', 'This reversal is due to a cancellation of the claim by the provider.');
	_codeSet.set('N694', 'This reversal is due to a resubmission/change to the claim by the provider.');
	_codeSet.set('N695', 'This reversal is due to incorrect patient financial responsibility information on the initial adjudication.');
	_codeSet.set('N696', 'This reversal is due to a Coordination of Benefits or Third Party Liability Recovery retroactive adjustment.');
	_codeSet.set('N697', 'This reversal is due to a payers retroactive contract incentive program adjustment.');
	_codeSet.set('N698', 'This reversal is due to non-payment of the health insurance premiums (Health Insurance Exchange or other) by the end of the premium payment grace period, resulting in loss of coverage.');
	_codeSet.set('N699', 'Payment adjusted based on the Physician Quality Reporting System (PQRS) Incentive Program.');
	_codeSet.set('N700', 'Payment adjusted based on the Electronic Health Records (EHR) Incentive Program.');
	_codeSet.set('N701', 'Payment adjusted based on the Value-based Payment Modifier.');
	_codeSet.set('N702', 'Decision based on review of previously adjudicated claims or for claims in process for the same/similar type of services.');
	_codeSet.set('N703', 'This service is incompatible with previously  adjudicated claims or claims in process.');
	_codeSet.set('N704', 'You may not appeal this decision but can resubmit this claim/service with corrected information if warranted.');
	_codeSet.set('N705', 'Incomplete/invalid documentation.');
	_codeSet.set('N706', 'Missing documentation.');
	_codeSet.set('N707', 'Incomplete/invalid orders.');
	_codeSet.set('N708', 'Missing orders.');
	_codeSet.set('N709', 'Incomplete/invalid notes.');
	_codeSet.set('N710', 'Missing notes.');
	_codeSet.set('N711', 'Incomplete/invalid summary.');
	_codeSet.set('N712', 'Missing summary.');
	_codeSet.set('N713', 'Incomplete/invalid report.');
	_codeSet.set('N714', 'Missing report.');
	_codeSet.set('N715', 'Incomplete/invalid chart.');
	_codeSet.set('N716', 'Missing chart.');
	_codeSet.set('N717', 'Incomplete/Invalid documentation of face-to-face examination.');
	_codeSet.set('N718', 'Missing documentation of face-to-face examination.');
	_codeSet.set('N719', 'Penalty applied based on plan requirements not being met.');
	_codeSet.set('N720', 'The patient overpaid you. You may need to issue the patient a refund for the difference between the patients payment and the amount shown as patient responsibility on this notice.');
	_codeSet.set('N721', 'This service is only covered when performed as part of a clinical trial.');
	_codeSet.set('N722', 'Patient must use Workers Compensation Set-Aside (WCSA) funds to pay for the medical service or item.');
	_codeSet.set('N723', 'Patient must use Liability set-aside (LSA) funds to pay for the medical service or item.');
	_codeSet.set('N724', 'Patient must use No-Fault set-aside (NFSA) funds to pay for the medical service or item.');
	_codeSet.set('N725', 'A liability insurer has reported having ongoing responsibility for medical services (ORM) for this diagnosis.');
	_codeSet.set('N726', 'A conditional payment is not allowed.');
	_codeSet.set('N727', 'A no-fault insurer has reported having ongoing responsibility for medical services (ORM) for this diagnosis.');
	_codeSet.set('N728', 'A workers compensation insurer has reported having ongoing responsibility for medical services (ORM) for this diagnosis.');
	_codeSet.set('N729', 'Missing patient medical/dental record for this service.');
	_codeSet.set('N730', 'Incomplete/invalid patient medical/dental record for this service.');
	_codeSet.set('N731', 'Incomplete/Invalid mental health assessment.');
	_codeSet.set('N732', 'Services performed at an unlicensed facility are not reimbursable.');
	_codeSet.set('N733', 'Regulatory surcharges are paid directly to the state.');
	_codeSet.set('N734', 'The patient is eligible for these medical services only when unable to work or perform normal activities due to an illness or injury.');
	_codeSet.set('N735', 'Adjustment without review of medical/dental record because the requested records were not received or were not received timely.');
	_codeSet.set('N736', 'Incomplete/invalid Sleep Study Report.');
	_codeSet.set('N737', 'Missing Sleep Study Report.');
	_codeSet.set('N738', 'Incomplete/invalid Vein Study Report.');
	_codeSet.set('N739', 'Missing Vein Study Report.');
	_codeSet.set('N740', 'The members Consumer Spending Account does not contain sufficient funds to cover the members liability for this claim/service.');
	_codeSet.set('N741', 'This is a site neutral payment.');
	_codeSet.set('N742', 'This claim was processed based on one or more ICD-9 codes. The transition to ICD-10 is required by October 1, 2015, for health care providers, health plans, and clearinghouses. More information can be found at http://www.cms.gov/Medicare/Coding/ICD10/ProviderResources.html');
	_codeSet.set('N743', 'Adjusted because the services may be related to an employment accident.');
	_codeSet.set('N744', 'Adjusted because the services may be related to an auto/other accident.');
	_codeSet.set('N745', 'Missing Ambulance Report.');
	_codeSet.set('N746', 'Incomplete/invalid Ambulance Report.');
	_codeSet.set('N747', 'This is a misdirected claim/service. Submit the claim to the payer/plan where the patient resides.');
	_codeSet.set('N748', 'Adjusted because the related hospital charges have not been received.');
	_codeSet.set('N749', 'Missing Blood Gas Report.');
	_codeSet.set('N750', 'Incomplete/invalid Blood Gas Report.');
	_codeSet.set('N751', 'Adjusted because the patient is covered under a Medicare Part D plan.');
	_codeSet.set('N752', 'Missing/incomplete/invalid HIPPS Treatment Authorization Code (TAC).');
	_codeSet.set('N753', 'Missing/incomplete/invalid Attachment Control Number.');
	_codeSet.set('N754', 'Missing/incomplete/invalid Referring Provider or Other Source Qualifier on the 1500 Claim Form.');
	_codeSet.set('N755', 'Missing/incomplete/invalid ICD Indicator.');
	_codeSet.set('N756', 'Missing/incomplete/invalid point of drop-off address.');
	_codeSet.set('N757', 'Adjusted based on the Federal Indian Fees schedule (MLR).');
	_codeSet.set('N758', 'Adjusted based on the prior authorization decision.');
	_codeSet.set('N759', 'Payment adjusted based on the National Electrical Manufacturers Association (NEMA) Standard XR-29-2013.');
	_codeSet.set('N760', 'This facility is not authorized to receive payment for the service(s).');
	_codeSet.set('N761', 'This provider is not authorized to receive payment for the service(s).');
	_codeSet.set('N762', 'This facility is not certified for Tomosynthesis (3-D) mammography.');
	_codeSet.set('N763', 'The demonstration code is not appropriate for this claim; resubmit without a demonstration code.');
	_codeSet.set('N764', 'Missing/incomplete/invalid Hematocrit (HCT) value.');
	_codeSet.set('N765', 'This payer does not cover coinsurance assessed by a previous payer.');
	_codeSet.set('N766', 'This payer does not cover co-payment assessed by a previous payer.');
	_codeSet.set('N767', 'The Medicaid state requires provider to be enrolled in the members Medicaid state program prior to any claim benefits being processed.');
	_codeSet.set('N768', 'Incomplete/invalid initial evaluation report.');
	_codeSet.set('N769', 'A lateral diagnosis is required.');
	_codeSet.set('N770', 'The adjustment request received from the provider has been processed. Your original claim has been adjusted based on the information received.');
	_codeSet.set('N771', 'Under Federal law you cannot charge more than the limiting charge amount.');
	_codeSet.set('N772', 'Rebill urgent/emergent and ancillary services separately.');
	_codeSet.set('N773', 'Drug supplied not obtained from specialty vendor.');
	_codeSet.set('N774', 'Refer to your Third Party Processor Agreement for specific information on fees associated with this payment type.');
	_codeSet.set('N775', 'Payment adjusted based on x-ray radiograph on film.');
	_codeSet.set('N776', 'This service is not a covered Telehealth service.');
	_codeSet.set('N777', 'Missing Assignment of Benefits Indicator.');
	_codeSet.set('N778', 'Missing Primary Care Physician Information.');
	_codeSet.set('N779', 'Replacement/Void claims cannot be submitted until the original claim has finalized. Please resubmit once payment or denial is received.');
	_codeSet.set('N780', 'Missing/incomplete/invalid end therapy date.');
	_codeSet.set('N781', 'Patient is a Medicaid/ Qualified Medicare Beneficiary. Review your records for any wrongfully collected deductible. This amount may be billed to a subsequent payer.');
	_codeSet.set('N782', 'Patient is a Medicaid/ Qualified Medicare Beneficiary. Review your records for any wrongfully collected coinsurance. This amount may be billed to a subsequent payer.');
	_codeSet.set('N783', 'Patient is a Medicaid/ Qualified Medicare Beneficiary. Review your records for any wrongfully collected copayment. This amount may be billed to a subsequent payer.');
	_codeSet.set('N784', 'Missing comprehensive procedure code.');
	_codeSet.set('N785', 'Missing current radiology film/images.');
	_codeSet.set('N786', 'Benefit limitation for the orthodontic active and/or retention phase of treatment.');
	_codeSet.set('N787', 'Under 42 CFR 410.43, an eligible Partial Hospitalization Program (PHP) patient/beneficiary requires a minimum of 20 hours of PHP services per week, as evidenced in the plan of care. PHP services must be furnished in accordance with the plan of care.');
	_codeSet.set('N788', 'The third-party administrator/review organization did not receive the required information.');
	_codeSet.set('N789', 'Clinical Trial is not a covered benefit.');
	_codeSet.set('N790', 'Provider/supplier not accredited for product/service.');
	_codeSet.set('N791', 'Missing history & physical report.');
	_codeSet.set('N792', 'Incomplete/invalid history & physical report.');
	_codeSet.set('N793', 'Starting January 1, 2020, Medicare will ONLY accept claims submitted with the Medicare Beneficiary Identifier (MBI). Medicare will reject any claims submitted with the Health Insurance Claim Number (HICN) with a few exceptions. Please see www.cms.gov/Medicare/New-Medicare-Card/index.html for more information.');
	_codeSet.set('N794', 'Payment adjusted based on type of technology used.');
	_codeSet.set('N795', 'Item must be resubmitted as a purchase.');
	_codeSet.set('N796', 'Missing/incomplete/invalid Hemoglobin (Hb or Hgb) value.');
	_codeSet.set('N797', 'Missing/incomplete/invalid date qualifier.');
	_codeSet.set('N798', 'Submit a void request for the original claim and resubmit a new claim.');
	_codeSet.set('N799', 'Submitted identifier must be an individual identifier, not group identifier.');
	_codeSet.set('N800', 'Only one service date is allowed per claim.');
	_codeSet.set('N801', 'Services performed in a Medicare participating or CAH facility under a self-insured tribal Group Health Plan, in accordance with Federal Regulation 42 CFR 136.');
	_codeSet.set('N802', 'This claim/service is not payable under our service area. The claim must be filed to the Payer/Plan in whose service area the Rendering Physician is located.');
	_codeSet.set('N803', 'Submission of the claim for the service rendered is the responsibility of the Contracted Medical Group or Hospital.');
	_codeSet.set('N804', 'The claim/service was processed through the Outpatient Code Editor (OCE).');
	_codeSet.set('N805', 'The claim/service was processed through the Correct Code Editor (CCE).');
	_codeSet.set('N806', 'Payment is included in the Global transplant allowance.');
	_codeSet.set('N807', 'Payment adjustment based on the Merit-based Incentive Payment System (MIPS).');
	_codeSet.set('N808', 'Not covered for this provider type / provider specialty.');
	_codeSet.set('N809', 'The fee schedule amount for this service was adjusted based on prior competitive bidding rates. For more information, contact your local contractor.');
	_codeSet.set('N810', 'Due to federal, state or local disaster declaration, this claim has been processed at the in-network level of benefit. At the conclusion or expiration of the disaster declaration, network payment rules will be reinstated.');
	_codeSet.set('N811', 'Missing Federal Sequestration Reduction from Prior Payer.');
	_codeSet.set('N812', 'The start service date through end service date cannot span greater than 18 months.');
	_codeSet.set('N815', 'Missing/Incomplete/Invalid NDC Unit Count');
	_codeSet.set('N816', 'Missing/Incomplete/Invalid NDC Unit of Measure');
	_codeSet.set('N817', 'Applicable laboratories are required to collect and report private payor data and report that data to CMS between January 1, 2020 - March 31, 2020.');
	_codeSet.set('N818', 'Claims Dates of Service do not match Electronic Visit Verification System.');
	_codeSet.set('N819', 'Patient not enrolled in Electronic Visit Verification System.');
	_codeSet.set('N820', 'Electronic Visit Verification System units do not meet requirements of visit.');
	_codeSet.set('N821', 'Electronic Visit Verification System visit not found.');
	_codeSet.set('N822', 'Missing procedure modifier(s).');
	_codeSet.set('N823', 'Incomplete/Invalid procedure modifier(s).');
	_codeSet.set('N824', 'Electronic Visit Verification (EVV) data must be submitted through EVV Vendor.');
	_codeSet.set('N825', 'Early intervention guidelines were not met.');
	_codeSet.set('N826', 'Patient did not meet the inclusion criteria for the Medicare Shared Savings Program.');
	_codeSet.set('N827', 'Missing/Incomplete/Invalid Federal Information Processing Standard (FIPS) Code.');
	_codeSet.set('N828', 'Payment is suppressed due to a contracted funding.');
	_codeSet.set('N829', 'Missing/incomplete/invalid Diagnostics Exchange Z-Code Identifier.');
	_codeSet.set('N830', 'The charge[s] for this service was processed in accordance with Federal/ State, Balance Billing/ No Surprise Billing regulations. As such, any amount identified with OA, CO, or PI cannot be collected from the member and may be considered provider liability or be billable to a subsequent payer. Any amount the provider collected over the identified PR amount must be refunded to the patient within applicable Federal/State timeframes. Payment amounts are eligible for dispute pursuant to any Federal/State documented appeal/grievance process(es).');
	_codeSet.set('N831', 'You have not responded to requests to revalidate your provider/supplier enrollment information.');
	_codeSet.set('N832', 'Duplicate occurrence code/occurrence span code.');
	_codeSet.set('N833', 'Patient share of cost waived.');
	_codeSet.set('N834', 'Jurisdiction exempt from sales and health tax charges.');
	_codeSet.set('N835', 'Unrelated Service/procedure/treatment is reduced. The balance of this charge is the patients responsibility.');
	_codeSet.set('N836', 'Provider W9 or Payee Registration not on file.');
	_codeSet.set('N837', 'Missing modifier was added.');
	_codeSet.set('N838', 'Service/procedure postponed due to a federal, state, or local mandate/disaster declaration. Any amounts applied to deductible or member liability will be applied to the prior plan year from which the procedure was cancelled.');
	_codeSet.set('N839', 'The procedure code was added/changed because the level of service exceeds the compensable condition(s).');
	_codeSet.set('N840', 'Workers compensation claim filed with a different state.');
	_codeSet.set('N841', 'North Dakota Administrative Rule 92-01-02-50.3.');
	_codeSet.set('N842', 'Patient cannot be billed for charges.');
	_codeSet.set('N843', 'Missing/incomplete/invalid Core-Based Statistical Area (CBSA) code.');
	_codeSet.set('N844', 'This claim, or a portion of this claim, was processed in accordance with the Nebraska Legislative LB997 July 24, 2020 - Out of Network Emergency Medical Care Act.');
	_codeSet.set('N845', 'Nebraska Legislative LB997 July 24, 2020 - Out of Network Emergency Medical Care Act.');
	_codeSet.set('N846', 'National Drug Code (NDC) supplied does not correspond to the HCPCs/CPT billed.');
	_codeSet.set('N847', 'National Drug Code (NDC) billed is obsolete.');
	_codeSet.set('N848', 'National Drug Code (NDC) billed cannot be associated with a product.');
	_codeSet.set('N849', 'Missing Tooth Clause: Tooth missing prior to the member effective date.');
	_codeSet.set('N850', 'Missing/incomplete/invalid narrative explaining/describing this service/treatment.');
	_codeSet.set('N851', 'Payment reduced because services were furnished by a therapy assistant.');
	_codeSet.set('N852', 'The pay-to and rendering provider tax identification numbers (TINs) do not match');
	_codeSet.set('N853', 'The number of modalities performed per session exceeds our acceptable maximum.');
	_codeSet.set('N854', 'If you have primary other health insurance (OHI) coverage that has denied services, you must exhaust all appeal levels with your primary OHI before we can consider your claim for reimbursement.');
	_codeSet.set('N855', 'This coverage is subject to the exclusive jurisdiction of ERISA (1974), U.S.C. SEC 1001.');
	_codeSet.set('N856', 'This coverage is not subject to the exclusive jurisdiction of ERISA (1974), U.S.C. SEC 1001.');
	_codeSet.set('N857', 'This claim has been adjusted/reversed. Refund any collected copayment to the member.');
	_codeSet.set('N858', 'State regulations relating to an Out of Network Medical Emergency Care Act were applied to the processing of this claim. Payment amounts are eligible for dispute following the states documented appeal/ grievance/ arbitration process.');
	_codeSet.set('N859', 'The Federal No Surprise Billing Act was applied to the processing of this claim. Payment amounts are eligible for dispute pursuant to any Federal documented appeal/ grievance/ dispute resolution process(es).');
	_codeSet.set('N860', 'The Federal No Surprise Billing Act Qualified Payment Amount (QPA) was used to calculate the member cost share(s).');
	_codeSet.set('N861', 'Mismatch between the submitted Patient Liability/Share of Cost and the amount on record for this recipient.');
	_codeSet.set('N862', 'Member cost share is in compliance with the No Surprises Act, and is calculated using the lesser of the QPA or billed charge.');
	_codeSet.set('N863', 'This claim is subject to the No Surprises Act (NSA). The amount paid is the final out-of-network rate and was calculated based on an All Payer Model Agreement, in accordance with the NSA.');
	_codeSet.set('N864', 'This claim is subject to the No Surprises Act provisions that apply to emergency services.');
	_codeSet.set('N865', 'This claim is subject to the No Surprises Act provisions that apply to nonemergency services furnished by nonparticipating providers during a patient visit to a participating facility.');
	_codeSet.set('N866', 'This claim is subject to the No Surprises Act provisions that apply to services furnished by nonparticipating providers of air ambulance services.');
	_codeSet.set('N867', 'Cost sharing was calculated based on a specified state law, in accordance with the No Surprises Act.');
	_codeSet.set('N868', 'Cost sharing was calculated based on an All-Payer Model Agreement, in accordance with the No Surprises Act.');
	_codeSet.set('N869', 'Cost sharing was calculated based on the qualifying payment amount, in accordance with the No Surprises Act.');
	_codeSet.set('N870', 'In accordance with the No Surprises Act, cost sharing was based on the billed amount because the billed amount was lower than the qualifying payment amount.');
	_codeSet.set('N871', 'This initial payment was calculated based on a specified state law, in accordance with the No Surprises Act.');
	_codeSet.set('N872', 'This final payment was calculated based on a specified state law, in accordance with the No Surprises Act.');
	_codeSet.set('N873', 'This final payment was calculated based on an All-Payer Model Agreement, in accordance with the No Surprises Act.');
	_codeSet.set('N874', 'This final payment was determined through open negotiation, in accordance with the No Surprises Act.');
	_codeSet.set('N875', 'This final payment equals the amount selected as the out-of-network rate by a Federal Independent Dispute Resolution Entity, in accordance with the No Surprises Act.');
	_codeSet.set('N876', 'This item or service is covered under the plan. This is a notice of denial of payment provided in accordance with the No Surprises Act. The provider or facility may initiate open negotiation if they desire to negotiate a higher out-of-network rate than the amount paid by the patient in cost sharing.');
	_codeSet.set('N877', 'This initial payment is provided in accordance with the No Surprises Act. The provider or facility may initiate open negotiation if they desire to negotiate a higher out-of-network rate.');
	_codeSet.set('N878', 'The provider or facility specified that notice was provided and consent to balance bill obtained, but notice and consent was not provided and obtained in a manner consistent with applicable Federal law. Thus, cost sharing and the total amount paid have been calculated based on the requirements under the No Surprises Act, and balance billing is prohibited.');
	_codeSet.set('N879', 'The notice and consent to balance bill, and to be charged out-of-network cost sharing, that was obtained from the patient with regard to the billed services, is not permitted for these services. Thus, cost sharing and the total amount paid have been calculated based on the requirements under the No Surprises Act, and balance billing is prohibited.');
	_codeSet.set('N880', 'Original claim closed due to changes in submitted data. Adjustment claim will be processed under a new claim number.');
	_codeSet.set('N881', 'Client Obligation, patient responsibility for Home & Community Based Services (HCBS)');
	_codeSet.set('N882', 'The out-of-network payment and cost sharing amounts were based on the plans allowance because the provider or facility obtained the patients consent to waive the balance billing protections under the No Surprises Act.');
	_codeSet.set('N883', 'Processed according to state law');
	_codeSet.set('N884', 'The No Surprises Act may apply to this claim. Please contact payer for instructions on how to submit information regarding whether or not the item or service was furnished during a patient visit to a participating facility.');
	_codeSet.set('N885', 'This claim was not processed in accordance with the No Surprises Act cost-sharing or out-of-network payment requirements. The payer disagrees with your determination that those requirements apply. You may contact the payer to find out why it disagrees. You may appeal this adverse determination on behalf of the patient through the payer’s internal appeals and external review processes.');
	_codeSet.set('N886', 'A Health Care Claim Request for Additional Information (277 RFAI) has been sent.');
	_codeSet.set('N887', 'Providers not participating in the Medicare Advantage Plan have the right to appeal if the plan has partially or fully denied payment or if the provider believes the plan has not paid the services at the expected Medicare reimbursable rate or type of level/service. Providers may file their appeal in writing within 60 calendar days after the date of the remittance advice. For the plan to review the appeal, the plan will need a completed signed Waiver of Liability Statement. To obtain a Waiver of Liability form, please contact your Medicare Advantage Plan.Once we receive the completed forms, we will give you a decision on your appeal within 60 calendar days.');
	_codeSet.set('N888', 'An electronic request for additional information has been sent for this claim.');
	_codeSet.set('N889', 'This claim was originally processed in real-time, and we sent a real-time 835 response.');
	_codeSet.set('N890', 'Electronic Visit Verification Data Element Requirements were not met.');
	_codeSet.set('N891', 'The maximum allowable payment for this service/procedure was paid by the primary insurance. No further payment due.');
	_codeSet.set('N892', 'The claim does not meet the criteria for acceptable use of the Delay Reason Code.');
	_codeSet.set('N893', 'Missing/incomplete/invalid child medical evaluation form/checklist.');
	_codeSet.set('N894', 'These payments are made subject to a reservation of rights for the Payor to recoup or otherwise recover all or part of these payments based on any of the following: outcome of pending or future litigation/ new or updated state, federal or regulatory guidance/ any other actions that may affect the Payors obligation to make these payments.');
	_codeSet.set('N895', 'Processed based on a negotiated fee schedule for a specialty drug program.');
	_codeSet.set('N896', 'Missing/incomplete/invalid trauma activation sheet.');
	_codeSet.set('N897', 'Missing/incomplete/invalid proof of member payment.');
	_codeSet.set('N898', 'Missing/incomplete/invalid Resource Utilization Group(s) (RUG) code(s).');
	_codeSet.set('N899', 'Missing Initial Evaluation Report.');
	_codeSet.set('N900', 'Missing Therapy Notes/Report.');
	_codeSet.set('N901', 'Incomplete/Invalid Therapy Notes/Report.');
	_codeSet.set('N902', 'Missing Health Risk Assessment (HRA).');
	_codeSet.set('N903', 'Incomplete/Invalid Health Risk Assessment (HRA).');
	_codeSet.set('N904', 'The transportation vendor is responsible for this claim.');
	_codeSet.set('N905', 'Our records show you have opted out of Medicare, agreeing with the patient not to bill Medicare for services/tests/supplies furnished. As result, we cannot pay this claim. The patient is not responsible for payment.');
	_codeSet.set('N906', 'Service is not covered when patient is under age 45.');
	_codeSet.set('N907', 'No refund because this claim has been identified as 340B-eligible with a ceiling price lower than the maximum fair price.');
	_codeSet.set('N908', 'No refund because this drug has been prospectively purchased at the maximum fair price.');
	_codeSet.set('N909', 'Refund amount has been calculated using a methodology that differs from the Standard Default Refund Amount calculation ((Wholesale Acquisition Cost minus Maximum Fair Price) times Quantity).');
	_codeSet.set('N910', 'A refund cannot be provided for this claim at this time. Contact the manufacturer directly regarding your eligibility.');
	_codeSet.set('N911', 'This claim cannot be reimbursed by the manufacturer until the Part D plan submits corrected prescription drug event data to CMS for maximum fair price validation.');
	_codeSet.set('N912', 'Our records indicate that this beneficiary did not elect hospice.');
	_codeSet.set('N913', 'More than one Electronic Visit Verification record exists for the date and time of this service.');
	_codeSet.set('N914', 'This claim was priced and processed in accordance with California AB-72 Health care coverage.');
	_codeSet.set('N915', 'Predetermination of services is not allowed under the members plan.');
	_codeSet.set('N916', 'The third party will render payment to the provider, and they will reimburse you for covered services.');
	return _codeSet;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

const _fnGenerateCodeSetMap_CodeSource967 = function () {
	let _codeSet = new Map();
	_codeSet.set('01', 'Card interchange fee amount');
	_codeSet.set('02', 'Advanced or accelerated payment recoupment amount');
	_codeSet.set('03', 'Claim transmission fee amount');
	_codeSet.set('04', 'Real-time adjudication resulting in a payment that will follow separately.');
	_codeSet.set('05', 'Penalty amount withheld due to reports that were not filed');
	_codeSet.set('06', 'Penalty amount withheld due to reports that were filed incorrectly');
	_codeSet.set('07', 'Non-Internal Revenue Service third-party  withholding amount unrelated to a federal payment levy program');
	_codeSet.set('08', 'Penalty Withholding for Bankruptcy/Termination');
	_codeSet.set('10', 'Non-claims-based interim payment of the providers cost settlement amounts for capital expense.');
	_codeSet.set('11', 'Domestic N95 Respirator Procurement Passthrough');
	_codeSet.set('12', 'Non-claims-based payment of a manual invoice for temporary payment allowance or settlement for an amount due to the payee which cannot be paid via normal processes.');
	_codeSet.set('13', 'Supply chain cost pass-through');
	_codeSet.set('14', 'Non-claims-based interim payment of the providers cost settlement amount for Direct Graduate Medical Education expense');
	_codeSet.set('15', 'Non-claims-based interim lump sum payment of the providers cost settlement amount for non-physician anesthetists expense');
	_codeSet.set('16', 'Non-claims-based interim payment of the providers cost settlement amount for organ acquisition expense');
	_codeSet.set('17', 'Non-claims-based interim payment of the providers cost settlement amount for Return on Equity (ROE) expense');
	_codeSet.set('18', 'Non-claims-based interim payment of the providers cost settlement amount for direct medical education expense');
	_codeSet.set('50', 'The amount of the late charge, late claim filing penalty, or  Medicare late cost report penalty.');
    _codeSet.set('51', 'Late filing interest penalty assessment amount');
	_codeSet.set('72', 'Provider refund amount');
	_codeSet.set('90', 'Early payment allowance amount');
    _codeSet.set('AH', 'Claim transmission fee amount');
	_codeSet.set('AM', 'Loan repayment amount');
	_codeSet.set('AP', 'Advanced or accelerated payment amount');
	_codeSet.set('B2', 'Rebate amount');
	_codeSet.set('B3', 'Recovery amount');
	_codeSet.set('BD', 'Bad debt amount');
	_codeSet.set('BN', 'Bonus amount');
	_codeSet.set('CR', 'Capitation interest amount');
	_codeSet.set('CS', 'Adjustment amount, detailed information is provided separately to explain the adjustment.');
	_codeSet.set('CT', 'Capitation payment amount');
	_codeSet.set('E3', 'Withholding amount');
	_codeSet.set('FB', 'Non-claim related balance forward amount');
	_codeSet.set('FC', 'Allocation of prepaid funds against which deductions are drawn as services are provided.');
	_codeSet.set('FR', 'Claim-related balance forward amount');
	_codeSet.set('HM', 'Hemophilia clotting factor add-on payment amount');
	_codeSet.set('IP', 'Incentive payment amount');
	_codeSet.set('IR', 'Internal Revenue Service 1099 withholding amount');
	_codeSet.set('IS', 'Lump sum based on an interim rate');
	_codeSet.set('J1', 'Amount not reimbursed based on a demonstration program or other limitation that prevents issuance of payment.');
	_codeSet.set('L3', 'Penalty amount');
	_codeSet.set('L6', 'Interest amount');
	_codeSet.set('LE', 'Internal Revenue Service non-1099 withholding amount');
	_codeSet.set('OB', 'Affiliated provider(s) offset amount');
	_codeSet.set('PI', 'Periodic Interim Payment (PIP) lump sum amount');
	_codeSet.set('PL', 'Final payment or settlement amount');
	_codeSet.set('RA', 'Retroactive adjustment amount');
	_codeSet.set('SL', 'Student loan garnishment amount');
	_codeSet.set('TL', 'Third party liability determination amount');
	_codeSet.set('WO', 'Overpayment recovery amount');
	_codeSet.set('WU', 'Non-Internal Revenue Service withholding amount related to a federal payment levy program');
	return _codeSet;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnGetDelimitersFromFirstSegment
 * @private
 * @summary      Extract standard delimeters from first 107 chars of file content
 * @description  Extract standard delimeters from first 107 chars of file content
 */

const _fnGetDelimitersFromFirstSegment = function (firstSegmentStr) {
	
	const delimeters = {};

	/* Peform basic checks for validity */

	if (!firstSegmentStr) throw new Error("First segment not provided");
	const firstSegmentName = firstSegmentStr.substring(0, 3).toUpperCase();
	if (firstSegmentName != 'ISA') throw new Error("Invalid X12 EDI file");

	/* Extract element and segment delimiters characters
	 * from reserved positions.  First segment is fixed in size (107 characters).
	 */
	
	delimeters.elementSeperator          = firstSegmentStr.substring(3, 4);
	delimeters.componentElementSeperator = firstSegmentStr.substring(104, 105);
	delimeters.segmentTerminator         = firstSegmentStr.substring(105, 106);

	/* We now have the element seperator so we can use it to parse the segment
     * into elements and extract the remaining delimiters.
     */

	const elements = firstSegmentStr.split(delimeters.elementSeperator);

	delimeters.repetitionSeparator       = elements[11];
		
	return delimeters;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnParseX12FileContentIntoX12SimpleDataObj
 * @private
 * @summary      Parses X12 standard fileContent into a X12SimpleDataObj
 * @description  Parses X12 standard fileContent into a X12SimpleDataObj. 
 * Provides very basic parsing only (segments and elements) using the basic X12
 * rules without additional standards (ie 4010, 5010).  Does not attempt to 
 * identify control segments and does not perform any checksum validation.
 */

const _fnParseX12FileContentIntoX12SimpleDataObj = function (fileName, fileContent) {

  let x12SimpleDataObj = {};

  x12SimpleDataObj.fileName = fileName;
  x12SimpleDataObj.success  = true;
  x12SimpleDataObj.message  = '';
  x12SimpleDataObj.segments = [];
  x12SimpleDataObj.maxPossibleSegmentElementCount = 0;

  try {

	/* Read first 107 characters (first segment). First segment is fixed in size. */

	const firstSegmentStr = fileContent.substring(0, 106);

	/* Extract delimeters from first segment */

	x12SimpleDataObj.delimeters = _fnGetDelimitersFromFirstSegment(firstSegmentStr);

	/* Split filecontent into segments */

	const segmentsStrArr = fileContent.split(x12SimpleDataObj.delimeters.segmentTerminator);

	/* Used to calc max possible element count for a segment */

	let elementCountsArr = [];

	/* Populate segments array */
    
	segmentsStrArr.forEach((segmentStr) => {

	  let segment = {};

	  /* Split segment into elements */

	  segment.elements = segmentStr.split(x12SimpleDataObj.delimeters.elementSeperator);
	  
	  x12SimpleDataObj.segments.push(segment);
	  elementCountsArr.push(segment.elements.length);
	});

	x12SimpleDataObj.maxPossibleSegmentElementCount = elementCountsArr.reduce((a, b) => Math.max(a, b), -Infinity);
  }
  catch (err) {
    x12SimpleDataObj.success = false;
    x12SimpleDataObj.message = err.message;
  }

  return x12SimpleDataObj;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnParseSegmentObjIntoHtmlRowStr
 * @private
 * @summary      Parses segmentObj into string containing a table row.
 * @description  Parses segmentObj into string containing a table row.
 */

const _fnParseSegmentObjIntoHtmlRowStr = function (segmentObj) {

	let htmlStr = '<div class="d-flex">';
	
	htmlStr += '<div class="mr-3">';
	htmlStr += '<span class="badge badge-dark">';
	htmlStr += segmentObj.elements[0];
	htmlStr += '</span>';
	htmlStr += '</div>';

	let elementRefPos = 1;

	/* Note: Skipping element that contains segment name */

	segmentObj.elements.slice(1).forEach((element) => {
		htmlStr += '<div class="mr-2 border">'
		htmlStr += '<div class="text-center">';
		htmlStr += '<span class="badge badge-light">';
		htmlStr += elementRefPos;
		htmlStr += '</span>';
		htmlStr += '</div>';
		
		htmlStr += '<div class="p-2">';
		htmlStr += element;
		htmlStr += '</div>';		
		htmlStr += '</div>';				
		elementRefPos++;
	}); /* Elements */

	htmlStr += '</div>';

	return htmlStr;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnParseX12SimpleDataObjIntoHTMLTableStr
 * @private
 * @summary      Parses x12SimpleDataObj into a string containing a html table.
 * @description  Parses x12SimpleDataObj into a string containing a html table.
 */

const _fnParseX12SimpleDataObjIntoHTMLTableStr = function (x12SimpleDataObj) {
	let htmlStr = '';
	x12SimpleDataObj.segments.forEach((segment) => {
		htmlStr += _fnParseSegmentObjIntoHtmlRowStr(segment);
	});	
	return htmlStr;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnParseX125010FileContentIntoX125010DataObj
 * @private
 * @summary      Parses X12 5010 standard fileContent into a X125010DataObj
 * @description  Parses X12 5010 standard fileContent into a X125010DataObj.
 */

const _fnParseX125010FileContentIntoX125010DataObj = function (fileName, fileContent) {
    
  let x12DataObj = {};

  x12DataObj.fileName = fileName;

  x12DataObj.interchanges    = [];
  x12DataObj.interchangesCtr = 0;
  x12DataObj.segmentCounts   = new Map();
  x12DataObj.warningsCtr     = 0;
  x12DataObj.warnings        = [];
  x12DataObj.errorsCtr       = 0;
  x12DataObj.errors          = [];
  x12DataObj.success         = true;
  x12DataObj.message         = '';
  		
  try 
  {

	/* Read first 107 characters (first segment). First segment is fixed in size. */

	const firstSegmentStr = fileContent.substring(0, 106);
	x12DataObj.delimeters      = _fnGetDelimitersFromFirstSegment(firstSegmentStr);

	/* Extract segment strings */
	  
	const segmentsStrArr = fileContent.split(x12DataObj.delimeters.segmentTerminator);

	let curIcIdx          = 0;
    let curFnGroupIdx     = 0;
	let curTxSetIdx       = 0;
	let curHlKey          = null;
	let preHlKey          = null;
	let hlDepth           = null;

	/* Parse segments */
	
	segmentsStrArr.forEach((segmentStr, segmentsStrArrIndex, segmentsStrArrRef) => {
        	  	  
	  /* Extract elements */
	  
	  const elements = segmentStr.split(x12DataObj.delimeters.elementSeperator);
	  
	  /* Extract segment name from first element */
	  
	  const segmentName = elements[0].toUpperCase();
	  const segmentKey = segmentName + '-' + elements[1];

	  if (x12DataObj.segmentCounts.has(segmentKey) === true) {
		let segmentCount = x12DataObj.segmentCounts.get(segmentKey);
		segmentCount++;
		x12DataObj.segmentCounts.set(segmentKey, segmentCount);
	  }
	  else {
	     x12DataObj.segmentCounts.set(segmentKey, 1);
      }

		/* Interchange header */
	  
	  if (segmentName === 'ISA') 
	  {
	    let interchange = {};
		interchange.controlNumber                     = '';
		interchange.functionGroups                    = [];
		interchange.functionGroupsExpected            = 0;
		interchange.functionGroupsCtr                 = 0;
		interchange.segmentCountInterchangeHeader     = 0;
		interchange.segmentCountInterchangeTrailer    = 0;
		interchange.segmentCountFunctionGroupHeader   = 0;
		interchange.segmentCountFunctionGroupTrailer  = 0;
		interchange.segmentCountTransactionSetHeader  = 0;
		interchange.segmentCountTransactionSetTrailer = 0;

	    x12DataObj.interchanges.push(interchange);
		x12DataObj.interchangesCtr++;

		curIcIdx      = x12DataObj.interchangesCtr - 1;
		curFnGroupIdx = 0;
	    curTxSetIdx   = 0;
		preHlKey      = null;
		curHlKey      = null;
		hlDepth       = null;

		x12DataObj.interchanges[curIcIdx].controlNumber           = elements[13]; /* Has to match control number of interchange trailer */
		x12DataObj.interchanges[curIcIdx].functionGroupsCtr       = 0;
		x12DataObj.interchanges[curIcIdx].segmentCountInterchangeHeader++;
	  }
	  
	  /* Interchange trailer */
	  
	  else if (segmentName === 'IEA') 
	  {        
	      
		preHlKey      = null;
		curHlKey      = null;
		hlDepth       = null;
		curFnGroupIdx = 0;
		curTxSetIdx = 0;

		x12DataObj.interchanges[curIcIdx].functionGroupsExpected           = parseInt(elements[1]);
		x12DataObj.interchanges[curIcIdx].interchangeControlNumberExpected = elements[2];
		x12DataObj.interchanges[curIcIdx].segmentCountInterchangeTrailer++;

		if (x12DataObj.interchanges[curIcIdx].functionGroupsExpected != x12DataObj.interchanges[curIcIdx].functionGroupsCtr) {
			x12DataObj.errorsCtr++;
			x12DataObj.errors.push('IEA - Function group count mismatch');
		}

		if (x12DataObj.interchanges[curIcIdx].controlNumber != x12DataObj.interchanges[curIcIdx].interchangeControlNumberExpected) {
			x12DataObj.errorsCtr++;
			x12DataObj.errors.push('IEA - Control number mismatch');
		}
	  }

	  /* Function group header */
	  
	  else if (segmentName === 'GS')  
	  {        	 		  		           
		curTxSetIdx = 0;
		preHlKey    = null;
		curHlKey    = null;
		hlDepth     = null;

		x12DataObj.interchanges[curIcIdx].functionGroupsCtr++;
		x12DataObj.interchanges[curIcIdx].segmentCountFunctionGroupHeader++;

		let functionGroup = {};
		  
		functionGroup.identifierCode          = elements[1];
		functionGroup.applicationSenderCode   = elements[2];
		functionGroup.applicationReceiverCode = elements[3];
		functionGroup.createDateCCYYMMDD      = elements[4];
		functionGroup.createTimeHHMMSS        = elements[5];
        functionGroup.controlNumber           = elements[6]; /* Must match trailer */

	    functionGroup.transactionSetsCtr      = 0;
		functionGroup.transactionSetsExpected = 0;
		functionGroup.transactionSets         = [];	
		functionGroup.controlNumberExpected   = '';

		x12DataObj.interchanges[curIcIdx].functionGroups.push(functionGroup);
		curFnGroupIdx = x12DataObj.interchanges[curIcIdx].functionGroupsCtr - 1;
	     	     
	  }
      
	  /* Function group end */
	  
	  else if (segmentName === 'GE')  
	  {
		  		  		 		  
		  curTxSetIdx = 0;
		  preHlKey    = null;
		  curHlKey    = null;
		  hlDepth     = null;

		  x12DataObj.interchanges[curIcIdx].functionGroups[curFnGroupIdx].transactionSetsExpected = parseInt(elements[1]);
		  x12DataObj.interchanges[curIcIdx].functionGroups[curFnGroupIdx].controlNumberExpected   = elements[2];		  
		  x12DataObj.interchanges[curIcIdx].segmentCountFunctionGroupTrailer++;

		  if (x12DataObj.interchanges[curIcIdx].functionGroups[curFnGroupIdx].transactionSetsCtr != x12DataObj.interchanges[curIcIdx].functionGroups[curFnGroupIdx].transactionSetsExpected){
			x12DataObj.errors++;
			x12DataObj.errors.push('GE - Transaction set count mismatch');
		  }
		  
		  if (x12DataObj.interchanges[curIcIdx].functionGroups[curFnGroupIdx].controlNumber != x12DataObj.interchanges[curIcIdx].functionGroups[curFnGroupIdx].controlNumberExpected) {
			x12DataObj.errorsCtr++;
			x12DataObj.errors.push('GE - Function group control number mismatch');
		  }
          		  	      
		}
	  
 	    /* Transaction set start */
	  
	    else if (segmentName === 'ST')  
		{        
		  preHlKey = null;
		  curHlKey = null;
		  hlDepth  = 0;

		  x12DataObj.interchanges[curIcIdx].functionGroups[curFnGroupIdx].transactionSetsCtr++;
		  x12DataObj.interchanges[curIcIdx].segmentCountTransactionSetHeader++;

		  let transactionSet = {};
		  
		  transactionSet.identifierCode            = elements[1];
		  transactionSet.controlNumber             = elements[2];
		  transactionSet.implementationConvention  = elements[3];		  
		  transactionSet.hierarchicalTransaction   = false;
		  transactionSet.hierarchicalLevels        = new Map();
	      transactionSet.hierarchicalLevelsCtr     = 0;
		  transactionSet.dataSegments              = [];
		  transactionSet.segmentsCtr               = 1; /* Count but do not store segment*/
          transactionSet.segmentsExpected          = 0;
		           
		  x12DataObj.interchanges[curIcIdx].functionGroups[curFnGroupIdx].transactionSets.push(transactionSet);

		  /* Set index */

		  curTxSetIdx = x12DataObj.interchanges[curIcIdx].functionGroups[curFnGroupIdx].transactionSetsCtr - 1;

	    }
        
		else if (segmentName === 'BHT') 
		{		  
		  x12DataObj.interchanges[curIcIdx].functionGroups[curFnGroupIdx].transactionSets[curTxSetIdx].hierarchicalTransaction   = true;
		  x12DataObj.interchanges[curIcIdx].functionGroups[curFnGroupIdx].transactionSets[curTxSetIdx].hierarchicalStructureCode = elements[1];
		  x12DataObj.interchanges[curIcIdx].functionGroups[curFnGroupIdx].transactionSets[curTxSetIdx].hierarchicalPurposeCode   = elements[2];
		  x12DataObj.interchanges[curIcIdx].functionGroups[curFnGroupIdx].transactionSets[curTxSetIdx].hierarchicalReferenceID   = elements[3];
		  x12DataObj.interchanges[curIcIdx].functionGroups[curFnGroupIdx].transactionSets[curTxSetIdx].hierarchicalCreateDate    = elements[4];

			/* Count but do not store segment*/
		  x12DataObj.interchanges[curIcIdx].functionGroups[curFnGroupIdx].transactionSets[curTxSetIdx].segmentsCtr++;
		}

		else if (segmentName === 'HL')
		{

		    preHlKey = curHlKey;
		    curHlKey = elements[1];

		    if (preHlKey) {
				let prevHLObj = x12DataObj.interchanges[curIcIdx].functionGroups[curFnGroupIdx].transactionSets[curTxSetIdx].hierarchicalLevels.get(preHlKey);
				prevHLObj.dataSegmentsEndIdx = x12DataObj.interchanges[curIcIdx].functionGroups[curFnGroupIdx].transactionSets[curTxSetIdx].dataSegments.length-1;
				x12DataObj.interchanges[curIcIdx].functionGroups[curFnGroupIdx].transactionSets[curTxSetIdx].hierarchicalLevels.set(preHlKey, prevHLObj);
			}

		    let hierarchicalLevel = {};
			hierarchicalLevel.ID        = curHlKey;
			hierarchicalLevel.parentID  = elements[2];
			hierarchicalLevel.levelCode = elements[3];
		    hierarchicalLevel.childCode = elements[4];
		    hierarchicalLevel.depth     = hlDepth;

 		    if (hierarchicalLevel.childCode === '1') {
		      hlDepth++;
		    }

		  hierarchicalLevel.dataSegmentsStartIdx = x12DataObj.interchanges[curIcIdx].functionGroups[curFnGroupIdx].transactionSets[curTxSetIdx].dataSegments.length;
		  hierarchicalLevel.dataSegmentsEndIdx = -1;
		    
		  x12DataObj.interchanges[curIcIdx].functionGroups[curFnGroupIdx].transactionSets[curTxSetIdx].hierarchicalTransaction = true;
		  x12DataObj.interchanges[curIcIdx].functionGroups[curFnGroupIdx].transactionSets[curTxSetIdx].hierarchicalLevels.set(curHlKey, hierarchicalLevel);
		  x12DataObj.interchanges[curIcIdx].functionGroups[curFnGroupIdx].transactionSets[curTxSetIdx].hierarchicalLevelsCtr++;

		    /* Count but do not store segment */

		  x12DataObj.interchanges[curIcIdx].functionGroups[curFnGroupIdx].transactionSets[curTxSetIdx].segmentsCtr++;
		}

		/* Transaction set end */
	  
	    else if (segmentName === 'SE')
		{        	    
		  x12DataObj.interchanges[curIcIdx].segmentCountTransactionSetTrailer++;

		  /* If this is a hierarchicalTransaction get the dataSegmentsEndIdx
		   * for the last HL */

		  if (x12DataObj.interchanges[curIcIdx].functionGroups[curFnGroupIdx].transactionSets[curTxSetIdx].hierarchicalTransaction === true) {
			  if (curHlKey) {
				  let currHLObj = x12DataObj.interchanges[curIcIdx].functionGroups[curFnGroupIdx].transactionSets[curTxSetIdx].hierarchicalLevels.get(curHlKey);
				  currHLObj.dataSegmentsEndIdx = x12DataObj.interchanges[curIcIdx].functionGroups[curFnGroupIdx].transactionSets[curTxSetIdx].dataSegments.length - 1;
				  x12DataObj.interchanges[curIcIdx].functionGroups[curFnGroupIdx].transactionSets[curTxSetIdx].hierarchicalLevels.set(curHlKey, currHLObj);
			  }			  
		  }

		  preHlKey = null;
		  curHlKey = null;

		  /* Count but do not store segment*/

		  x12DataObj.interchanges[curIcIdx].functionGroups[curFnGroupIdx].transactionSets[curTxSetIdx].segmentsCtr++;

	      /* Checksum */

		  x12DataObj.interchanges[curIcIdx].functionGroups[curFnGroupIdx].transactionSets[curTxSetIdx].segmentsExpected = parseInt(elements[1]);

		  if (x12DataObj.interchanges[curIcIdx].functionGroups[curFnGroupIdx].transactionSets[curTxSetIdx].segmentsCtr != x12DataObj.interchanges[curIcIdx].functionGroups[curFnGroupIdx].transactionSets[curTxSetIdx].segmentsExpected)
		  {
			  x12DataObj.errorsCtr++;
			  x12DataObj.errors.push('SE - Segment count mismatch');			  
		  }
		  
		  if (x12DataObj.interchanges[curIcIdx].functionGroups[curFnGroupIdx].transactionSets[curTxSetIdx].controlNumber != elements[2])
		  {		    
			  x12DataObj.errorsCtr++;
			  x12DataObj.errors.push('SE - Control number mismatch');
		  }
	    }
	       	  
		else if (segmentName != '')
		{
		
		  let segment = {};
		  
		  segment.name                     = segmentName;		  
		  segment.hierarchicalLevelKey     = curHlKey;
		  segment.elements                 = elements;
		  
		  /*segment.elements.forEach((element, elementsArrIndex, elementsArrRef) => {
	      
          });*/	  
		  		 		  
		  x12DataObj.interchanges[curIcIdx].functionGroups[curFnGroupIdx].transactionSets[curTxSetIdx].dataSegments.push(segment);
		  x12DataObj.interchanges[curIcIdx].functionGroups[curFnGroupIdx].transactionSets[curTxSetIdx].segmentsCtr++;		  

		}
	  	
		/* No name */
		
		else 
		{
		
		}			
	    
	  });

	}
	catch (err) 
	{
	  x12DataObj.success = false;
	  x12DataObj.message = err.message;
	}
    return x12DataObj;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

const _fnFindHLByLevelCode = function (levelCode, hierarchicalLevels) {

	let resultObj = {};
	resultObj.hierarchicalLevelKey;
	resultObj.found = false;
	resultObj.hierarchicalLevel = {};

	/* Note: Cannot use a forEach because you cant break out of forEach */
	for (const [key, value] of hierarchicalLevels) {
		if (value.levelCode === levelCode) {
			resultObj.hierarchicalLevelKey = key;
			resultObj.hierarchicalLevel    = value;
			resultObj.found = true;
			break; 
		}		
	};
	return resultObj;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

const _fnFindHLsByLevelCode = function (levelCode, hierarchicalLevels) {
	let resultObj = {};
	resultObj.numFound = 0;
	resultObj.hierarchicalLevels = [];
	hierarchicalLevels.forEach((hierarchicalLevel) => {
		if (hierarchicalLevel.levelCode === levelCode) {
			resultObj.hierarchicalLevels.push(hierarchicalLevel);
			resultObj.hierarchicalLevels.numFound++;
		}
	});
	return resultObj;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

const _fnGetSubElementValueAtPos = function (subelements, subElementPos) {

	/* Note: Designed to work with X12 position documentation for sub elements
	 * ie STC01 - 1, STC01 - 2. */

	let _elementVal = null;
	let _elementIdx = 0;

	try {

		let _maxPos = subelements.length;

		if ((subElementPos > 0) && (subElementPos <= _maxPos)) {
			_elementIdx = subElementPos - 1;
			_elementVal = subelements[_elementIdx].toUpperCase();
		}
	}
	catch {
	  _elementVal = null
	}

	return _elementVal;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

const _fnGetSegmentElementValueAtPos = function (elements, elementPos) {

	/* Note: Designed to work with X12 position documentation for elements
     * ie STC01, STC02 */

	let _elementVal = null;

	try {
		let _maxPos = elements.length - 1;
		if ((elementPos > 0) && (elementPos <= _maxPos)) {
			_elementVal = elements[elementPos].toUpperCase();
		}
	}
	catch {
	  _elementVal = null
	}

	return _elementVal;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

const _fnGetElementValueFromDataSegment = function (dataSegment, elementPos) {
	let _elementVal = null;	
	try {
	  _elementVal = _fnGetSegmentElementValueAtPos(dataSegment.elements, elementPos);		
	}
	catch {
		_elementVal = null
	}
	return _elementVal;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

const _isElementValueInDataSegmentEqualToTestValue = function (dataSegment, elementPos, testValue) {
	let _elementVal = _fnGetElementValueFromDataSegment(dataSegment, elementPos);
	if (!_elementVal) return false;
	if (_elementVal === testValue) {
		return true;
	}
	return false;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

const _fnParseX125010QtyDataSegment = function (dataSegment) {

  /* X12 Name : Monetary Amount Information */

  let _qtyObj = {};
  _qtyObj.qualifier = _fnGetElementValueFromDataSegment(dataSegment, 1);
  _qtyObj.value		= parseInt(_fnGetElementValueFromDataSegment(dataSegment, 2));		
  return _qtyObj;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

const _fnParseX125010AmtDataSegment = function (dataSegment) {

  /* X12 Name : Quantity Information */

  let _amtObj = {};
  _amtObj.qualifier = _fnGetElementValueFromDataSegment(dataSegment, 1);
  _amtObj.value = parseFloat(_fnGetElementValueFromDataSegment(dataSegment, 2));
  return _amtObj;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

const _fnParseX125010Nm1DataSegment = function (dataSegment) {
	let _nm1Obj = {};
	_nm1Obj.entityIdentifierCode     = _fnGetElementValueFromDataSegment(dataSegment, 1);
	_nm1Obj.entityTypeQualifierCode  = _fnGetElementValueFromDataSegment(dataSegment, 2);
    _nm1Obj.lastOrOrgName            = _fnGetElementValueFromDataSegment(dataSegment, 3);
	_nm1Obj.firstName                = _fnGetElementValueFromDataSegment(dataSegment, 4);
	_nm1Obj.idCodeQualifier          = _fnGetElementValueFromDataSegment(dataSegment, 8);
	_nm1Obj.idCode                   = _fnGetElementValueFromDataSegment(dataSegment, 9);
	return _nm1Obj;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

const _fnParseX125010277DataObjIntoTxSetReportsObj = function (x12DataObj) {

  let returnObj = {};	
  returnObj.success       = true;
  returnObj.message       = '';
  returnObj.txSetReports  = [];

  const _entityIdentifier98         = _fnGenerateCodeSetMap_DataElement98();
  const _claimStatusCodeCategory507 = _fnGenerateCodeSetMap_CodeSource507();
  const _claimStatusCode508         = _fnGenerateCodeSetMap_CodeSource508();

  /*-----------------------------------------*/

  const _fnCreateEmptyStcObj = function () {
	  let _statusObj = {};
	  _statusObj.accepted              = null;	  
	  _statusObj.effectiveDate         = null;
	  _statusObj.actionCode            = null;
	  _statusObj.amount                = null;
	  _statusObj.messageText           = null;
	  _statusObj.statusCodeObjs        = [];
	  return _statusObj;
  };

  /*-----------------------------------------*/

  const _fnParseStcCompositeStatusCode = function (statusCode) {

	 /*
	  * 01 : Health Care Claim Status Category Code (Code Source 507).
	  * The Category Code indicates the level of pre - adjudication status of the claim.
	  * This implementation guide will only utilize Category Codes indicating Acknowledgement(Ax) and Errors(Ex).
 	  * 
	  * 02 : Health Care Claim Status Code (Code Source 508).
	  * The Status Code provides more specific information about the claim or line item.
	  * Examples of status messages include :
	  * 19 - entity acknowledges receipt of claim / encounter
	  * 122 - missing /invalid data prevents payer from processing claim
	  * 
	  * 03: Entity Identifier Code (ASC X12 data element 98). 
	  * The Entity Identifier code is used to clarify the entity when referred 
	  * to in the status message (CO43-02). The code list identifies an 
	  * organizational entity, a physical location, property, or an individual.
	  */

	  let _statusCodeObj = {};
	 
	  let _elements = statusCode.split(x12DataObj.delimeters.componentElementSeperator);
	  
	  let _subElement1 = _fnGetSubElementValueAtPos(_elements, 1);
	  let _subElement2 = _fnGetSubElementValueAtPos(_elements, 2);
	  let _subElement3 = _fnGetSubElementValueAtPos(_elements, 3);

	  _statusCodeObj.claimStatusCategoryCodeValue = _subElement1 ?? "";
	  _statusCodeObj.claimStatusCodeValue         = _subElement2 ?? "";
	  _statusCodeObj.entityIdentifierCodeValue    = _subElement3 ?? "";	  

	  _statusCodeObj.claimStatusCategoryCodeName = _claimStatusCodeCategory507.get(_statusCodeObj.claimStatusCategoryCodeValue) ?? "";
	  _statusCodeObj.claimStatusCodeName = _claimStatusCode508.get(_statusCodeObj.claimStatusCodeValue) ?? "";
	  _statusCodeObj.entityIdentifierCodeName    = _entityIdentifier98.get(_statusCodeObj.entityIdentifierCodeValue) ?? "";
	  
	  return _statusCodeObj;
  };

  /*-----------------------------------------*/

  const _fnParseStcDataSegment = function (dataSegment) {

	    let _statusObj = _fnCreateEmptyStcObj();

		let _stc01 = _fnGetElementValueFromDataSegment(dataSegment, 1);
		let _stc10 = _fnGetElementValueFromDataSegment(dataSegment, 10);
		let _stc11 = _fnGetElementValueFromDataSegment(dataSegment, 11);
		
	    _statusObj.effectiveDate  = _fnConvertCCYYMMDDToDate(_fnGetElementValueFromDataSegment(dataSegment, 2));
		_statusObj.actionCode     = _fnGetElementValueFromDataSegment(dataSegment, 3);
		_statusObj.amount         = parseFloat(_fnGetElementValueFromDataSegment(dataSegment, 4));
	    _statusObj.messageText    = _fnGetElementValueFromDataSegment(dataSegment, 12) ?? "";

	    if (_stc01) { _statusObj.statusCodeObjs.push(_fnParseStcCompositeStatusCode(_stc01)); }
		if (_stc10) { _statusObj.statusCodeObjs.push(_fnParseStcCompositeStatusCode(_stc10)); }
		if (_stc11) { _statusObj.statusCodeObjs.push(_fnParseStcCompositeStatusCode(_stc11)); }
		  
	    if (_statusObj.actionCode === 'WQ') {
		  _statusObj.accepted = true;
	    } else if (_statusObj.actionCode === 'U') {
		  _statusObj.accepted = false;
	    }
	    else {
		  _statusObj.accepted = null;
	    }

	    return _statusObj;
    };

  /*-----------------------------------------*/

  try
  {

	  if (x12DataObj.success === false) {
		  throw new Error ("Invalid data");
	  }
	  
	  x12DataObj.interchanges.forEach((interchange) => {
		  interchange.functionGroups.forEach((functionGroup) => {
			  functionGroup.transactionSets.forEach((transactionSet) => {

				  /* If the transaction set is not a 277 then get out */

				  if (transactionSet.identifierCode != '277') {
					  throw new Error("Not a 277");
				  }

				  let reportObj = {};

				  reportObj.summaryObj = {};
				  reportObj.summaryObj.icControlNumber       = interchange.controlNumber;
				  reportObj.summaryObj.fgControlNumber       = functionGroup.controlNumber;
				  reportObj.summaryObj.txSetControlNumber    = transactionSet.controlNumber;
				  reportObj.summaryObj.sourceName            = '';
				  reportObj.summaryObj.receiverName          = '';
				  reportObj.summaryObj.senderTransactionID   = '';
				  reportObj.summaryObj.transmissionID        = '';
				  reportObj.summaryObj.dateReceived          = null;
				  reportObj.summaryObj.dateProcessed         = null;
				  reportObj.summaryObj.qtyClaimsAccepted     = 0;
				  reportObj.summaryObj.qtyClaimsRejected     = 0;
				  reportObj.summaryObj.amtClaimsAccepted     = 0;
				  reportObj.summaryObj.amtClaimsRejected     = 0;
				  reportObj.summaryObj.entireBatchRejected   = false;
				  reportObj.summaryObj.batchStatusState      = 3;
				  reportObj.summaryObj.batchStatusMessage    = '';

				  reportObj.detailObjs = [];

				  /******************** Source ********************/

				  let hl20 = _fnFindHLByLevelCode('20', transactionSet.hierarchicalLevels);

				  for (let i = hl20.hierarchicalLevel.dataSegmentsStartIdx; i <= hl20.hierarchicalLevel.dataSegmentsEndIdx; i++) {

					  /* Info source name.
					   * Required. Only expect 1 at this level. */

					  if (transactionSet.dataSegments[i].name === 'NM1') {
						  reportObj.summaryObj.sourceName   = _fnGetElementValueFromDataSegment(transactionSet.dataSegments[i], 3);
						  reportObj.summaryObj.sourceIDCode = _fnGetElementValueFromDataSegment(transactionSet.dataSegments[i], 9);
					  }					 					  

					   /* Info source application trace identifier 
						* Required. Only expect 1 at this level.
						*/

					  else if (transactionSet.dataSegments[i].name === 'TRN') {
                        reportObj.summaryObj.senderTransactionID = _fnGetElementValueFromDataSegment(transactionSet.dataSegments[i], 2);
					  }

					  /* Can either be info source received or processed date */

					  else if (transactionSet.dataSegments[i].name === 'DTP') {

						  const _dateVal = _fnConvertCCYYMMDDToDate(_fnGetElementValueFromDataSegment(transactionSet.dataSegments[i], 3));

						  /* Received date 
						   * Required. Only expect 1 at this level.
						   */

						  if (_isElementValueInDataSegmentEqualToTestValue(transactionSet.dataSegments[i], 1, '050')) {						  
							  reportObj.summaryObj.dateReceived = _dateVal;
						  }

					      /* Processed date 
						   * Required. Only expect 1 at this level.
						   */

						  else if (_isElementValueInDataSegmentEqualToTestValue(transactionSet.dataSegments[i], 1, '009')) {
							  reportObj.summaryObj.dateProcessed = _dateVal;
						  }

						  else {

						  }
					  }
					  else {

					  }
				  };

				  /******************* Receiver *******************/

				  let hl21 = _fnFindHLByLevelCode('21', transactionSet.hierarchicalLevels);

				  for (let i = hl21.hierarchicalLevel.dataSegmentsStartIdx; i <= hl21.hierarchicalLevel.dataSegmentsEndIdx; i++) {

					  /* Info receiver name.
                       * Required. Only expect 1 at this level. */

					  if (transactionSet.dataSegments[i].name === 'NM1') {
						  reportObj.summaryObj.receiverName   = _fnGetElementValueFromDataSegment(transactionSet.dataSegments[i], 3);
						  reportObj.summaryObj.receiverIDCode = _fnGetElementValueFromDataSegment(transactionSet.dataSegments[i], 9);
					  }

					  /* Info receiver application trace identifier
					   * Required. Only expect 1 at this level.
					   * Note: This segment contains the value submitted in the BHT03 data element from the 837
					   */

					  else if (transactionSet.dataSegments[i].name === 'TRN') {						  
						reportObj.summaryObj.transmissionID = _fnGetElementValueFromDataSegment(transactionSet.dataSegments[i], 2);
						/* We expect 1 or more status segments */
						reportObj.summaryObj.transmissionLevelStcObjs = [];
					  }

                      /* Info receiver status info
					   * Required.  1 or more are expected at this level.
					   * Note: This segment will be used to convey information about 
					   * an entire unit of work (e.g. single transaction of claims). 
					   * Information contained at this level will be summary details 
					   * pertaining to the unit of work being acknowledged. 
					   */

					  else if (transactionSet.dataSegments[i].name === 'STC') {

						  let _stcObj = _fnParseStcDataSegment(transactionSet.dataSegments[i]);

						  /* If previous data segment is a TRN segment then this is the first STC 
						   * segment and the first STC is going to provide info on if the entire batch 
						   * was rejected.*/

						  if (transactionSet.dataSegments[i-1].name === 'TRN') {
							  if (_stcObj.accepted === true) {
								  reportObj.summaryObj.entireBatchRejected = false;
							  } else {
								  reportObj.summaryObj.entireBatchRejected = true;
                              }
						  }

						  /* Save the first STC and any subsequent STCS at this level */

						  reportObj.summaryObj.transmissionLevelStcObjs.push(_stcObj);
						  						  
					  }

                      /* Can either be total accepted or rejected quantity 
					   * for entire batch/transaction
					   * 
					   * Situational. 0 to 2 may be provided at this level.
					   */

					  else if (transactionSet.dataSegments[i].name === 'QTY') {

						  let _qty = parseInt(_fnGetElementValueFromDataSegment(transactionSet.dataSegments[i], 2));

						  /* Accepted */

						  if (transactionSet.dataSegments[i].elements[1] === '90') {
							  reportObj.summaryObj.qtyClaimsAccepted = _qty;
						  }

						  /* Rejected */

						  else if (transactionSet.dataSegments[i].elements[1] === 'AA') {
							  reportObj.summaryObj.qtyClaimsRejected = _qty;
						  }

						  else {

						  }

					  }
					  /* Can either be total accepted or rejected amount 
					   * for entire batch/transaction
					   *
 					   * Situational. 0 to 2 may be provided at this level.
					   */

					  else if (transactionSet.dataSegments[i].name === 'AMT') {

						  let _amt = _fnGetElementValueFromDataSegment(transactionSet.dataSegments[i], 2);

						  if (transactionSet.dataSegments[i].elements[1] === 'YU') {
							  reportObj.summaryObj.amtClaimsAccepted = _amt;
						  }

						  else if (transactionSet.dataSegments[i].elements[1] === 'YY') {
							  reportObj.summaryObj.amtClaimsRejected = _amt;
						  }

						  else {

						  }

					  }

					  else {

					  }
				  }; /* Receiver */

				  /******************* Patients *******************/

				  let hlPts = _fnFindHLsByLevelCode('PT', transactionSet.hierarchicalLevels);

				  hlPts.hierarchicalLevels.forEach((hlPt) => {

					  let detailObj                  = {};
					  detailObj.patientLastName      = '';
					  detailObj.patientFirstName     = '';
					  detailObj.patientBeneficiaryID = '';
					  detailObj.claims               = new Map();

					  let currentTrn = '';

					  for (let i = hlPt.dataSegmentsStartIdx; i <= hlPt.dataSegmentsEndIdx; i++) {

						 /* Patient name.
                          * Required. Only expect 1 at this level. */

						  if (transactionSet.dataSegments[i].name === 'NM1') {
							  
							  detailObj.patientLastName      = _fnGetElementValueFromDataSegment(transactionSet.dataSegments[i], 3);
							  detailObj.patientFirstName     = _fnGetElementValueFromDataSegment(transactionSet.dataSegments[i], 4);
							  detailObj.patientBeneficiaryID = _fnGetElementValueFromDataSegment(transactionSet.dataSegments[i], 9);
						  }

						  /* Patient claim tracking number
						   * Required. Only one expected at this level.
						   *
						   * Note: This segment is the patient control 
						   * number submitted in the CLM01 of the 837.
						   */

						  else if (transactionSet.dataSegments[i].name === 'TRN') {							  
							 currentTrn =  _fnGetElementValueFromDataSegment(transactionSet.dataSegments[i], 2);							 
							  let _statusObj = {};
							  _statusObj.accepted = null;
							  /* We expect 1 or more status segments */
							 _statusObj.patientLevelStcObjs = [];							
							 detailObj.claims.set(currentTrn, _statusObj);							  
						  }

						  /* Patient level status info
						   * Required.  1 or more are expected at this level.
						   * Provides status info about a claim or service line
						   */

						  else if (transactionSet.dataSegments[i].name === 'STC') {
							 
							  let _statusObj = detailObj.claims.get(currentTrn);
							  let _stcObj = _fnParseStcDataSegment(transactionSet.dataSegments[i]);

							  /* If previous data segment is a TRN segment then 
							   * this is the first STC segment and we use that segment
							   * to determine if the claim was accepted or rejected
							   */

							  if (transactionSet.dataSegments[i - 1].name === 'TRN') {								  
								  _statusObj.accepted      = _stcObj.accepted;								  
							  } /* Prev segment is TRN*/

							  _statusObj.patientLevelStcObjs.push(_stcObj);
							  detailObj.claims.set(currentTrn, _statusObj);
						  }
					  };
					  reportObj.detailObjs.push(detailObj);
				  });

				  /***************** Determine Overall Status of Batch *******************/

				  reportObj.summaryObj.batchStatusState   = 3;
				  reportObj.summaryObj.batchStatusMessage = 'Could not be determined';

				  if (reportObj.summaryObj.entireBatchRejected === true) {
					  reportObj.summaryObj.batchStatusMessage = 'Entire batch rejected.';
					  reportObj.summaryObj.batchStatusState = 3;
				  }
				  else if ((reportObj.summaryObj.qtyClaimsRejected === 0) && (reportObj.summaryObj.qtyClaimsAccepted === 0)) {
					  reportObj.summaryObj.batchStatusMessage = 'None accepted and none rejected';
					  reportObj.summaryObj.batchStatusState = 3;
				  }
				  else if ((reportObj.summaryObj.qtyClaimsRejected > 0) && (reportObj.summaryObj.qtyClaimsAccepted === 0)) {
					  reportObj.summaryObj.batchStatusMessage = 'All rejected';
					  reportObj.summaryObj.batchStatusState = 3;
				  }
				  else if ((reportObj.summaryObj.qtyClaimsRejected === 0) && (reportObj.summaryObj.qtyClaimsAccepted > 0)) {
					  reportObj.summaryObj.batchStatusMessage = 'All accepted';
					  reportObj.summaryObj.batchStatusState = 1;
				  }
				  else if ((reportObj.summaryObj.qtyClaimsRejected > 0) && (reportObj.summaryObj.qtyClaimsAccepted > 0)) {					  
					  reportObj.summaryObj.batchStatusMessage = 'Some rejected and some accepted';
					  reportObj.summaryObj.batchStatusState = 2;
				  }
				  else {
					  reportObj.summaryObj.batchStatusMessage = 'Could not be determined';
					  reportObj.summaryObj.batchStatusState = 3;
				  }

				  returnObj.txSetReports.push(reportObj);

			  }); /* Transaction sets */
		  }); /* Function groups */
	  }); /* Interchanges */

	}
	catch (err)
	{
	  returnObj.success = false;
	  returnObj.message = err.message;
	}
	return returnObj;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

const _fnParseX125010835DataObjIntoTxSetReportsObj = function (x12DataObj) {

  let returnObj = {};	
  returnObj.success       = true;
  returnObj.message       = '';
  returnObj.txSetReports  = [];
  returnObj.txSetCount    = 0;

  const _claimStatusCodes = _fnGenerateCodeSetMap_DataElement1029();
  const _carcCodes = _fnGenerateCodeSetMap_CodeSource139Carc();
  const _rarcCodes = _fnGenerateCodeSetMap_CodeSource411Rarc();
  const _plbCodes  = _fnGenerateCodeSetMap_CodeSource967();

	/*------------------------------------------------*/

	const _fnParseX125010CasTrioDataElements = function (groupCodeElement, reasonCodeElement, amountElement, quantityElement) {
		let _adjustmentObj = {};
		_adjustmentObj.groupCode = groupCodeElement ?? '';
		if (_adjustmentObj.groupCode === '') return null;
		_adjustmentObj.reasonCode = reasonCodeElement;
		_adjustmentObj.reasonCodeDescription = _carcCodes.get(reasonCodeElement) ?? 'Code description not found';
		_adjustmentObj.amountStr = amountElement;
		_adjustmentObj.amount = parseFloat(amountElement);
		_adjustmentObj.quantity = parseInt(quantityElement ?? 0); /* Qty is situational */
		_adjustmentObj.quantityStr = quantityElement;
		return _adjustmentObj;
	};

	/*------------------------------------------------*/

	const _fnParseX125010CasDataSegment = function (dataSegment) {

		// A single CAS segment contains six repetitions of the "adjustment trio" composed of
		// adjustment reason code
		// adjustment amount
		// and adjustment quantity
		// These six adjustment trios are used to report up to six adjustments
		// related to a specific Claim Adjustment Group Code(CAS01).
		// The six iterations(trios) of the Adjustment Reason Code related 
		// to the Specific Adjustment Group Code must be exhausted 
		// before repeating a second iteration of the CAS segment 
		// using the same Adjustment Group Code.
		// The first adjustment must be the first non - zero adjustment 
		// and is reported in the first adjustment trio(CAS02 - CAS04).
		// If there is a second non - zero adjustment, it is reported in 
		// the second adjustment trio(CAS05 - CAS07), and so on 
		// through the sixth adjustment trio(CAS17 - CAS19).

		let _adjustmentObjs = [];

		/* Trio 1/6 */

		let adjustmentObj1 = _fnParseX125010CasTrioDataElements(
			_fnGetElementValueFromDataSegment(dataSegment, 1)
			, _fnGetElementValueFromDataSegment(dataSegment, 2)
			, _fnGetElementValueFromDataSegment(dataSegment, 3)
			, _fnGetElementValueFromDataSegment(dataSegment, 4)
		);

		/* The first has to be there.  The rest are optional. */

		_adjustmentObjs.push(adjustmentObj1);

		/* Trio 2/6 */

		let adjustmentObj2 = _fnParseX125010CasTrioDataElements(
			_fnGetElementValueFromDataSegment(dataSegment, 5)
			, _fnGetElementValueFromDataSegment(dataSegment, 6)
			, _fnGetElementValueFromDataSegment(dataSegment, 7)
			, _fnGetElementValueFromDataSegment(dataSegment, 8)
		);

		if (adjustmentObj2) _adjustmentObjs.push(adjustmentObj2); else return _adjustmentObjs;

		/* Trio 3/6 */

		let adjustmentObj3 = _fnParseX125010CasTrioDataElements(
			_fnGetElementValueFromDataSegment(dataSegment, 9)
			, _fnGetElementValueFromDataSegment(dataSegment, 10)
			, _fnGetElementValueFromDataSegment(dataSegment, 11)
			, _fnGetElementValueFromDataSegment(dataSegment, 12)
		);

		if (adjustmentObj3) _adjustmentObjs.push(adjustmentObj3); else return _adjustmentObjs;

		/* Trio 4/6 */

		let adjustmentObj4 = _fnParseX125010CasTrioDataElements(
			_fnGetElementValueFromDataSegment(dataSegment, 13)
			, _fnGetElementValueFromDataSegment(dataSegment, 14)
			, _fnGetElementValueFromDataSegment(dataSegment, 15)
			, _fnGetElementValueFromDataSegment(dataSegment, 16)
		);

		if (adjustmentObj4) _adjustmentObjs.push(adjustmentObj4); else return _adjustmentObjs;

		/* Trio 5/6 */

		let adjustmentObj5 = _fnParseX125010CasTrioDataElements(
			_fnGetElementValueFromDataSegment(dataSegment, 17)
			, _fnGetElementValueFromDataSegment(dataSegment, 18)
			, _fnGetElementValueFromDataSegment(dataSegment, 19)
			, _fnGetElementValueFromDataSegment(dataSegment, 20)
		);

		if (adjustmentObj5) _adjustmentObjs.push(adjustmentObj5); else return _adjustmentObjs;

		/* Trio 6/6 */

		let adjustmentObj6 = _fnParseX125010CasTrioDataElements(
			_fnGetElementValueFromDataSegment(dataSegment, 21)
			, _fnGetElementValueFromDataSegment(dataSegment, 22)
			, _fnGetElementValueFromDataSegment(dataSegment, 23)
			, _fnGetElementValueFromDataSegment(dataSegment, 24)
		);

		if (adjustmentObj6) _adjustmentObjs.push(adjustmentObj6); else return _adjustmentObjs;

		return _adjustmentObjs;
	};

	/*------------------------------------------------*/


	const _fnParseX125010PlbDataSegment = function (dataSegment, componentElementSeperator) {

		/*-------------------------------------------*/

		let _fnCreateAdjustmentObj = function (providerIdentifier, fiscalPeriodEndDate, adjustmentIdentifier, amount) {

			if (!adjustmentIdentifier) return null;

			let _adjustmentIdentifierParts = adjustmentIdentifier.split(componentElementSeperator);

			let _adjustmentObj = {};
			_adjustmentObj.providerIdentifier = providerIdentifier;
			_adjustmentObj.fiscalPeriodEndDate = fiscalPeriodEndDate;

			_adjustmentObj.reasonCode = _fnGetSubElementValueAtPos(_adjustmentIdentifierParts, 1);
			_adjustmentObj.reasonCodeDescription = _plbCodes.get(_adjustmentObj.reasonCode) ?? 'Code description not found'; /* */
			_adjustmentObj.adjustmentIdentifier = _fnGetSubElementValueAtPos(_adjustmentIdentifierParts, 2);
			_adjustmentObj.amountStr = amount;
			_adjustmentObj.amount = parseFloat(amount);

			return _adjustmentObj;
		};

		/*-------------------------------------------*/

		let _adjustmentObjs = [];

		/* This the provider number assigned by the payer.
		 * When the National Provider Identifier (NPI) is mandated and the provider is 
		 * a covered health care provider under that mandate, this must be the NPI assigned
		 * to the provider. Until the NPI is mandated, this is the provider identifier
		 * as assigned by the payer.
		 */

		let _providerIdentifier = _fnGetElementValueFromDataSegment(dataSegment, 1);

		/* This is the last day of the provider's fiscal year. 
		 * If the end of the provider's fiscal year is not known by the payer
		 * then December 31st of the current year is required to be used.
		 */

		let _fiscalPeriodEndDate = _fnConvertCCYYMMDDToDate(_fnGetElementValueFromDataSegment(dataSegment, 2));

		/* The first has to be there.  The rest are optional. */

		let adjustmentObj1 = _fnCreateAdjustmentObj(_providerIdentifier, _fiscalPeriodEndDate, _fnGetElementValueFromDataSegment(dataSegment, 3), _fnGetElementValueFromDataSegment(dataSegment, 4));
		_adjustmentObjs.push(adjustmentObj1);

		/* 2 of 6 */

		let adjustmentObj2 = _fnCreateAdjustmentObj(_providerIdentifier, _fiscalPeriodEndDate, _fnGetElementValueFromDataSegment(dataSegment, 5), _fnGetElementValueFromDataSegment(dataSegment, 6));
		if (adjustmentObj2) _adjustmentObjs.push(adjustmentObj2); else return _adjustmentObjs;

		/* 3 of 6 */

		let adjustmentObj3 = _fnCreateAdjustmentObj(_providerIdentifier, _fiscalPeriodEndDate, _fnGetElementValueFromDataSegment(dataSegment, 7), _fnGetElementValueFromDataSegment(dataSegment, 8));
		if (adjustmentObj3) _adjustmentObjs.push(adjustmentObj3); else return _adjustmentObjs;

		/* 4 of 6 */

		let adjustmentObj4 = _fnCreateAdjustmentObj(_providerIdentifier, _fiscalPeriodEndDate, _fnGetElementValueFromDataSegment(dataSegment, 9), _fnGetElementValueFromDataSegment(dataSegment, 10));
		if (adjustmentObj4) _adjustmentObjs.push(adjustmentObj4); else return _adjustmentObjs;

		/* 5 of 6 */

		let adjustmentObj5 = _fnCreateAdjustmentObj(_providerIdentifier, _fiscalPeriodEndDate, _fnGetElementValueFromDataSegment(dataSegment, 11), _fnGetElementValueFromDataSegment(dataSegment, 12));
		if (adjustmentObj5) _adjustmentObjs.push(adjustmentObj5); else return _adjustmentObjs;

		/* 6 of 6 */

		let adjustmentObj6 = _fnCreateAdjustmentObj(_providerIdentifier, _fiscalPeriodEndDate, _fnGetElementValueFromDataSegment(dataSegment, 13), _fnGetElementValueFromDataSegment(dataSegment, 14));
		if (adjustmentObj6) _adjustmentObjs.push(adjustmentObj6); else return _adjustmentObjs;

		return _adjustmentObjs;
	};

	/*------------------------------------------------*/

  try
  {

	  if (x12DataObj.success === false) {
		  throw new Error ("Invalid data");
	  }
	  
	  x12DataObj.interchanges.forEach((interchange) => {
		  interchange.functionGroups.forEach((functionGroup) => {
			  functionGroup.transactionSets.forEach((transactionSet) => {

				  /* If the transaction set is not a 835 then get out */

				  if (transactionSet.identifierCode != '835') {
					  throw new Error("Not a 835");
				  }
				 
				  let reportObj = {};
				  
				  reportObj.summaryObj = {};
				  reportObj.summaryObj.icControlNumber       = interchange.controlNumber;
				  reportObj.summaryObj.fgControlNumber       = functionGroup.controlNumber;
				  reportObj.summaryObj.txSetControlNumber    = transactionSet.controlNumber;				  
				  reportObj.summaryObj.payer = {};

				  reportObj.summaryObj.payer.name = '';
				  reportObj.summaryObj.payer.idCodeQualifier = '';
				  reportObj.summaryObj.payer.idCode          = '';

				  reportObj.summaryObj.payee = {};
				  reportObj.summaryObj.payee.name = '';
				  reportObj.summaryObj.payee.idCodeQualifier = '';
				  reportObj.summaryObj.payee.idCode = '';

				  reportObj.summaryObj.check = {};
				  reportObj.summaryObj.check.date = null;
				  reportObj.summaryObj.check.dateStr = '';
				  reportObj.summaryObj.check.number = '';
				  reportObj.summaryObj.check.amountStr = '0';
				  reportObj.summaryObj.check.amount    = 0;
				  reportObj.summaryObj.check.transactionHandlingCode = '';
				  reportObj.summaryObj.check.debitCreditFlagCode     = '';
				  reportObj.summaryObj.check.paymentMethodCode       = '';

				  reportObj.summaryObj.providerLevelAdjustments      = [];
                  
				  reportObj.summaryObj.qtyClaims                   = 0;
				  reportObj.summaryObj.qtyClaimsDenied             = 0;
				  reportObj.summaryObj.qtyClaimLevelAdjustments    = 0;
				  reportObj.summaryObj.qtyServiceLevelAdjustments  = 0;
				  reportObj.summaryObj.qtyProviderLevelAdjustments = 0;
				  reportObj.summaryObj.qtyHealthCareRemarks        = 0;

				  reportObj.summaryObj.amtProviderLevelAdjustments = 0;
				  reportObj.summaryObj.amtClaimLevelPayments       = 0;				  
		
				  reportObj.detailObjs = new Map();

				  let prevCLPRef   = '';
				  let currCLPRef   = '';
				  let currSVCIdx   = -1;
				  let currentLoop  = '';

				  transactionSet.dataSegments.forEach((dataSegment) => {

					  if (dataSegment.name === 'BPR') {
						  currentLoop = '';
						  reportObj.summaryObj.check.transactionHandlingCode = _fnGetElementValueFromDataSegment(dataSegment, 1);
						  reportObj.summaryObj.check.amountStr = _fnGetElementValueFromDataSegment(dataSegment, 2);
						  reportObj.summaryObj.check.amount = parseFloat(reportObj.summaryObj.check.amountStr);
						  reportObj.summaryObj.check.debitCreditFlagCode = _fnGetElementValueFromDataSegment(dataSegment, 3);
						  reportObj.summaryObj.check.paymentMethodCode = _fnGetElementValueFromDataSegment(dataSegment, 4);
						  reportObj.summaryObj.check.dateStr = _fnGetElementValueFromDataSegment(dataSegment, 16);
						  reportObj.summaryObj.check.date    = _fnConvertCCYYMMDDToDate(reportObj.summaryObj.check.dateStr);
						  
					  }

					  else if (dataSegment.name === 'TRN') {
						  /* Should only be one trn */ 
						  currentLoop = '';
						  reportObj.summaryObj.check.number = _fnGetElementValueFromDataSegment(dataSegment, 2);
					  }

					  else if (dataSegment.name === 'N1') {
						  let n1Obj = {};
						  n1Obj.name            = _fnGetElementValueFromDataSegment(dataSegment, 2);
						  n1Obj.idCodeQualifier = _fnGetElementValueFromDataSegment(dataSegment, 3);
						  n1Obj.idCode          = _fnGetElementValueFromDataSegment(dataSegment, 4);

						  if (_isElementValueInDataSegmentEqualToTestValue(dataSegment, 1, 'PR')) {
							  currentLoop = '1000A';
							  reportObj.summaryObj.payer = n1Obj;
						  }

						  if (_isElementValueInDataSegmentEqualToTestValue(dataSegment, 1, 'PE')) {
							  currentLoop = '1000B';
							  reportObj.summaryObj.payee = n1Obj;
						  }
					  }

					  else if (dataSegment.name === 'CLP') {

						  reportObj.summaryObj.qtyClaims++;

						  currentLoop = '2100';
						  currSVCIdx = -1;
						  let clpObj = {};

						  clpObj.patientControlNumber        = _fnGetElementValueFromDataSegment(dataSegment, 1);
						  clpObj.claimStatusCode             = _fnGetElementValueFromDataSegment(dataSegment, 2);
						  clpObj.claimStatusDescription      = _claimStatusCodes.get(clpObj.claimStatusCode) ?? 'Description not found';
						  clpObj.amountSubmittedStr          = _fnGetElementValueFromDataSegment(dataSegment, 3);
						  clpObj.amountSubmitted             = parseFloat(clpObj.amountSubmittedStr);
						  clpObj.amountPaidStr               = _fnGetElementValueFromDataSegment(dataSegment, 4);
						  clpObj.amountPaid                  = parseFloat(clpObj.amountPaidStr);
						  clpObj.patientResponsibilityAmount = _fnGetElementValueFromDataSegment(dataSegment, 5) ?? "0";
						  clpObj.claimFilingIndicatorCode    = _fnGetElementValueFromDataSegment(dataSegment, 6);
						  clpObj.claimControlNumber          = _fnGetElementValueFromDataSegment(dataSegment, 7);
						  
						  clpObj.patient                  = null;
						  clpObj.hasRenderingPractitioner = false;
						  clpObj.renderingPractitioner    = null;

						  clpObj.statementPeriodStartDate = null;
						  clpObj.statementPeriodEndDate   = null;
						  clpObj.coverageExpiredDate      = null;
						  clpObj.claimReceivedDate        = null;

						  clpObj.statementPeriodStartDateStr = '';
						  clpObj.statementPeriodEndDateStr   = '';
						  clpObj.coverageExpiredDateStr      = '';
						  clpObj.claimReceivedDateStr        = '';

						  clpObj.claimLevelAdjustments = [];
						  clpObj.services              = [];

						  prevCLPRef = currCLPRef;						  
						  currCLPRef = crypto.randomUUID();
						  clpObj.claimDenied = false;

						  if (clpObj.claimStatusCode === "4") {
							  reportObj.summaryObj.qtyClaimsDenied++;
							  clpObj.claimDenied = true;
						  }

						  reportObj.summaryObj.amtClaimLevelPayments = reportObj.summaryObj.amtClaimLevelPayments + clpObj.amountPaid;
						  reportObj.detailObjs.set(currCLPRef, clpObj);
					  }

					  else if (dataSegment.name === 'NM1') {

						  let nm1Obj = _fnParseX125010Nm1DataSegment(dataSegment);

						  /* NM1 segments per the spec should only be in 2100 loops */

						  if (currentLoop === '2100') {

							  let clpObj = reportObj.detailObjs.get(currCLPRef);

							  if (nm1Obj.entityIdentifierCode === 'QC') {
								  clpObj.patient = nm1Obj;
							  }

							  else if (nm1Obj.entityIdentifierCode === '82') {
								  clpObj.renderingPractitioner = nm1Obj;
								  clpObj.hasRenderingPractitioner = true;
							  }

							  reportObj.detailObjs.set(currCLPRef, clpObj);
						  }
					  }
	
					  else if (dataSegment.name === 'SVC') {
						  currentLoop = '2110';
						  let clpObj = reportObj.detailObjs.get(currCLPRef);
						  let service = {};
						  let pmcSubElements = _fnGetElementValueFromDataSegment(dataSegment, 1).split(x12DataObj.delimeters.componentElementSeperator);
						  let pmcObj = {};
						  pmcObj.codeQualifier = _fnGetSubElementValueAtPos(pmcSubElements, 1);
						  pmcObj.code          = _fnGetSubElementValueAtPos(pmcSubElements, 2);
						  pmcObj.mod1          = _fnGetSubElementValueAtPos(pmcSubElements, 3) ?? '';
						  pmcObj.mod2          = _fnGetSubElementValueAtPos(pmcSubElements, 4) ?? '';
						  pmcObj.mod3          = _fnGetSubElementValueAtPos(pmcSubElements, 5) ?? '';
						  pmcObj.mod4          = _fnGetSubElementValueAtPos(pmcSubElements, 6) ?? '';
						  pmcObj.procModCombo  = (pmcObj.code + ' ' + pmcObj.mod1 + ' ' + pmcObj.mod2 + ' ' + pmcObj.mod3 + ' ' + pmcObj.mod4).trim();

						  service.medicalProcedure = pmcObj;
						  service.amountSubmittedStr = _fnGetElementValueFromDataSegment(dataSegment, 2);
						  service.amountSubmitted = parseFloat(service.amountSubmittedStr);
						  service.amountPaidStr = _fnGetElementValueFromDataSegment(dataSegment, 3);
						  service.amountPaid = parseFloat(service.amountPaidStr);
						  service.lineItemControlNumber = '';

						  service.dosStart    = null;
						  service.dosStartStr = '';
						  service.dosEnd      = null;
						  service.dosEndStr   = '';
						  service.dos         = null;
						  service.dosStr      = '';
						  service.serviceLevelAdjustments = [];
						  service.healthCareRemarkCodes   = [];
						  service.policyReferences        = [];


						  clpObj.services.push(service);
						  currSVCIdx = clpObj.services.length-1;
						  reportObj.detailObjs.set(currCLPRef, clpObj);
					  }

					  else if (dataSegment.name === 'DTM') {

						  let _qualifier = _fnGetElementValueFromDataSegment(dataSegment, 1);
						  let _dateStr = _fnGetElementValueFromDataSegment(dataSegment, 2);
						  let _dateCCYYMMDD = _fnConvertCCYYMMDDToDate(_dateStr);

						  if (currentLoop === '2100') /* CLP related */ {
							  let clpObj = reportObj.detailObjs.get(currCLPRef);
							  if (_qualifier === '232') {
								  clpObj.statementPeriodStartDateStr = _dateStr;
								  clpObj.statementPeriodStartDate = _dateCCYYMMDD;
							  } /* period start */
							  else if (_qualifier === '233') {
								  clpObj.statementPeriodEndDateStr = _dateStr;
								  clpObj.statementPeriodEndDate = _dateCCYYMMDD;
							  } /* period end */
							  else if (_qualifier === '036') {
								  clpObj.coverageExpiredDateStr = _dateStr;
								  clpObj.coverageExpiredDate = _dateCCYYMMDD;
							  }
							  else if (_qualifier === '050') {
								  clpObj.claimReceivedDateStr = _dateStr;
								  clpObj.claimReceivedDate = _dateCCYYMMDD;
							  } /* received*/

							  reportObj.detailObjs.set(currCLPRef, clpObj);
						  }

						  else if (currentLoop === '2110') /* Svc related */ {
							  if (currSVCIdx >= 0) {
								  let clpObj = reportObj.detailObjs.get(currCLPRef);

								  if (_qualifier === '150') {
									  clpObj.services[currSVCIdx].dosStartStr = _dateStr;
									  clpObj.services[currSVCIdx].dosStart = _dateCCYYMMDD;
								  }
								  else if (_qualifier === '151') {
									  clpObj.services[currSVCIdx].dosEndStr = _dateStr;
									  clpObj.services[currSVCIdx].dosEnd = _dateCCYYMMDD;
								  }
								  else if (_qualifier === '472') {
									  clpObj.services[currSVCIdx].dosStr = _dateStr;
									  clpObj.services[currSVCIdx].dos = _dateCCYYMMDD;
								  }
								  reportObj.detailObjs.set(currCLPRef, clpObj);
							  }
						  }
						  else {

						  }
					  }

					  else if (dataSegment.name === 'CAS') {

						  /* Note: CAS should only be in CLP or SVC loops */

						  let _adjustments = _fnParseX125010CasDataSegment(dataSegment);

						  let clpObj = reportObj.detailObjs.get(currCLPRef);
						  
						  if (currentLoop === '2100') /* CLP related */ {

							  _adjustments.forEach((_adjustment) => {
								  reportObj.summaryObj.qtyClaimLevelAdjustments++;
								  clpObj.claimLevelAdjustments.push(_adjustment);
							  });							  
						  }
						  else if (currentLoop === '2110') /* Svc related */ {
							  if (currSVCIdx >= 0) {
								  _adjustments.forEach((_adjustment) => {
									  reportObj.summaryObj.qtyServiceLevelAdjustments++;
									  clpObj.services[currSVCIdx].serviceLevelAdjustments.push(_adjustment);
								  });
							  }
						  }
						  else { }						   
						  reportObj.detailObjs.set(currCLPRef, clpObj);						  
					  }

					  else if (dataSegment.name === 'REF') {


						  let refObj = {};
						  refObj.identificationQualifier = _fnGetElementValueFromDataSegment(dataSegment, 1);
						  refObj.identification          = _fnGetElementValueFromDataSegment(dataSegment, 2);

						  if (currentLoop === '2100') /* CLP related */ {
							  
						  }

						  else if (currentLoop === '2110') /* Svc related */ {
							  let clpObj = reportObj.detailObjs.get(currCLPRef);
							  if (currSVCIdx >= 0) {
								  if (refObj.identificationQualifier === '6R') {
									  clpObj.services[currSVCIdx].lineItemControlNumber = refObj.identification;
								  }
								  else if (refObj.identificationQualifier === '0K') {
									  clpObj.services[currSVCIdx].policyReferences.push(refObj.identification);
								  }
							  }
							  reportObj.detailObjs.set(currCLPRef, clpObj);
						  }
						  
						  else { }
						  
					  }

					  else if (dataSegment.name === 'LQ') {
						  

						  /* Should only be in 2110 loops */
						  if (currentLoop === '2110') /* Svc related */ {
					        if (currSVCIdx >= 0) {
							  let clpObj = reportObj.detailObjs.get(currCLPRef);
							  let remarkCodeObj = {};
							  remarkCodeObj.codeListQualifierCode = _fnGetElementValueFromDataSegment(dataSegment, 1);
							  remarkCodeObj.industryCode = _fnGetElementValueFromDataSegment(dataSegment, 2);
							  remarkCodeObj.industryCodeDescription = _rarcCodes.get(remarkCodeObj.industryCode) ?? 'Code description not found';
							  clpObj.services[currSVCIdx].healthCareRemarkCodes.push(remarkCodeObj);
							  reportObj.summaryObj.qtyHealthCareRemarks++;
							  reportObj.detailObjs.set(currCLPRef, clpObj);
						    }
						  }
					  }

					  else if (dataSegment.name === 'PLB') {
						  currentLoop = '';
						  
						  let _adjustments = _fnParseX125010PlbDataSegment(dataSegment, x12DataObj.delimeters.componentElementSeperator);
						  _adjustments.forEach((_adjustment) => {
							  reportObj.summaryObj.qtyProviderLevelAdjustments++;
							  reportObj.summaryObj.amtProviderLevelAdjustments = reportObj.summaryObj.amtProviderLevelAdjustments + _adjustment.amount;
							  reportObj.summaryObj.providerLevelAdjustments.push(_adjustment);							  
						  });
					  }

				  });
				  
				  
				  returnObj.txSetReports.push(reportObj);

			  }); /* Transaction sets */
		  }); /* Function groups */
	  }); /* Interchanges */

	}
	catch (err)
	{
	  returnObj.success = false;
	  returnObj.message = err.message;
	}
	return returnObj;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

const _fnParseX125010835TxSetReportsObjIntoHTMLTableStr = function (reportsObj) {

  let htmlStrRpt = '';
   
  if (reportsObj.success === false) {
     htmlStrRpt = '<div class="alert alert-warning">';
     htmlStrRpt += reportsObj.message;
     htmlStrRpt += '</div>';     
     return htmlStrRpt;
  }
  
  /*----------------------------------------------------------------------------------------*/

  function generateReportPartProviderLevelAdjustments(adjustments) {
    let htmlStr = '';
        if (adjustments.length === 0) {
            htmlStr = 'None';
            return htmlStr;
    }
        htmlStr += '<table>';
        htmlStr += '<thead>';

        htmlStr += '<tr>';
        htmlStr += '<th class="font-weight-bold" scope="col">Provider<br>Identifier</th>';
        htmlStr += '<th class="font-weight-bold" scope="col">Fiscal<br>Period<br>End Date</th>';
        htmlStr += '<th class="font-weight-bold" scope="col">Reason Code</th>';
        htmlStr += '<th class="font-weight-bold" scope="col">Adjustment<br>Identifier</th>';
        htmlStr += '<th class="font-weight-bold" scope="col">Amount</th>';
        htmlStr += '</tr>';
        htmlStr += '</thead>';
        htmlStr += '<tbody>';

        adjustments.forEach((adjustment) => {
            htmlStr += '<tr>';
                      
            htmlStr += '<td>';
            htmlStr += adjustment.providerIdentifier;
            htmlStr += '</td>';

            htmlStr += '<td>';
            htmlStr += adjustment.fiscalPeriodEndDate.toDateString();
            htmlStr += '</td>';

            htmlStr += '<td>';
            htmlStr += adjustment.reasonCode;
            htmlStr += ' - ';
            htmlStr += adjustment.reasonCodeDescription;
            htmlStr += '</td>';

            htmlStr += '<td>';
            htmlStr += adjustment.adjustmentIdentifier;
            htmlStr += '</td>';

            htmlStr += '<td>';
            htmlStr += adjustment.amount;
            htmlStr += '</td>';

            htmlStr += '</tr>';
        });
        htmlStr += '</tbody>';
        htmlStr += '</table>';
        return htmlStr;
  };

  /*----------------------------------------------------------------------------------------*/

  function generateReportPartClaimOrServiceLevelAdjustments (adjustments) {
    let htmlStr = '';
    if (adjustments.length === 0) {
        htmlStr = 'None';
        return htmlStr;
    }
    htmlStr += '<table>';
    htmlStr += '<thead>';

    htmlStr += '<tr>';
    htmlStr += '<th class="font-weight-bold" scope="col">Group Code</th>';
    htmlStr += '<th class="font-weight-bold" scope="col">Reason Code</th>';
    htmlStr += '<th class="font-weight-bold" scope="col">Amount</th>';
    htmlStr += '<th class="font-weight-bold" scope="col">Quantity</th>';
    htmlStr += '</tr>';
    htmlStr += '</thead>';
    htmlStr += '<tbody>';

    adjustments.forEach((adjustment) => {
        htmlStr += '<tr>';

        htmlStr += '<td>';
        htmlStr += adjustment.groupCode;
        htmlStr += '</td>';

        htmlStr += '<td>';
        htmlStr += adjustment.reasonCode;
        htmlStr += ' - ';
        htmlStr += adjustment.reasonCodeDescription;        
        htmlStr += '</td>';

        htmlStr += '<td>';
        htmlStr += adjustment.amount;
        htmlStr += '</td>';

        htmlStr += '<td>';
        htmlStr += adjustment.quantity;
        htmlStr += '</td>';
        
        htmlStr += '</tr>';
    });
    htmlStr += '</tbody>';
    htmlStr += '</table>';
    return htmlStr;
    };

  /*----------------------------------------------------------------------------------------*/

  function generateReportPartHealthCareRemarkCodes (healthCareRemarkCodes) {
    let htmlStr = '';
    if (healthCareRemarkCodes.length === 0) {
            htmlStr = 'None';
            return htmlStr;
    }
        htmlStr += '<table>';
        htmlStr += '<thead>';

        htmlStr += '<tr>';
        htmlStr += '<th class="font-weight-bold" scope="col">Code<br>List</th>';
        htmlStr += '<th class="font-weight-bold" scope="col">Remark Code</th>';
        htmlStr += '</tr>';
        htmlStr += '</thead>';
        htmlStr += '<tbody>';

       healthCareRemarkCodes.forEach((healthCareRemarkCode) => {
            htmlStr += '<tr>';

            htmlStr += '<td>';
            htmlStr += healthCareRemarkCode.codeListQualifierCode;
            htmlStr += '</td>';

            htmlStr += '<td>';
            htmlStr += healthCareRemarkCode.industryCode;
            htmlStr += ' - ';
            htmlStr += healthCareRemarkCode.industryCodeDescription;
            htmlStr += '</td>';
        
            htmlStr += '</tr>';
        });
        htmlStr += '</tbody>';
        htmlStr += '</table>';

        return htmlStr;
    };

  /*----------------------------------------------------------------------------------------*/

  function generateReportPartPolicyReferences (policyReferences) {

    let htmlStr = '';
    if (policyReferences.length === 0) {
            htmlStr = 'None';
            return htmlStr;
    }

    htmlStr += '<ul>';
    
    policyReferences.forEach((policyReference) => {
        htmlStr += '<li>';
        htmlStr += policyReference;
        htmlStr += '</li>';
    });
    return htmlStr;
  };

  /*----------------------------------------------------------------------------------------*/

  function generateReportPartServiceLevel (services) {

    let htmlStr = '';

    htmlStr += '<table class="service-level">';
    htmlStr += '<thead>';

    htmlStr += '<tr>';
    htmlStr += '<th class="font-weight-bold" scope="col">Service<br>Line</th>';
    htmlStr += '<th class="font-weight-bold" scope="col">Procedure</th>';
    htmlStr += '<th class="font-weight-bold" scope="col">Amount<br>Submitted</th>';
    htmlStr += '<th class="font-weight-bold" scope="col">Amount<br>Paid</th>';
    htmlStr += '<th class="font-weight-bold" scope="col">Service Level Adjustments</th>';
    htmlStr += '<th class="font-weight-bold" scope="col">Health Care Remarks</th>';
    htmlStr += '<th class="font-weight-bold" scope="col">Policy References</th>';

    htmlStr += '</tr>';
    htmlStr += '</thead>';
    htmlStr += '<tbody>';

    services.forEach((service) => {
        
        htmlStr += '<tr>';

        htmlStr += '<td>';
        htmlStr += service.lineItemControlNumber;
        htmlStr += '</td>';

        htmlStr += '<td>';
        htmlStr += service.medicalProcedure.procModCombo;
        htmlStr += '</td>';

        htmlStr += '<td>';
        htmlStr += service.amountSubmitted;
        htmlStr += '</td>';

        htmlStr += '<td>';
        htmlStr += service.amountPaid;
        htmlStr += '</td>';

        htmlStr += '<td>';
        htmlStr += generateReportPartClaimOrServiceLevelAdjustments(service.serviceLevelAdjustments);
        htmlStr += '</td>';

        htmlStr += '<td>';
        htmlStr += generateReportPartHealthCareRemarkCodes(service.healthCareRemarkCodes);
        htmlStr += '</td>';

        htmlStr += '<td>';
        htmlStr += generateReportPartPolicyReferences(service.policyReferences);
        htmlStr += '</td>';


        htmlStr += '</tr>';
    });
    htmlStr += '</tbody>';
    htmlStr += '</table>';
    return htmlStr;
  };

  /*----------------------------------------------------------------------------------------*/

  function generateReportPartClaimLevel (detailObjs) {

    let htmlStr = '';

    htmlStr += '<table class="claim-level">';
    htmlStr += '<thead>';

    htmlStr += '<tr>';
    htmlStr += '<th scope="col"></th>';
    htmlStr += '<th class="font-weight-bold" scope="col">SpEdCare<br>Service Record<br>Tx Reference</th>';
    htmlStr += '<th class="font-weight-bold" scope="col">Patient</th>';
    htmlStr += '<th class="font-weight-bold" scope="col">Insurance ID</th>';
    htmlStr += '<th class="font-weight-bold" scope="col">Amount<br>Submitted</th>';
    htmlStr += '<th class="font-weight-bold" scope="col">Claim Control Number</th>';
    htmlStr += '<th class="font-weight-bold" scope="col">Claim Status Code</th>';
    htmlStr += '<th class="font-weight-bold" scope="col">Amount<br>Paid</th>';
    htmlStr += '<th class="font-weight-bold" scope="col">Claim<br>Denied</th>';
    htmlStr += '<th class="font-weight-bold" scope="col">Claim Level Adjustments</th>';
    htmlStr += '</tr>';
    htmlStr += '</thead>';
    htmlStr += '<tbody>';

    let claimCtr = 1;

    for (const [key, claim] of detailObjs) {

        htmlStr += '<tr id="' + key + '" ';
        if (claim.claimDenied === true) {
            htmlStr += 'class="rejected table-warning">';
        }
        else {
            htmlStr += 'class="accepted">';
        }

        htmlStr += '<td rowspan="2">';
        htmlStr += claimCtr;
        htmlStr += '</td>';

        htmlStr += '<td>';
        htmlStr += claim.patientControlNumber;
        htmlStr += '</td>';

        htmlStr += '<td>';
        htmlStr += claim.patient.lastOrOrgName;
        htmlStr += ', ';
        htmlStr += claim.patient.firstName;
        htmlStr += '</td>';

        htmlStr += '<td>';
        htmlStr += claim.patient.idCode;
        htmlStr += '</td>';
        
        htmlStr += '<td>';
        htmlStr += claim.amountSubmitted;
        htmlStr += '</td>';

        htmlStr += '<td>';
        htmlStr += claim.claimControlNumber;
        htmlStr += '</td>';

        htmlStr += '<td>';
        htmlStr += claim.claimStatusCode;
        htmlStr += ' - ';
        htmlStr += claim.claimStatusDescription;
        htmlStr += '</td>';

        htmlStr += '<td>';
        htmlStr += claim.amountPaid;
        htmlStr += '</td>';
               
        htmlStr += '<td>';
        htmlStr += (claim.claimDenied === true) ? "Yes": "No";
        htmlStr += '</td>';

        htmlStr += '<td>';
        htmlStr += generateReportPartClaimOrServiceLevelAdjustments(claim.claimLevelAdjustments);
        htmlStr += '</td>';

        htmlStr += '</tr>';

        htmlStr += '<tr ';

        if (claim.claimDenied === true) {
            htmlStr += 'class="rejected table-warning">';
        }
        else {
            htmlStr += 'class="accepted">';
        }

        htmlStr += '<td colspan="9">';
        htmlStr += '<details>';
        htmlStr += '<summary>';
        htmlStr += 'Service Lines (';
        htmlStr += claim.services.length;
        htmlStr += ')';
        htmlStr += '</summary>';
        htmlStr += generateReportPartServiceLevel(claim.services);
        htmlStr += '</details>';
        htmlStr += '</td>';
        htmlStr += '</tr>';
        
        claimCtr++;

    };
    htmlStr += '</tbody>';
    htmlStr += '</table>';
        
    return htmlStr;
  };

  /*----------------------------------------------------------------------------------------*/
  

  let txCounter = 1;
  
  const numOfTx = reportsObj.txSetReports.length;
  
  htmlStrRpt += '<table class="table table-sm provider-level">';
  htmlStrRpt += '<thead>';
  htmlStrRpt += '<tr>';
  htmlStrRpt += '<th class="font-weight-bold" scope="col">Transaction</th>';
  htmlStrRpt += '<th class="font-weight-bold" scope="col">Client Name</th>';
  htmlStrRpt += '<th class="font-weight-bold" scope="col">Provider ID</th>';
  htmlStrRpt += '<th class="font-weight-bold" scope="col">Claims<br>Adjudicated</th>';
  htmlStrRpt += '<th class="font-weight-bold" scope="col">Denial<br>Count</th>';
  htmlStrRpt += '<th class="font-weight-bold" scope="col">Check<br>Number</th>';
  htmlStrRpt += '<th class="font-weight-bold" scope="col">Check<br>Date</th>';
  htmlStrRpt += '<th class="font-weight-bold" scope="col">Check<br>Amount</th>';
  htmlStrRpt += '<th class="font-weight-bold" scope="col">Provider Level Adjustments</th>';
  htmlStrRpt += '</tr>';
  htmlStrRpt += '</thead>';
  htmlStrRpt += '<tbody>';

  reportsObj.txSetReports.forEach((reportObj) => {
	  
    htmlStrRpt += '<tr class="file-report-summary">';

    htmlStrRpt += '<td rowspan="2">';
    htmlStrRpt += txCounter;
    htmlStrRpt += ' of ';
	htmlStrRpt += numOfTx;
    htmlStrRpt += '</td>';

    htmlStrRpt += '<td>';
    htmlStrRpt += reportObj.summaryObj.payee.name;
    htmlStrRpt += '</td>';

    htmlStrRpt += '<td>';
    htmlStrRpt += reportObj.summaryObj.payee.idCode;
    htmlStrRpt += '</td>';

    htmlStrRpt += '<td>';
    htmlStrRpt += reportObj.summaryObj.qtyClaims;
    htmlStrRpt += '</td>';

    if (reportObj.summaryObj.qtyClaimsDenied > 0) {
       htmlStrRpt += '<td class="table-warning">';
    } 
	else {
       htmlStrRpt += '<td class="table-success">';
    }        
     
	htmlStrRpt += reportObj.summaryObj.qtyClaimsDenied;
    htmlStrRpt += '</td>';

    htmlStrRpt += '<td>';
    htmlStrRpt += reportObj.summaryObj.check.number;
    htmlStrRpt += '</td>';

     htmlStrRpt += '<td>';
     htmlStrRpt += reportObj.summaryObj.check.date.toDateString();
     htmlStrRpt += '</td>';

     htmlStrRpt += '<td>';
     htmlStrRpt += reportObj.summaryObj.check.amount;
	  
	 htmlStrRpt += '</td>';

     /* Provider level adjustments */

     htmlStrRpt += '<td>';
     htmlStrRpt += generateReportPartProviderLevelAdjustments(reportObj.summaryObj.providerLevelAdjustments);
     htmlStrRpt += '</td>';

     htmlStrRpt += '</tr>';

     /* Details row */

     htmlStrRpt += '<tr>';

     /* Details col */

     htmlStrRpt += '<td colspan="8">';
        
     htmlStrRpt += '<details>';
     htmlStrRpt += '<summary>';
     htmlStrRpt += 'Claim Lines (';
     htmlStrRpt += reportObj.detailObjs.size;
     htmlStrRpt += ')';
     htmlStrRpt += '</summary>';

     htmlStrRpt += generateReportPartClaimLevel(reportObj.detailObjs);

     htmlStrRpt += '</details>';
     htmlStrRpt += '</td>'
     htmlStrRpt += '</tr>'
     txCounter++;
  });
  htmlStrRpt += '</tbody>';
  htmlStrRpt += '</table>';
  return htmlStrRpt;

};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

const _fnParseX125010835TxSetReportsObjIntoPostingObjs = function (reportsObj) {

	let postingObjs = [];

	reportsObj.txSetReports.forEach((reportObj) => {
		let postingObj = {};

		postingObj.check = reportObj.summaryObj.check;
		postingObj.payer = reportObj.summaryObj.payer;
		postingObj.payee = reportObj.summaryObj.payee;
		postingObj.providerLevelAdjustments = reportObj.summaryObj.providerLevelAdjustments;
		postingObj.claims = [];

	    for (const [key, claim] of reportObj.detailObjs) {
		  postingObj.claims.push(claim);
	    };
		postingObjs.push(postingObj);
    });
	return postingObjs;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

return {
	  fnParseX125010FileContentIntoX125010DataObj: _fnParseX125010FileContentIntoX125010DataObj	
	, fnParseX125010277DataObjIntoTxSetReportsObj: _fnParseX125010277DataObjIntoTxSetReportsObj
    , fnParseX125010835DataObjIntoTxSetReportsObj: _fnParseX125010835DataObjIntoTxSetReportsObj   
	, fnParseX125010835TxSetReportsObjIntoHTMLTableStr: _fnParseX125010835TxSetReportsObjIntoHTMLTableStr
	, fnParseX125010835TxSetReportsObjIntoPostingObjs: _fnParseX125010835TxSetReportsObjIntoPostingObjs
	, fnParseX12FileContentIntoX12SimpleDataObj: _fnParseX12FileContentIntoX12SimpleDataObj
	, fnParseX12SimpleDataObjIntoHTMLTableStr: _fnParseX12SimpleDataObjIntoHTMLTableStr
};

})();