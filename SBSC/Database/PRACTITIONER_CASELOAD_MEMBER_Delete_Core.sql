USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTITIONER_CASELOAD_MEMBER_Delete_Core') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.PRACTITIONER_CASELOAD_MEMBER_Delete_Core
GO


/*-------------------------------
 * Object Definition
 *------------------------------*/
   
CREATE PROCEDURE dbo.PRACTITIONER_CASELOAD_MEMBER_Delete_Core (
    @clientID        BIGINT
  , @pracID          BIGINT
  , @patID           BIGINT
  , @caseloadEntryID BIGINT
  , @recordID        BIGINT output
)    
AS    
BEGIN    
   
/***************************************************************************    
 * PRACTITIONER_CASELOAD_MEMBER_Delete_Core */    
/**    
 * Deletes (removes) caseload entry and any associated records
 *    
 ***************************************************************************/        
        
set @recordID = 0

/*-------------------------------    
 * Find caseload entry using
 * client, prac, pat tuple
 *------------------------------*/    

if ((@clientID is not null) and (@pracID is not null) and (@patID is not null) and (@caseloadEntryID is null))
begin

  select top 1
      @caseloadEntryID = ppc.id
    , @clientID        = ppc.clientID
    , @pracID          = ppc.pracID
    , @patID           = ppc.patID
  from dbo.PRACTITIONER_PATIENT_CASELOAD as ppc
  where ( 
        (ppc.clientID = @clientID)
    and (ppc.pracID   = @pracID)
    and (ppc.patID    = @patID)
  )
end

/*-------------------------------    
 * Or find caseload entry using
 * entry id
 *------------------------------*/    

else if ((@clientID is null) and (@pracID is null) and (@patID is null) and (@caseloadEntryID is not null))
begin

  select top 1
      @caseloadEntryID = ppc.id
    , @clientID        = ppc.clientID
    , @pracID          = ppc.pracID
    , @patID           = ppc.patID
  from dbo.PRACTITIONER_PATIENT_CASELOAD as ppc
  where ( 
     (ppc.id = @caseloadEntryID)
  )
end

/*-------------------------------    
 * Or find caseload entry using
 * entry id, clientid, pracid
 *------------------------------*/    

else if ((@clientID is not null) and (@pracID is not null) and (@patID is null) and (@caseloadEntryID is not null))
begin

  select top 1
      @caseloadEntryID = ppc.id
    , @clientID        = ppc.clientID
    , @pracID          = ppc.pracID
    , @patID           = ppc.patID
  from dbo.PRACTITIONER_PATIENT_CASELOAD as ppc
  where ( 
        (ppc.id = @caseloadEntryID)
	and (ppc.clientID = @clientID)
    and (ppc.pracID   = @pracID)
  )
end

/*-------------------------------    
 * Or find caseload entry using
 * entry id, clientid, pracid,
 * and patID
 *------------------------------*/    

else if ((@clientID is not null) and (@pracID is not null) and (@patID is not null) and (@caseloadEntryID is not null))
begin

  select top 1
      @caseloadEntryID = ppc.id
    , @clientID        = ppc.clientID
    , @pracID          = ppc.pracID
    , @patID           = ppc.patID
  from dbo.PRACTITIONER_PATIENT_CASELOAD as ppc
  where ( 
        (ppc.id = @caseloadEntryID)
	and (ppc.clientID = @clientID)
    and (ppc.pracID   = @pracID)
    and (ppc.patID    = @patID)
  )
end

/*-------------------------------    
 * Not enough data passed to find
 * entry.  Exit with error.
 *------------------------------*/    
else
begin
  set @recordID = 0
end

set @recordID = isnull(@caseloadEntryID,0)

/*-------------------------------    
 * If caseload entry not found
 * exit
 *------------------------------*/    

if (@recordID = 0)
begin
  RETURN(0)
end

/*-------------------------------    
 * Remove all related group 
 * memberships
 *------------------------------*/    

delete ppgm 
from dbo.PRACTITIONER_PATIENT_GROUP        as ppg
join dbo.PRACTITIONER_PATIENT_GROUP_MEMBER as ppgm on ppgm.pracPatGroupID = ppg.id
where (
      (ppg.clientID = @clientID)
  and (ppg.pracID   = @pracID)
  and (ppgm.patID   = @patID)
)
	  
/*-------------------------------    
 * Remove all expected services
 *------------------------------*/    

delete ppces
from dbo.PRACTITIONER_PATIENT_CASELOAD                   as ppc                 
join dbo.PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES as ppces on ppces.caseloadEntryId = ppc.id
where (
      (ppc.id        = @caseloadEntryID)
  and (ppc.clientID  = @clientID) 
  and (ppc.pracID    = @pracID) 
  and (ppc.patID     = @patID)
  and (ppces.caseloadEntryID = @caseloadEntryID)
)

/*-------------------------------    
 * Remove promised service
 * and orp documents
 *------------------------------*/    

delete from dbo.PRACTITIONER_PATIENT_CASELOAD_PROMISED_SERVICES where (caseloadEntryID = @caseloadEntryID)
delete from dbo.PRACTITIONER_PATIENT_CASELOAD_ORP_DOCUMENTS     where (caseloadEntryID = @caseloadEntryID)

/*-------------------------------    
 * Remove caseload entry itself
 *------------------------------*/    

delete dbo.PRACTITIONER_PATIENT_CASELOAD 
where (  
       (id        = @caseloadEntryID)
   and (clientID  = @clientID) 
   and (pracID    = @pracID) 
   and (patID     = @patID)
)
   
RETURN(0)    

END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[PRACTITIONER_CASELOAD_MEMBER_Delete_Core] TO [webuser]
GO
