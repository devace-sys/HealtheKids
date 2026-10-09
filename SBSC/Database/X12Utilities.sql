/***************************************************************************    
 * X12Utilities */    
/**    
 * This is a set of general purpose utility functions to work with data that
 * is formatted using X12 EDI ANSI standards.
 *
 * The purpose of these functions is to be used as building blocks for more
 * specific document parsing modules.  There will not function on their own
 * to perform complete parsing of various files.
 *
 * Some of these fuctions make use of segment meta data from the X12Parser
 * project.  See: https://github.com/Inteligenz/X12Parser
 ***************************************************************************/  

USE SPEDMON
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.X12FindSegmentInGeneralSpec') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.X12FindSegmentInGeneralSpec
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.X12SegmentIsTopLevelTransactionTrailerSegment') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.X12SegmentIsTopLevelTransactionTrailerSegment
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.X12FindUnboundedLoopDataInTransactionSpec') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.X12FindUnboundedLoopDataInTransactionSpec
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.X12FindSegmentInTransactionSpec') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.X12FindSegmentInTransactionSpec
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.X12GenerateTransactionSegmentLoopMap') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.X12GenerateTransactionSegmentLoopMap
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.X12GetLoopDescFromLoopData') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.X12GetLoopDescFromLoopData
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.X12GetElementDescFromSegmentDataGeneral') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.X12GetElementDescFromSegmentDataGeneral
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.X12ParseX12SegmentsIntoX12Elements') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.X12ParseX12SegmentsIntoX12Elements
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.X12ParseX12FileContentsIntoX12Segments') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.X12ParseX12FileContentsIntoX12Segments
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.X12GenerateNameDescValueData') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.X12GenerateNameDescValueData
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.X12ParseFileContents') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.X12ParseFileContents
GO

IF EXISTS (select * from sys.table_types where name = 'X12Segments')
DROP TYPE X12Segments

IF EXISTS (select * from sys.table_types where name = 'X12Elements')
DROP TYPE X12Elements

IF EXISTS (select * from sys.table_types where name = 'X12SegmentLoopMap')
DROP TYPE X12SegmentLoopMap

/**********************************************************************************************************/

/*-------------------------------
 * Custom types
 *------------------------------*/

/***************************************************************************    
 * X12Segments */    
/**    
 * Various X12 Segments
 ***************************************************************************/   

 CREATE TYPE X12Segments AS TABLE
(
    idx                   bigint
  , tx_control_number     varchar(256)
  , tx_start_idx          bigint
  , tx_end_idx            bigint
  , segment_num           bigint       /* Relative to transaction set */
  , segment_name          varchar(10)
  , segment_level         smallint
  , element_seperator     char (1)
  , sub_element_seperator char (1)
  , data_elements         varchar(max)

    UNIQUE CLUSTERED  (idx)     
  , UNIQUE NONCLUSTERED (tx_control_number, tx_start_idx, tx_end_idx, idx)

)
GO


/**********************************************************************************************************/

/***************************************************************************    
 * X12Elements */    
/**    
 * Various X12 Elements
 ***************************************************************************/   

CREATE TYPE X12Elements AS table (
    idx                   bigint 
  , segment_idx           bigint
  , element_pos           bigint
  , element_ref           varchar(255)
  , sub_element_seperator char (1)
  , data_element          varchar(max)
 
  UNIQUE CLUSTERED    (idx)
, UNIQUE NONCLUSTERED (segment_idx, idx)

)

/**********************************************************************************************************/

/***************************************************************************    
 * X12SegmentLoopMap */    
/**    
 * Mapping of segments and loops
 ***************************************************************************/   

CREATE TYPE X12SegmentLoopMap as table (
    idx                           bigint 
  , segment_idx                   bigint  
  , segment_num                   bigint
  , segment_name                  varchar(255)
  , segment_data_general          xml
  , segment_data_transaction      xml
  , top_level_trailer_segment     bit
  , loop_starting_segment         bit
  , loop_name                     varchar(255)
  , loop_data                     xml
  unique clustered (idx)
)

/**********************************************************************************************************/

USE [spedmon]
GO

/***************************************************************************    
 * X12ParseX12FileContentsIntoX12Segments */    
/**    
 * Parses X12 EDI text in @fileContentsIn into X12Segments.
 * Uses just ANSI X12 EDI parsing rules.
 * This is transaction set specification independent.
 * NOTE: This routine assumes ONE function group per file.
 *
 * Multiple functions groups per file are allowed in the ANSI specification
 * but this parser does not support them.
 ***************************************************************************/   

