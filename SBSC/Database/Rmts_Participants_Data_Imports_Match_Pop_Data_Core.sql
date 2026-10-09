USE spedmon
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Rmts_Participants_Data_Imports_Match_Pop_Data_Core') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.Rmts_Participants_Data_Imports_Match_Pop_Data_Core
GO



/*-------------------------------
 * Create new
 *------------------------------*/

CREATE PROCEDURE [dbo].[Rmts_Participants_Data_Imports_Match_Pop_Data_Core] (
    @userID            bigint
  , @userGroup         int
  , @userRank          int
  , @clientID          bigint
  , @rmtsDataImportID  bigint
  , @validateRec       bit
  , @importResultsJSON varchar(max) output
)    
AS 

BEGIN

set nocount on

declare @startProcessingDateTime as datetime
declare @endProcessingDateTime   as datetime
declare @numPracMatches          as bigint
declare @fyQuarterID             as bigint
declare @fyQuarterStartDate      as date
declare @fyQuarterEndDate        as date
declare @numOfExistingPracRecs   as int	= 0
declare @numOfNewPracRecs		 as int	= 0
declare @rosterID                as bigint

/*-----------------------------------------------------
 * Loop parameters
 *----------------------------------------------------*/

declare @i int
declare @processingRmtsPracID                       bigint
	  , @processingRmtsRosterID					    bigint
	  , @processingRmtsStartDate					date
	  , @processingRmtsEndDate					    date
	  , @processingRmtsReasonForStartDateChangeCode int
	  , @processingRmtsReasonForEndDateChangeCode	int
	  , @processingRmtsHasServiceRecords			bit
	  , @processingRmtsHasReimbursement			    bit      
	  , @processingRmtsSaveType                     int
	  , @processingRmtsRecID						bigint

--------------------------------------------------------

set @importResultsJSON = '{}'

/*-------------------------------    
 * Exit if we are validating
 *------------------------------*/    

if (@validateRec = 1)
begin
  return(0)
end

BEGIN TRY

/*-------------------------------    
 * set values for quarter related
 * variables
 *------------------------------*/ 

select top 1 
	@fyQuarterID       	= fyq.ID
  , @fyQuarterStartDate	= fyq.QTR_START
  , @fyQuarterEndDate  	= fyq.QTR_END
from dbo.Rmts_Participants_Data_Imports as rpd
join dbo.COMPANY_FISCAL_QUARTERS        as fyq on fyq.ID = rpd.fyQuarterID
where 
  (rpd.id = @rmtsDataImportID)

/*-------------------------------    
 * Validation
 *------------------------------*/ 

select
	@rosterID = id
from dbo.RMTS_PARTICIPATION_ROSTER as rpr where rpr.clientID = @clientID and rpr.quarterID = @fyQuarterID

if (isnull(@rosterID, 0) = 0)
begin
	RAISERROR('Roster doesn''t exist', 11, 1)
end

set @startProcessingDateTime = getdate()

/*-------------------------------
 * Incoming pracs core data
 *
 * Note: This is for matching 
 * purposes only.  Use the data
 * stored in the rmts participants imports
 * record table for adding
 * new core prac data.
 *------------------------------*/

declare @incomingRecordsPracData as table (
    idx                       bigint identity(1,1)
  , dataImportRecordID		  bigint
  , lastName                  nvarchar(50)
  , firstName                 nvarchar(50)
  , middleName                nvarchar(50)
  , title                     nvarchar(50)       
  , email                     nvarchar(50)   
  , startDate    			  date
  ,	endDate     			  date
  unique clustered (idx)
)


/*-------------------------------
 * Existing prac core data
 * Note: This is for matching
 * purposes only.  Do not save
 * changes to this table.
 *------------------------------*/

declare @existingRecordsPracData as table ( 
    idx                 bigint identity(1,1)
  , pracClientID		bigint
  , lastName            nvarchar(50)
  , firstName           nvarchar(50)
  , middleName          nvarchar(50)
  , email				nvarchar(50)       
  , pracID               bigint
  unique clustered (idx)
)

