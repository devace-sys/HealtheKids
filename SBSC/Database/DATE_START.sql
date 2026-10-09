USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.DATE_START') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.DATE_START
GO
/*-------------------------------
 * Object Definition
 *------------------------------*/
CREATE FUNCTION [dbo].[DATE_START](@datein DATETIME, @starton SMALLINT) 
RETURNS DATETIME 
WITH SCHEMABINDING 
AS     
BEGIN    
  DECLARE @startDate  AS DATETIME    
  DECLARE @startYear  AS INT    
  DECLARE @startMonth AS INT    
  DECLARE @startDay   AS INT    
  DECLARE @startTime      AS VARCHAR(13)    
  DECLARE @newDateStr     AS VARCHAR(10)    
  DECLARE @newDateTimeStr AS VARCHAR(23)    
      
  IF @datein  IS NULL SET @datein  = GETDATE()    
  IF @starton IS NULL SET @starton = 1 /* 1= start of day, 2= start of week, 3= start of month, 4= start of year*/    
      
  -- Default is start of day    
      
  SET @startMonth = DATEPART(month,@datein)    
  SET @startYear  = DATEPART(year, @datein)    
  SET @startDay   = DATEPART(day,  @datein)    
  SET @startTime  = ' 00:00:00.000'    
      
  -- TODO: Start of week    
  IF (@starton = 3)    
  BEGIN    
    -- Start of month    
    SET @startDay = 1    
  END    
  ELSE IF (@starton = 4)    
  BEGIN    
    -- Start of year    
    SET @startMonth = 1    
    SET @startDay   = 1    
  END    
        
  SET @newDateStr = CONVERT(VARCHAR(2),@startMonth) + '-' + CONVERT(VARCHAR(2),@startDay) + '-' + CONVERT(VARCHAR(4),@startYear)    
  SET @newDateTimeStr = @newDateStr + @startTime    
  SET @startDate = CONVERT(DATETIME,@newDateTimeStr)    
  RETURN @startDate    
      
END    
    
GO
