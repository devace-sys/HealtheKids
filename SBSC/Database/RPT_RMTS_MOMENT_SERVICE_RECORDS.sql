USE SPEDMON
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RPT_RMTS_MOMENT_SERVICE_RECORDS') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))   
DROP FUNCTION dbo.RPT_RMTS_MOMENT_SERVICE_RECORDS  
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[RPT_RMTS_MOMENT_SERVICE_RECORDS]   
(
   @clientID   BIGINT 
)    
 
RETURNS TABLE
 
 /***************************************************************************    
  * RPT_RMTS_MOMENT_SERVICE_RECORDS */    
 /**    
  * Returns a table of report rows
  *    
  * @param   userID         The userid of who is requesting the report
  * @param   userGroup      Users group    
  * @param   userRank       User rank      
  * @return                 Table of report rows
  ***************************************************************************/     
 
AS RETURN
(
 
 
   select top (dbo.CONST_MAX_ROWS())

	   [Client]             = clc.CLIENT_NAME
	 , [Quarter]            = fq.QTR_DEFINITION
	 , [Date]               = dbo.RPT_DATE_FMT(sr.dos)
	 , [dos]                = sr.dos
	 , [StartTime]          = dbo.RPT_TIME_FMT(sr.startTime,0)
	 , [EndTime]            = dbo.RPT_TIME_FMT((iif(sr.startTime is not null,dateadd(minute,sr.numMins,sr.startTime),null)),0)
	 , [PracticeFamily]    = scn.GROUP_SERVICE_CLASS_NAME
	 , [Practitioner]       = prp.CONCAT_NAME + ' [' + gg.GROUP_NAME + ']'
	 , [Patient]            = pap.CONCAT_NAME + ' [' + dbo.RPT_DATE_FMT(pap.DATE_OF_BIRTH) + ']'
	 , [Minutes]            = sr.numMins
	 , [Notes]              = isnull(sr.notes,'')
	-- , [Service Record ID]        = sr.id      

	from dbo.CLIENTS_Client            as clc 
	join dbo.PRACTITIONER_Client       as prc on prc.CLIENT_ID = clc.CLIENT_ID
	join dbo.PRACTITIONER_Practitioner as prp on prp.PRACTITIONER_ID = prc.PRACTITIONER_ID
	join dbo.SERVICE_RECORDS           as sr  on ((sr.clientID = clc.CLIENT_ID) 
											  and (sr.pracID = prp.PRACTITIONER_ID))  
	join dbo.PATIENTS_Patient          as pap on pap.PATIENT_ID = sr.patID
	join dbo.GROUP_Group               as gg  on gg.GROUP_ID  = sr.groupID

	join dbo.GROUP_GROUP_SERVICE_CLASS_NAMES as scn on scn.GROUP_SERVICE_CLASS_NAME_ID = sr.pracGrpSvcClsNameID
	join dbo.COMPANY_FISCAL_QUARTERS         as fq  on sr.dos between fq.QTR_START and fq.QTR_END


	where (
		  (1=1)
	  and ((@clientID is null) or (clc.CLIENT_ID = @clientID))
  
	  and (sr.svcType  = 5)
	  and (sr.svcSubType1 = 5001)
	  and (sr.state != 99) /* Exclude deleted */
	)

	order by 
	  
	  clc.CLIENT_NAME
	, fq.QTR_DEFINITION 
	, sr.dos
	, sr.startTime
 
)
 
 
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[RPT_RMTS_MOMENT_SERVICE_RECORDS] TO [webuser]  
GO