CREATE FUNCTION [dbo].[X12ParseX12FileContentsIntoX12Segments] (  
    @fileContentsIn varchar (max)  
)
returns @segments table (
    idx                   bigint --identity(1,1)
  , tx_control_number     varchar(256)
  , tx_start_idx          bigint
  , tx_end_idx            bigint
  , segment_num           bigint       /* Relative to transaction set */
  , segment_name          varchar(10)
  , segment_level         smallint
  , element_seperator     char (1)
  , sub_element_seperator char (1)
  , data_elements         varchar(max)
  UNIQUE CLUSTERED    (idx)
)
AS
BEGIN

 /*============================================================
   *
   * !! THIS ROUTINE ASSUMES ONE FUNCTIONAL GROUP PER FILE !!
   *
   *============================================================*/

declare @fileContents as varchar(max)
declare @numChars     as int
declare @firstSegm    as varchar(107)
declare @firstElem    as varchar(3)
declare @segmTerm     as char
declare @elemSep      as char
declare @subElemSep   as char

declare @st   as table (control_number varchar(256), start_idx bigint)
declare @se   as table (control_number varchar(256), end_idx bigint)
declare @stse as table (idx bigint identity(1,1), control_number varchar(256), start_idx bigint, end_idx bigint)
declare @rankingWorkspace as table (idx bigint, pos bigint UNIQUE CLUSTERED (idx))


/*#############################################################################
  #                               TEST CONTENT
  #############################################################################*/

/*===========================================================
 * If there is no content then there is nothing to do.
 * Get out!  
 *============================================================*/  

set @fileContents = upper(trim(isnull(@fileContentsIn,'')))
if (@fileContents = '') return

/*===========================================================
 * If we have less than 107 characters this is an incomplete
 * or invalid X12 file.  Get out!
 *============================================================*/  

set @numChars = len(@fileContents)
if (@numChars < 107) return


/*===========================================================
 * If first 3 characters is not ISA then this is not a 
 * valid X12 file.  Get out!
 *============================================================*/  

set @firstSegm  = SUBSTRING (@fileContents, 1, 107)
set @firstElem  = SUBSTRING (@firstSegm,    1, 3)
if (@firstElem != 'ISA') return

/*#############################################################################
  #                           EXTRACT DELIMITERS
  #
  #   Note: The various delimiters used to parse an X12 file are stored in
  #   the first 106 characters.
  #############################################################################*/

set @segmTerm   = SUBSTRING (@firstSegm, 106, 1)  /* Segment terminator */
set @elemSep    = SUBSTRING (@firstSegm, 4, 1)    /* Element seperator */
set @subElemSep = SUBSTRING (@firstSegm, 105, 1)  /* Sub element seperator */

/*#############################################################################
  #                     PARSE CONTENTS INTO SEGMENTS
  #############################################################################*/

insert into @segments (
    idx
  , tx_control_number
  , tx_start_idx     
  , tx_end_idx       
  , segment_num      
  , segment_name     
  , segment_level    
  , element_seperator 
  , sub_element_seperator
  , data_elements    
)
select          
    idx                   = t1.position
  , tx_control_number     = null
  , tx_start_idx          = null
  , tx_end_idx            = null
  , segment_num           = null
  , segment_name          = trim(replace(left(t1.part,charindex(@elemSep, t1.part,1)),@elemSep,''))
  , segment_level         = null
  , element_seperator     = @elemSep
  , sub_element_seperator = @subElemSep
  , data_elements         = trim(isnull(t1.part,''))
from dbo.STRING_SPLIT_MAX (@fileContents,@segmTerm) as t1 /* Do not replace with native STRING_SPLIT until we have a version of MSSQL that supports returning ordinal position.  The ordinal position is pretty important for X12 files.*/
order by 
  t1.position

delete @segments where segment_name = ''

/*#############################################################################
  # ASSIGN INITIAL STRUCTURE TO SEGMENTS BASED ON ANSI STANDARDS FOR X12 EDI
  #############################################################################*/

/*===========================================================
 * Initial hierarchy
 *============================================================*/  

update @segments set segment_level = 1 where segment_name = 'ISA' 
update @segments set segment_level = 2 where segment_name = 'GS'  
update @segments set segment_level = 3 where segment_name = 'ST'  
update @segments set segment_level = 3 where segment_name = 'SE'  
update @segments set segment_level = 2 where segment_name = 'GE'  
update @segments set segment_level = 1 where segment_name = 'IEA' 
update @segments set segment_level = 4 where segment_level is null

/*===========================================================
 * Identify the segments that start and end transaction sets
 * and extract the transaction set control numbers.  
 *
 * Note: There is a unique control number per transaction set.  
 * We will use this this to partition transaction sets.
 *============================================================*/  

insert into @st (
    control_number 
  , start_idx 
)
select 
    control_number = convert(varchar(256),ev)
  , start_idx      = t4.idx
