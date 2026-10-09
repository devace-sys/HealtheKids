USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.FILE_UPLOAD_GENERATE_FILE_AS_NAME') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.FILE_UPLOAD_GENERATE_FILE_AS_NAME
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[FILE_UPLOAD_GENERATE_FILE_AS_NAME] (
    @userID         BIGINT  
  , @userGroup      INT 
  , @userRank       INT
  , @uploadID       BIGINT
)
RETURNS 
@recs table (
   uploadID bigint
 , fileAsName nvarchar(max)
UNIQUE CLUSTERED (uploadID)
) 
AS
BEGIN

/***************************************************************************
 * FILE_UPLOAD_GENERATE_FILE_AS_NAME */
/**
 * Returns name we should file uploaded file under 
 *
 * @return Table
 ***************************************************************************/ 

declare @fileNameParts as table (
   UPLOAD_ID         varchar(50)
 , UPLOAD_DATE       varchar(50)
 , CLIENT_SHORT_NAME varchar(100)
 , CLIENT_CDS        nvarchar(50)
 , FILE_CLASS        varchar(1000)
 , FILE_SUB_CLASS    varchar(1000)
 , PAT_NAME          nvarchar(202)
 , PRAC_NAME         nvarchar(202)
 , REF_DATE_1        varchar(30)
 , REF_DATE_2        varchar(30)
 , REF_TITLE_1       varchar(2000)
 , REF_TITLE_2       varchar(2000)
 , CLIENT_ID         varchar(256)
 , PRAC_ID           varchar(256)
 , PAT_ID            varchar(256)
 , GROUP_ID_DISP     varchar(256)
 , GROUP_ID_REPT     varchar(256)
 , GROUP_DISP_NAME   nvarchar(max)
 , GROUP_DISP_ABBREVATION nvarchar(max)
 , GROUP_DISP_BASE_NAME   nvarchar(max)
 , GROUP_REPT_NAME        nvarchar(max)
 , FILE_EXTENSION         varchar(8000)
 , fileClass              bigint
 , id                     bigint
)    

declare @filePartsArr as table (
  partID    bigint
, fileClass bigint
, partValue varchar(512)
UNIQUE CLUSTERED (partID)
)

;with

/*###########################################################################
  # Retrieve upload record and convert key fields to varchar.
  # These are our basic file name parts
  ###########################################################################*/    

cte_file_name_parts_p1
as
(
  select top 1    
     convert (varchar(50),fu.id)                           as UPLOAD_ID
   , convert ( varchar(50)
              ,fued.effectiveUploadedOnDateTime,112)       as UPLOAD_DATE
   , isnull (cc.ShortName,'')                              as CLIENT_SHORT_NAME
   , isnull (cc.CLIENT_CDS,N'')                            as CLIENT_CDS
   , isnull (fc.name,'')                                   as FILE_CLASS
   , isnull (fu.fileSubClass,'')                           as FILE_SUB_CLASS
   , isnull (pap.LAST_NAME,N'')                            as PAT_LAST
   , isnull (pap.FIRST_NAME,N'')                           as PAT_FIRST
   , isnull (prp.LAST_NAME,N'')                            as PRAC_LAST
   , isnull (prp.FIRST_NAME,N'')                           as PRAC_FIRST
   , isnull (fu.ReferenceDate1, '')                        as REF_DATE_1
   , isnull (fu.ReferenceDate2, '')                        as REF_DATE_2
   , isnull (fu.ReferenceTitle1,'')                        as REF_TITLE_1
   , isnull (fu.ReferenceTitle2,'')                        as REF_TITLE_2
   , isnull (convert(varchar(256),fu.clientID) ,'')        as CLIENT_ID
   , isnull (convert(varchar(256),fu.pracID)   ,'')        as PRAC_ID
   , isnull (convert(varchar(256),fu.patID)    ,'')        as PAT_ID
   , isnull (convert(varchar(256),fu.groupIDDisp) ,'')     as GROUP_ID_DISP
   , isnull (convert(varchar(256),fu.groupIDRept) ,'')     as GROUP_ID_REPT
   , isnull (ggd.GROUP_NAME,N'')                           as GROUP_DISP_NAME
   , isnull (ggd.GROUP_NAME_ABBREVIATION,N'')              as GROUP_DISP_ABBREVATION
   , isnull (ggd.GROUP_BASE,N'')                           as GROUP_DISP_BASE_NAME
   , isnull (ggr.GROUP_NAME,N'')                           as GROUP_REPT_NAME
   , fu.fileClass
   , fu.savedName
   , fu.id

from dbo.FILE_UPLOADS                   as fu
join dbo.FILE_CLASSES                   as fc  on fc.id               = fu.fileClass

left join dbo.CLIENTS_Client            as cc  on cc.CLIENT_ID        = fu.clientID
left join dbo.PATIENTS_Patient          as pap on pap.PATIENT_ID      = fu.patID
left join dbo.PRACTITIONER_Practitioner as prp on prp.PRACTITIONER_ID = fu.pracID
left join dbo.GROUP_Group               as ggd on ggd.GROUP_ID        = fu.groupIDDisp
left join dbo.GROUP_Group               as ggr on ggr.GROUP_ID        = fu.groupIDRept

/* Detemine effective upload date */

cross apply (
  select top 1 effectiveUploadedOnDateTime 
  from dbo.FILE_UPLOAD_GENERATE_EFFECTIVE_UPLOAD_DATE(@userID, @userGroup, @userRank, fu.id)
) as fued

where 
  (fu.id = @uploadID)
)
,

