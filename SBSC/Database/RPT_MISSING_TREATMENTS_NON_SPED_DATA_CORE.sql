USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RPT_MISSING_TREATMENTS_NON_SPED_DATA_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RPT_MISSING_TREATMENTS_NON_SPED_DATA_CORE
GO


CREATE FUNCTION [dbo].[RPT_MISSING_TREATMENTS_NON_SPED_DATA_CORE] (
   @clientID             bigint  = null
 , @groupSvcClassNameID  bigint  = null
 , @patHasBIC            bit     = null  
 , @leaBopSvc            bit     = null
 , @missingTmt           bit     = null
)
returns
table
as
return
(

  select 
      ss.clientID
    , ss.patID
    , groupServiceClassNameID       = ss.groupSvcClassNameID
    , groupServiceClassNames        = gsn.GROUP_SERVICE_CLASS_NAME
    , planStart                     = ss.planStartDate
    , planEnd                       = ss.planEndDate
    , spEdServiceCode               = -1
	, spEdServiceCodeStr            = ''
    , spEdServiceName               = ''
    , spEdServiceCodeName           = ''
	, orpDocStandardSelectionNameID = ss.orpDocStandardSelectionNameID
    , orpDocStandardSelectionName   = ssn.NAME
	, orpDocID                      = ss.orpDocID
    , svcTrackingClass              = dbo.CONST_SVC_TRACKING_CLASS_NON_SPED()
    , serviceOrOrderName            = 'Non IEP - ' + gsn.GROUP_SERVICE_CLASS_NAME 
    , numMinsExpected               = ss.totalMinutesExpected
    , numMinsApplicable             = ss.totalMinutesSatisfied
    , minsExpectedApplicableDiff    = ss.diffMinutesExpectedSatified
    , estLostReimburse              = ss.potentialLostReimbursment
	, ss.spEdFreqCode
	, spEdFreqName = isnull(ssf.[name],'')
	, ss.minsPerFreq
    , id                            = ss.idx
	
  from dbo.PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_NON_SPED_SERVICES_ORP_DOC_SUMMARY_VIEW_DATA_CORE (
      @clientID
    , null
    , @groupSvcClassNameID
    , null /*@orpDocID */
    , null /*@planInEffectStartDate*/
    , null /*@planInEffectEndDate */
    , @patHasBIC
    , null
    , @leaBopSvc
    , 1   
    , 1
    , 1
    , 1
    , 0
	, 0 /* Exit without calc*/) as ss
  join      dbo.GROUP_GROUP_SERVICE_CLASS_NAMES        as gsn on gsn.GROUP_SERVICE_CLASS_NAME_ID = ss.groupSvcClassNameID
  join      dbo.ORP_DOCUMENT_STANDARD_SELECTION_NAMES  as ssn on ssn.id                          = ss.orpDocStandardSelectionNameID
  left join dbo.SpEd_Service_Frequency                 as ssf on ssf.codeValue = ss.spEdFreqCode
  where (
	     (1=1)
     and ((@missingTmt is null) or (ss.lessThanExpected = @missingTmt))
  )
)
GO

/*-------------------------------
* User Permissions
*------------------------------*/

GRANT SELECT ON  dbo.RPT_MISSING_TREATMENTS_NON_SPED_DATA_CORE TO [webuser]
GO