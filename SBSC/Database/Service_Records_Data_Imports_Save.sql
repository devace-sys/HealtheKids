USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Service_Records_Data_Imports_Save') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.Service_Records_Data_Imports_Save
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[Service_Records_Data_Imports_Save] (
    @userID                   bigint
  , @userGroup                int
  , @userRank                 int
  , @clientID                 bigint  
  , @svcNamesListDataSourceID smallint 
  , @generateClaims           bit = 1
  , @importDataJSON           varchar(max)  
  , @editDelReason            varchar(7000)
  , @validateRec              bit
  , @saveType                 int
  , @recID                    bigint
  , @MsgNoRec                 varchar(1000)
  , @MsgNoEdit                varchar(1000)
  , @MsgDupRec                varchar(1000)
  , @MsgDataError             varchar(1000)
  , @MsgNotActive             varchar(1000)
  , @MsgInvCombo    	      varchar(1000)
  , @MsgMinReq		          varchar(1000)
  , @MsgMinDef		          varchar(1000)
  , @MsgMilReq		          varchar(1000)
  , @MsgPatElg		          varchar(1000)
  , @MsgPatDOBGteDOS	      varchar(1000)
  , @MsgPatAbsent		      varchar(1000)
  , @MsgFutureDOS		      varchar(1000)
  , @spDetails                varchar(8000) output
  , @recordID                 bigint        output
  , @jsonData                 varchar(max)  output
)
AS
BEGIN

/***************************************************************************    
 * Service_Records_Data_Imports_Save */    
/**    
 * Using the contents of @importDataJSON this routine attempts to generate
 * service records and if @generateClaims is set to 1 generate claims as well.
 *
 * The operation as a whole is globally limited to
 *
 * - @clientID                 : What client to record the service records for.
 * - @svcNamesListDataSourceID : Determines what billing program/fee schedule is used.  
 *                               Currently only LEA BOP - Non IEP/IFSP and CYBHI are supported
 *
 * Otherwise each imported row is evaluated indepedently and the service rendered can be specified by 
 *
 * 1. service name,  2. procedure code + procedure mods
 * 
 * The specification type is determined automatically for each row
 *
 * There are 
 *
 * 1. Telehealth, 2. Dyadic, 3. Group
 * 
 * and depending on how the service rendered these flags are either determined automatically or
 * the user must provide them.
 *
 * == For telehealth ==
 *
 * Applies to all billing programs
 *
 * It is assumed for all service specification types and billing programs that telehealth = N (in person)
 *
 * If the specification type is by proc code + mods and the telehealth modifier is passed then 
 * telehealth is set to Y.  Otherwise the user has to provide the telehealth flag value.
 * 
 * == For dyadic ==
 *
 * Only applies to CYBHI at present and only to services that have the dyadic option
 * The logic in the routine is designed to extend this to other billing programs if needed.
 *
 * It is assumed that dyadic = N if services are specified by proc or procModCombo
 *
 * If services are specified by name then the name determines the value of the flag
 *
 * If services are specified by proc code + mods and the dyadic modifier is passed then 
 * this sets the flag value to Y
 *
 * If services are specified by proc code the user must provide a dyadic flag value
 * of Y to set the flag value to Y
 *
 * == For group ==
 *
 * Only applies to CYBHI at present and only to services that require the modifier
 * The logic in the routine is designed to extend this to other billing programs if needed.
 *
 * It is assumed that group = N if services are specified by proc or procModCombo
 *
 * If services are specified by name then the name determines the value of the flag
 *
 * If services are specified by proc code + mods and the individual OR group modifier is 
 * passed then depending on WHAT modifier is passed determines the value of flag.  
 *
 * If services are specified by proc code then the user must provide a group flag
 * value of Y to set the flag value to Y 
 ***************************************************************************/         

SET NOCOUNT ON

BEGIN TRY

declare @tranOpen            as bit              = 0
declare @reference           as varchar(500)     = ''
declare @isIEPOrIFSP         as bit              = 0
declare @billingProgramID    as tinyint          = 0
declare @batchID             as uniqueidentifier = null
declare @batchIDRecID        as bigint           = null
declare @batchIDAssRecID     as bigint           = null
declare @maxIdx              as int              = 0
declare @curIdx              as int              = 0
declare @rowBad              as bit              = 0
declare @pracID              as int              = null
declare @patID               as bigint           = null
declare @groupID             as int              = null
declare @numMins             as int              = null
declare @nameID              as int              = null
declare @dos                 as datetime         = null
declare @startTime           as time(0)          = null
declare @viaTelehealth       as bit              = 0 
declare @notes               as varchar(max)     = ''

declare @svcRecSaveOK        as bit              = 0
declare @svcRecSaveStatusMsg as varchar(max)     = ''
declare @svcRecID            as bigint           = 0
declare @spDetailsOut        as varchar(8000)    = null

