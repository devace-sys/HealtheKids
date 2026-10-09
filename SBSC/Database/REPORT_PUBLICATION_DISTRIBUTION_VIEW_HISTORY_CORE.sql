USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.REPORT_PUBLICATION_DISTRIBUTION_VIEW_HISTORY_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION REPORT_PUBLICATION_DISTRIBUTION_VIEW_HISTORY_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[REPORT_PUBLICATION_DISTRIBUTION_VIEW_HISTORY_CORE]    
()    

RETURNS TABLE
 
 /***************************************************************************    
  * REPORT_PUBLICATION_DISTRIBUTION_VIEW_HISTORY_CORE */    
 /**    
  * Returns a core table containing report distribution history
  *
  * @return table 
  ***************************************************************************/                         
     
AS RETURN
(

/*============================================================
 * Report Distribution History Base
 *============================================================*/  

with 
RptDistHistBase
as
(
  select      

    /*-------------------------------
     * Get day of week for proc run
     * date
     *------------------------------*/

    DATENAME(dw,rdh.ProcRunDate) as [Run Date - Day Of Week],
     
    /*-------------------------------
     * Decode result flags
     *------------------------------*/
    
    dbo.DECODE_FLAG(ResultFlags, 1)         as [Is New],
    dbo.DECODE_FLAG(ResultFlags, 2)         as [Is Retry],
    dbo.DECODE_FLAG(ResultFlags, 4)         as [Not Run Date],
    dbo.DECODE_FLAG(ResultFlags, 8)         as [Is Run Date],
    dbo.DECODE_FLAG(ResultFlags, 16)        as [Not OK To Publish],
    dbo.DECODE_FLAG(ResultFlags, 32)        as [Is OK To Publish],
    dbo.DECODE_FLAG(ResultFlags, 64)        as [Config Error],
    dbo.DECODE_FLAG(ResultFlags, 128)       as [No Records],
    dbo.DECODE_FLAG(ResultFlags, 256)       as [Data Error],
    dbo.DECODE_FLAG(ResultFlags, 512)       as [File Error],
    dbo.DECODE_FLAG(ResultFlags, 1024)      as [Email Error],
    dbo.DECODE_FLAG(ResultFlags, 2048)      as [Schedule For Retry],
    dbo.DECODE_FLAG(ResultFlags, 4096)      as [No File Distributed],
    dbo.DECODE_FLAG(ResultFlags, 8192)      as [File Distributed],
    
    /*-------------------------------
     * All columns
     *------------------------------*/
    
    rdh.*  

  from dbo.REPORT_PUBLICATION_DISTRIBUTION_HISTORY as rdh
)
,

/*============================================================
 * Report Distribution History Base + Hierarchy Data
 * Note: This is a recursive CTE
 *============================================================*/  

RptDistHistHierarchy
as
(
   /*-------------------------------
    * All history records with no
    * children
    * 
    * Note: This is the anchor query
    * for the recursive calls    
    *------------------------------*/

  select    
    cast(CONVERT(varchar(1000),rd.id) as varchar(max)) as [chain], /* Chain of ids */
    0                                                  as [level], /* Depth */
    rd.*
  from RptDistHistBase as rd 
  where 
    PrevID is null
  
  union all
  
  /*-------------------------------
   * All history records that are
   * children
   * 
   * Note: This is the recursive
   * portion     
   *------------------------------*/
  
  select 
    rdh.chain + ' | ' + CONVERT(varchar(1000),rd.id) as [chain],
    rdh.[level] + 1                                  as [level],
    rd.*
  from RptDistHistBase as rd
  inner join RptDistHistHierarchy as rdh on rdh.id = rd.PrevID
)

/*============================================================
 * Generate rows
 * Note: Sort by chain to put records in order of parents
 * and children.
 *============================================================*/  

select * from RptDistHistHierarchy

)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[REPORT_PUBLICATION_DISTRIBUTION_VIEW_HISTORY_CORE] TO [webuser]
GO   
