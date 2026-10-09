USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_AUTHORIZATION_STATUS_CONFIRMATION_MANAGE_DATA_CORE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.SERVICE_AUTHORIZATION_STATUS_CONFIRMATION_MANAGE_DATA_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/


CREATE PROCEDURE [dbo].[SERVICE_AUTHORIZATION_STATUS_CONFIRMATION_MANAGE_DATA_CORE] (    
    @clientID                       BIGINT
  , @patID                          BIGINT
  , @pracID                         BIGINT
  , @orpPracID                      BIGINT
  , @effectiveDate                  DATE 
  , @expirationDate                 DATE
  , @responseCode                   BIGINT
  , @reqSvcAuthFromSelectionID      BIGINT
  , @svcAuthorizationRequestTypeID  BIGINT
  , @referencedEntityID             BIGINT
  , @orpDocumentID                  BIGINT
  , @serviceAuthorizationRequestID  BIGINT
  , @entrySourceCode                BIGINT
  , @today                          DATETIME
  , @userID                         BIGINT      
  , @statusConfirmationRuleIDApplied          BIGINT  OUTPUT
  , @createDirectAuthorizationRequestResponse BIT     OUTPUT
  , @recordID                                 BIGINT  OUTPUT  
)  

AS    
BEGIN    
   
/***************************************************************************    
 * SERVICE_AUTHORIZATION_STATUS_CONFIRMATION_MANAGE_DATA_CORE */
/**    
 * 
 ***************************************************************************/        
     
SET NOCOUNT ON    

   
declare @createConfirmationRecord                            as bit = null
declare @deactivateAllConfirmationRecordsRelatedToSvcRequest as bit = null

set @recordID                        = null
set @statusConfirmationRuleIDApplied = null
set @createConfirmationRecord        = null

/* If no ORP has been selected then there is nothing to do */

set @orpPracID = isnull(@orpPracID,0)
if (@orpPracID = 0) return (0)


if @today is null set @today = getdate()

if (@effectiveDate  is null) set @effectiveDate  = convert(date,@today)

/* Expiration date unless otherwise speficied will be one year from effective date */

if (@expirationDate is null) set @expirationDate = DATEADD(year,1,@effectiveDate)

/* Sanity check on dates.  Effective date cannot be after expiration date. */

if (@effectiveDate > @expirationDate)
begin
  RAISERROR ('The service authorization expiration date cannot before the effective date', 11, 1)
end

/* Sanity check on dates. - Effective date and expiration date cannot be before patients date of birth */

if (isnull(@patID,0) != 0)
begin
  
  /* Get patients date of birth*/

  declare @patDOB as date = null
  
  select top 1 @patDOB = convert(date,pap.DATE_OF_BIRTH) from dbo.PATIENTS_Patient as pap where pap.PATIENT_ID = @patID 

  /* If date of birth is found check it against effective and expiration dates */

  if (@patDOB is not null)
  begin
    if (@effectiveDate < @patDOB)
    begin
      RAISERROR ('The service authorization effective date cannot before the patients date of birth', 11, 1)
    end
    if (@expirationDate < @patDOB)
    begin
      RAISERROR ('The service authorization expiration date cannot before the patients date of birth', 11, 1)
    end
  end
  
  /* If date of birth is not found there is a problem */

  else
  begin
      RAISERROR ('The patients date of birth could not be found', 11, 1)
  end
end

/* Rules check  */

select top 1

    @statusConfirmationRuleIDApplied                      = t1.id
  , @createDirectAuthorizationRequestResponse             = t1.createDirectAuthorizationRequestResponse
  , @createConfirmationRecord                             = t1.createConfirmationRecord
  , @deactivateAllConfirmationRecordsRelatedToSvcRequest  = t1.deactivateAllConfirmationRecordsRelatedToSvcRequest

from dbo.SERVICE_AUTHORIZATION_STATUS_CONFIRMATION_RULES as t1
where (
      (t1.entrySourceCode               = @entrySourceCode)
  and (t1.svcAuthRequestFromID          = @reqSvcAuthFromSelectionID)
  and (t1.svcAuthorizationRequestTypeID = @svcAuthorizationRequestTypeID)
  and (t1.responseCode                  = @responseCode) 
  and (t1.active                        = 1)
)

/* If no rule was found get out */

if (@statusConfirmationRuleIDApplied is null)
begin
    --RAISERROR ('Authorization status rule not found', 11, 1)
    return(0)
end

/* If we are creating a direct authorization then get out
 * The authorization system will take care of calling this procedure in the proper
 * way to record the authorization status */

if (@createDirectAuthorizationRequestResponse = 1) return(0)

/* If the rule says to create a record then do so */

if (@createConfirmationRecord  = 1)
begin
  
  insert into dbo.SERVICE_AUTHORIZATION_STATUS_CONFIRMATION (
      [clientID] 
    , [patID] 
    , [pracID] 
    , [orpPracID] 
    , [effectiveDate] 
    , [expirationDate] 
    , [confirmationResponseCode] 
    , [svcAuthorizationRequestTypeID] 
    , [referencedEntityID] 
    , [orpDocumentID]
    , [serviceAuthorizationRequestID]   
    , [entrySourceCode] 
    , [statusConfirmationRuleID]
    , [created]  
    , [createdBy]
  )
  values (
      @clientID
    , @patID
    , @pracID
    , @orpPracID
    , @effectiveDate
    , @expirationDate
    , @responseCode
    , @svcAuthorizationRequestTypeID
    , @referencedEntityID
    , @orpDocumentID
    , @serviceAuthorizationRequestID
    , @entrySourceCode
    , @statusConfirmationRuleIDApplied    
    , @today  
    , @userID
  )
  set @recordID = SCOPE_IDENTITY()
end

--if (@deactivateAllConfirmationRecordsRelatedToSvcRequest = 1)
--begin  
--  print 'set to cancelled'
--end

/*============================================================
 * All done
 *============================================================*/      

RETURN(0)    

END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[SERVICE_AUTHORIZATION_STATUS_CONFIRMATION_MANAGE_DATA_CORE] TO [webuser]
GO