declare @svcs as table (
    idx             int identity(1,1)
  , rowBad          bit default(0)
  , rowNum          int
  , clientID        int
  , patSSID         nvarchar(50)  default(N'')
  , patStudentID    nvarchar(50)  default(N'')                
  , pracEmail       nvarchar(50)  default(N'')       
  , pracNPI         varchar(50)   default(N'') 		
  , dos             datetime                    
  , dosStr          varchar(50)   default('')
  , procCode        nchar(10) 	  default(N'')
  , procMod1        nchar(10)     default(N'')
  , procMod2        nchar(10)     default(N'')
  , procMod3        nchar(10)     default(N'')
  , procMod4        nchar(10)     default(N'')
  , svcName         nvarchar(100) default(N'') 					  				
  , groupSvc        bit           default(0)
  , teleHealth      bit           default(0)
  , dyadic          bit           default(0)
  , startTime       time(0)			
  , endTime         time(0)				                    
  , numMins         int		   
  , numMinsStr      varchar(50)   default('')
  , notes           varchar(max)  default('')
  
  /* The has<Value> flags indicate if a value was passed */
  
  , hasPracEmail    bit           default(0)
  , hasPracNPI      bit           default(0)
  , hasPatSSID      bit           default(0)  
  , hasPatStudentID bit           default(0)
  , hasDos          bit           default(0)  
  , hasProcCode     bit           default(0)
  , hasProcMods     bit           default(0)
  , hasSvcName      bit           default(0)
  , hasStartTime    bit           default(0)
  , hasEndTime      bit           default(0)
  , hasNumMins      bit           default(0)
  , hasTelehealth   bit           default(0)  /* Flag or mods */
  , hasGroupSvc     bit           default(0)  /* Mods only */
  , hasDyadic       bit           default(0)  /* Mods only */

  /* the <value>Found indicates if a matching record on our side was found */

  , durationFound   bit           default(1)
  , durationInvalid bit           default(0)

  , pracFound       bit           default(0)
  , pracID          int
  , pracName        varchar(256)  default('')
  , groupID         int
  , groupName       varchar(256)  default('')

  , patFound        bit           default(0)
  , patID           bigint
  , patName         varchar(256)  default('')
  , patDOB          datetime

  , planTypeFound   bit  default(0)
  , planTypeID      int

  , svcProvided                             bit default(0)  
  , svcSearchMethodDetermined               bit default(0)
  , svcSearchByProcCode                     bit default(0)
  , svcSearchBySvcName                      bit default(0)
  , svcSearchByProcCodeRequiresGroupFlag    bit default(0)
  , svcSearchByProcCodeUseSvcSubTypeID      bit default(0)  
  , svcSearchByProcCodeSvcSubTypeID         int

  , svcFound                 bit            default(0)
  , svcNameSelectionID       int
  , svcNameSelection         varchar(256)   default('')
  
  , svcRecExists             bit            default(0)
  , validate                 bit            default(0)
  , svcRecSaveWasOK          bit            default(0)
  , svcRecSaveStatusMessage  varchar(max)   default('')
  , svcRecSpDetails          varchar(800)   default('')
  , svcRecID                 bigint
  , processingNotes          varchar(max)   default('')
 
unique clustered (idx)  

)

declare @programProcedureCodes as table (
  procCode nvarchar(10) default (N'')
unique clustered(procCode)
)

declare @programProcedureCodesThatRequireIndGrp as table (
  procCode nvarchar(10) default (N'')
unique clustered (procCode)
)

declare @cybhiProcedureCodesThatSupportDyadic as table (
  procCode nvarchar(10) default (N'')
unique clustered (procCode)
)

/*############################################################################
 *# Init
 *############################################################################*/

set @tranOpen         = 0
set @spDetails        = ''
set @recordID         = 0
set @jsonData         = '{}'
set @billingProgramID = 0
set @isIEPOrIFSP      = 0
set @reference        = ''
   
set @jsonData = '{"importData":' 
                + @importDataJSON 
				+ ',"exportData":[]'
				+ '}'

/*############################################################################
 *# If billing program not supported exit.
 *############################################################################*/

if (@svcNamesListDataSourceID not in (200,300)) /* Only supporting LEA BOP - Non IEP and CYBHI */
begin
  RAISERROR ('Plan is not supported', 11, 1)      
  return(0)
end

/*############################################################################
 *# Find iep and billing program id values
 *############################################################################*/

set @billingProgramID = 0

select top 1
     @isIEPOrIFSP      = csnlds.isIEPOrIFSP
   , @billingProgramID = csnlds.billingProgramID
from dbo.CLAIM_Svc_Names_List_Data_Sources as csnlds 
where 
  (csnlds.id = @svcNamesListDataSourceID)

/*############################################################################
 *# If billing program not supported exit.
 *############################################################################*/

if (@billingProgramID = 0) /* Only supporting LEA BOP - Non IEP and CYBHI */
begin
  RAISERROR ('Plan is not supported', 11, 1)      
  return(0)
end

/*############################################################################
 *# Extract file name.  We will use this as the service record reference
 *############################################################################*/

set @reference = ''

select top 1
  @reference = left(t1.[fileName],500)
from openjson ( @importDataJSON, '$."fileInfo"' ) 
with (
    [fileName] varchar(256) '$.name'
) as t1

if (@reference = '') 
begin
  RAISERROR ('Could not extract file name to use as service record reference', 11, 1)      
  return(0)
end

/*############################################################################
 *# Extract services
 *############################################################################*/

insert into @svcs (
    rowBad
  , rowNum
  , clientID
  , patSSID
  , patStudentID
  , pracEmail
  , pracNPI
  , dos  
  , procCode
  , procMod1
  , procMod2
  , procMod3
  , procMod4
  , svcName
  , startTime
  , endTime
  , numMins  
  , notes
  , teleHealth 
  , validate
)
select 
    t1.rowBad
  , t1.rowNum
  , clientID       = @clientID
  , patSSID        = trim(isnull(t1.patSSID,      N''))
  , patStudentId   = trim(isnull(t1.patStudentID, N''))
  , pracEmail      = trim(isnull(t1.pracEmail,    N''))
  , pracNPI        = trim(isnull(t1.pracNPI, ''))
  , dos            = try_convert(datetime,nullif(t1.dos,N''))
  , procCode       = trim(isnull(t1.procCode, N''))
  , procMod1       = trim(isnull(t1.procMod1, N''))
  , procMod2       = trim(isnull(t1.procMod2, N''))
  , procMod3       = trim(isnull(t1.procMod3, N''))
  , procMod4       = trim(isnull(t1.procMod4, N''))
  , svcName        = trim(isnull(t1.svcName, N''))
  , startTime      = try_convert(time(0), nullif(t1.startTime,''))
  , endTime        = try_convert(time(0), nullif(t1.endTime,''))
  , numMins        = try_convert(int,     nullif(t1.numMins,''))
  , notes          = trim(isnull(t1.notes,''))
  , teleHealth     = isnull(try_convert(bit,nullif(t1.teleHealth, '')),0)
  , validate       = @validateRec

