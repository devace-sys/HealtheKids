use SPEDMON
go

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CYBHI_TPA_RETURN_FILE_PROCESS_PRAC_REG') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.CYBHI_TPA_RETURN_FILE_PROCESS_PRAC_REG
GO

/*-------------------------------
 * Create 
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[CYBHI_TPA_RETURN_FILE_PROCESS_PRAC_REG] (
    @userID                   bigint
  , @userGroup                int  
  , @userRank                 int      
  , @clientID                 bigint
 
  , @fileClass                tinyint
  , @fileContents             varchar(max)
  , @fromExternalSource       bit = 1  /* No longer used */

  , @editDelReason            varchar(7000)
  , @validateRec              bit
  , @saveType                 int
  , @recID                    bigint
  , @MsgNoRec                 VARCHAR(1000)
  , @MsgNoEdit                VARCHAR(1000)
  , @MsgDupRec                VARCHAR(1000)
  , @MsgDataError             VARCHAR(1000)
  , @MsgNotActive             VARCHAR(1000)
  , @recordID                 bigint        output
  , @spDetails                varchar(8000) output
  , @jsonData                 varchar(max)  output )    
AS    
BEGIN     

SET NOCOUNT ON    

/*============================================================
 * Init output parameters and worker variables
 *===========================================================*/  
    
set @recordID  = 0    
set @spDetails = ''    
set @jsonData  = '[]'
    
declare @fileLines as table (       
    idx  int 
  , line varchar(max)
)
 
declare @fileLineParts as table (
    lineIdx  int
  , position int
  , part     varchar(max)
  unique clustered (lineIdx, position)
)
 
declare @fileHeaderMap as table (
    part     varchar(512)
  , position int  
  unique clustered (part, position)
)
 
declare @providersAck as table (
    lineIdx            int 
  , provType           varchar(10)
  , provNpi            varchar(256)
  , providerID         varchar(512)
  , cybhiTpaID         varchar(256)
  , lName              varchar(60)
  , fName              varchar(35)
  , servName           varchar(100)
  , clientID		   bigint
  , pracID			   bigint
  , siteID			   bigint  
  , isPrac             bit not null default(1)
  , spEdCarePracLastName   nvarchar(50)  default('')
  , spEdCarePracFirstName  nvarchar(50)  default('')
  , spEdCareSiteName       nvarchar(100) default('')
)

declare @providersErr as table (
     lineIdx    int 
   , providerID varchar(512)
   , errCde     varchar(256)
   , [errLvl]   varchar(256)
   , errMsg     varchar(256)
   , provName   varchar(256)
   , servName   varchar(256)
   , clientID   bigint
   , pracID		bigint
   , siteID		bigint  
   , isPrac     bit not null default(1)
   , tblData    varchar(max)
)

declare @clientsParticipating as table (    
    clientID          bigint  not null default -1
  , billingClient     bit     not null default(0)
)

declare @pracs as table (
    clientID    bigint
  , pracID      bigint
  , cybhiTpaID  varchar(256)
) 

declare @sites as table (
     clientID bigint
   , siteID   bigint
)

declare @providerIDParts as table (
    position int
  , part     varchar(max)
)

declare @clientFound             as bit     = 0 
declare @consortium              as bit     = 0
declare @consortiumLeadClientID  as bigint  = null
declare @consortiumLead          as bit     = 0
declare @curLineIdx              as int     = 0
declare @maxLineIdx              as int     = 0
declare @tranOpen                as bit     = 0 
declare @todayDateOnly           as date    = getdate()
declare @provTypePos             as int     = 0
declare @provNpiPos		         as int     = 0
declare @providerIdPos		     as int     = 0
declare @tpaIdPos                as int     = 0
declare @fNamePos                as int     = 0
declare @lNamePos                as int     = 0
declare @servNamePos             as int     = 0
declare @provType                as varchar(10)  = ''
declare @provNpi                 as varchar(50)  = ''
declare @cybhiTpaID              as varchar(256) = ''
declare @providerID              as varchar(512) = ''
declare @entityID                as bigint       = -1
declare @fName				     as varchar(35)  = ''
declare @lName				     as varchar(60)  = ''
declare @servName                as varchar(100) = ''
declare @clientIDIntVal          as bigint       = -1
declare @pracIDIntVal            as bigint       = -1
declare @siteIDIntVal            as bigint       = -1
declare @isPrac                  as bit          = null