from
(
  select top (9999999999)
      t1.idx
	, t3.*
  from @segments as t1
  cross apply (
    select top (9999999999)
        ep = t2.position /*ROW_NUMBER() OVER(ORDER BY (SELECT 1))*/
	  , ev = t2.part
    from dbo.STRING_SPLIT_MAX(t1.data_elements,t1.element_seperator) as t2 /* Do not replace with native STRING_SPLIT until we have a version of MSSQL that supports returning ordinal position.  The ordinal position is pretty important for X12 files.*/
    order by 
	  t2.position	
  ) as t3
  where (t1.segment_level = 3) and (t1.segment_name = 'ST')
  order by 
    t1.idx
) as t4
where (t4.ep = 3)

insert into @se (
    control_number
  , end_idx
)
select 
    control_number = convert(varchar(256),ev)
  , end_idx        = t4.idx  
from
(
  select top (999999)
  t1.idx, t3.*
  from @segments as t1
  cross apply (
    select top (9999999999)
        ep = t2.position /*ROW_NUMBER() OVER(ORDER BY (SELECT 1))*/
	  , ev = t2.part
    from dbo.STRING_SPLIT_MAX(t1.data_elements,t1.element_seperator) as t2 /* Do not replace with native STRING_SPLIT until we have a version of MSSQL that supports returning ordinal position.  The ordinal position is pretty important for X12 files.*/
	order by 
	  t2.position
  ) as t3
  where (t1.segment_level = 3) and (t1.segment_name = 'SE')
  order by 
    t1.idx
) as t4
where (t4.ep = 3)

/*===========================================================
 * Identify which segments (start and end indexs) 
 * belong to distinct transaction sets.
 *============================================================*/  

insert into @stse (
    control_number
  , start_idx
  , end_idx
)
select 
    t1.control_number
  , t1.start_idx
  , t2.end_idx 
from @st as t1
join @se as t2 on t2.control_number = t1.control_number
order by 
  t1.control_number

/*===========================================================
 * Assign these segments to their transaction set control
 * numbers
 *============================================================*/  

update t2
set 
      t2.tx_control_number = t1.control_number
	, t2.tx_start_idx      = t1.start_idx
	, t2.tx_end_idx        = t1.end_idx
from @stse     as t1
join @segments as t2 on t2.idx between t1.start_idx and t1.end_idx

/*===========================================================
 * Compute a segment position relative to its transaction set
 * partition.
 *============================================================*/  

insert into @rankingWorkspace (
   idx
  ,pos
)  
select 
    idx
  , pos =  DENSE_RANK() over (partition by t1.tx_control_number order by t1.idx)
from @segments as t1
where 
  (t1.segment_level >= 3)

/*===========================================================
 * Assign segment positions.
 *============================================================*/  

update t1
  set t1.segment_num = t2.pos     
from @segments         as t1
join @rankingWorkspace as t2 on t2.idx = t1.idx
where 
  (t1.segment_level >=3)

return

END
GO


/**********************************************************************************************************/

USE [spedmon]
GO

/***************************************************************************    
 * X12ParseX12FileContentsIntoX12Elements */    
/**    
 * Parses X12Segments in @X12Segments into X12Elements.
 * Uses just ANSI X12 EDI parsing rules.
 * This is transaction set specification independent.
 ***************************************************************************/   

CREATE FUNCTION [dbo].[X12ParseX12SegmentsIntoX12Elements] (
  @x12Segments X12Segments READONLY
)

returns @elements table (
    idx                   bigint
  , segment_idx           bigint
  , element_pos           bigint
  , element_ref           varchar(255)
  , sub_element_seperator char (1)
  , data_element          varchar(max)
  UNIQUE CLUSTERED    (idx)  
)
AS
BEGIN
/*
declare @rankingWorkspace as table (
    idx      bigint
  , pos      bigint 
  UNIQUE CLUSTERED (idx)
)
*/
insert into @elements (
    idx   
  , segment_idx
  , element_pos
  , element_ref
  , sub_element_seperator
  , data_element         
)
select 
     idx                   = ROW_NUMBER() over (order by t1.idx, t3.position)
   , segment_idx           = t1.idx
   , element_pos           = t3.position -- null
   , element_ref           = null
   , sub_element_seperator = t1.sub_element_seperator
   , data_element          = t3.part
from @x12Segments as t1
cross apply (
  select top (9999999999)
    t2.* 
  from dbo.STRING_SPLIT_MAX(t1.data_elements,t1.element_seperator) as t2 /* Do not replace with native STRING_SPLIT until we have a version of MSSQL that supports returning ordinal position.  The ordinal position is pretty important for X12 files.*/ 
  order by 
    t2.position
) as t3
order by 
  t1.idx
, t3.position

/*============================================================
  * Compute element position relative to its siblings
  *============================================================*/  
