USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Patient_Data_Imports_Parse_SpEd_Data_File_Into_Summary_Rows_Core') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.Patient_Data_Imports_Parse_SpEd_Data_File_Into_Summary_Rows_Core
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[Patient_Data_Imports_Parse_SpEd_Data_File_Into_Summary_Rows_Core] (
    @clientID        bigint   = null
  , @patID           bigint   = null
  , @spEdSvcCode     int      = null
  , @startDate       datetime = null
  , @importFileID    bigint   = null  
  , @canUseRow       bit      = null
  , @canUseSvc       bit      = null
  , @minYear         int      = null
  , @maxYear         int      = null
) 

/***************************************************************************    
 * Patient_Data_Imports_Parse_SpEd_Data_File_Into_Summary_Rows_Core */    
/**    
 *
 * This returns summarized by service data for each row in @importFileID.
 *    
 ***************************************************************************/        

RETURNS TABLE
AS
RETURN
(

/*###########################################################################*/
/*# Pass 1                                                                  #*/
/*#                                                                         #*/
/*#  - Build svc line details JSON. Note: Include anything in the svc line  #*/
/*#    details that is needed after the aggregate that is not part of the   #*/
/*#    aggregate.                                                           #*/
/*###########################################################################*/

with
cte_p1
as
(
select 
    t1.*  
  , svcLineDetailsJSON = dbo.Patient_Data_Imports_Parse_SpEd_Data_File_Row_Create_Svc_Line_Details_JSON (
      t1.svcLineIdx 
	, t1.doNotReport
	, t1.fileID
    , t1.fileRowID 
	, t1.hasEndDate
	, t1.duration 
	, t1.spEdLocationCode
	, t1.spEdProviderCode
	, t1.individualSvc
	, t1.groupSvc
    , t1.spEdDisabilityCode1
	, t1.spEdDisabilityCode2
	, t1.spEdSpecTransport
	, t1.lastEvalDate
    , t1.lastAnnIEPDate
    , t1.nextAnnIEPDate 
    , t1.exitedSpEdDate	
	, t1.caseManagerName
	, t1.additionalInfo
	, t1.reportableToCDE 
	, null
	, null
	)

from dbo.Patient_Data_Imports_Parse_SpEd_Data_File_Into_Detail_Rows_Core (
    @clientID 
  , @patID   
  , @spEdSvcCode
  , @startDate
  , @importFileID
  , null 
  , @canUseRow  
  , @minYear  
  , @maxYear ) as t1
)
,

/*###########################################################################*/
/*# Pass 2                                                                  #*/
/*#                                                                         #*/
/*#  - Aggregate and build svcLinesDetailsJSON                              #*/
/*#                                                                         #*/
/*#  - Aggregate and build fileRowIDs                                       #*/
/*#                                                                         #*/
/*#  - Build a dnrFlags check field we will use later to determine if a     #*/
/*#    svc should be included                                               #*/
/*#                                                                         #*/
/*#  - Build a indSvcFlags check field we will use later to determine if    #*/
/*#    any svcLineDetails has a indSvc flag set.  We will use this to set   #*/
/*#    a summary value later.                                               #*/
/*#                                                                         #*/
/*#  - Build a grpSvcFlags check field we will use later to determine if    #*/
/*#    any svcLineDetails has a grpSvc flag set.  We will use this to set   #*/
/*#    a summary value later.                                               #*/
/*###########################################################################*/

cte_p2
as
(

select 
    p1.clientID  
  , p1.fileID
  , p1.patID
  , p1.spEdSvcCode
  , p1.startDate
  , p1.endDate
  , p1.spEdFreqCode
  , p1.svcIdx          
  , totalDuration       = sum(p1.duration) 
  , numSvcLines         = count(p1.fileRowID)  
  , svcLinesDetailsJSON = '[' + STRING_AGG(convert(varchar(max),p1.svcLineDetailsJSON),',') +']'
  , dnrFlags            = STRING_AGG(convert(varchar(max),p1.doNotReport),'')
  , indSvcFlags         = STRING_AGG(convert(varchar(max),p1.individualSvc),'')
  , grpSvcFlags         = STRING_AGG(convert(varchar(max),p1.groupSvc),'')

from cte_p1 as p1

/*------------------------------------*/
/* Note: We heavily depend on the     */
/* following grouping.  If a data     */
/* file has svcs that need to be      */
/* grouped together they need to      */
/* have accurate values               */
/*------------------------------------*/

group by 
    p1.clientID
  , p1.fileID
  , p1.patID
  , p1.spEdSvcCode
  , p1.startDate
  , p1.endDate
  , p1.spEdFreqCode
  , p1.svcIdx 
)
,

/*###########################################################################*/
/*# Pass 3                                                                  #*/
/*#                                                                         #*/
/*#  - Build a "all true" check dnr field that is comparible to dnr check.  #*/
/*#    field build in previous pass.   This will be used later.             #*/
/*#                                                                         #*/
/*#  - Get client pref for skipping svc contract if all svc lines are dnr.  #*/
/*###########################################################################*/

cte_p3
as
(
select 
    p2.* 
  , allDnrFlagsAreTrue                  = convert(bit,(iif((p2.dnrFlags = REPLICATE('1',p2.numSvcLines)),1,0)))
  , skipSvcContractIfAllDnrFlagsAreTrue = convert(bit,(isnull(scr.skipSvcContractIfAllDnrFlagsAreTrue,0)))
  , individualSvc                       = convert(bit,(iif((CHARINDEX('1', p2.indSvcFlags) = 0),0,1)))
  , groupSvc                            = convert(bit,(iif((CHARINDEX('1', p2.grpSvcFlags) = 0),0,1))) 
from cte_p2 as p2
left join dbo.Client_SpEd_Service_Specific_Data_Import_Rules as scr on ((scr.clientID = p2.clientID) and (scr.spEdSvcCode = p2.spEdSvcCode))
)
,

/*###########################################################################*/
/*# Pass 4                                                                  #*/
/*#                                                                         #*/
/*#  - Create canUseSvc flag value                                          #*/
/*###########################################################################*/

cte_p4
as
(

select 
    p3.* 
  , canUseSvc = convert (bit, (case 
      when (p3.allDnrFlagsAreTrue = 0) and ( p3.skipSvcContractIfAllDnrFlagsAreTrue = 0) then 1
	  when (p3.allDnrFlagsAreTrue = 0) and ( p3.skipSvcContractIfAllDnrFlagsAreTrue = 1) then 1
	  when (p3.allDnrFlagsAreTrue = 1) and ( p3.skipSvcContractIfAllDnrFlagsAreTrue = 0) then 1
	  when (p3.allDnrFlagsAreTrue = 1) and ( p3.skipSvcContractIfAllDnrFlagsAreTrue = 1) then 0
	  else 1 end))
from cte_p3 as p3
)

/*###########################################################################*/
/*# Output                                                                  #*/
/*#                                                                         #*/
/*#  - Eval canUseSvc flag value                                            #*/
/*#  - Extract reportable (to CDE) latestFileRowID, hasEndDate              #*/
/*###########################################################################*/

select 
    p4.* 
  , t3.*
from cte_p4 as p4

/*------------------------------------*/
/* The latest file rowID will be      */
/* a reference to the 1 reportable    */
/* to CDE row.                        */
/*------------------------------------*/

cross apply (
  
  select top 1
      t2.latestFileRowID
	, t2.hasEndDate
  from
  (
    /* Try for reportable */

    select top 1
       latestFileRowID = t1.fileRowID
     , t1.hasEndDate
	 , selectPref = 1
	from dbo.Patient_Data_Imports_Parse_SpEd_Data_File_Row_Parse_Svc_Lines_Details_JSON (p4.svcLinesDetailsJSON) as t1
    where 
      (t1.reportableToCDE = 1)
    order by
	  t1.svcLineIdx asc

    union /* Takes care of cases where we have 2 possible */

	/* Fallback will be 1st row */

    select top 1
        latestFileRowID = t1.fileRowID
      , t1.hasEndDate
	  , selectPref = 2
    from dbo.Patient_Data_Imports_Parse_SpEd_Data_File_Row_Parse_Svc_Lines_Details_JSON (p4.svcLinesDetailsJSON) as t1
    where 
      (t1.svcLineIdx = 1)
  ) as t2
  order by 
    t2.selectPref asc
) as t3

where (
      (1=1)
  and ((@canUseSvc is null) or (p4.canUseSvc = @canUseSvc))
)

)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[Patient_Data_Imports_Parse_SpEd_Data_File_Into_Summary_Rows_Core] TO [webuser]
GO   

