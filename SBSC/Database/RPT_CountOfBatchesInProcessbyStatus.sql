USE [SPEDMON]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RPT_CountOfBatchesInProcessbyStatus]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[RPT_CountOfBatchesInProcessbyStatus]
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION  [dbo].[RPT_CountOfBatchesInProcessbyStatus] ()
RETURNS TABLE
 
 /***************************************************************************
 * RPT_Count_of_Batches__by_Status */
/**
 * Returns a table of report rows

 * @return                         Table of report rows
 ***************************************************************************/
 
 AS RETURN
 (

  SELECT top (dbo.CONST_MAX_ROWS())
     ibs.Status_Code															as 'Status Code'
	,ibs.Status																	as 'Status Description'
	,COUNT(ib.id)																as '# of Batches'
	--,isnull(SUM(ib.Estimated_Input_Hours),0)									as 'Hours'
	,isnull(convert(varchar(10),convert(date,MIN(ib.Date_Recieved))),'')		as 'Oldest Date Received'
	,isnull(convert(varchar(10),convert(date,MIN(ib.Oldest_DOS))),'')			as 'Oldest DOS'

FROM dbo.Input_Batches_Status			as ibs
	left outer join dbo.Input_Batches	as ib		on ibs.Status_Code = ib.Current_status_Code

WHERE 1=1
	and ibs.Status_Code in (10,30,50,60,70,80,85,90,100,110,130,250)		--Batches currently in Process
	
GROUP by ibs.Status_Code,ibs.Status --Current_status_Code, ib.Current_status_Code, ibs.Status 
order by ibs.Status_Code asc
)

GO

GRANT SELECT ON  [dbo].[RPT_CountOfBatchesInProcessbyStatus] TO [webuser]     
GO
 
