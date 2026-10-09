USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SVCJOURNAL_JOURNAL_SERVICE_DESCRIPTION_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION SVCJOURNAL_JOURNAL_SERVICE_DESCRIPTION_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[SVCJOURNAL_JOURNAL_SERVICE_DESCRIPTION_VIEW] (
    @userID            BIGINT
  , @userGroup         INT  
  , @userRank          INT      
  , @clientID          BIGINT
  , @patID             BIGINT
  , @referenceDate     DATE
  , @maxRow            INT
  , @recID             BIGINT
  , @active            BIT
)    

RETURNS TABLE
 
 /***************************************************************************    
  * SVCJOURNAL_JOURNAL_SERVICE_DESCRIPTION_VIEW */    
 /**    
  * Returns 
  *
  * @return table 
  ***************************************************************************/                         
     
AS RETURN
(
  
  select top (isnull(@maxRow,dbo.CONST_MAX_ROWS()))
    
      sjsd.* 
    , clientName             = cc.CLIENT_NAME
    , patName                = pp.CONCAT_NAME
    , effectiveDateStr       = dbo.RPT_DATE_FMT(sjsd.effectiveDate)
    , createdStr             = dbo.RPT_DATE_FMT(sjsd.created)
    , lastModifiedStr        = dbo.RPT_DATE_FMT(sjsd.lastModified)
    , createdByUserName      = isnull(ucb.UserName,'')
    , lastModifiedByUserName = isnull(umb.UserName,'')
	, displayLastApproval    = convert(bit,(case when (sjsd.lastApprovalEffectiveDateStr is null) then 0 else 1 end))
 
    
  from dbo.SVCJOURNAL_JOURNAL_SERVICE_DESCRIPTION_VIEW_CORE (   @userID
                                                              , @userGroup
                                                              , @userRank
                                                              , @clientID
                                                              , @patID
                                                              , @referenceDate
                                                              , @maxRow
                                                              , @recID
															  , @active ) as sjsd
                                                              
  join dbo.PATIENTS_PATIENT   as pp   on pp.PATIENT_ID = sjsd.patID 
  join dbo.CLIENTS_Client     as cc   on cc.CLIENT_ID  = sjsd.clientID  
 
  left join users.dbo.Users   as ucb  on ucb.userrid   = sjsd.createdBy
  left join users.dbo.Users   as umb  on umb.userrid   = sjsd.lastModifiedBy
  
  order by
      cc.CLIENT_NAME
    , pp.CONCAT_NAME
    , sjsd.effectiveDate desc

)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[SVCJOURNAL_JOURNAL_SERVICE_DESCRIPTION_VIEW] TO [webuser]
GO  
