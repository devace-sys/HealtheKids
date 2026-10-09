USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.REPORT_PUB_MAN_DIST_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.REPORT_PUB_MAN_DIST_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[REPORT_PUB_MAN_DIST_VIEW] (@managedBy as varchar(1000))    

RETURNS TABLE
 
 /***************************************************************************    
  * REPORT_PUB_MAN_DIST_VIEW */    
 /**    
  * Returns manual distribution list for report distribution 
  *
  * @return table 
  ***************************************************************************/                         
     
AS RETURN
(


select top (dbo.CONST_MAX_ROWS()) 
  ClientName                                     as [Client],
  PublicationTrackingSheetDescription            as [Period],
  PublicationDescription                         as [Publication],  
  DistributeToEmails                             as [Email TO],
  RepEmail                                       as [Email CC],
  RepNameFirst    + ' ' + RepNameLast            as [Rep],
  RepPhone                                       as [Rep Phone],
  RepEmail                                       as [Rep Email],
  ManagedByEmails                                as [Distributed By]

from REPORT_PUBLICATION_DISTRIBUTION_VIEW (null,null,null,null,dbo.CONST_MAX_DATETIME(),0)

where 
  (1=1)
  and (@managedBy is null) or (ManagedByEmails = @managedBy)

order by 
  ManagedByEmails, 
  ClientName, 
  PublicationID 

)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[REPORT_PUB_MAN_DIST_VIEW] TO [webuser]
GO   
