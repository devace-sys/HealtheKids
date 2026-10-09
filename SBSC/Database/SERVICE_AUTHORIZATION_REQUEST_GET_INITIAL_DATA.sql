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

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_AUTHORIZATION_REQUEST_GET_INITIAL_DATA') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SERVICE_AUTHORIZATION_REQUEST_GET_INITIAL_DATA
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[SERVICE_AUTHORIZATION_REQUEST_GET_INITIAL_DATA] (    
    @userID                        BIGINT
  , @userGroup                     INT  
  , @userRank                      INT 
  , @clientID                      bigint
  , @svcAuthorizationRequestTypeID bigint 
  , @referencedEntityID            bigint
) 

returns @data table (        
	  clientID                         bigint	
	, pracID                           bigint
	, pracName                         nvarchar(100)
    , pracEmail                        nvarchar(50)
	, pracPhone                        nvarchar(14)
	, patID                            bigint
	, patName                          nvarchar(100)
	, groupSvcClassNameID              bigint
	, fileClass                        bigint
	, fileNameSpace                    varchar(500)
	, fileSource                       varchar(500)
	, svcAuthorizationRequestTypeID    bigint
	, referencedEntityID               bigint
	, svcSelectionTypeID               bigint /* 1 = ORP Document Standard Service Name */
	, svcSelectionNameID               bigint    
	, svcName                          varchar(1000)
	, svcDescription                   varchar(8000)
	, svcStartDate                     date

	, prtGrd1PersonID                  bigint
	, prtGrd1Name                      varchar(512)
	, prtGrd1RelationshipWithPatientLabel varchar(1000)
	, prtGrd1Email                     varchar(255)
	, prtGrd1Phone                     varchar(255)
	, prtGrd1PlaceAddress              varchar(2000)

	, prtGrd2PersonID                  bigint
	, prtGrd2Name                      varchar(512)
	, prtGrd2RelationshipWithPatientLabel varchar(1000)
	, prtGrd2Email                     varchar(255)
	, prtGrd2Phone                     varchar(255)
	, prtGrd2PlaceAddress             varchar(2000)

	, orpPracID                     bigint
	, orpPracName                   nvarchar(100)
    , orpPracEmail                  nvarchar(50)
	, orpPracPhone                  nvarchar(14)
	, orpPracPlaceAddress           varchar(2500)	
	
	, formBuilderQuestionsJSON		varchar(max)
	, formBuilderAnswersJSON  		varchar(max)
	
    , districtContactUserID         bigint
    , districtContactName           nvarchar(100)    
    , districtContactEmail          nvarchar(50)
    , districtContactPhone          nvarchar(14)

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
     
  declare @clientIDOut          as     bigint

  declare @pracID               as     bigint
  declare @pracName             as     nvarchar(100)    
  declare @pracEmail            as     nvarchar(50)
  declare @pracPhone            as     nvarchar(14)

  declare @districtContactUserID  as     bigint
  declare @districtContactName    as     nvarchar(257)    
  declare @districtContactEmail   as     nvarchar(256)
  declare @districtContactPhone   as     nvarchar(14)

  declare @patID                as     bigint
  declare @patName              as     nvarchar(100)
  declare @groupSvcClassNameID  as     bigint
  declare @fileClass            as     bigint
  declare @fileNameSpace        as     varchar(500)
  declare @fileSource           as     varchar(500)
  declare @svcSelectionTypeID   as     bigint /* 1 = ORP Document Standard Service Name */
  declare @svcSelectionNameID   as     bigint
  declare @svcName              as     varchar(1000)
  declare @svcDescription       as     varchar(8000)
  declare @svcStartDate         as     date
    
  declare @prtGrd1PersonID                  as bigint
  declare @prtGrd1Name                      as varchar(512)
  declare @prtGrd1RelationshipWithPatientLabel as varchar(1000)
  declare @prtGrd1Email                     as varchar(255)
  declare @prtGrd1Phone                     as varchar(255)  
  declare @prtGrd1PlaceAddress              as varchar(2000)

  declare @prtGrd2PersonID                  as bigint
  declare @prtGrd2Name                      as varchar(512)
  declare @prtGrd2RelationshipWithPatientLabel as varchar(1000)
  declare @prtGrd2Email                     as varchar(255)
  declare @prtGrd2Phone                     as varchar(255)  
  declare @prtGrd2PlaceAddress             as varchar(2000)

  declare @orpPracID            as     bigint
  declare @orpPracName          as     nvarchar(100)  
  
  declare @orpPracEmail         as     nvarchar(50)
  declare @orpPracPhone         as     nvarchar(14)
  declare @orpPracPlaceAddress  as     varchar(2500)
  
  declare @rdrPracID            as     bigint
  declare @rdrPracName          as     nvarchar(100)
  declare @rdrPracEmail         as     nvarchar(100)
  declare @rdrPracPhone         as     nvarchar(100)	
  
  declare @formBuilderQuestionsJSON               as  varchar(max)  
  declare @formBuilderAnswersJSON                 as  varchar(max)
  
  declare @hasFileIncludes                        as  bit
  declare @fileClassInclude                       as  bigint
  declare @fileNameSpaceInclude                   as  varchar(500)
  declare @fileSourceInclude                      as  varchar(500)
  declare @filesToIncludeUseClientIdDataParameter as  bit
  declare @filesToIncludeUsePracIdDataParameter   as  bit
  declare @filesToIncludeUsePatIdDataParameter    as  bit
  
  /* Get additional data we need for this request using the referencedEntityID and request type
   * Note: At present, referencedEntityID is REQUIRED because it is the only way we can 100%
   * determine what the patient and client id values are as well as other data 
   */

  select top 1

     @clientIDOut                            = t1.clientID
   , @patID                                  = t1.patID
   , @groupSvcClassNameID                    = t1.groupSvcClassNameID
   , @fileClass                              = t1.fileClass
   , @fileNameSpace                          = t1.fileNameSpace
   , @fileSource                             = t1.fileSource
   , @svcSelectionTypeID                     = t1.svcSelectionTypeID 
   , @svcSelectionNameID                     = t1.svcSelectionNameID
   , @svcName                                = t1.svcName
   , @svcDescription                         = t1.svcDescription
   , @svcStartDate                           = t1.svcStartDate
   , @orpPracID                              = t1.orpPracID 
   , @formBuilderQuestionsJSON               = t1.formBuilderQuestionsJSON
   , @formBuilderAnswersJSON  	             = t1.formBuilderAnswersJSON  
   , @hasFileIncludes                        = t1.hasFileIncludes                      
   , @fileClassInclude                       = t1.fileClassInclude                       
   , @fileNameSpaceInclude                   = t1.fileNameSpaceInclude                  
   , @fileSourceInclude                      = t1.fileSourceInclude                    
   , @filesToIncludeUseClientIdDataParameter = t1.filesToIncludeUseClientIdDataParameter 
   , @filesToIncludeUsePracIdDataParameter   = t1.filesToIncludeUsePracIdDataParameter
   , @filesToIncludeUsePatIdDataParameter    = t1.filesToIncludeUsePatIdDataParameter    

from dbo.SERVICE_AUTHORIZATION_REQUEST_GET_RELATED_DATA_REFERENCED_ENTITY_AND_FILE_CLASS_DETAIL (
    @userID                    
  , @userGroup                 
  , @userRank                  
  , @clientID                      
  , @svcAuthorizationRequestTypeID 
  , @referencedEntityID ) as t1

 /*==========================================================
  * Patient (at present) is always required)
  *==========================================================*/
 
  select top 1 
    @patName = pp.CONCAT_NAME 
  from dbo.PATIENTS_PATIENT as pp
  where (pp.PATIENT_ID = @patID)
  
 /*==========================================================
  * District Contact (at present) is always required)
  *==========================================================*/
  
  /*-------------------------------
   * For requests where the contact
   * MUST be a practitioner
   *------------------------------*/

  if ( @svcAuthorizationRequestTypeID in (1,2) )  /* Expansion hook:  Add request types here if needed */
  begin
    select top 1
        @districtContactUserID  = ua.id
      , @districtContactName    = ua.lastName + N', ' + ua.firstName 
      , @districtContactEmail   = ua.email
      , @districtContactPhone   = ua.phone
      , @pracID                 = ua.pracID
      , @pracName               = ua.pracName
      , @pracEmail              = ua.email
      , @pracPhone              = ua.phone
  
    from users.dbo.USERS_ALL as ua

    where ( 
          (ua.id          = @userID)
	  and (ua.clientID    = @clientIDOut)
      and (ua.appName     = users.dbo.CONST_APP_NAME_SPEDCARE())
	  and (ua.userGroupID = 1)    /* Limit to district contacts only */
	  and (ua.pracID is not null) /* Limit to pracs only */
    )
  end

  /*-------------------------------
   * For other requests where the
   * contact does not have to be
   * a practitioner
   *------------------------------*/

  else
  begin
    select top 1
        @districtContactUserID  = ua.id
      , @districtContactName    = ua.lastName + N', ' + ua.firstName 
      , @districtContactEmail   = ua.email
      , @districtContactPhone   = ua.phone
      , @pracID                 = ua.pracID
      , @pracName               = ua.pracName
      , @pracEmail              = ua.email
      , @pracPhone              = ua.phone
  
    from users.dbo.USERS_ALL as ua

    where ( 
          (ua.id          = @userID)
	  and (ua.clientID    = @clientIDOut)
      and (ua.appName     = users.dbo.CONST_APP_NAME_SPEDCARE())
	  and (ua.userGroupID = 1) /* Limit to district contacts only */
    )
  end
 
 /*==========================================================
  * Parent/Guardian Selection.  Required in some cases.
  * Good to have in any case.
  *==========================================================*/
 
  declare @prtGrds as table (
      idx                          bigint identity(1,1)
	, personID                     bigint
	, name                         varchar(512)
	, relationshipWithPatientLabel varchar(1000)
	, email                        varchar(255)
	, phone                        varchar(255)
	, placeAddress                 varchar(2000)
  )
        
  insert into @prtGrds (
      personID
	, name
	, relationshipWithPatientLabel
	, email
	, phone
	, placeAddress
  )  
  
  /* Note: Do not use a top on this select or it will hang.  Not sure why.*/

  select 
	  personID
	, name
	, relationshipWithPatientLabel
	, email
	, phone
	, placeAddress

  from dbo.PATIENT_PERSONS_VIEW_CORE (  @userID
                                      , @userGroup
                                      , @userRank
                                      , @clientID
                                      , @patID
                                      , 1 
                                      , null
                                      , 1
                                      , null
									  , null ) as ppvc
  order by 
    ppvc.ClassID2 asc

  select top 1
        @prtGrd1PersonID                  = personID
	  , @prtGrd1Name                      = name
	  , @prtGrd1RelationshipWithPatientLabel = relationshipWithPatientLabel
	  , @prtGrd1Email                     = email
	  , @prtGrd1Phone                     = phone
	  , @prtGrd1PlaceAddress             = placeAddress
  from @prtGrds 
  where (idx = 1)

  select top 1
        @prtGrd2PersonID                  = personID
	  , @prtGrd2Name                      = name
	  , @prtGrd2RelationshipWithPatientLabel = relationshipWithPatientLabel
	  , @prtGrd2Email                     = email
	  , @prtGrd2Phone                     = phone
	  , @prtGrd2PlaceAddress             = placeAddress
  from @prtGrds 
  where (idx = 2)

 /*==========================================================
  * ORP Selection.  Required in some cases.
  * Good to have in any case.
  *==========================================================*/

  select top 1 
      @orpPracName         = pp.CONCAT_NAME 
    , @orpPracEmail        = pp.EMAIL
    , @orpPracPhone        = pp.PHONE_NUMBER
    , @orpPracPlaceAddress = dbo.BUILD_PLACE_ADDRESS_STRING (pp.street1, pp.street2, pp.city, pp.usState, pp.zip5, pp.zip4, 0)

  from dbo.PRACTITIONER_Practitioner as pp
  where (pp.PRACTITIONER_ID = @orpPracID)
 
 /*###########################################################################
   # Return data
   ###########################################################################*/  
   
insert into @data
(    
      clientID
	, pracID
	, pracName
	, pracEmail
	, pracPhone
	, patID
	, patName
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
	, svcStartDate
	, prtGrd1PersonID
	, prtGrd1Name
	, prtGrd1RelationshipWithPatientLabel
	, prtGrd1Email
	, prtGrd1Phone
	, prtGrd1PlaceAddress
	, prtGrd2PersonID
	, prtGrd2Name
	, prtGrd2RelationshipWithPatientLabel
	, prtGrd2Email
	, prtGrd2Phone
	, prtGrd2PlaceAddress
	, orpPracID
	, orpPracName
	, orpPracEmail
	, orpPracPhone
	, orpPracPlaceAddress	
	, formBuilderQuestionsJSON
	, formBuilderAnswersJSON
	, districtContactUserID 
    , districtContactName
    , districtContactEmail
    , districtContactPhone
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
      @clientIDOut
    , @pracID
    , @pracName
	, @pracEmail
	, @pracPhone
	, @patID
	, @patName
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
	, @svcStartDate
	, @prtGrd1PersonID
	, @prtGrd1Name
	, @prtGrd1RelationshipWithPatientLabel
	, @prtGrd1Email
	, @prtGrd1Phone
	, @prtGrd1PlaceAddress
	, @prtGrd2PersonID
	, @prtGrd2Name
	, @prtGrd2RelationshipWithPatientLabel
	, @prtGrd2Email
	, @prtGrd2Phone
	, @prtGrd2PlaceAddress
	, @orpPracID
	, @orpPracName
	, @orpPracEmail
	, @orpPracPhone
	, @orpPracPlaceAddress
	, @formBuilderQuestionsJSON
	, @formBuilderAnswersJSON
	, @districtContactUserID 
    , @districtContactName
    , @districtContactEmail
    , @districtContactPhone
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
 
GRANT SELECT ON  [dbo].[SERVICE_AUTHORIZATION_REQUEST_GET_INITIAL_DATA] TO [webuser]
GO