from OPENJSON( @importDataJSON, '$."structuredDataRows"' )
with (
      [rowBad]       bit                     '$."rowBad"'
	, [rowNum]       int                     '$."rowNumIn"'
    , [patSSID]      nvarchar(50)            '$."rowData"."patSSID"'
	, [patStudentID] nvarchar(50)            '$."rowData"."patStudentID"'
	, [pracEmail]    nvarchar(128)           '$."rowData"."pracEmail"'
	, [pracNPI]      varchar(50)             '$."rowData"."pracNPI"'
	, [dos]          varchar(50)             '$."rowData"."dos"'
    , [procCode]     nchar(10)               '$."rowData"."procCode"'
	, [procMod1]     nchar(10)               '$."rowData"."procMod1"'
    , [procMod2]     nchar(10)               '$."rowData"."procMod2"'
    , [procMod3]     nchar(10)               '$."rowData"."procMod3"'
    , [procMod4]     nchar(10)               '$."rowData"."procMod4"'
	, [svcName]      nvarchar(100)           '$."rowData"."svcName"'
	, [startTime]    varchar(50)             '$."rowData"."startTime"'
	, [endTime]      varchar(50)             '$."rowData"."endTime"'
	, [numMins]      varchar(50)             '$."rowData"."numMins"'
	, [notes]        varchar(max)            '$."rowData"."notes"'
    , [teleHealth]   varchar(50)             '$."rowData"."teleHealth"'
) as t1

/*############################################################################
 *# Determine what values were provided 
 *############################################################################*/

update @svcs set hasPracEmail    = 1 where (len(pracEmail) > 0)
update @svcs set hasPracNPI      = 1 where (len(pracNPI) > 0)
update @svcs set hasPatSSID      = 1 where (len(patSSID) > 0)
update @svcs set hasPatStudentID = 1 where (len(patStudentID) > 0)
update @svcs set hasDos          = 1 where (dos is not null)
update @svcs set hasSvcName      = 1 where (len(svcName)  > 0)
update @svcs set hasProcCode     = 1 where (len(procCode) > 0)
update @svcs set hasProcMods     = 1 where ((len(procMod1) > 0) or (len(procMod2) > 0) or (len(procMod3) > 0) or (len(procMod4) > 0))
update @svcs set hasStartTime    = 1 where (startTime is not null)
update @svcs set hasEndTime      = 1 where (endTime is not null)
update @svcs set hasNumMins      = 1 where (numMins is not null)

/*############################################################################
 *# If the row does not have the prac email or npi then flag it as bad 
 *# Note: Should already be flagged as bad by the middleware
 *############################################################################*/

update @svcs 
set 
    rowBad          = 1 
  , processingNotes = processingNotes + ' No email or NPI provided for practitioner.'
where 
  ((hasPracEmail = 0) and (hasPracNPI = 0))

/*############################################################################
 *# If the row does not have the pat SSID or a student ID then flag it as bad 
 *# Note: Should already be flagged as bad by the middleware
 *############################################################################*/

update @svcs 
set 
    rowBad          = 1 
  , processingNotes = processingNotes + ' No SSID or student ID provided for patient.'
where 
  ((hasPatSSID = 0) and (hasPatStudentID = 0))

/*############################################################################
 *# If the row does not have the date of service then flag it as bad 
 *# Note: Should already be flagged as bad by the middleware
 *# Also create reportable version of dos
 *############################################################################*/

update @svcs 
set 
    rowBad          = 1 
  , processingNotes = processingNotes + ' No DOS provided.'
where 
  (hasDos = 0)

update @svcs set dosStr = dbo.RPT_DATE_FMT(dos) where (hasDos = 1)

/*############################################################################
 *# If the row does not have any of the three values we can use to find the 
 *# duration of the service then flag it as bad
 *############################################################################*/

update @svcs 
set 
    rowBad          = 1 
  , durationFound   = 0
  , processingNotes = processingNotes + ' No service duration provided.'
where 
  ((hasStartTime = 0) and (hasEndTime = 0) and (hasNumMins = 0))

/*############################################################################
 *# If numMins was not provided but start and end time were then calculate
 *# the minutes
 *############################################################################*/

update t1
set 
      t1.numMins      = datediff(MINUTE,t1.startTime,t1.endTime)  
	, processingNotes = processingNotes + ' Minutes were calculated from start and end time.'
from @svcs as t1
where ( 
        (t1.durationFound = 1)
	and (t1.hasNumMins    = 0) 
	and (t1.hasStartTime  = 1) 
	and (t1.hasEndTime    = 1)
)

/*############################################################################
 *# If the number of minutes is 0 then flag row as bad
 *############################################################################*/

update t1
set 
      rowBad          = 1   
    , durationInvalid = 1
	, processingNotes = processingNotes + ' Service duration has to be 1 or more minutes.'
from @svcs as t1
where ( 
        (t1.durationFound = 1)
    and (isnull(t1.numMins,0) <= 0) 
)

update @svcs set numMinsStr = convert(varchar(50),numMins) where ((durationFound = 1) and (numMins is not null))

/*############################################################################
 *# If the row does not have either of the values we can use to find the 
 *# service selection then flag it as bad 
 *############################################################################*/

update @svcs set svcProvided = 1 where (hasProcCode = 1) 
update @svcs set svcProvided = 1 where ((hasSvcName  = 1) and (svcProvided = 0))

update @svcs 
set 
    rowBad          = 1
  , processingNotes = processingNotes + ' No service name or procedure provided.'
where 
  (svcProvided = 0)

/*############################################################################
 *# Determine if the service search method is by procedure code
 *############################################################################*/
  
update t1
set 
    t1.svcSearchMethodDetermined = 1
  , t1.svcSearchByProcCode       = 1
  , t1.svcSearchBySvcName        = 0
