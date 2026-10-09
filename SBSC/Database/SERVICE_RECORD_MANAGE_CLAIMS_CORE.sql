USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_RECORD_MANAGE_CLAIMS_CORE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.SERVICE_RECORD_MANAGE_CLAIMS_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[SERVICE_RECORD_MANAGE_CLAIMS_CORE] (
    @svcRecID        bigint
  , @saveType        int
  , @today           datetime
  , @batchNum        nchar(10)    
  , @papClmNum       nchar(35)
  , @updateState     smallint
  , @recordClaim     bit    
)
as    
begin     
    
/***************************************************************************    
 * SERVICE_RECORD_MANAGE_CLAIMS_CORE */    
/**    
 *
 * NOTE: You MUST call this sproc within the context of a transaction from
 *       another sproc.  Do not use this sproc directly!
 *
 *    
 * @param   svcRecID        The record id of the service record
 * @param   updateState     Service record update state
 * @param   recordClaim     Record claim flag
 * @param   today           Current date/time  
 ***************************************************************************/         
     
/*####################################################################
  # Init
  ####################################################################*/     

set NOCOUNT ON    
 
declare @clientID         bigint
declare @userID           bigint
declare @created          date
declare @lastModified     date
declare @groupID          bigint
declare @groupIDRept      bigint
declare @siteID           bigint
declare @svcType          int
declare @planType         int
declare @dos              date
declare @pracID           bigint
declare @patID            bigint
declare @nameID           bigint
declare @orpPracID        bigint
declare @svcDetFlag1      bit
declare @svcDetFlag2      bit
declare @svcDetFlag3      bit
declare @svcDetFlag4      bit
declare @numMins          int
declare @numTrips         int
declare @numMiles         as decimal(7,1) 
declare @claimID1         bigint
declare @claimID2         bigint
declare @claimID3         bigint
declare @claimID4         bigint
declare @firstIdx         int
declare @lastIdx          int
declare @currIdx          int
declare @billingProgramID tinyint

declare @claimsData as table (
    IDX                       int identity(1,1)
   ,CLAIM_NUM                 int
   ,PROCEDURE_ID              bigint
   ,PROCEDURE_PROC_MOD_COMBO  varchar(100)
   ,NUM_UNITS                 int
)

/*####################################################################
  # Retrieve service record
  ####################################################################*/     

select top 1
  
    @clientID     = sr.clientID
  , @userID       = sr.userID
  , @created      = sr.created
  , @lastModified = sr.lastmodified
  , @groupID      = sr.groupID
  , @siteID       = sr.siteID
  , @svcType      = sr.svcType
  , @planType     = sr.planType
  , @dos          = sr.dos
  , @pracID       = sr.pracID
  , @patID        = sr.patID
  , @nameID       = sr.nameID 
  , @orpPracID    = sr.orpPracID  
  , @svcDetFlag1  = sr.svcDetFlag1 
  , @svcDetFlag2  = sr.svcDetFlag2 
  , @svcDetFlag3  = sr.svcDetFlag3 
  , @svcDetFlag4  = sr.svcDetFlag4 
  , @numMins      = sr.numMins
  , @numTrips     = dbo.CALC_TOTAL_TRIPS_8 ( sr.trip1Start
                                           , sr.trip1End
                                           , sr.trip2Start
                                           , sr.trip2End
                                           , sr.trip3Start
                                           , sr.trip3End
                                           , sr.trip4Start
                                           , sr.trip4End )
 
  , @numMiles    = dbo.CALC_TOTAL_MILES_8 ( sr.trip1Start
                                          , sr.trip1End
                                          , sr.trip2Start
                                          , sr.trip2End
                                          , sr.trip3Start
                                          , sr.trip3End
                                          , sr.trip4Start
                                          , sr.trip4End )
        
  , @claimID1 = sr.claimID1
  , @claimID2 = sr.claimID2
  , @claimID3 = sr.claimID3
  , @claimID4 = sr.claimID4

  , @billingProgramID = sr.billingProgramID

from dbo.SERVICE_RECORDS as sr 
where (sr.id = @svcRecID)
 
/*####################################################################
  # Delete previous service record and claim records 
  # for this service record (if any) for all billing programs
  ####################################################################*/     

