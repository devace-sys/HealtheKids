USE SPEDMON
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PLAN_WRITER_PLANS_PRESCRIBED_ORDERS_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PLAN_WRITER_PLANS_PRESCRIBED_ORDERS_VIEW_CORE
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[PLAN_WRITER_PLANS_PRESCRIBED_ORDERS_VIEW_CORE] (
  @userID              BIGINT,    
  @userGroup           INT,    
  @userRank            INT,
  @clientID            BIGINT, 
  @groupSvcClassNameID bigint,
  @planID              bigint,
  @active              BIT,
  @recID               INT )    
 
RETURNS TABLE
 
 /***************************************************************************    
  * PLAN_WRITER_PLANS_PRESCRIBED_ORDERS_VIEW_CORE */    
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

    sjpo.*
  ,	requestID = sar.id
  , od.ORP_DOCUMENT_STANDARD_SELECTION_NAME_ID 
  , ORP_DOCUMENT_STANDARD_SELECTION_NAME = odssn.NAME 
  , PLAN_ID                              = pwp.ID
  , useInPlan         = convert(bit,case when pwpcpo.id is null then 0 else 1 end)
    
from dbo.PLAN_WRITER_PLANS_VIEW_CORE(				@userID
                                                  , @userGroup
                                                  , @userRank
                                                  , @clientID
                                                  , null
                                                  , @groupSvcClassNameID
                                                  , @active
                                                  , @planID )  as pwp

cross apply dbo.SVCJOURNAL_JOURNAL_ORP_DOCS_ORDERS_PROFILES_VIEW_CORE (
    @userID                 
  , @userGroup              
  , @userRank               
  , pwp.CLIENT_ID               
  , null -- @pracID                 
  , null -- @groupSvcClassNameID    
  , pwp.PATIENT_ID                   
  , null -- @referenceDate          
  , null -- @startRefDate           
  , null -- @endRefDate             
  , null -- @maxRow                 
  , null -- @orpApprovalState       
  , null -- @recID                  
  , 1    -- @active                 
) sjpo  
                                                   
join   dbo.ORP_DOCUMENTS                         as od    on od.ID                    = sjpo.ORP_DOCUMENT_ID
join   dbo.ORP_DOCUMENT_STANDARD_SELECTION_NAMES as odssn on odssn.ID                 = od.ORP_DOCUMENT_STANDARD_SELECTION_NAME_ID

join dbo.PLAN_WRITER_PLANS_CONDITIONS_PRESCRIBED_ORDERS_FLAGGED_FOR_USE as pwpcpo on  pwpcpo.PLAN_ID             = pwp.ID
                                                                                       and pwpcpo.PRESCRIBED_ORDER_ID = sjpo.refID
outer apply (select top 1 * from dbo.SERVICE_AUTHORIZATION_REQUESTS as sar where sar.orpDocID = sjpo.ORP_DOCUMENT_ID order by id desc) as sar
                                                                            
where (
       (1=1)   
   and ((@active  is null)  or  (pwp.ACTIVE  = @active))
   and ((@recID   is null)  or  (pwpcpo.ID      = @recID))
)

)
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PLAN_WRITER_PLANS_PRESCRIBED_ORDERS_VIEW_CORE] TO [webuser]
GO