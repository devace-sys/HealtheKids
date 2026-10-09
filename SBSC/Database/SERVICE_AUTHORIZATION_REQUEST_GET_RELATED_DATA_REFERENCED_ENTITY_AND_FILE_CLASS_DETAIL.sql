USE SPEDMON
GO

/*
 * THIS ROUTINE CONTAINS EXPANSION HOOKS FOR E-AUTHORIZE
 * Add additional code if needed to support new request types
 * Note: @svcName will have the following text appended to it provided to [patient name]
 */

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_AUTHORIZATION_REQUEST_GET_RELATED_DATA_REFERENCED_ENTITY_AND_FILE_CLASS_DETAIL') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SERVICE_AUTHORIZATION_REQUEST_GET_RELATED_DATA_REFERENCED_ENTITY_AND_FILE_CLASS_DETAIL
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[SERVICE_AUTHORIZATION_REQUEST_GET_RELATED_DATA_REFERENCED_ENTITY_AND_FILE_CLASS_DETAIL] (
    @userID                        BIGINT
  , @userGroup                     INT  
  , @userRank                      INT 
  , @clientID                      bigint
  , @svcAuthorizationRequestTypeID bigint 
  , @referencedEntityID            bigint
) 

returns @data table (        
	  orpDocID                         bigint
	, clientID                         bigint	
	, patID                            bigint
	, groupSvcClassNameID              bigint
	
	/* Fileclass that the authorization request/response is associated with for permanent record */

	, fileClass                        bigint         
	, fileNameSpace                    varchar(500)
	, fileSource                       varchar(500)
	
	, svcAuthorizationRequestTypeID    bigint
	, referencedEntityID               bigint
	, svcSelectionTypeID               bigint /* 1 = ORP Document Standard Service Name */
	, svcSelectionNameID               bigint    
	, svcName                          varchar(1000)
	, svcDescription                   varchar(8000)
	, formBuilderQuestionsJSON         varchar(max)
	, formBuilderAnswersJSON           varchar(max)
	, svcStartDate                     date
    , orpPracID                        bigint	
	, formQuestionsJSON				   varchar(max)
    , formAnswersJSON  				   varchar(max)		

	, hasFileIncludes                        bit
	, fileClassInclude                       bigint
    , fileNameSpaceInclude                   varchar(500)
    , fileSourceInclude                      varchar(500)
	, filesToIncludeUseClientIdDataParameter bit
    , filesToIncludeUsePracIdDataParameter   bit
    , filesToIncludeUsePatIdDataParameter    bit
)
as
begin
     
  declare @id                                     as    bigint
  declare @clientIDOut                            as    bigint
  declare @patID                                  as    bigint
  declare @groupSvcClassNameID                    as    bigint
  declare @fileClass                              as    bigint
  declare @fileNameSpace                          as    varchar(500)
  declare @fileSource                             as    varchar(500)
  declare @svcSelectionTypeID                     as    bigint /* 1 = ORP Document Standard Service Name */
  declare @svcSelectionNameID                     as    bigint
  declare @svcName                                as    varchar(1000)
  declare @svcDescription                         as    varchar(8000) 
  declare @formBuilderQuestionsJSON               as    varchar(max)
  declare @formBuilderAnswersJSON                 as    varchar(max) 
  declare @svcStartDate                           as    date
  declare @orpPracID                              as    bigint
  declare @formQuestionsJSON	                  as	varchar(max)
  declare @formAnswersJSON  	                  as	varchar(max)
  declare @hasFileIncludes                        as    bit
  declare @fileClassInclude                       as    bigint
  declare @fileNameSpaceInclude                   as    varchar(500)
  declare @fileSourceInclude                      as    varchar(500)
  declare @filesToIncludeUseClientIdDataParameter as    bit
  declare @filesToIncludeUsePracIdDataParameter   as    bit
  declare @filesToIncludeUsePatIdDataParameter    as    bit
  


  /*============================================================
   * Orders/Prescriptions or Patient Profiles
   *============================================================*/
  
  if (@svcAuthorizationRequestTypeID in (1,2))
  begin
    
	declare @orpDocTypeID as bigint = null
	declare @orpDocID     as bigint = null
	
	set @fileNameSpace       = 'daily_journal'
	set @svcSelectionTypeID  = 1

    set @hasFileIncludes                        = 0
    set @fileClassInclude                       = 0
    set @fileNameSpaceInclude                   = ''
    set @fileSourceInclude                      = ''
    set @filesToIncludeUseClientIdDataParameter = 0
    set @filesToIncludeUsePracIdDataParameter   = 0
    set @filesToIncludeUsePatIdDataParameter    = 0
	
	if (@svcAuthorizationRequestTypeID = 1) 
	begin
	  set @orpDocTypeID = 2
	  set @fileClass    = 6
	  set @fileSource   = 'prescription'
	end
	else if (@svcAuthorizationRequestTypeID = 2) 
	begin
	  set @orpDocTypeID = 3
	  set @fileClass    = 6
	  set @fileSource   = 'prescription'
	end
	else
	begin	   
	   return
	end
	    
    select top 1

        @orpDocID                 = ID
      , @clientIDOut              = CLIENT_ID	  
	  , @patID                    = PATIENT_ID
	  , @groupSvcClassNameID      = GROUP_SERVICE_CLASS_NAME_ID
      , @svcSelectionNameID       = ORP_DOCUMENT_STANDARD_SELECTION_NAME_ID
      , @svcName                  = ORP_DOCUMENT_STANDARD_SELECTION_NAME /* provided to [patient name] */
      , @svcDescription           = ORP_ORDERS
	  , @formBuilderQuestionsJSON = formBuilderQuestionsJSON
	  , @formBuilderAnswersJSON   = formBuilderAnswersJSON
	  , @svcStartDate             = START_DATE
	  , @orpPracID                = ORP_PRAC_ID
	  , @formQuestionsJSON	      = formBuilderQuestionsJSON		
      ,	@formAnswersJSON  	      = formBuilderAnswersJSON  

    from dbo.ORP_DOCUMENTS_DATA_CORE (   @clientID
                                       , null
                                       , null
                                       , null
                                       , null
									   , null
									   , @referencedEntityID )

     where ( 
           (ORP_DOCUMENT_TYPE_ID = @orpDocTypeID)
	   and (REFERENCE_ID = @referencedEntityID)
	 )
  
    if (@orpDocID is null) return

  end
  
  /*==========================================================
   * Medi-Cal Billing Parent Consent/Authorization
   *============================================================*/

  else if (@svcAuthorizationRequestTypeID = 3)
  begin

    set @orpDocID             = null
	set @groupSvcClassNameID  = null
	
	select top 1
	    @clientIDOut    = pc.CLIENT_ID
	  , @patID          = pp.PATIENT_ID
	  , @svcDescription = trim(isnull(clc.defaultMCALBillingConsentMsgText,N''))
	
	from dbo.PATIENTS_Patient as pp  
	join dbo.PATIENTS_Client  as pc on pc.PATIENT_ID = pp.PATIENT_ID
	join dbo.CLIENTS_Client   as clc on clc.CLIENT_ID = pc.CLIENT_ID
	 
	where ( 
	      (pp.PATIENT_ID = @referencedEntityID)
	  and ((@clientID is null) or (pc.CLIENT_ID = @clientID))
	)

	set @fileClass            = 30
	set @fileNameSpace        = 'patients'
	set @fileSource           = 'mcal_billing_authorization'
    
	set @svcAuthorizationRequestTypeID = 3
	set @referencedEntityID            = @patID
	set @svcSelectionTypeID            = null
	set @svcSelectionNameID            = null 
 	set @svcName                       = 'Medi-Cal billing authorization for professional treatment or therapy services'
	set @formBuilderQuestionsJSON      = null
	set @formBuilderAnswersJSON        = null
	set @svcStartDate                  = convert(date,getdate())
	set @orpPracID                     = null
	set @formQuestionsJSON             = null	
	set @formAnswersJSON               = null

    set @hasFileIncludes                        = 1
    set @fileClassInclude                       = 25
    set @fileNameSpaceInclude                   = 'mcal_billing'
    set @fileSourceInclude                      = 'eauth'
    set @filesToIncludeUseClientIdDataParameter = 1
    set @filesToIncludeUsePracIdDataParameter   = 0
    set @filesToIncludeUsePatIdDataParameter    = 0

