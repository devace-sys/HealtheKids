USE SPEDMON
GO

CREATE OR ALTER VIEW [dbo].[View_Latest_Successful_Total_Pop_Imports] 
AS

select
  q1.clientID
, latestFileAcceptedOn = max(q1.fileAcceptedOn)
, latestSDI            = max(q1.structuredDataImportID)
, latestImportFromID   = max(q1.importFromFileReferenceID)
, latestPDI            = max(q1.id)
from
(
  select  
      pdi.clientID
    , pdi.importFromFileReferenceID
    , pdi.structuredDataImportID
    , pdi.id
    , pdi.fileAcceptedOn
 
  from dbo.Patient_Data_Imports as pdi 
  where (
	    (pdi.clientID is not null)
	and (pdi.fileSubClass            = 'TOTPOP')    
    and (pdi.structuredDataImportID    is not null)
	and (pdi.importFromFileReferenceID is not null)
	and (pdi.id                        is not null)
    and (pdi.fileAccepted            = 1)
    and (pdi.fileProcessingCompleted = 1)
    and (pdi.fileProcessingError     = 0)
    and (pdi.importRolledBack        = 0)
	and (pdi.active                  = 1)
  )
) as q1
group by 
  q1.clientID

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[View_Latest_Successful_Total_Pop_Imports] TO [webuser]
GO
