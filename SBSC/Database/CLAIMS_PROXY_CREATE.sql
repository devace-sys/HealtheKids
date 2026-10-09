USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLAIMS_PROXY_CREATE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.CLAIMS_PROXY_CREATE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[CLAIMS_PROXY_CREATE] (
   @proxyNumberX   INT
  ,@proxyNumberY   INT
  ,@today          DATETIME
  ,@userID         INT
  ,@clientID       INT
  ,@patID          INT
  ,@dos            DATETIME
  ,@entryDate      DATETIME

  ,@totNumSvcRecs  INT
  ,@totNumSvcMins  INT
  ,@totNumSvcTrips INT
  ,@totNumSvcMiles INT

  ,@procID1        BIGINT  
  ,@procID2        BIGINT
  ,@totNumUnits1   INT
  ,@totNumUnits2   INT

  ,@svcRecIDsStr   VARCHAR(1000)
  ,@clmRecIDs1Str  VARCHAR(1000)   
  ,@clmRecIDs2Str  VARCHAR(1000)
  ,@proxyClmRecID1 BIGINT OUTPUT
  ,@proxyClmRecID2 BIGINT OUTPUT
  )    

AS    

BEGIN     
    
/***************************************************************************    
 * CLAIMS_PROXY_Create */    
/**    
 * Creates a proxy claim and updates applicable service and claim records
 *    
 * Note: This procedure depends on the caller passing valid data
 *
 * @param   today           Todays date
 * @param   userID          The userid of who saved the record    
 * @param   clientID        Client id for proxy
 * @param   dos             Service date for proxy
 * @param   entryDate       Entry date for proxy claim
 * @param   patID           Patient id for proxy
 * @param   procID          Procedure id for proxy
 * @param   totNumUnits     Total number of units
 * @param   svcRecIDsStr    Service records that contributed claims for proxy
 * @param   clmRecIDsStr    Claims to proxy (needs to be in same order as svc recs)
 * @param   recordID        New proxy claim record
 ***************************************************************************/         
     
SET NOCOUNT ON    

DECLARE @procModCombo1     as varchar(50)
DECLARE @procModCombo2     as varchar(50)
DECLARE @nameID            as bigint
DECLARE @svcTypeID         as int
DECLARE @svcPlanTypeID     as int
DECLARE @claimSpan2        as bit
DECLARE @is22              as bit
DECLARE @expectedNumProcID as int
DECLARE @unitTypeProc1     as varchar(50)
DECLARE @unitTypeProc2     as varchar(50)

DECLARE @siteID        as int
DECLARE @pracID        as int
DECLARE @groupID       as int
DECLARE @groupIDRept   as int
DECLARE @orpPracID     as bigint

DECLARE @clmRecID1     as int
DECLARE @clmRecID2     as int
DECLARE @svcRecID      as int

DECLARE @proxyBy       as varchar(20)
declare @msg           as varchar(512)

declare @svcRecIDsTbl  as table (
  id bigint
)

declare @clmRecIDs1Tbl as table (
  CLAIM_ID bigint
)

declare @clmRecIDs2Tbl as table (
  CLAIM_ID bigint
)

declare @claimsData as table (
    LINE_NUMBER   INT
  , PROCEDURE_ID  BIGINT
  , SERVICE_UNITS INT
  unique clustered (LINE_NUMBER)
)

declare @childClaimsOrpData as table (
    CLAIM_ID            bigint
  , ORP_PRACTITIONER_ID bigint
  , SERVICE_UNITS       int
)


BEGIN TRY    

set @nameID        = null
set @svcTypeID     = null
set @svcPlanTypeID = null
set @claimSpan2    = null
set @is22          = null

set @msg = CHAR(10)
RAISERROR (@msg, 0, 1) WITH NOWAIT

