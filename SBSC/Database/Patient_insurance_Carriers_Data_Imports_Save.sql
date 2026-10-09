USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Patients_Insurance_Carriers_Data_Imports_Save') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.Patients_Insurance_Carriers_Data_Imports_Save
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[Patients_Insurance_Carriers_Data_Imports_Save] (
    @userID                   bigint
  , @userGroup                int
  , @userRank                 int
  , @clientID                 bigint  
  , @importDataJSON           varchar(max)  
  , @editDelReason            varchar(7000)
  , @validateRec              bit
  , @saveType                 int
  , @recID                    bigint
  , @MsgNoRec                 varchar(1000)
  , @MsgNoEdit                varchar(1000)
  , @MsgDupRec                varchar(1000)
  , @MsgDataError             varchar(1000)
  , @MsgNotActive             varchar(1000)

  , @spDetails                varchar(8000) output
  , @recordID                 bigint        output
  , @jsonData                 varchar(max)  output
)
AS
BEGIN

declare @tranOpen      as bit = 0
declare @today         as datetime = getdate()
declare @todayDateOnly as date     = convert(date,@today)

set @recordID  = 0
set @spDetails = ''
set @jsonData  = '{"importData":' 
                  + @importDataJSON 
		  		  + ',"exportData":[]'
	 			  + '}'

declare @patientInsuranceCarriersIn as table (
   rowBad                      bit
 , rowNum                      int

 , clientID                    bigint
 , ssid                        nvarchar(50)
 , patID                       bigint
 , carrierCode                 varchar(15)

 , policyNumOrig               varchar(80)
 , MIDorig                     varchar(80)

 , insuranceCarrierID          bigint
 , beneficiaryLastName         varchar(60)
 , beneficiaryFirstName        varchar(35)
 , beneficiaryID               varchar (80)
 , policyHolderName            varchar (512)
 , insCarrierNameStr           varchar (512)
 , policyGroupID               varchar (256)
 , ferpaConsentIn              bit
 , ferpaConsentEffectiveDateIn date
 , ferpaConsentExisting                   bit
 , ferpaConsentEffectiveDateExisting      date
 , ssidProvided                           bit default(0)
 , carrierCodeProvided                    bit default(0)
 , beneficiaryIDProvided                  bit default(0)
 , patientFound                           bit default(0)
 , carrierFound                           bit default(0)
 , hasEnoughDataForPatientCarrierRec      bit default(0)
 , hasExistingPatientCarrierRecWithData   bit default(0)
 , canCreateNewPatientCarrierRec          bit default(0)
 , canUpdateFerpaConsent                  bit default(0)
 , validateSubmit                         bit not null
 , processingNotes                        varchar(max)   default('')
 , patientHasExistingActiveInsuranceCarrier bit default(0)
 , carrierSupportedByCybhi                  bit default(0)
 , primaryCarrier                           bit default(0)
)

declare @duplicateSsidDetectionsInDataIn as table (
  ssid  nvarchar(50)
)

declare @ssidMatchesInOurData as table (
    ssid  nvarchar(50)
  , patID bigint
)

declare @duplicateSsidMatchesInOurData as table (
  ssid  nvarchar(50)
)

BEGIN TRY
 
;with
cte_p1
as
(
  select
      rowBad                = t1.rowBad
	, rowNum                = t1.rowNum
    , SSID                  = convert(nvarchar(50),(trim(isnull(str(t1.[patSSID],50,0),''))))
    , carrierName           = trim(isnull(nullif(t1.[CarrierName],'NULL'),''))
    , carrierCode           = trim(isnull(nullif(t1.[CarrierCode],'NULL'),''))
    , policyNumber          = trim(isnull(nullif(t1.[PolicyNumber],'NULL'),''))
    , policyGroupID         = trim(isnull(nullif(t1.[GroupID],'NULL'),''))
    , medicalID             = trim(isnull(nullif(t1.[MID],'NULL'),''))
    , subscriberFirstName   = trim(isnull(nullif(t1.[SubscriberFirstName],'NULL'),''))
    , subscriberLastName    = trim(isnull(nullif(t1.[SubscriberLastName],'NULL'),''))
    , consentToBillCode     = isnull((try_convert(tinyint,(nullif(t1.[ConsentToBill],'NULL')))),0)
    , consentToBillAuthDate = try_convert(date,(nullif(t1.[AuthorizationDate],'NULL')))
 
  FROM OPENJSON( @importDataJSON, '$."structuredDataRows"' )
  WITH (
        [rowBad]      bit                     '$."rowBad"'
	  , [rowNum]      int                     '$."rowNumIn"'

      , [patSSID]         nvarchar(14)        '$."rowData"."patSSID"'
      , [CarrierName]     nvarchar(14)        '$."rowData"."CarrierName"'

      , [CarrierCode]     nvarchar(14)        '$."rowData"."CarrierCode"'
      , [PolicyNumber]     nvarchar(14)       '$."rowData"."PolicyNumber"'
      , [GroupID]     nvarchar(14)            '$."rowData"."GroupID"'

      , [MID]                       nvarchar(14)           '$."rowData"."MID"'
      , [SubscriberFirstName]       nvarchar(14)           '$."rowData"."SubscriberFirstName"'
	  , [SubscriberLastName]        nvarchar(14)           '$."rowData"."SubscriberLastName"'

      , [ConsentToBill]         nvarchar(14)            '$."rowData"."ConsentToBill"'
      , [AuthorizationDate]     nvarchar(14)            '$."rowData"."AuthorizationDate"'


  ) as t1 
)
,
cte_p2
as
(
 select
 
    p1.*
 
  /* Determine ferpa consent using clients business rules for their consent to bill values */
 
  , ferpaConsentIn = convert(bit,(case
                                 when p1.consentToBillCode = 0 then null
                                 when p1.consentToBillCode = 1 then 1
                                 when p1.consentToBillCode = 2 then 0
               else null end))
     
 from cte_p1 as p1
)
 