BEGIN TRY

/*============================================================
 * Verify incoming parameters that are essential for proper op
 *============================================================*/  

IF (@userGroup     IS NULL) RAISERROR ('userGroup is required',   11, 1)  
IF (@userID        IS NULL) RAISERROR ('user id is required',     11, 1)    
IF (@userRank      IS NULL) RAISERROR ('userRank is required',    11, 1)    
IF (@validateRec   IS NULL) RAISERROR ('Validate flag required',  11, 1)    
IF (@clientID      IS NULL) RAISERROR ('Client ID required',      11, 1)    
IF (@fileClass     IS NULL) RAISERROR ('File class required',     11, 1)
IF (@fileContents  IS NULL) RAISERROR ('File contents required',  11, 1)

/*============================================================
 * Make sure file class is supported
 *============================================================*/  

if (@fileClass not in (1,2))
begin
  RAISERROR ('This class of return file is not supported',11, 1)
end

/*============================================================
 * Error files not supported at this time
 *============================================================*/  

if (@fileClass = 2)
begin
  RAISERROR ('Cannot parse error files at this time.',11, 1)
end

/*============================================================
 * Get client data
 *============================================================*/  

set @consortium             = 0
set @consortiumLead         = 0
set @consortiumLeadClientID = null

select top 1
    @clientFound             = 1
  , @consortium              = isnull(clc.cybhiConsortiumBilling,0)
  , @consortiumLeadClientID  = isnull(clc.cybhiConsortiumLeadClientID,0)  
from dbo.CLIENTS_Client as clc 
where (
      (clc.CLIENT_ID = @clientID)
  and (clc.cybhi     = 1)
)

/*============================================================
 * If client not found - exit
 *============================================================*/  

if (@clientFound = 0) return

/*============================================================
 * Get participating clients 
 *============================================================*/  

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
    
	insert into @clientsParticipating (clientID, billingClient)
	select 
	    clientID      = t1.id 
	  , billingClient = t1.leadClient
	from dbo.CYBHI_CONSORTIUM_MEMBERS_VIEW_CORE(null,null,null,@clientID) as t1
 
  end /* client is lead */

  /*------------------------------------*/
  /* Client is not the lead - exit      */
  /*------------------------------------*/

  else
  begin
    return
  end /* client is not lead */
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
/*#             Parse File Content Into Intermediate Form                   #*/
/*###########################################################################*/

/*============================================================
 * Parse file content into lines 
 *============================================================*/  
 
insert into @fileLines (
    idx
  , line
)
select
   idx
  ,line
from
(
  select 
      idx  = t1.position
    , line = replace(t1.part,char(13),'') 
  from dbo.STRING_SPLIT_MAX (@fileContents,char(10)) as t1
) as q1
where 
  (line != '')
 
/*============================================================
 * Parse each line into parts 
 *============================================================*/  
 
insert into @fileLineParts (
    lineIdx
  , position
  , part
)
select 
    lineIdx = t1.idx
  , t3.position
  , t3.part 
from @fileLines as t1
cross apply (
  select 
    t2.* 
  from dbo.STRING_SPLIT_MAX(t1.line,',') as t2
) as t3
 
/*============================================================
 * Create a header map
 *============================================================*/  

insert into @fileHeaderMap (part, position)
select 
    t1.part
  , t1.position
from @fileLineParts as t1
where 
  (t1.lineIdx = 1)

/*###########################################################################*/
/*#                Parse Intermediate Form - Ack File                       #*/
/*###########################################################################*/