/*
insert into @rankingWorkspace (
    idx
  , pos
)
select 
    idx
  , pos =  DENSE_RANK() over (partition by segment_idx order by idx)
from @elements

update t1
  set t1.element_pos = t2.pos     
from @elements         as t1
join @rankingWorkspace as t2 on t2.idx = t1.idx
*/
/*============================================================
 * Generate element reference (text with leading 0).
 * The max # of elements is less than 99.
 *============================================================*/  

update t1
  set t1.element_ref = FORMAT((t1.element_pos - 1),'0#') 
from @elements as t1
where (t1.element_pos > 0)
     
return

END
GO

/***************************************************************************    
 * X12FindSegmentInGeneralSpec */    
/**    
 * Finds segment specification rules for @segmentName in @x12GeneralSpec
 *
 * This is general ANSI X12 segment data.
 * The segment data was imported from the X12Parser project 
 * See: https://github.com/Inteligenz/X12Parser
 ***************************************************************************/   

USE [spedmon]
GO

CREATE FUNCTION [dbo].[X12FindSegmentInGeneralSpec] (
     @segmentName     varchar(255)
   , @x12GeneralSpec  XML
)
returns XML
AS
BEGIN
  declare @x12Seg as xml
  set @x12Seg = @x12GeneralSpec.query('/SegmentSet/Segment[@SegmentId=sql:variable("@segmentName")]')
  return @x12Seg
END

GO

/**********************************************************************************************************/

USE [spedmon]
GO

/***************************************************************************    
 * X12SegmentIsTopLevelTransactionTrailerSegment */    
/**    
 * Returns true if @segmentName is flagged as a top level transaction trailer
 * segment in the segment specification rules for @segmentName in @x12TransactionSpec
 *
 * This is transaction set specific data.
 * The segment data was imported from the X12Parser project 
 * See: https://github.com/Inteligenz/X12Parser
 ***************************************************************************/   
 
CREATE FUNCTION [dbo].[X12SegmentIsTopLevelTransactionTrailerSegment] (
     @segmentName          varchar(255)
   , @x12TransactionSpec   XML
)
returns bit
AS
BEGIN  
  declare @data1 as xml
  declare @data2 as xml
  set @data1 = @x12TransactionSpec.query('/TransactionSpecification/Segment[@SegmentId=sql:variable("@segmentName")]')
  set @data2 = @data1.query('/Segment[@Trailer="true"]')
  if ((@data2 is null) or (@data2.exist('*') = 0)) return 0
  return 1
END

GO

/**********************************************************************************************************/

USE [spedmon]
GO

/***************************************************************************    
 * X12FindUnboundedLoopDataInTransactionSpec */    
/**    
 * Finds unbounded loop specification rules for @startingSegmentName and 
 * @entityIdentifer in @x12TransactionSpec.
 *
 * This is transaction set specific data.
 * The segment data was imported from the X12Parser project 
 * See: https://github.com/Inteligenz/X12Parser
 ***************************************************************************/   

CREATE FUNCTION [dbo].[X12FindUnboundedLoopDataInTransactionSpec] (
      @startingSegmentName    varchar(255)
	, @entityIdentifer        varchar(255)
    , @x12TransactionSpec     XML
)
returns xml
AS
BEGIN
  
  declare @loopData as xml
  
  /*============================================================
   * First see if a loop exists in the transaction spec that has
   * a specific starting segment name AND entity identifier.
   *============================================================*/  
  
  select
    @loopData = l.c.query('.')
  from  @x12TransactionSpec.nodes('/TransactionSpecification//Loop//StartingSegment[@SegmentId=sql:variable("@startingSegmentName")]/EntityIdentifier[@Code=sql:variable("@entityIdentifer")]') as m(c)
  cross apply m.c.nodes ('..') as t(c)
  cross apply t.c.nodes('..') as l(c)
  
  /*============================================================
   * If no loop has been found then see if a loop exists in the
   * transaction spec that has just a specific starting segment
   * name.
   *============================================================*/  
  
  if ((@loopData is null) or (@loopData.exist('*') = 0))
  begin
    select
      @loopData = m.c.query('..')
    from @x12TransactionSpec.nodes('/TransactionSpecification//Loop//StartingSegment[@SegmentId=sql:variable("@startingSegmentName")]') as m(c)
  end

  /*============================================================
   * If no loop has been found then one probably does not exist
   * in the transaction spec.  
   *============================================================*/  

  if ((@loopData is null) or (@loopData.exist('*') = 0))
  begin
    set @loopData = null
  end

  return @loopData

END

GO

/**********************************************************************************************************/

USE [spedmon]
GO

/***************************************************************************    
 * X12FindSegmentInTransactionSpec */    
