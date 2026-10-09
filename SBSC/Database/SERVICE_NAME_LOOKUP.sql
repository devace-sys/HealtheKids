USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_NAME_LOOKUP') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SERVICE_NAME_LOOKUP
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[SERVICE_NAME_LOOKUP] (
    @servicePlanTypeID      int
  , @serviceTypeID          int
  , @serviceNameID          int
  , @serviceNameAliasRecID  int
  , @dos                    date
  , @groupID                bigint
  , @hasSvcDetailFlags      bit
  , @svcDetFlag1            bit
  , @svcDetFlag2            bit
  , @svcDetFlag3            bit
  , @svcDetFlag4            bit
) 
RETURNS TABLE    

/***************************************************************************    
 * SERVICE_NAME_LOOKUP */    
/**   
 * Core function used to provide a service name lookup
 *
 *
 * @param   servicePlanTypeID     1    =  IFSP 
 *                                2    =  IEP 
 *                                3    =  No Plan 
 *                                4    =  CYBHI
 *                                5    =  RU Health
 *
 * @param   serviceTypeID         1    =  Assessement
 *                                2    =  Treatment/Therapy
 *                                3    =  Transportation
 *                                4    =  TCM
 *
 * @param   serviceNameID         specific name id
 *
 * @param   serviceNameAliasRecID specific alias rec id if 
 *                                it is recorded or null 
 *                                if it is not defined
 
 * @return table 
 ***************************************************************************/     

as return (
     
with 

/*###########################################################################
  # Pass 1
  ###########################################################################*/ 
  
cte_pass_1
as
(
  select top 1
 
    SERVICE_NAME_ID
  , SERVICE_NAME_STANDARD
  , SERVICE_NAME_ALIAS_RECORD_ID
  , SERVICE_NAME_ALIAS_NAME_ID
  , SERVICE_NAME_ALIAS
  , GROUP_BASE 
  
  from dbo.SERVICES_VIEW_ALL_CORE (  null
                                   , @groupID
                                   , @servicePlanTypeID
                                   , @serviceTypeID
                                   , @serviceNameID
                                   , null
                                   , null
                                   , @dos
                                   , null )

  where ( 
         (1=1) 
     --and ((@serviceNameAliasRecID is null) or (SERVICE_NAME_ALIAS_RECORD_ID = @serviceNameAliasRecID))
  )
)
,

/*###########################################################################
  # Pass 2
  ###########################################################################*/ 

cte_pass_2
as
(
  select top 1
  
       --[SERVICE_NAME]    = case when (@serviceNameAliasRecID is null) then [SERVICE_NAME_STANDARD] else [SERVICE_NAME_ALIAS] end 
       [SERVICE_NAME]    = [SERVICE_NAME_STANDARD] 
  
     , [SERVICE_DETAILS] = dbo.BUILD_SERVICE_DETAILS_STRING (  @serviceTypeID       
                                                           , GROUP_BASE
                                                           , @hasSvcDetailFlags
                                                           , @svcDetFlag1  
                                                           , @svcDetFlag2  
                                                           , @svcDetFlag3  
                                                           , @svcDetFlag4 ) 
    , *
  
  from cte_pass_1
)
,
/*###########################################################################
  # Pass 3
  ###########################################################################*/ 

cte_pass_3
as
(
  select top 1
    
     [SERVICE_NAME] = [SERVICE_NAME] + [SERVICE_DETAILS]
   , SERVICE_DETAILS      
   , SERVICE_NAME_ID
   , SERVICE_NAME_STANDARD
   , SERVICE_NAME_ALIAS_RECORD_ID
   , SERVICE_NAME_ALIAS_NAME_ID
   , SERVICE_NAME_ALIAS

  from cte_pass_2
)

/*###########################################################################
  # Output
  ###########################################################################*/ 

select top 1 * from cte_pass_3

)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[SERVICE_NAME_LOOKUP] TO [webuser]
GO