if (@fileClass = 1)
begin

  /*============================================================
   * Get indexes of various fields 
   *============================================================*/  
  
  select top 1 @provTypePos   = t1.position from @fileHeaderMap as t1 where (t1.part = 'PRVTYPFLG')
  select top 1 @provNpiPos    = t1.position from @fileHeaderMap as t1 where (t1.part = 'PRVNPI')
  select top 1 @providerIdPos = t1.position from @fileHeaderMap as t1 where (t1.part = 'CLIENTID')
  select top 1 @tpaIdPos      = t1.position from @fileHeaderMap as t1 where (t1.part = 'PROVNO')
  select top 1 @fNamePos      = t1.position from @fileHeaderMap as t1 where (t1.part = 'PRVFST')
  select top 1 @lNamePos      = t1.position from @fileHeaderMap as t1 where (t1.part = 'PRVLST')
  select top 1 @servNamePos   = t1.position from @fileHeaderMap as t1 where (t1.part = 'SERVNAME')  

  /*============================================================
   * Get our starting and ending lines (line 1 is header)
   *============================================================*/  

  select 
      @curLineIdx = 2
    , @maxLineIdx = max(idx) 
  from @fileLines

  /*============================================================
   * For each lines distict set of parts 
   *============================================================*/  

  while (@curLineIdx <= @maxLineIdx)
  begin
    
	set @provType       = ''
    set @provNpi        = ''
    set @clientIDIntVal = null
	set @pracIDIntVal   = null
	set @siteIDIntVal   = null
	set @providerID     = ''
	set @cybhiTpaID     = ''
	set @fName          = ''
	set @lName          = ''
	set @servName       = ''
	set @isPrac         = 0

	/*============================================================
     * Get the part values
     *============================================================*/  

    select top 1 @provType   = t1.part from @fileLineParts as t1 where ((t1.lineIdx = @curLineIdx) and (t1.position = @provTypePos))
    select top 1 @provNpi    = t1.part from @fileLineParts as t1 where ((t1.lineIdx = @curLineIdx) and (t1.position = @provNpiPos))
    select top 1 @providerID = t1.part from @fileLineParts as t1 where ((t1.lineIdx = @curLineIdx) and (t1.position = @providerIdPos))
    select top 1 @cybhiTpaID = t1.part from @fileLineParts as t1 where ((t1.lineIdx = @curLineIdx) and (t1.position = @tpaIdPos))
    select top 1 @fName      = t1.part from @fileLineParts as t1 where ((t1.lineIdx = @curLineIdx) and (t1.position = @fNamePos))
    select top 1 @lName      = t1.part from @fileLineParts as t1 where ((t1.lineIdx = @curLineIdx) and (t1.position = @lNamePos))
    select top 1 @servName   = t1.part from @fileLineParts as t1 where ((t1.lineIdx = @curLineIdx) and (t1.position = @servNamePos))
   	  
	set @clientIDIntVal = @clientID

	select top 1
	  @pracIDIntVal = prp.PRACTITIONER_ID 
	from @clientsParticipating         as cp
	join dbo.PRACTITIONER_Client       as prc on prc.CLIENT_ID       = cp.clientID  /* Limits search to participating clients */
    join dbo.PRACTITIONER_Practitioner as prp on prp.PRACTITIONER_ID = prc.PRACTITIONER_ID
    where (	        
            (prp.active    = 1)
	    and (prp.npiNumber = @provNpi)
		and (@provNpi      != N'')
	)

	select top 1
       @siteIDIntVal   = ss.SITE_ID
     , @clientIDIntVal = ss.SITE_CLIENT_ID
    from @clientsParticipating as cp /* Limits search to participating clients */
	join dbo.SITES_Site        as ss on ss.SITE_CLIENT_ID = cp.clientID
    where (	      
	      (ss.SITE_NAME      = @servName)
	  and (ss.ACTIVE         = 1)
	  and (@servName        != '')
    )
	  
	set @isPrac = iif((@provType != 'G'),1,0)

    /*============================================================
     * Add part values to our parsed value table
     *============================================================*/ 
 
    insert into @providersAck (
        lineIdx          
	  , provType   
      , provNpi           
      , providerID       
      , cybhiTpaID  
      , fName 
      , lName 
      , clientID
      , pracID
      , siteID 
      , servName
	  , isPrac
	)
    values (@curLineIdx, @provType, @provNpi, @providerID, @cybhiTpaID, @fName ,@lName ,@clientIDIntVal ,@pracIDIntVal ,@siteIDIntVal, @servName, @isPrac)
 
    set @curLineIdx = @curLineIdx + 1

  end /* while */

  /*============================================================
   * Fill in prac and site names
   *============================================================*/  
  
  update t1
  set 
      t1.spEdCarePracLastName  = prp.LAST_NAME
	, t1.spEdCarePracFirstName = prp.FIRST_NAME
  from @providersAck                 as t1
  join dbo.PRACTITIONER_Practitioner as prp on prp.PRACTITIONER_ID = t1.pracID
  where 
    (t1.pracID is not null)

  update t1
  set 
      t1.spEdCareSiteName = ss.SITE_NAME	
  from @providersAck  as t1
  join dbo.SITES_Site as ss on ss.SITE_ID = t1.siteID
  where 
    (t1.siteID is not null)
  
  /*============================================================
   * Get individual site record ids to update
   *============================================================*/  

  insert into @sites (
    siteID  
  )
  select distinct 
    siteID 
  from @providersAck
  where 
    (siteID is not null)

  /*============================================================
   * Get individual practitioner record ids to update
   *============================================================*/  

  insert into @pracs (
      pracID
    , cybhiTpaID
  )
  select distinct 
      pracID 
    , cybhiTpaID
  from @providersAck
  where ( 
    (pracID is not null)
  )

  /*============================================================
   * Set json data with results
   *============================================================*/  

  set @jsonData = convert(varchar(max),(select * from @providersAck order by clientID, pracID, siteID FOR JSON AUTO, INCLUDE_NULL_VALUES ))
