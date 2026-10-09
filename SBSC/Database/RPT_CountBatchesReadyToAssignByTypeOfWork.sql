USE [SPEDMON]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RPT_CountBatchesReadyToAssignByTypeOfWork]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[RPT_CountBatchesReadyToAssignByTypeOfWork]
GO


 
/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION  [dbo].[RPT_CountBatchesReadyToAssignByTypeOfWork]

(
)

RETURNS TABLE
 
 /***************************************************************************
 * RPT_CountBatchesReadyToAssignByTypeOfWork */
/**
 * Returns a table of report rows

 * @return                         Table of report rows
 ***************************************************************************/
 
 AS RETURN
--THIS IS AN INLINE TVF/UDF BECAUSE THE SYNTAX USED IS "AS RETURN".  WE CANNOT "DECLARE" ANY VARIABLES.

 
 ----*************************************************************************************************************
--2 - This section counts the batches in each by WORK TYPE
--*************************************************************************************************************

SELECT
	--'2 - Count by Work Type'																	as 'Section'
	tw.WorkType																    as 'Type of Work'
	,COUNT(ib.id)																as '# of Batches'
	--,isnull(SUM(ib.Estimated_Input_Hours),0)									as 'Hours'
	,isnull(convert(varchar(10),convert(date,MIN(ib.Date_Recieved))),0)			as 'Oldest Date Received'
	,isnull(convert(varchar(10),convert(date,MIN(ib.Oldest_DOS))),0)			as 'Oldest DOS'
	,ISNULL(YearCount.Batches_Past_Year,0)									    as 'Batches in Past Year'
	--,ISNULL(YearCount.Hours_past_year,0)										as 'Hours in Past Year'

FROM	dbo.TYPE_OF_WORK					as tw
	left outer join dbo.Input_Batches		as ib		on ib.Type_Of_Work = tw.id
															and ib.Current_status_Code = 50
	left outer join (
		SELECT
		tw.WorkType
		,COUNT(ib.id)								as Batches_Past_Year
		,SUM(ib.Estimated_Input_Hours)				as Hours_past_year
	 
		FROM Input_Batches							as ib
			join TYPE_OF_WORK						as tw	on tw.id = ib.Type_Of_Work
																WHERE 1=1
																	and ib.Date_Recieved >= DATEADD(year,-1, GETDATE())
																	and Partial_File <> 1
																GROUP by ib.Type_Of_Work,tw.WorkType
																	)											
																	as YearCount on tw.WorkType = YearCount.WorkType
WHERE 1=1
		and tw.WorkType not in (
		 'ADR - Audiometrist'
		,'AUD - Audiology'
		,'COTA - Certified Occupational Therapist Assistant'
		,'DR - Physician'
		,'DRPSY - Psychiatrist'
		,'DRPSY - Psychiatrist'
		,'OPT - Optometrist'
		,'SLPA - Speech Language Pathologist Assistant'
		,'TCM - Case Manager'
		,'TCM - RSP Teacher'
		,'TCM - SDC Teacher'
		,'TCM - Teacher, General Education')
	
GROUP by  tw.WorkType, YearCount.Batches_Past_Year, YearCount.Hours_past_year	

GO

--ORDER by [# of Batches] desc

---SELECT * FROM [dbo].[RPT_CountBatchesReadyToAssignByTypeOfWork]( )
 
 
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[RPT_CountBatchesReadyToAssignByTypeOfWork] TO [webuser]     
GO