set @msg = 'Proxy claim(s) ' + convert(varchar(50),@proxyNumberX) + ' of ' + CONVERT(varchar(50),@proxyNumberY)
RAISERROR (@msg, 0, 1) WITH NOWAIT 

select top 1 @msg = CLIENT_NAME from dbo.CLIENTS_CLIENT   as clc where clc.CLIENT_ID  = @clientID
RAISERROR (@msg, 0, 1) WITH NOWAIT 

select top 1 @msg = CONCAT_NAME from dbo.PATIENTS_PATIENT as pap where pap.PATIENT_ID = @patID
RAISERROR (@msg, 0, 1) WITH NOWAIT 

set @msg = dbo.RPT_DATE_FMT(@dos)
RAISERROR (@msg, 0, 1) WITH NOWAIT 

/*============================================================
 * Get data on procedure 1
 *============================================================*/  

/*-------------------------------    
 * If procedure 1 was provided
 *------------------------------*/  

if (@procID1 > 0)
begin
   
   /*-------------------------------    
    * Get data
    *------------------------------*/  

   select top 1
       @nameID         = svac.SERVICE_NAME_ID
     , @svcTypeID      = svac.SERVICE_TYPE_ID
     , @svcPlanTypeID  = svac.SERVICE_PLAN_TYPE_ID
     , @unitTypeProc1  = svac.PROCEDURE_UNIT_TYPE
     , @claimSpan2     = svac.PROCEDURE_CLAIM_SPAN_2
     , @procModCombo1  = svac.PROCEDURE_PROC_MOD_COMBO        
   from dbo.SERVICES_VIEW_ALL_CORE (null, null ,null ,null ,null ,null ,null ,null ,null ) as svac   
   where (PROCEDURE_ID = @procID1)       
   
   /*-------------------------------    
    * If there is missing data
    * or no data get out
    *------------------------------*/  
   
   if (@nameID is null)
   begin
     RAISERROR ('No data found for procedure id 1', 0, 1) WITH NOWAIT 
     return
   end  
   
end

/*-------------------------------    
 * If procedure 1 was not provided
 * then get out
 *------------------------------*/  

else
begin
  RAISERROR ('No procedure id passed for procedure id 1', 0, 1) WITH NOWAIT 
  return
end

/*============================================================
 * Determine expected number of procedure ids and proxy 
 * method based on data for procedure id 1
 *============================================================*/  

set @proxyBy = null

/*-------------------------------    
 * Assessement
 *------------------------------*/  

if ((@svcTypeID = dbo.CONST_SERVICES_ASSESS()) and (@unitTypeProc1 = 'MINUTES')) 
begin
  set @expectedNumProcID = 1
  set @proxyBy           = 'UNITS'
  RAISERROR ('Assessement (by minute)', 0, 1) WITH NOWAIT 
end

/*-------------------------------    
 * TCM
 *------------------------------*/  

if ((@svcTypeID = dbo.CONST_SERVICES_TCM()) and (@unitTypeProc1 = 'MINUTES'))                                     
begin
  set @expectedNumProcID = 1
  set @proxyBy           = 'UNITS'
  RAISERROR ('TCM', 0, 1) WITH NOWAIT 
end

/*-------------------------------    
 * Treatment (combined)
 *------------------------------*/  

if ((@svcTypeID = dbo.CONST_SERVICES_TREATMENT()) and (@unitTypeProc1 = 'MINUTES') and (@claimSpan2 = 0)) 
begin
  set @expectedNumProcID = 1
  set @proxyBy           = 'UNITS'
  RAISERROR ('Treatment (combined service)', 0, 1) WITH NOWAIT 
end

/*-------------------------------    
 * Treatment (Initial + Additional)
 *------------------------------*/  

if ((@svcTypeID = dbo.CONST_SERVICES_TREATMENT()) and (@unitTypeProc1 = 'MINUTES') and (@claimSpan2 = 1))
begin
  set @expectedNumProcID = 2
  set @proxyBy           = 'MINUTES'
  RAISERROR ('Treatment (initial + additional service)', 0, 1) WITH NOWAIT 