/**    
 * Finds specification rules for @loopName, @loopStartingSegment, 
 * and @segmentName in @x12TransactionSpec.
 *
 * This is transaction set specific data.
 * The segment data was imported from the X12Parser project 
 * See: https://github.com/Inteligenz/X12Parser
 ***************************************************************************/   

CREATE FUNCTION [dbo].[X12FindSegmentInTransactionSpec] (     
     @loopName            varchar(255)
   , @loopStartingSegment bit
   , @segmentName         varchar(255)
   , @x12TransactionSpec  XML
)
returns XML
AS
BEGIN
  declare @x12Seg as xml
  
  if (@loopName = '')
  begin
    set @x12Seg = @x12TransactionSpec.query('/TransactionSpecification/Segment[@SegmentId=sql:variable("@segmentName")]')
  end
  else
  begin
    if (@loopStartingSegment = 1)
	begin
	   set @x12Seg = @x12TransactionSpec.query('/TransactionSpecification//Loop[@LoopId=sql:variable("@loopName")]//StartingSegment[@SegmentId=sql:variable("@segmentName")]')
    end
	else
	begin
	  set @x12Seg = @x12TransactionSpec.query('/TransactionSpecification//Loop[@LoopId=sql:variable("@loopName")]//Segment[@SegmentId=sql:variable("@segmentName")]')
	end
  end

  return @x12Seg
END

GO


/**********************************************************************************************************/

USE [spedmon]
GO

/***************************************************************************    
 * X12GetLoopDescFromLoopData */    
/**    
 * Returns name of loop that matches @loopName in @loopData.
 * @loopData is a subset of data from what would be found in 
 * @x12TransactionSpec in other related functions.
 *
 * This is transaction set specific data.
 * The data was imported from the X12Parser project 
 * See: https://github.com/Inteligenz/X12Parser
 ***************************************************************************/   

CREATE FUNCTION [dbo].[X12GetLoopDescFromLoopData] (
     @loopName           varchar(255)
   , @loopData           XML
)
returns varchar(512)
AS
BEGIN
  declare @loopDesc as varchar(512) = ''
  if (@loopName = '') return @loopDesc
  if ((@loopData is null) or (@loopData.exist('*') = 0)) return @loopDesc
  set @loopDesc = @loopData.value('(/Loop[@LoopId=sql:variable("@loopName")]/Name)[1]','varchar(512)')  
  return @loopDesc
END

GO

/**********************************************************************************************************/

USE [spedmon]
GO

/***************************************************************************    
 * X12GetElementDescFromSegmentDataGeneral */    
/**    
 * Returns description of element that matches @segmentName and @elementRef
 * in @segmentDataGeneral.
 *
 * @segmentDataGeneral is a subset of data from what would be found in 
 * @x12GeneralSpec in other related functions.
 *
 * This is general ANSI X12 segment data.
 * The data was imported from the X12Parser project 
 * See: https://github.com/Inteligenz/X12Parser
 ***************************************************************************/   

 CREATE FUNCTION [dbo].[X12GetElementDescFromSegmentDataGeneral] (
     @segmentName         varchar(255)
   , @elementRef          varchar(255)
   , @segmentDataGeneral  XML
)
returns varchar(512)
AS
BEGIN
  declare @data1 as xml
  declare @elementDesc as varchar(512)
  set @data1       = @segmentDataGeneral.query('/Segment[@SegmentId=sql:variable("@segmentName")]/Element[@Reference=sql:variable("@elementRef")]')
  set @elementDesc =  @data1.value('(/Element/@Name)[1]','varchar(512)')
  return @elementDesc
END

GO

/**********************************************************************************************************/

/***************************************************************************    
 * X12GenerateTransactionSegmentLoopMap */    
/**    
 * Generates a mapping of segments to loops. 
 *
 * @x12GeneralSpec       This is general ANSI X12 segment data.
 * @x12TransactionSpec   This is transaction specific X12 segment data
 *
 * THIS ROUTINE ONLY SUPPORTS UNBOUNDED LOOPS AT PRESENT !!
 * Transaction sets that contain hierarchal loop sets like the 837 are NOT
 * supported at present
 *
 * The X12 data was imported from the X12Parser project 
 * See: https://github.com/Inteligenz/X12Parser
 ***************************************************************************/   

USE [spedmon]
GO

CREATE FUNCTION [dbo].[X12GenerateTransactionSegmentLoopMap] (   
     @x12GeneralSpec          XML
   , @x12TransactionSpec      XML   
   , @x12Segments X12Segments READONLY
   , @x12Elements X12Elements READONLY
   , @findLoopAndSegmentDesc bit
)

