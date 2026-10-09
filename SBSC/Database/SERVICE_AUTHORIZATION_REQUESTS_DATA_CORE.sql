USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_AUTHORIZATION_REQUESTS_DATA_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SERVICE_AUTHORIZATION_REQUESTS_DATA_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[SERVICE_AUTHORIZATION_REQUESTS_DATA_CORE] (
    @userID                            BIGINT
  , @userGroup                         INT  
  , @userRank                          INT  
  , @clientID                          BIGINT
  , @startDate                         DATE
  , @endDate                           DATE
  , @currentResponseCode               bigint
  , @closed                            BIT
  , @active                            BIT
  , @recID                             BIGINT
)    

RETURNS TABLE
 
 /***************************************************************************    
  * SERVICE_AUTHORIZATION_REQUESTS_DATA_CORE */    
 /**    
  * Retuns a list of service authorization requests that @userID (viewingUserID)
  * has access to
  *
  * @return table 
  ***************************************************************************/                         
     
AS RETURN
(


with

/*============================================================
 * Users who are explicity authorized
 *============================================================*/  

cte_explicit_authorized
as
(

  select 
     viewingUserID = sarau.userID
   , requestID = sar.id
   , saprc.isRdp
   , saprc.isPg
   , saprc.isOrp
   , saprc.isRa
   , saprc.isLEAAdmin
   , saprc.isPCALStaff
   , sarras.responseAttestStatement
   , saprc.canAccessSupportingFiles
   , sarau.responseRequired
   , sarau.responseAttestStatementID /* Value in effect caputured at time of auth request entry */
   , personRoleCode = saprc.code
  from dbo.SERVICE_AUTHORIZATION_REQUEST_AUTHORIZED_USERS           as sarau
  join dbo.SERVICE_AUTHORIZATION_REQUEST_RESPONSE_ATTEST_STATEMENTS as sarras on sarras.id  = sarau.responseAttestStatementID
  join dbo.SERVICE_AUTHORIZATION_PERSON_ROLE_CODES                  as saprc  on saprc.code = sarau.serviceAuthorizationPersonRoleCode  
  join dbo.SERVICE_AUTHORIZATION_REQUESTS                           as sar    on sar.id     = sarau.requestID

  /* Note: Keep filters in synch with indexes */
  
  where (
        ((sarau.userID = @userID) and (saprc.explicitAccess = 1))
    and ((@recID        is null)         or (sar.id       = @recID))
    and ((@clientID     is null)         or (sar.clientID = @clientID))
    and ((@closed       is null)         or (sar.closed   = @closed))
    and ((@active       is null)         or (sar.active   = @active))
    and ((@currentResponseCode is null)  or (sar.currentResponseCode = @currentResponseCode))
    and ((@startDate    is null)         or (sar.created  >= @startDate))
    and ((@endDate      is null)         or (sar.created  <= @endDate))
  )
)
,

/*============================================================
 * Implied access
 *============================================================*/  

cte_implied_authorized
as
(

  select   
      viewingUserID = sariudc.userrid
    , requestID     = sar.id
    , sariudc.isRdp
    , sariudc.isPg 
    , sariudc.isOrp
    , sariudc.isRa
    , sariudc.isLEAAdmin
    , sariudc.isPCALStaff
    , sariudc.responseAttestStatement
    , sariudc.canAccessSupportingFiles
    , responseRequired = convert(bit,0) /* Response never required from this group */
    , sariudc.responseAttestStatementID /* Always current value */
	, sariudc.personRoleCode
  from dbo.SERVICE_AUTHORIZATION_REQUESTS_IMPLIED_USERS_DATA_CORE (@userID, @clientID) as sariudc

  cross apply (
    
	select  	
	  t1.id 	
	from dbo.SERVICE_AUTHORIZATION_REQUESTS as t1

   /* Note: Keep filters in synch with indexes */

    where (
           (1=1)
      and  ((@clientID is null)    or (t1.clientID = @clientID))
	  and  ((@recID    is null)    or (t1.id       = @recID))
	  and  ((@closed   is null)    or (t1.closed   = @closed))
	  and  ((@active    is null)   or (t1.active   = @active))
	  and  ((@currentResponseCode is null) or (t1.currentResponseCode  = @currentResponseCode))
	  and  ((@startDate is null)   or (t1.created  >= @startDate))
	  and  ((@endDate   is null)   or (t1.created  <= @endDate))
    )
) as sar

)
,


/*============================================================
 * Combine results
 *
 * Note: Each subset should be unique.  No user should be
 * listed in no more than one set.  So we can forgoe union
 * and select distinct
 *============================================================*/  

cte_combine
as
(
  select *
  from
  (
    select * from cte_explicit_authorized
    union all
    select * from cte_implied_authorized
  ) as q1
)
,

/*============================================================
 * Determine rules 1 of 2
 *============================================================*/  

cte_get_rules_p1
as
(
  select  
      al.viewingUserID 
    , al.requestID
    , al.isRdp
    , al.isPg 
    , al.isOrp
    , al.isRa
    , al.isLEAAdmin
    , al.isPCALStaff	 	
	, al.responseAttestStatement
	, al.responseAttestStatementID
	, al.personRoleCode
    , responseRequiredFromViewingUser           = al.responseRequired

    , viewingUserCanAccessSupportingFiles       = al.canAccessSupportingFiles    

	, viewingUserCanCurrentlyAccessResponseForm = dbo.SERVICE_AUTHORIZATION_REQUEST_IS_RESPONSE_ALLOWED (  sar.active
                                                                                                         , sar.closed
                                                                                                         , al.responseRequired
                                                                                                         , sarer.responseEntryAllowedByRa
                                                                                                         , al.isRa
                                                                                                         , sarer.responseEntryAllowedByRdp
                                                                                                         , al.isRdp
                                                                                                         , sarer.responseEntryAllowedByLEAAdmin
                                                                                                         , al.isLEAAdmin
                                                                                                         , sarer.responseEntryAllowedByPCALStaff
                                                                                                         , al.isPCALStaff )


    , viewingUserCanCurrentlyDeleteAndSaveNew = dbo.SERVICE_AUTHORIZATION_REQUEST_IS_DELETE_AND_SAVE_NEW_ALLOWED (  sar.active
                                                                                                                  , sar.closed
                                                                                                                  , sar.currentResponseCode
																												  , sarer.deleteAndSaveNewAllowedByRa
                                                                                                                  , al.isRa
                                                                                                                  , sarer.deleteAndSaveNewAllowedByRdp
                                                                                                                  , al.isRdp
                                                                                                                  , sarer.deleteAndSaveNewAllowedByLEAAdmin
                                                                                                                  , al.isLEAAdmin
                                                                                                                  , sarer.deleteAndSaveNewAllowedByPCALStaff
                                                                                                                  , al.isPCALStaff )

    , viewingUserCanCurrentlyCloseAndSaveNew = dbo.SERVICE_AUTHORIZATION_REQUEST_IS_CLOSE_AND_SAVE_NEW_ALLOWED (   sar.active
                                                                                                                 , sar.closed
                                                                                                                 , sar.currentResponseCode
																												 , sarer.closeAndSaveNewAllowedByRa
                                                                                                                 , al.isRa
                                                                                                                 , sarer.closeAndSaveNewAllowedByRdp
                                                                                                                 , al.isRdp
                                                                                                                 , sarer.closeAndSaveNewAllowedByLEAAdmin
                                                                                                                 , al.isLEAAdmin
                                                                                                                 , sarer.closeAndSaveNewAllowedByPCALStaff
                                                                                                                 , al.isPCALStaff )


	
	, sar.*  

from cte_combine                                                  as al
join dbo.SERVICE_AUTHORIZATION_REQUESTS                           as sar       on sar.id       = al.requestID
join dbo.SERVICE_AUTHORIZATION_REQUEST_ENTRY_RULES                as sarer     on sarer.id     = sar.svcAuthorizationRequestEntryRulesID
)
,

/*============================================================
 * Determine rules 2 of 2
 *============================================================*/  

cte_get_rules_p2
as
( 
  select 
     rp1.*	
	, [viewingUserCanCurrentlyEditServiceDescription] = convert( bit
	                                                            ,(case when ((rp1.viewingUserCanCurrentlyAccessResponseForm = 1) and (rp1.isOrp = 1)) then 1 else 0 end))
  from cte_get_rules_p1 as rp1  
)

/*============================================================
 * Output
 *============================================================*/  

select 
  rp2.* 
from cte_get_rules_p2 as rp2

)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[SERVICE_AUTHORIZATION_REQUESTS_DATA_CORE] TO [webuser]
GO  