from @svcs as t1
where (
      (t1.svcProvided               = 1)
  and (t1.svcSearchMethodDetermined = 0)
  and (t1.hasProcCode               = 1)  
)

/*############################################################################
 *# Determine if the service search method is by service name
 *############################################################################*/

update t1
set 
    t1.svcSearchMethodDetermined = 1
  , t1.svcSearchByProcCode       = 0
  , t1.svcSearchBySvcName        = 1
from @svcs as t1
where (
      (t1.svcProvided               = 1)
  and (t1.svcSearchMethodDetermined = 0)  
  and (t1.hasSvcName                = 1)  
)

/*############################################################################
 *# Set default for telehealth. Applies to all billing programs.
 *# We assume the service was provided in person.
 *############################################################################*/

update @svcs 
  set teleHealth = 0 
where 
  (hasTelehealth = 0)
	
/*############################################################################
 *#                   LEA BOP specific rules and limits
 *#
 *#               CAN ONLY SEARCH BY SERVICE NAME AT THIS TIME
 *############################################################################*/

if (@billingProgramID = 1)
begin
  
  update t1
  set 
      t1.rowBad = 1
    , processingNotes = processingNotes + ' Cannot currently search by procedure code for this plan type.'
  from @svcs as t1
  where ( 
           (t1.svcProvided               = 1)
	   and (t1.svcSearchMethodDetermined = 1)
	   and (t1.svcSearchByProcCode       = 1)
  )

end /* LEA BOP billing program */

/*############################################################################
 *#                  CYBHI specific billing rules and limits
 *############################################################################*/

if (@billingProgramID = 2)
begin
  
  /*############################################################################
   *# Get ALL procedure codes for CYBHI
   *############################################################################*/

  insert into @programProcedureCodes (
     procCode
  )
  select distinct 
    procCode = trim(cp.PROCEDURE_CODE)
  from dbo.CLAIM_Procedures as cp
  where (
        (cp.billingProgramID = 2)
    and (cp.PUT_IN_837 = 1)
  )

  /*############################################################################
   *# Get CYBHI procedure codes that require individual or group modifiers
   *############################################################################*/
  
  insert into @programProcedureCodesThatRequireIndGrp (procCode)
  values
    (N'H2014')
  , (N'H2027')

  /*############################################################################
   *# Get CYBHI procedure codes that can have a dyadic modifier
   *############################################################################*/

  insert into @cybhiProcedureCodesThatSupportDyadic (procCode)
  values     
    (N'96127')
  , (N'G9919')
  , (N'G9920')
  , (N'G0442')
  , (N'G8431')
  , (N'G8510')
  , (N'96156')
  , (N'90791')
  , (N'T1027')
  , (N'H2027')
  
  /*############################################################################
   *# Check if procedure code is valid CYBHI procedure code
   *############################################################################*/

  update t1
  set 
      t1.rowBad          = 1	  	  
    , t1.processingNotes = t1.processingNotes + ' ' + t1.procCode + ' is not in our records as a valid CYBHI program procedure code.'
  from @svcs as t1
  where ( 
        (t1.svcProvided = 1) and (t1.svcSearchMethodDetermined = 1) and (t1.svcSearchByProcCode = 1)
    and (t1.procCode not in (
	     select top 1 
	       t2.procCode 
	     from @programProcedureCodes as t2
	     where 
	       (t2.procCode = t1.procCode)	     
	   ))
  ) 
 
  /*############################################################################
   *#            Evaluate Individual or Group Service Modifer
   *############################################################################*/
      
   /* Flag all rows with procs that REQUIRE the ind or grp modifier */

   update t1
   set 
	   t1.svcSearchByProcCodeRequiresGroupFlag = 1
	 , t1.svcSearchByProcCodeUseSvcSubTypeID   = 1
	 , t1.hasGroupSvc                          = 0
   from @svcs as t1
   where 
   (
         (t1.svcProvided = 1) and (t1.svcSearchMethodDetermined = 1) and (t1.svcSearchByProcCode = 1) 
     and (t1.procCode in (select top 1 t2.procCode from @programProcedureCodesThatRequireIndGrp as t2 where t2.procCode = t1.procCode )) /* Has to be an an applicable procedure */
   )

   /* Flag all rows with procs that DO NOT require the ind or grp modifier */
   
   update t1
   set 
	   t1.svcSearchByProcCodeRequiresGroupFlag = 0	 
	 , t1.hasGroupSvc                          = 0
   from @svcs as t1
   where 
   (
    
         (t1.svcProvided = 1) and (t1.svcSearchMethodDetermined = 1) and (t1.svcSearchByProcCode = 1) 
     and (t1.procCode not in (select top 1 t2.procCode from @programProcedureCodesThatRequireIndGrp as t2 where t2.procCode = t1.procCode )) /* Has to be an an applicable procedure */
   )
	
   /* Flag all rows with procs that require the ind or grp mod and have the ind mod */

   update t1
   set 
	   t1.groupSvc                             = 0
	 , t1.hasGroupSvc                          = 1	 
	 , t1.svcSearchByProcCodeSvcSubTypeID      = 2000 /* Ind */
   from @svcs as t1
   where 
   (
     (
          (t1.svcProvided = 1) and (t1.svcSearchMethodDetermined = 1) and (t1.svcSearchByProcCode = 1)
      and (t1.svcSearchByProcCodeRequiresGroupFlag = 1) and (t1.svcSearchByProcCodeUseSvcSubTypeID = 1)
      and (t1.hasProcMods = 1) /* Have to have mods to determine the value */      
	 )

     and /* Is the HA modifier present.  If so its group = 0 */
		  
	 (
	   (t1.procMod1 = N'HA') or (t1.procMod2 = N'HA') or (t1.procMod3 = N'HA') or (t1.procMod4 = N'HA')
	 )
   )

   /* Handle all procedures that require the ind or grp mod and have the grp mod */

   update t1
   set 
	   t1.groupSvc                             = 1
	 , t1.hasGroupSvc                          = 1	 
	 , t1.svcSearchByProcCodeSvcSubTypeID      = 2001 /* grp */
   from @svcs as t1
   where 
   (
     (
          (t1.svcProvided = 1) and (t1.svcSearchMethodDetermined = 1) and (t1.svcSearchByProcCode = 1)
      and (t1.svcSearchByProcCodeRequiresGroupFlag = 1) and (t1.svcSearchByProcCodeUseSvcSubTypeID = 1)
      and (t1.hasProcMods = 1) /* Have to have mods to determine the value */      
	 )

     and /* Is the HQ modifier present.  If so its group = 1 */
	 ( 
	   (t1.procMod1 = N'HQ') or (t1.procMod2 = N'HQ') or (t1.procMod3 = N'HQ') or (t1.procMod4 = N'HQ')
	 )
   )
  
  /*############################################################################
   *#                         Evaluate Dyadic Modifier
   *############################################################################*/
   
  
  /* Default */

  update t1
  set 
    t1.dyadic = 0	
  from @svcs as t1
  where 
  (
    (t1.svcProvided = 1) and (t1.svcSearchMethodDetermined = 1) and (t1.svcSearchByProcCode = 1)       
  )
  
  /* Handle all procedures that support the dyadic option and the mod was passed */

  update t1
  set 
      t1.dyadic    = 1
	, t1.hasDyadic = 1	
  from @svcs as t1
  where 
  (
    (
		  (t1.svcProvided = 1) and (t1.svcSearchMethodDetermined = 1) and (t1.svcSearchByProcCode = 1) 
      and (t1.hasProcMods = 1) /* Has to have mods to determine */             
	  and (t1.procCode in (select top 1 t2.procCode from @cybhiProcedureCodesThatSupportDyadic as t2 where t2.procCode = t1.procCode)) /* Has to be an applicable procedure */
    )
    
	and /* Has to have mod U1.  It can be any of the mods.*/
	( 
	  (t1.procMod1 = N'U1') or (t1.procMod2 = N'U1') or (t1.procMod3 = N'U1') or (t1.procMod4 = N'U1')
    )
  )
  
   /*----------------------------------------------------------------------------
    *                            Telehealth Yes or No 
	*
	* Indicated by the presence or absence of a 93 or 95 modifier.  
	*
	* If the modifier is present the value is Yes 
	* If the modifier is absent the value is No
	*---------------------------------------------------------------------------*/

   update t1
   set 
	   t1.teleHealth    = 1
     , t1.hasTelehealth = 1
   from @svcs as t1
   where 
   (       	   
     (     
	       (t1.svcProvided   = 1) and (t1.svcSearchMethodDetermined = 1) and (t1.svcSearchByProcCode = 1) 
	   and (t1.hasProcMods   = 1) /* Have to have mods to determine the value */
	 )	 	   
	 and ((t1.procMod1 in (N'93', N'95')) or (t1.procMod2 in (N'93', N'95')) or (t1.procMod3 in (N'93', N'95')) or (t1.procMod4 in (N'93', N'95')))
   )
    
  
