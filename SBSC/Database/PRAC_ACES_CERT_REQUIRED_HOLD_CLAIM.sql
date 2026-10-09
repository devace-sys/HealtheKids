USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRAC_ACES_CERT_REQUIRED_HOLD_CLAIM') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PRAC_ACES_CERT_REQUIRED_HOLD_CLAIM
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[PRAC_ACES_CERT_REQUIRED_HOLD_CLAIM] (
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
      
  declare @isProxy          as bit      = null
  declare @claimProcedureID as bigint   = null
  declare @pracsJson        as varchar(max)
   
  declare @pracsToCheck as table (
        pracID                       bigint
      , isAcesCertifiedForDOS        bit
    unique clustered (pracID)
  )

  if (@commonClaimHoldDataJSON = '{}')
  begin
    insert into @hold values (1,N'ACESC - Data issue.  Common claim hold data is empty.')
	return
  end

  /* Extract claim procedure id from common claim hold data */

  select top 1 @claimProcedureID = convert(bigint,[value]) 
  FROM OPENJSON(@commonClaimHoldDataJSON) as t1
  where (t1.[key] = 'claimProcedureID')

  /* If this is not an ACES procedure then exit */

  if not exists (
    select top 1  
      cp.PROCEDURE_ID 
    from dbo.CLAIM_Procedures as cp
    where (
          (cp.PROCEDURE_ID = @claimProcedureID)
	  and (cp.NO_PLAN_NAME in (
         128
       , 129
       , 130
       , 131))
    )
  )
  begin
    insert into @hold values (0,N'ACESC - ACES Cert is not required for this procedure')
	return  
  end

  /* Extract is proxy from common claim hold data */

  select top 1 @isProxy = convert(bit,[value]) 
  FROM OPENJSON(@commonClaimHoldDataJSON) as t1
  where (t1.[key] = 'isProxy')
  
  /* Extract pracs data from common claim hold data */

  select top 1 @pracsJson = t1.value 
  FROM OPENJSON(@commonClaimHoldDataJSON) as t1
  where (t1.[key] = 'pracs')
  
  insert into @pracsToCheck (pracID, isAcesCertifiedForDOS)
  select distinct
      t1.pracID
	, t1.isAcesCertifiedForDOS
  FROM OPENJSON(@pracsJson) 
  WITH (
      pracID                   bigint   '$."pracID"'
	, isAcesCertifiedForDOS    bit      '$."isAcesCertifiedForDOS"'
  ) as t1
 
  /* See if there are any pracs that require ACES certification but dont have it for dos */

  if exists (
    select 
      t1.pracID 
    from @pracsToCheck as t1 
    where ((t1.isAcesCertifiedForDOS = 0))
  )
  begin
     if (@isProxy = 0)
	 begin
	   insert into @hold values (1,N'ACESC - This service requires ACES certification and there is no current record of ACES certification that covers the dos')
     end
	 else
     begin
	   insert into @hold values (1,N'ACESC - This service requires ACES certification and at least one practitioner who contributed to this service has no current record of ACES certification that covers the dos')
	 end
	 return
  end

  if (@isProxy = 0)
  begin
    insert into @hold values (0,N'ACESC - ACES certification is valid for this dos')
  end
  else
  begin
    insert into @hold values (0,N'ACESC - All practitioners who contributed to this service have valid ACES certification for this dos')
  end

  return

END  
GO
