USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.STRUCTURED_DATA_IMPORT_GET_INPUT_DATA') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.STRUCTURED_DATA_IMPORT_GET_INPUT_DATA
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION dbo.STRUCTURED_DATA_IMPORT_GET_INPUT_DATA (
  @importDataJSON as varchar(max)
)
     
RETURNS
TABLE
AS
return
( 


with
cte_p1
as
(
  /*-------------------------------
   * Get rows and cell values
   * cell values are in JSON arr
   *------------------------------*/

  select 
      [inputRowNum] = sheetData1.[key]
    , [cells]       = sheetData1.[value]
  FROM OPENJSON(@importDataJSON,'$."inputDataObj"."sheetData"') as sheetData1
)
,

cte_p2
as
(
  /*-------------------------------
   * For each row
   *------------------------------*/

  select 
      p1.inputRowNum 
    , row2.inputFieldIdx
    , row2.inputFieldValue
  from cte_p1 as p1
  
  /*-------------------------------
   * Extract cell values
   *------------------------------*/

  cross apply
  (
    select 
        inputFieldIdx   = row1.[key]
      , inputFieldValue = row1.[value]
    from OPENJSON(p1.[cells]) as row1
  ) as row2
)

select 
    inputRowNum    = convert(int,p2.inputRowNum)
  , inputFieldIdx  = convert(int,p2.inputFieldIdx)
  , inputFieldName = hd.[value]
  , p2.inputFieldValue 
from cte_p2 as p2

/*-------------------------------
 * Get field names from 
 * header array
 *------------------------------*/

join OPENJSON(@importDataJSON,'$."inputDataObj"."hdrArr"') as hd on hd.[key] = p2.inputFieldIdx

)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON [dbo].[STRUCTURED_DATA_IMPORT_GET_INPUT_DATA] TO [webuser]
GO