end /* CYBHI billing program */

/*############################################################################
 *# If the row requires a group flag and the flag is not provided row is bad
 *############################################################################*/

update t1
set 
    t1.rowBad       = 1
  , processingNotes = processingNotes + ' Group flag is required.'
from @svcs as t1
where (       
      (t1.svcProvided                          = 1)
  and (t1.svcSearchMethodDetermined            = 1)
  and (t1.svcSearchByProcCode                  = 1)
  and (t1.svcSearchByProcCodeRequiresGroupFlag = 1)
  and (t1.hasGroupSvc                          = 0)
)

/*############################################################################
 *# Find active practitioners and their discipline group
 *############################################################################*/

 /*----------------------------------------------------------------------------
  * First by NPI
  *---------------------------------------------------------------------------*/

update t1
set 
    t1.pracID    = prp.PRACTITIONER_ID
  , t1.pracName  = prp.CONCAT_NAME
  , t1.groupID   = ggd.GROUP_ID
  , t1.groupName = ggd.GROUP_NAME
  , t1.pracFound = 1

from @svcs                         as t1
join dbo.PRACTITIONER_Client       as prc on prc.CLIENT_ID       = t1.clientID
join dbo.PRACTITIONER_Practitioner as prp on prp.PRACTITIONER_ID = prc.PRACTITIONER_ID
join dbo.PRACTITIONER_GROUPS       as pgd on pgd.PRACTITIONER_ID = prp.PRACTITIONER_ID and (pgd.GROUP_TYPE in (1,2)) and (pgd.ACTIVE = 1)
join dbo.GROUP_Group               as ggd on ggd.GROUP_ID        = pgd.GROUP_ID

where (
        (t1.hasPracNPI = 1)
    and (t1.pracFound  = 0)
	and (prp.npiNumber = t1.pracNPI)
    and (prp.ACTIVE    = 1)
)

/*----------------------------------------------------------------------------
  * Then try by email if NPI not provided but email is
  *---------------------------------------------------------------------------*/

update t1
set 
    t1.pracID    = prp.PRACTITIONER_ID
  , t1.pracName  = prp.CONCAT_NAME
  , t1.groupID   = ggd.GROUP_ID
  , t1.groupName = ggd.GROUP_NAME
  , t1.pracFound = 1

from @svcs                         as t1
join dbo.PRACTITIONER_Client       as prc on prc.CLIENT_ID = t1.clientID
join dbo.PRACTITIONER_Practitioner as prp on prp.PRACTITIONER_ID = prc.PRACTITIONER_ID
join dbo.PRACTITIONER_GROUPS       as pgd on pgd.PRACTITIONER_ID = prp.PRACTITIONER_ID and (pgd.GROUP_TYPE in (1,2)) and (pgd.ACTIVE = 1)
join dbo.GROUP_Group               as ggd on ggd.GROUP_ID        = pgd.GROUP_ID