insert into @patientInsuranceCarriersIn (

   rowBad
 , rowNum

 , clientID
 , ssid
 , carrierCode
 , beneficiaryLastName
 , beneficiaryFirstName
 , beneficiaryID       
 , policyHolderName    
 , insCarrierNameStr   
 , policyGroupID       
 , ferpaConsentIn        
 , ferpaConsentEffectiveDateIn

 , policyNumOrig
 , MIDorig

 , validateSubmit
)
select

    rowBad
  , rowNum

  , clientID             = @clientID
  , p2.ssid 
  , p2.carrierCode
  , beneficiaryLastName  = p2.subscriberLastName
  , beneficiaryFirstName = p2.subscriberFirstName
  , beneficiaryID        = case when (p2.medicalID    != '') then p2.medicalID
                                when (p2.policyNumber != '') then p2.policyNumber
                          else '' end
  , policyHolderName  = p2.subscriberFirstName + ' ' + p2.subscriberLastName
  , insCarrierNameStr = p2.carrierName
  , policyGroupID     = p2.policyGroupID
  , p2.ferpaConsentIn
  , ferpaConsentEffectiveDateIn = p2.consentToBillAuthDate

  , policyNumber
  , medicalID

  , @validateRec

from cte_p2 as p2
order by 
  p2.rowNum asc

/* Flag rows that have SSID */
 
update @patientInsuranceCarriersIn set ssidProvided = 1 where (ssid != '')
 
/* Flag rows that have carrier code */
 
update @patientInsuranceCarriersIn set carrierCodeProvided = 1 where (carrierCode != '')
 
/* Flag rows that have beneficiary ID */
 
update @patientInsuranceCarriersIn set beneficiaryIDProvided = 1 where (beneficiaryID != '')
 
/* Search incoming data for duplicate SSID rows */

insert into @duplicateSsidDetectionsInDataIn (
  ssid
)
select 
  t1.ssid 
from @patientInsuranceCarriersIn as t1
where 
  (t1.ssidProvided = 1)
group by 
  t1.ssid
having 
  (count(t1.rowNum) > 1)

/* Flag */

update t2
set 
    rowBad = 1
  , processingNotes = processingNotes + ' There is another row in this dataset with the same SSID.'
from @duplicateSsidDetectionsInDataIn as t1
join @patientInsuranceCarriersIn      as t2 on t2.ssid = t1.ssid
where 
  (t2.ssidProvided = 1)

/* Attempt to find patient matches */

insert into @ssidMatchesInOurData (
    ssid  
  , patID 
)
select 
    ssid  = t1.SSID
  , patID = pap.PATIENT_ID
from @patientInsuranceCarriersIn as t1
join dbo.PATIENTS_Patient        as pap on pap.CSIS       = t1.ssid
join dbo.PATIENTS_Client         as pac on pac.PATIENT_ID = pap.PATIENT_ID and pac.CLIENT_ID = @clientID                             
where (
      (t1.rowBad       = 0)
  and (t1.ssidProvided = 1)
  and (pap.ACTIVE != N'n')
)

/* Attempt to find duplicate rows by ssid in our data */
 
insert into @duplicateSsidMatchesInOurData (ssid)
select 
  t1.ssid 
from @ssidMatchesInOurData as t1
group by 
  t1.ssid
having count(patID) > 1

