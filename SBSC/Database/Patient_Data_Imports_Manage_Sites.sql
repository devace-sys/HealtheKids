USE spedmon
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Patient_Data_Imports_Manage_Sites') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.Patient_Data_Imports_Manage_Sites
GO


/*-------------------------------
 * Create new
 *------------------------------*/

CREATE PROCEDURE [dbo].[Patient_Data_Imports_Manage_Sites] (
    @userID                         bigint
  , @userGroup                      int
  , @userRank                       int
  , @clientID                       bigint
  , @patientDataImportID            bigint
  , @testMode                       bit
  , @manageResultsJSON              varchar(max) output
)
AS

BEGIN

set nocount on

declare @today                               as datetime
declare @tranOpen                            as bit          = 0
declare @fileSubClass                        as varchar(256) = ''
declare @importFromFileReferenceID           as bigint       = 0
declare @structuredDataImportID              as bigint       = null
declare @statCount                           as int          = 0

declare @importStatistics as table (
    idx                bigint identity(1,1)
  , label              varchar(512)
  , [name]             varchar(256)
  , [value]            varchar(max)
  , [returnStatus]     bigint
  , [forPCALStaffOnly] bit
)

declare @importExceptions as table (
    idx                bigint identity(1,1)
  , label              varchar(512)
  , [name]             varchar(256)
  , [value]            varchar(max)
  , [returnStatus]     bigint
  , [forPCALStaffOnly] bit
)

declare @incomingSiteData as table (
    idx                bigint identity(1,1)
  , siteName           nvarchar(50)
  , school_CDS_7       nchar(7)
  , existingSiteName   nvarchar(50)
  , existingSiteID     bigint default(null)

  -- NOTE: everywhere were are INSERTing/UPDATEing existingSiteID in @isd
  --       we also need to INSERT/UPDATE existingSiteCDS,
  --       since that is the value we are actually using to pre-update the import log

  , existingSiteCDS    nchar(7)

  , existingSiteActive bit default(null)

  , importRowIDsJSONArr       varchar(max)

  , attemptFuzzyMatchByNameAndCode bit not null default (0)
)

declare @unknownSitesNoNameOrCode as table (
    idx                 bigint identity(1,1)
  , incomingSiteDataIdx bigint
  , siteName            nvarchar(50)
  , school_CDS_7        nchar(7)
)

declare @existingSitesToReactivate as table (
    idx                 bigint identity(1,1)
  , incomingSiteDataIdx bigint
  , existingSiteID      bigint
)

declare @existingSitesToRename table (
    idx                 bigint identity(1,1)
  , incomingSiteDataIdx bigint
  , existingSiteID      bigint
)

declare @newSitesToAddWCdsProvided as table (
    idx                 bigint identity(1,1)
  , incomingSiteDataIdx bigint
)

declare @iterNewSitesToAddUnknownCDS as table (
    idx int identity(1,1)
  --, isd_idx bigint   -- the siteName is distinct in the @isd tbl; we don't need the isd_idx in here, I guess
  , siteName          nvarchar(50)
)

declare @newSitesAdded as table (
    SITE_ID             bigint
  , SITE_NAME           nvarchar(50)
  , SITE_CDS            nchar(7)

  -- wProvidedCDS       bit  -- TODO: create, populate this col
                             --       for statistical subtotals and echoing-out

)

declare @existingCDS2orig nchar(2)
declare @existingCDS5orig nchar(5)
    -- TODO: I should have named these local vars without orig

set @today             = getdate()
set @manageResultsJSON = '{"importStatistics":[],"importExceptions":[]}'
set @tranOpen          = 0

BEGIN TRY

SELECT top 1
     @existingCDS2orig = SUBSTRING(isnull(clc.CLIENT_CDS,N''), 1, 2)
   , @existingCDS5orig = SUBSTRING(isnull(clc.CLIENT_CDS,N''), 3, 5)
FROM dbo.CLIENTS_Client as clc
WHERE (clc.CLIENT_ID = @clientID)

/*############################################################################
 *# Load patient data import record
 *############################################################################*/