end

/*-------------------------------    
 * Transportation
 *------------------------------*/  

if (@svcTypeID = dbo.CONST_SERVICES_TRANSPORT()) 
begin
  set @expectedNumProcID = 2
  set @proxyBy           = 'UNITS'
  RAISERROR ('Transportation', 0, 1) WITH NOWAIT 
end


/*-------------------------------    
 * Nothing found, get out
 *------------------------------*/  

if (@proxyBy is null)
begin
  RAISERROR ('Cannot determine proxy method', 0, 1) WITH NOWAIT 
  return
end

/*============================================================
 * Get data on procedure 2 
 *============================================================*/  

/*-------------------------------    
 * If procedure 2 is expected
 * and it was provided
 *------------------------------*/  

if (@expectedNumProcID = 2)
begin

  if (@procID2 > 0)
  begin  
  
    /*-------------------------------    
     * Get data
     *------------------------------*/  
  
    select top 1      
        @is22           = svac.PROCEDURE_HAS_22
      , @unitTypeProc2  = svac.PROCEDURE_UNIT_TYPE 
      , @procModCombo2  = svac.PROCEDURE_PROC_MOD_COMBO
    from dbo.SERVICES_VIEW_ALL_CORE (null,null,@svcPlanTypeID,@svcTypeID,null,null,null,null,null) as svac
    where (PROCEDURE_ID = @procID2)        

  end


  /*-------------------------------    
   * If procedure 2 was not provided
   * and it was expected then
   * get out
   *------------------------------*/  

  else
  begin
    RAISERROR ('No procedure id passed for procedure id 2', 0, 1) WITH NOWAIT 
    return
  end
end

/*============================================================
 * Parse service record id string into table var
 *============================================================*/  

insert into @svcRecIDsTbl
select recid as id from dbo.MULTI_RECORD_ID_PARSE(@svcRecIDsStr,',')
   
/*============================================================
 * Parse claim 1 record id string into table var
 *============================================================*/  

insert into @clmRecIDs1Tbl
select recid as CLAIM_ID from dbo.MULTI_RECORD_ID_PARSE(@clmRecIDs1Str,',')

/*============================================================
 * Parse claim 2 record id string into table var
 *============================================================*/  

insert into @clmRecIDs2Tbl
select recid as CLAIM_ID from dbo.MULTI_RECORD_ID_PARSE(@clmRecIDs2Str,',')
    

/*============================================================
 * Get data needed to determine ORP prac id to use
 *============================================================*/  

insert into @childClaimsOrpData
select 
    cr.CLAIM_ID 
  , cc.ORP_PRACTITIONER_ID
  , cc.SERVICE_UNITS
from @clmRecIDs1Tbl as cr
join dbo.CLAIM_Claim as cc on cc.CLAIM_ID = cr.CLAIM_ID

insert into @childClaimsOrpData
select 
    cr.CLAIM_ID 
  , cc.ORP_PRACTITIONER_ID
  , cc.SERVICE_UNITS
from @clmRecIDs2Tbl as cr
join dbo.CLAIM_Claim as cc on cc.CLAIM_ID = cr.CLAIM_ID

/*============================================================
 * We use the orp with the highest unit count.
 *
 * This is either THE orp or the orp that has orders that
 * covers the largest portion of the service (in the case of
 * more than one orp)
 *============================================================*/  

set @orpPracID = null

select top 1 
  @orpPracID = ORP_PRACTITIONER_ID
from @childClaimsOrpData 
where (ORP_PRACTITIONER_ID is not null)
order by SERVICE_UNITS desc

/*============================================================
 * Get first service record id 
 *============================================================*/ 
 
select top 1 @svcRecID  = id from @svcRecIDsTbl

/*============================================================
 * Get first claim record id 
 *============================================================*/ 