/*###########################################################################
  # Create composite and derived file name parts
  ###########################################################################*/    

cte_file_name_parts_p2
as
(
select top 1
    p1.*
  , PAT_NAME       = trim(PAT_LAST)  + N'_' + trim(PAT_FIRST)
  , PRAC_NAME      = trim(PRAC_LAST) + N'_' + trim(PRAC_FIRST)
  , FILE_EXTENSION = case when savedName like'%.%' then reverse(left(reverse(savedName),charindex('.',reverse(savedName),0)-1)) else '' end
from cte_file_name_parts_p1 as p1
)
,

/*###########################################################################
  # Clean up and format key fields
  ###########################################################################*/    
  
cte_file_name_parts_p3
as
(
select top 1
    UPLOAD_ID
  , UPLOAD_DATE
  , CLIENT_SHORT_NAME
  , CLIENT_CDS
  , FILE_CLASS     
  , FILE_SUB_CLASS
  , PAT_NAME   = case (PAT_NAME)   when N'_' then N'' else PAT_NAME end
  , PRAC_NAME  = case (PRAC_NAME)  when N'_' then N'' else PRAC_NAME end
  , REF_DATE_1 = case (REF_DATE_1) when ''   then '' else convert(varchar,(convert(date,REF_DATE_1)),112) end
  , REF_DATE_2 = case (REF_DATE_2) when ''   then '' else convert(varchar,(convert(date,REF_DATE_2)),112) end
  , REF_TITLE_1
  , REF_TITLE_2
  , CLIENT_ID
  , PRAC_ID
  , PAT_ID
  , GROUP_ID_DISP
  , GROUP_ID_REPT
  , GROUP_DISP_NAME
  , GROUP_DISP_ABBREVATION
  , GROUP_DISP_BASE_NAME
  , GROUP_REPT_NAME
  , FILE_EXTENSION
  , fileClass
  , id
from cte_file_name_parts_p2 as p2
)
insert into @fileNameParts
select top 1 * from cte_file_name_parts_p3


insert into @filePartsArr
          select top 1 1  as [partID], fileClass, UPLOAD_ID               as [partValue] from @fileNameParts
