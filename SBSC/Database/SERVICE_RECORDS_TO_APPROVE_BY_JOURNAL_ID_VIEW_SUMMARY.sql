/*########################################################
 *#  Entry Point for Summary - Review Health Services    #
 *########################################################*/

USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_RECORDS_TO_APPROVE_BY_JOURNAL_ID_VIEW_SUMMARY') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SERVICE_RECORDS_TO_APPROVE_BY_JOURNAL_ID_VIEW_SUMMARY
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[SERVICE_RECORDS_TO_APPROVE_BY_JOURNAL_ID_VIEW_SUMMARY] (
    @userID          BIGINT  
  , @userGroup       INT    
  , @userRank        INT
  , @clientID        bigint
  , @siteID          bigint 
  , @pracID          bigint
  , @approvingPracID bigint
  , @startEntryDate  datetime
  , @endEntryDate    datetime
  , @assigned        bit
  , @journalID       bigint
  , @reviewed        bit )
      
returns table     
as    
    
/***************************************************************************    
 * SERVICE_RECORDS_TO_APPROVE_BY_JOURNAL_ID_VIEW_SUMMARY */    
/**    
 *     
 * @param  userID          User ID (Required)    
 * @param  userGroup       User group (Required)    
 * @param  userRank        User rank (Required)    
 * @param  clientID
 * @param  reviewingUserID
 * @param  pracID
 * @return                 Service records and svc notes
 ***************************************************************************/     
    
return (    
	with
	cte_p1
	as
	(
	  select distinct
		id                  = sra.journalID
	  , sra.pracName
      , sra.pracID
	  , pracUserID          = sra.svcEnteredByUserID
	  , pracNameForMessages = sra.svcEnteredByUserName
	  , sra.pracGroup       
	  , dosStr              = sra.svcDateStr
      , sra.patID
	  , sra.patName
	  , sra.dos
	  , held
	  , siteName                                  = sra.siteName
      , approvingPracID                           = @approvingPracID
      , pracIsSupervisedByApprovingPracID         = convert(bit,(iif((pds.currPracSupRecID is null),0,1)))
      , latestPracSupervisionByApprovingPracRecID = pds.currPracSupRecID
      , sra.svcFromJournal
	  , siteID = sra.siteID

	  from dbo.SERVICE_RECORDS_TO_APPROVE_BY_PRAC_ID_VIEW_CORE (  @userID 
																, @userGroup
																, @userRank
																, @clientID                                                            
																, @siteID
																, @approvingPracID
																, null
																, null
																, @startEntryDate 
																, @endEntryDate
																, @reviewed
																, null
																, @assigned ) as sra

	  outer apply (select top 1 
					 pds1.id as currPracSupRecID
				   from dbo.PRACTITIONER_PRACTITIONER_DIRECT_SUPERVISED_SUPERVISOR as pds1 
	               where (pds1.ACTIVE = 1 				    
	  			      and pds1.SUPERVISED_PRAC_ID = sra.pracID 
	                  and (
	                          (
                                  ((pds1.START_DATE is null) or (GETDATE() >= pds1.START_DATE))
                              and ((pds1.END_DATE   is null) or (GETDATE() <= pds1.END_DATE  ))
                              )
                          )
                      and pds1.SUPERVISING_PRAC_ID = @approvingPracID
					  and pds1.SHARE_NOTES = 0
					  and (pds1.relationshipTypeID = 10)
                   )
                   order by pds1.id desc
      ) as pds
	  where (
	          (1=1)
	      and ((@assigned is null) or (sra.assigned = @assigned))
	  )
	)
	select 
	  p1.* 
	from cte_p1 as p1	
)  
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[SERVICE_RECORDS_TO_APPROVE_BY_JOURNAL_ID_VIEW_SUMMARY] TO [webuser]
GO