USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_RECORDS_THAT_REQUIRE_ORP_DOC_ASSOCIATION_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SERVICE_RECORDS_THAT_REQUIRE_ORP_DOC_ASSOCIATION_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[SERVICE_RECORDS_THAT_REQUIRE_ORP_DOC_ASSOCIATION_CORE] (
    @userID        as   bigint
  , @userGroup     as   int  
  , @userRank      as   int    
  , @enteredByPCAL as   bit
)    
returns table     
as    
    
/***************************************************************************    
 * SERVICE_RECORDS_THAT_REQUIRE_ORP_DOC_ASSOCIATION_CORE */    
/**    
 *     
 * @param  userID          User ID (Required)    
 * @param  userGroup       User group (Required)    
 * @param  userRank        User rank (Required)    
 * @return                 Service records and svc notes
 ***************************************************************************/     
    
return (    

  select 
      sr.reference      as [Reference]
    , pap.CONCAT_NAME   as [Patient]
    , sr.dos            as [DOS]
    , sr.numMins        as [Mins]
    , prp.CONCAT_NAME   as [Practitioner]
    , gg.GROUP_NAME     as [Group]
    , clc.REP_NAME      as [Consultant]
    , clc.CLIENT_NAME   as [Client]
    , m.SBSC_Employee   as [EnteredByPcal]
    , sr.created        as [EnteredOn]
    , sr.clientID
    , sr.patID
    , sr.pracID
    , sr.groupID
    , sr.id             

from dbo.CLIENTS_Client_Active_LEA     as clc
join dbo.PATIENTS_Client               as pac  on  pac.CLIENT_ID  = clc.CLIENT_ID
join dbo.PATIENTS_PATIENT              as pap  on  pap.PATIENT_ID = pac.PATIENT_ID
join dbo.SERVICE_RECORDS               as sr   on  sr.clientID    = pac.CLIENT_ID
                                               and sr.patID       = pac.PATIENT_ID
                                               and sr.dos         >= dbo.CONST_ORP_DOCUMENTATION_FOR_TREATMENT_REQUIRED_START_DATE()
join dbo.PRACTITIONER_Practitioner      as prp  on prp.PRACTITIONER_ID = sr.pracID
join dbo.GROUP_Group                    as gg   on gg.GROUP_ID         = sr.groupID
join Users.dbo.Users                    as u    on u.userrid = sr.userID
join Users.dbo.Membership               as m    on m.UserId  = u.UserId
join Users.dbo.UsersInRoles             as ur   on ur.UserId = m.UserId
join Users.dbo.Roles                    as r    on r.RoleId  = ur.RoleId
join Users.dbo.RoleData                 as rd   on rd.RoleId = r.RoleId

where (            
        (sr.svcType    =  dbo.CONST_SERVICES_TREATMENT())

   and  (sr.state not in (   dbo.CONST_SVC_REC_STATE_SUB()
                           , dbo.CONST_SVC_REC_STATE_DEL()
                           , dbo.CONST_SVC_REC_STATE_CIF()))

   and (sr.patAbsent   = 0)
   and (sr.orpRequired = 1)
   and (isnull(sr.orpDocID,0) = 0)
   and (dbo.GET_ORP_SVC_CLASS_NAME_ID_FROM_GROUP_ID(sr.groupID) = 3)
   
   and (sr.entryType != 10) /* Skip journal generated */
   and (sr.entryType != 11)
   
   and (m.SBSC_Employee = @enteredByPCAL)
)

)  
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[SERVICE_RECORDS_THAT_REQUIRE_ORP_DOC_ASSOCIATION_CORE] TO [webuser]
GO