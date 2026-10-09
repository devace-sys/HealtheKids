USE [SPEDMON]
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENTS_Promised_Services_Delivery_Exceptions_View') AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PATIENTS_Promised_Services_Delivery_Exceptions_View
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[PATIENTS_Promised_Services_Delivery_Exceptions_View] (    
    @userID                        bigint
  , @userGroup                     int   
  , @userRank                      int
  , @source                        int
  , @clientID                      bigint
  , @patID                         bigint
  , @svcTrackingClass              int
  , @spEdServiceCode               int
  , @orpDocStandardSelectionNameID bigint
  , @planStartDate                 date
  , @planEndDate                   date
  , @reviewed                      bit
  , @active                        bit
)
 
RETURNS TABLE       
AS RETURN (      
    
/*-------------------------------    
 * Retrieve records   
 *------------------------------*/  

  select top (dbo.CONST_MAX_ROWS())
      vc.* 
	, clientName                       = clc.CLIENT_NAME
	, patName                          = pap.CONCAT_NAME
	, patDOB                           = pap.DATE_OF_BIRTH
	, patCSIS                          = trim(isnull(pap.CSIS,N''))
	, spEdFreqName                     = ssf.[name]

	, ss3.spEdServiceCodeStr
	, ss3.spEdServiceName
	, ss3.spEdServiceCodeName
	, serviceOrOrderName = case vc.svcTrackingClass 
	  when (dbo.CONST_SVC_TRACKING_CLASS_SPED())     then ss3.spEdServiceCodeName
	  when (dbo.CONST_SVC_TRACKING_CLASS_NON_SPED()) then ssn2.[NAME]
	  else ''
	 end

	, patDOBStr                          = dbo.RPT_DATE_FMT(pap.DATE_OF_BIRTH)
	, planStartDateStr                   = dbo.RPT_DATE_FMT(vc.planStartDate)
	, planEndDateStr                     = dbo.RPT_DATE_FMT(vc.planEndDate)
	, dosStartStr                        = dbo.RPT_DATE_FMT(vc.dosStart)
	, dosEndStr                          = dbo.RPT_DATE_FMT(vc.dosEnd)
	
  from dbo.PATIENTS_Promised_Services_Delivery_Exceptions_View_Core ( 
      @source 
    , @clientID
    , @patID   
    , @svcTrackingClass
    , @spEdServiceCode 
    , @orpDocStandardSelectionNameID
    , @planStartDate 
    , @planEndDate   
    , @reviewed 
	, @active) as vc

  join dbo.SpEd_Service_Frequency                                      as ssf     on ssf.codeValue  = vc.spEdFreqCode
  join dbo.CLIENTS_Client                                              as clc     on clc.CLIENT_ID  = vc.clientID
  join dbo.PATIENTS_Patient                                            as pap     on pap.PATIENT_ID = vc.patID
  
  /* For promised SpEd Services */

  outer apply (
    select top 1
	   ss2.*
	 , spEdServiceCodeName = ss2.spEdServiceCodeStr + ' - ' + ss2.spEdServiceName 
	from
	(
	  select top 1 
	     spEdServiceName    = ss1.[name]
	   , spEdServiceCodeStr = convert(varchar(50),ss1.codeValue)
	   
	  from dbo.SpEd_Service as ss1
	  where ( 
	        (vc.svcTrackingClass = dbo.CONST_SVC_TRACKING_CLASS_SPED())
	    and (ss1.codeValue = vc.spEdServiceCode)
      )
	) as ss2
  ) as ss3 
  
  /* For promised non-SpEd services */

  outer apply 
  (
    select top 1 
      ssn1.[NAME]
    from dbo.ORP_DOCUMENT_STANDARD_SELECTION_NAMES as ssn1
    where (
	      (vc.svcTrackingClass = dbo.CONST_SVC_TRACKING_CLASS_NON_SPED())
	  and (ssn1.ID = vc.orpDocStandardSelectionNameID)
	  )
  ) as ssn2

  order by 
    pap.CONCAT_NAME
  , pap.CSIS
  , pap.DATE_OF_BIRTH
)
  
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].PATIENTS_Promised_Services_Delivery_Exceptions_View TO [webuser]
GO   


