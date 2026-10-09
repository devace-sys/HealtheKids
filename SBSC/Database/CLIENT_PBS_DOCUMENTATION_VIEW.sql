USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLIENT_PBS_DOCUMENTATION_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CLIENT_PBS_DOCUMENTATION_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[CLIENT_PBS_DOCUMENTATION_VIEW] (
    @userID              BIGINT
  , @userGroup           INT  
  , @userRank            INT 
  , @clientID            BIGINT
  , @groupSvcClassNameID BIGINT /* 9 = Speech */
  , @active              BIT 
  , @recID               BIGINT 
)    

RETURNS TABLE
 
 /***************************************************************************    
  * CLIENT_PBS_DOCUMENTATION_VIEW */    
 /**    
  * Returns 
  *
  * @return table 
  ***************************************************************************/                         
     
AS RETURN
(
  with
  cte_p1
  as
  (  
    select   
        id                      = pbs.ID
      , name                    = 'Special Authorization Document for '
                                + ggscn.GROUP_SERVICE_CLASS_NAME                                
      , clientID                = pbs.CLIENT_ID
      , clientName              = clc.CLIENT_NAME
      , groupServiceClassNameID = pbs.GROUP_SERVICE_CLASS_NAME_ID
      , groupServiceClassName   = ggscn.GROUP_SERVICE_CLASS_NAME    
      , orpPracID               = pbs.ORP_PRAC_ID
      , orpPracName             = prp.CONCAT_NAME
      , orpPracNPI              = prp.npiNumber
      , startDate               = pbs.START_DATE
      , startDateStr            = dbo.RPT_DATE_FMT(pbs.START_DATE)
      , endDate                 = pbs.END_DATE
      , endDateStr              = dbo.RPT_DATE_FMT(pbs.END_DATE)
      , notes                   = pbs.NOTES 
      , active                  = pbs.active
      
    from dbo.CLIENT_PBS_DOCUMENTATION        as pbs
    join dbo.CLIENTS_CLIENT                  as clc   on clc.CLIENT_ID                     = pbs.CLIENT_ID
    join dbo.GROUP_GROUP_SERVICE_CLASS_NAMES as ggscn on ggscn.GROUP_SERVICE_CLASS_NAME_ID = pbs.GROUP_SERVICE_CLASS_NAME_ID
    join dbo.PRACTITIONER_Practitioner       as prp   on prp.PRACTITIONER_ID               = pbs.ORP_PRAC_ID
  
    where (
        (1=1)
      and ((@clientID            is null) or (pbs.CLIENT_ID                   = @clientID))
      and ((@recID               is null) or (pbs.id                          = @recID))
      and ((@groupSvcClassNameID is null) or (pbs.GROUP_SERVICE_CLASS_NAME_ID = @groupSvcClassNameID))
      and ((@active              is null) or (pbs.ACTIVE                      = @active))    
    )
  )
  
  select top (dbo.CONST_MAX_ROWS()) 
    * 
  
  from cte_p1
  
  order by
  
      clientName       
    , groupServiceClassName
    , startDate
    , endDate
    

)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CLIENT_PBS_DOCUMENTATION_VIEW] TO [webuser]
GO  