select top 1
    @structuredDataImportID     = pdi.structuredDataImportID
  , @fileSubClass               = pdi.fileSubClass
  , @importFromFileReferenceID  = pdi.importFromFileReferenceID
from dbo.Patient_Data_Imports as pdi
where (
      (pdi.id = @patientDataImportID)
  and (pdi.clientID = @clientID)
)

if (@structuredDataImportID is null)
begin
  return
end

/*############################################################################
 *# Load site data from total pop file data
 *############################################################################*/

if (@fileSubClass = dbo.CONST_PATIENT_DATA_FILE_SUB_CLASS_TOTAL_POP())
begin

  insert into @incomingSiteData (
      siteName
    , school_CDS_7
    , importRowIDsJSONArr
  )

  select

    siteName     = left(t2.School_Site_Name_orig,50)
	, school_CDS_7 = t2.School_Site_CDS7_orig
  , importRowIDsJSONArr = '[ ' + STRING_AGG( CONVERT( varchar(max), CAST( t2.ID as varchar ) ), ', ' ) + ' ]'

  from dbo.Import_From_A_From_Client_ToSPED_Files as t1
  join dbo.Import_From_A_From_Client_ToSPED_File_rows as t2 on t2.FROM_CLIENT_log_entry = t1.id
  where
    (t1.id = @importFromFileReferenceID)

  -- GROUP BY t2.School_Site_CDS7, t2.School_Site_Name

  GROUP BY t2.School_Site_CDS7_orig, t2.School_Site_Name_orig


end

/*############################################################################
 *# Load site data from special ed file data
 *############################################################################*/

else if (@fileSubClass = dbo.CONST_PATIENT_DATA_FILE_SUB_CLASS_SPEC_ED_SVCS())
begin

  insert into @incomingSiteData (
      siteName
    , school_CDS_7
    , importRowIDsJSONArr
  )
  select

    siteName     = left  (t2.School_of_Attendance_orig ,50)
	, school_CDS_7 = right (t2.School_CDS_Code_orig,7)
  , importRowIDsJSONArr = '[ ' + STRING_AGG( CONVERT( varchar(max), CAST( t2.ID as varchar ) ), ', ' ) + ' ]'

  from dbo.[Import_From_A.5_SERVICES_From_Client_Files]     as t1
  join dbo.[Import_From_A.5_SERVICES_From_Client_File_Rows] as t2 on t2.File_import_log_entry = t1.id
  where
    (t1.id = @importFromFileReferenceID)

  -- GROUP BY  t2.[School CDS Code orig], t2.[School of Attendance]

  GROUP BY t2.School_CDS_Code_orig, t2.School_of_Attendance_orig 



end

/*############################################################################
 *# Update initial stats... rest of updates will be near end
 *############################################################################*/

/*-------------------------------
 * Count of incoming total
 *------------------------------*/

select @statCount = count(idx) from @incomingSiteData
insert into @importStatistics (label, [name], [value], [returnStatus], [forPCALStaffOnly])
values ('Total Number of Incoming Sites','numSitesInTotal',convert(varchar(50),@statCount),1,1)

/*############################################################################
 *# Clean up
 *############################################################################*/

update @incomingSiteData
set
    siteName      = trim(isnull(siteName,N''))
  , school_CDS_7  = trim(isnull(school_CDS_7,N''))

/*###########################################################################
 *# Identify and remove any incoming sites that cant be used because of
 *# empty names AND empty cds codes
 *############################################################################*/

 -- debug
 -- SELECT * FROM @incomingSiteData

/*-------------------------------
 * Identify
 *------------------------------*/

insert into @unknownSitesNoNameOrCode (
    incomingSiteDataIdx
  , siteName
  , school_CDS_7
)
select
  t1.idx
, t1.siteName
, t1.school_CDS_7
from @incomingSiteData as t1


where (
         (t1.siteName = ''     OR t1.siteName LIKE 'Unknown%' )

         and

         (t1.school_CDS_7 = '' OR t1.school_CDS_7 = '0000000' OR CAST(t1.school_CDS_7 as numeric) = 0 )
      )

      and (t1.existingSiteID is null)


/*-------------------------------
 * Instead of removing from processing,
 * create or use x7 code for unknown site
 * and continue processing like normal...
 *------------------------------*/

