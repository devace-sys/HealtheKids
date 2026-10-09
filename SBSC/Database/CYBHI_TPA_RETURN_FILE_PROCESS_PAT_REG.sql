USE SPEDMON
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CYBHI_TPA_RETURN_FILE_PROCESS_PAT_REG') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.CYBHI_TPA_RETURN_FILE_PROCESS_PAT_REG
GO

/*-------------------------------
 * Create 
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[CYBHI_TPA_RETURN_FILE_PROCESS_PAT_REG] (
    @userID                   bigint
  , @userGroup                int  
  , @userRank                 int      
  , @clientID                 bigint 
  , @fileClass                tinyint
  , @fileContents             varchar(max)
  , @fromExternalSource       bit = 0  /* If = 1 we attempt to add insurance data for patient */ 
  , @editDelReason            varchar(7000)
  , @validateRec              bit
  , @saveType                 int
  , @recID                    bigint
  , @MsgNoRec                 VARCHAR(1000)
  , @MsgNoEdit                VARCHAR(1000)
  , @MsgDupRec                VARCHAR(1000)
  , @MsgDataError             VARCHAR(1000)
  , @MsgNotActive             VARCHAR(1000)
  , @recordID                 bigint        output
  , @spDetails                varchar(8000) output
  , @jsonData                 varchar(max)  output )    
AS    
BEGIN     
    
/***************************************************************************    
 * CYBHI_TPA_RETURN_FILE_PROCESS_PAT_REG */    
/**    
 * @param  fileClass  
 *  
 * 1 = Return Accept : CARELON-RA 
 * 2 = Return Error  : CARELON-RE
 *
 * @param  fileContents  Fixed width records. LF delimited 
 *   
 * Note:
 *
 * CARELON-RR for Summary File
 * CARELON-RA for Accepted File
 * CARELON-RP for Pended File
 * CARELON-RE for Error (Rejected) File
 * CARELON-RI for Pended Resolution File
 *
 * TODO: Eventually update this routine to use 
 * CYBHI_TPA_CARELON_GET_PAT_REG_FILE_LAYOUT.sql to get the layout data
 * and use this to parse.
 ***************************************************************************/         
     
SET NOCOUNT ON    

/*============================================================
 * Init output parameters and worker variables
 *===========================================================*/  
    
set @recordID  = 0    
set @spDetails = ''    
set @jsonData  = '[]'

/*============================================================
 * Variables
 *============================================================*/

declare @tranOpen                as bit       = 0 
declare @clientFound             as bit       = 0
declare @consortium              as bit       = 0
declare @consortiumLeadClientID  as bigint    = null
declare @consortiumLead          as bit       = 0

declare @clientTpaID          as varchar(256) = ''
declare @regProviderTpaID     as varchar(256) = ''
declare @uploadStatus         as varchar(1)   = ''
declare @today                as datetime     = getdate()
declare @todayDateOnly        as date         = @today
declare @addSupportingData    as bit          = 0

declare @fileContentsJSONOut  as varchar(max)  = ''
declare @curIdx               as int           = 0
declare @maxIdx               as int           = 0

declare @participatingClientID as bigint        = -1
declare @patID				   as bigint        = -1
declare @ssid                  as nvarchar(50)  = N''
declare @street1               as varchar(1000) = ''
declare @street2               as varchar(1000) = ''
declare @city                  as varchar(100)  = ''
declare @state                 as varchar(2)    = ''
declare @zip5                  as varchar(5)    = ''
declare @zip4                  as varchar(4)    = ''

declare @insuranceCarrierCode         as varchar(15)  = ''
declare @insuranceCarrierID           as bigint       = -1
declare @insuranceMemberID            as varchar(80)  = ''
declare @insuranceSubscriberFirstName as varchar(60)  = ''
declare @insuranceSubscriberLastName  as varchar(35)  = ''
declare @policyHolderName             as varchar(512) = ''

declare @fileLines as table (       
  line varchar(max)
)

declare @clientsParticipating as table (    
    clientID          bigint  not null default -1
  , billingClient     bit     not null default(0)
)