update t2
set 
    rowBad = 1
  , processingNotes = processingNotes + ' There is another patient record in SpEdCare with the same SSID.'
from @duplicateSsidMatchesInOurData as t1
join @patientInsuranceCarriersIn    as t2 on t2.ssid = t1.ssid
where 
  (t2.ssidProvided = 1)

/* Update with clean matches */

update t1
set
    t1.patID                             = t2.patID
  , t1.patientFound                      = 1
  , t1.ferpaConsentExisting              = pap.ferpaConsent
  , t1.ferpaConsentEffectiveDateExisting = pap.ferpaConsentEffectiveDate
from @patientInsuranceCarriersIn as t1
join @ssidMatchesInOurData       as t2  on t2.ssid = t1.ssid
join PATIENTS_Patient            as pap on pap.PATIENT_ID = t2.patID

where (
  (t1.rowBad = 0)
)

/* Attempt to find insurance carrier ID */
 
update t1
set
    t1.insuranceCarrierID = ic.id
  , t1.carrierFound       = 1
  , t1.carrierSupportedByCybhi = ISNULL(ic.planSupportedByCYBHI, 0)
from @patientInsuranceCarriersIn as t1
join dbo.INSURANCE_CARRIERS      as ic on ic.carrierCode = t1.carrierCode and ic.active = 1
where
  (t1.carrierCodeProvided = 1)
 
/* Determine if we have complete data */
 
update @patientInsuranceCarriersIn
set
  hasEnoughDataForPatientCarrierRec = 1
where (
      (patientFound          = 1)
  and (carrierFound          = 1)
  and (beneficiaryIDProvided = 1)  
)
   
/* Check for existing record that has complete data */
 
update t1
set
  t1.hasExistingPatientCarrierRecWithData = pic2.active
from @patientInsuranceCarriersIn    as t1
cross apply (
  select top 1
    pic1.active
  from dbo.PATIENT_INSURANCE_CARRIERS as pic1
  where (
        (pic1.clientID           = t1.clientID)
    and (pic1.patID              = t1.patID)
    and (pic1.insuranceCarrierID = t1.insuranceCarrierID)
    and (pic1.beneficiaryID      = t1.beneficiaryID)
    and (pic1.active             = 1)
  )
) as pic2
where
  (t1.hasEnoughDataForPatientCarrierRec = 1)

/* Determine if patient already has any active insurance carrier rows */

update t1
set
    t1.patientHasExistingActiveInsuranceCarrier = 1
from @patientInsuranceCarriersIn as t1
where exists
(
    select top 1
        pic.id
    from dbo.PATIENT_INSURANCE_CARRIERS as pic
    where pic.clientID = t1.clientID
      and pic.patID    = t1.patID
      and pic.active   = 1
);
 
/* Determine if we can add a new insurance record */
 
update @patientInsuranceCarriersIn
set
  canCreateNewPatientCarrierRec = 1
where (
      (hasEnoughDataForPatientCarrierRec = 1)
  and (hasExistingPatientCarrierRecWithData = 0)
)
 
/* Determine if imported new row should be primary */

update @patientInsuranceCarriersIn
set
    primaryCarrier = 1
where (
      canCreateNewPatientCarrierRec = 1
  and patientHasExistingActiveInsuranceCarrier = 0
  and carrierSupportedByCybhi = 1
);

/* Determine if we can update ferpa consent */
 
update @patientInsuranceCarriersIn
  set canUpdateFerpaConsent = 1
where (
      (patientFound = 1)
  and (ferpaConsentIn is not null)
)

/* Return info to user on missing or existing data */

update @patientInsuranceCarriersIn
set   
   processingNotes = processingNotes + ' No SSID provided.'
where 
  (ssidProvided = 0)

update @patientInsuranceCarriersIn
set   
  processingNotes = processingNotes + ' Patient not found with SSID provided.' 
where 
  ((rowBad = 0) and (ssidProvided = 1) and (patientFound = 0))

update @patientInsuranceCarriersIn
set 
  processingNotes = processingNotes + ' No carrier code provided.'
where 
  (carrierCodeProvided = 0)

update @patientInsuranceCarriersIn
set 
  processingNotes = processingNotes + ' No member ID provided.'
where 
  (beneficiaryIDProvided = 0)

update @patientInsuranceCarriersIn
set 
  processingNotes = processingNotes + ' No FERPA consent status provided.'
where 
  (ferpaConsentIn is null)

update @patientInsuranceCarriersIn
  set 
    ferpaConsentEffectiveDateIn = @todayDateOnly
  , processingNotes = processingNotes + ' No FERPA consent effective date provided, using todays date instead.'