/*-------------------------------
 * Core prac data matches
 *------------------------------*/

declare @pracMatches as table (
    idx               bigint identity(1,1)
  , incomingRecordIdx bigint
  , existingRecordIdx bigint
  , quality           int
  unique clustered (incomingRecordIdx, existingRecordIdx, idx)
)

/*-------------------------------
 * RMTS roster
 *------------------------------*/			 

declare @rmtsRoster as table (
    idx								bigint identity(1,1)
  , recID							bigint
  , rosterID						bigint
  , fyQuarterID                     bigint
  , pracID							bigint
  , startDate					    date
  , endDate							date
  , reasonForStartDateChangeCode	int
  , reasonForEndDateChangeCode	    int
  , hasServiceRecords				bit
  , hasReimbursement				bit
  unique clustered (idx)
)

/*############################################################################
 *# Start processing file
 *############################################################################*/

/*############################################################################
 *# Pull incoming data into a working table for match purposes and
 *# modify some of the values to make matching easier
 *############################################################################*/

/*-------------------------------
 * Incoming patient core data
 *------------------------------*/

insert into @incomingRecordsPracData
(
    dataImportRecordID
  , lastName           
  , firstName          
  , middleName   
  , title      
  , email        
  , startDate                
  , endDate               
)

select 
    dataImportRecordID = pdir.id
  , lastName           = upper(trim(isnull(pdir.lastName  ,N'')))
  , firstName          = upper(trim(isnull(pdir.firstName ,N'')))
  , middleName         = upper(trim(isnull(pdir.middleName,N'')))
  , title              = isnull(pdir.title, N'')
  , email              = lower(trim(isnull(pdir.email     ,N'')))
  , startDate          = pdir.startDate
  , endDate            = pdir.endDate  
from dbo.Rmts_Participants_Data_Imports_Records as pdir
join dbo.Rmts_Participants_Data_Imports as rpd on rpd.id = pdir.dataImportID
where ( 
      (pdir.dataImportID = @rmtsDataImportID)
  and (rpd.clientID = @clientID)
)

/*############################################################################
 *# Pull existing data into a working table for match purposes
 *# modify some of the values to make matching easier
 *############################################################################*/

/*-------------------------------
 * Existing prac core data
 *------------------------------*/

insert into @existingRecordsPracData (
   pracClientID	
 , lastName      
 , firstName     
 , middleName    
 , email			
 , pracID        
)

select  
    pracClientID	   = pc.PRACCLIENT_ID
  , lastName           = upper(trim(isnull(pr.LAST_NAME,N'')))
  , firstName          = upper(trim(isnull(pr.FIRST_NAME,N'')))
  , middleName         = N''
  , email			   = pr.EMAIL
  , pracID             = pr.PRACTITIONER_ID

from dbo.PRACTITIONER_Client  as pc
join dbo.PRACTITIONER_Practitioner as pr on pr.PRACTITIONER_ID = pc.PRACTITIONER_ID
where ( 
      (pc.CLIENT_ID = @clientID)
  and (pr.ACTIVE != 0)
)

/*-------------------------------
 * Existing RMTS Roster
 *------------------------------*/

insert into @rmtsRoster (			
	  recID						
	, rosterID
	, fyQuarterID					
	, pracID						
	, startDate					
	, endDate						
	, reasonForStartDateChangeCode
	, reasonForEndDateChangeCode	
	, hasServiceRecords			
	, hasReimbursement			      
)

select  
	  recID						   = rpv.id
	, rosterID					   = rpv.rosterID
	, fyQuarterID                  = rpv.fyQuarterID		
	, pracID					   = rpv.pracID		
	, startDate					   = rpv.startDate				
	, endDate					   = rpv.endDate	
	, reasonForStartDateChangeCode = rpv.reasonForStartDateChangeCode
	, reasonForEndDateChangeCode   = rpv.reasonForEndDateChangeCode
	, hasServiceRecords			   = rpv.hasServiceRecords
	, hasReimbursement			   = rpv.hasReimbursement
