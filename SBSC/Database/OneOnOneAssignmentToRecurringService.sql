use SPEDMON

SET NOCOUNT ON    

/*============================================================
 * Init control variable
 *============================================================*/  

declare @testRun as bit = 0

/*============================================================
 * Init detail variables
 *============================================================*/  

declare @RecIDsStr    as VARCHAR(8000) 
declare @clientID     as BIGINT
declare @patID        as BIGINT
declare @pracID       as BIGINT
declare @fiscalYearID as INT
declare @startDate    as DATETIME
declare @endDate      as DATETIME
declare @calendarID   as BIGINT
declare @scheduleID   as BIGINT     
declare @pracIDsStr   as VARCHAR(8000) 
declare @aideNames    as VARCHAR(8000)
declare @tmtBS        as BIT
declare @tmtDSInd     as BIT
declare @tmdDSGrp     as BIT
declare @tmtAS        as BIT
declare @tmtBSMins    as INT
declare @tmtDSIndMins as INT
declare @tmtASMins    as INT
declare @notes        as VARCHAR(1000) = ''

/*============================================================
 * Init detail tables
 *============================================================*/  

declare @detailsPracs     as RecurringServiceDetailsPracInfoAll
declare @detailsTmtBS     as RecurringServiceDetailsSvcMinuteBased
declare @detailsTmtDSInd  as RecurringServiceDetailsSvcScheduleOrMinuteBased
declare @detailsTmtDSGrp  as RecurringServiceDetailsSvcScheduleOrMinuteBased 
declare @detailsTmtAS     as RecurringServiceDetailsSvcMinuteBased
declare @detailsTransHmSs as RecurringServiceDetailsSvcMileBased
declare @detailsTransSsHm as RecurringServiceDetailsSvcMileBased             
declare @detailsTransSsOs as RecurringServiceDetailsSvcMileBased             
declare @detailsTransOsSs as RecurringServiceDetailsSvcMileBased            

/*============================================================
 * Init parms for save sproc
 *============================================================*/  

declare @userID           as BIGINT  = 0
declare @userGroup        as INT     = 2
declare @userRank         as INT     = 9
declare @editDelReason    as VARCHAR(7000) = ''   
declare @validateRec      as BIT           = 0
declare @saveType         as INT           = dbo.CONST_SAVE_TYPE_NEW()   
declare @recID            as BIGINT        = null   
declare @MsgNoRec         as VARCHAR(1000) = 'No Record'    
declare @MsgNoEdit        as VARCHAR(1000) = 'No Edit'
declare @MsgDupRec        as VARCHAR(1000) = 'Duplicate Record'  
declare @MsgNoClient      as VARCHAR(1000) = 'No Client'
declare @MsgNoPat         as VARCHAR(1000) = 'No Pat'
declare @MsgNoPrac        as VARCHAR(1000) = 'No Prac'
declare @MsgDataError     as VARCHAR(1000) = 'Data Error'
declare @MsgNotActive     as VARCHAR(1000) = 'Not Active'
declare @spDetails        as VARCHAR(8000) = ''
declare @recordID         as BIGINT        = 0 

/*============================================================
 * Init table variable to hold converted recs
 *============================================================*/  

declare @recs as table  
(RowNum       INT, 
 RecIDStrs    VARCHAR(8000),
 AideNames    VARCHAR(8000),
 clientID     BIGINT,
 patID        BIGINT,
 pracID       BIGINT,
 fiscalYearID BIGINT,
 calendarID   BIGINT,
 scheduleID   BIGINT,
 startDate    DATETIME,
 endDate      DATETIME,
 tmtBSMins    INT,
 tmtDSIndMins INT,
 tmtASMins    INT,
 NumOf        INT,
 tmtBS        BIT,
 tmtDSInd     BIT,
 tmtAS        BIT,
 rcrSvcID     BIGINT,
 spDetails    VARCHAR(8000)
 );
 
DECLARE @recIDs as TABLE (id int IDENTITY(1,1), recid bigint)

/*============================================================
 * Retrieve and Aggregate One on One Records 
 *============================================================*/  

;with 

/*-------------------------------
 * Details
 *------------------------------*/

cte_one_on_one_detail
as
(
  select
    id,
    CONVERT(varchar(500),id) as recIDStr,    
    clientID, 
    patID,
    pracID,
    fiscalYearID,
    calendarID,
    scheduleID,
    ltrim(rtrim(isnull(aideFirstName,'') + ' ' + isnull(aideLastName,''))) as [aideName],
    startDate,
    endDate,
    tmtBSMins     = case when busMinsAM > 0 then busMinsAM else 0 end,
    tmtDSIndMins  = case when siteMins  > 0 then siteMins  else 0 end,  
    tmtASMins     = case when busMinsPM > 0 then busMinsPM else 0 end
  from ONE_ON_ONE_AIDE_ASSIGNMENT 
  where 
        active = 1
    and fiscalYearID is not null
    and calendarID   is not null
    and scheduleID   is not null
)
,

