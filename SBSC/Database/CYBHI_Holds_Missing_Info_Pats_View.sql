USE SPEDMON
GO

-- Drop if exists

IF EXISTS (
  SELECT * FROM sys.objects 
  WHERE object_id = OBJECT_ID('dbo.CYBHI_Holds_Missing_Info_Pats_View') 
    AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT')
)
DROP FUNCTION dbo.CYBHI_Holds_Missing_Info_Pats_View
GO

/* TODO: Remove this file once all platforms have run this */