where (
        (t1.hasPracNPI   = 0)
	and (t1.hasPracEmail = 1)	
    and (t1.pracFound    = 0)
	and (prp.EMAIL       = t1.pracEmail)
    and (prp.ACTIVE      = 1)
)


/*############################################################################
 *# If practitioner was not found flag the row as bad
 *############################################################################*/

update @svcs 
set 
    rowBad = 1 
  , processingNotes = processingNotes + ' No practitioner was found with the npi ' + pracNPI + '.'
where 
  ((hasPracNPI = 1) and (pracFound = 0))

update @svcs 
set 
    rowBad = 1 
  , processingNotes = processingNotes + ' No practitioner was found with the email ' + pracEmail + '.'
where 
  ((hasPracNPI = 0) and (hasPracEmail = 1) and (pracFound = 0))

/*############################################################################
 *# Find active patients and their dob 
 *############################################################################*/

/*----------------------------------------------------------------------------
  * First by SSID
  *---------------------------------------------------------------------------*/

update t1
set 
    t1.patID    = pap.PATIENT_ID
  , t1.patName  = pap.CONCAT_NAME 
  , t1.patDOB   = pap.DATE_OF_BIRTH
  , t1.patFound = 1
from @svcs                as t1
join dbo.PATIENTS_Client  as pac on pac.CLIENT_ID  = t1.clientID
join dbo.PATIENTS_Patient as pap on pap.PATIENT_ID = pac.PATIENT_ID
where (     
      (t1.hasPatSSID      = 1)
  and (pap.CSIS           = t1.patSSID)  
  and (pap.ACTIVE != N'N')
)

/*----------------------------------------------------------------------------
  * Then by student id if SSID is not provided but student id is
  *---------------------------------------------------------------------------*/

update t1
set 
    t1.patID    = pap.PATIENT_ID
  , t1.patName  = pap.CONCAT_NAME 
  , t1.patDOB   = pap.DATE_OF_BIRTH
  , t1.patFound = 1
from @svcs                as t1  /* Uses [STUDENT_ID_PAT_ID_IDX] index */
join dbo.PATIENTS_SCHOOL  as ps  on ((ps.STUDENT_ID = t1.patStudentID) and (ps.PATIENT_ID is not null) and (ps.PATIENT_SCHOOL_ID is not null))
join dbo.PATIENTS_Client  as pac on ((pac.CLIENT_ID  = t1.clientID) and (pac.PATIENT_ID = ps.PATIENT_ID))
join dbo.PATIENTS_Patient as pap on (pap.PATIENT_ID = pac.PATIENT_ID)
where (     
      (t1.hasPatSSID      = 0)
  and (t1.hasPatStudentID = 1)  
  and (t1.patFound        = 0)
  and (pap.ACTIVE != N'N')
)

/*############################################################################
 *# If a patient was not found flag the row as bad
 *############################################################################*/

update @svcs 
set 
    rowBad          = 1 
  , processingNotes = processingNotes + ' No patient was found with the SSID ' + patSSID + '.'
where 
  ((hasPatSSID = 1) and (patFound = 0))

update @svcs 
set 
    rowBad          = 1 
  , processingNotes = processingNotes + ' No patient was found with the student ID ' + patStudentID + '.'
where 
  ((hasPatSSID = 0) and (hasPatStudentID = 1) and (patFound = 0))

/*############################################################################
 *# Determine plan type
 *############################################################################*/

update t1
set 
  t1.planTypeID = dbo.DOS_DOB_IEP_BILLING_PROGRAM_TO_PLAN_TYPE (t1.dos, t1.patDOB, @isIEPOrIFSP, @billingProgramID)
from @svcs as t1
where ( 
      (t1.hasDos   = 1) 
  and (t1.patFound = 1)
)

/*############################################################################
 *# If plan type was found flag it
 *############################################################################*/

update t1
set  
  t1.planTypeFound = 1
from @svcs as t1
where (         
        (t1.hasDos   = 1) 
    and (t1.patFound = 1)
    and (t1.planTypeID is not null)
)

/*############################################################################
 *# If plan type was not found flag the row as bad
 *############################################################################*/

update t1
set  
    t1.rowBad       = 1
  , processingNotes = processingNotes + ' Service plan type could not be determined for this patient.'
from @svcs as t1
where (         
        (t1.hasDos        = 1) 
    and (t1.patFound      = 1)
    and (t1.planTypeFound = 0)
)

/*############################################################################
 *# Attempt to find service based on procedure code 
 *############################################################################*/

/* 1 - Grp or Ind not required, dyadic is Y or N, telehealth is Y or N */

update t1
set 
    t1.svcNameSelectionID = t3.SERVICE_NAME_ID
  , t1.svcNameSelection   = t3.SERVICE_NAME
  , t1.svcFound           = 1
from @svcs as t1
cross apply (
  select top 1
      t2.SERVICE_NAME_ID
	, t2.SERVICE_NAME
  from dbo.SERVICES_VIEW_ALL_CORE (
      null
    , t1.groupID
    , t1.planTypeID
    , null
    , null
    , 1
    , 1
    , t1.dos
    , null) as t2  
  join dbo.CLAIM_Procedures as cp on ((cp.PROCEDURE_ID = t2.PROCEDURE_ID) and (cp.excludeFromServiceRecordImport = 0))
  where (
        (t2.PROCEDURE_CODE            = t1.procCode)
	and (t2.SERVICE_IS_VIA_TELEHEALTH = t1.teleHealth)   	   
	and (t2.SERVICE_IS_DYADIC         = t1.dyadic)    
  )
) as t3

where (
      (t1.rowBad                                = 0)
  and (t1.svcFound                              = 0) 
  and (t1.svcSearchByProcCode                   = 1)
  and (t1.svcSearchByProcCodeRequiresGroupFlag  = 0)
  and (t1.svcSearchByProcCodeUseSvcSubTypeID    = 0)
)

/*  2 - Grp or Ind required, dyadic is Y or N, telehealth is Y or N */

