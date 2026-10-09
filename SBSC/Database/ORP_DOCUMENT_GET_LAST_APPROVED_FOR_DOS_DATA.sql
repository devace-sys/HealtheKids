USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.ORP_DOCUMENT_GET_LAST_APPROVED_FOR_DOS_DATA') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.ORP_DOCUMENT_GET_LAST_APPROVED_FOR_DOS_DATA
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[ORP_DOCUMENT_GET_LAST_APPROVED_FOR_DOS_DATA] (    
    @dos                date  
  , @orpDocID           bigint ) 

returns @data table (     
	orpDocID                        	                 bigint
  , lastApprovedForDOSOrpDocTypeID  	                 bigint
  , lastApprovedForDOSOrpPracID     	                 bigint
  , lastApprovedForDOSEffectiveDate 	                 date
  , lastApprovedForDOSExpirationDate	                 date
  , lastApprovedApprovalRecordID    	                 bigint
  , lastApprovedForDOSOrpLastName		                 nvarchar(50)
  , lastApprovedForDOSOrpFirstName		                 nvarchar(50)
  , lastApprovedForDOSOrpPracName		                 nvarchar(100)
  , lastApprovedForDOSOrpPracNpiNumber	                 varchar(50)
  , lastApprovedForDOSOrpPracHasNpi                      bit
  , lastApprovedForDOSOrpPracIsValidMcalOrp              bit
  , lastApprovedForDOSOrpPracIsValidMcalOrpLastValidated date
  , lastApprovedForDOSOrpPracIsReadyFor837               bit
)   
as
begin
    
  declare @orpDocTypeID  as bigint
  declare @orpPracID     as bigint = null
  declare @startDate     as date
  declare @endDate       as date 
  declare @approvalRecID as bigint
  
  
  select top 1 
  	@orpDocTypeID = od.ORP_DOCUMENT_TYPE_ID 
  from dbo.ORP_DOCUMENTS as od
  where (od.ID = @orpDocID)

  /*###########################################################################
    # Special authorization
    ###########################################################################*/  
  
  if (@orpDocTypeID = 1)
  begin
  	select top 1
  		  @orpPracID     = pbs.ORP_PRAC_ID 
  		, @startDate     = pbs.START_DATE
  		, @endDate       = pbs.END_DATE  
  		, @approvalRecID = pbs.ID
  	from dbo.CLIENT_PBS_DOCUMENTATION as pbs
  	where (
  		  (pbs.ORP_DOCUMENT_ID = @orpDocID)
  	  and (@dos between pbs.START_DATE and pbs.END_DATE)
  	  and (pbs.ACTIVE = 1)
  	) 
  	order by 
  	  pbs.ID desc
  end

  /*###########################################################################
    # Orders/Presriptions and Patient Profiles
    ###########################################################################*/  

  else if (@orpDocTypeID in (2,3))
  begin
  	select top 1 
  	      @orpPracID = sac.orpPracID 
  		, @startDate = sac.effectiveDate
  		, @endDate   = sac.expirationDate
  	    , @approvalRecID = sac.id
  	from dbo.SERVICE_AUTHORIZATION_STATUS_CONFIRMATION as sac 
  	where (       
  			(sac.orpDocumentID = @orpDocID)  		
  		and (sac.confirmationResponseCode = 100)
  		and (@dos between sac.effectiveDate and sac.expirationDate)
		and (sac.active = 1)
  	)
  	order by 
  	  sac.id desc
  end
  
  /*###########################################################################
    # Return data
    ###########################################################################*/  
  
  insert into @data 

	  select top 1
  		  orpDocID                         = @orpDocID
  		, lastApprovedForDOSOrpDocTypeID   = @orpDocTypeID
  		, lastApprovedForDOSOrpPracID      = @orpPracID
  		, lastApprovedForDOSEffectiveDate  = @startDate
  		, lastApprovedForDOSExpirationDate = @endDate
  		, lastApprovedApprovalRecordID     = @approvalRecID
  		, q1.* 
  		, lastApprovedForDOSOrpPracIsReadyFor837 = dbo.IS_ORP_COMPLIANT (1,q1.lastApprovedForDOSOrpPracHasNpi ,q1.lastApprovedForDOSOrpPracIsValidMcalOrp)
	  from
	  (
  		select top 1
  			  orp.LAST_NAME                       as lastApprovedForDOSOrpLastName
  			, orp.FIRST_NAME                      as lastApprovedForDOSOrpFirstName
  			, orp.CONCAT_NAME                     as lastApprovedForDOSOrpPracName
  			, isnull(orp.npiNumber, '')           as lastApprovedForDOSOrpPracNpiNumber
  			, lastApprovedForDOSOrpPracHasNpi                      = dbo.IS_VALID_NPI (orp.npiNumber)                  
  			, lastApprovedForDOSOrpPracIsValidMcalOrp              = orp.isValidMcalOrp
  			, lastApprovedForDOSOrpPracIsValidMcalOrpLastValidated = orp.isValidMcalOrpLastValidated 
  		from dbo.PRACTITIONER_Practitioner as orp 
  		where 
  		(orp.PRACTITIONER_ID = @orpPracID)
	  ) as q1

  
  return  

end

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[ORP_DOCUMENT_GET_LAST_APPROVED_FOR_DOS_DATA] TO [webuser]
GO