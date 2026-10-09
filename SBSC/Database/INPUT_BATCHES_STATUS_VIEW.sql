USE [spedmon]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[INPUT_BATCHES_STATUS_VIEW]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[INPUT_BATCHES_STATUS_VIEW]
GO

USE [spedmon]
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[INPUT_BATCHES_STATUS_VIEW] (
    @id             bigint
  , @status_code    varchar(1000)
)

RETURNS TABLE 
AS
RETURN 
(

/***************************************************************************
 * INPUT_BATCHES_STATUS_VIEW */
/**
 * Displays 
 *
 * @return                 Table of batch status codes and descriptions
 ***************************************************************************/ 

SELECT TOP 1000
      [Status_Code] AS id
      ,[id] AS [db_row_id]
      ,[Status] AS [status_code_descrip]
      ,[name] = [Status]
  FROM [spedmon].[dbo].[Input_Batches_Status]
  WHERE ((@status_code is null)
   or (Cast([Status_Code] AS VARCHAR(4)) like (('%' + @status_code + '%'))) or ([Status] like (('%' + @status_code + '%'))))
  ORDER BY Status_Code 
 
)
GO

GRANT SELECT ON [spedmon].[dbo].[INPUT_BATCHES_STATUS_VIEW] TO [webuser]
GO