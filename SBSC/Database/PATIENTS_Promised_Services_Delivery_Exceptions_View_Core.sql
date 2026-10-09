USE [SPEDMON]
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENTS_Promised_Services_Delivery_Exceptions_View_Core') AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PATIENTS_Promised_Services_Delivery_Exceptions_View_Core
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[PATIENTS_Promised_Services_Delivery_Exceptions_View_Core] (    
    @source                        int
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
returns
table
as
return
(
  
  select 
	
	  ppsde.*
  	, deliveryExceptionAddedReasonName   = ppsdear.[name]
	, createdByUserName                  = u1.UserName
	, removedByUserName                  = u2.UserName
	, deliveryExceptionRemovedReasonName = ppsderr.[name]
	, reviewedByUserName                 = u3.UserName

  from dbo.PATIENTS_Promised_Services_Delivery_Exceptions_View_Data_Core ( 
      @source 
    , @clientID
    , @patID   
    , @svcTrackingClass
    , @spEdServiceCode 
    , @orpDocStandardSelectionNameID
    , @planStartDate 
    , @planEndDate   
	, @reviewed
    , @active) as vdc

  /* Data core only returns record ids so we join to table to get rest of data */

  join dbo.PATIENTS_Promised_Services_Delivery_Exceptions              as ppsde   on ppsde.id = vdc.id
  
  /* For who created */

  join users.dbo.Users                                                 as u1      on u1.userrid = ppsde.createdBy 
  join dbo.PATIENTS_Promised_Services_Delivery_Exception_Added_Reasons as ppsdear on ppsdear.id = ppsde.deliveryExceptionAddedReasonID

  /* For removals */

  left join users.dbo.Users                                                   as u2      on u2.userrid = ppsde.removedBy
  left join dbo.PATIENTS_Promised_Services_Delivery_Exception_Removed_Reasons as ppsderr on ppsderr.id = ppsde.deliveryExceptionRemovedReasonID

  /* For Reviews */

  left join users.dbo.Users                                                   as u3      on u3.userrid = ppsde.reviewedBy

)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].PATIENTS_Promised_Services_Delivery_Exceptions_View_Core TO [webuser]
GO   