returns @loopMap table (
    idx                           bigint identity(1,1)
  , segment_idx                   bigint  
  , segment_num                   bigint
  , segment_name                  varchar(255)
  , segment_data_general          xml
  , segment_data_transaction      xml
  , top_level_trailer_segment     bit
  , loop_starting_segment         bit
  , loop_name                     varchar(255)
  , loop_data                     xml  
  
  unique clustered (idx)
)
AS
BEGIN
  
  /*============================================================
   *
   * !! THIS ROUTINE ONLY SUPPORTS UNBOUNDED LOOPS AT PRESENT !!
   *
   *============================================================*/  

  declare @minIdx           as bigint
  declare @maxIdx           as bigint
  declare @curIdx           as bigint
  declare @prev_loop_name   as varchar(255)
  declare @curr_loop_name   as varchar(255)

  declare @generalSegmentSpecs table (
      segment_name       varchar(255)
    , segment_data       xml    
    unique clustered (segment_name)
  )

 declare @transactionSegmentSpecs table (
      loop_name               varchar(255)
	, segment_name            varchar(255)
	, loop_starting_segment   bit	
    , segment_data            xml    
    unique clustered (loop_name, segment_name)
  )

 declare @loopSpecs table (
      loop_name             varchar(255)
    , loop_data             xml    
    unique clustered (loop_name)
 )

 /*============================================================
   * Get general segment data
   *============================================================*/  

  if ( @findLoopAndSegmentDesc = 1)
  begin
    insert into @generalSegmentSpecs
    select distinct segment_name, null as segment_spec from @x12Segments
    update @generalSegmentSpecs set segment_data = dbo.X12FindSegmentInGeneralSpec(segment_name, @x12GeneralSpec)
    option (recompile)
  end

  /*============================================================
   * Identify loops by their starting segment names and entity
   * identfier elements.  Note: This is why we need to pass in
   * the parsed elements.  Also identify which segments are
   * top level transaction trailer segments.  These segments
   * need to be excluded from loop membership.
   *============================================================*/  

  insert into @loopMap
  select 
      segment_id                 = segs.idx 
    , segment_num                = segs.segment_num
	, segment_name               = segs.segment_name
	, segment_data_general       = null
	, segment_data_transaction   = null
	, top_level_trailer_segment  = dbo.X12SegmentIsTopLevelTransactionTrailerSegment (segs.segment_name, @x12TransactionSpec)
	, loop_starting_segment      = null
	, loop_name                  = null
	, loop_data                  = dbo.X12FindUnboundedLoopDataInTransactionSpec(segs.segment_name, elms.data_element, @x12TransactionSpec)  
  from @x12Segments  as segs
  join @x12Elements  as elms on elms.segment_idx = segs.idx
  where 
    ((segs.segment_level = 4) and (elms.element_pos = 2))
  order by 
    segs.segment_num
  option (recompile)
    
  /*============================================================
   * Update loop map with general spec segment data
   *============================================================*/  

  if ( @findLoopAndSegmentDesc = 1)
  begin
    update t1
      set t1.segment_data_general = t2.segment_data
    from @loopMap as t1
    join @generalSegmentSpecs as t2 on t2.segment_name = t1.segment_name
    option (recompile)
  end

  /*============================================================
   * Set loop names for the starting segments
   *============================================================*/  
  
  update @loopMap 
    set  loop_name = loop_data.value('(/Loop/@LoopId)[1]','varchar(255)') 
  where (loop_name is null)
  
  /*============================================================
   * Flag the starting segments
   *============================================================*/  

  update @loopMap
    set loop_starting_segment = 1
  where (loop_name is not null)
  option (recompile)

  update @loopMap
    set loop_starting_segment = 0
  where (loop_name is null)
  option (recompile)
 
  /*============================================================
   * Identify loops membership for all other segments
   *============================================================*/  

  select @minIdx = min(idx) from @loopMap option (recompile)
  select @maxIdx = max(idx) from @loopMap option (recompile)
  select @curIdx = @minIdx

  while (@curIdx <= @maxIdx)
  begin    
	select top 1 @prev_loop_name = isnull(loop_name,'') from @loopMap where (idx = @curIdx - 1) option (recompile)
	select top 1 @curr_loop_name = isnull(loop_name,'') from @loopMap where (idx = @curIdx )    option (recompile)
	if ((@curr_loop_name = '') and (@prev_loop_name != @curr_loop_name)) 
	begin	  
	  update @loopMap set loop_name = @prev_loop_name where ((idx = @curIdx) and (top_level_trailer_segment = 0)) option (recompile)
	end
	set @curIdx = @curIdx + 1
  end

  update @loopMap set loop_name = '' where (loop_name is null) option (recompile)

  /*============================================================
   * Find transaction segment data
   *============================================================*/  
 
 insert into @transactionSegmentSpecs 

 select distinct 
      loop_name              
	, segment_name         
	, loop_starting_segment
	, null as segment_data
 from @loopMap
 option (recompile)

 update @transactionSegmentSpecs set segment_data = dbo.X12FindSegmentInTransactionSpec (loop_name, loop_starting_segment, segment_name, @x12TransactionSpec) option (recompile)

 /*============================================================
  * Update loop map with transaction segment data
  *============================================================*/  
 
 update t1
   set t1.segment_data_transaction = t2.segment_data
 from @loopMap as t1
 join @transactionSegmentSpecs as t2 on  t2.loop_name             = t1.loop_name
                                     and t2.segment_name          = t1.segment_name
                                     and t2.loop_starting_segment = t1.loop_starting_segment
 where (t1.segment_data_transaction is null)
 option (recompile)

 /*============================================================
  * Generate loop specs lookup table 
  *============================================================*/  

 insert into @loopSpecs
 select distinct loop_name, null as loop_data 
 from @loopMap
 where (loop_starting_segment = 1)
 option (recompile)

 update t2
   set t2.loop_data = t1.loop_data
 from @loopMap   as t1
 join @loopSpecs as t2 on  t2.loop_name  = t1.loop_name
 where (t1.loop_starting_segment = 1)
 option (recompile)

 /*============================================================
  * Update loop map
  *============================================================*/  

 update t1
   set t1.loop_data = t2.loop_data
 from @loopMap   as t1
 join @loopSpecs as t2 on  t2.loop_name  = t1.loop_name
 where (t1.loop_name != '')
 option (recompile)


 return 

