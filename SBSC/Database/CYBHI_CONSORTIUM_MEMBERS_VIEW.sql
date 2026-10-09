USE SPEDMON
GO

-- Drop if exists

IF EXISTS (
  SELECT * FROM sys.objects 
  WHERE object_id = OBJECT_ID('dbo.CYBHI_CONSORTIUM_MEMBERS_VIEW') 
    AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT')
)
DROP FUNCTION dbo.CYBHI_CONSORTIUM_MEMBERS_VIEW
GO

-- Create function

CREATE FUNCTION dbo.CYBHI_CONSORTIUM_MEMBERS_VIEW (
      @userID                   bigint
    , @userGroup                int
    , @userRank                 int
    , @consortiumLeadClientID   bigint
)
RETURNS TABLE
AS
RETURN (

  select top (dbo.CONST_MAX_ROWS())
    t1.* 
  from dbo.CYBHI_CONSORTIUM_MEMBERS_VIEW_CORE (@userID,@userGroup,@userRank,@consortiumLeadClientID) as t1
  order by 
    t1.leadClient desc
  , t1.[name]     asc

)
GO

-- Grant permission

GRANT SELECT ON dbo.CYBHI_CONSORTIUM_MEMBERS_VIEW TO [webuser]
GO
