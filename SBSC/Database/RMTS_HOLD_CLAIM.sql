USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RMTS_HOLD_CLAIM') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RMTS_HOLD_CLAIM
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[RMTS_HOLD_CLAIM] (
    @clientID                       bigint
  , @rmtsRequiredStartDate          datetime
  , @rmtsParticipantsPossibleCsvStr varchar(max)  /* TODO: This data is no longer used.  Remove the routine that generates this from the calling routines when safe.*/
  , @commonClaimHoldDataJSON        varchar(max)
) 

RETURNS
@hold 
table (
    HOLD bit
  , REASON nvarchar(300) /* Matches bucket routine */
)
AS     
BEGIN    
      
  declare @dos       as datetime = null
  declare @isProxy   as bit      = null
  declare @svcTypeID as int      = null
  declare @quarterID as bigint   = null
  declare @rosterID  as bigint   = null
  declare @pracsJson as varchar(max)

  declare @pracsToCheck as table (
      pracID                    bigint
	, rmtsParticipationRequired bit default 1  /* Default to true for safety */
	, participatingInRmtsOnDos  bit default 0
	unique clustered (pracID)
  )

  declare @numPracs                 as int = 0
  declare @numPracsWhereRmtsPartReq as int = 0

  /* Somethings wrong, exit */

  if (@commonClaimHoldDataJSON = '{}')
  begin
    insert into @hold values (1,N'RMTS - Common claim hold data is empty.')
	return
  end

  /* Extract service type data  */

  select top 1 @svcTypeID = convert(int,[value]) FROM OPENJSON(@commonClaimHoldDataJSON) as t1
  where (t1.[key] = 'svcTypeID')

  /* Exit if this is transportation */

  if (@svcTypeID = 3) 
  begin
    insert into @hold values (0,N'RMTS - Transportation claim.  RMTS does not apply.')
    return
  end

  /* Extract date of service from common claim hold data */

  select top 1 @dos = convert(datetime,[value]) 
  FROM OPENJSON(@commonClaimHoldDataJSON) as t1 
  where (t1.[key] = 'dos')

  /* If RMTS does not apply because the dos is before the RMTS requirment start date, dont hold */

  if (@dos < @rmtsRequiredStartDate) 
  begin
    insert into @hold values (0,N'RMTS - No participation required for claims on the dos')
    return
  end

  /* Extract pracs data from common claim hold data */

  select top 1 @pracsJson = t1.value 
  FROM OPENJSON(@commonClaimHoldDataJSON) as t1
  where (t1.[key] = 'pracs')
  
  insert into @pracsToCheck (
      pracID
	, rmtsParticipationRequired
  )
  select distinct /* For safety just in case there is a different type of group */
      t1.pracID
	, t1.rmtsParticipationRequired
  FROM OPENJSON(@pracsJson) 
  WITH (
        pracID                    bigint  '$."pracID"'
	  , rmtsParticipationRequired bit     '$."rmtsParticipationRequired"' 
  ) as t1

  
  /* Safety count*/

  set @numPracs = 0
  select @numPracs = isnull(count(t1.pracID),0)
  from @pracsToCheck as t1 

  if (@numPracs = 0)
  begin
    insert into @hold values (1,N'RMTS - Issue.  No practitioners returned from common claim hold data.')
	return
  end
  
  /* Check if the prac(s) involved are required to participate in RMTS */

  set @numPracsWhereRmtsPartReq = 0  
  select @numPracsWhereRmtsPartReq = isnull(count(t1.pracID),0)
  from @pracsToCheck as t1 
  where 
    (t1.rmtsParticipationRequired = 1)

  /* If none of the prac(s) involved are required to participate in RMTS then exit */

  if (@numPracsWhereRmtsPartReq = 0)
  begin
    insert into @hold values (0,N'RMTS - No participation required for claims because prac(s) are exempt from participation')
	return
  end
    
  /* Look up quarter */
  
  select top 1 
    @quarterID = qtrs.ID 
  from dbo.COMPANY_FISCAL_QUARTERS as qtrs
  where (@dos between qtrs.QTR_START and qtrs.QTR_END)

  /* Look up roster */
  
  set @rosterID = null

  select top 1 
    @rosterID = pr.id
  from dbo.RMTS_PARTICIPATION_ROSTER as pr
  where ((pr.clientID = @clientID) and (pr.quarterID = @quarterID) and (pr.active = 1))

  /* If there is no roster, hold */

  if (@rosterID is null) 
  begin
     insert into @hold values (1,N'RMTS - No roster found for the quarter that the dos falls in')
     return
  end
  
  /* Extract is proxy from common claim hold data */

  select top 1 @isProxy = convert(bit,[value]) FROM OPENJSON(@commonClaimHoldDataJSON) as t1
  where (t1.[key] = 'isProxy')
 
  /* Flag pracs that ARE required to participate and are currently participating in RMTS on the date of service */
  	
  update t1
    set t1.participatingInRmtsOnDos = 1
  from @pracsToCheck         as t1
  join dbo.RMTS_PARTICIPANTS as rp on rp.pracID = t1.pracID
  where ((rp.rosterID = @rosterID) and (t1.rmtsParticipationRequired = 1) and (@dos between rp.startDate and rp.endDate))

  /* TODO: Handle changes */

  /* If there are any pracs left that are not currently participating */

  if exists (
    select 
      t1.pracID 
    from @pracsToCheck as t1 
    where ((t1.rmtsParticipationRequired = 1) and (t1.participatingInRmtsOnDos = 0))
  )
  begin
     if (@isProxy = 0)
	 begin
	   insert into @hold values (1,N'RMTS - Practitioner is required to participate in RMTS and is not for the dos')
     end
	 else
     begin
	   insert into @hold values (1,N'RMTS - All practitioners who contributed to this service are required to participate in RMTS for this dos and at least one is not')
	 end
	 return
  end

  if (@isProxy = 0)
  begin
    insert into @hold values (0,N'RMTS - Practitioner is required to and is partipating in RMTS for this dos')
  end
  else
  begin
    insert into @hold values (0,N'RMTS - All practitionrs who contributed to this service are required to and are partipating in RMTS for this dos')
  end

  return

END  
GO