union all select top 1 2  as [partID], fileClass, UPLOAD_DATE             as [partValue] from @fileNameParts
union all select top 1 3  as [partID], fileClass, CLIENT_SHORT_NAME       as [partValue] from @fileNameParts
union all select top 1 4  as [partID], fileClass, CLIENT_CDS              as [partValue] from @fileNameParts
union all select top 1 5  as [partID], fileClass, FILE_CLASS              as [partValue] from @fileNameParts
union all select top 1 6  as [partID], fileClass, FILE_SUB_CLASS          as [partValue] from @fileNameParts
union all select top 1 7  as [partID], fileClass, PAT_NAME                as [partValue] from @fileNameParts
union all select top 1 8  as [partID], fileClass, PRAC_NAME               as [partValue] from @fileNameParts
union all select top 1 9  as [partID], fileClass, REF_DATE_1              as [partValue] from @fileNameParts
union all select top 1 10 as [partID], fileClass, REF_DATE_2              as [partValue] from @fileNameParts
union all select top 1 11 as [partID], fileClass, REF_TITLE_1             as [partValue] from @fileNameParts
union all select top 1 12 as [partID], fileClass, REF_TITLE_2             as [partValue] from @fileNameParts
union all select top 1 13 as [partID], fileClass, CLIENT_ID               as [partValue] from @fileNameParts
union all select top 1 14 as [partID], fileClass, PRAC_ID                 as [partValue] from @fileNameParts
union all select top 1 15 as [partID], fileClass, PAT_ID                  as [partValue] from @fileNameParts
union all select top 1 16 as [partID], fileClass, GROUP_ID_DISP           as [partValue] from @fileNameParts
union all select top 1 17 as [partID], fileClass, GROUP_ID_REPT           as [partValue] from @fileNameParts
union all select top 1 18 as [partID], fileClass, GROUP_DISP_NAME         as [partValue] from @fileNameParts
union all select top 1 19 as [partID], fileClass, GROUP_DISP_ABBREVATION  as [partValue] from @fileNameParts
union all select top 1 20 as [partID], fileClass, GROUP_DISP_BASE_NAME    as [partValue] from @fileNameParts
union all select top 1 21 as [partID], fileClass, GROUP_REPT_NAME         as [partValue] from @fileNameParts
union all select top 1 9999 as [partID], fileClass, FILE_EXTENSION        as [partValue] from @fileNameParts


/*###########################################################################
  # Keep in synch with file_upload_name_part
  ###########################################################################*/    
;with
cte_pass_4
as
(
select * from @filePartsArr
)
,
/*###########################################################################
  # Filter out parts not relevant to file class and order by partOrder
  # File name only
  ###########################################################################*/    

cte_pass_5_filename
as
(
select 
    fups.partOrder
  , fup.partName
  , p4.partValue 
from cte_pass_4             as p4
join FILE_UPLOAD_NAME_PART  as fup  on  fup.id = p4.partID
join FILE_UPLOAD_NAME_PARTS as fups on  fups.fileClassID = p4.fileClass 
                                    and fups.partID      = fup.id
where p4.partID != 9999
group by 
    partOrder
  , partName
  , partValue
)
,

/*###########################################################################
  # Filter out parts not relevant to file class and order by partOrder
  # Extension only
  ###########################################################################*/    

cte_pass_5_fileext
as
(
select 
    fups.partOrder
  , fup.partName
  , p4.partValue 
from cte_pass_4             as p4
join FILE_UPLOAD_NAME_PART  as fup  on  fup.id = p4.partID
join FILE_UPLOAD_NAME_PARTS as fups on  fups.fileClassID = p4.fileClass 
                                    and fups.partID      = fup.id
where p4.partID = 9999
group by 
    partOrder
  , partName
  , partValue
)
,

/*###########################################################################
  # Create filename from parts and delimit with - and create extenstion
  # from parts and delimit with .  Then combine
  ###########################################################################*/  
  
cte_pass_6
as
(
 
select
   uploadID
  ,fileAsName = fileAsName1 + '.' + isnull(fileAsName2,'unknown')
from
(
  select 
      uploadID   = @uploadID 
    , fileAsName1 = stuff((select N'-' + partValue FROM cte_pass_5_filename FOR XML PATH(''),TYPE).value('text()[1]','nvarchar(max)'),1,1,N'')
    , fileAsName2 = stuff((select N'.' + partValue FROM cte_pass_5_fileext FOR XML PATH(''),TYPE).value('text()[1]','nvarchar(max)'),1,1,N'')
    
  ) as p61 
)
,

/*###########################################################################
  # Strip out pipes, commas and replace with underscores
  ###########################################################################*/  

cte_pass_7
as
(
select 
    uploadID
  , fileAsName = trim(replace((replace(fileAsName,'|','_')),',','_')) 
from cte_pass_6
)

/*###########################################################################
  # Output
  ###########################################################################*/  

insert into @recs
select * from cte_pass_7

return

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[FILE_UPLOAD_GENERATE_FILE_AS_NAME] TO [webuser]
GO