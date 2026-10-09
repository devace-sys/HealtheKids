USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_AUTHORIZATION_REQUEST_FORM_DATA_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SERVICE_AUTHORIZATION_REQUEST_FORM_DATA_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[SERVICE_AUTHORIZATION_REQUEST_FORM_DATA_VIEW] (
    @userID                            BIGINT
  , @userGroup                         INT  
  , @userRank                          INT
  , @requestID                         INT
)    

RETURNS TABLE
 
 /***************************************************************************    
  * SERVICE_AUTHORIZATION_REQUEST_FORM_DATA_VIEW */    
 /**    
  * Retuns a list of service authorization requests that userId is permitted
  * to view
  *
  * @return table 
  ***************************************************************************/                         
     
AS RETURN
(
  select top 1
	  formQuestionsJSON = sjpo.formBuilderQuestionsJSON
	, formAnswersJSON   = sjpo.formBuilderAnswersJSON
  from dbo.SERVICE_AUTHORIZATION_REQUESTS        as sar
  join dbo.SvcJournal_Prescribed_Orders          as sjpo  on sjpo.id  = sar.referencedEntityID
  where
  (
        (sar.id = @requestID) 
	and (sar.svcAuthorizationRequestTypeID = 1)
  )
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[SERVICE_AUTHORIZATION_REQUEST_FORM_DATA_VIEW] TO [webuser]
GO  
