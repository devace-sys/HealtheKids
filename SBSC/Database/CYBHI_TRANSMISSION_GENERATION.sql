use SPEDMON 
GO

/*---------------------------------------------------------------------------------------------------------*/

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].CYBHI_TRANSMISSION_GENERATION') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
begin
  drop PROCEDURE dbo.CYBHI_TRANSMISSION_GENERATION
end
GO

/*---------------------------------------------------------------------------------------------------------*/

CREATE PROCEDURE dbo.CYBHI_TRANSMISSION_GENERATION (
	  @clientID           bigint	    = -1
	, @path               varchar(255)	
	, @userID	          bigint        = -1
	, @oldestDos          date
	, @latestDos          date
    , @possibleClaimCount int           output
	, @claimHoldCount     int           output
    , @claimReleaseCount  int           output
	, @fileName           varchar(100)  output			
	, @transmissionID     bigint        output
	, @generationOK       bit           output
	, @fileGenerated      bit           output
	, @svcRecHoldCount    int           output
	, @svcRecReleaseCount int           output
	, @amountHeld         money         output
	, @amountReleased     money         output
)
AS
BEGIN
  
set nocount on

/*---------------------------------------------------------------------------------------------------------*/

/* Init output parameters */

set @possibleClaimCount   = -1
set @claimHoldCount       = -1
set @claimReleaseCount    = -1
set @fileName             = ''
set @transmissionID       = -1
set @generationOK         = 0
set @fileGenerated        = 0
set @svcRecHoldCount      = 0
set @svcRecReleaseCount   = 0
set @amountHeld           = 0
set @amountReleased       = 0

/*---------------------------------------------------------------------------------------------------------*/

/* Declare locals */

declare @tranOpen              as bit            = 0
declare @holdForDays           as int            = 0
declare @clientName            as nvarchar(256)  = N''
declare @cybhiClientName       as nvarchar(100)  = N''
declare @cybhiNPI              as nchar(10)      = N''
declare @cybhiTaxID            as nchar(10)      = N''
declare @cid                   as bigint         = null
declare @shortName             as varchar(100)   = ''
declare @cybhi                 as bit            = 0
declare @cybhiTpaApproved      as bit            = 0
declare @cybhiTpaApprovedOn    as date           = null
declare @cybhiTpaID            as varchar(256)   = ''
declare @cybhiGenerate837      as bit            = 0
declare @distAddressOK         as bit            = 0
declare @todayDateOnly         as date           = null
declare @claimsAgeOutAfterDate as date           = null
declare @oldestDosAllowed      as date           = null
declare @checkServiceDateRange as bit            = 0
declare @msgStr                as varchar(512)   = ''

declare @consortium              as bit            = 0
declare @consortiumLeadClientID  as bigint         = null
declare @consortiumLead          as bit            = 0
declare @billingClientID         as bigint         = 0


