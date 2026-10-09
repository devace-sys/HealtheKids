
/* TODO: This is deprecated.  Remove once replacement is proven to work. */

USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Patient_Data_Imports_Parse_SpEd_Data_Files_Into_Summary_Rows_Core') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.Patient_Data_Imports_Parse_SpEd_Data_Files_Into_Summary_Rows_Core
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[Patient_Data_Imports_Parse_SpEd_Data_Files_Into_Summary_Rows_Core] (
  @clientID bigint = null
) 

/***************************************************************************    
 * Patient_Data_Imports_Parse_SpEd_Data_Files_Into_Summary_Rows_Core */    
/**    
 *
 * This returns summarized by service data for each row by @clientID in
 * Patient_Data_Imports_SpEd_Data_File_Summary_Rows.  
 * 
 * It also provides a corrected (normalized) end date for the service data.
 * for the latest imports 
 *
 * This is a conversion of an earlier routine that generated this data 
 * "on the fly" by aggregating the results of multiple calls to the following
 * udf: Patient_Data_Imports_Parse_SpEd_Data_File_Into_Summary_Rows_Core
 *
 ***************************************************************************/        

RETURNS @usableSvcs table (
    clientID                 bigint
  , patID                    bigint
  , spEdSvcCode              int
  , startDate                datetime
  , fileID                   bigint
  , idx                      bigint identity(1,1)
  , endDate                  datetime
  , spEdFreqCode             int
  , individualSvc            bit
  , groupSvc                 bit  
  , totalDuration            int
  , numSvcLines              int
  , svcLinesDetailsJSON      varchar(max)
  , latestFileRowID          bigint
  , hasEndDate               bit
  , latestImport             bit default(0)
  , adjustedEndDate          datetime 
  , endDateNeedsToBeAdjusted bit default(0)

unique clustered  (clientID, patID, spEdSvcCode, startDate, fileID, idx)
)

AS
BEGIN

declare @latestUsableSvcs as table (
    clientID        bigint
  , patID           bigint
  , spEdSvcCode     int
  , startDate       datetime
  , fileID          bigint
  , adjustedEndDate datetime
unique clustered  (clientID, patID, spEdSvcCode, startDate, fileID)
)

declare @latestUsableFiles as table (
    clientID    bigint
  , fileID      bigint
unique clustered  (clientID, fileID)
)

/*###########################################################################*/
/*#  Pass 1                                                                 #*/
/*#                                                                         #*/
/*#  - Get latest files data that contain data for client, patient          #*/
/*#    spEdSvcCode, start date.  We are assuming that the last file we      #*/
/*#    received containing this data will have the most accurate data as    #*/
/*#    service terms that are still being negotiated will have been settled #*/
/*#                                                                         #*/
/*#  - Calculate an end date we can use for normalizing dates later         #*/
/*#                                                                         #*/
/*###########################################################################*/

;with
cte_p1
as
(
  select 
      t1.clientID
    , t1.patID
    , t1.spEdSvcCode
    , t1.startDate
    , fileID = max(t1.fileID)
  from dbo.Patient_Data_Imports_SpEd_Data_File_Summary_Rows as t1
  where (
     (t1.clientID = @clientID)
  )
  group by
      t1.clientID
    , t1.patID
    , t1.spEdSvcCode
    , t1.startDate
)

insert into @latestUsableSvcs (
    clientID 
  , patID 
  , spEdSvcCode
  , startDate 
  , fileID  
  , adjustedEndDate
)
select 
    p1.clientID
  , p1.patID
  , p1.spEdSvcCode
  , p1.startDate
  , p1.fileID
  , adjustedEndDate = dateadd(day,-1,(lead(p1.startDate) over (partition by p1.clientID, p1.patID, p1.spEdSvcCode order by p1.startDate)))
from cte_p1 as p1
order by
    p1.clientID
  , p1.patID
  , p1.spEdSvcCode
  , p1.startDate
  , p1.fileID
option(recompile)

