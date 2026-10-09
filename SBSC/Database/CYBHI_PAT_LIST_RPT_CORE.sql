USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CYBHI_PAT_LIST_RPT_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CYBHI_PAT_LIST_RPT_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[CYBHI_PAT_LIST_RPT_CORE] ( 
    @clientID           bigint
  , @generateRosterMode bit = 0
)

/***************************************************************************    
 * CYBHI_PAT_LIST_RPT_CORE */    
/**    
 * Returns complete list of patients and if they can be included in
 * the TPA export and (if not) reasons why.
 *
 * Note: Keep this in synch with the spec from the TPA (third party admin).
 * Currently the TPA is Carelon.
 * 
 ***************************************************************************/            

returns @patients table (   
     [Record Number]	 							int 			identity(1,1)	
	,[CanExportRow]  					            bit             default(1)  
	,[ProblemsDetected]       						varchar(max)    default('') 
	,[Carelon PARENT Code]	                        varchar(4)		default('CASB')
	,[Submitter ID]	                                varchar(10)		default('')
	,[Registering Provider ID]	                    varchar(15)		default('')
	,[Enrollment Indicator]	                        varchar(1)		default('I')
	,[Enrollment Start Date]	                    varchar(8)		default('')
	,[Enrollment End Date]                          varchar(8)      default('')
	,[Carelon Assigned Member ID]                   varchar(256)    default('')
	,[Student ID]	                                varchar(15)		default('')
	,[Last Name]	                                varchar(60)		default('')	
	,[First Name]	                                varchar(50)		default('')
	,[Birth Date]	                                varchar(8)		default('')
	,[Unknown Address]	                            varchar(1)		default('')
	,[Member is Homeless]	                        varchar(1)		default('')
	,[Street Address Line 1]	                    varchar(55)		default('')
	,[City]	                                        varchar(30)		default('')
	,[State]	                                    varchar(2)		default('')
	,[Zip Code]	                                    varchar(5)		default('')
	,[Gender At Birth]	                            varchar(1)		default('')
	,[Insurance Carrier Code 1]	                    varchar(3)		default('')
	,[Insurance Policy Member ID 1]	                varchar(30)		default('')
	,[Insurance Subscriber First Name 1]	        varchar(35)		default('')
	,[Insurance Subscriber Last Name 1]	            varchar(60)		default('')
	,[Insurance Primacy Indicator 1]	            varchar(1)		default('P')
	,[Insurance Group Number 1]	                    varchar(30)		default('UNKNOWN')
	,[Insurance Carrier Code 2]	                    varchar(3)		default('')
	,[Insurance Policy Member ID 2]	                varchar(30)		default('')
	,[Insurance Subscriber First Name 2]	        varchar(35)		default('')
	,[Insurance Subscriber Last Name 2]	            varchar(60)		default('')
	,[Insurance Primacy Indicator 2]	            varchar(1)		default('')
	,[Insurance Group Number 2]	                    varchar(30)		default('')
	,[No Phone]                                     varchar(1)      default('')
	,[Home Phone Area Code]                         varchar(3)      default('')
	,[Home Phone Exchange Number]                   varchar(3)      default('')
	,[Home Phone Suffix]                            varchar(4)      default('')
	,[FERPA Consent]                                bit             default(null)
	,[Enrollment State]                             tinyint         default(1)
	,registerPatWithTPA                             bit             
	,earliestDOS                                    datetime
	,carrierFound                                   bit default(0)
	,carrierRegWithTpa                              bit default(1)
	,carrierRegWithTpaHasEndDate                    bit default(0)
	,carrierRegWithTpaEndDate                       datetime
    
  unique clustered ([Record Number])
)
as
begin

declare @today                           as datetime = convert(date,getdate())
declare @todayDate                       as date     = convert(date,@today)
declare @clientFound                     as bit    = 0
declare @clientClaimStartDateVal         as date   = convert(date,'7/1/2024')
declare @submitterID                     as	varchar(10)	= ''
declare @registeringProviderID	         as varchar(15)	= ''
declare @todayYearAgo                    as date        = dateadd(day,-349,@todayDate)
declare @earliestEnrollmentStartDateTime as datetime    = @todayYearAgo