update t1
set 
    t1.svcNameSelectionID = t3.SERVICE_NAME_ID
  , t1.svcNameSelection   = t3.SERVICE_NAME
  , t1.svcFound           = 1
from @svcs as t1

cross apply (
  select top 1
      t2.SERVICE_NAME_ID
	, t2.SERVICE_NAME
  from dbo.SERVICES_VIEW_ALL_CORE (
      null
    , t1.groupID
    , t1.planTypeID
    , null
    , null
    , 1
    , 1
    , t1.dos
    , null) as t2
  join dbo.CLAIM_Procedures as cp on ((cp.PROCEDURE_ID = t2.PROCEDURE_ID) and (cp.excludeFromServiceRecordImport = 0))
  where (
        (t2.PROCEDURE_CODE            = t1.procCode)
	and (t2.SERVICE_SUB_TYPE_1_ID     = t1.svcSearchByProcCodeSvcSubTypeID) 
	and (t2.SERVICE_IS_VIA_TELEHEALTH = t1.teleHealth)	  
	and (t2.SERVICE_IS_DYADIC         = t1.dyadic)
  )
) as t3

where (
      (t1.rowBad                                = 0)
  and (t1.svcFound                              = 0) 
  and (t1.svcSearchByProcCode                   = 1)
  and (t1.svcSearchByProcCodeRequiresGroupFlag  = 1)
  and (t1.svcSearchByProcCodeUseSvcSubTypeID    = 1)
)

/*############################################################################
 *# Attempt to find service based on service name 
 *#
 *# Service name will have individual or group and service name will have
 *# dyadic as part of name.  Telehealth will be specified by flag.
 *############################################################################*/

update t1
set 
    t1.svcNameSelectionID = t3.SERVICE_NAME_ID
  , t1.svcNameSelection   = t3.SERVICE_NAME
  , t1.svcFound           = 1
from @svcs as t1
cross apply (
  select top 1
      t2.SERVICE_NAME_ID
	, t2.SERVICE_NAME
  from dbo.SERVICES_VIEW_ALL_CORE (
      null
    , t1.groupID
    , t1.planTypeID
    , null
    , null
    , 1
    , 1
    , t1.dos
    , 1) as t2
  join dbo.CLAIM_Procedures as cp on ((cp.PROCEDURE_ID = t2.PROCEDURE_ID) and (cp.excludeFromServiceRecordImport = 0))
  where (
        (t2.SERVICE_NAME_WITHOUT_IN_PERSON_OR_TELEHEALTH_TEXT = t1.svcName)
	and (t2.SERVICE_IS_VIA_TELEHEALTH                         = t1.teleHealth)
  )
) as t3
where (
      (t1.rowBad             = 0)
  and (t1.svcFound           = 0) 
  and (t1.svcSearchBySvcName = 1)  
)

/*############################################################################
 *# Flag any row that the service was not found as bad
 *############################################################################*/

update t1
set 
    rowBad          = 1  
  , processingNotes = processingNotes                     
					+ ' Service could not be found by '
                    + iif (  (t1.svcSearchBySvcName = 1)
					       , ' service name '   + t1.svcName 
					       , ' procedure code ' + t1.procCode )
from @svcs as t1
where (
      (t1.rowBad   = 0)
  and (t1.svcFound = 0)
)

/*############################################################################
 *# Find existing service records and if any found flag row as bad
 *############################################################################*/

update t1
set 
    t1.svcRecID        = sr2.id
  , t1.rowBad          = 1
  , t1.svcRecExists    = 1
  , t1.processingNotes = t1.processingNotes + ' Service record already exists.'
from @svcs as t1

/*CLIENT_PRAC_PAT_DOS_CREATED_ID_W_EXTRA_COLS*/

cross apply (
  select top 1 
    sr1.id 
  from dbo.SERVICE_RECORDS as sr1 
  where ((
        (sr1.clientID = t1.clientID)
    and (sr1.pracID   = t1.pracID)
    and (sr1.patID    = t1.patID)
    and (sr1.dos      = t1.dos)
    and (sr1.created is not null)
    and (sr1.userId  is not null)
    and (sr1.id      is not null))
    and (sr1.planType = t1.planTypeID)
    and (sr1.nameID   = t1.svcNameSelectionID)
	and (sr1.[state] not in (99,199)))
) as sr2

where (
  (t1.rowBad = 0)
)

/*############################################################################
 *# If we reach this point and we are validating or there are no good rows exit
 *############################################################################*/

if ((@validateRec = 1) or (not exists (select top 1 * from @svcs where rowBad = 0)))
begin
  
  set @svcRecSaveStatusMsg = 'Service record can be saved'
  
  update t1
	set 
	    t1.svcRecID                = 0
	  , t1.svcRecSpDetails         = ''
	  , t1.svcRecSaveWasOK         = 1
	  , t1.svcRecSaveStatusMessage = @svcRecSaveStatusMsg
	  , t1.processingNotes         = t1.processingNotes + ' ' + @svcRecSaveStatusMsg	  
	from @svcs as t1
    where 
	  (t1.rowBad = 0)  
  
    update @svcs set processingNotes = trim(processingNotes)
  
    set @jsonData = '{"importData":' 
                + @importDataJSON 
				+ ',"exportData":'
				+ convert(varchar(max),(select * from @svcs FOR JSON AUTO, INCLUDE_NULL_VALUES ))
				+ '}'
  return(0)
end

/*############################################################################
 *# Create batch ID 
 *############################################################################*/

EXEC dbo.SERVICE_RECORD_BATCH_ID_Create @userID, @userGroup, @userRank, @saveType, @validateRec, @batchIDRecID OUTPUT , @batchID OUTPUT 

/*############################################################################
 *# Create service records (1 transaction per row)
 *############################################################################*/

set @tranOpen = 0
set @curIdx   = 0

select 
  @maxIdx = max(idx) 
from @svcs as t1