end /* return ack */

/*###########################################################################*/
/*#                Parse Intermediate Form - Error File                     #*/
/*###########################################################################*/


else if (@fileClass = 2)
begin

  declare @errCdePos  as int = 0
  declare @errLvlPos  as int = 0
  declare @errMsgPos  as int = 0
  declare @tblDataPos as int = 0

  /*============================================================
   * Get indexes of various fields 
   *============================================================*/  

  select top 1 @errCdePos  = t1.position from @fileHeaderMap as t1 where (t1.part = 'ERRCD')
  select top 1 @errLvlPos  = t1.position from @fileHeaderMap as t1 where (t1.part = 'ERRLVL')
  select top 1 @errMsgPos  = t1.position from @fileHeaderMap as t1 where (t1.part = 'ERRMSG')
  select top 1 @tblDataPos = t1.position from @fileHeaderMap as t1 where (t1.part = 'TBLDATA')
  
  /*============================================================
   * Get our starting and ending lines (line 1 is header)
   *============================================================*/  

  select 
      @curLineIdx = 2
    , @maxLineIdx = max(idx) 
  from @fileLines

  /*============================================================
   * For each lines distict set of parts 
   *============================================================*/  

  while (@curLineIdx <= @maxLineIdx)
  begin
 
   declare @errCde  as varchar(256) = ''
   declare @errLvl  as varchar(256) = ''
   declare @errMsg  as varchar(256) = ''
   declare @tblData as varchar(max) = ''
   
   set @clientIDIntVal = null
   set @pracIDIntVal   = null
   set @siteIDIntVal   = null
   set @providerID     = ''

   /*============================================================
    * Get the part values
    *============================================================*/  
 
    select top 1 @errCde  = t1.part from @fileLineParts as t1 where ((t1.lineIdx = @curLineIdx) and (t1.position = @errCdePos))
    select top 1 @errLvl  = t1.part from @fileLineParts as t1 where ((t1.lineIdx = @curLineIdx) and (t1.position = @errLvlPos))
    select top 1 @errMsg  = t1.part from @fileLineParts as t1 where ((t1.lineIdx = @curLineIdx) and (t1.position = @errMsgPos))
	select top 1 @tblData = t1.part from @fileLineParts as t1 where ((t1.lineIdx = @curLineIdx) and (t1.position = @tblDataPos))

   /*============================================================
    * Extract the provider ID from the @tblData "cell"
    *============================================================*/  
 
   select @providerID = isnull(t2.part,'') from dbo.STRING_SPLIT_MAX(@tblData,'|') as t2 where (t2.position = 2)

   /*============================================================
    * Add part values to our parsed value table
    *============================================================*/ 
 
    insert into @providersErr (
        lineIdx                    
      , providerID	  
	  , errCde       
      , [errLvl]
      , errMsg
	  , clientID
	  , pracID
	  , siteID
      , tblData
	)
    values (@curLineIdx, @providerID, @errCde ,@errLvl ,@errMsg ,@clientIDIntVal, @pracIDIntVal, @siteIDIntVal, @tblData)

    set @curLineIdx = @curLineIdx + 1

  end /* while */

  /*============================================================
   * Determine which row is not a prac
   *============================================================*/  

  update @providersErr set isPrac = 0 where pracID is null

  /*============================================================
   * Get client name (for client provider row)
   *============================================================*/  

  update pe 
    set pe.provName = clc.CLIENT_NAME
  from @providersErr      as pe
  join dbo.CLIENTS_Client as clc on clc.CLIENT_ID = pe.clientID
  where 
    (pe.isPrac = 0)
  
  /*============================================================
   * Get provider name
   *============================================================*/  

  update pe 
    set pe.provName = prp.CONCAT_NAME
  from @providersErr as pe
  join dbo.PRACTITIONER_Practitioner as prp on prp.PRACTITIONER_ID = pe.pracID
  where 
    (pe.isPrac = 1)

  /*============================================================
   * Get site name
   *============================================================*/  

  update pe 
    set pe.servName = ss.SITE_NAME
  from @providersErr  as pe
  join dbo.SITES_Site as ss on ss.SITE_ID = pe.siteID
  where 
    (pe.isPrac = 1)

  /*============================================================
   * Set json data with results
   *============================================================*/  

  set @jsonData = convert(varchar(max),(select * from @providersErr FOR JSON AUTO, INCLUDE_NULL_VALUES ))