declare @consortium                      as bit         = 0
declare @consortiumLeadClientID          as bigint      = null
declare @consortiumLead                  as bit         = 0

declare @clientsParticipating as table (    
    clientID          bigint                   not null default -1
  , billingClient     bit                      not null default(0)
)

/*###########################################################################*/
/*#                    Exit if client not passed                            #*/
/*###########################################################################*/

if (@clientID is null) return

/*###########################################################################*/
/*#                        Get client data                                  #*/
/*###########################################################################*/

select top 1
    @clientFound             = 1
  , @clientClaimStartDateVal = clc.cybhiTpaApprovedOn
  , @submitterID             = dbo.STRING_REMOVE_NON_ALPHA_NUMERIC(('CYBHI' + clc.cybhiClientCode), 0,1,1,0,10) /* Per feedback from Carelon we need to append a CYBHI to the CYBHI TPA short name*/
  , @registeringProviderID   = dbo.STRING_REMOVE_NON_ALPHA_NUMERIC(clc.cybhiTpaID, 0,1,1,0,15)  /* Per feedback from Carelon we need to use the ID we get back from Carelon for the client */
  , @consortium              = isnull(clc.cybhiConsortiumBilling,0)
  , @consortiumLeadClientID  = isnull(clc.cybhiConsortiumLeadClientID,0)  
from dbo.CLIENTS_Client as clc 
where (
      (clc.CLIENT_ID = @clientID)
  and (clc.cybhi     = 1)
)

/*###########################################################################*/
/*#                    If client not found exit                             #*/
/*###########################################################################*/

if (@clientFound = 0) return

/*###########################################################################*/
/*#                      Get Participating Clients                          #*/
/*###########################################################################*/

/*------------------------------------*/
/* Client is part of consortium       */
/*------------------------------------*/

if (@consortium = 1)
begin

  /*------------------------------------*/
  /* Client is the lead client          */
  /*------------------------------------*/

  if (@consortiumLeadClientID = 0) 
  begin  
    
	/*------------------------------------*/
    /* If we are generating the roster    */
	/* include all consortium members     */
    /*------------------------------------*/
	
	if (@generateRosterMode = 1)
	begin
	  insert into @clientsParticipating (clientID, billingClient)
	  select 
	      clientID      = t1.id 
	    , billingClient = t1.leadClient
	  from dbo.CYBHI_CONSORTIUM_MEMBERS_VIEW_CORE(null,null,null,@clientID) as t1
    end

	/*------------------------------------*/
    /* If we are not generating the roster*/
	/* include just the lead              */
    /*------------------------------------*/

	else
	begin
	  insert into @clientsParticipating (clientID, billingClient) values (@clientID,1)
	end

  end

  /*------------------------------------*/
  /* Client is not the lead             */
  /*------------------------------------*/

  else
  begin

    /*------------------------------------*/
    /* If we are generating the roster    */
	/* exit.  Client is submitted under   */
	/* the lead.                          */
    /*------------------------------------*/

    if (@generateRosterMode = 1)
	begin
	  return
	end
	else

	/*------------------------------------*/
    /* If we are not generating the roster*/
	/* include just this client.          */
    /*------------------------------------*/

	begin
  	  insert into @clientsParticipating (clientID, billingClient) values (@clientID,1)	  
    end
  end
end

/*------------------------------------*/
/* Client is not part of consortium   */
/* include just this client */
/*------------------------------------*/

else
begin  
  insert into @clientsParticipating (clientID, billingClient) values (@clientID,1)
end

/* Earliest possible enrollment start date for everyone is either tpa start date 
 * or 349 days from the current date.. whichever is latest date */
   
