USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_RECORDS_APPROVAL_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SERVICE_RECORDS_APPROVAL_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[SERVICE_RECORDS_APPROVAL_VIEW_CORE] (
	@userID			      as bigint
  , @clientID             as bigint  
  , @groupID              as bigint
  , @approvingPracID      as bigint
  , @supervisionStartDate as datetime
  , @supervisionEndDate   as datetime
  , @pracID               as bigint
  , @patID                as bigint
  , @startEntryDate       as datetime
  , @endEntryDate         as datetime
  , @reviewed             as bit
  , @approved             as bit
  , @active               as bit
)    
returns table     
as    
    
/***************************************************************************    
 * SERVICE_RECORDS_APPROVAL_VIEW_CORE */    
/**    
 * Returns table of service records that have approval records.
 *    
 * @param  clientID      client ID
 * @param  groupID       practitioner group
 * @param  pracID        practitioner id
 * @param  reviewed      reviewed
 * @param  active
 * @return               Service records
 ***************************************************************************/     
    
return (    

select  
     [id]                   = sr.ID
   , [svcRecID]             = sr.svcRecID
   , [clientID]             = sr.clientID
   , [clientName]           = sr.ClientName
   , [dos]                  = sr.svcDateVal
   , [pracID]               = sr.pracID
   , [pracName]             = sr.PractitionerName
   , [pracGroupID]          = sr.groupID
   , [pracGroup]            = sr.GroupName
   , [patID]                = sr.patID
   , [patName]              = sr.PatientName
   , [svcName]              = sr.SvcName
   , [minsOrMiles]          = sr.MinsOrMiles
   , [reviewed]             = sr.SvcReviewedVal
   , [approved]             = sr.SvcApprovedVal
   , [svcDateStr]           = sr.SvcDateStr
   , [svcEnteredByUserID]   = sr.SvcEnteredByUserID
   , [svcEnteredByUserName] = sr.SvcEnteredByUserName
   , [svcFromJournal]       = sr.svcFromJournal
   , [journalID]            = sr.journalID
   , sr.planTypeSelectionName
   , sr.startTimeStr
   , sr.endTimeStr
   , sr.numMins
   , sr.notes
   , sr.privateNotes 
   , sr.renderingPractitionerSignature
   , sr.reviewingPractitionerSignature
   , sr.reviewedByNameRefID
   , sr.[SvcReviewNotes]
   , sr.startTimeVal
   , sr.endTimeVal
 --  , entryDateTimeStr = sr.SvcEnteredOnStr
 --  , entryDateTimeVal = sr.SvcEnteredOnVal
from dbo.SERVICE_RECORDS_REVIEW_VIEW_CORE (
    @userID
  , null
  , null
  , @clientID
  , @groupID
  , @pracID
  , @patID
  , @startEntryDate 
  , @endEntryDate
  , @reviewed
  , @approved
  , @active) as sr

/* Limits to supervision dates */

where 
  (sr.svcDateVal between @supervisionStartDate and @supervisionEndDate)

)


GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[SERVICE_RECORDS_APPROVAL_VIEW_CORE] TO [webuser]
GO