declare @patients as table (
   ssid                           nvarchar(50)
 , patID                          bigint /* The null value default is important */
 , clientID                       bigint /* The null value default is important */
 , rNumber                        varchar(7)
 , lName                          varchar(60)
 , fName                          varchar(35)
 , cybhiTpaApproved               bit
 , cybhiTpaID                     varchar(256)
 , cybhiTpaEnrollmentState        tinyint
 , cybhiTpaEnrollmentStartDateStr varchar(8)
 , cybhiTpaEnrollmentEndDateStr   varchar(8)
 , cybhiTpaEnrollmentStartDate    date
 , cybhiTpaEnrollmentEndDate      date
 , cybhiTpaRegOrErrCode           varchar(3)
 , cybhiTpaRegOrErrComments       varchar(100)
 , cybhiTpaFundingSource          varchar(4)
 , patientFound                   bit default(0)
 , addressDataAdded               bit default(0)
 , insuranceDataAdded             bit default(0)
 , ferpaConsentUpdated            bit default(0)
 , processed                      bit default(0)
 , processingComments             varchar(max) default('')
 , okToOverwriteExistingData      bit default(0) /* This default is important */
 , validateRec                    bit default(1)
 unique clustered (ssid)
)

declare @patientSupportingData as table (
    idx        int identity(1,1)
  , patID      bigint default(-1) /* The -1 default value is important */
  , clientID                       bigint /* The null value default is important */
  , ssid       nvarchar(50)                       
  , address1   varchar(100)                   
  , address2   varchar(100)                     
  , city       varchar(30)                      
  , [state]    varchar(2)                    
  , zip5       varchar(5)                   
  , zip4       varchar(4)           
		
  , insuranceCarrierID             bigint default(-1) /* The -1 default value is important */
  , insuranceCarrierCode           varchar(15)
  , insuranceMemberID              varchar(80)
  , insuranceSubscriberFirstName   varchar(60)
  , insuranceSubscriberLastName    varchar(35)           

  unique clustered    (idx)
, unique nonclustered (ssid)
)

/* enrollmentState
  1. None
  2. Pended
  3. Accepted
  4. Rejected
  5. Accepted But Update Required
  6. Accepted But Removal Required
  7. Accepted But Reenrollment Required
  8. Accepted But Pended - Waiting for Update
  9. Accepted But Info Sent to TPA by mistake
  */

BEGIN TRY

/*============================================================
 * Verify incoming parameters that are essential for proper op
 *============================================================*/  
    
IF (@userGroup     IS NULL) RAISERROR ('userGroup is required',   11, 1)  
IF (@userID        IS NULL) RAISERROR ('user id is required',     11, 1)    
IF (@userRank      IS NULL) RAISERROR ('userRank is required',    11, 1)    
IF (@validateRec   IS NULL) RAISERROR ('Validate flag required',  11, 1)    
IF (@clientID      IS NULL) RAISERROR ('Client ID required',      11, 1)    
IF (@fileClass     IS NULL) RAISERROR ('File class required',     11, 1)
IF (@fileContents  IS NULL) RAISERROR ('File contents required',  11, 1)

/*============================================================
 * Make sure file class is supported
 *============================================================*/  

if (@fileClass not in (1,2))
begin
  RAISERROR ('This class of return file is not supported',11, 1)
end

/*============================================================
 * Get clients TPA ID and other info
 *============================================================*/  

set @clientFound            = 0
set @consortium             = 0
set @consortiumLead         = 0
set @consortiumLeadClientID = null

select top 1
    @clientFound             = 1
  , @clientTpaID             = trim(isnull(clc.cybhiTpaID,''))   
  , @consortium              = isnull(clc.cybhiConsortiumBilling,0)
  , @consortiumLeadClientID  = isnull(clc.cybhiConsortiumLeadClientID,0)  
from dbo.CLIENTS_Client as clc
where 
  (clc.CLIENT_ID = @clientID)

/*============================================================
 * Exit if not found
 *============================================================*/  

if (@clientFound = 0)
begin
  RAISERROR ('Client not found',11, 1)