if (@clientClaimStartDateVal >= @todayYearAgo)
begin
  set @earliestEnrollmentStartDateTime = @clientClaimStartDateVal
end
else 
begin
  set @earliestEnrollmentStartDateTime = @todayYearAgo
end

/*###########################################################################*/
/*#                       Get Patient Data                                  #*/
/*###########################################################################*/

INSERT INTO @patients (
		  [Submitter ID]
		, [Registering Provider ID]	
		, [Enrollment Start Date]
		, [Enrollment End Date]
		, [Carelon Assigned Member ID]
	    , [Student ID]
		, [Last Name]
		, [First Name]
		, [Birth Date]
		, [Member is Homeless]
		, [Street Address Line 1]
		, [City]
		, [State]
		, [Zip Code]
		, [Gender At Birth]
		, [Insurance Carrier Code 1]
		, [Insurance Policy Member ID 1]
		, [Insurance Subscriber First Name 1]
		, [Insurance Subscriber Last Name 1]
		, [Insurance Group Number 1]
	    , [No Phone]
		, [Home Phone Area Code]
	    , [Home Phone Exchange Number] 
	    , [Home Phone Suffix] 
		, [FERPA Consent]	 
		, [Enrollment State] 
		, registerPatWithTPA
		, earliestDOS
		, carrierFound
		, carrierRegWithTpa
		, carrierRegWithTpaHasEndDate
	    , carrierRegWithTpaEndDate

    )
	select 
	  q1.* 
	from @clientsParticipating as cp
	cross apply (    
	
	  select distinct
		
		[Submitter ID] = @submitterID, 
		[Registering Provider ID]	= @registeringProviderID,		
		
		/* Earliest start date or students dob if dob is on or after earliest start date */

		[Enrollment Start Date] = REPLACE(dbo.RPT_DATE_FMT_WITH_LEADING_ZEROS(iif((pap.DATE_OF_BIRTH >= @earliestEnrollmentStartDateTime),pap.DATE_OF_BIRTH,@earliestEnrollmentStartDateTime)), '/', ''),
		
		/* Day before students 26th birthday */
		
		[Enrollment End Date] = REPLACE(dbo.RPT_DATE_FMT_WITH_LEADING_ZEROS(dateadd(day,-1,(dateadd(year,26,pap.DATE_OF_BIRTH)))),'/',''),  

        /* TPA ID if applicable */

        [Carelon Assigned Member ID] = iif((pap.cybhiTpaEnrollmentState in (5,6,7))
		     , isnull(pap.cybhiTpaID,'')
		     , '' ),
		
		[Student ID] = convert(varchar(15),(trim(isnull(pap.CSIS,N'')))),
        		
		[Last Name] = dbo.STRING_REMOVE_NON_ALPHA_NUMERIC(pap.LAST_NAME,1,1,1,1,50),
        [First Name] = dbo.STRING_REMOVE_NON_ALPHA_NUMERIC(pap.FIRST_NAME,1,1,1,1,50),
        [Birth Date] = REPLACE(dbo.RPT_DATE_FMT_WITH_LEADING_ZEROS(pap.DATE_OF_BIRTH), '/', ''),        
		--[Member is Homeless] = iif(pp2.ADDRESS_1 IS NULL, 'Y', ''),
        [Member is Homeless] = iif((pap.inTransitionalHousingStatus = 1),'Y',''),
		[Street Address Line 1] = dbo.STRING_REMOVE_NON_ALPHA_NUMERIC(pp2.ADDRESS_1,1,1,1,0,55),
		[City] = dbo.STRING_REMOVE_NON_ALPHA_NUMERIC(pp2.CITY,1,1,1,0,30),
        [State] = dbo.STRING_REMOVE_NON_ALPHA_NUMERIC(pp2.STATE,0,0,1,0,2),
        [Zip Code] = dbo.STRING_REMOVE_NON_ALPHA_NUMERIC(pp2.ZIP_5, 0,1,0,0,5),
		[Gender At Birth] = IIF(pap.SEX IN ('F', 'M'), pap.SEX, 'U'),
        [Insurance Carrier Code 1] = dbo.STRING_REMOVE_NON_ALPHA_NUMERIC(pic_1_2.carrierCode, 0,1,1,0,3),
        [Insurance Policy Member ID 1] = dbo.STRING_REMOVE_NON_ALPHA_NUMERIC(pic_1_2.beneficiaryID,0,1,1,0,30), 
		[Insurance Subscriber First Name 1] = dbo.STRING_REMOVE_NON_ALPHA_NUMERIC(LEFT(pic_1_2.policyHolderName, CHARINDEX(' ', pic_1_2.policyHolderName + ' ') - 1),1,1,1,0,35),
		[Insurance Subscriber Last Name 1] = dbo.STRING_REMOVE_NON_ALPHA_NUMERIC(REVERSE(LEFT(REVERSE(pic_1_2.policyHolderName), CHARINDEX(' ', REVERSE(pic_1_2.policyHolderName) + ' ') - 1)),1,1,1,0,60),
		[Insurance Group Number 1] = dbo.STRING_REMOVE_NON_ALPHA_NUMERIC(pic_1_2.policyGroupID,1,1,1,0,30),  
		[No Phone] = iif((pp_home_phone_2.id is null),'Y',''),
		[Home Phone Area Code] = pp_home_phone_2.area_code,
		[Home Phone Exchange Number] = pp_home_phone_2.exchange_number,
		[Home Phone Suffix]  = pp_home_phone_2.suffix,
		[FERPA Consent] = pap.ferpaConsent,
		[Enrollment State]  = pap.cybhiTpaEnrollmentState,
		registerPatWithTPA = null, /* We will determine later */
		sr.earliestDOS,
		carrierFound = isnull(pic_1_2.carrierFound,0),
		carrierRegWithTpa = isnull(pic_1_2.carrierRegWithTpa,1),
		carrierRegWithTpaHasEndDate = isnull(pic_1_2.carrierRegWithTpaHasEndDate,0),
	    carrierRegWithTpaEndDate = pic_1_2.carrierRegWithTpaEndDate
   
    from dbo.CYBHI_PATS_VIEW_DATA_CORE (cp.clientID) as sr
    join dbo.PATIENTS_Patient                        as pap on pap.PATIENT_ID = sr.patID

    /* Get patient home address */
    /* Keep in synch with homeplace id get logic in C:\SBSC\Spedmon\Database\TRANSPORTATION_MGMT_AUTHORIZED_PATIENTS_SAVE_CORE.sql */

    outer apply (
      select top 1 
          pp1.ID
	    , pp1.ADDRESS_1
	    , pp1.ADDRESS_2
	    , pp1.CITY
	    , pp1.STATE
	    , pp1.ZIP_5
	    , pp1.ZIP_4	
      from dbo.PATIENT_PLACES as pp1
      where (
            (pp1.PATIENT_ID         = sr.patID)
        and (pp1.PATIENT_PLACE_TYPE = 1)
        and (pp1.ACTIVE             = 1)
      )
      order by 
        pp1.id         desc
	  , pp1.START_DATE desc
    ) as pp2

    /* Get primary insurance supported by cybhi */

    outer apply (
      select top 1
        pic_1_1.beneficiaryID
      , ic.carrierCode 
	  , pic_1_1.policyHolderName
	  , policyGroupID = iif( (trim(isnull(pic_1_1.policyGroupID,'')) != '')
	                        , pic_1_1.policyGroupID
	  				        ,'UNKNOWN')
    
	  , carrierFound                = 1
	  , carrierRegWithTpa           = ic.cybhiRegisterPatInsuranceInfoWithTPA
	  , carrierRegWithTpaHasEndDate = ic.cybhiRegisterPatInsuranceInfoWithTPAHasEndDate
	  , carrierRegWithTpaEndDate    = ic.cybhiRegisterPatInsuranceInfoWithTPAEndDate

    from dbo.PATIENT_INSURANCE_CARRIERS as pic_1_1
    join dbo.INSURANCE_CARRIERS         as ic on ic.id = pic_1_1.insuranceCarrierID
    where (
          ((pic_1_1.clientID = sr.clientID) and (pic_1_1.patID = sr.patID) and (pic_1_1.id > 0)) /* Index: CLIENT_PAT_IDX*/
	  and (pic_1_1.active           = 1)
      and (pic_1_1.expiredOrInvalid = 0)
	  and (ic.planSupportedByCYBHI  = 1)	
    )
  ) as pic_1_2

  /* Get home phone */

  outer apply (
    select top 1   
        area_code        = left      (pp_home_phone_1.phone,3)
      , exchange_number  = substring (pp_home_phone_1.phone,4,3)
      , suffix           = right     (pp_home_phone_1.phone,4)
	  , id               = pp_home_phone_1.ID
    from  
    (
      select 
          ppp.ID	
	    , phone = replace(replace(replace(replace(trim(isnull(pep.PHONE,'')),'(',''),')',''),'-',''),' ','')  	  
      from dbo.PATIENTS_PERSON  as ppp
      join dbo.PERSONS_PERSON   as pep  on  pep.ID = ppp.PERSON_ID
      where     
            (ppp.CLIENT_ID  = sr.clientID)
	    and (ppp.PATIENT_ID = sr.patID)
        and (ppp.ACTIVE     = 1)
	    and (pep.CLASS_ID_1 = 1)
	    and (pep.ACTIVE     = 1)	  
    ) as pp_home_phone_1
    where 
      (len(pp_home_phone_1.phone) = 10)
    order by 
      pp_home_phone_1.ID desc
  ) as pp_home_phone_2

  where (
        (pap.ACTIVE           = 'Y')
    and (pap.cybhiTpaEnrollmentState not in (2,3,8,9))
  )
) as q1

