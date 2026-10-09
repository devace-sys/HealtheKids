USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CYBHI_TO_DHCS_FOR_MCAL_ELIG_DATA_LIST_RPT_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CYBHI_TO_DHCS_FOR_MCAL_ELIG_DATA_LIST_RPT_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[CYBHI_TO_DHCS_FOR_MCAL_ELIG_DATA_LIST_RPT_CORE] ( 
    @clientID           bigint
  , @generateRosterMode bit = 0
)

/***************************************************************************    
 * CYBHI_TO_DHCS_FOR_MCAL_ELIG_DATA_LIST_RPT_CORE */    
/**    
 * Returns patients that we can request a DHCS MCAL match for
 ***************************************************************************/            

returns @patients table (         
	  [patID]               bigint      not null
	, [clientID]            bigint      not null
	, [SSN]       			varchar(9)  default('') 
	, [LastName]	        varchar(20)	default('')	
	, [FirstName]	        varchar(15)	default('')
	, [MiddleInitial]       varchar(1)  default('')
	, [DateOfBirth]	        varchar(8)	default('')
	, [Gender]	            varchar(1)	default('')
	, [ProviderID]	        varchar(9)	default('')
	, [SchoolName]	        varchar(20)	default('')
	, [UserData]	        varchar(20)	default('')
	, [CountyCode]	        varchar(2)  default('')
	
  unique clustered (patID)
)
as
begin

declare @clientFound                     as bit    = 0
declare @consortium                      as bit    = 0
declare @consortiumLeadClientID          as bigint = null
declare @consortiumLead                  as bit    = 0

declare @clientsParticipating as table (    
    clientID          bigint                   not null default -1
  , billingClient     bit                      not null default(0)
)

/*###########################################################################*/
/*#                    Exit if client not passed                            #*/
/*###########################################################################*/

if (@clientID is null) return

/*###########################################################################*/
/*#              Exit if global switch is not enabled                       #*/
/*###########################################################################*/

if not exists (
  select top 1 
    appSet.id 
  from users.dbo.APP_SETTINGS as appSet
  where (
        (appSet.appName     = 'spedcare') 
    and (appSet.[namespace] = 'dhcs') 
    and (appSet.class       = 'mcal-elig-data') 
    and (appSet.subClass1   = 'match-requests')
    and (appSet.subClass2   = 'lea-bop')
    and (appSet.[name]      = 'enabled')
	and (appSet.[value]     = '1')
	and (appSet.active      = 1)
  )
)
begin
  return 
end

/*###########################################################################*/
/*#                        Get client data                                  #*/
/*###########################################################################*/

select top 1
    @clientFound             = 1
  , @consortium              = isnull(clc.cybhiConsortiumBilling,0)
  , @consortiumLeadClientID  = isnull(clc.cybhiConsortiumLeadClientID,0)  
from dbo.CLIENTS_Client as clc 
where (
      (clc.CLIENT_ID = @clientID)
  and (clc.cybhi     = 1)
  and (clc.cybhiSendElibilityDataMatchRequestsToDHCSForMCAL = 1)
)

/*###########################################################################*/
/*#                    If client not found exit                             #*/
/*###########################################################################*/

if (@clientFound = 0) return

/*###########################################################################*/
/*#                      Get Participating Clients                          #*/
/*###########################################################################*/

/*------------------------------------*/
/* Client is part of consortium       */
/*------------------------------------*/

if (@consortium = 1)
begin

  /*------------------------------------*/
  /* Client is the lead client          */
  /*------------------------------------*/

  if (@consortiumLeadClientID = 0) 
  begin  
    
	/*------------------------------------*/
    /* If we are generating the roster    */
	/* include all consortium members     */
    /*------------------------------------*/
	
	if (@generateRosterMode = 1)
	begin
	  insert into @clientsParticipating (clientID, billingClient)
	  select 
	      clientID      = t1.id 
	    , billingClient = t1.leadClient
	  from dbo.CYBHI_CONSORTIUM_MEMBERS_VIEW_CORE(null,null,null,@clientID) as t1
	  join dbo.CLIENTS_Client                                               as t2 on t2.CLIENT_ID = t1.id
	  where 
	    (t2.cybhiSendElibilityDataMatchRequestsToDHCSForMCAL = 1)
    end

	/*------------------------------------*/
    /* If we are not generating the roster*/
	/* include just the lead              */
    /*------------------------------------*/

	else
	begin
	  insert into @clientsParticipating (clientID, billingClient) values (@clientID,1)
	end

  end

  /*------------------------------------*/
  /* Client is not the lead             */
  /*------------------------------------*/

  else
  begin

    /*------------------------------------*/
    /* If we are generating the roster    */
	/* exit.  Client is submitted under   */
	/* the lead.                          */
    /*------------------------------------*/

    if (@generateRosterMode = 1)
	begin
	  return
	end
	else

	/*------------------------------------*/
    /* If we are not generating the roster*/
	/* include just this client.          */
    /*------------------------------------*/

	begin
  	  insert into @clientsParticipating (clientID, billingClient) values (@clientID,1)	  
    end
  end
end

/*------------------------------------*/
/* Client is not part of consortium   */
/* include just this client */
/*------------------------------------*/

else
begin  
  insert into @clientsParticipating (clientID, billingClient) values (@clientID,1)
end


/*###########################################################################*/
/*#                       Get Patient Data                                  #*/
/*###########################################################################*/

insert into @patients (
	  patID
	, clientID
	, [SSN]   
	, [LastName]	
	, [FirstName]	
	, [MiddleInitial]
	, [DateOfBirth]	 
	, [Gender]	     
	, [ProviderID]	 
	, [SchoolName]	 
	, [UserData]	 
	, [CountyCode]	 

)
select 
  q1.* 
from @clientsParticipating as cp
cross apply (    
  select 
      sr.patID
	, sr.clientID
	, [SSN]           = '' /* We do not collect SSN anymore */ 		
    , [LastName]      = dbo.STRING_REMOVE_NON_ALPHA_NUMERIC(pap.LAST_NAME,1,1,1,1,20)
    , [FirstName]     = dbo.STRING_REMOVE_NON_ALPHA_NUMERIC(pap.FIRST_NAME,1,1,1,1,15)
    , [MiddleInitial] = dbo.STRING_REMOVE_NON_ALPHA_NUMERIC(pap.MIDDLE_NAME,1,1,1,1,1)
    , [DateOfBirth]   = replace(dbo.RPT_DATE_FMT_YYYY_MM_DD(pap.DATE_OF_BIRTH),'-','')
    , [Gender]        = dbo.STRING_REMOVE_NON_ALPHA_NUMERIC(pap.SEX,1,1,1,1,1)
    , [ProviderID]    = ''	 
    , [SchoolName]	  = ''
    , [UserData]	  = dbo.bigint_2_hexstr(sr.patID,20) /* Hex value for patient ID */
    , [CountyCode]    = ''
 
  from dbo.CYBHI_PATS_VIEW_DATA_CORE (cp.clientID) as sr
  join dbo.PATIENTS_Patient                        as pap on pap.PATIENT_ID = sr.patID
  where (
        (pap.ACTIVE       = N'Y')
    and (pap.ferpaConsent = 1)
  )
) as q1

return

end
     
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CYBHI_TO_DHCS_FOR_MCAL_ELIG_DATA_LIST_RPT_CORE] TO [webuser]
GO