while (@curIdx <= @maxIdx)
begin

  /*############################################################################
   *# Get service row
   *############################################################################*/

  set @rowBad    = 1
  set @nameID    = null
  set @pracID    = null
  set @patID     = null     	 
  set @startTime = null
  set @numMins   = null
  set @dos       = null
  set @notes     = ''

  select top 1
      @rowBad           = t1.rowBad
	, @nameID           = t1.svcNameSelectionID
    , @pracID           = t1.pracID
	, @patID            = t1.patID
	, @startTime        = t1.startTime
	, @numMins          = t1.numMins
	, @dos              = t1.dos
	, @notes            = t1.notes
  from @svcs as t1
  where 
    (t1.idx = @curIdx)	

  /*############################################################################
   *# If the row is not bad
   *############################################################################*/

  if (@rowBad = 0)
  begin
    
	/*############################################################################
     *# Attempt to save
     *############################################################################*/

	set @spDetailsOut        = ''
	set @svcRecID            = 0
    set @svcRecSaveOK        = 0
	set @svcRecSaveStatusMsg = ''
	set @tranOpen            = 0

	begin try
	
      begin transaction 
        
		set @tranOpen = 1 

        exec dbo.SERVICE_RECORD_Save_Core 
	        @userID 
          , @userGroup
	      , @userRank
	      , @generateClaims   /* Claimable */
	      , 116               /* Service record import entry type */     
	      , @reference
	      , null
	      , null    
	      , @dos    
	      , @clientID
	      , @pracID
	      , @patID
	      , @isIEPOrIFSP       
	      , @nameID
	      , 0         /* No orp doc provided in imports */
	      , null
	      , null
	      , 0
	      , null
	      , null
	      , null
	      , null
	      , @startTime
	      , @numMins    
	      , 0  
	      , 0    
	      , 0    
	      , 0    
	      , 0    
	      , 0    
	      , 0    
	      , 0
	      , 0                /* Patient is never absent */
	      , 0                /* Practitioner is never absent */
	      , 0                /* This is never a makup session */
	      , null             /* @attendanceSelectionID*/
	      , @notes    
	      , null
	      , null
	      , null
          , 0                 /* goal tracking */
	      , @billingProgramID /* Billing program */
	      , 0                 /* Has fillable pdf */
          , '[]'              /* Fillable pdf selections */
	      , '[]'              /* Fillable pdf answers*/
	      , ''                /*@editDelReason*/
	      , @validateRec   
	      , 1 /* Always save type = 1*/
	      , null /* No edits so no rec id*/    
          , @msgDupRec 
	      , @msgInvCombo    
	      , @MsgNoRec
	      , @MsgNoEdit
	      , @MsgDataError
	      , @MsgMinReq    
	      , @MsgMinDef     
	      , @MsgMilReq
	      , @MsgPatElg
	      , @MsgPatDOBGteDOS
	      , @MsgNotActive
	      , @MsgPatAbsent
	      , @MsgFutureDOS
	      , @spDetailsOut OUTPUT
	      , @svcRecID     OUTPUT 	  

        /*############################################################################
         *# Associate batch id
         *############################################################################*/

	    set @batchIDAssRecID = null	
	  		
	    exec dbo.SERVICE_RECORD_BATCH_ID_Assign 
	        @userID
		  , @userGroup
		  , @userRank
		  , 1 /*@saveType always 1*/
		  , @validateRec
		  , @batchID
		  , @curIdx
		  , @svcRecID
		  , @batchIDAssRecID OUTPUT 
    
	    /*############################################################################
          *# If we reach this point we are ok
          *############################################################################*/

	    set @svcRecSaveOK        = 1		   
	    set @svcRecSaveStatusMsg = 'Service record has been saved'
	    
      commit transaction
	  set @tranOpen = 0
	  
	end try
    
	/*############################################################################
     *# If we end up here there is a problem
     *############################################################################*/

	begin catch
	  set @svcRecSaveOK        = 0
	  set @svcRecSaveStatusMsg = ERROR_MESSAGE()
	  if (@tranOpen = 1) rollback transaction
	  set @tranOpen = 0
	end catch
	 	
	/*############################################################################
     *# Update our stats
     *############################################################################*/

	update t1
	set 
	    t1.svcRecID                = @svcRecID
	  , t1.svcRecSpDetails         = @spDetailsOut
	  , t1.svcRecSaveWasOK         = @svcRecSaveOK
	  , t1.svcRecSaveStatusMessage = @svcRecSaveStatusMsg
	  , t1.processingNotes         = t1.processingNotes + ' ' + @svcRecSaveStatusMsg	  
	from @svcs as t1
	where 
	  (t1.idx = @curIdx)
  end /* Row is not bad */

  set @curIdx = @curIdx + 1
  
end /* While */

set @recordID = @batchIDRecID
update @svcs set processingNotes = trim(processingNotes)

set @jsonData = '{"importData":' 
                + @importDataJSON 
				+ ',"exportData":'
				+ convert(varchar(max),(select * from @svcs FOR JSON AUTO, INCLUDE_NULL_VALUES ))
				+ '}'
return(0)

END TRY
BEGIN CATCH

  /*-------------------------------
   * If we end up here something
   * went wrong.  Cancel any pending
   * transactions and return any
   * error any error messages to
   * the caller
   *------------------------------*/

  if (@tranOpen = 1)
  begin
    rollback transaction
	set @tranOpen = 0
  end

  -- Error or raise error with severity 11 to 19 will be caught here

  DECLARE @ErrorMessage  AS NVARCHAR(4000)
  DECLARE @ErrorSeverity AS INT
  DECLARE @ErrorState    AS INT

  SELECT  @ErrorMessage  = ERROR_MESSAGE(),
          @ErrorSeverity = ERROR_SEVERITY(),
          @ErrorState    = ERROR_STATE()

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

GRANT EXECUTE ON  [dbo].[Service_Records_Data_Imports_Save] TO [webuser]
GO