/*
   Note: Possible cybhiTpaEnrollmentStates are 

1. None
2. Submitted
3. Accepted
4. Rejected
5. Accepted But Update Required
6. Accepted But Removal Required
7. Accepted But Reinrollment Needed
8. Accepted But Pended - Waiting for Update
9. Accepted But Info Sent To TPA By Mistake
*/


/*###########################################################################*/
/*#                        Set Enrollment Indicator                         #*/
/*#                                                                         #*/
/*#   I = Initial (default)                                                 #*/
/*#   R = Reregister                                                        #*/
/*#   D = Demographic change                                                #*/
/*###########################################################################*/

/* Renrollment needed */

update @patients
set 
  [Enrollment Indicator] = 'R' 
where 
  ([Enrollment State] = 7)

/* Demographic change */

update @patients
set
[Enrollment Indicator] = 'D'
where 
  ([Enrollment State] =  5)

/*###########################################################################*/
/*#                  Determine if we need to register                       #*/
/*###########################################################################*/

/* No longer need to register and no cutover date */

update t1
  set registerPatWithTPA = 0
from @patients as t1
where ( 
      (t1.registerPatWithTPA is null)
  and (t1.carrierFound                = 1)
  and (t1.carrierRegWithTpa           = 0)
  and (t1.carrierRegWithTpaHasEndDate = 0)
)

