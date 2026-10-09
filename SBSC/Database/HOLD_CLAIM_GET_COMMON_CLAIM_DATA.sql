USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.HOLD_CLAIM_GET_COMMON_CLAIM_DATA') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.HOLD_CLAIM_GET_COMMON_CLAIM_DATA
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[HOLD_CLAIM_GET_COMMON_CLAIM_DATA] (
    @claimID  bigint
) 

RETURNS varchar(max)
AS     
BEGIN    
      
  declare @pracs as table (
      pracID                                    bigint
    , groupID                                   bigint
	, groupType                                 smallint default (0)
	, directSupervisionRequired                 bit      default(0)
	, isContractor                              bit      default(0)
	, supervisionNotRequiredIfPracIsAContractor bit      default(0)
	, rmtsParticipationRequired                 bit      default(0)
	, cprCertificationRequired                  bit      default(0)
	, isAcesCertifiedForDOS                     bit      default(0)
  )
  
  declare @dos              as datetime = null
  declare @dosDateOnly      as date   = null
  declare @isProxy          as bit      = null
  declare @svcTypeID        as int      = null
  declare @pracID           as bigint   = null
  declare @groupID          as bigint   = null
  declare @claimProcedureID as bigint = null
  declare @jsonOut          as varchar(max) = '{}'
  
  /* Look up claim */
  
  select top 1      
	  @isProxy            = clm.IS_PROXY
	, @pracID             = clm.PRACTITIONER_ID
	, @groupID            = clm.GROUP_ID  
	, @dos                = clm.SERVICE_DATE
	, @svcTypeID          = cp.SERVICE_TYPE_ID
	, @claimProcedureID   = cp.PROCEDURE_ID
  from dbo.CLAIM_Claim      as clm
  join dbo.CLAIM_PROCEDURES as cp on cp.PROCEDURE_ID = clm.PROCEDURE_ID
  where 
    (clm.CLAIM_ID = @claimID)
  
  if (@pracID is null) 
  begin
    return @jsonOut
  end

  /* This is a stand alone claim so there is only one practitioner to return */
  
  if (@isProxy = 0)
  begin
	insert into @pracs (pracID,groupID) values (@pracID, @groupID)
  end
    
  /* Otherwise we need to retrieve the practitioner data from the child claims */

  else
  begin
    insert into @pracs (pracID, groupID)
    select
	     pracID  = clm.PRACTITIONER_ID  
	   , groupID = clm.GROUP_ID 
    from dbo.CLAIM_Claim as clm 	 
    where ( 
          (clm.HAS_PROXY = 1) 
      and (clm.REFERENCE_CLAIM_ID_1 = @claimID)
    )
  end
  
  /* Get group types for discipline */

  update t1
    set t1.groupType = gg.GROUP_TYPE
  from @pracs          as t1
  join dbo.GROUP_Group as gg on (gg.GROUP_ID = t1.groupID)
  
  /* Is practitioner currently a contractor */
  
  update t1
    set t1.isContractor = iif((prp.employeeRelationshipID = 20),1,0)    
  from @pracs                        as t1
  join dbo.PRACTITIONER_Practitioner as prp on (prp.PRACTITIONER_ID = t1.pracID)
  
  /* Was practitioner previously a contractor on dos */
  
  update t1
    set t1.isContractor = iif((per.employeeRelationshipID = 20),1,0)
  from @pracs                                    as t1
  join dbo.PRACTITIONER_EMPLOYMENT_RELATIONSHIPS as per on per.pracID = t1.pracID                                                 
  where (
        (@dos between per.startDate and per.endDate)
    and (per.active = 1)
  )
    
  /* Flag pracs that are required to participate in RMTS because their discipline group is one of the required ones */

  update t1
    set t1.rmtsParticipationRequired = 1
  from @pracs                                                as t1
  join dbo.GROUP_GROUP_SERVICE_CLASS_PARTITIONS_NAMES_GROUPS as png on ((png.GROUP_SERVICE_CLASS_PARTITION_ID = 300)                                                                  
																    and (png.GROUP_SERVICE_CLASS_NAME_ID is not null) /* for index */
																    and (png.GROUP_ID  = t1.groupID))
																	 
  /* Flag pracs that are exempt from RMTS particpation because they are a contractor */

  update t1
    set rmtsParticipationRequired = 0
  from @pracs as t1
  where 
    ((t1.isContractor = 1) and (t1.rmtsParticipationRequired = 1))

  /* Flag pracs that must be directly supervised - Pass 1 - Get basic info */

  update t1
  set 
	  t1.directSupervisionRequired                 = 1
	, t1.supervisionNotRequiredIfPracIsAContractor = ggdss.supervisionNotRequiredIfPracIsAContractor
  from @pracs                                       as t1
  join dbo.GROUP_GROUP_DIRECT_SUPERVISED_SUPERVISOR as ggdss on ggdss.SUPERVISED_GROUP_ID = t1.groupID
  where ((ggdss.ACTIVE = 1) and (ggdss.approveServiceRecords = 0))

  /* Flag pracs that must be directly supervised - Pass 2 - Apply supervision expections for contractors */

  update t1
  set 
	t1.directSupervisionRequired = 0
  from @pracs as t1
  where (
        (t1.directSupervisionRequired                 = 1) 
    and (t1.isContractor                              = 1)
    and (t1.supervisionNotRequiredIfPracIsAContractor = 1)
  )

  /* Flag practitioners that are required to have CPR certification */

  update @pracs 
    set cprCertificationRequired = 1
  where 
    (groupID in (12) /* Trained health care aides */)
    
  /* Flag practitioners that have ACES certification valid for dos */
  
  set @dosDateOnly = convert(date,@dos)

  /* First eliminate any pracs that dont have aces cert */

  update t1
    set t1.isAcesCertifiedForDOS = 0
  from @pracs                        as t1
  join dbo.PRACTITIONER_Practitioner as prp on (prp.PRACTITIONER_ID = t1.pracID)
  where ((t1.isAcesCertifiedForDOS is null)
    and (prp.acesCertCompletedOn is null))

  /* Then find anyone who has aces cert that is valid on or after dos */
  /* We can send claims that require aces cert if the cert date is before or on
   * the DOS */

  update t1
    set t1.isAcesCertifiedForDOS = 1
  from @pracs                        as t1
  join dbo.PRACTITIONER_Practitioner as prp on (prp.PRACTITIONER_ID = t1.pracID)
  where ((t1.isAcesCertifiedForDOS is not null)
    and (@dosDateOnly >= prp.acesCertCompletedOn))
  
  /* Then find anyone who has aces cert that is valid after dos */
  /* We wont be able to send these claims that require aces cert for the dos */

  update t1
    set t1.isAcesCertifiedForDOS = 0
  from @pracs                        as t1
  join dbo.PRACTITIONER_Practitioner as prp on (prp.PRACTITIONER_ID = t1.pracID)
  where ((t1.isAcesCertifiedForDOS is not null)
    and (@dosDateOnly < prp.acesCertCompletedOn))
   
  
  /* Return a reference to each prac only once */
  
  declare @pracsJson as varchar(max) = ''

  set @pracsJson = (
    select distinct 
	    t1.pracID
	  , t1.groupID
	  , t1.groupType
	  , t1.directSupervisionRequired
	  , t1.rmtsParticipationRequired 
	  , t1.cprCertificationRequired
	  , t1.isAcesCertifiedForDOS
	from @pracs as t1
	FOR JSON PATH, INCLUDE_NULL_VALUES
  )
 
  set @jsonOut = '{'               
               + '"dos":"'       + dbo.RPT_DATE_FMT(@dos)        + '"'
			   + ',"isProxy":'   + iif((@isProxy = 1),'1','0')  
			   + ',"svcTypeID":' + convert(varchar(50),isnull(@svcTypeID,-1))
			   + ',"claimProcedureID":' + convert(varchar(50),isnull(@claimProcedureID,-1))
			   + ',"pracs":'     + @pracsJson		
               + '}'  
  
  return @jsonOut


END  
GO