from dbo.Rmts_Participants_Data_Imports as rpd
join dbo.RMTS_PARTICIPATION_ROSTER      as rpr on rpr.quarterID = rpd.fyQuarterID and rpr.clientID = rpd.clientID
cross apply dbo.RMTS_PARTICIPANTS_VIEW_CORE(rpd.clientID, rpr.id, 1, null) as rpv
where ((rpd.id = @rmtsDataImportID) and (rpd.clientID = @clientID))

/*############################################################################
 *# Further modify data in working table to modify some of the 
 *# values to make matching easier
 *############################################################################*/

/*-------------------------------
 * Incoming
 *------------------------------*/

update ir
set 
  ir.firstName = REPLACE(REPLACE(ir.firstName,N' ',N''),N'-',N'')
, ir.lastName  = REPLACE(REPLACE(ir.lastName,N' ',N''),N'-',N'')

from @incomingRecordsPracData as ir

/*-------------------------------
 * Existing
 *------------------------------*/

update er
set 
  er.firstName = REPLACE(REPLACE(er.firstName,N' ',N''),N'-',N'')
, er.lastName  = REPLACE(REPLACE(er.lastName,N' ',N''),N'-',N'')
from @existingRecordsPracData as er

/*############################################################################
 *#  Match Existing Prac Core Data
 *############################################################################*/

/*-------------------------------
 * Exact matches for email
 * and name
 *------------------------------*/

;with incoming_info_w_email_flags as (
  SELECT  *
  FROM    @incomingRecordsPracData  ir
  OUTER APPLY
    [dbo].[PARSE_EMAIL]
    (
      ir.email ,
      @clientID  
    ) ir_q

)
insert into @pracMatches
(
    incomingRecordIdx
  , existingRecordIdx
  , quality
)
select 
   incomingRecordIdx  = ir.idx
 , existingRecordsIdx = er.idx
 , quality            = 1
from @existingRecordsPracData  as er
OUTER APPLY
    [dbo].[PARSE_EMAIL]
    (
      er.email ,
      @clientID  
    ) er_qi
join incoming_info_w_email_flags  as ir
 on (
		(ir.email = er.email)   -- logic is: if email matches, it's our prac

		or  (						-- if email doesn't match, match on first and last name
					   (ir.lastName = er.lastName)
				and    (ir.firstName = er.firstName)
										 
				-- IF the name matches, we MUST have a sufficiently matched email address proving that
				-- the same-named individuals are NOT different people.  Avoid false-positive duplicates when
				-- importing somebody with the same name.

                AND NOT (  -- NOT clause contains possible same-name false-positive-match conditions
						( ir.email != er.email )

						AND (  	
							-- An email mismatch alone does not prove two people are different.
							-- A person could have multiple personal email addresses from public
							-- webmail services or residential ISPs.

							-- We're taking it for granted that the employer will never give more than one
							-- organization-issued email address to a single employee for their public-facing communications.
				
							(  ir.isLEAClientEmail = 1 AND er_qi.isLEAClientEmail = 1 )

					    -- if we're comparing two email addresses that have different screennames,
	                    -- issued by the same employer, they are different people, not a duplicate entry.
							 OR
	                         (
						            -- if we're looking at two prac emails, and one is district-issued and the other is
						            -- is from a healthcare organization, I'd assume they are different people.  (if one or
						            -- both emails is from a public webmail service or ISP, all bets are off.)
									ir.isViaPublicEmailWebhost = 0 AND ir.isISP = 0
	                                AND  er_qi.isViaPublicEmailWebhost = 0 AND  er_qi.isISP = 0

									AND  ir.isHealthCareProviderOrg != er_qi.isHealthCareProviderOrg
						     )


					    )


                )
        )
)