/* Still has to register.  Carrier has cutover date and patient has services on or before. 
 * Replace enrollment end date with cutover date.
 */

update t1
  set 
    registerPatWithTPA = 1
  , [Enrollment End Date] = REPLACE(dbo.RPT_DATE_FMT_WITH_LEADING_ZEROS(t1.carrierRegWithTpaEndDate),'/','')
from @patients as t1
where (
      (t1.registerPatWithTPA is null)
  and (t1.carrierFound                = 1)
  and (t1.carrierRegWithTpa           = 0)
  and (t1.carrierRegWithTpaHasEndDate = 1)
  and (t1.earliestDOS <= t1.carrierRegWithTpaEndDate)
)

/* Has cutover date and patient has services after (basically whats left over from prior case) */

update t1
  set registerPatWithTPA = 0
from @patients as t1
where (
      (t1.registerPatWithTPA is null)
  and (t1.carrierFound                = 1)
  and (t1.carrierRegWithTpa           = 0)
  and (t1.carrierRegWithTpaHasEndDate = 1)
)

/* Whats left (assume we are registering) */

update t1
  set registerPatWithTPA = 1
from @patients as t1
where (
    (t1.registerPatWithTPA is null)
)

/*###########################################################################*/
/*#                        Scan For Errors                                  #*/
/*###########################################################################*/

