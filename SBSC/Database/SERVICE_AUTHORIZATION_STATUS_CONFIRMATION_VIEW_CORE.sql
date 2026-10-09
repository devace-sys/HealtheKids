USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_AUTHORIZATION_STATUS_CONFIRMATION_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SERVICE_AUTHORIZATION_STATUS_CONFIRMATION_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[SERVICE_AUTHORIZATION_STATUS_CONFIRMATION_VIEW_CORE] (
    @userID                            BIGINT
  , @userGroup                         INT  
  , @userRank                          INT  
  , @clientID                          BIGINT
  , @orpDocumentID                     BIGINT
  , @responseCode                      BIGINT
  , @active                            BIT
  , @recID                             BIGINT
)    

RETURNS TABLE
 
 /***************************************************************************    
  * SERVICE_AUTHORIZATION_STATUS_CONFIRMATION_VIEW_CORE */    
 /**    
  * 
  *
  * @return table 
  ***************************************************************************/                         
     
AS RETURN
(
  
  select
      sasc.id
	, sasc.orpDocumentID
    , responseCode        = sasc.confirmationResponseCode
	, responseName        = sascrc.name  
    , responseShortName   = sascrc.shortName
	, entrySourceCode     = sasces.code
	, entrySourceName     = sasces.name
    , sasc.orpPracID
	, orpPracName         = orp.CONCAT_NAME
    , orpPracTitle        = gg.GROUP_NAME
    , orpPracNPI          = orp.npiNumber 
    , sasc.effectiveDate
    , effectiveDateStr     = dbo.RPT_DATE_FMT(sasc.effectiveDate)
	, sasc.expirationDate
	, expirationDateStr    = dbo.RPT_DATE_FMT(sasc.expirationDate)
	, enteredOn            = sasc.created
	, enteredOnStr         = dbo.RPT_DATE_FMT(sasc.created)
	, enteredByUserID      = sasc.createdBy
	, enteredByUserName    = u.UserName
	, orpIsValidMcalOrp    = orp.isValidMcalOrp
	, orpIsValidMcalOrpStr = dbo.RPT_BIT_TO_YNU(orp.isValidMcalOrp)

  from dbo.SERVICE_AUTHORIZATION_STATUS_CONFIRMATION                as sasc
  join dbo.SERVICE_AUTHORIZATION_STATUS_CONFIRMATION_RESPONSE_CODES as sascrc on sascrc.code         = sasc.confirmationResponseCode
  join dbo.SERVICE_AUTHORIZATION_STATUS_CONFIRMATION_ENTRY_SOURCE   as sasces on sasces.code         = sasc.entrySourceCode
  join dbo.PRACTITIONER_Practitioner                                as orp    on orp.PRACTITIONER_ID = sasc.orpPracID  
  join dbo.PRACTITIONER_GROUPS                                      as pg     on pg.PRACTITIONER_ID  = orp.PRACTITIONER_ID and pg.GROUP_TYPE in (1,2)  
  join dbo.GROUP_GROUP                                              as gg     on gg.GROUP_ID         = pg.GROUP_ID         and gg.GROUP_TYPE in (1,2)    
  join users.dbo.Users                                              as u      on u.userrid           = sasc.createdBy
  
  where (
        (1=1)  
    and ((@orpDocumentID is null) or (sasc.orpDocumentID            = @orpDocumentID))
	and ((@responseCode  is null) or (sasc.confirmationResponseCode = @responseCode))
    and ((@clientID      is null) or (sasc.clientID                 = @clientID))
  )

)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON [dbo].[SERVICE_AUTHORIZATION_STATUS_CONFIRMATION_VIEW_CORE] TO [webuser]
GO  
