USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.REPORT_PUBLICATION_DISTRIBUTION_TRACKING_SHEET_STYLE_SUMMARY') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION REPORT_PUBLICATION_DISTRIBUTION_TRACKING_SHEET_STYLE_SUMMARY
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[REPORT_PUBLICATION_DISTRIBUTION_TRACKING_SHEET_STYLE_SUMMARY]    
()    

RETURNS TABLE
 
 /***************************************************************************    
  * REPORT_PUBLICATION_DISTRIBUTION_TRACKING_SHEET_STYLE_SUMMARY */    
 /**    
  * Returns distribution list in a form similar to what the original tracking
  * sheet shows
  *
  * @return table 
  ***************************************************************************/                         
     
AS RETURN
(

select top (dbo.CONST_MAX_ROWS()) 
  [ClientID],
  [District],
  [RepName] = [RepFirstName] + ' ' + [RepLastName],
  [RepPhone],
  [Frequency],
  [Emails],
  [RepEmail]
from
(
select 

  ClientID,
  ClientName         as [District],
  RepNameFirst       as [RepFirstName],
  RepNameLast        as [RepLastName],
  [RepPhone],
  [Frequency] = substring((SELECT ( ', ' + PublicationTrackingSheetDescription )
                           FROM REPORT_PUBLICATION_DISTRIBUTION_VIEW(0,0,0,null,dbo.CONST_MAX_DATETIME(),null) as t2
                           WHERE (t1.ClientName = t2.ClientName) and (t1.DistributeToEmails = t2.DistributeToEmails)
                           FOR XML PATH( '' )
                         ), 3, 1000 ),  
  DistributeToEmails as [Emails],
  [RepEmail]

from 
  REPORT_PUBLICATION_DISTRIBUTION_VIEW(0,0,0,null,dbo.CONST_MAX_DATETIME(),null) as t1
where (IsRetry = 0)
group by 
  ClientID,
  ClientName, 
  RepNameFirst,
  RepNameLast,
  RepPhone,
  DistributeToEmails,
  RepEmail 

) as q1
order by [District]


)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[REPORT_PUBLICATION_DISTRIBUTION_TRACKING_SHEET_STYLE_SUMMARY] TO [webuser]
GO   
