USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.STRUCTURED_DATA_IMPORT_GET_FIELD_MAPPING') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.STRUCTURED_DATA_IMPORT_GET_FIELD_MAPPING
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION dbo.STRUCTURED_DATA_IMPORT_GET_FIELD_MAPPING (
  @importDataJSON as varchar(max)
)
     
RETURNS TABLE
AS 
RETURN
(
 
 /*-------------------------------
  * Input data to output data
  * field mapping
  *------------------------------*/

  select 
      t1.inputFieldIdx
    , t1.inputFieldName
    , t1.outputFieldIdx
    , t1.outputFieldName

  FROM OPENJSON(@importDataJSON,'$."inputOutputFieldMatches"')
  WITH (
	      [inputFieldIdx]     int          '$."inputFieldIdx"'
        , [inputFieldName]    varchar(256) '$."inputFieldName"'
        , [outputFieldIdx]    int          '$."outputFieldIdx"'
	    , [outputFieldName]   varchar(256) '$."outputFieldName"'
  ) as t1
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON [dbo].[STRUCTURED_DATA_IMPORT_GET_FIELD_MAPPING] TO [webuser]
GO