select top 1 @clmRecID1 = CLAIM_ID from @clmRecIDs1Tbl

/*============================================================
 * Get name id from service record.
 * Note: Name ID could be different
 *============================================================*/ 

select top 1 @nameID = sr.nameID from dbo.SERVICE_RECORDS as sr where (sr.id = @svcRecID)

/*============================================================
 * Get pracID, groupID disp, siteID, groupID report from 
 * first claim record.  This data is neccessary for 
 * creating a complete and valid claim record for proxy purposes 
 * but it will not be used for any other purpose.  The child
 * claims of the proxy contain the actual particulars.
 *============================================================*/ 

select top 1
  @pracID      = PRACTITIONER_ID, 
  @groupID     = GROUP_ID, 
  @siteID      = SITE_ID, 
  @groupIDRept = GROUP_ID_REPT 
from dbo.CLAIM_Claim 
where (CLAIM_ID = @clmRecID1)

/*============================================================
 * Get claim data
 *============================================================*/ 

RAISERROR (@procModCombo1, 0, 1) WITH NOWAIT 
RAISERROR (@procModCombo2, 0, 1) WITH NOWAIT 

/*-------------------------------    
 * Unit based proxy
 * We use total claim units
 * that have been provided
 *------------------------------*/  

if (@proxyBy = 'UNITS')
begin
 
  RAISERROR ('Preparing unit based proxy record(s) data', 0, 1) WITH NOWAIT 
 
  if (@procID1 > 0) 
  begin
    set @msg = 'Num units 1 : ' + CONVERT(varchar(50),@totNumUnits1)
    RAISERROR (@msg, 0, 1) WITH NOWAIT 
    insert into @claimsData values (1, @procID1, @totNumUnits1)
  end
  
  if (@procID2 > 0) 
  begin
    set @msg = 'Num units 2 : ' + CONVERT(varchar(50),@totNumUnits2)
    RAISERROR (@msg, 0, 1) WITH NOWAIT 
    insert into @claimsData values (2, @procID2, @totNumUnits2)
  end
end

/*-------------------------------    
 * Minute based proxy
 * We recompute units based on
 * total service minutes
 *------------------------------*/  

if (@proxyBy = 'MINUTES')
begin
  
  RAISERROR ('Preparing minute based proxy record(s) data', 0, 1) WITH NOWAIT 
  set @msg = 'Num mins : ' + CONVERT(varchar(50),@totNumSvcMins)
  RAISERROR (@msg, 0, 1) WITH NOWAIT 
  insert into @claimsData
  select 
      LINE_NUMBER   = IDX
    , PROCEDURE_ID
    , SERVICE_UNITS = NUM_UNITS  
  from dbo.CALC_CLAIMS (
     @clientID     
   , @pracID
   , @patID
   , @dos
   , @svcPlanTypeID    
   , @nameID 
   , 0
   , 0
   , 0
   , 0
   , 0
   , @totNumSvcMins
   , 0    
   , 0    
   , 0    
   , 0    
   , 0    
   , 0    
   , 0
   , 0 )
  
end

/*============================================================
 * Create proxy claims for claim1 and 2 (if 2 is needed)
 *============================================================*/ 

declare @minLineNum as int
declare @maxLineNum  as int
declare @curLineNum as int

select @minLineNum = MIN(LINE_NUMBER) from @claimsData
select @maxLineNum = MAX(LINE_NUMBER) from @claimsData
select @curLineNum = @minLineNum
declare @proxyClmRecID as bigint

