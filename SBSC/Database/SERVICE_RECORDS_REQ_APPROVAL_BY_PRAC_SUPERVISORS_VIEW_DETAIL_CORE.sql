USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_RECORDS_REQ_APPROVAL_BY_PRAC_SUPERVISORS_VIEW_DETAIL_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SERVICE_RECORDS_REQ_APPROVAL_BY_PRAC_SUPERVISORS_VIEW_DETAIL_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[SERVICE_RECORDS_REQ_APPROVAL_BY_PRAC_SUPERVISORS_VIEW_DETAIL_CORE] (
    @userID            BIGINT
  , @userGroup         INT  
  , @userRank          INT
  , @clientID          BIGINT )
      
returns table     
as    
    
/***************************************************************************    
 * SERVICE_RECORDS_REQ_APPROVAL_BY_PRAC_SUPERVISORS_VIEW_DETAIL_CORE */    
/**    
 *     
 * @param  userID          User ID (Required)    
 * @param  userGroup       User group (Required)    
 * @param  userRank        User rank (Required)    
 * @param  clientID
 * @param  pracID
 * @param  approvingPracID
 * @param  pracID
 * @return                 Service records and svc notes
 ***************************************************************************/     
    
return (    

select 
  [id]                  = ID
, [Client]              = ClientName
, [Practitioner]        = PractitionerName
, [ServiceDate]         = SvcDateStr
, [Patient]             = PatientName
, [ServiceProvided]     = SvcName
, [Minutes]             = MinsOrMiles
, [EnteredOn]           = SvcEnteredOnStr
, [EnteredByUserName]   = SvcEnteredByUserName
, [EnteredByUserEmail]  = SvcEnteredByUserEmail
, [EnteredByName]       = SvcEnteredByName
, [EnteredByTitle]      = SvcEnteredByTitle
, [Reviewed]            = SvcReviewedStr
, [ReviewedByUserName]  = SvcReviewedByUserName
, [ReviewedByUserEmail] = SvcReviewedByUserEmail
, [ReviewedByName]      = SvcReviewedByName
, [ReviewedByTitle]     = SvcReviewedByTitle
, [ReviewedOn]          = SvcReviewedOnStr
, [Approved]            = SvcApprovedStr

from dbo.SERVICE_RECORDS_REVIEW_VIEW_CORE (@userID, @userGroup, @userRank, @clientID, null, null, null, null, null, null, null,1) as t1

where 
  (t1.SvcReviewState > 1)

)  
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[SERVICE_RECORDS_REQ_APPROVAL_BY_PRAC_SUPERVISORS_VIEW_DETAIL_CORE] TO [webuser]
GO