/*-------------------------------
 * Summary
 *------------------------------*/

cte_one_on_one_summary
as
(
  select
    RecIDStrs = substring((select ( ', ' + t2.RecIDStr)
                from cte_one_on_one_detail as t2
                where 
                      (t1.clientID      = t2.clientID)     and
                      (t1.patID         = t2.patID)        and
                      (t1.pracID        = t2.pracID)       and
                      (t1.fiscalYearID  = t2.fiscalYearID) and
                      (t1.calendarID    = t2.calendarID)   and
                      (t1.scheduleID    = t2.scheduleID)   and
                      (t1.startDate     = t2.startDate)    and
                      (t1.endDate       = t2.endDate)      
                                
                for xml path ( '' )), 3, 1000 ),
                
  AideNames = substring((select ( ', ' + t2.aideName)
                from cte_one_on_one_detail as t2
                where 
                      (t1.clientID      = t2.clientID)     and
                      (t1.patID         = t2.patID)        and
                      (t1.pracID        = t2.pracID)       and
                      (t1.fiscalYearID  = t2.fiscalYearID) and
                      (t1.calendarID    = t2.calendarID)   and
                      (t1.scheduleID    = t2.scheduleID)   and                      
                      (t1.startDate     = t2.startDate)    and
                      (t1.endDate       = t2.endDate)      
                                
                for xml path ( '' )), 3, 1000 ),                     
                     
    clientID,
    patID,
    pracID,
    fiscalYearID,
    calendarID,
    scheduleID,
    startDate,
    endDate,    
    SUM(tmtBSMins)    as tmtBSMins,
    SUM(tmtDSIndMins) as tmtDSIndMins,
    SUM(tmtASMins)    as tmtASMins,
    COUNT(id)         as NumOf 
  from cte_one_on_one_detail as t1
  
  group by
    clientID,
    patID,
    pracID,
    fiscalYearID,
    calendarID,
    scheduleID,
    startDate,
    endDate

)
,

/*-------------------------------
 * Put in a row number
 *------------------------------*/

cte_one_on_one_summary_with_idx
as
(
  select 
    ROW_NUMBER() OVER (ORDER BY rand()) as RowNum, 
    * 
  from cte_one_on_one_summary
)
,

/*-------------------------------
 * Determine various flags
 *------------------------------*/

cte_one_one_one_to_recr_svc
as
(
select 
*,
tmtBS    = case when tmtBSMins    > 0 then 1 else 0 end, 
tmtDSInd = case when tmtDSIndMins > 0 then 1 else 0 end,
tmtAS    = case when tmtASMins    > 0 then 1 else 0 end
from cte_one_on_one_summary_with_idx
)


/*============================================================
 * Put One on One Record Conversion Data Into A Table Var
 *============================================================*/  

insert into @recs
select *,0,'' from cte_one_one_one_to_recr_svc

/*============================================================
 * Init table we use to hold One on One IDS for later deactivate
 *============================================================*/  

delete @recIDs

begin transaction

/*============================================================
 * Create recurring service records
 *============================================================*/  

declare @ctr as int = 1
declare @cnt as int = 0
declare @cur as int = 0

select @ctr = MIN(RowNum) from @recs
select @cnt = MAX(RowNum) from @recs
select @cur = 0