while (@curLineNum <= @maxLineNum)
begin

  declare @lineNumber  as int
  declare @procID      as bigint
  declare @svcUnits    as int

  /*-------------------------------    
   * Get claim data
   *------------------------------*/          
  
  select top 1 
      @lineNumber = cd.LINE_NUMBER
    , @procID     = cd.PROCEDURE_ID
    , @svcUnits   = cd.SERVICE_UNITS
  from @claimsData as cd
  where (cd.LINE_NUMBER = @curLineNum)

  /*-------------------------------    
   * Create new proxy claim
   *------------------------------*/          

  insert into dbo.CLAIM_Claim (
      PATIENT_ID
    , PROCEDURE_ID
    , PRACTITIONER_ID
    , USER_ID
    , CLIENT_ID
    , SITE_ID
    , STATUS
    , LINE_NUMBER
    , SERVICE_DATE
    , SERVICE_UNITS
    , ENTRY_DATE
    , LAST_UPDATED
    , BATCH_NUMBER
    , ELIGIBILE,ELIGIBILITY_CONFIRMED
    , PAPER_CLAIM_NUMBER
    , GROUP_ID
    , GROUP_ID_REPT
    , IS_PROXY
    , ORP_PRACTITIONER_ID
  )    
  
  values (
  
    @patID
  , @procID
  , @pracID
  , 0           /* User id */
  , @clientID
  , @siteID
  , '1'         /* Status */
  , @lineNumber /* Line number*/
  , @dos
  , @svcUnits
  , @entryDate
  , @today
  , ''
  , 0
  , 0
  , ''
  , @groupID
  , @groupIDRept
  , 1
  , @orpPracID
 )
 
 /*-------------------------------    
  * Get new claim record id
  *------------------------------*/          

 set @proxyClmRecID = SCOPE_IDENTITY()
 
 /*-------------------------------    
  * Display info about proxy
  *------------------------------*/          

 set @msg = 'Proxy Claim'
           + ' ('  + CONVERT(varchar(10),@proxyClmRecID) + ') '
           + ' - ' + CONVERT(varchar(2), @lineNumber) 
           + ' - ' + CONVERT(varchar(10),@procID)
           + ' - ' + CONVERT(varchar(10),@svcUnits)
           
 RAISERROR (@msg, 0, 1) WITH NOWAIT 
 
 /*-------------------------------    
  * For proc1 
  *------------------------------*/          

 if (@curLineNum = 1) 
 begin
      
   set @proxyClmRecID1 = @proxyClmRecID     
   set @msg = ''
 
   select  @msg = @msg  
           + '    Child Claim' 
           + ' ('  + CONVERT(varchar(10),CLAIM_ID) + ') '
           + ' - ' + CONVERT(varchar(2), LINE_NUMBER) 
           + ' - ' + CONVERT(varchar(10),PROCEDURE_ID)
           + ' - ' + CONVERT(varchar(10),SERVICE_UNITS)
           + char(10)
   from dbo.CLAIM_Claim where CLAIM_ID in (select CLAIM_ID from @clmRecIDs1Tbl)

   RAISERROR (@msg, 0, 1) WITH NOWAIT 

 end

 /*-------------------------------    
  * For proc2 
  *------------------------------*/          

 if (@curLineNum = 2) 
 begin
   set @proxyClmRecID2 = @proxyClmRecID
   set @msg = ''
   select  @msg = @msg 
           + '    Child Claim' 
           + ' ('  + CONVERT(varchar(10),CLAIM_ID) + ') '
           + ' - ' + CONVERT(varchar(2), LINE_NUMBER) 
           + ' - ' + CONVERT(varchar(10),PROCEDURE_ID)
           + ' - ' + CONVERT(varchar(10),SERVICE_UNITS)
           + char(10)
   from dbo.CLAIM_Claim where CLAIM_ID in (select CLAIM_ID from @clmRecIDs2Tbl)

   RAISERROR (@msg, 0, 1) WITH NOWAIT 

 end
 
 set @curLineNum = @curLineNum + 1
 
end


/*============================================================
 * Update child claim recoords
 * Note: We set these to a status that the 837 routine should
 * ignore
 *============================================================*/ 