end

/*==========================================================
 * Care Plan Parent Authorization
 *==========================================================*/

else if (@svcAuthorizationRequestTypeID = 4)
begin
   set @orpDocID             = null
	set @groupSvcClassNameID  = null
	
	select top 1
		@id             = pwp.ID
	  , @clientIDOut    = pc.CLIENT_ID
	  , @patID          = pwp.PATIENT_ID
	  , @svcDescription = 'Care plan'
	
	from dbo.PLAN_WRITER_PLANS as pwp
	join dbo.PATIENTS_Client  as pc on pc.PATIENT_ID = pwp.PATIENT_ID
	join dbo.CLIENTS_Client   as clc on clc.CLIENT_ID = pc.CLIENT_ID
	 
	where ( 
	      (pwp.id = @referencedEntityID)
	  and ((@clientID is null) or (pc.CLIENT_ID = @clientID))
	)

	set @fileClass            = 40
	set @fileNameSpace        = 'patients'
	set @fileSource           = 'care_plan_authorization'
    
	set @svcAuthorizationRequestTypeID = 4
	set @referencedEntityID            = @id
	set @svcSelectionTypeID            = null
	set @svcSelectionNameID            = null 
 	set @svcName                       = 'Parental Authorization for Care Plan for Services to be ' /* provided to [patient name] */
	set @formBuilderQuestionsJSON      = null
	set @formBuilderAnswersJSON        = null
	set @svcStartDate                  = convert(date,getdate())
	set @orpPracID                     = null
	set @formQuestionsJSON             = null	
	set @formAnswersJSON               = null

    set @hasFileIncludes                        = 1
	set @fileClassInclude                       = 35
    set @fileNameSpaceInclude                   = 'careplan_writer'
    set @fileSourceInclude                      = 'eauth'
    set @filesToIncludeUseClientIdDataParameter = 1
    set @filesToIncludeUsePracIdDataParameter   = 0
    set @filesToIncludeUsePatIdDataParameter    = 1
