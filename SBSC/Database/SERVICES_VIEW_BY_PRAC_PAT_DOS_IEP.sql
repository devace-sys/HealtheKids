USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICES_VIEW_BY_PRAC_PAT_DOS_IEP') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SERVICES_VIEW_BY_PRAC_PAT_DOS_IEP
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
    
CREATE FUNCTION [dbo].[SERVICES_VIEW_BY_PRAC_PAT_DOS_IEP] (
   @clientID                 INT
 , @pracID                   INT     
 , @patID                    INT     
 , @dos                      DATETIME
 , @isiep                    BIT
 , @nameID                   INT    
 , @is22                     BIT    
 , @trnPrcNum                SMALLINT
 , @isSvcSel                 BIT 
 , @svcNamesListDataSourceID smallint
)

RETURNS 
@recs TABLE (  nameID    INT 
             , name      NVARCHAR(255)    
             , groupname NVARCHAR(max)
             , minUnits  INT     
             , maxUnits  INT     
             , svcType   INT     
             , planType  INT     
             , span2     BIT     
             , procID    INT
             , procName  NVARCHAR(50)
             , procCode  NCHAR(10)
             , procMod1  NCHAR(10)
             , procMod2  NCHAR(10)
             , procMod3  NCHAR(10)
             , procMod4  NCHAR(10)
             , clientID                  INT
             , groupID                   INT
             , groupBase                 nvarchar(max)
             , showOptions1              varchar(255)
             , showOptions2              varchar(255)
			 , showOptions3              varchar(255)
             , groupServiceClassNameID   bigint
             , groupServiceClassNameName varchar(1000)
             , svcMayBeBillableInFuture  bit
             , svcIsNeverBillable        bit
			 , isAutoSelectORPDocPossible bit
             , svcRenderedVia             varchar(100)

			 , svcPlanTypeName	          NVARCHAR(50)  
			 , svcTypeName                varchar(500)
	         , svcSubType1Name            varchar(500)
	         , svcSubType1IDStr           varchar(50)
	         , calpadsCodeName            varchar(256)
	         , calpadsCodeValueStr        varchar(50)
	         , selectionNameWithoutInPersonOrTelehealthText NVARCHAR(255)
			 , selectionForModalityFlags                    int
			 , selectionAltModalityNameID                   int 
             , serviceEntryOrpDocumentRequired              bit
) 
AS
BEGIN      
      
  DECLARE @plan             as INT    
  DECLARE @age              as INT    
  DECLARE @dob              as DATETIME    
  DECLARE @dateTest         as INT    
  DECLARE @billingProgramID as tinyint
  
  declare @participatesInLEABOP        as bit = 0
  declare @participatesInCYBHI         as bit = 0
  declare @participatesInRUHealth      as bit = 0
  declare @participatesInLEABOPNonSpEd as bit = 0
  declare @okToShowServicesForPlan     as bit = 0

  -- Inspect required parameters and return 0 records if one or more    
  -- of the parameters are not provided    
  
  IF @clientID IS NULL RETURN
  IF @pracID   IS NULL RETURN
  IF @patID    IS NULL RETURN
  IF @dos      IS NULL RETURN
    
  -- Retrieve patients date of birth and calculate their age at the    
  -- time of service    
  
  select top 1 
    @dob = DATE_OF_BIRTH 
  from dbo.PATIENTS_Patient 
  where 
   (PATIENT_ID = @patID)
      
  -- Compare date of service to dob    
  -- dob is subtracted from dos 
  -- if dob is later than dos a negative value is returned
      
  set @dateTest = DATEDIFF(day,@dob,@dos)
  if (@dateTest < 0) RETURN    
      
  -- If no list data source is provided then we assume the request is from
  -- a screen or other part of the system that does not have that data available
  -- so we look up what the source should be so we can provide backwards compatibility

  if (isnull(@svcNamesListDataSourceID,-1) = -1)
  begin
  
    -- IEP is definately required now.  If its not provided exit.

	IF (@isiep IS NULL) RETURN
    
	select top 1 
	    @svcNamesListDataSourceID = t1.id 
	  , @billingProgramID         = t1.billingProgramID  
	from dbo.CLAIM_Svc_Names_List_Data_Sources as t1
	where ( 
	         (t1.isIEPOrIFSP      = @isiep)
	     and (t1.billingProgramID = 1)	  
	)

  end
  
  -- Data source provided

  else
  begin
    
	-- We get the value of IEP and billing program from the data source

	select top 1 
	    @isiep            = t1.isIEPOrIFSP 
	  , @billingProgramID = t1.billingProgramID
	from dbo.CLAIM_Svc_Names_List_Data_Sources as t1
	where 
	  (t1.id = @svcNamesListDataSourceID)
  end

  -- Could not find it get out

  if (@billingProgramID is null) return

  -- Determine plan type

  select top 1 @plan = dbo.DOS_DOB_IEP_BILLING_PROGRAM_TO_PLAN_TYPE (@dos,@dob,@isiep,@billingProgramID)
              
  -- Determine if prac can see services for this plan type

  select top 1 
      @participatesInLEABOP        = prp.participatesInLEABOP
    , @participatesInCYBHI         = prp.participatesInCYBHI
    , @participatesInRUHealth      = prp.participatesInRUHealth
	, @participatesInLEABOPNonSpEd = prp.participatesInLEABOPNonSpEd
  from dbo.PRACTITIONER_Practitioner as prp
  where 
    (prp.PRACTITIONER_ID = @pracID)

  set @okToShowServicesForPlan = dbo.SERVICES_CAN_SHOW_FOR_PLAN_TYPE (@plan,@participatesInLEABOP,@participatesInLEABOPNonSpEd,@participatesInCYBHI, @participatesInRUHealth)
  
  --if (@okToShowServicesForPlan = 0) return

  -- Retrieve records     
                  
  insert into @recs (
               nameID   
             , name     
             , groupname 
             , minUnits  
             , maxUnits  
             , svcType   
             , planType  
             , span2     
             , procID    
             , procName  
             , procCode  
             , procMod1  
             , procMod2  
             , procMod3  
             , procMod4  
             , clientID                  
             , groupID                   
             , groupBase                 
             , showOptions1              
             , showOptions2              
			 , showOptions3              
             , groupServiceClassNameID   
             , groupServiceClassNameName 
             , svcMayBeBillableInFuture  
             , svcIsNeverBillable        
			 , isAutoSelectORPDocPossible 
             , svcRenderedVia 

			 , svcPlanTypeName
			 , svcTypeName    
	         , svcSubType1Name
	         , svcSubType1IDStr  
	         , calpadsCodeName  
	         , calpadsCodeValueStr 
			 , selectionNameWithoutInPersonOrTelehealthText
			 , selectionForModalityFlags
			 , selectionAltModalityNameID
			 , serviceEntryOrpDocumentRequired
	
  ) 
  select 
               t1.nameID   
             , t1.name     
             , t1.groupname 
             , t1.minUnits  
             , t1.maxUnits  
             , t1.svcType   
             , t1.planType  
             , t1.span2     
             , t1.procID    
             , t1.procName  
             , t1.procCode  
             , t1.procMod1  
             , t1.procMod2  
             , t1.procMod3  
             , t1.procMod4  
             , t1.clientID                  
             , t1.groupID                   
             , t1.groupBase                 
             , t1.showOptions1              
             , t1.showOptions2              
			 , t1.showOptions3              
             , t1.groupServiceClassNameID   
             , t1.groupServiceClassNameName 
             , t1.svcMayBeBillableInFuture  
             , t1.svcIsNeverBillable        
			 , t1.isAutoSelectORPDocPossible 
             , t1.svcRenderedVia 
			 , t1.svcPlanTypeName
			 , t1.svcTypeName    
	         , t1.svcSubType1Name
	         , t1.svcSubType1IDStr  
	         , t1.calpadsCodeName  
	         , t1.calpadsCodeValueStr 
			 , t1.selectionNameWithoutInPersonOrTelehealthText
			 , t1.selectionForModalityFlags
			 , t1.selectionAltModalityNameID
             , t1.serviceEntryOrpDocumentRequired
  from dbo.SERVICES_VIEW_BY_PRAC_PAT_PLAN ( 
      @clientID
    , @pracID
    , @patID
    , @dos
    , @plan
    , @nameID
    , @is22
    , @trnPrcNum
    , @isSvcSel ) as t1
    
  RETURN    
END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[SERVICES_VIEW_BY_PRAC_PAT_DOS_IEP] TO [webuser]
GO