/*-------------------------------    
 * Claim records associated with
 * proc 1
 *------------------------------*/  

update dbo.CLAIM_Claim
set 
    HAS_PROXY            = 1
  , IS_PROXY             = 0
  , REFERENCE_CLAIM_ID_1 = @proxyClmRecID1
  , HOLD                 = 1
  , STATUS               = dbo.CONST_CLAIM_STATUS_CHILD_OF_SENT_PROXY()                      
where 
  (CLAIM_ID in (select CLAIM_ID from @clmRecIDs1Tbl))

/*-------------------------------    
 * Claim records associated with
 * proc 2
 *------------------------------*/  

update dbo.CLAIM_Claim
set 
   HAS_PROXY            = 1 
  ,IS_PROXY             = 0
  ,REFERENCE_CLAIM_ID_1 = @proxyClmRecID2
  ,HOLD                 = 1
  ,STATUS               = dbo.CONST_CLAIM_STATUS_CHILD_OF_SENT_PROXY()
where 
  (CLAIM_ID in (select CLAIM_ID from @clmRecIDs2Tbl))
 

RAISERROR ('Claim records updated', 0, 1) WITH NOWAIT 

/*============================================================
 * Update service records
 *
 * Note: We update the associated service records here because
 * the 837 routine will not pick them up because we are 
 * setting their claim state here
 *============================================================*/ 

/*-------------------------------    
 * Service records
 *------------------------------*/    

update dbo.SERVICE_RECORDS
set 
  state = dbo.CONST_SVC_REC_STATE_SUB()
where id in (select id from @svcRecIDsTbl)

RAISERROR ('Service records updated', 0, 1) WITH NOWAIT 

/*-------------------------------    
 * Add to audit log
 *------------------------------*/    
    
insert into dbo.SERVICE_RECORDS_AUDIT_LOG ( 
    svcRecID
  , loggedOn
  , userID
  , state
)    
select     
    id                            as svcrecid
  , @today                        as loggedOn
  , @userID                       as userID     
  , dbo.CONST_SVC_REC_STATE_SUB() as state 
from
  @svcRecIDsTbl

RAISERROR ('Service records audit log updated', 0, 1) WITH NOWAIT 

/*============================================================
 * Notification messages
 *============================================================*/ 

set @msg = 'Svc recs (' + @svcRecIDsStr + ') are now claimed as part of a proxy'
RAISERROR (@msg, 0, 1) WITH NOWAIT 

if (@proxyClmRecID1 is not null)
begin
  set @msg = 'Clm recs (' + @clmRecIDs1Str + ') are proxied in ' + convert(varchar(50),@proxyClmRecID1)      
  RAISERROR (@msg, 0, 1) WITH NOWAIT
end

if (@proxyClmRecID2 is not null)
begin                        
  set @msg = 'Clm recs (' + @clmRecIDs2Str + ') are proxied in ' + convert(varchar(50),@proxyClmRecID2)              
  RAISERROR (@msg, 0, 1) WITH NOWAIT
end

RETURN(0)    

END TRY 
   
BEGIN CATCH    
    
  /*-------------------------------    
   * If we end up here something    
   * went wrong.  Cancel any pending    
   * transactions and return any    
   * error any error messages to    
   * the caller    
   *------------------------------*/    
       
  -- Error or raise error with severity 11 to 19 will be caught here    

 
  DECLARE @ErrorMessage  AS NVARCHAR(4000)    
  DECLARE @ErrorSeverity AS INT    
  DECLARE @ErrorState    AS INT    
      
  SELECT  @ErrorMessage  = ERROR_MESSAGE(),    
          @ErrorSeverity = ERROR_SEVERITY(),    
          @ErrorState    = ERROR_STATE()    
      
  SET @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ']'    
      
  -- Reraise the error so it returns back to the server    
      
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
    
END CATCH    
END    
    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[CLAIMS_PROXY_CREATE] TO [webuser]
GO