/*###########################################################################*/
/*#  Pass 2                                                                 #*/
/*#                                                                         #*/
/*#  - Get just the file ids that contain all of the data we collected for  #*/
/*#    pass 1                                                               #*/
/*#                                                                         #*/
/*# - Note: We will use this to limit the # of times we have to retrieve    #*/
/*#   the same sets of data                                                 #*/
/*###########################################################################*/

insert into @latestUsableFiles (
    clientID
  , fileID
)
select distinct 
    t1.clientID
  , t1.fileID 
from @latestUsableSvcs as t1
order by 
    t1.clientID
  , t1.fileID
option(recompile)

/*###########################################################################*/
/*#  Pass 3                                                                 #*/
/*#                                                                         #*/
/*#  - Get all of the data from the files that were identified in           #*/
/*#    pass 2                                                               #*/
/*###########################################################################*/

insert into @usableSvcs (
    clientID 
  , patID 
  , spEdSvcCode
  , startDate 
  , fileID 
  , endDate
  , spEdFreqCode
  , individualSvc
  , groupSvc
  , totalDuration
  , numSvcLines
  , svcLinesDetailsJSON 
  , latestFileRowID
  , hasEndDate
)

select 
  t3.*
from @latestUsableFiles as t1
cross apply (
  select 
	  t2.clientID 
    , t2.patID 
    , t2.spEdSvcCode
    , t2.startDate 
    , t2.fileID  
    , t2.endDate 
    , t2.spEdFreqCode
    , t2.individualSvc
    , t2.groupSvc
    , t2.totalDuration
    , t2.numSvcLines
    , t2.svcLinesDetailsJSON 
    , t2.latestFileRowID
    , t2.hasEndDate  
  from dbo.Patient_Data_Imports_SpEd_Data_File_Summary_Rows as t2
  where ( 
        (t2.clientID = @clientID)
    and (t2.fileID   = t1.fileID)
  )
) as t3
order by
    t3.clientID
  , t3.patID
  , t3.spEdSvcCode
  , t3.startDate
  , t3.fileID
option(recompile)

/*###########################################################################*/
/*#  Pass 4                                                                 #*/
/*#                                                                         #*/
/*#  - Flag the rows from pass 3 that represent the latest data imported    #*/
/*#    using the data we collected in pass 1                                #*/
/*###########################################################################*/

update t2
  set t2.latestImport = 1
from @latestUsableSvcs as t1
join @usableSvcs       as t2 on   ((t2.clientID   = t1.clientID)
					         and  (t2.patID       = t1.patID) 
					         and  (t2.spEdSvcCode = t1.spEdSvcCode)
					         and  (t2.startDate   = t1.startDate)
	                         and  (t2.fileID      = t1.fileID))
option (recompile)

/*###########################################################################*/
/*#  Pass 5                                                                 #*/
/*#                                                                         #*/
/*#  - Determine adjusted end date (for normalization) for latest import    #*/
/*###########################################################################*/

update t2
  set t2.adjustedEndDate = iif((t1.adjustedEndDate is null)
                               , t2.endDate
				               , iif((t2.endDate > t1.adjustedEndDate)
				                     , t1.adjustedEndDate
						             , t2.endDate))
from @latestUsableSvcs as t1
join @usableSvcs       as t2 on   ((t2.clientID    = t1.clientID)
					         and  (t2.patID       = t1.patID) 
					         and  (t2.spEdSvcCode = t1.spEdSvcCode)
					         and  (t2.startDate   = t1.startDate)
	                         and  (t2.fileID      = t1.fileID))
where (
      (t2.startDate < t2.endDate)
  and (t2.latestImport = 1)
)
option (recompile)

/*###########################################################################*/
/*#  Pass 6                                                                 #*/
/*#                                                                         #*/
/*#  - Flag cases where adjusted end date should be used instead of         #*/
/*#    end date                                                             #*/
/*###########################################################################*/

update @usableSvcs
  set endDateNeedsToBeAdjusted = 1
where 
  (endDate != adjustedEndDate)
option (recompile)

/*###########################################################################*/
/*#  Done                                                                   #*/
/*###########################################################################*/

return

END


GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[Patient_Data_Imports_Parse_SpEd_Data_Files_Into_Summary_Rows_Core] TO [webuser]
GO   