update @patients
set 
	[CanExportRow]     = 0
  , [ProblemsDetected] = [ProblemsDetected] 
					 + ' FERPA Consent is unknown'
where (
	([FERPA Consent] is null)	
)

update @patients
set 
	[CanExportRow]     = 0
  , [ProblemsDetected] = [ProblemsDetected] 
					 + ' FERPA Consent was NOT given'
where (
	([FERPA Consent] = 0)
)

update @patients
set 
    [CanExportRow]     = 0
  , [ProblemsDetected] = [ProblemsDetected] 
					 + ' ERROR CODE 008: SUBMITTER ID MUST BE POPULATED – FILE LEVEL ERROR'
where (       
  ([Submitter ID] = '')
) 

update @patients
set 
    [CanExportRow]     = 0
  , [ProblemsDetected] = [ProblemsDetected] 
					 + ' ERROR CODE 013: ENROLLING PROVIDER ID IS MISSING OR NOT FOUND - FILE LEVEL ERROR'
where (       
  ([Registering Provider ID] = '')
) 


update @patients
set 
	[CanExportRow]     = 0
  , [ProblemsDetected] = [ProblemsDetected] 
					 + ' ERROR CODE 049: MEMBER ADDRESS LINE 1 MISSING'
where (
	([Street Address Line 1] = '')
)

update @patients
set 
	[CanExportRow]     = 0
  , [ProblemsDetected] = [ProblemsDetected] 
					 + ' ERROR CODE 050: MEMBER CITY IS MISSING'
where (
	([City] = '')
)

update @patients
set 
	[CanExportRow]     = 0
  , [ProblemsDetected] = [ProblemsDetected] 
					 + ' ERROR CODE 051: MEMBER STATE IS MISSING'
where (
	([State] = '')
)

update @patients
set 
	[CanExportRow]     = 0
  , [ProblemsDetected] = [ProblemsDetected] 
					 + ' ERROR CODE 053: MEMBER ZIP CODE IS MISSING'
where (
	([Zip Code] = '')
)


/*------------------------------------*/
/* Required (R) fields patients  */
/*------------------------------------*/

/*
[Carelon PARENT Code]
[Submitter ID]	
[Registering Provider ID]
[Enrollment Indicator]	
[Student ID]
[First Name]
[Last Name]
[Birth Date]
[Gender At Birth]
[Insurance Carrier Code 1]
[Insurance Policy Member ID 1]
[Insurance Subscriber Last Name 1]
[Insurance Primacy Indicator 1]
[Insurance Group Number 1]	

*/

update @patients
set 
    [CanExportRow]     = 0
  , [ProblemsDetected] = [ProblemsDetected] 
					 + ' ERROR CODE 007: PARENT CODE MUST BE POPULATED – FILE LEVEL ERROR'
where (       
  ([Carelon PARENT Code] = '')
) 

update @patients
set 
    [CanExportRow]     = 0
  , [ProblemsDetected] = [ProblemsDetected] 
					 + ' ERROR CODE 014: ENROLLMENT INDICATOR IS MISSING/INVALID'
where (       
	([Enrollment Indicator] = '') OR
    ([Enrollment Indicator] NOT IN ('I', 'R', 'D'))
) 

update @patients
set 
    [CanExportRow]     = 0
  , [ProblemsDetected] = [ProblemsDetected] 
					 + ' STUDENT SSID IS MISSING'
