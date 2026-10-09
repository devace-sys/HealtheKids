use SPEDMON 
GO

/*---------------------------------------------------------------------------------------------------------*/

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].CYBHI_TRANSMISSION_GENERATION_CREATE_TRANSMISSION_RECORD_SET') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
begin
  drop PROCEDURE dbo.CYBHI_TRANSMISSION_GENERATION_CREATE_TRANSMISSION_RECORD_SET
end
GO

/*---------------------------------------------------------------------------------------------------------*/

CREATE PROCEDURE dbo.CYBHI_TRANSMISSION_GENERATION_CREATE_TRANSMISSION_RECORD_SET (
	  @clientID           bigint
	, @billingClientID    bigint
	, @consortium         bit
	, @oldestDos          date
	, @latestDos          date
    , @shortName          varchar(100) = ''
	, @userID	          bigint
	, @possibleClaimCount int           output
	, @fileName           varchar(100)  output
	, @transmissionID     bigint        output
)
AS
BEGIN

  set nocount on
  
  declare @possibleClaims as table (      
      svcRecID                           bigint
    , claimID                            bigint
	, siteID                             int	
	, patInsuranceCarrierID              bigint
	, patInsuranceMemberID               varchar(80)
	, useTpaIdAsInsuranceMemberID        bit null /* Do not use a default must start out as null */
	, carrierFound                       bit not null default(0)
	, carrierRegisterWithTPA             bit not null default(1)
	, carrierRegisterWithTPAHasEndDate   bit not null default(0)
	, carrierRegisterWithTPAEndDate      datetime
	, dos                                datetime
	, carrierPcCode                      varchar(50)
	unique clustered (svcRecID, claimID)
  )
  	
  declare @transmissionIDx16 as varchar(7)

  /*---------------------------------------------------------------------------------------------------------*/
  
  /* Init */

  set @possibleClaimCount = 0
  set @fileName           = ''
  set @transmissionID     = -1

  /* Get possible claims */

  insert into @possibleClaims (
      svcRecID
    , claimID
	, siteID
	
  )
  select
      t1.svcRecID
    , t1.claimID
	, t1.siteID    
	   
  from dbo.CYBHI_TRANSMISSION_GENERATION_GET_POSSIBLE_CLAIMS (@clientID, @oldestDos, @latestDos) as t1  

  order by 
      t1.svcRecID
    , t1.claimID
  
  option(recompile)

  /*---------------------------------------------------------------------------------------------------------*/

  /* Get possible claim count */

  select 
    @possibleClaimCount = count(t1.claimID) 
  from @possibleClaims as t1
  option(recompile)

  /* If nothing to submit get out */

  if (@possibleClaimCount = 0)
  begin
    return(0)
  end
  
  /*---------------------------------------------------------------------------------------------------------*/

  /* Create transmission record, capture transmission id (tx id), create hex value of tx id. */

  insert into dbo.CYBHI_CLAIM_TRANSMISSIONS (
      clientID                    
	, billingClientID
	, consortium
	, created 
	, createdBy	
  )
  values (
      @clientID
	, @billingClientID
	, @consortium
    , getdate()
    , @userID
  )
  option(recompile)

  set @transmissionID    = SCOPE_IDENTITY()                          /* Get transmissionID.  We need this ID for control purposes. */
  set @transmissionIDx16 = dbo.bigint_2_hexstr(@transmissionID, 7)   /* Creare Hex version */

  /*---------------------------------------------------------------------------------------------------------*/

  /* Generate filename */

  set @fileName = 'CYBHI-X12-5010-837P'
                + '-' 
                + @shortName 
                + '-' 
				+ convert(varchar(50),@transmissionID) 
				+ '.edi'
 
  update dbo.CYBHI_CLAIM_TRANSMISSIONS
  set 
    [fileName] = @fileName
  where 
    (id = @transmissionID)
  option(recompile)
  
  /*---------------------------------------------------------------------------------------------------------*/

  /* Get insurance info for patient and info on insurance carrier.
   * Also set some sentinal values in cases where insurance info is not found 
   * so the hold routine can detect problems.
   */

  update t1 
  set 
      t1.patInsuranceCarrierID              = isnull(pic_1_2.carrierID,-1)             /* -1 if not found.  We will check for -1 carrier code in hold */
    , t1.patInsuranceMemberID               = trim(isnull(pic_1_2.beneficiaryID,''))    
  	, t1.carrierFound                       = isnull(pic_1_2.carrierFound,0)
	, t1.carrierRegisterWithTPA             = isnull(pic_1_2.cybhiRegisterPatInsuranceInfoWithTPA,1)
	, t1.carrierRegisterWithTPAHasEndDate   = isnull(pic_1_2.cybhiRegisterPatInsuranceInfoWithTPAHasEndDate,0)
	, t1.carrierRegisterWithTPAEndDate      = pic_1_2.cybhiRegisterPatInsuranceInfoWithTPAHasEndDate
    , t1.dos                                = convert(datetime,t2.dos)
	, t1.carrierPcCode                      = convert(varchar(50),pic_1_2.ohcCode)

  from @possibleClaims  as t1
  join dbo.CYBHI_CLAIMS as t2 on t2.id = t1.claimID

  outer apply (

    select top 1
      
	    pic_1_1.beneficiaryID
      , carrierID = ic.id
	  , carrierFound = 1
	  , ic.cybhiRegisterPatInsuranceInfoWithTPA
	  , ic.cybhiRegisterPatInsuranceInfoWithTPAHasEndDate
	  , ic.cybhiRegisterPatInsuranceInfoWithTPAEndDate
	  , ic.ohcCode
    from dbo.PATIENT_INSURANCE_CARRIERS as pic_1_1
    join dbo.INSURANCE_CARRIERS         as ic      on ic.id = pic_1_1.insuranceCarrierID
    where (
          ((pic_1_1.clientID = t2.clientID) and (pic_1_1.patID = t2.patID) and (pic_1_1.id > 0)) /* Index: CLIENT_PAT_IDX*/
      and (pic_1_1.active           = 1)
	  and (pic_1_1.expiredOrInvalid = 0)
	  and (ic.planSupportedByCYBHI  = 1)	
    )
  ) as pic_1_2
  option(recompile)

  /*---------------------------------------------------------------------------------------------------------*/

  /* Determine if we use the TPA ID as the insurance member id 
   * or we use the patients insurance member id directly
   */

  /* 1. No applicable insurance carrier row found for patient. We will force a hold later. */

  update t1 
  set 
    t1.useTpaIdAsInsuranceMemberID = 0 /* Setting to 0 if not found to force hold*/
  from @possibleClaims as t1
  where ( 
        (t1.useTpaIdAsInsuranceMemberID is null)   /* Have not determined state for this row */
    and (t1.carrierFound                     = 0)  /* All cases where we could not find carrier + member data */
  )
  option (recompile)  
  
  /* 2. TPA no longer requires registration for carrier and there is no cutover date. */

  update t1 
  set 
    t1.useTpaIdAsInsuranceMemberID = 0 /* Use insurance carrier member id */
  from @possibleClaims as t1
  where ( 
        (t1.useTpaIdAsInsuranceMemberID is null)   /* Have not determined state for this row */
    and (t1.carrierFound                     = 1)  /* Found carrier and membership data */
    and (t1.carrierRegisterWithTPA           = 0)  /* No registration required */
    and (t1.carrierRegisterWithTPAHasEndDate = 0)  /* No cutover date */
  )
  option (recompile)  

  /* 3. TPA requires registration for carrier up to a cutover date and then no registration required. 
   *    DOS is AFTER cutover date.
   */

  update t1 
  set 
    t1.useTpaIdAsInsuranceMemberID = 0 /* Use insurance carrier member id */
  from @possibleClaims as t1
  where ( 
        (t1.useTpaIdAsInsuranceMemberID is null)    /* Have not determined state for this row */
    and (t1.carrierFound                     = 1)   /* Found carrier and membership data */ 
    and (t1.carrierRegisterWithTPA           = 1)   /* Registration required */
    and (t1.carrierRegisterWithTPAHasEndDate = 1)   /* Up to cutover date*/
	and (t1.dos > t1.carrierRegisterWithTPAEndDate) /* Dos is after cutover date*/
  )
  option (recompile)  

  /* 4. TPA requires registration for carrier up to a cutover date and then no registration required. 
   *    DOS is on or before cutover date.
   */

  update t1 
  set 
    t1.useTpaIdAsInsuranceMemberID = 1 /* Use TPA ID */
  from @possibleClaims as t1
  where ( 
        (t1.useTpaIdAsInsuranceMemberID is null)     /* Have not determined state for this row */
    and (t1.carrierFound                     = 1)    /* Found carrier and membership data */ 
    and (t1.carrierRegisterWithTPA           = 1)    /* Registration required */
    and (t1.carrierRegisterWithTPAHasEndDate = 1)    /* Up to cutover date*/
	and (t1.dos <= t1.carrierRegisterWithTPAEndDate) /* Dos is on or before cutover date*/
  )
  option (recompile)  

  /* 5. TPA requires registration for carrier and there is no cutover date.   
   */

  update t1 
  set 
    t1.useTpaIdAsInsuranceMemberID = 1 /* Use TPA ID */
  from @possibleClaims as t1
  where ( 
        (t1.useTpaIdAsInsuranceMemberID is null)     /* Have not determined state for this row */
    and (t1.carrierFound                     = 1)    /* Found carrier and membership data */ 
    and (t1.carrierRegisterWithTPA           = 1)    /* Registration required */
    and (t1.carrierRegisterWithTPAHasEndDate = 0)    /* No cutover date */	
  )
  option (recompile)  
  
  /* 6. Anything left over.  Force a hold */  
  
  update t1 
  set 
    t1.useTpaIdAsInsuranceMemberID = 0 /* Setting to 0 if not found to force hold*/
  from @possibleClaims as t1
  where ( 
        (t1.useTpaIdAsInsuranceMemberID is null)   /* Have not determined state for this row */
  )
  option (recompile)  
  
  /*---------------------------------------------------------------------------------------------------------*/

  /* Get tpa id for patient for the cases where we need to use the tpa id as the member id in claiming. */

  update t1
    set t1.patInsuranceMemberID = pap.cybhiTpaID
  from @possibleClaims      as t1
  join dbo.CYBHI_CLAIMS     as t2  on t2.id          = t1.claimID
  join dbo.PATIENTS_Patient as pap on pap.PATIENT_ID = t2.patID
  where 
    (t1.useTpaIdAsInsuranceMemberID = 1)
  option(recompile)

  /*---------------------------------------------------------------------------------------------------------*/

  /* Save all possible claims.  We will apply holds later.  Also generate reference id we will
   * use in 837.  Max chars for referenceID is 20.
   */

  insert into dbo.CYBHI_CLAIM_TRANSMISSION_CLAIMS (      
      transmissionID              
	, svcRecID                         
    , claimID  
	, referenceID                        
	, claimHeld
	, siteID
	, useTpaIdAsInsuranceMemberID
	, patInsuranceCarrierID
	, patInsuranceMemberID
	, patInsuranceCarrierPcCode
  )
  select
      transmissionID = @transmissionID
	, t1.svcRecID
	, t1.claimID
	, referenceID = '9A7' + dbo.bigint_2_hexstr(@transmissionID, 7) + dbo.bigint_2_hexstr(t1.svcRecID,10) 
    , claimHeld = 0
	, t1.siteID
    , t1.useTpaIdAsInsuranceMemberID
	, t1.patInsuranceCarrierID
	, t1.patInsuranceMemberID
	, patInsuranceCarrierPcCode = t1.carrierPcCode
  from @possibleClaims  as t1
  option(recompile)
  
  /*---------------------------------------------------------------------------------------------------------*/

  return(0)

END
GO