where 
  (ferpaConsentEffectiveDateIn is null)

if (@validateRec = 1)
begin

  update @patientInsuranceCarriersIn
  set 
    processingNotes = processingNotes + ' No need to add new insurance data because there is an existing record with this insurance data.'
  where (
        (hasEnoughDataForPatientCarrierRec    = 1)
    and (hasExistingPatientCarrierRecWithData = 1)   
  )

  update @patientInsuranceCarriersIn
  set 
    processingNotes = processingNotes + ' Unable to add new insurance data but FERPA consent can be updated.'
  where (
        (hasEnoughDataForPatientCarrierRec = 0)
    and (canUpdateFerpaConsent             = 1)
  )

  update @patientInsuranceCarriersIn
  set 
    processingNotes = processingNotes + ' Unable to add new insurance data but FERPA consent can be updated.'
  where (
        (hasEnoughDataForPatientCarrierRec     = 1)
    and (hasExistingPatientCarrierRecWithData  = 1)
    and (canUpdateFerpaConsent                 = 1)
)

  update @patientInsuranceCarriersIn
  set 
      processingNotes = processingNotes + ' Unable to update FERPA consent but new insurance data can be added.'
  where (
        (hasEnoughDataForPatientCarrierRec    = 1)
    and (hasExistingPatientCarrierRecWithData = 0)
    and (canUpdateFerpaConsent                = 0)
  )
end

update @patientInsuranceCarriersIn
set 
    rowBad = 1
  , processingNotes = processingNotes + ' Unable to use any data on this row.'
where ( 
      (hasEnoughDataForPatientCarrierRec = 0) 
  and (canUpdateFerpaConsent             = 0)
)

set @jsonData = '{"importData":' 
              + @importDataJSON 
		   	  + ',"exportData":'
			  + convert(varchar(max),(select * from @patientInsuranceCarriersIn FOR JSON AUTO, INCLUDE_NULL_VALUES ))
			  + '}'

IF (@validateRec = 1) RETURN(0)
 
  BEGIN TRANSACTION
  SET @tranOpen = 1

	/* List of patients to add new carrier record for */

		INSERT INTO 
		 [dbo].[PATIENT_INSURANCE_CARRIERS](
			[clientID]   ,
			[patID]      ,

			[insuranceCarrierID]  , 
			[insCarrierNameStr]   ,

			[beneficiaryLastName]    , 
			[beneficiaryFirstName]   ,
			[beneficiaryID]      , 
			[created]            , 
			[createdBy]          , 

			[policyHolderName]   , 
			[policyGroupID]		 ,			

			[primaryCarrier]     

		)
		select
		   clientID                                        
		 , patID                                  
		 , insuranceCarrierID  
		 , insCarrierNameStr 
       
		 , beneficiaryLastName   
		 , beneficiaryFirstName      
		 , beneficiaryID 
 
		 , GETDATE() 
		 , @userID

		 , policyHolderName         
		 , policyGroupID   
		 , primaryCarrier           
       
	  FROM
		@patientInsuranceCarriersIn
	  where 
	      rowBad = 0
	  and canCreateNewPatientCarrierRec = 1

/* List of patient to update ferpa consent data for*/
 
	  update p_p
	  set 
	        ferpaConsent              = _in.ferpaConsentIn
	      , ferpaConsentEffectiveDate = _in.ferpaConsentEffectiveDateIn
		  , LAST_UPDATED              = @today
	  FROM   dbo.PATIENTS_Patient   p_p
	  JOIN   @patientInsuranceCarriersIn _in  ON p_p.PATIENT_ID = _in.patID
	  where  (
	         _in.rowBad = 0
		 and _in.canUpdateFerpaConsent = 1
	  )
      
    COMMIT TRANSACTION
	SET @tranOpen = 0

return(0)

END TRY
BEGIN CATCH

  /*-------------------------------
   * If we end up here something
   * went wrong.  Cancel any pending
   * transactions and return any
   * error any error messages to
   * the caller
   *------------------------------*/

  if (@tranOpen = 1)
  begin
    rollback transaction
	set @tranOpen = 0
  end

  -- Error or raise error with severity 11 to 19 will be caught here

  DECLARE @ErrorMessage  AS NVARCHAR(4000)
  DECLARE @ErrorSeverity AS INT
  DECLARE @ErrorState    AS INT

  SELECT  @ErrorMessage  = ERROR_MESSAGE(),
          @ErrorSeverity = ERROR_SEVERITY(),
          @ErrorState    = ERROR_STATE()

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

GRANT EXECUTE ON  [dbo].[Patients_Insurance_Carriers_Data_Imports_Save] TO [webuser]
GO