end
/* else if ....*/
/* Expansion hook:  Add request types here if needed */

/*==========================================================
 * Unknown request type
 *========================================================*/

else
begin
    return
end
    
  
/*###########################################################################
  # Return data
  ###########################################################################*/  
   
insert into @data
(    
      orpDocID
	, clientID
	, patID
	, groupSvcClassNameID
	, fileClass
	, fileNameSpace
	, fileSource
    , svcAuthorizationRequestTypeID
	, referencedEntityID
	, svcSelectionTypeID
	, svcSelectionNameID
	, svcName
	, svcDescription
	, formBuilderQuestionsJSON
	, formBuilderAnswersJSON
	, svcStartDate	
	, orpPracID
	, formQuestionsJSON	
    , formAnswersJSON  		
	, hasFileIncludes                        
	, fileClassInclude                       
    , fileNameSpaceInclude                   
    , fileSourceInclude                      
	, filesToIncludeUseClientIdDataParameter 
    , filesToIncludeUsePracIdDataParameter   
    , filesToIncludeUsePatIdDataParameter    
)
values
(
      @orpDocID 
	, @clientIDOut
	, @patID
	, @groupSvcClassNameID
	, @fileClass
	, @fileNameSpace
	, @fileSource
    , @svcAuthorizationRequestTypeID
	, @referencedEntityID
	, @svcSelectionTypeID
	, @svcSelectionNameID
	, @svcName
	, @svcDescription
	, @formBuilderQuestionsJSON
	, @formBuilderAnswersJSON
	, @svcStartDate
	, @orpPracID
	, @formQuestionsJSON	
	, @formAnswersJSON 
    , @hasFileIncludes                        
	, @fileClassInclude                       
    , @fileNameSpaceInclude                   
    , @fileSourceInclude                      
	, @filesToIncludeUseClientIdDataParameter 
    , @filesToIncludeUsePracIdDataParameter   
    , @filesToIncludeUsePatIdDataParameter     	
) 

return  

end

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[SERVICE_AUTHORIZATION_REQUEST_GET_RELATED_DATA_REFERENCED_ENTITY_AND_FILE_CLASS_DETAIL] TO [webuser]
GO