while (@ctr <= @cnt)
begin 
  
  /*-------------------------------
   * Get single record
   *------------------------------*/  

  select top 1 
    @cur          = RowNum,
    @RecIDsStr    = RecIDStrs,     
    @clientID     = clientID, 
    @patID        = patID,
    @fiscalYearID = fiscalYearID,
    @calendarID   = calendarID,
    @scheduleID   = scheduleID,
    @startDate    = startDate,
    @endDate      = endDate,
    @pracIDsStr   = CONVERT(varchar(8000),pracID),
    @pracID       = pracID,
    @aideNames    = AideNames,
    @tmtBS        = tmtBS,
    @tmtDSInd     = tmtDSInd,
    @tmtAS        = tmtAS,
    @tmtBSMins    = tmtBSMins,
    @tmtDSIndMins = tmtDSIndMins,
    @tmtASMins    = tmtASMins
  from @recs 
  
  where RowNum = @ctr  
  
  /*-------------------------------
   * Clear previous table values
   *------------------------------*/
  
  delete @detailsPracs
  delete @detailsTmtBS
  delete @detailsTmtDSInd
  delete @detailsTmtAS

  /*-------------------------------
   * Create note
   *------------------------------*/  
  
  set @notes = 'Converted from One on One Aide Assignment record(s) ' + @RecIDsStr 
  
  /*-------------------------------
   * Prac details
   *------------------------------*/
   
  insert into @detailsPracs values (@pracID,'','',null,@tmtBS,@tmtDSInd,0,@tmtAS,0,0,0,0,@aideNames)
  
  /*-------------------------------
   * Tmt BS
   *------------------------------*/
  
  if (@tmtBS = 1)
  begin
    insert into @detailsTmtBS values (@pracID,'','',1,1,@tmtBSMins,@tmtBSMins,@tmtBSMins,@tmtBSMins,@tmtBSMins,@tmtBSMins)
  end
  
  /*-------------------------------
   * Tmt DS
   *------------------------------*/

  if (@tmtDSInd = 1)
  begin
    insert into @detailsTmtDSInd values (@pracID,'','',1,1,0,@tmtDSIndMins,0,@tmtDSIndMins,0,@tmtDSIndMins,0,@tmtDSIndMins,0,@tmtDSIndMins,0,@tmtDSIndMins)  
  end
  
  /*-------------------------------
   * Tmt BS
   *------------------------------*/
  
  if (@tmtAS = 1)
  begin
    insert into @detailsTmtAS values (@pracID,'','',1,1,@tmtASMins,@tmtASMins,@tmtASMins,@tmtASMins,@tmtASMins,@tmtASMins)
  end
         
  set @spDetails = ''
  set @recordID  = 0
  
  /*-------------------------------
   * Create recurring service
   * record by calling appropriate
   * save sproc
   *------------------------------*/
  
  exec RECURRING_SERVICES_Save
    @userID,
    @userGroup,
    @userRank,
    @clientID,
    @patID,
    @fiscalYearID,
    @startDate,
    @endDate,
    @calendarID,
    @scheduleID,
    @pracIDsStr,
    @detailsPracs,
    @detailsTmtBS,
    @detailsTmtDSInd,
    @detailsTmtDSGrp,
    @detailsTmtAS,
    @detailsTransHmSs,
    @detailsTransSsHm,
    @detailsTransSsOs,
    @detailsTransOsSs,
    @notes,
    @editDelReason,
    @validateRec,
    @saveType,
    @recID,
    @MsgNoRec,
    @MsgNoEdit,
    @MsgDupRec,
    @MsgNoClient,
    @MsgNoPat,
    @MsgNoPrac,
    @MsgDataError,
    @MsgNotActive,
    @spDetails OUTPUT,
    @recordID  OUTPUT
  
  /*-------------------------------
   * Save original record ids 
   * if no issues
   *------------------------------*/
  
  if (@recordID > 0)
  begin
    insert into @recIDs select recid from dbo.MULTI_RECORD_ID_PARSE(@recIDsStr,',')
  end
  
  /*-------------------------------
   * Update recs table
   *------------------------------*/

  UPDATE @recs 
  SET 
    rcrSvcID  = @recordID,
    spDetails = @spDetails
  WHERE RowNum = @cur
    
  set @ctr = @ctr + 1
end

/*============================================================
 * Deactivate original one one one assignment records 
 *============================================================*/  

set @ctr = 0
set @cnt = 0
set @cur = 0

select @ctr = MIN(id) from @recIDs
select @cnt = MAX(id) from @recIDs

select @cur = 0

/*-------------------------------
 * Create edit/del reason
 *------------------------------*/  

SET @editDelReason = 'Converted to recurring service record'
  
while (@ctr <= @cnt)
begin
  
  /*-------------------------------
   * Get single record
   *------------------------------*/  
   
  select top 1 
    @cur   = id, 
    @recID = recid 
  from @recIDs 
  where id = @ctr
    
  /*-------------------------------
   * Deactivate by calling
   * appropriate delete sproc
   *------------------------------*/  
  
  EXEC ONE_ONE_ONE_AIDE_ASSIGNMENT_Delete 
    @userID, 
    @userGroup, 
    @userRank,
    @editDelReason,
    @validateRec,
    0,
    @recID,
    @MsgNoRec,
    @MsgNoClient,
    @spDetails OUTPUT,
    @recordID  OUTPUT
  
    set @ctr = @ctr + 1  
end

/*============================================================
 * Report Results
 *============================================================*/  

select * from @recs

/*============================================================
 * Either commit or rollback operations
 *============================================================*/  

if (@testRun = 1)
  rollback transaction
else
  commit transaction

