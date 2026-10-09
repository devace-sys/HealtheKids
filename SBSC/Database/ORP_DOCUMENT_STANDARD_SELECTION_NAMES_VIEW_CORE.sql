USE SPEDMON
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.ORP_DOCUMENT_STANDARD_SELECTION_NAMES_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.ORP_DOCUMENT_STANDARD_SELECTION_NAMES_VIEW_CORE
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[ORP_DOCUMENT_STANDARD_SELECTION_NAMES_VIEW_CORE] (
   @userID                    BIGINT
 , @userGroup                 INT  
 , @userRank                  INT
 , @clientID                  BIGINT
 , @rdrGroupSvcClassNameID    BIGINT   
 , @active                    BIT
 , @recID                     BIGINT )    
 
RETURNS TABLE
 
 /***************************************************************************    
  * ORP_DOCUMENT_STANDARD_SELECTION_NAMES_VIEW_CORE */    
 /**    
  * Returns a table of entities
  *    
  * @param   userID         The userid of who is requesting the operation
  * @param   userGroup      Users group    
  * @param   userRank       User rank      
  * @param   active         Active 0 = No 1 = Yes
  * @param   recID          Entity record id
  * @return                 Table of patient data    
  ***************************************************************************/     
 
AS RETURN
( 
  select                    
      ssn.ID                           as id
    , ssn.NAME                         as name
    , ssn.CREATED                      as created
    , ssn.CREATED_BY                   as createdBy
    , ssn.LAST_MODIFIED                as lastModified
    , ssn.LAST_MODIFIED_BY             as lastModifiedBy
    , ssn.META_DFLT_SEL_FOR            as dftSelFor
    , ssn.GROUP_SERVICE_CLASS_NAME_ID  as groupSvcClassNameID
    , scn.GROUP_SERVICE_CLASS_NAME     as groupSvcClassName
    , ssn.NOTES                        as notes
	, ssn.svcDescTemplateText
	, ssn.noteCrit1TemplateText
	, ssn.noteCrit2TemplateText
	, ssn.noteCrit3TemplateText
	, ssn.noteCrit4TemplateText
	, ssn.noteCrit5TemplateText
	, ssn.noteCrit6TemplateText
	, ssn.noteCrit7TemplateText
	, ssn.noteCrit8TemplateText
	, ssn.noteCrit9TemplateText
	, ssn.noteCrit10TemplateText
    , ssn.ACTIVE                       as active
    , ssn.DISPLAY                      as display
	, ssn.allowMultipleOrders          as allowMultipleOrders
	, ssn.orderContextFieldName        as orderContextFieldName
	, ssn.formBuilderContentJSON       as formBuilderContentJSON
    , ssn.clientID                     as clientID
	, isnull(clc.CLIENT_NAME,N'')      as clientName
    , ssn.formBuilderContentForServiceJournalEntryNotesJSON
	, ssn.serviceJournalAssociatedEventTypeID

  from dbo.ORP_DOCUMENT_STANDARD_SELECTION_NAMES as ssn
  join dbo.GROUP_GROUP_SERVICE_CLASS_NAMES       as scn on scn.GROUP_SERVICE_CLASS_NAME_ID = ssn.GROUP_SERVICE_CLASS_NAME_ID

  left join dbo.CLIENTS_Client                   as clc on clc.CLIENT_ID = ssn.clientID

  where (
       (1=1)
   and ((@rdrGroupSvcClassNameID is null)  or (ssn.GROUP_SERVICE_CLASS_NAME_ID = @rdrGroupSvcClassNameID))
   and ((@active                 is null)  or (ssn.ACTIVE                      = @active))
   and ((@recID                  is null)  or (ssn.ID                          = @recID))
   and ((@clientID               is null)  or (ssn.clientID is null) or (ssn.clientID = @clientID)) 
)

)
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[ORP_DOCUMENT_STANDARD_SELECTION_NAMES_VIEW_CORE] TO [webuser]
GO