end

/*============================================================
 * Get participating clients 
 *============================================================*/  

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
    
	insert into @clientsParticipating (clientID, billingClient)
	select 
	    clientID      = t1.id 
	  , billingClient = t1.leadClient
	from dbo.CYBHI_CONSORTIUM_MEMBERS_VIEW_CORE(null,null,null,@clientID) as t1
 
  end /* client is lead */

  /*------------------------------------*/
  /* Client is not the lead - exit      */
  /*------------------------------------*/

  else
  begin
    return
  end /* client is not lead */
end

/*------------------------------------*/
/* Client is not part of consortium   */
/* include just this client */
/*------------------------------------*/

else
begin  
  insert into @clientsParticipating (clientID, billingClient) values (@clientID,1)
end

/*============================================================
 * If we reach this point the client is a consortium lead
 * or a stand alone client.  We need to verify the TPA id 
 * exists.
 *============================================================*/  

if (@clientTpaID = '')
begin
  RAISERROR ('Client does not have a TPA ID',11, 1)
end

/*============================================================
 * Parse file content
 *============================================================*/  

insert into @fileLines (
  line
)
select
  line
from
(
  select 
    line = replace(t1.[value],char(13),'') 
  from STRING_SPLIT (@fileContents,char(10)) as t1
) as q1
where 
  (line != '')

/*============================================================
 * If there are no lines to process then exit
 *============================================================*/  

set @recordID = 0
select @recordID = count(line) from @fileLines
if (@recordID = 0)
begin
  return(0)
end

/*============================================================
 * If this is a return accepted or error
 *============================================================*/  

if (@fileClass in (1,2))
begin
  
  declare @fileIsRA as bit = iif ((@fileClass = 1),1,0)
  
  /* Sniff first line */

  select top 1 
      @regProviderTpaID = trim(substring (line, 22,   15))
    , @uploadStatus     = trim(substring (line, 3296, 1))
  from @fileLines
  
  /* Peform sanity check - Does tpa id in file match the tpa id we have on file for client */

  if (@regProviderTpaID != @clientTpaID)
  begin
    RAISERROR ('Client and file TPA ids do not match',11, 1)
  end

  /* Peform sanity check - If this is a return accept file class does the upload status in file concur */

  if ((@fileIsRA = 1) and (@uploadStatus = '1'))
  begin
    RAISERROR ('File class and file contents do not match',11, 1)
  end

  /* Peform sanity check - If this is a return error file class does the upload status in file concur */

  if ((@fileIsRA = 0) and (@uploadStatus = '0'))
  begin
    RAISERROR ('File class and file contents do not match',11, 1)
  end
  
  /* Parse */

  insert into @patients (      
	  ssid 
	, rNumber
	, lName
	, fName                
    , cybhiTpaApproved           
    , cybhiTpaID                
    , cybhiTpaEnrollmentState   
    , cybhiTpaEnrollmentStartDateStr 
    , cybhiTpaEnrollmentEndDateStr   
    , cybhiTpaRegOrErrCode
    , cybhiTpaRegOrErrComments
    , cybhiTpaFundingSource
	, validateRec
  )
  select 
      ssid                            = trim(substring (line, 69,  15)) 
    , rNumber                         = trim(substring (line, 1,   7))
	, lName                           = trim(substring (line, 141, 60))
	, fName                           = trim(substring (line, 261, 35))
	, cybhiTpaApproved                = @fileIsRA
	, cybhiTpaID                      = iif ((@fileIsRA = 1), trim(substring (line, 3319, 15)),    null)
    , cybhiTpaEnrollmentState         = iif ((@fileIsRA = 1),3,4) /*3. Accepted 4. Rejected*/
	, cybhiTpaEnrollmentStartDateStr  = iif ((@fileIsRA = 1), trim(substring (line, 3338, 8)),     null)
    , cybhiTpaEnrollmentEndDateStr    = iif ((@fileIsRA = 1), trim(substring (line, 3346, 8)),     null)
    , cybhiTpaRegOrErrCode            = iif ((@fileIsRA = 1), trim(substring (line, 3354, 3))  , trim(substring (line, 3297, 3)))
	, cybhiTpaRegOrErrComments        = iif ((@fileIsRA = 1), trim(substring (line, 3357, 100)), trim(substring (line, 3300, 100))) 
    , cybhiTpaFundingSource           = iif ((@fileIsRA = 1), trim(substring (line, 3334, 4)),     null) 
	, validateRec                     = @validateRec
  from @fileLines

  /* If this is a return accept */

  if (@fileIsRA = 1)
  begin

    /* Convert enrollment dates (returned as mmddyyyy string) */  

	update @patients
    set 
    
	  cybhiTpaEnrollmentStartDate = DATEFROMPARTS(
          convert(INT,SUBSTRING(cybhiTpaEnrollmentStartDateStr,5,4),0)
       ,  convert(INT,SUBSTRING(cybhiTpaEnrollmentStartDateStr,1,2),0)
       ,  convert(INT,SUBSTRING(cybhiTpaEnrollmentStartDateStr,3,2),0)
      )
      ,
      cybhiTpaEnrollmentEndDate = DATEFROMPARTS(
          convert(INT,SUBSTRING(cybhiTpaEnrollmentEndDateStr,5,4),0)
       ,  convert(INT,SUBSTRING(cybhiTpaEnrollmentEndDateStr,1,2),0)
       ,  convert(INT,SUBSTRING(cybhiTpaEnrollmentEndDateStr,3,2),0)
      )
  
  end