END
GO

/**********************************************************************************************************/

USE [spedmon]
GO

/***************************************************************************    
 * X12GenerateNameDescValueData */    
/**    
 * Parses @x12Segments and @x12Loops into name, description, value records
 *
 ***************************************************************************/   

CREATE FUNCTION [dbo].[X12GenerateNameDescValueData] (           
     @x12Segments       X12Segments       READONLY
   , @x12Elements       X12Elements       READONLY
   , @x12SegmentLoopMap X12SegmentLoopMap READONLY
   , @findLoopAndSegmentDesc              bit
)
returns table 
as
return
(  

select
    segs.idx
  , segs.segment_num
  , map.loop_name 
  , loop_desc          = case when (@findLoopAndSegmentDesc = 1) then dbo.X12GetLoopDescFromLoopData ( map.loop_name, map.loop_data) else null end
  , segs.segment_name  
  , elms.element_pos
  , elms.element_ref    
  , element_desc       = case when (@findLoopAndSegmentDesc = 1) then dbo.X12GetElementDescFromSegmentDataGeneral (segs.segment_name,elms.element_ref,map.segment_data_general) else null end
  , element_value      = elms.data_element
  , elms.sub_element_seperator

from @x12Segments        as segs
join @x12Elements        as elms on elms.segment_idx = segs.idx
join @x12SegmentLoopMap  as map  on map.segment_idx  = segs.idx

)
 
GO

/**********************************************************************************************************/

USE [spedmon]
GO

/***************************************************************************    
 * X12ParseFileContents */    
/**    
 * Entry point function.
 * Use this to build more specific parsers.
 ***************************************************************************/   

