USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRAC_CPR_CERT_REQUIRED_HOLD_CLAIM') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PRAC_CPR_CERT_REQUIRED_HOLD_CLAIM
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[PRAC_CPR_CERT_REQUIRED_HOLD_CLAIM] (
  @commonClaimHoldDataJSON  varchar(max)
) 

RETURNS
@hold 
table (
    HOLD bit
  , REASON nvarchar(300) /* Matches bucket routine */
)
AS     
BEGIN    
      
  declare @dos       as date     = null
  declare @isProxy   as bit      = null
  declare @pracsJson as varchar(max)
   
  declare @pracsToCheck as table (
        pracID                       bigint
	  , groupID                      bigint
	  , cprCertificationRequired     bit      default 0
	  , cprCertificationValidForDos  bit      default 0
    unique clustered (pracID, groupID)
  )

  if (@commonClaimHoldDataJSON = '{}')
  begin
    insert into @hold values (1,N'CPRC - Data issue.  Common claim hold data is empty.')
	return
  end

  /* Extract date of service from common claim hold data */

  select top 1 @dos = convert(date,[value]) 
  FROM OPENJSON(@commonClaimHoldDataJSON) as t1 
  where (t1.[key] = 'dos')
  
  /* Extract is proxy from common claim hold data */

  select top 1 @isProxy = convert(bit,[value]) FROM OPENJSON(@commonClaimHoldDataJSON) as t1
  where (t1.[key] = 'isProxy')
  
  /* Extract pracs data from common claim hold data */

  select top 1 @pracsJson = t1.value 
  FROM OPENJSON(@commonClaimHoldDataJSON) as t1
  where (t1.[key] = 'pracs')
  
  insert into @pracsToCheck (pracID, groupID, cprCertificationRequired, cprCertificationValidForDos)
  select distinct
      t1.pracID
    , t1.groupID
    , t1.cprCertificationRequired
	, cprCertificationValidForDos = 0
  FROM OPENJSON(@pracsJson) 
  WITH (
      pracID                   bigint   '$."pracID"'
    , groupID                  bigint   '$."groupID"'
	, cprCertificationRequired bit      '$."cprCertificationRequired"'
  ) as t1
 
  /* Flag pracs that have valid CPR certification on the date of service.*/
     
  /* Check current values first */
  
  update t1
  set 
    t1.cprCertificationValidForDos = iif (@dos between prp.cprCertEffectiveDate and prp.cprCertExpirationDate,1,0)
  from @pracsToCheck                 as t1
  join dbo.PRACTITIONER_Practitioner as prp on prp.PRACTITIONER_ID = t1.pracID
  where 
    ((t1.cprCertificationRequired = 1) and (t1.cprCertificationValidForDos = 0))

  /* Then check historical values. */
  
  update t1
  set 
    t1.cprCertificationValidForDos = iif (@dos between cpr.EFFECTIVE_DATE and cpr.EXPIRATION_DATE,1,0)
  from @pracsToCheck                 as t1
  join dbo.PRACTITIONER_CPR_CERTIFICATION as cpr on cpr.PRACTITIONER_ID = t1.pracID
  where 
    ((t1.cprCertificationRequired = 1) and (t1.cprCertificationValidForDos = 0))

  /* See if there are any pracs that require CPR certification but dont have it for dos */

  if exists (
    select 
      t1.pracID 
    from @pracsToCheck as t1 
    where ((t1.cprCertificationRequired = 1) and (t1.cprCertificationValidForDos = 0))
  )
  begin
     if (@isProxy = 0)
	 begin
	   insert into @hold values (1,N'CPRC - Practitioner must have CPR certification and there is no current record of CPR certification that covers the dos')
     end
	 else
     begin
	   insert into @hold values (1,N'CPRC - At least one practitioner who contributed to this service requires CPR certification and there is no current record of CPR certification that covers the dos')
	 end
	 return
  end

  if (@isProxy = 0)
  begin
    insert into @hold values (0,N'CPRC - CPR certification is either not required for this practitioner or is valid for this dos')
  end
  else
  begin
    insert into @hold values (0,N'CPRC - All practitioners who contributed to this service either do not require CPR certification or have valid certification for this dos')
  end

  return

END  
GO