declare @clientUnkSiteID bigint
declare @clientUnkX7CDS nchar(7)

exec
  dbo.CREATE_OR_GET_SITE_INFO_UNKNOWN_SCHOOL_CORE
    @clientID,
    @clientUnkSiteID output,
    @clientUnkX7CDS output


UPDATE isd

  SET
    existingSiteCds = @clientUnkX7CDS ,
    existingSiteID = @clientUnkSiteID ,
    existingSiteName = dbo.CONST_UNKNOWN_SCHOOL_NAME()

  FROM @incomingSiteData as isd
  JOIN @unknownSitesNoNameOrCode unk
    on isd.idx = unk.idx

/*############################################################################
 *# Locate existing sites
 *############################################################################*/

/*-------------------------------
 * First by cds code
 *------------------------------*/

;with ss_data as (

  select
     SITE_ID
   , ss.SITE_CDS
   , ss.ACTIVE

   --, MAX( CAST( attemptFuzzyMatchByNameAndCode as int ) ) attemptFuzzyMatchByNameAndCode



   , fuzzyMatchSitesByNameAndCode attemptFuzzyMatchByNameAndCode
   -- , attemptFuzzyMatchByNameAndCode

   -- a early botched attempt to treat all SITES of the same CDS code as fuzzy-matched, if one of them is marked fuzzy matched.
   -- Not ultimately necessary because we are flagging fuzzy matching for all Sites of a given client, not site by site, and not code by code.

   , ss.SITE_NAME

  FROM    dbo.SITES_Site        ss

  JOIN    dbo.CLIENTS_Client    cc
    ON   cc.CLIENT_ID = ss.SITE_CLIENT_ID

  WHERE  (ss.SITE_CLIENT_ID = @clientID)

  -- GROUP BY  SITE_CDS

  --           , SITE_NAME -- this here is the reason why the GROUP BY Site_CDS didn't do what I originally intended;
                           -- they have different site_names, so same Site_CDSs aren't being grouped together
                           -- and MAX( attemptFuzzyMatchByNameAndCode ) can't be found

  --          , ACTIVE    -- grouping by ACTIVE, out of blind habit apparently

                          -- admittedly I didn't implement fail-over code to use inactive sites if no active site is found,
                          -- like we have done in the 13 trillion step heuristic we use elsewhere.

                          -- For the fuzzy-matched client(s) we're assuming we'll never run into that particular edge case.
                          -- It isn't hard to look at the data in SITES_Sites table
                          -- and see that a particular client doesn't have any corresponding pairs of inactive site row and an active site row with the same SITE_CDS.

)

   -- the ss_data CTE above, with lines commented, is exactly the same as querying the SITES_Site table directly.
   -- As it happens the GROUP BY and MIN and MAX functions weren't doing anything; with aggregation, the query fetches 31 rows for cli 278,
   -- and without aggregation, the query still fetches exactly 31 rows for cli 278.

update t1
  set
     t1.existingSiteID     = ss.SITE_ID
   , t1.existingSiteCDS    = ss.SITE_CDS
   , t1.existingSiteName   = trim(ss.SITE_NAME)
   , t1.existingSiteActive = ss.ACTIVE

   , t1.attemptFuzzyMatchByNameAndCode = ss.attemptFuzzyMatchByNameAndCode

from @incomingSiteData as t1
join ss_data as ss on (ss.SITE_CDS = t1.school_CDS_7)

where (t1.existingSiteID is null)

/*-------------------------------
 * Then by site name
 *------------------------------*/