if ((@saveType = dbo.CONST_SAVE_TYPE_EDIT()) or (@saveType = dbo.CONST_SAVE_TYPE_DELETE()))
begin
  
  /*||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    ||
    ||                      LEA BOP Billing Program               
    ||
    |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*/

  delete cc
  from dbo.SERVICE_RECORD_CLAIMS  as src
  join dbo.CLAIM_Claim            as cc on cc.CLAIM_ID = src.claimID
  where 
	(src.svcRecID = @svcRecID)

  delete dbo.SERVICE_RECORD_CLAIMS where (svcRecID = @svcRecID) 
  
  /*||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    ||
    ||                      CYBHI Billing Program               
    ||
    |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*/

    
  delete cc
  from dbo.CYBHI_SERVICE_RECORD_CLAIMS as src
  join dbo.CYBHI_CLAIMS                as cc on cc.id = src.claimID
  where 
	(src.svcRecID = @svcRecID)

  delete dbo.CYBHI_SERVICE_RECORD_CLAIMS where (svcRecID = @svcRecID) 
    
end /* Edit or Delete */

set @claimID1 = null
set @claimID2 = null
set @claimID3 = null
set @claimID4 = null

/*####################################################################
  # Optionally create new claim records and service record claim records
  ####################################################################*/     

