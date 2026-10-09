USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SVCJOURNAL_JOURNAL_ORP_DOCS_ORDERS_PROFILES_VIEW_EXISTING_FOR_CLIENT_GROUP_SVC_CLASS_PAT_STD_SEL_NAME') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SVCJOURNAL_JOURNAL_ORP_DOCS_ORDERS_PROFILES_VIEW_EXISTING_FOR_CLIENT_GROUP_SVC_CLASS_PAT_STD_SEL_NAME
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[SVCJOURNAL_JOURNAL_ORP_DOCS_ORDERS_PROFILES_VIEW_EXISTING_FOR_CLIENT_GROUP_SVC_CLASS_PAT_STD_SEL_NAME] (
    @userID                   bigint
  , @userGroup                int  
  , @userRank                 int
  , @clientID                 bigint
  , @groupSvcClassNameID      bigint
  , @patID                    bigint
  , @orpDocStdSelNameID       bigint
  , @active                   bit
)    

RETURNS TABLE
 
/*********************************************************************************************************    
 * SVCJOURNAL_JOURNAL_ORP_DOCS_ORDERS_PROFILES_VIEW_EXISTING_FOR_CLIENT_GROUP_SVC_CLASS_PAT_STD_SEL_NAME */    
/**    
 * Returns 
 *
 * @return table 
 ********************************************************************************************************/                         
     
AS RETURN
(

select 
	  [id]       = oddc.ID
    , [name]     = oddc.ORP_DOCUMENT_STANDARD_SELECTION_NAME	
    , [context1] = oddc.viewSelContext1 
	, oddc.REFERENCE_ID

  from dbo.ORP_DOCUMENTS_DATA_CORE (@clientID,@groupSvcClassNameID,@patID,null,@active,null,null) as oddc
  where (
        (oddc.ORP_DOCUMENT_TYPE_ID != 1) /* Just search through 2 and 3 */
	and (oddc.ORP_DOCUMENT_STANDARD_SELECTION_NAME_ID = @orpDocStdSelNameID)
    and (oddc.allowMultipleOrders = 0)
  )
  
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[SVCJOURNAL_JOURNAL_ORP_DOCS_ORDERS_PROFILES_VIEW_EXISTING_FOR_CLIENT_GROUP_SVC_CLASS_PAT_STD_SEL_NAME] TO [webuser]
GO  