end

/*============================================================
 * Add other file classes here
 *============================================================*/  

else 
begin
  return 
end

/*============================================================
 * Match up to patient ids (within scope of participating 
 * clients)
 *============================================================*/  

update p
set 
   p.patID    = pap.PATIENT_ID
 , p.clientID = pac.CLIENT_ID
from @patients             as p
join dbo.PATIENTS_Patient  as pap on pap.CSIS       = p.ssid
join dbo.PATIENTS_Client   as pac on pac.PATIENT_ID = pap.PATIENT_ID
join @clientsParticipating as cp  on cp.clientID    = pac.CLIENT_ID

/*============================================================
 * Update processing flag and comments for cases where we 
 * could not find patients
 *============================================================*/  

update @patients
set 
    patientFound       = 0
  , processingComments = 'Patient record WAS NOT found in SpEdCare.'
where 
  (patID is null)

/*============================================================
 * Update processing flag and comments for cases where we 
 * COULD find patients
 *============================================================*/  

update @patients
set 
    patientFound       = 1
  , processingComments = 'Patient record found in SpEdCare.'
where 
  (patID is not null)

/*============================================================
 * Update okToOverwrite
 *============================================================*/  

if (@fileClass = 1)
begin
  update p
  set 
    p.okToOverwriteExistingData = 1
  from @patients as p
  where 
    (p.patID is not null)
end

else if (@fileClass = 2)
begin
  update p
  set 
    p.okToOverwriteExistingData = 1
  from @patients            as p
  join dbo.PATIENTS_Patient as pap on pap.PATIENT_ID = p.patID
  where (
        (p.patID is not null)
    and (pap.cybhiTpaApproved = 0)
    and (trim(isnull(pap.cybhiTpaID,'')) = '')
  )
end

/*============================================================
 * Determine if we need to add supporting data for each
 * patient (address and/or insurance data)
 *============================================================*/  

set @addSupportingData = 0
if ((@fromExternalSource = 1) and (@fileClass = 1)) 
begin 
  set @addSupportingData = 1 
end
 
/*============================================================
 * If we have to add supporting data extract it from the 
 * file
 *============================================================*/  