where (       
  ([Student ID] = '')
) 

update @patients
set 
    [CanExportRow]     = 0
  , [ProblemsDetected] = [ProblemsDetected] 
					 + ' ERROR CODE 029: FIRST NAME IS MISSING'
where (       
  ([First Name] = '')
) 

update @patients
set 
    [CanExportRow]     = 0
  , [ProblemsDetected] = [ProblemsDetected] 
					 + ' ERROR CODE 028: LAST NAME IS MISSING'
where (       
  ([Last Name] = '')
) 

update @patients
set 
    [CanExportRow] = 0,
    [ProblemsDetected] = CASE 
							WHEN [Birth Date] = '' THEN 
								[ProblemsDetected] + ' ERROR CODE 030: DATE OF BIRTH IS MISSING OR INVALID'
							WHEN (CONVERT(DATE, STUFF(STUFF([Birth Date], 3, 0, '-'), 6, 0, '-'), 101) > CONVERT(DATE, STUFF(STUFF([Enrollment Start Date], 3, 0, '-'), 6, 0, '-'), 101)) THEN 
								[ProblemsDetected] + ' ERROR CODE 031: DATE OF BIRTH CANNOT BE GREATER THAN ENROLLMENT START DATE'
							ELSE [ProblemsDetected]
							END
where (
    ([Birth Date] = '') OR 
	([Birth Date] IS NULL) OR 
    (CONVERT(DATE, STUFF(STUFF([Birth Date], 3, 0, '-'), 6, 0, '-'), 101) > CONVERT(DATE, STUFF(STUFF([Enrollment Start Date], 3, 0, '-'), 6, 0, '-'), 101))
)

update @patients
set 
    [CanExportRow]     = 0
  , [ProblemsDetected] = CASE 
							WHEN [Gender At Birth] = '' THEN 
								[ProblemsDetected] + ' ERROR CODE 038: MEMBER GENDER IS MISSING'
							WHEN [Gender At Birth] NOT IN ('M', 'F', 'U') THEN 
								[ProblemsDetected] + ' ERROR CODE 140: MEMBER GENDER IS INVALID'
							ELSE [ProblemsDetected]
							END
where (       
  ([Gender At Birth] = '') OR ([Gender At Birth] NOT IN ('M', 'F', 'U'))
) 

update @patients
set 
    [CanExportRow]     = 0
  , [ProblemsDetected] = CASE
							WHEN ([Enrollment Indicator] IN ('I', 'R') AND [Insurance Carrier Code 1] = '') THEN 
								[ProblemsDetected] + ' ERROR CODE 170: INSURANCE CARRIER CODE 1 NOT POPULATED'
							WHEN ([Enrollment Indicator] = 'D' AND [Insurance Carrier Code 1] <> '') THEN 
								[ProblemsDetected] + ' ERROR CODE 408: INSURANCE CARRIER CODE MUST NOT BE POPULATED ON DEMOGRAPHIC CHANGE'
							ELSE [ProblemsDetected]
							END
where (       
  ([Insurance Carrier Code 1] = '') AND ([Enrollment Indicator] IN ('I', 'R', 'D'))
)

update @patients
set 
    [CanExportRow] = 0,
    [ProblemsDetected] = CASE
							WHEN ([Enrollment Indicator] IN ('I', 'R') AND [Insurance Policy Member ID 1] = '') THEN 
								[ProblemsDetected] + ' ERROR CODE 171: INSURANCE POLICY MEMBER NUMBER 1 NOT POPULATED'
							WHEN ([Enrollment Indicator] = 'D' AND [Insurance Policy Member ID 1] <> '') THEN 
								[ProblemsDetected] + ' ERROR CODE 409: INSURANCE POLICY MEMBER NUMBER MUST NOT BE POPULATED ON DEMOGRAPHIC CHANGE'
							ELSE [ProblemsDetected]
							END
where (
    ([Insurance Policy Member ID 1] = '') AND ([Enrollment Indicator] IN ('I', 'R', 'D'))
)