--SELECT * FROM @incomingRecordsPracData
--SELECT * FROM @existingRecordsPracData
--SELECT * FROM @pracMatches  -- for debugging

/*-------------------------------
 * Count core prac data matches
 * We will put this in the
 * table later
 *------------------------------*/

select 
  @numPracMatches = count(m.idx) 
from @pracMatches                 as m
join @incomingRecordsPracData as ir on ir.idx = m.incomingRecordIdx
join @existingRecordsPracData as er on er.idx = m.existingRecordIdx

/*-------------------------------
 * Document pracs not found 
 *------------------------------*/

 Insert into dbo.Rmts_Participants_Data_Imports_Pracs_Not_In_SpEdCare (
	rmtsDataImportID	
  , lastName      
  , firstName     
  , middleName
  , title    
  , email			
  , startDate     
  , endDate	
)
select
	@rmtsDataImportID
  , er.lastName      
  , er.firstName     
  , er.middleName 
  , er.title   
  , er.email			
  , iif(( -- ensure start date is between quarter start and end
		(er.startDate is not null) 
	and (er.startDate between @fyQuarterStartDate and @fyQuarterEndDate)
	), er.startDate, @fyQuarterStartDate)
  , iif(( -- ensure start date is between quarter start and end
		(er.endDate is not null) 
	and (er.endDate between @fyQuarterStartDate and @fyQuarterEndDate)
	), er.endDate  , @fyQuarterEndDate  )
from @incomingRecordsPracData as er
where (er.idx not in 
		(select
			prm.incomingRecordIdx
		 from @pracMatches as prm
        )
)


/*############################################################################
 *#  Insert valid records into RMTS participants table
 *############################################################################*/

set @i = 1
                     

while (@i <= @numPracMatches)                        
begin
  
 /*-------------------------------
 * Init loop parameters
 *------------------------------*/

	select top 1
		@processingRmtsPracID                         = er.pracID
	  , @processingRmtsRosterID					      = rpr.id
	  , @processingRmtsStartDate			          = iif(( -- ensure start date is between quarter start and end
															(ir.startDate is not null) 
														and (ir.startDate between @fyQuarterStartDate and @fyQuarterEndDate)
														), ir.startDate, @fyQuarterStartDate)
	  , @processingRmtsEndDate					      = iif(( -- ensure start date is between quarter start and end
															(ir.endDate is not null) 
														and (ir.endDate between @fyQuarterStartDate and @fyQuarterEndDate)
														), ir.endDate  , @fyQuarterEndDate  )
	  , @processingRmtsReasonForStartDateChangeCode   = null
	  , @processingRmtsReasonForEndDateChangeCode	  = null

	  , @processingRmtsHasServiceRecords			  = rr.hasServiceRecords
	  , @processingRmtsHasReimbursement			      = rr.hasReimbursement
	  , @processingRmtsSaveType                       = iif(rr.recID is null, dbo.CONST_SAVE_TYPE_NEW(), dbo.CONST_SAVE_TYPE_EDIT())
	  , @processingRmtsRecID						  = rr.recID
	from @pracMatches			       as pm
	join @incomingRecordsPracData      as ir on ir.idx    = pm.incomingRecordIdx
	join @existingRecordsPracData      as er on er.idx    = pm.existingRecordIdx
	join dbo.RMTS_PARTICIPATION_ROSTER as rpr on rpr.quarterID = @fyQuarterID and rpr.clientID = @clientID
	left join @rmtsRoster			   as rr on rr.pracID = er.pracID -- this list is already filtered by quarter ID and client ID
	where pm.idx = @i

	if (@processingRmtsSaveType = dbo.CONST_SAVE_TYPE_NEW())
	begin
		set @numOfNewPracRecs += 1				
	end
	else if (@processingRmtsSaveType = dbo.CONST_SAVE_TYPE_EDIT())
	begin
		set @numOfExistingPracRecs += 1
	end

	declare @spDetailsRmtsPart as varchar(8000) = ''
    declare @recordIDRmtsPart  as bigint = 0
 
	/*-------------------------------
	 * Save to roster
	 *------------------------------*/

	exec [dbo].[RMTS_PARTICIPANTS_SAVE_CORE]
	  @userID                       
	, @userGroup                    
	, @userRank                     
	, @clientID                     
	, @processingRmtsPracID                       
	, @processingRmtsRosterID					  
	, @processingRmtsStartDate					  
	, @processingRmtsEndDate					  
	, @processingRmtsReasonForStartDateChangeCode 
	, @processingRmtsReasonForEndDateChangeCode   
	, @processingRmtsHasServiceRecords			  
	, @processingRmtsHasReimbursement  
	, null  -- employeeRelationshipID           
	, ''	-- editDelReason 
	, 0     -- validateRec             
	, @processingRmtsSaveType                     
	, @processingRmtsRecID                        
	, 'Record doesn''t exist'                        
	, 'Record not editable'                    
	, 'Duplicate record'                        
	, 'A data error occured'                 
	, 'Inactive Record'                     
	, @spDetailsRmtsPart output   
	, @recordIDRmtsPart  output 
  
  set @i = @i + 1            
        