end

/*###########################################################################*/
/*#                       Validation Only Exit                              #*/
/*###########################################################################*/

IF (@validateRec = 1) 
BEGIN  
  SET @recordID = 0 
  RETURN(0)    
END        

/*###########################################################################*/
/*#                          Update Data                                    #*/
/*###########################################################################*/

if (@fileClass = 1)
begin

  BEGIN TRANSACTION

    set @tranOpen = 1
  
    update pp
    set
        pp.cybhiTpaApproved            = 1
      , pp.cybhiTpaApprovedOn          = @todayDateOnly
      , pp.cybhiTpaID                  = p.cybhiTpaID
    from @pracs                        as p
    join dbo.PRACTITIONER_Practitioner as pp on pp.PRACTITIONER_ID = p.pracID
    join dbo.PRACTITIONER_Client       as pc on pc.PRACTITIONER_ID = pp.PRACTITIONER_ID
    where 
      (pc.CLIENT_ID = @clientID)

    update ss
    set
        ss.cybhiTpaApproved            = 1
      , ss.cybhiTpaApprovedOn          = @todayDateOnly
    from @sites         as s
    join dbo.SITES_Site as ss on ss.SITE_ID = s.siteID
    where 
      (ss.SITE_CLIENT_ID = @clientID)

  COMMIT TRANSACTION    
  SET @tranOpen = 0    

end /* Return ack */

/*###########################################################################*/
/*#                              Done                                       #*/
/*###########################################################################*/

RETURN(0)    
END TRY  

/*============================================================
 * Exception handling
 *============================================================*/      

BEGIN CATCH    
    
  /*-------------------------------    
   * If we end up here something    
   * went wrong.  Cancel any pending    
   * transactions and return any    
   * error any error messages to    
   * the caller    
   *------------------------------*/    
       
  -- Error or raise error with severity 11 to 19 will be caught here    
      
  IF @tranOpen = 1 ROLLBACK TRANSACTION    
      
  DECLARE @ErrorMessage  AS NVARCHAR(4000)    
  DECLARE @ErrorSeverity AS INT    
  DECLARE @ErrorState    AS INT    
      
  SELECT  @ErrorMessage  = ERROR_MESSAGE(),    
          @ErrorSeverity = ERROR_SEVERITY(),    
          @ErrorState    = ERROR_STATE()    
   
  -- Only send really bad exceptions back with sp details

  if (@ErrorSeverity > 11)    
    SET @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ']'    
      
  -- Reraise the error so it returns back to the server    
      
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
    
END CATCH    
END    
    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[CYBHI_TPA_RETURN_FILE_PROCESS_PRAC_REG] TO [webuser]
GO