if (@addSupportingData = 1)
begin
   
  /* Parse contents into JSON */
 
  exec dbo.CYBHI_TPA_CARELON_PARSE_PAT_REG_FILE_CONTENTS_CORE 
      @fileClass 
    , @fileContents
    , @fileContentsJSONOut output     
 
  /* Parse json into table */
  
  insert into @patientSupportingData (
      ssid                         
    , address1                       
    , address2                       
    , city                           
    , [state]                        
    , zip5                         
    , zip4                         
 
	, insuranceCarrierCode         
    , insuranceMemberID            
    , insuranceSubscriberFirstName 
    , insuranceSubscriberLastName  
  )

  select  
   	  ssid                         
    , address1                       
    , address2                       
    , city                           
    , [state]                        
    , zip5                         
    , zip4                          
	
	, insuranceCarrierCode         
	, insuranceMemberID            
    , insuranceSubscriberFirstName 
    , insuranceSubscriberLastName
    
  from openjson(@fileContentsJSONOut,'$.patients')
  with (                     
		   ssid                         nvarchar(50)      '$."Student ID"'
         , address1                     varchar(100)      '$."Street Address Line 1"'
         , address2                     varchar(100)      '$."Street Address Line 2"'
         , city                         varchar(30)       '$."City"'
         , [state]                      varchar(2)        '$."State"'
         , zip5                         varchar(5)        '$."Zip Code"'
         , zip4                         varchar(4)        '$."Zip Code Extension"'    
 
		 , insuranceCarrierCode         varchar(15)       '$."Insurance Carrier Code 1"'
		 , insuranceMemberID            varchar(80)       '$."Insurance Policy Member ID 1"'
         , insuranceSubscriberFirstName varchar(60)       '$."Insurance Subscriber First Name 1"'
         , insuranceSubscriberLastName  varchar(35)       '$."Insurance Subscriber Last Name 1"'
  ) as t1
 
  
  update t2 
  set 
      t2.patID    = t1.patID
    , t2.clientID = t1.clientID
  from @patients              as t1
  join @patientSupportingData as t2 on t2.ssid = t1.ssid
 
  update t1
    set t1.insuranceCarrierID = ic.id
  from @patientSupportingData as t1 
  join dbo.INSURANCE_CARRIERS as ic on ic.carrierCode = t1.insuranceCarrierCode
  where 
    (ic.active = 1)
  
  select @maxIdx = max(t1.idx) from @patientSupportingData as t1

end

/*============================================================
 * Validation
 *============================================================*/  

IF (@validateRec = 1) 
BEGIN  
  
  /*============================================================
   * Set json data with results
   *============================================================*/  

  set @jsonData = convert(varchar(max),(select * from @patients FOR JSON AUTO, INCLUDE_NULL_VALUES ))

  SET @recordID = 0 
  RETURN(0)    
END        

/*============================================================
 * Update actual patient data
 *===========================================================*/   

begin transaction

  set @tranOpen = 1
  
  /*============================================================
   * TPA data
   *===========================================================*/   

  update pap
  set
      pap.cybhiTpaApproved            = p.cybhiTpaApproved
    , pap.cybhiTpaApprovedOn          = @todayDateOnly
    , pap.cybhiTpaID                  = p.cybhiTpaID
    , pap.cybhiTpaEnrollmentState     = p.cybhiTpaEnrollmentState
    , pap.cybhiTpaEnrollmentStartDate = p.cybhiTpaEnrollmentStartDate
    , pap.cybhiTpaEnrollmentEndDate   = p.cybhiTpaEnrollmentEndDate
    , pap.cybhiTpaRegOrErrCode        = p.cybhiTpaRegOrErrCode
    , pap.cybhiTpaRegOrErrComments    = p.cybhiTpaRegOrErrComments
  from @patients            as p
  join dbo.PATIENTS_Patient as pap on pap.PATIENT_ID = p.patID
  where ( 
        (p.patID is not null)
    and (p.okToOverwriteExistingData = 1)
  )
commit transaction
set @tranOpen = 0

/*============================================================
 * Supporting data
 *===========================================================*/   