update @patients
set 
    [CanExportRow]     = 0
  , [ProblemsDetected] = CASE
							WHEN ([Enrollment Indicator] IN ('I', 'R') AND [Insurance Subscriber First Name 1] = '') THEN 
								[ProblemsDetected] + ' ERROR CODE 172: INSURANCE SUBSCRIBER FIRST NAME 1 NOT POPULATED'
							WHEN ([Enrollment Indicator] = 'D' AND [Insurance Subscriber First Name 1] <> '') THEN 
								[ProblemsDetected] + ' ERROR CODE 410: INSURANCE SUBSCRIBER FIRST NAME MUST NOT BE POPULATED ON DEMOGRAPHIC CHANGE'
							ELSE [ProblemsDetected]
							END
where (       
  ([Insurance Subscriber First Name 1] = '') AND ([Enrollment Indicator] IN ('I', 'R', 'D'))
)

update @patients
set 
    [CanExportRow]     = 0
  , [ProblemsDetected] = CASE
							WHEN ([Enrollment Indicator] IN ('I', 'R') AND [Insurance Subscriber Last Name 1] = '') THEN 
								[ProblemsDetected] + ' ERROR CODE 173: INSURANCE SUBSCRIBER LAST NAME 1 NOT POPULATED'
							WHEN ([Enrollment Indicator] = 'D' AND [Insurance Subscriber Last Name 1] <> '') THEN 
								[ProblemsDetected] + ' ERROR CODE 411: INSURANCE SUBSCRIBER LAST NAME MUST NOT BE POPULATED ON DEMOGRAPHIC CHANGE'
							ELSE [ProblemsDetected]
							END
where (       
  ([Insurance Subscriber Last Name 1] = '') AND ([Enrollment Indicator] IN ('I', 'R', 'D'))
)

update @patients
set 
    [CanExportRow]     = 0
  , [ProblemsDetected] = CASE
							WHEN ([Enrollment Indicator] IN ('I', 'R') AND [Insurance Primacy Indicator 1] = '') THEN 
								[ProblemsDetected] + ' ERROR CODE 174: INSURANCE PRIMACY INDICATOR 1 NOT POPULATED'
							WHEN ([Enrollment Indicator] = 'D' AND [Insurance Primacy Indicator 1] <> '') THEN 
								[ProblemsDetected] + ' ERROR CODE 412: INSURANCE PRIMACY INDICATOR MUST NOT BE POPULATED ON DEMOGRAPHIC CHANGE'
							WHEN ([Insurance Primacy Indicator 1] <> 'P') THEN 
								[ProblemsDetected] + ' ERROR CODE 330: INSURANCE PRIMACY INDICATOR 1 MUST BE PRIMARY'
							ELSE [ProblemsDetected]
							END
where (       
  ([Insurance Primacy Indicator 1] = '') AND ([Enrollment Indicator] IN ('I', 'R', 'D') AND [Insurance Primacy Indicator 1] <> 'P')
)

/*
update @patients
set 
    [CanExportRow]     = 0
  , [ProblemsDetected] = CASE
							WHEN ([Enrollment Indicator] IN ('I', 'R') AND [Insurance Group Number 1] = '') THEN 
								[ProblemsDetected] + ' ERROR CODE 175: INSURANCE GROUP NUMBER 1 NOT POPULATED'
							WHEN ([Enrollment Indicator] = 'D' AND [Insurance Group Number 1] <> '') THEN 
								[ProblemsDetected] + ' ERROR CODE 413: INSURANCE GROUP NUMBER MUST NOT BE POPULATED ON DEMOGRAPHIC CHANGE'
							ELSE [ProblemsDetected]
							END
where (       
  ([Insurance Group Number 1] = '') AND ([Enrollment Indicator] IN ('I', 'R', 'D'))
)
*/

	
return

end
     
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CYBHI_PAT_LIST_RPT_CORE] TO [webuser]
GO