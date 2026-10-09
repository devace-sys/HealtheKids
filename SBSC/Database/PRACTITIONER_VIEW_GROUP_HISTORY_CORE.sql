USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTITIONER_VIEW_GROUP_HISTORY_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PRACTITIONER_VIEW_GROUP_HISTORY_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[PRACTITIONER_VIEW_GROUP_HISTORY_CORE] (@pracID int)           
returns TABLE

/***************************************************************************    
 * PRACTITIONER_VIEW_GROUP_HISTORY_CORE */    
/**    
 * Returns a table of group ids that the given practitioner has used
 *    
 * @param  pracID          Practitioner id
 * @return                 Table of groups
 ***************************************************************************/            

as           
return
(      
  select q2.*
  from
  (
    select 
      @pracID as [PRACTITIONER_ID], 
      q1.LAST_USED,    
      gg.GROUP_TYPE,
      q1.GROUP_ID,
      gg.GROUP_NAME,
      gg.GROUP_NAME_ABBREVIATION,
      gg.GROUP_BASE,
      q1.CLIENT_ID,
      gg.ACTIVE as [GROUP_ACTIVE],
      q1.GROUP_SOURCE
  from
  (
  
    /*-------------------------------    
     * Current groups
     *------------------------------*/    

    select 
      GETDATE() [LAST_USED], 
      GROUP_ID, 
      CLIENT_ID,
      'GR' as [GROUP_SOURCE]
    from PRACTITIONER_GROUPS as pg
    join PRACTITIONER_Client as pc on pc.PRACTITIONER_ID = pg.PRACTITIONER_ID
    where pg.PRACTITIONER_ID = @pracID

    union all

    /*-------------------------------    
     * Group history from 
     * claim records
     *------------------------------*/    

    select 
      MAX(SERVICE_DATE)      as LAST_USED, 
      isnull(cc.GROUP_ID, 0) as GROUP_ID,
      isnull(cc.CLIENT_ID,0) as CLIENT_ID,
      'CR'                   as GROUP_SOURCE
    from CLAIM_Claim as cc
    where PRACTITIONER_ID = @pracID
    and cc.IS_PROXY = 0
    group by GROUP_ID, CLIENT_ID

    /*-------------------------------    
     * Group history from 
     * service records
     *------------------------------*/    

    union all
  
    select 
      MAX(dos)           as LAST_USED, 
      isnull(groupID, 0) as [GROUP_ID],
      isnull(clientID,0) as [CLIENT_ID],
      'SR'               as GROUP_SOURCE
    from SERVICE_RECORDS as sr
    where pracID = @pracID 
    and sr.state <> dbo.CONST_SVC_REC_STATE_DEL()
    and sr.state <> dbo.CONST_SVC_REC_STATE_CIF()
    group by groupID, clientID
  ) as q1

  left join GROUP_Group as gg on gg.GROUP_ID = q1.GROUP_ID

) as q2

)        
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PRACTITIONER_VIEW_GROUP_HISTORY_CORE] TO [webuser]
GO
    
