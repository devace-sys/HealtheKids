USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRAC_DIRECT_SUPERVISION_HOLD_CLAIM') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PRAC_DIRECT_SUPERVISION_HOLD_CLAIM
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[PRAC_DIRECT_SUPERVISION_HOLD_CLAIM] (
    @directSupRequiredStartDate datetime 
  , @commonClaimHoldDataJSON    varchar(max)
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
  declare @pracsJson as varchar(max)
  declare @svcTypeID as bigint = null
   
  declare @pracsToCheck as table (
      pracID                    bigint
	, groupID                   bigint
	, groupType                 smallint default 0
	, directSupervisionRequired bit      default 0
	, directlySupervisedOnDos   bit      default 0
    unique clustered (pracID, groupID)
  )

  if (@commonClaimHoldDataJSON = '{}')
  begin
    insert into @hold values (1,N'DSUP - Data issue.  Common claim hold data is empty.')
	return
  end

  /* Extract service type data  */

  select top 1 @svcTypeID = convert(int,[value]) FROM OPENJSON(@commonClaimHoldDataJSON) as t1
  where (t1.[key] = 'svcTypeID')

  /* Exit if this is transportation */

  if (@svcTypeID = 3) 
  begin
    insert into @hold values (0,N'DSUP - Transportation claim.  No direct supervision required')
    return
  end

  /* Extract date of service from common claim hold data */

  select top 1 @dos = convert(datetime,[value]) 
  FROM OPENJSON(@commonClaimHoldDataJSON) as t1 
  where (t1.[key] = 'dos')

  /* If direct supervision does not apply because the dos is before the requirment start date, dont hold */

  if (@dos < @directSupRequiredStartDate) 
  begin
    insert into @hold values (0,N'DSUP - No direct supervision required because dos is before requirement date')
    return
  end
  
  /* Extract is proxy from common claim hold data */

  select top 1 @isProxy = convert(bit,[value]) FROM OPENJSON(@commonClaimHoldDataJSON) as t1
  where (t1.[key] = 'isProxy')
  
  /* Extract pracs data from common claim hold data */

  select top 1 @pracsJson = t1.value 
  FROM OPENJSON(@commonClaimHoldDataJSON) as t1
  where (t1.[key] = 'pracs')
  
  insert into @pracsToCheck (pracID, groupID, groupType, directSupervisionRequired)
  select distinct
    t1.pracID
  , t1.groupID
  , t1.groupType
  , t1.directSupervisionRequired
  FROM OPENJSON(@pracsJson) 
  WITH (
      pracID    bigint   '$."pracID"'
    , groupID   bigint   '$."groupID"'
	, groupType smallint '$."groupType"'
	, directSupervisionRequired bit '$."directSupervisionRequired"'
  ) as t1
 
  /* Check group type of practitioner... all must be 1 */
      
  if exists (select top 1 * from @pracsToCheck as t1 where t1.groupType != 1)
  begin
    insert into @hold values (1,N'DSUP - Data issue.  One or more of the practitioner groups associated with the claim needs to be converted to a supported discipline group')
	return
  end

  /* Flag pracs that ARE required to be supervised and are  
  currently supervised on the date of service */
  	
  update t1
    set t1.directlySupervisedOnDos = dbo.PRACTITIONER_HAS_QUALIFIED_DIRECT_SUPERVISION (t1.pracID, t1.groupID, @dos) 
  from @pracsToCheck as t1
  where (t1.directSupervisionRequired = 1)


  /* See if there are any pracs that require supervision but are not supervised */

  if exists (
    select 
      t1.pracID 
    from @pracsToCheck as t1 
    where ((t1.directSupervisionRequired = 1) and (t1.directlySupervisedOnDos = 0))
  )
  begin
     if (@isProxy = 0)
	 begin
	   insert into @hold values (1,N'DSUP - Practitioner must be supervised and there is no current record of qualified supervision that covers the dos')
     end
	 else
     begin
	   insert into @hold values (1,N'DSUP - At least one practitioner who contributed to this service must be supervised and there is no current record of qualified supervision that covers the dos')
	 end
	 return
  end

  if (@isProxy = 0)
  begin
    insert into @hold values (0,N'DSUP - Practitioner supervision is either not required or is covered for this dos')
  end
  else
  begin
    insert into @hold values (0,N'DSUP - All practitioners who contributed to this service either require no supervision or have coverage for this dos')
  end

  return

END  
GO
