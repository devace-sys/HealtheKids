USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.GET_ORP_PRAC_NPI_DATA') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.GET_ORP_PRAC_NPI_DATA
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[GET_ORP_PRAC_NPI_DATA] (    
    @svcIsNeverBillable        bigint
  , @svcType                   bigint
  , @dos                       date  
  , @clientID                  bigint  
  , @groupID                   bigint
  , @orpDocID                  bigint
  , @patID                     bigint
  , @procedureBillingProgramID tinyint 
) 

returns @data table (     
     OrpRequired     bit
   , OrpDocumentID   bigint
   , OrpDocumentName varchar(255)
   , OrpDocTypeID    bigint
   , OrpDocRefID     bigint
   , PracID          bigint
   , LastName        nvarchar(50)
   , FirstName       nvarchar(50)
   , NpiNumber       varchar(50)
   , IsValidMcalOrp  bit )   
as
begin
    
   declare @orpRequired         as  bit          = null
   declare @orpDocumentID       as  bigint       = null
   declare @orpDocumentName     as  varchar(255) = null 
   declare @orpDocTypeID        as  bigint       = null
   declare @orpDocRefID         as  bigint       = null

   declare @pracID              as  bigint       = null
   declare @lastName            as  nvarchar(50) = null
   declare @firstName           as  nvarchar(50) = null
   declare @npiNumber           as  varchar(50)  = null
   declare @isValidMcalOrp      as  bit          = null
   declare @autoMatchFound      as  bit          = null

   /*###########################################################################
     # Determine if ORP is required
     ###########################################################################*/  
   
   set @orpRequired = dbo.IS_ORP_REQUIRED_FOR_SVC (@svcIsNeverBillable, @svcType, @dos,@procedureBillingProgramID)
     
   /*###########################################################################
     # If ORP is required then we have multiple methods to determine who to use
     ###########################################################################*/  

   if (@orpRequired = 1)
   begin 

     declare @searchDone             as bit    = 0 
     declare @getLastApprovalData    as bit    = 0
	 declare @rdrGroupSvcClassNameID as bigint = null
   
	 /*###########################################################################
       # Get service class name that applies to the rendering practitioner 
       # discipline group for orp data.  Also let rest of routine know we are
	   # just starting out
       ###########################################################################*/  
     
     set @rdrGroupSvcClassNameID = dbo.GET_ORP_SVC_CLASS_NAME_ID_FROM_GROUP_ID (@groupID)
	 set @searchDone          = 0
	 set @getLastApprovalData = 0  
         
     /*###########################################################################
 	   # If a prescription, order, or other document that was issued by an ORP was 
       # specifically provided by the rendering practitioner or their agent.
       # then use the document if it is valid.  
	   #
	   # This is the highest priority for document assignment.
       ###########################################################################*/  
     
     if ((@searchDone = 0) and (@orpDocID is not null))
     begin 
       
	   /* Find orp document that was provided */

       select top 1 
      
           @pracID          = orpPracID
         , @lastName        = orpLastName
         , @firstName       = orpFirstName
         , @npiNumber       = orpPracNpiNumber
         , @isValidMcalOrp  = orpPracIsValidMcalOrp
         , @orpDocumentID   = id
         , @orpDocumentName = name
         , @orpDocTypeID    = orpDocTypeID
         , @orpDocRefID     = refID

       from dbo.ORP_DOCUMENTS_VIEW_CORE (   null
                                          , null
                                          , null
                                          , @clientID                /* Limit to client */
                                          , @rdrGroupSvcClassNameID  /* Limit to group family */
                                          , @patID                   /* Only docs for patient */
                                          , null
                                          , null
                                          , null
                                          , null        
                                          , @orpDocID               /* Limit to specific doc*/
                                         )
       
	   /* Let rest of routine know we are done and we want to get current authorization data */

	   set @searchDone          = 1
       set @getLastApprovalData = 1
     
	 end /* ORP Doc ID specifically provided */
            
     /*###########################################################################
       # No orpDocID was specifically provided 
	   # So we attempt to autoselect a special authorization document
	   # This applies to OT, PT, and Speech Services Only
       #
	   # This is the next next highest priority assignment
	   ###########################################################################*/  

     if ((@searchDone = 0) and (@rdrGroupSvcClassNameID in (4,6,9))) 
     begin                                            
       
       select top 1
          
             @pracID          = orpPracID
           , @lastName        = orpLastName
           , @firstName       = orpFirstName
           , @npiNumber       = orpPracNpiNumber           
           , @isValidMcalOrp  = orpPracIsValidMcalOrp
           , @orpDocumentID   = id
           , @orpDocumentName = name
           , @orpDocTypeID    = orpDocTypeID
           , @orpDocRefID     = refID
     
       from dbo.ORP_DOCUMENTS_VIEW_CORE (  null
                                         , null
                                         , null
                                         , @clientID                /* Limit to client */
                                         , @rdrGroupSvcClassNameID  /* Limit to group family */
                                         , null
                                         , @dos                     /* Limit to docs that cover dos */
                                         , 1                        /* Limit to PBS docs*/
                                         , null
                                         , 1                        /* Active only */
                                         , null
                                        )                  
       
       /* If we found a document let rest of routine know we are done and we want to get current authorization data */

	   if (@orpDocumentID is not null) 
	   begin
	     set @searchDone          = 1 
	     set @getLastApprovalData = 1
	   end

       /* If we didnt find a document let rest of routine know that we need to keep looking */

	   else 
	   begin
	     set @searchDone          = 0
		 set @getLastApprovalData = 0
       end          
     
	 end /* Special Authorization */
             
     /*###########################################################################
       # If no special authorization document is available we attempt to 
	   # autoselect a "default" individual order.  This autoselection can be 
	   # peformed for all group families except health services.
       ###########################################################################*/  

	 if ((@searchDone = 0) and (dbo.IS_AUTO_SELECT_ORP_DOC_POSSIBLE ( @rdrGroupSvcClassNameID ) = 1))
     begin

	   set @autoMatchFound = 0

	   /*###########################################################################
         # Find the first order that either
		 #
		 #  - has approval for DOS
	     #  - or is active
         #  - or is most recently added
         #
		 # Note: We are using the sort order to do this
		 ###########################################################################*/  
                
	   select top 1
           @pracID          = orpPracID
         , @lastName        = orpLastName
         , @firstName       = orpFirstName
         , @npiNumber       = orpPracNpiNumber           
         , @isValidMcalOrp  = orpPracIsValidMcalOrp
         , @orpDocumentID   = id
         , @orpDocumentName = name
         , @orpDocTypeID    = orpDocTypeID
         , @orpDocRefID     = refID
         , @autoMatchFound  = 1
	  from
      (
        select 
            approvedOrder = iif( (la2.lastApprovedApprovalRecordID is null),0,1)
          , odvc.active
		  , odvc.id
		  , odvc.orpPracID
          , odvc.orpLastName
          , odvc.orpFirstName
          , odvc.orpPracNpiNumber           
          , odvc.orpPracIsValidMcalOrp
          , odvc.name
          , odvc.orpDocTypeID
		  , odvc.refID
        
        from dbo.ORP_DOCUMENTS_VIEW_CORE (  null
                                          , null
	  	  	    					      , null
								          , @clientID
								          , @rdrGroupSvcClassNameID   /* Limit to group family */
                                          , @patID
                                          , null
                                          , 2                         /* Orders only */
                                          , null
                                          , null                      /* Active and inactive */
                                          , null)  as odvc
        outer apply (
	      select top 1
	        la1.lastApprovedApprovalRecordID 
	       ,la1.lastApprovedForDOSOrpPracIsReadyFor837
		  from dbo.ORP_DOCUMENT_GET_LAST_APPROVED_FOR_DOS_DATA (@dos,odvc.id) as la1  
        ) as la2
      ) as wo
      order by 
          wo.approvedOrder desc
	    , wo.active        desc
        , wo.id            desc
	   
       /*###########################################################################
         # If we do NOT have any orders in the system that we can automatch then 
		 # we need to exit
         ###########################################################################*/ 
       
	   if (@autoMatchFound = 0) 
	   begin
	      
		  /* Let rest of routine know we are done and since we did not find a match we don't want
		     to get current authorization data */

		 set @searchDone          = 1
         set @getLastApprovalData = 0
	   end
       
	   /*###########################################################################
         # We have a match.
		 ###########################################################################*/ 
       
	   else	                           
	   begin
        
		/* Let rest of routine know we are done and that we want to get current authorization data */

	    set @searchDone          = 1    
        set @getLastApprovalData = 1

      end
      
    end /* Auto select individual order  */
         
    /*###########################################################################
      # If we reach this point and the search is not done then we need to assume
      # that we can't find anything
      ###########################################################################*/  

	if (@searchDone = 0)
	begin
	  
	  /* Let rest of routine know we are done and since we did not find an orp document to use
		 we don't need to get current authorization data */

	  set @searchDone          = 1    
	  set @getLastApprovalData = 0
	
	end /* Cant find anything */
  
    /*###########################################################################
      # Get ORP who has last approved the service based on authorization records
      # for ORP document ID and DOS
      #
      # Note: The last approval routine takes care of returning the ORP stored
      # with special authorization documents, so its OK to run this here
      ###########################################################################*/

    if ((@searchDone = 1) and (@getLastApprovalData = 1))
    begin

      set @pracID          = null
	  set @firstName       = null
	  set @lastName        = null
	  set @npiNumber       = null
	  set @isValidMcalOrp  = null


       select top 1

	       @pracID         = orp.lastApprovedForDOSOrpPracID
	     , @firstName      = orp.lastApprovedForDOSOrpFirstName
	     , @lastName       = orp.lastApprovedForDOSOrpLastName
	     , @npiNumber      = orp.lastApprovedForDOSOrpPracNpiNumber
	     , @isValidMcalOrp = orp.lastApprovedForDOSOrpPracIsValidMcalOrp
	
 	   from dbo.ORP_DOCUMENT_GET_LAST_APPROVED_FOR_DOS_DATA (@dos, @orpDocumentID) as orp
  
    end /* Get last approval data*/  
  end /* Is ORP required */
 
  /*###########################################################################
    # Return data
    ###########################################################################*/  
   
  insert into @data 
  
  values (   @orpRequired
           , @orpDocumentID
           , @orpDocumentName
           , @orpDocTypeID
           , @orpDocRefID  
           , @pracID
           , @lastName
           , @firstName
           , @npiNumber
           , @isValidMcalOrp )   
  
  return  

end

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[GET_ORP_PRAC_NPI_DATA] TO [webuser]
GO