if (@addSupportingData = 1)
begin
    
  set @curIdx = 1
    
  while (@curIdx <= @maxIdx)
  begin

      set @tranOpen              = 0
      set @ssid                  = N''
      set @participatingClientID = -1
	  set @patID                 = -1
	  set @insuranceCarrierID    = -1
	  set @street1               = ''
      set @street2               = ''
	  set @city                  = ''
	  set @state                 = ''
	  set @zip5                  = ''
	  set @zip4                  = ''

	  set @insuranceMemberID            = ''
	  set @insuranceSubscriberFirstName = ''
	  set @insuranceSubscriberLastName  = ''
	  set @policyHolderName             = ''

      select top 1
	      @ssid                  = t1.ssid
		, @patID                 = t1.patID
       	, @participatingClientID = t1.clientID	  		         
	    , @street1               = t1.address1
        , @street2               = t1.address2
	    , @city                  = t1.city
	    , @state                 = t1.[state]
	    , @zip5                  = t1.zip5
	    , @zip4                  = t1.zip4

		, @insuranceCarrierID           = t1.insuranceCarrierID	    
	    , @insuranceMemberID            = t1.insuranceMemberID
	    , @insuranceSubscriberFirstName = t1.insuranceSubscriberFirstName
	    , @insuranceSubscriberLastName  = t1.insuranceSubscriberLastName
            
      from @patientSupportingData as t1
	  
      where 
        (t1.idx = @curIdx)
    
	  /*============================================================
       * If the patient was found open a dedicated transaction
	   * and attempt to save data
       *===========================================================*/   
       
      if (@patID != -1)
	  begin
	  begin transaction	  
	  set @tranOpen = 1

	    /*============================================================
         * If the address was provided
         *===========================================================*/   

	    if ((@street1 !='') and (@city != '') and (@state !='') and (@zip5 != ''))
	    begin
  	  
	      /*============================================================
           * And the address is not already in our records
           *===========================================================*/   

	      if not exists (
	        select top 1 
	          pp.ID
	        from dbo.PATIENT_PLACES as pp
	        where (
	              ((pp.PATIENT_ID = @patID) and (pp.ID is not null)) /* PAT_ID_IDX index */
              and (pp.NAME                  = 'Primary Home')
	          and (pp.PATIENT_PLACE_TYPE    = 1)
	          and (pp.PLACE_FORMAT_TYPE     = 1)
	          and (pp.PLACE_SOURCE_TYPE     = 2)
	          and (isnull(pp.ADDRESS_1,'')  = @street1)
	          and (isnull(pp.ADDRESS_2,'')  = @street2)
	          and (isnull(pp.CITY,'')       = @city)
	          and (isnull(pp.[STATE],'')    = @state)
	          and (isnull(pp.ZIP_5,'')      = @zip5)
	          and (isnull(pp.ZIP_4,'')      = @zip4)
	          and (pp.active                = 1)
	        )
          ) /* If patient place does not exist*/
          begin    
            insert into dbo.PATIENT_PLACES (
                CLIENT_ID
              , PATIENT_ID
              , [NAME] 
              , PATIENT_PLACE_TYPE
              , PLACE_FORMAT_TYPE
              , PLACE_SOURCE_TYPE
              , ADDRESS_1
              , ADDRESS_2
              , CITY
              , [STATE]
              , ZIP_5
              , ZIP_4
              , CREATED_BY
              , CREATED_ON
              , ACTIVE 			  
            )
            values (
                @clientID
              , @patID
              , 'Primary Home'
              , 1 /* PATIENT_PLACE_TYPE */  
              , 1 /*PLACE_FORMAT_TYPE*/
              , 2 /*PLACE_SOURCE_TYPE*/
              , @street1
              , @street2
              , @city
              , @state
              , @zip5
              , @zip4
              , @userID
              , @today
              , 1  
            )

	        update @patients 
			set 
			    processingComments = processingComments + ' Patient address added.'
			  , addressDataAdded   = 1
			where 
			  (ssid = @ssid)

          end /* if patient place does not exist*/
	    end /* address provided */

        /*============================================================
         * If the insurance info was provided
         *===========================================================*/   
         
	    if ((@insuranceCarrierID != -1) and (@insuranceMemberID != '') and (@insuranceSubscriberFirstName != '') and (@insuranceSubscriberLastName != ''))
        begin
         	  
	      /*============================================================
           * And the insurance info is not in our records already
           *===========================================================*/   
  
	      if not exists (
	        select top 1 
	          t1.id 
	        from dbo.PATIENT_INSURANCE_CARRIERS as t1
	        where (
	              ((t1.clientID = @participatingClientID) and (t1.patID = @patID) and (t1.id > 0)) /* Index: CLIENT_PAT_IDX*/
	          and (t1.insuranceCarrierID   = @insuranceCarrierID)
	          and (t1.beneficiaryFirstName = @insuranceSubscriberFirstName)
	          and (t1.beneficiaryLastName  = @insuranceSubscriberLastName)
	          and (t1.beneficiaryID        = @insuranceMemberID)
              and (t1.active = 1)
	        )
	      ) /* If patient insurance carrier record does not exist */
          begin             
            
			set @policyHolderName = @insuranceSubscriberFirstName + ' ' + @insuranceSubscriberLastName

		    insert into dbo.PATIENT_INSURANCE_CARRIERS (
                clientID
              , patID
              , insuranceCarrierID 
              , beneficiaryFirstName
              , beneficiaryLastName
              , beneficiaryID
			  , policyHolderName
			  , cybhiRegisteredWithTpa
			  , primaryCarrier
              , createdBy
              , created
              , active
            )
            values (
                @participatingClientID
              , @patID
              , @insuranceCarrierID
              , @insuranceSubscriberFirstName
              , @insuranceSubscriberLastName
              , @insuranceMemberID
			  , @policyHolderName
			  , 1  /* Flag as registered with TPA */
			  , 1
              , @userID
              , @today
              , 1  
            )
			
			update @patients 
			set 
			    processingComments = processingComments + ' Patient insurance carrier record added.'
			  , insuranceDataAdded = 1
			where 
			  (ssid = @ssid)

	      end /* If patient insurance carrier does not exist */
        end /* Insurance data provided */

 	    /*============================================================
         * Update FERPA consent.  Note: Since this data is coming from
	     * the client then the client provided this initially to 
	     * the TPA and thus MUST HAVE FERPA CONSENT.
         *===========================================================*/   

        update dbo.PATIENTS_Patient 
        set 
            ferpaConsent              = 1
          , ferpaConsentEffectiveDate = @todayDateOnly
        where 
	      (patient_id = @patID)

        update @patients 
	    set 
		  processingComments = processingComments + ' FERPA status updated.'
	    , ferpaConsentUpdated = 1
		where 
	     (ssid = @ssid)

   /*============================================================
    * If we reach this point everything is OK commit the tx	     
    *===========================================================*/   

	commit transaction
	set @tranOpen = 0
	end /* patient found */

    set @curIdx = @curIdx + 1
        
  end /* while */