CREATE FUNCTION [dbo].[X12ParseFileContents] (   
     @x12GeneralSpec          XML
   , @x12TransactionSpec      XML
   , @fileID                  bigint
   , @fileContents            varchar(max)
   , @findLoopAndSegmentDesc  bit      
)
returns @data table (
    file_id                       bigint
  , tx_control_number             varchar(255)
  , segment_idx                   bigint
  , segment_num                   bigint
  , loop_name                     varchar(255)
  , loop_desc                     varchar(512)
  , segment_name                  varchar(255)
  , element_pos                   bigint
  , element_ref                   varchar(255)
  , element_desc                  varchar(512)
  , element_value                 varchar(max)
  , sub_element_seperator         char(1)
)
AS
BEGIN

 /*============================================================
   *
   * !! THIS ROUTINE ASSUMES ONE FUNCTIONAL GROUP PER FILE !!
   *
   *============================================================*/

  declare @startTx           as bigint
  declare @endTx             as bigint
  declare @curTx             as bigint
  declare @tx_control_number as varchar(256)
  declare @tx_start_idx      as bigint
  declare @tx_end_idx        as bigint
  declare @x12SegmentsAll    as X12Segments 
  declare @x12SegmentsTx     as X12Segments
  declare @x12ElementsTx     as X12Elements
  declare @x12LoopMapTx      as X12SegmentLoopMap

  declare @txSets as table (
      idx                   bigint identity(1,1)
    , tx_control_number     varchar(256)
    , tx_start_idx          bigint
    , tx_end_idx            bigint
  )

  insert into @x12SegmentsAll (
     idx                   
    , tx_control_number     
    , tx_start_idx          
    , tx_end_idx            
    , segment_num           
    , segment_name          
    , segment_level         
    , element_seperator     
    , sub_element_seperator 
    , data_elements         
  )
  select 
      idx                   
    , tx_control_number     
    , tx_start_idx          
    , tx_end_idx            
    , segment_num           
    , segment_name          
    , segment_level         
    , element_seperator     
    , sub_element_seperator 
    , data_elements         
  from dbo.X12ParseX12FileContentsIntoX12Segments(@fileContents)
  order by 
    idx  /* We need the segments in the same order they are in the file */

  insert into @txSets (
      tx_control_number
    , tx_start_idx
    , tx_end_idx 
  )
  select 
      tx_control_number
    , tx_start_idx
    , tx_end_idx 
  from @x12SegmentsAll 
  where 
    (segment_level >= 3)
  group by
      tx_control_number
    , tx_start_idx
    , tx_end_idx 
  order by
      tx_control_number
    , tx_start_idx
    , tx_end_idx 
  
  select @startTx = min(idx) from @txSets --option (recompile)
  select @endTx   = max(idx) from @txSets --option (recompile)
  select @curTx   = @startTx

  while (@curTx <= @endTx)
  begin

    set @tx_control_number = null
    set @tx_start_idx      = null  
    set @tx_end_idx        = null
  
    delete @x12SegmentsTx
    delete @x12ElementsTx   
    delete @x12LoopMapTx 

    select top 1     
	    @tx_control_number = ts.tx_control_number
      , @tx_start_idx      = ts.tx_start_idx
	  , @tx_end_idx        = ts.tx_end_idx
    from @txSets as ts
    where (ts.idx = @curTx)
    option (recompile)

    insert into @x12SegmentsTx
    select 
	  t1.* 
	from @x12SegmentsAll as t1
    where 
	  (t1.idx between @tx_start_idx and @tx_end_idx)
	order by 
	  t1.idx /* Need these in same order as file */
    option (recompile)

    insert into @x12ElementsTx   
    select 
	  t1.* 
	from dbo.X12ParseX12SegmentsIntoX12Elements(@x12SegmentsTx) as t1
    option (recompile)
		
    insert into @x12LoopMapTx 
    select * from dbo.X12GenerateTransactionSegmentLoopMap (@x12GeneralSpec, @x12TransactionSpec, @x12SegmentsTx , @x12ElementsTx,  @findLoopAndSegmentDesc)
    option (recompile)

    insert into @data
	select    
      file_id           = @fileID  
	, tx_control_number = @tx_control_number
	, segment_idx       = t1.idx
	, segment_number    = t1.segment_num - 1
	, t1.loop_name
	, t1.loop_desc
	, t1.segment_name
	, t1.element_pos
	, t1.element_ref
	, t1.element_desc
	, t1.element_value
	, t1.sub_element_seperator
	
    from dbo.X12GenerateNameDescValueData (@x12SegmentsTx, @x12ElementsTx ,@x12LoopMapTx, @findLoopAndSegmentDesc) as t1
	option (recompile)

    set @curTx = @curTx + 1
	  
  end


  return
END
GO

/**********************************************************************************************************/

GRANT EXECUTE ON TYPE::X12Segments       TO [webuser]
GRANT EXECUTE ON TYPE::X12Elements       TO [webuser]
GRANT EXECUTE ON TYPE::X12SegmentLoopMap TO [webuser]

GRANT EXECUTE ON  [dbo].[X12FindUnboundedLoopDataInTransactionSpec]       TO [webuser]
GRANT EXECUTE ON  [dbo].[X12SegmentIsTopLevelTransactionTrailerSegment]   TO [webuser]
GRANT EXECUTE ON  [dbo].[X12FindSegmentInGeneralSpec]                     TO [webuser]
GRANT EXECUTE ON  [dbo].[X12FindSegmentInTransactionSpec]                 TO [webuser]
GRANT SELECT  ON  [dbo].[X12GenerateTransactionSegmentLoopMap]            TO [webuser]
GRANT SELECT  ON  [dbo].[X12ParseX12SegmentsIntoX12Elements]              TO [webuser]
GRANT SELECT  ON  [dbo].[X12ParseX12FileContentsIntoX12Segments]          TO [webuser]
GRANT EXECUTE ON  [dbo].[X12GetLoopDescFromLoopData]                      TO [webuser]
GRANT EXECUTE ON  [dbo].[X12GetElementDescFromSegmentDataGeneral]         TO [webuser]
GRANT SELECT  ON  [dbo].[X12GenerateNameDescValueData]                    TO [webuser]
GRANT SELECT  ON  [dbo].[X12ParseFileContents]                            TO [webuser]

GO

