USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[SpEd_Service_GroupServiceClassNamesNotAssigned]'))
DROP VIEW [dbo].[SpEd_Service_GroupServiceClassNamesNotAssigned]
GO

CREATE VIEW [dbo].[SpEd_Service_GroupServiceClassNamesNotAssigned] 
AS 
(

/***************************************************************************    
 * SpEd_Service_GroupServiceClassNamesNotAssigned */    
/**    
 * 
 * @return table
 ***************************************************************************/     

select 
    spEdSvcCodeValue    = ss.codeValue
  , groupSvcClassNameID = -1
  , groupSvcClassName   = '' 
from dbo.SpEd_Service as ss
left join dbo.SpEd_Service_GroupServiceClassNames as scn on scn.spEdSvcCodeValue = ss.codeValue
where ( 
      (ss.active = 1)
  and (scn.spEdSvcCodeValue is null)
)

)
GO