end /* patient supporting data*/
  
/*============================================================
 * All done
 *============================================================*/  

update @patients set processed = 1
set @jsonData = convert(varchar(max),(select * from @patients FOR JSON AUTO, INCLUDE_NULL_VALUES ))

RETURN(0)    
END TRY  

/*============================================================
 * Exception handling
 *============================================================*/      

BEGIN CATCH    
    
  /*-------------------------------    
   * If we end up here something    
   * went wrong.  Cancel any pending    
   * transactions and return any    
   * error any error messages to    
   * the caller    
   *------------------------------*/    
       
  -- Error or raise error with severity 11 to 19 will be caught here    
      
  IF @tranOpen = 1 ROLLBACK TRANSACTION    
      
  DECLARE @ErrorMessage  AS NVARCHAR(4000)    
  DECLARE @ErrorSeverity AS INT    
  DECLARE @ErrorState    AS INT    
      
  SELECT  @ErrorMessage  = ERROR_MESSAGE(),    
          @ErrorSeverity = ERROR_SEVERITY(),    
          @ErrorState    = ERROR_STATE()    
   
  -- Only send really bad exceptions back with sp details

  if (@ErrorSeverity > 11)    
    SET @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ']'    
      
  -- Reraise the error so it returns back to the server    
      
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
    
END CATCH    
END    
    
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[CYBHI_TPA_RETURN_FILE_PROCESS_PAT_REG] TO [webuser]
GO
 