if ((@recordClaim = 1) and ((@saveType = dbo.CONST_SAVE_TYPE_NEW()) or (@saveType = dbo.CONST_SAVE_TYPE_EDIT())))
begin

  /*============================================================
   * Retrieve reporting group for practitioner (if any)
   *============================================================*/  

  select top 1
    @groupIDRept = pg.GROUP_ID     
  from dbo.PRACTITIONER_GROUPS as pg 
  join dbo.GROUP_Group         as gr on gr.GROUP_ID = pg.GROUP_ID 
  where (
        (pg.PRACTITIONER_ID = @pracID )
    and (gr.GROUP_TYPE      = dbo.CONST_PRAC_GROUP_REPT())
  )
      
  /*============================================================
   * Retrieve claims data from given service data 
   *============================================================*/  

  insert into @claimsData (
      CLAIM_NUM      
    , PROCEDURE_ID  
    , PROCEDURE_PROC_MOD_COMBO 
    , NUM_UNITS
  )
  select     
	  cd.CLAIM_NUM      
    , cd.PROCEDURE_ID  
    , cd.PROCEDURE_PROC_MOD_COMBO 
    , cd.NUM_UNITS
  from dbo.SERVICE_DATA_TO_CLAIMS_DATA (
      @clientID
    , @groupID
    , @planType
    , @dos
    , @nameID
    , @svcDetFlag1 
    , @svcDetFlag2
    , @svcDetFlag3
    , @svcDetFlag4
    , @numMins
    , @numTrips
    , @numMiles 
	, @billingProgramID
  ) as cd
       
  /*============================================================
   * Get min and max number of claim records we will be creating
   * from results. 
   *============================================================*/  

  select @firstIdx = MIN(idx) from @claimsData
  select @lastIdx  = MAX(idx) from @claimsData
  set    @currIdx  = @firstIdx

  /*============================================================
   * Iterate through results and create claim and service record
   * claim records
   *============================================================*/  

  while (@currIdx <= @lastIdx)
  begin
  
    declare @claimID      as bigint  = null
    declare @procID       as bigint  = null
    declare @claimNum     as int     = null
    declare @numUnits     as int     = null
    declare @claimPurpose as int     = null
	declare @svcFee       as money   = null
	declare @claimAmount  as money   = null

    /*-------------------------------    
     * Get claim data record
     *------------------------------*/  

    select top 1
        @claimNum = CLAIM_NUM
      , @procID   = PROCEDURE_ID 
      , @numUnits = NUM_UNITS
    from @claimsData 
    where 
     (IDX = @currIdx)
    
    /*||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      ||
      ||                      LEA BOP Billing Program               
      ||
      |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*/

	if (@billingProgramID = 1)
	begin

      /*-------------------------------    
       * Create claim record
       *------------------------------*/  
    
      insert into dbo.CLAIM_Claim (
        PATIENT_ID
      , PROCEDURE_ID
      , PRACTITIONER_ID
      , USER_ID
      , CLIENT_ID
      , SITE_ID
      , STATUS
      , LINE_NUMBER
      , SERVICE_DATE
      , SERVICE_UNITS
      , ENTRY_DATE
      , LAST_UPDATED
      , BATCH_NUMBER
      , ELIGIBILE
      , ELIGIBILITY_CONFIRMED
      , PAPER_CLAIM_NUMBER
      , GROUP_ID
      , GROUP_ID_REPT
      , ORP_PRACTITIONER_ID
      )    
       
      values (
  
        @patID
      , @procID
      , @pracID
      , @userID
      , @clientID
      , @siteID
      , '1'
      , @claimNum
      , @dos
      , @numUnits
      , @today
      , @today
      , @batchNum
      , 0
      , 0
      , @papClmNum
      , @groupID
      , @groupIDRept
      , @orpPracID
      )
    
      /*-------------------------------    
       * Get new claim id
       *------------------------------*/  

      set @claimID = SCOPE_IDENTITY()
  
      /*-------------------------------    
       * Get claim 1 data
       *------------------------------*/  
    
      if (@claimNum = 1) 
      begin
        set @claimID1     = @claimID
        set @claimPurpose = dbo.CONST_CLAIM_PURPOSE_LINE_1()
      end
   
      /*-------------------------------    
       * Get claim 2 data
       *------------------------------*/  

      if (@claimNum = 2) 
      begin
        set @claimID2     = @claimID
        set @claimPurpose = dbo.CONST_CLAIM_PURPOSE_LINE_2()
      end
    
      /*-------------------------------    
       * Get claim 3 data
       *------------------------------*/  
  
      if (@claimNum = 3) 
      begin
        set @claimID3     = @claimID
        set @claimPurpose = dbo.CONST_CLAIM_PURPOSE_LINE_3()
      end
    
      /*-------------------------------    
       * Get claim 4 data
       *------------------------------*/  

      if (@claimNum = 4) 
      begin
        set @claimID4     = @claimID
        set @claimPurpose = dbo.CONST_CLAIM_PURPOSE_LINE_4()
      end
  
     /*-------------------------------    
      * Create service record claim
      * record
      *------------------------------*/  

      insert into dbo.SERVICE_RECORD_CLAIMS (
        svcRecID
      , claimID
      , purpose )     
      values (
        @svcRecID
      , @claimID
      , @claimPurpose )    
    
    end /* LEA BOP billing program */
	
    /*||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      ||
      ||                      CYBHI Billing Program               
      ||
      |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*/

	else if (@billingProgramID = 2)
	begin
	 
	 select top 1
	   @svcFee = cp.SERVICE_FEE
	 from dbo.CLAIM_Procedures as cp
	 where 
	   (cp.PROCEDURE_ID = @procID)
	 
	 set @claimAmount = (@svcFee * @numUnits)

	 /*-------------------------------    
       * Create claim record
       *------------------------------*/  
    
      insert into dbo.CYBHI_Claims (
          clientID
        , patID          
	    , renderingPracID
        , dos
        , procedureID
        , numUnits
        , claimLineNum         
		, txStatusCode 
        , amountClaimed
		, created  
	    , createdBy
		, active
      )              
      values (
          @clientID
        , @patID
	    , @pracID
		, @dos
	    , @procID
		, @numUnits
		, @claimNum	  		
		, 1          /* status code - pending */
	    , @claimAmount
		, @today
		, @userID
		, 1          /* active*/
      )
	  set @claimID = SCOPE_IDENTITY()

      insert into dbo.CYBHI_SERVICE_RECORD_CLAIMS (
	      svcRecID
		, claimID		
	  )
	  values (
	      @svcRecID
	    , @claimID
	  )

	
	end /* CYBHI billing program*/

	/*-------------------------------    
     * Get index for next claim data
     * record (if any)
     *------------------------------*/  

    set @currIdx = @currIdx + 1
  
  end /* While */
end  /* New or Edit and Record Claim = 1 */
 
/*####################################################################
  # Update service record 
  ####################################################################*/     

update dbo.SERVICE_RECORDS
set 
    claimID1     = @claimID1
  , claimID2     = @claimID2
  , claimID3     = @claimID3
  , claimID4     = @claimID4
  , lastmodified = @today
  , state        = @updateState
where (id = @svcRecID)    

return (0)

end
go

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[SERVICE_RECORD_MANAGE_CLAIMS_CORE] TO [webuser]
GO