update t1
 set
     t1.existingSiteID     = ss.SITE_ID
   , t1.existingSiteCDS    = ss.SITE_CDS
   , t1.existingSiteName   = REPLACE( 
                               trim(ss.SITE_NAME) ,
                               '''', '`'
                             )
   , t1.existingSiteActive = ss.ACTIVE
from @incomingSiteData as t1
join dbo.SITES_Site    as ss on  (ss.SITE_CLIENT_ID = @clientID)
                             and (ss.SITE_NAME = t1.siteName)

where (
        t1.existingSiteID is null
        AND
        t1.attemptFuzzyMatchByNameAndCode = 0
      )

declare @fuzzy_isd_iter_i     bigint = 1
declare @fuzzy_isd_iter_max   bigint

select @fuzzy_isd_iter_max = MAX(idx) FROM @incomingSiteData

declare @fuzzy_iter_isd_siteName       nvarchar(100)
declare @fuzzy_iter_isd_cds7           nchar(7)
declare @fuzzy_selected_siteID_retval  bigint

 -- debug
 -- SELECT * FROM @incomingSiteData

declare @possibleSiteIdsCSV varchar(max)

SELECT
@possibleSiteIdsCSV = STRING_AGG(convert(varchar(max),ss.SITE_ID),',') /* Note: the convert(varchar(max) is needed to make sure STRING_AGG does not trucate the results. */
FROM dbo.SITES_Site as ss
WHERE
(ss.SITE_CLIENT_ID = @clientID)

while (@fuzzy_isd_iter_i <= @fuzzy_isd_iter_max)
BEGIN

  SELECT
    @fuzzy_iter_isd_siteName  = null,
    @fuzzy_iter_isd_cds7      = null

  SELECT
    @fuzzy_iter_isd_siteName = siteName      ,
    @fuzzy_iter_isd_cds7     = school_CDS_7
  FROM @incomingSiteData
  WHERE (idx = @fuzzy_isd_iter_i  AND  attemptFuzzyMatchByNameAndCode = 1 )

  IF ( @fuzzy_iter_isd_cds7 IS NOT NULL )
    SELECT @fuzzy_selected_siteID_retval = [dbo].[SITE_ATTEMPT_MATCHES_BY_NAME_AND_CODE] (
        @clientID                 ,
        @possibleSiteIdsCSV       ,
        @fuzzy_iter_isd_siteName  ,
        @fuzzy_iter_isd_cds7
    )
  IF ( @fuzzy_selected_siteID_retval IS NOT NULL )
  BEGIN

    ; with selected_siterec as (
        select
          ACTIVE    ,
          SITE_CDS  ,
          trim(SITE_NAME)  SITE_NAME
        FROM SITES_Site
        WHERE SITE_ID = @fuzzy_selected_siteID_retval
    )
    UPDATE  t1
       set
                         existingSiteID   = @fuzzy_selected_siteID_retval ,
                     existingSiteActive   = selected_siterec.ACTIVE       ,

                       existingSiteCDS    = selected_siterec.SITE_CDS     ,
                       existingSiteName   = selected_siterec.SITE_NAME    ,

         attemptFuzzyMatchByNameAndCode   = 0
    FROM  @incomingSiteData t1
    JOIN  selected_siterec ON 1=1 -- 1 row; no join condition

    WHERE     t1.school_CDS_7    = @fuzzy_iter_isd_cds7
       AND   REPLACE(  
               REPLACE(  t1.siteName ,
                       '''', ''
               ) ,
               '`', ''
             )
                 =  REPLACE(  
                      REPLACE(  @fuzzy_iter_isd_siteName ,
                       '''', ''
                       ) ,
                     '`', ''
                    )

  END

  SET @fuzzy_isd_iter_i += 1
END

/*############################################################################
 *# Determine what sites need to be reactivated
 *############################################################################*/

insert into @existingSitesToReactivate (
    incomingSiteDataIdx
  , existingSiteID
)
select
    incomingSiteDataIdx = t1.idx
  , t1.existingSiteID
from @incomingSiteData as t1
where (
      (t1.existingSiteActive = 0)
  and (t1.existingSiteID is not null)
)

/*############################################################################
 *# Determine what sites need to be renamed
 *############################################################################*/

insert into @existingSitesToRename (
    incomingSiteDataIdx
  , existingSiteID
)
select
    incomingSiteDataIdx = t1.idx
  , t1.existingSiteID
from @incomingSiteData as t1
where (
      (t1.existingSiteID is not null)
  and (t1.siteName != t1.existingSiteName)
)

/*############################################################################
 *# Handle NPS
 *############################################################################*/


declare @clientNPSsiteID bigint
declare @clientNPSx7CDS nchar(7)

exec
  dbo.CREATE_OR_GET_SITE_INFO_NON_PUBLIC_SCHOOL_CORE
    @clientID,
    @clientNPSsiteID output,
    @clientNPSx7CDS output


UPDATE isd

  SET
    existingSiteCDS = @clientNPSx7CDS ,
    existingSiteID = @clientNPSsiteID ,
    existingSiteName = dbo.CONST_NON_PUBLIC_SCHOOL_NAME()

  FROM @incomingSiteData as isd
  WHERE

    isd.existingSiteID IS NULL

    -- NOTE: in this case we are handling NPS with NO cds7 provided
    -- in the previous release we were mistakenly requiring a CDS7 with the non-public school entries
    AND (
    isd.school_CDS_7 = '' OR isd.school_CDS_7 = '0000000' OR CAST(isd.school_CDS_7 as numeric) != 0
    )

    AND (
      isd.siteName = 'NPS' OR isd.siteName like 'Non[- ]public%' OR isd.siteName like 'Nonpublic%'
    )

/*############################################################################
 *# Determine what sites need to be added
 *############################################################################*/

insert into @newSitesToAddWCdsProvided (
   incomingSiteDataIdx
)
select
    incomingSiteDataIdx = t1.idx
from @incomingSiteData as t1
where

  (t1.existingSiteID is null)

  AND (
    t1.school_CDS_7 != '' AND t1.school_CDS_7 != '0000000' AND CAST(t1.school_CDS_7 as numeric) != 0
  )

/*############################################################################
 *# Update stats
 *############################################################################*/

/*-------------------------------
 * Count of not usable
 *------------------------------*/

set @statCount = 0
select @statCount = count(idx) from @unknownSitesNoNameOrCode
insert into @importStatistics (label, [name], [value], [returnStatus], [forPCALStaffOnly])
values ('Number of Incoming Sites That Are NOT Usable','numSitesInNotUsable',convert(varchar(50),@statCount),1,1)
-- TODO: consider re-wording the verbiage here....

/*-------------------------------
 * Count of usable
 *------------------------------*/

set @statCount = 0
select @statCount = count(idx) from @incomingSiteData
insert into @importStatistics (label, [name], [value], [returnStatus], [forPCALStaffOnly])
values ('Number of Incoming Sites That ARE Usable','numSitesInUsable',convert(varchar(50),@statCount),1,1)

/*-------------------------------
 * Count of incoming found
 *------------------------------*/

set @statCount = 0
select @statCount = count(idx) from @incomingSiteData
insert into @importStatistics (label, [name], [value], [returnStatus], [forPCALStaffOnly])
values ('Sites Found in SpEdCare','numSitesInFound',convert(varchar(50),@statCount),1,1)

/*-------------------------------
 * Count of sites to reactivate
 *------------------------------*/

set @statCount = 0
select @statCount = count(idx) from @existingSitesToReactivate
insert into @importStatistics (label, [name], [value], [returnStatus], [forPCALStaffOnly])
values ('Sites Found in SpEdCare That Were Reactivated','numSitesInFoundInactive',convert(varchar(50),@statCount),1,1)

/*-------------------------------
 * Count of sites to rename
 *------------------------------*/

set @statCount = 0
select @statCount = count(idx) from @existingSitesToRename
insert into @importStatistics (label, [name], [value], [returnStatus], [forPCALStaffOnly])
values ('Sites Found in SpEdCare That May Need to Be Renamed','numSitesInFoundToRename',convert(varchar(50),@statCount),1,1)

/*-------------------------------
 * Count of sites to add
 *------------------------------*/

set @statCount = 0
select @statCount = count(idx) from @newSitesToAddWCdsProvided
insert into @importStatistics (label, [name], [value], [returnStatus], [forPCALStaffOnly])
values ('Sites Not Found in SpEdCare That Were Added','numSitesInNotFoundToAdd',convert(varchar(50),@statCount),1,1)

-- TODO: not sure is this verbiage needs to be changed

/*############################################################################
 *# Exit if in test mode
 *############################################################################*/

if (@testMode = 1) return(0)

/*############################################################################
 *# Otherwise update and/or add data
 *############################################################################*/

begin transaction
set @tranOpen = 1

/*############################################################################
 *# Reactivate inactive sites
 *############################################################################*/

/*-------------------------------
 * Update site table
 *------------------------------*/

update ss
set    ss.ACTIVE           = 1
     , ss.DATE_MODIFIED    = @today
     , ss.LAST_MODIFIED_BY = @userID
from @existingSitesToReactivate as t1
join dbo.SITES_Site             as ss on ss.SITE_ID = t1.existingSiteID

  -- TODO: this entire sproc lacks an UPDATE statement that is capable of automatically renaming a row in SITES_Site

/*-------------------------------
 * Add to audit log
 *------------------------------*/

insert into dbo.SITES_Audit_Log (
    recID
  , loggedOn
  , userID
  , saveType
  , state
  , reason
)
select
    recID    = t1.existingSiteID
  , loggedOn = @today
  , userID   = @userID
  , saveType = 2
  , [state]  = 10
  , [reason] = 'Updated via automation. Reactivated because we received student data that indicated this site was in use.'
from @existingSitesToReactivate as t1

/*############################################################################
 *# Add new sites
 *############################################################################*/

/*-------------------------------
 * Handle rows w/ CDS provided
 * - Add to the site table
 *------------------------------*/

insert into dbo.SITES_Site (
    SITE_CLIENT_ID
  , SITE_CDS
  , SITE_NAME
  , LOWERED_SITE_NAME
  , DATE_CREATED
  , CREATED_BY
  , ACTIVE
)

output inserted.SITE_ID ,inserted.SITE_NAME ,inserted.SITE_CDS into @newSitesAdded

select
    SITE_CLIENT_ID    = @clientID
  , SITE_CDS          = t2.school_CDS_7
  , SITE_NAME         = REPLACE(
                          t2.siteName  ,
                          '''', '`'
                        )
                           -- NOTE: INSERT only.
                           -- TODO: this entire sproc lacks an UPDATE statement that is capable of automatically renaming a row in SITES_Site

  , LOWERED_SITE_NAME = REPLACE(
                          trim(lower(t2.siteName)) ,
                          '''', '`'
                        )

  , DATE_CREATED      = @today
  , CREATED_BY        = @userID
  , ACTIVE            = 1
from @newSitesToAddWCdsProvided    as t1
join @incomingSiteData as t2 on t2.idx = t1.incomingSiteDataIdx

/*-------------------------------
 * Handle rows requiring new x7 CDS code
 * and add to the site table
 *------------------------------*/


declare @iterNewSitesToAddUnknownCDS_max int
declare @iterNewSitesToAddUnknownCDS_idx int = 1

INSERT INTO @iterNewSitesToAddUnknownCDS ( siteName )
SELECT
  isd.siteName
from @incomingSiteData isd
WHERE
  (
    isd.school_CDS_7 = '' OR isd.school_CDS_7 = '0000000' OR CAST(isd.school_CDS_7 as numeric) = 0
  )
  AND
  isd.existingSiteID IS NULL

SELECT @iterNewSitesToAddUnknownCDS_max = MAX(idx) FROM @iterNewSitesToAddUnknownCDS

declare @x7_siteCDS_i   nchar(7)
declare @isd_siteName_wX7_i  nvarchar(50)
declare @insertedSiteID bigint

while ( @iterNewSitesToAddUnknownCDS_idx <= @iterNewSitesToAddUnknownCDS_max )
begin

  SELECT @x7_siteCDS_i=NEXT_CDS_NUMBER
  FROM [dbo].[GENERATE_NEXT_CDS_7_X_CODE]
  -- regrettably this 1-row 1-col view needs to be called iteratively;
  -- it doesn't support bulk imports, apparently.
  -- if I wasn't using a loop then all the new, incoming school names would get assigned
  -- the same x7 code

  SELECT @isd_siteName_wX7_i = siteName FROM @iterNewSitesToAddUnknownCDS
  WHERE idx = @iterNewSitesToAddUnknownCDS_idx

  insert into dbo.SITES_Site (
      SITE_CLIENT_ID
    , SITE_CDS
    , SITE_NAME
    , LOWERED_SITE_NAME
    , DATE_CREATED
    , CREATED_BY
    , ACTIVE
  )

  output inserted.SITE_ID ,inserted.SITE_NAME ,inserted.SITE_CDS into @newSitesAdded

  select
      SITE_CLIENT_ID    = @clientID
    , SITE_CDS          = @x7_siteCDS_i
    , SITE_NAME         = @isd_siteName_wX7_i
    , LOWERED_SITE_NAME = trim(lower( @isd_siteName_wX7_i ))
    , DATE_CREATED      = @today
    , CREATED_BY        = @userID
    , ACTIVE            = 1

  SET @insertedSiteID = SCOPE_IDENTITY()

  UPDATE isd
    SET
        isd.existingSiteID    = @insertedSiteID
      , isd.existingSiteCDS   = @x7_siteCDS_i
      , isd.existingSiteName  = @isd_siteName_wX7_i
  FROM @incomingSiteData isd
  WHERE siteName = @isd_siteName_wX7_i

  SET @iterNewSitesToAddUnknownCDS_idx = @iterNewSitesToAddUnknownCDS_idx + 1

end

/*-------------------------------
 * Add to audit log
 *------------------------------*/

insert into dbo.SITES_Audit_Log (
    recID
  , loggedOn
  , userID
  , saveType
  , state

  --  , wProvidedCDS

  , reason
)
select
    recID    = t1.SITE_ID
  , loggedOn = @today
  , userID   = @userID
  , saveType = 1
  , [state]  = 1

  -- , ...

  , [reason] = 'Added via automation.  We received student data that included this site we did not have on file'

  -- TODO: make sure that the audit recording logic is up-to-date with the latest changes...

from @newSitesAdded as t1


if (@fileSubClass = dbo.CONST_PATIENT_DATA_FILE_SUB_CLASS_TOTAL_POP())
begin

  ;with isd_x_ir_ids as (
    SELECT
      --isd.existingSiteID  ,
      isd.existingSiteCDS   ,
      isd.existingSiteName  ,
      unravelled.ir_id
    FROM @incomingSiteData isd
    CROSS APPLY (
      SELECT value ir_id FROM
      OPENJSON( isd.importRowIDsJSONArr, '$' )
    ) unravelled
  )

  -- no idea.

  UPDATE i_r
  SET
    i_r.County_CDS2_orig = i_r.County_CDS2 ,
    i_r.District_CDS5_orig = i_r.District_CDS5
  FROM dbo.Import_From_A_From_Client_ToSPED_File_rows i_r
  JOIN isd_x_ir_ids ON isd_x_ir_ids.ir_id = i_r.id

  ;with isd_x_ir_ids as (
    SELECT
      --isd.existingSiteID  ,
      isd.existingSiteCDS   ,
      isd.existingSiteName  ,
      unravelled.ir_id
    FROM @incomingSiteData isd
    CROSS APPLY (
      SELECT value ir_id FROM
      OPENJSON( isd.importRowIDsJSONArr, '$' )
    ) unravelled
  )

  -- ????
  UPDATE i_r
  SET
    i_r.County_CDS2 = @existingCDS2orig,
    i_r.District_CDS5 = @existingCDS5orig
  FROM dbo.Import_From_A_From_Client_ToSPED_File_rows i_r
  JOIN isd_x_ir_ids ON isd_x_ir_ids.ir_id = i_r.id

  ;with isd_x_ir_ids as (
    SELECT
      --isd.existingSiteID  ,
      isd.existingSiteCDS   ,
      isd.existingSiteName  ,
      unravelled.ir_id
    FROM @incomingSiteData isd
    CROSS APPLY (
      SELECT value ir_id FROM
      OPENJSON( isd.importRowIDsJSONArr, '$' )
    ) unravelled
  )

  UPDATE i_r
  SET
    i_r.School_Site_Name = isd_x_ir_ids.existingSiteName,
    i_r.School_Site_CDS7     = isd_x_ir_ids.existingSiteCDS
  FROM dbo.Import_From_A_From_Client_ToSPED_File_rows i_r
  JOIN isd_x_ir_ids ON isd_x_ir_ids.ir_id = i_r.id

end

/*############################################################################
 *# Load site data from special ed file data
 *############################################################################*/

else if (@fileSubClass = dbo.CONST_PATIENT_DATA_FILE_SUB_CLASS_SPEC_ED_SVCS())
begin

  ;with isd_x_ir_ids as (
    SELECT
      --isd.existingSiteID  ,
      isd.existingSiteCDS   ,
      isd.existingSiteName  ,
      unravelled.ir_id
    FROM @incomingSiteData isd
    CROSS APPLY (
      SELECT value ir_id FROM
      OPENJSON( isd.importRowIDsJSONArr, '$' )
    ) unravelled
  )

  UPDATE i_r
  SET
    i_r.[School of Attendance] = isd_x_ir_ids.existingSiteName,
    i_r.[School CDS Code]      = isd_x_ir_ids.existingSiteCDS
  FROM dbo.[Import_From_A.5_SERVICES_From_Client_File_Rows] i_r
  JOIN isd_x_ir_ids ON isd_x_ir_ids.ir_id = i_r.id

end


if @tranOpen = 1 commit transaction
--if @tranOpen = 1 rollback transaction

set @tranOpen = 0

/*############################################################################
 *# Update exceptions for reporting
 *############################################################################*/

insert into @importExceptions (
    label
  , [name]
  , [value]
  , [returnStatus]
  , [forPCALStaffOnly]
)

select
   label              = 'Could not use this incoming site data'
 , [name]             = '[CDS7]: ' + t1.school_CDS_7 + ' [Name]: ' + t1.siteName
 , [value]            = convert(varchar(50),t1.incomingSiteDataIdx)
 , [returnStatus]     = 2
 , [forPCALStaffOnly] = 1
from @unknownSitesNoNameOrCode as t1

union all

select
   label              = 'Had to reactivate this site'
 , [name]             = convert(varchar(50),t2.existingSiteID)
 , [value]            = '[CDS7]: ' + t2.school_CDS_7 + ' [Name]: ' + t2.existingSiteName
 , [returnStatus]     = 1
 , [forPCALStaffOnly] = 1
from @existingSitesToReactivate as t1
join @incomingSiteData          as t2 on t2.idx = t1.incomingSiteDataIdx

union all

select
   label              = 'Our site name and the clients site name are different'
 , [name]             = convert(varchar(50),t2.existingSiteID)
 , [value]            = '[CDS7]: ' + t2.school_CDS_7 + ' [Our Name]: ' + t2.existingSiteName + ' [Their Name]: ' + t2.siteName
 , [returnStatus]     = 2
 , [forPCALStaffOnly] = 1
from @existingSitesToRename     as t1
join @incomingSiteData          as t2 on t2.idx = t1.incomingSiteDataIdx

union all

select
   label              = 'Added this site'
 , [name]             = convert(varchar(50),t1.SITE_ID)
 , [value]            = '[CDS7]: ' + t1.SITE_CDS + ' [Name]: ' + t1.SITE_NAME
 , [returnStatus]     = 1
 , [forPCALStaffOnly] = 1
from @newSitesAdded     as t1

declare @importStatisticsJSON as varchar(max) = CONVERT(VARCHAR(MAX),( select * from @importStatistics FOR JSON AUTO))
declare @importExceptionsJSON as varchar(max) = CONVERT(VARCHAR(MAX),( select * from @importExceptions FOR JSON AUTO))
set @manageResultsJSON = '{"importStatistics":' + @importStatisticsJSON
                       + ',"importExceptions":' + @importExceptionsJSON
					   + '}'


/*############################################################################
 *# Done
 *############################################################################*/

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

  if (@tranOpen = 1)
  begin
    ROLLBACK TRANSACTION
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
  set @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ']'

  if ((@clientID is not null) and (@patientDataImportID is not null) and (@userId is not null))
  begin
  set @today = getdate()

    update dbo.Patient_Data_Imports
    set
        fileProcessingError              = 1
      , errorMessages                    = @ErrorMessage
      , lastModified                     = @today
      , lastModifiedBy                   = @userID
    where ((id = @patientDataImportID) and (clientID = @clientID))
  end

  -- Reraise the error so it returns back to the server

  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)

END CATCH
END
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[Patient_Data_Imports_Manage_Sites] TO [webuser]