end 

/*-------------------------------
* Mark as "Not on TSP list" for
* pracs in our roster but not
* the uploaded 
*------------------------------*/										
update rp
	set rp.reasonForEndDateChangeCode = 2 -- 2 is "not on certified TSP list" in dbo.RMTS_REASONS_FOR_END_DATE_CHANGE				
from dbo.RMTS_PARTICIPATION_ROSTER              as rpr
join dbo.RMTS_PARTICIPANTS                      as rp  on rp.rosterID = rpr.id
where ((rpr.clientID = @clientID and rpr.quarterID = @fyQuarterID)
  and (rp.pracID not in 
		(select
			erp.pracID  
		 from @pracMatches as prm
		 join @existingRecordsPracData as erp on erp.idx = prm.existingRecordIdx)
      )
)

/*############################################################################
 *# Complile Report Results
 *############################################################################*/

/*-------------------------------
 * Generate result statistics
 *------------------------------*/

set @importResultsJSON = 
 '{'
+ isnull(convert(varchar(max),
	(select 
		er.pracID  as [pracRec.pracID]
	  , m.quality  as [pracRec.matchQuality]
	from @pracMatches             as m
	join @incomingRecordsPracData as ir on ir.idx = m.incomingRecordIdx
	join @existingRecordsPracData as er on er.idx = m.existingRecordIdx
	for json path, root('existingPracRecMatches')
	)
	)
, '')
+ '}' 

/*###########################################################################################################################
 *# Persist data
 *#
 *#            NOTE: The goal is to keep the transaction(s) open for the least amount of time possible
 *#
 *###########################################################################################################################*/

/*-------------------------------
 * Update status
 *------------------------------*/

set @endProcessingDateTime = getdate()

update dbo.Rmts_Participants_Data_Imports
set 
    fileProcessingCompleted        = 1
  , numOfExistingPracRecsFound     = @numPracMatches
  , numOfExistingPracRecChanges	   = @numOfExistingPracRecs
  , numOfNewPracRecAdditions	   = @numOfNewPracRecs
  ,	importResultsJSON			   = @importResultsJSON
  , fileProcessingStartDateTime    = @startProcessingDateTime
  , fileProcessingEndDateTime      = @endProcessingDateTime
  , lastModified                   = @endProcessingDateTime
  , lastModifiedBy                 = @userID

where ((id = @rmtsDataImportID) and (clientID = @clientID))

RETURN(0)    

END TRY    
BEGIN CATCH    
    
  /*-------------------------------    
   * If we end up here something    
   * went wrong.  Cancel any pending    
   * transactions and return any    
   * error any error messages to    
   * the caller    
   *------------------------------*/    
         
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