begin try

  /*---------------------------------------------------------------------------------------------------------*/

  exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Transmission Generation - Init'

  set @tranOpen              = 0
  set @todayDateOnly         = convert(date,getdate())
  set @claimsAgeOutAfterDate = dateadd(day,1,(EOMONTH(dateadd(month,-13,@todayDateOnly))))
  set @checkServiceDateRange = 0

  /*---------------------------------------------------------------------------------------------------------*/

  exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Transmission Generation - Get claiming client data'
  
  set @cid = null
    
  select top 1
      @cid                     = clc.CLIENT_ID
    , @clientName              = trim(left(clc.CLIENT_NAME,256))
	, @shortName               = clc.ShortName
    , @cybhi                   = clc.cybhi     
	, @cybhiGenerate837        = clc.cybhiGenerate837
    , @holdForDays             = clc.cybhiNumDaysToHoldEnteredClaims
	, @consortium              = clc.cybhiConsortiumBilling
	, @consortiumLeadClientID  = isnull(clc.cybhiConsortiumLeadClientID,0)  
  from dbo.CLIENTS_Client as clc
  where 
    (clc.CLIENT_ID = @clientID)
  option(recompile)
  
  /*---------------------------------------------------------------------------------------------------------*/

  if (@cid is null) 
  begin
    exec dbo.PRINT_STATUS_MESSAGE 'Claiming client not found'
	set @generationOK  = 0
    set @fileGenerated = 0
    return (0)
  end
 
  /*---------------------------------------------------------------------------------------------------------*/

  set @msgStr = 'Claiming client : ' + @clientName
  exec dbo.PRINT_STATUS_MESSAGE @msgStr
  
  /*---------------------------------------------------------------------------------------------------------*/
  
  exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Transmission Generation - Verifying claiming client data'
  
  /*---------------------------------------------------------------------------------------------------------*/
  
  if (@cybhi= 0) 
  begin
    exec dbo.PRINT_STATUS_MESSAGE 'Claiming client not a CYBHI client'
    set @generationOK  = 0
	set @fileGenerated = 0
	return (0)
  end

  /*---------------------------------------------------------------------------------------------------------*/
  
  if (@cybhiGenerate837 = 0)
  begin
    exec dbo.PRINT_STATUS_MESSAGE 'Claiming client is flagged to not generate 837'
	set @generationOK  = 0
    set @fileGenerated = 0
	return (0)
  end
  
  /*---------------------------------------------------------------------------------------------------------*/

  exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Transmission Generation - Determine billing client'
  
  set @billingClientID = @clientID

  if (@consortium = 1)
  begin
    exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Transmission Generation - Consortium billing'
   
    if (@consortiumLeadClientID = 0) 
    begin  
	  exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Transmission Generation - Consortium billing LEAD CLIENT'
	  set @consortiumLead  = 1
      set @billingClientID = @clientID   
	end /* Lead client */

	else
	begin
	  exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Transmission Generation - Consortium billing subordinate client'
	  set @consortiumLead  = 0
	  set @billingClientID = @consortiumLeadClientID
	end /* Not lead */

  end /* consortium */

  else
  begin
    exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Transmission Generation - Stand alone billing'
	set @consortiumLead  = 0
	set @billingClientID = @clientID
  end /* stand alone */

  /*---------------------------------------------------------------------------------------------------------*/
  
  /* TODO: Remove once consortium subordinate clients have claims */

  if (@consortium = 1)
  begin
    if (@consortiumLead = 0)
	begin
	  exec dbo.PRINT_STATUS_MESSAGE 'Consortium subordinate client claims not supported yet due to lack of testing data'
  	  set @generationOK  = 0
      set @fileGenerated = 0
      return (0)
	end
  end

  /*---------------------------------------------------------------------------------------------------------*/
  
  exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Transmission Generation - Get billing client info'
  
  set @cid = null

  select top 1
      @cid                     = clc.CLIENT_ID
	, @clientName              = trim(left(clc.CLIENT_NAME,256))
	, @cybhi                   = clc.cybhi
	, @cybhiTpaApproved        = clc.cybhiTpaApproved
	, @cybhiTpaApprovedOn      = clc.cybhiTpaApprovedOn
    , @cybhiTpaID              = clc.cybhiTpaID
    , @cybhiClientName         = trim(isnull(clc.cybhiClientName, N''))
	, @cybhiNPI                = trim(isnull(clc.cybhiNPI,        N''))
	, @cybhiTaxID              = trim(isnull(clc.cybhiTaxID,      N''))
  from dbo.CLIENTS_Client as clc
  where 
    (clc.CLIENT_ID = @billingClientID)
  option(recompile)

  /*---------------------------------------------------------------------------------------------------------*/

  if (@cid is null) 
  begin
    exec dbo.PRINT_STATUS_MESSAGE 'Billing client not found'
	set @generationOK  = 0
    set @fileGenerated = 0
    return (0)
  end

  /*---------------------------------------------------------------------------------------------------------*/
  
  set @msgStr = 'Billing client : ' + @clientName
  exec dbo.PRINT_STATUS_MESSAGE @msgStr

  /*---------------------------------------------------------------------------------------------------------*/
  
  if (@cybhi= 0) 
  begin
    exec dbo.PRINT_STATUS_MESSAGE 'Billing client not a CYBHI client'
    set @generationOK  = 0
	set @fileGenerated = 0
	return (0)
  end

  /*---------------------------------------------------------------------------------------------------------*/
    
  if (len(@cybhiClientName) = 0)
  begin
    exec dbo.PRINT_STATUS_MESSAGE 'Billing client does not have a CYBHI provider Name'
	set @generationOK  = 0
	set @fileGenerated = 0
    return(0)
  end
  
  /*---------------------------------------------------------------------------------------------------------*/

  if (len(@cybhiNPI) = 0)
  begin
    exec dbo.PRINT_STATUS_MESSAGE 'Billing client does not have a CYBHI NPI'
	set @generationOK  = 0
	set @fileGenerated = 0
    return (0)
  end

  /*---------------------------------------------------------------------------------------------------------*/

  if (len(@cybhiTaxID) = 0)
  begin
    exec dbo.PRINT_STATUS_MESSAGE 'Billing client does not have a CYBHI tax ID'
	set @generationOK  = 0
	set @fileGenerated = 0
    return (0)
  end

  /*---------------------------------------------------------------------------------------------------------*/

  if (@cybhiTpaApproved = 0) 
  begin
    exec dbo.PRINT_STATUS_MESSAGE 'Billing client is not approved by TPA'
	set @generationOK  = 0
	set @fileGenerated = 0
	return (0)
  end

  /*---------------------------------------------------------------------------------------------------------*/
  
  if (trim(isnull(@cybhiTpaID,'')) = '')
  begin
    exec dbo.PRINT_STATUS_MESSAGE 'Billing client does not have a TPA ID'
	set @generationOK  = 0
	set @fileGenerated = 0
	return (0)
  end

  /*---------------------------------------------------------------------------------------------------------*/

  if (@cybhiTpaApprovedOn is null)
  begin
    exec dbo.PRINT_STATUS_MESSAGE 'Billing client does not have a TPA approved on date'
	set @generationOK  = 0
    set @fileGenerated = 0
	return (0)
  end

  /*---------------------------------------------------------------------------------------------------------*/

  /* Get addresss data and check for incomplete address for claiming client*/

  ;
  with
  cte_p1
  as
  (
    select top 1 charsToRemove = '~*:^'
  )
  ,
  cte_p2
  as
  (
    select top 1 
        clientAddress1  = dbo.STRING_REMOVE_CHARS((trim(UPPER(LEFT(REPLACE(isnull(cla2.cybhiAddress1,''),'.',''),26)))),p1.charsToRemove,null)
      , clientCity      = dbo.STRING_REMOVE_CHARS((trim(UPPER(LEFT(cla2.cybhiCity, 18)))),p1.charsToRemove,null)
      , clientState     = trim(upper(cla2.cybhiState))
      , clientZip       = trim(upper(LEFT(isnull(cla2.cybhiZip5,'') + isnull(cla2.cybhiZip4,''),9)))
    from cte_p1 as p1
  
    cross apply (
      select top 1 
	    cla1.* 
      from dbo.CLIENTS_Client as cla1 
      where 
        (cla1.CLIENT_ID = @clientID)
    ) as cla2
  )
  ,
  cte_p3
  as
  (
    select top 1 
        p2.*
      , dataComplete = convert (bit, (case 
        when (p2.clientAddress1  = '')  then 0
	    when (p2.clientCity = '')       then 0
	    when (p2.clientState    = '')   then 0
	    when (len(p2.clientZip) != 9)   then 0
	    else 1 end ))
    from cte_p2 as p2
  )
  select top 1 
    @distAddressOK = isnull(p3.dataComplete,0)
  from cte_p3 as p3
  option(recompile)

  /* Incomplete addresss, exit */

  if (@distAddressOK = 0)
  begin
    exec dbo.PRINT_STATUS_MESSAGE 'Claiming client does not have a complete CYBHI address'
	set @generationOK  = 0
	set @fileGenerated = 0
	return (0)
  end

  
  /* Get addresss data and check for incomplete address for billing client*/

  ;
  with
  cte_p1
  as
  (
    select top 1 charsToRemove = '~*:^'
  )
  ,
  cte_p2
  as
  (
    select top 1 
        clientAddress1  = dbo.STRING_REMOVE_CHARS((trim(UPPER(LEFT(REPLACE(isnull(cla2.cybhiAddress1,''),'.',''),26)))),p1.charsToRemove,null)
      , clientCity      = dbo.STRING_REMOVE_CHARS((trim(UPPER(LEFT(cla2.cybhiCity, 18)))),p1.charsToRemove,null)
      , clientState     = trim(upper(cla2.cybhiState))
      , clientZip       = trim(upper(LEFT(isnull(cla2.cybhiZip5,'') + isnull(cla2.cybhiZip4,''),9)))
    from cte_p1 as p1
  
    cross apply (
      select top 1 
	    cla1.* 
      from dbo.CLIENTS_Client as cla1 
      where 
        (cla1.CLIENT_ID = @billingClientID)
    ) as cla2
  )
  ,
  cte_p3
  as
  (
    select top 1 
        p2.*
      , dataComplete = convert (bit, (case 
        when (p2.clientAddress1  = '')  then 0
	    when (p2.clientCity = '')       then 0
	    when (p2.clientState    = '')   then 0
	    when (len(p2.clientZip) != 9)   then 0
	    else 1 end ))
    from cte_p2 as p2
  )
  select top 1 
    @distAddressOK = isnull(p3.dataComplete,0)
  from cte_p3 as p3
  option(recompile)

  /* Incomplete addresss, exit */

  if (@distAddressOK = 0)
  begin
    exec dbo.PRINT_STATUS_MESSAGE 'Billing client does not have a complete CYBHI address'
	set @generationOK  = 0
	set @fileGenerated = 0
	return (0)
  end

  /*---------------------------------------------------------------------------------------------------------*/

  exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Transmission Generation - Client data seems OK'
  
  /*---------------------------------------------------------------------------------------------------------*/

  exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Transmission Generation - Determine oldest possible date of service'    
  
  set @msgStr = 'Claims age out after date : ' + convert(varchar,@claimsAgeOutAfterDate,101)
  exec dbo.PRINT_STATUS_MESSAGE @msgStr

  set @msgStr = 'TPA approved on date : ' + convert(varchar,@cybhiTpaApprovedOn,101)
  exec dbo.PRINT_STATUS_MESSAGE @msgStr

  set @oldestDosAllowed = iif ((@cybhiTpaApprovedOn >= @claimsAgeOutAfterDate),@cybhiTpaApprovedOn,@claimsAgeOutAfterDate)

  set @msgStr = 'Oldest DOS allowed date : ' + convert(varchar,@oldestDosAllowed,101)
  exec dbo.PRINT_STATUS_MESSAGE @msgStr

  /*---------------------------------------------------------------------------------------------------------*/

  exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Transmission Generation - Determine service data range'    

  /* Oldest dos not provided - use default */

  if (@oldestDos is null) 
  begin
    set @oldestDos = @oldestDosAllowed  
    set @msgStr = 'Using default for oldest dos : ' + convert(varchar,@oldestDos,101)
    exec dbo.PRINT_STATUS_MESSAGE @msgStr
  end

  /* Oldest dos provided - Check it over */

  else
  begin
    set @checkServiceDateRange = 1
    set @msgStr = 'Value provided for oldest dos : ' + convert(varchar,@oldestDos,101)
    exec dbo.PRINT_STATUS_MESSAGE @msgStr
	if (@oldestDos not between @oldestDosAllowed and @todayDateOnly)
	begin
	  exec dbo.PRINT_STATUS_MESSAGE 'Oldest dos is outside allowed range'
	  set @generationOK  = 0
	  set @fileGenerated = 0
  	  return (0)
	end
  end

  /* Latest dos not provided, use default */

  if (@latestDos is null) 
  begin
    set @latestDos = @todayDateOnly
    set @msgStr = 'Using default for latest dos : ' + convert(varchar,@latestDos,101)
    exec dbo.PRINT_STATUS_MESSAGE @msgStr
  end

  /* Latest dos provided, check it over */
  
  else
  begin
	set @checkServiceDateRange = 1
	set @msgStr = 'Value provided for latest dos : ' + convert(varchar,@latestDos,101)
	exec dbo.PRINT_STATUS_MESSAGE @msgStr
    if (@latestDos not between @oldestDosAllowed and @todayDateOnly)
	begin
	  exec dbo.PRINT_STATUS_MESSAGE 'Latest dos is outside allowed range'
	  set @generationOK  = 0
	  set @fileGenerated = 0
  	  return (0)
	end  
  end

  /*---------------------------------------------------------------------------------------------------------*/
    
  set @msgStr = 'Service date range is ' + convert(varchar,@oldestDos,101) + ' to ' + convert(varchar,@latestDos,101)
  exec dbo.PRINT_STATUS_MESSAGE @msgStr
     
  /*---------------------------------------------------------------------------------------------------------*/

  if (@checkServiceDateRange = 1)
  begin
    if (@oldestDos > @latestDos)
    begin
      exec dbo.PRINT_STATUS_MESSAGE 'Service date range provided is invalid'
	  set @generationOK  = 0
	  set @fileGenerated = 0
  	  return (0)
    end
  end
  
  /*---------------------------------------------------------------------------------------------------------*/

  begin transaction
  set @tranOpen = 1
 
  /*---------------------------------------------------------------------------------------------------------*/

  exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Transmission Generation - Create record set'
 
  exec dbo.CYBHI_TRANSMISSION_GENERATION_CREATE_TRANSMISSION_RECORD_SET 
	    @clientID
	  , @billingClientID  
  	  , @consortium       
	  , @oldestDos 
	  , @latestDos
      , @shortName
	  , @userID	
	  , @possibleClaimCount output
	  , @fileName           output
  	  , @transmissionID     output
 
  /*---------------------------------------------------------------------------------------------------------*/

  if (@possibleClaimCount = 0) 
  begin
    exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Transmission Generation - Nothing to claim.  Exiting.'
	commit transaction
	set @tranOpen      = 0
	set @generationOK  = 1
	set @fileGenerated = 0
 	return(0)
  end

  /*---------------------------------------------------------------------------------------------------------*/
  
  exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Transmission Generation - Assign ORP, Supervising, Rendering Pracs'
  exec dbo.CYBHI_CLAIMS_ASSIGN_ORP_SUPERVISING_RENDERING_PRACS @transmissionID

  /*---------------------------------------------------------------------------------------------------------*/

  exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Transmission Generation - Apply holds'
  exec dbo.CYBHI_TRANSMISSION_GENERATION_APPLY_HOLDS 
       @transmissionID
	 , @holdForDays 
	 , @todayDateOnly
     , @claimHoldCount    output
	 , @claimReleaseCount output

  /*---------------------------------------------------------------------------------------------------------*/
  
  if (@claimReleaseCount = 0) 
  begin
    exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Transmission Generation - Everything held.  Exiting.'
	commit transaction
	set @tranOpen      = 0
	set @generationOK  = 1
    set @fileGenerated = 0
	return(0)
  end

  /*---------------------------------------------------------------------------------------------------------*/

  exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Transmission Generation - Update service records and claims'  
  exec dbo.CYBHI_TRANSMISSION_GENERATION_UPDATE_SERVICE_RECORDS_AND_CLAIMS @transmissionID, @userID

  /*---------------------------------------------------------------------------------------------------------*/

  exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Transmission Generation - Create 837 file content'  
  exec dbo.CYBHI_TRANSMISSION_GENERATION_CREATE_837_FILE_CONTENT @transmissionID, @userID
  
  /*---------------------------------------------------------------------------------------------------------*/
    
  exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Transmission Generation - Write 837 file'    
  exec dbo.CYBHI_TRANSMISSION_GENERATION_WRITE_837_FILE @transmissionID, @path

  /*---------------------------------------------------------------------------------------------------------*/

  commit transaction

  set @fileGenerated = 1
  set @tranOpen      = 0
  
  /*---------------------------------------------------------------------------------------------------------*/

  exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Transmission Generation - Getting totals'    
      
  /* Held */
  
  select top 1 
      @svcRecHoldCount = t1.numSvcRecs
    , @amountHeld      = t1.amountClaimed 
  from dbo.CYBHI_TRANSMISSION_GET_AMOUNTS_DATA_CORE (@transmissionID , 1 /* Claim Held*/) as t1
  option(recompile)

  /* Released */

  select top 1 
      @svcRecReleaseCount = t1.numSvcRecs
    , @amountReleased     = t1.amountClaimed 
  from dbo.CYBHI_TRANSMISSION_GET_AMOUNTS_DATA_CORE (@transmissionID , 0 /* Claim Released */) as t1
  option(recompile)

  set @generationOK  = 1
  
  /*---------------------------------------------------------------------------------------------------------*/

end try  
begin catch
  
  if @tranOpen = 1
  begin
    rollback transaction
	set @tranOpen = 0
  end
  
  set @generationOK = 0

end catch  

/*---------------------------------------------------------------------------------------------------------*/

return(0)

/*---------------------------------------------------------------------------------------------------------*/

END
GO
